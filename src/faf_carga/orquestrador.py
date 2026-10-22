"""Execução completa da carga: trava, checagem da data de origem, endpoints, status final."""

import logging

from . import carga, controle_padrao, db
from . import log as logconf
from .api_client import ClienteFaF
from .catalogo import CATALOGO, Endpoint
from .config import Config

log = logging.getLogger(__name__)

# códigos de saída
OK, ERRO, EM_EXECUCAO, PARCIAL = 0, 1, 2, 3
CODIGO_POR_STATUS = {"SUCESSO": OK, "IGNORADA": OK, "ERRO": ERRO, "SUCESSO_PARCIAL": PARCIAL, "INCONSISTENTE": PARCIAL}


class ErroEndpoint(Exception):
    pass


def selecionar_endpoints(pedidos: str | None) -> list[Endpoint]:
    """'programas,/planos-acao' -> endpoints do catálogo, na ordem do catálogo. None = todos."""
    if not pedidos:
        return list(CATALOGO)
    nomes = {"/" + p.strip().lstrip("/") for p in pedidos.split(",") if p.strip()}
    validos = {e.endpoint for e in CATALOGO}
    if desconhecidos := sorted(nomes - validos):
        raise ErroEndpoint(
            f"endpoint(s) desconhecido(s): {', '.join(desconhecidos)}. Válidos: {', '.join(sorted(validos))}"
        )
    return [e for e in CATALOGO if e.endpoint in nomes]


def status_final(dt_origem, dt_origem_fim, resultados, parcial: bool) -> str:
    if dt_origem_fim != dt_origem:
        return "INCONSISTENTE"  # a origem mudou durante a carga; a próxima execução refaz tudo
    ok = sum(r.status == "SUCESSO" for r in resultados)
    if ok == 0:
        return "ERRO"
    if ok < len(resultados) or parcial:  # execução parcial nunca vale como carga completa
        return "SUCESSO_PARCIAL"
    return "SUCESSO"


def _resumo(resultados) -> str:
    log.info("%-45s %6s %10s %10s %7s  %s", "endpoint", "págs", "total API", "gravado", "seg", "status")
    for r in resultados:
        log.info("%-45s %6s %10s %10s %7.0f  %s", r.endpoint, r.paginas or "-", r.total_items_api or "-",
                 r.linhas_gravadas if r.linhas_gravadas is not None else "-", r.duracao, r.status)
    erros = [f"{r.endpoint}: {r.mensagem}" for r in resultados if r.status != "SUCESSO"]
    ok = len(resultados) - len(erros)
    return f"{ok}/{len(resultados)} endpoints ok" + ("; " + " | ".join(erros) if erros else "")


def _encerrar(conn, id_execucao, id_dia, status, dt_origem_fim, mensagem, resultados=()):
    db.encerrar_execucao(conn, id_execucao, status, dt_origem_fim, mensagem)
    controle_padrao.finalizar_dia(conn, id_dia, status, resultados, len(CATALOGO), mensagem)


def executar(cfg: Config, forcar: bool = False, pedidos: str | None = None, *, cliente=None,
             carregar=carga.carregar_endpoint) -> int:
    """Roda uma carga. Devolve o código de saída (0 ok/ignorada, 1 erro, 2 já em execução, 3 parcial/inconsistente)."""
    try:
        endpoints = selecionar_endpoints(pedidos)
    except ErroEndpoint as e:
        log.error("%s", e)
        return ERRO

    conn = db.conectar(cfg)
    proprio = cliente is None
    cliente = cliente or ClienteFaF(cfg)
    id_execucao = id_dia = None
    try:
        if not db.obter_trava(conn):
            log.error("Já existe uma carga em execução (trava do banco ocupada); nada foi feito.")
            return EM_EXECUCAO
        try:
            if n := db.marcar_interrompidas(conn):
                log.warning("%d execução(ões) anterior(es) ficaram EM_ANDAMENTO e foram marcadas como ERRO", n)
            id_execucao = db.iniciar_execucao(conn, forcar, pedidos)
            id_dia = controle_padrao.iniciar_dia(conn, logconf.arquivo_atual(), len(CATALOGO), len(endpoints))
            log.info("Execução %d iniciada (forçada=%s, endpoints=%s)", id_execucao, forcar, pedidos or "todos")

            dt_origem = cliente.data_atualizacao()
            db.registrar_origem(conn, id_execucao, dt_origem)
            if not forcar and dt_origem == db.ultima_origem_sucesso(conn):
                msg = f"Origem sem alteração desde a última carga completa ({dt_origem}); use --forcar para recarregar"
                log.info(msg)
                _encerrar(conn, id_execucao, id_dia, "IGNORADA", dt_origem, msg)
                return OK

            resultados = [carregar(cliente, conn, ep, id_execucao, cfg) for ep in endpoints]
            dt_origem_fim = cliente.data_atualizacao()
            status = status_final(dt_origem, dt_origem_fim, resultados, parcial=pedidos is not None)
            resumo = _resumo(resultados)
            if status == "INCONSISTENTE":
                resumo = f"origem mudou durante a carga ({dt_origem} -> {dt_origem_fim}); " + resumo
            _encerrar(conn, id_execucao, id_dia, status, dt_origem_fim, resumo[:4000], resultados)
            log.info("Execução %d: %s — %s", id_execucao, status, resumo[:300])
            return CODIGO_POR_STATUS[status]
        except BaseException as e:
            if id_execucao is not None:
                interrompida = isinstance(e, KeyboardInterrupt)
                _encerrar(conn, id_execucao, id_dia, "ERRO", None,
                          "Interrompida pelo usuário" if interrompida else f"{type(e).__name__}: {e}"[:4000])
            if isinstance(e, KeyboardInterrupt):
                raise
            log.exception("Execução abortada por erro inesperado")
            return ERRO
        finally:
            db.liberar_trava(conn)
    finally:
        if proprio:
            cliente.close()
        conn.close()

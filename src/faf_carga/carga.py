"""Carga de um endpoint: API -> staging (COPY, transação 1) -> merge incremental na base (transação 2)."""

import logging
import time
from dataclasses import dataclass, field

import psycopg
from psycopg import sql

from . import controle_padrao, db
from .catalogo import Endpoint
from .config import Config
from .db import ErroCarga
from .transformar import Transformador

log = logging.getLogger(__name__)


@dataclass
class ResultadoCarga:
    endpoint: str
    tabela: str
    status: str  # SUCESSO | ERRO
    paginas: int | None = None
    total_items_api: int | None = None
    linhas_gravadas: int | None = None  # registros ativos na tabela principal após o merge (= total da API)
    inseridos: int | None = None
    atualizados: int | None = None
    removidos: int | None = None
    duracao: float = 0.0
    mensagem: str | None = None
    por_tabela: dict = field(default_factory=dict)  # tabela -> (inseridos, atualizados, removidos)


def _preparar_staging(conn, cfg: Config, ep: Endpoint, varredura, maximos: dict):
    """Transação 1: recarrega o staging por inteiro e confere (contagem e chaves). A base não é tocada."""
    stg = cfg.db_esquema_stg
    db.truncar(conn, stg, [ep.tabela, *(d.tabela for d in ep.derivadas)])
    tr = Transformador(ep)

    with conn.cursor() as cur, cur.copy(db.comando_copy(stg, ep.tabela, ep.colunas)) as copia:
        for registro in varredura:
            linha = tr.linha(registro)
            copia.write_row(linha)
            tr.acumular_derivadas(registro)
            for coluna, valor in zip(ep.colunas, linha):
                if type(valor) is str and len(valor) > maximos.get(coluna, 0):
                    maximos[coluna] = len(valor)

    no_staging = db.contar(conn, stg, ep.tabela)
    if no_staging != varredura.total_items:
        raise ErroCarga(f"esperado {varredura.total_items}, gravado {no_staging}")

    for d in ep.derivadas:
        with conn.cursor() as cur, cur.copy(db.comando_copy(stg, d.tabela, d.colunas)) as copia:
            for linha in tr.linhas_derivadas(d.tabela):
                copia.write_row(linha)

    for tabela, chave in [(ep.tabela, ep.chave), *((d.tabela, d.chave) for d in ep.derivadas)]:
        db.verificar_duplicados(conn, stg, tabela, chave)


def _mesclar(conn, cfg: Config, ep: Endpoint, id_execucao: int) -> dict:
    """Transação 2: merge incremental na base (tudo ou nada). Devolve (ins, atu, rem) por tabela."""
    if cfg.db_merge_timeout:
        # cada comando do merge leva segundos/poucos minutos; se travar, falha cedo em vez de segurar a carga por horas
        conn.execute(sql.SQL("set local statement_timeout = {}").format(sql.Literal(cfg.db_merge_timeout)))
    resultado = {ep.tabela: db.mesclar(conn, cfg.db_esquema, cfg.db_esquema_stg, ep.tabela, ep.colunas, ep.chave, id_execucao)}
    for d in ep.derivadas:
        resultado[d.tabela] = db.mesclar(conn, cfg.db_esquema, cfg.db_esquema_stg, d.tabela, d.colunas, d.chave, id_execucao)
    return resultado


def _explicar_truncamento(conn, cfg: Config, ep: Endpoint, maximos: dict, erro) -> str:
    excedidas = [
        f"{col} (máx. observado {maximos[col]} > limite {lim})"
        for col, lim in db.limites_varchar(conn, cfg.db_esquema_stg, ep.tabela).items()
        if maximos.get(col, 0) > lim
    ]
    return f"valor maior que a coluna em {ep.tabela}: {', '.join(excedidas) or erro}. Ajustar o DDL."


def _descrever(resultado: ResultadoCarga) -> str:
    texto = f"inseridos {resultado.inseridos}, atualizados {resultado.atualizados}, removidos {resultado.removidos}"
    extras = {t: v for t, v in resultado.por_tabela.items() if t != resultado.tabela}
    if extras:
        texto += "; derivadas " + ", ".join(f"{t}: +{i}/~{a}/-{r}" for t, (i, a, r) in extras.items())
    return texto


def carregar_endpoint(cliente, conn, ep: Endpoint, id_execucao: int, cfg: Config) -> ResultadoCarga:
    inicio = time.monotonic()
    log.info("%s -> %s: iniciando", ep.endpoint, ep.tabela)
    db.registrar_inicio_endpoint(conn, id_execucao, ep.endpoint, ep.tabela)
    id_carga = controle_padrao.iniciar_endpoint(conn, ep.endpoint)
    varredura = cliente.iterar_registros(ep.endpoint)
    maximos: dict = {}
    resultado = ResultadoCarga(ep.endpoint, ep.tabela, "ERRO")
    try:
        with conn.transaction():
            _preparar_staging(conn, cfg, ep, varredura, maximos)
        db.analisar(conn, cfg.db_esquema_stg, ep.tabelas)
        log.info("%s: staging confirmado e analisado (%s linhas); mesclando na base", ep.endpoint, varredura.total_items)
        with conn.transaction():
            por_tabela = _mesclar(conn, cfg, ep, id_execucao)
        resultado.status = "SUCESSO"
        resultado.por_tabela = por_tabela
        resultado.inseridos, resultado.atualizados, resultado.removidos = por_tabela[ep.tabela]
        resultado.linhas_gravadas = varredura.total_items
    except psycopg.errors.StringDataRightTruncation as e:
        resultado.mensagem = _explicar_truncamento(conn, cfg, ep, maximos, e)
    except Exception as e:  # a falha de um endpoint não derruba os demais; a base fica como estava
        resultado.mensagem = f"{type(e).__name__}: {e}"
    resultado.paginas = varredura.paginas or None
    resultado.total_items_api = varredura.total_items
    resultado.duracao = time.monotonic() - inicio
    if resultado.status == "SUCESSO":
        resultado.mensagem = _descrever(resultado)
        log.info("%s: %d registros (%s) em %.0fs", ep.endpoint, resultado.linhas_gravadas, resultado.mensagem,
                 resultado.duracao)
    else:
        log.error("%s: ERRO: %s", ep.endpoint, resultado.mensagem)
    db.registrar_fim_endpoint(
        conn, id_execucao, ep.endpoint, resultado.status, resultado.paginas, resultado.total_items_api,
        resultado.linhas_gravadas, resultado.mensagem, resultado.inseridos, resultado.atualizados, resultado.removidos,
    )
    controle_padrao.finalizar_endpoint(conn, id_carga, resultado.status, resultado.linhas_gravadas, resultado.mensagem)
    return resultado

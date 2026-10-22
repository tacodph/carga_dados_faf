"""Linha de comando: faf-carga {ddl,executar,status,verificar,endpoints,config}."""

import argparse
import logging
import sys

from . import config, db, log
from .catalogo import CATALOGO
from .orquestrador import ERRO, OK, PARCIAL, executar, selecionar_endpoints

logger = logging.getLogger(__name__)


def _parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(prog="faf-carga", description="Carga da API Fundo a Fundo (Transferegov) no PostgreSQL")
    sub = p.add_subparsers(dest="comando", required=True)
    sub.add_parser("ddl", help="aplica os scripts de sql/ no banco (idempotente)")
    ex = sub.add_parser("executar", help="executa a carga (ignorada se a origem não mudou desde a última carga completa)")
    ex.add_argument("--forcar", action="store_true", help="recarrega mesmo sem mudança na origem")
    ex.add_argument("--endpoints", help="lista separada por vírgula, ex.: programas,planos-acao (carga parcial)")
    st = sub.add_parser("status", help="lista as últimas execuções e os endpoints da mais recente")
    st.add_argument("--ultimas", type=int, default=10)
    sub.add_parser("verificar", help="compara total_items da API com count(*) de cada tabela, sem carregar")
    sub.add_parser("endpoints", help="lista o catálogo (endpoint -> tabela)")
    sub.add_parser("config", help="mostra a configuração carregada (senha mascarada)")
    return p


def _status(cfg, ultimas: int) -> int:
    conn = db.conectar(cfg)
    execucoes = conn.execute(
        "select id_execucao, to_char(dt_inicio, 'YYYY-MM-DD HH24:MI:SS'), "
        "coalesce(extract(epoch from dt_fim - dt_inicio)::int::text, '-'), status, "
        "coalesce(to_char(dt_atualizacao_origem, 'YYYY-MM-DD HH24:MI'), '-'), forcada, coalesce(left(mensagem, 90), '') "
        "from controle_execucao order by id_execucao desc limit %s", (ultimas,)
    ).fetchall()
    if not execucoes:
        print("Nenhuma execução registrada.")
        return OK
    print(f"{'id':>5}  {'início':19}  {'seg':>5}  {'status':15}  {'origem':16}  forç  mensagem")
    for i, ini, seg, st, orig, forc, msg in execucoes:
        print(f"{i:>5}  {ini}  {seg:>5}  {st:15}  {orig:16}  {'s' if forc else 'n':4}  {msg}")
    ultima = execucoes[0][0]
    print(f"\nEndpoints da execução {ultima}:")
    print(f"{'endpoint':45} {'status':9} {'págs':>5} {'total API':>10} {'novos':>8} {'alterados':>9} {'removidos':>9}  mensagem")
    for ep, st, pg, tot, ins, atu, rem, msg in conn.execute(
        "select endpoint, status, paginas, total_items_api, qtd_inseridos, qtd_atualizados, qtd_removidos, "
        "case when status = 'ERRO' then coalesce(left(mensagem, 80), '') else '' end "
        "from controle_execucao_endpoint where id_execucao = %s order by dt_inicio", (ultima,)
    ):
        v = lambda x: "-" if x is None else x
        print(f"{ep:45} {st:9} {pg or '-':>5} {v(tot):>10} {v(ins):>8} {v(atu):>9} {v(rem):>9}  {msg}")
    return OK


def _verificar(cfg) -> int:
    from .api_client import ClienteFaF

    conn = db.conectar(cfg)
    divergentes = 0
    print(f"{'endpoint':45} {'total API':>10} {'ativos':>10}  situação")
    with ClienteFaF(cfg) as cliente:
        for ep in CATALOGO:
            api = cliente.pagina(ep.endpoint, 1, tamanho_da_pagina=1)["total_items"]
            banco = db.contar(conn, cfg.db_esquema, ep.tabela, somente_ativos=True)
            ok = api == banco
            divergentes += not ok
            print(f"{ep.endpoint:45} {api:>10} {banco:>10}  {'ok' if ok else 'DIVERGENTE'}")
    print(f"\n{len(CATALOGO) - divergentes}/{len(CATALOGO)} tabelas batem com a API")
    return OK if not divergentes else PARCIAL


def main(argv: list[str] | None = None) -> int:
    args = _parser().parse_args(argv)

    if args.comando == "endpoints":
        for e in CATALOGO:
            extras = f"  (+ {', '.join(d.tabela for d in e.derivadas)})" if e.derivadas else ""
            print(f"{e.endpoint:45} -> {e.tabela}{extras}")
        return OK

    try:
        cfg = config.carregar()
    except config.ErroConfiguracao as e:
        print(f"Erro de configuração: {e}", file=sys.stderr)
        return ERRO
    log.configurar(cfg.log_nivel, cfg.log_dir)

    if args.comando == "config":
        print(cfg.resumo())
        return OK
    if args.comando == "ddl":
        from . import ddl

        logger.info("DDL no banco %s@%s:%s/%s", cfg.db_usuario, cfg.db_host, cfg.db_porta, cfg.db_nome)
        logger.info("%d scripts aplicados", ddl.aplicar(cfg))
        return OK
    if args.comando == "executar":
        return executar(cfg, forcar=args.forcar, pedidos=args.endpoints)
    if args.comando == "status":
        return _status(cfg, args.ultimas)
    if args.comando == "verificar":
        return _verificar(cfg)
    return ERRO

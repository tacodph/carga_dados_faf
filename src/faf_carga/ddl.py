"""Aplica os scripts de sql/ (NNN_*.sql, em ordem) no banco. Idempotente."""

import logging
from pathlib import Path

import psycopg

from .config import Config
from .db import mover_para_tablespace, opcoes_conexao

log = logging.getLogger(__name__)

PASTA_SQL = Path(__file__).resolve().parents[2] / "sql"


def conectar(cfg: Config) -> psycopg.Connection:
    return psycopg.connect(
        host=cfg.db_host, port=cfg.db_porta, dbname=cfg.db_nome, user=cfg.db_usuario, password=cfg.db_senha,
        options=opcoes_conexao(cfg, search_path=False),  # objetos novos já nascem no tablespace configurado
    )


def aplicar(cfg: Config) -> int:
    """Executa cada script numa transação própria; devolve quantos foram aplicados."""
    scripts = sorted(PASTA_SQL.glob("[0-9][0-9][0-9]_*.sql"))
    if not scripts:
        raise FileNotFoundError(f"Nenhum script encontrado em {PASTA_SQL}")
    with conectar(cfg) as conn:
        for script in scripts:
            log.info("Aplicando %s", script.name)
            conn.execute(script.read_text(encoding="utf-8"))
            conn.commit()
        if cfg.db_tablespace:
            movidos = mover_para_tablespace(conn, [cfg.db_esquema, cfg.db_esquema_stg], cfg.db_tablespace)
            log.info("%d objeto(s) movido(s) para o tablespace %s", movidos, cfg.db_tablespace)
    return len(scripts)

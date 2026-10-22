"""Fixtures compartilhadas: dois esquemas temporários (base + staging) no PostgreSQL configurado em .env."""

import dataclasses
import uuid
from pathlib import Path

import pytest

SQL = Path(__file__).resolve().parents[1] / "sql"
ESQUEMA_PADRAO = "base_transferencias_fundo_fundo"
ESQUEMA_STG_PADRAO = "stg_transferencias_fundo_fundo"


@pytest.fixture(scope="module")
def banco():
    import psycopg

    from faf_carga import config, db

    try:
        cfg = config.carregar()
    except config.ErroConfiguracao as e:
        pytest.skip(f"sem configuração de banco: {e}")
    sufixo = uuid.uuid4().hex[:8]
    esquema, esquema_stg = f"faf_teste_{sufixo}", f"faf_teste_stg_{sufixo}"
    cfg = dataclasses.replace(cfg, db_esquema=esquema, db_esquema_stg=esquema_stg)
    admin = psycopg.connect(host=cfg.db_host, port=cfg.db_porta, dbname=cfg.db_nome, user=cfg.db_usuario,
                            password=cfg.db_senha, autocommit=True,
                            options=db.opcoes_conexao(cfg, search_path=False))
    for script in sorted(SQL.glob("[0-9][0-9][0-9]_*.sql")):
        texto = script.read_text(encoding="utf-8")
        admin.execute(texto.replace(ESQUEMA_STG_PADRAO, esquema_stg).replace(ESQUEMA_PADRAO, esquema))
    conn = db.conectar(cfg)
    yield cfg, conn
    conn.close()
    admin.execute(f"drop schema {esquema} cascade")
    admin.execute(f"drop schema {esquema_stg} cascade")
    admin.close()

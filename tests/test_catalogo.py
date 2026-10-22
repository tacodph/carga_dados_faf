import re
from pathlib import Path

import pytest

from faf_carga.catalogo import CATALOGO

SQL = Path(__file__).resolve().parents[1] / "sql" / "003_tabelas_dados.sql"
TECNICAS = ("dt_carga", "id_execucao", "dt_atualizacao", "hash_registro", "dt_remocao_origem")


def _colunas_ddl() -> dict:
    tabelas = {}
    for nome, corpo in re.findall(r"create table if not exists (\w+) \((.*?)\n\);", SQL.read_text(encoding="utf-8"), re.S):
        tabelas[nome] = [
            l.split()[0] for l in corpo.splitlines()
            if l.strip() and not l.strip().startswith("primary key") and l.split()[0] not in TECNICAS
        ]
    return tabelas


def _tabelas_do_catalogo():
    for ep in CATALOGO:
        yield ep.tabela, list(ep.colunas), ep.chave
        for d in ep.derivadas:
            yield d.tabela, list(d.colunas), d.chave


def test_catalogo_tem_20_endpoints_e_23_tabelas():
    assert len(CATALOGO) == 20 and len(list(_tabelas_do_catalogo())) == 23


def test_catalogo_igual_ao_ddl():
    ddl = _colunas_ddl()
    for tabela, colunas, chave in _tabelas_do_catalogo():
        assert ddl[tabela] == colunas, tabela
        assert set(chave) <= set(colunas), tabela
    assert set(ddl) == {t for t, _, _ in _tabelas_do_catalogo()}


@pytest.mark.integracao
def test_catalogo_igual_ao_banco():
    from faf_carga import config, db

    cfg = config.carregar()
    conn = db.conectar(cfg)
    for tabela, colunas, _ in _tabelas_do_catalogo():
        for esquema, extra in ((cfg.db_esquema, list(TECNICAS)), (cfg.db_esquema_stg, [])):
            reais = [r[0] for r in conn.execute(
                "select column_name from information_schema.columns where table_schema = %s "
                "and table_name = %s order by ordinal_position", (esquema, tabela))]
            assert reais == colunas + extra, f"{esquema}.{tabela}"

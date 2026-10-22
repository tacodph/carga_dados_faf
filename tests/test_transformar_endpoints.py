"""Transformação e catálogo contra respostas reais da API (tests/fixtures) e contra o OpenAPI."""

import json
import logging
from pathlib import Path

import pytest

from faf_carga.catalogo import CATALOGO
from faf_carga.transformar import Transformador

FIXTURES = Path(__file__).resolve().parent / "fixtures"
OPENAPI = Path(__file__).resolve().parents[1] / "docs" / "openapi.json"


def _fixture(ep):
    return json.loads((FIXTURES / f"{ep.endpoint.strip('/')}.json").read_text(encoding="utf-8"))


@pytest.mark.parametrize("ep", CATALOGO, ids=lambda e: e.endpoint)
def test_registro_real_gera_todas_as_colunas_sem_avisos(ep, caplog):
    caplog.set_level(logging.WARNING)
    tr = Transformador(ep)
    registros = _fixture(ep)
    assert registros
    for r in registros:
        linha = tr.linha(r)
        tr.acumular_derivadas(r)
        assert len(linha) == len(ep.colunas)
        assert all(linha[ep.colunas.index(c)] is not None for c in ep.chave)
    assert caplog.messages == []  # nenhum campo novo/ausente: catálogo e API estão alinhados
    for d in ep.derivadas:
        for linha in tr.linhas_derivadas(d.tabela):
            assert len(linha) == len(d.colunas)


def test_derivadas_de_programas_e_dados_bancarios_com_dados_reais():
    prog = next(e for e in CATALOGO if e.endpoint == "/programas")
    tr = Transformador(prog)
    for r in _fixture(prog):
        tr.acumular_derivadas(r)
    assert list(tr.linhas_derivadas("programas_natureza_despesa_faf"))
    assert list(tr.linhas_derivadas("programas_acao_orcamentaria_faf"))

    bancos = next(e for e in CATALOGO if e.endpoint == "/planos-acao-dados-bancarios")
    tr = Transformador(bancos)
    for r in _fixture(bancos):
        tr.linha(r)
        tr.acumular_derivadas(r)
    contas = {c for c, _ in tr.linhas_derivadas("gestao_financeira_saldo_conta_faf")}
    assert contas <= {r["id_agencia_conta"] for r in _fixture(bancos)}


def _campos_openapi() -> dict:
    api = json.loads(OPENAPI.read_text(encoding="utf-8"))
    esquemas = api["components"]["schemas"]
    campos = {}
    for caminho, v in api["paths"].items():
        if caminho == "/data-atualizacao":
            continue
        pagina = esquemas[v["get"]["responses"]["200"]["content"]["application/json"]["schema"]["$ref"].split("/")[-1]]
        item = esquemas[pagina["properties"]["data"]["items"]["$ref"].split("/")[-1]]
        campos[caminho] = set(item["properties"])
    return campos


def test_todo_campo_do_openapi_esta_mapeado_no_catalogo():
    """Falha quando a API ganhar campo: ajustar DDL (gerar_ddl.py) e catálogo (gerar_catalogo.py)."""
    campos = _campos_openapi()
    assert set(campos) == {e.endpoint for e in CATALOGO}
    for ep in CATALOGO:
        mapeados = (
            {c for c in ep.colunas if c not in ep.achatar}
            | {campo for campo, _ in ep.achatar.values()}
            | {d.campo for d in ep.derivadas}
        )
        assert campos[ep.endpoint] == mapeados, (ep.endpoint, campos[ep.endpoint] ^ mapeados)

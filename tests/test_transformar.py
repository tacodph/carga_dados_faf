import logging
from decimal import Decimal

from faf_carga.catalogo import por_endpoint
from faf_carga.transformar import Transformador, converter


def _registro_completo(ep, **extra):
    r = {c: None for c in ep.colunas if c not in ep.achatar}
    r.update(extra)
    return r


def test_converter_float_vira_decimal_e_remove_nul():
    assert converter(12000.5) == Decimal("12000.5") and isinstance(converter(0.1), Decimal)
    assert converter("a\x00b") == "ab"
    assert converter(None) is None and converter(True) is True and converter(3) == 3


def test_programas_com_listas_aninhadas():
    ep = por_endpoint("/programas")
    tr = Transformador(ep)
    r = _registro_completo(
        ep, id_programa=1, nome_programa="X",
        programa_natureza_despesa=[{"grupo_natureza_despesa_programa": "CUSTEIO"},
                                   {"grupo_natureza_despesa_programa": "INVESTIMENTO"},
                                   {"grupo_natureza_despesa_programa": "CUSTEIO"}],
        programa_acao_orcamentaria=[{"codigo_acao_orcamentaria_programa": "00R2", "descricao_acao_orcamentaria_programa": "A"}],
    )
    linha = tr.linha(r)
    tr.acumular_derivadas(r)
    assert len(linha) == len(ep.colunas) and linha[ep.colunas.index("nome_programa")] == "X"
    assert sorted(tr.linhas_derivadas("programas_natureza_despesa_faf")) == [(1, "CUSTEIO"), (1, "INVESTIMENTO")]
    assert list(tr.linhas_derivadas("programas_acao_orcamentaria_faf")) == [(1, "00R2", "A")]


def test_programas_com_listas_nulas():
    ep = por_endpoint("/programas")
    tr = Transformador(ep)
    r = _registro_completo(ep, id_programa=2, programa_natureza_despesa=None, programa_acao_orcamentaria=None)
    tr.linha(r)
    tr.acumular_derivadas(r)
    assert list(tr.linhas_derivadas("programas_natureza_despesa_faf")) == []
    assert list(tr.linhas_derivadas("programas_acao_orcamentaria_faf")) == []


def test_dados_bancarios_achata_saldo_e_deduplica_conta():
    ep = por_endpoint("/planos-acao-dados-bancarios")
    tr = Transformador(ep)
    r1 = _registro_completo(ep, id_plano_acao_dado_bancario=1, id_agencia_conta="4200-7182",
                            saldo_final_dado_bancario={"saldo_final_gestao_financeira": 10.5})
    r2 = _registro_completo(ep, id_plano_acao_dado_bancario=2, id_agencia_conta="4200-7182",
                            saldo_final_dado_bancario={"saldo_final_gestao_financeira": 20.0})
    r3 = _registro_completo(ep, id_plano_acao_dado_bancario=3, id_agencia_conta="9-9", saldo_final_dado_bancario=None)
    linhas = []
    for r in (r1, r2, r3):
        linhas.append(tr.linha(r))
        tr.acumular_derivadas(r)
    i = ep.colunas.index("saldo_final_conta_plano_acao_dado_bancario")
    assert linhas[0][i] == Decimal("10.5") and linhas[2][i] is None
    assert list(tr.linhas_derivadas("gestao_financeira_saldo_conta_faf")) == [("4200-7182", Decimal("20.0"))]


def test_lancamento_com_categoria_nula_e_preenchida():
    ep = por_endpoint("/gestao-financeira-lancamentos")
    tr = Transformador(ep)
    i = ep.colunas.index("caminho_categoria_despesa_lancamento_gestao_financeira")
    com = tr.linha(_registro_completo(ep, id_lancamento_gestao_financeira=1,
                                      categorias_despesa_lancamento={"caminho_categoria_lancamento": "A | B"}))
    sem = tr.linha(_registro_completo(ep, id_lancamento_gestao_financeira=2, categorias_despesa_lancamento=None))
    assert com[i] == "A | B" and sem[i] is None


def test_campo_novo_e_ausente_geram_aviso_uma_vez(caplog):
    ep = por_endpoint("/empenhos")
    tr = Transformador(ep)
    caplog.set_level(logging.WARNING)
    for n in range(3):
        r = _registro_completo(ep, id_empenho=n, campo_novo_da_api="x")
        del r["objeto_empenho"]
        linha = tr.linha(r)
    assert linha[ep.colunas.index("objeto_empenho")] is None
    avisos = [m for m in caplog.messages if "campo_novo_da_api" in m or "objeto_empenho" in m]
    assert len(avisos) == 2

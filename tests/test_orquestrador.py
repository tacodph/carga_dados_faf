from datetime import datetime

import pytest

from faf_carga import db
from faf_carga.carga import ResultadoCarga
from faf_carga.catalogo import CATALOGO
from faf_carga.orquestrador import ErroEndpoint, executar, selecionar_endpoints, status_final

T0, T1 = datetime(2026, 10, 21, 6, 0), datetime(2026, 10, 22, 6, 0)


def _r(status="SUCESSO", endpoint="/x"):
    return ResultadoCarga(endpoint, "x", status, linhas_gravadas=1, mensagem=None if status == "SUCESSO" else "falhou")


def test_selecionar_endpoints():
    assert selecionar_endpoints(None) == list(CATALOGO)
    assert [e.endpoint for e in selecionar_endpoints("planos-acao, /programas")] == ["/programas", "/planos-acao"]
    with pytest.raises(ErroEndpoint, match="inexistente"):
        selecionar_endpoints("inexistente")


@pytest.mark.parametrize("fim,resultados,parcial,esperado", [
    (T0, [_r(), _r()], False, "SUCESSO"),
    (T0, [_r(), _r("ERRO")], False, "SUCESSO_PARCIAL"),
    (T0, [_r("ERRO"), _r("ERRO")], False, "ERRO"),
    (T0, [_r()], True, "SUCESSO_PARCIAL"),  # --endpoints nunca vale como carga completa
    (T1, [_r(), _r()], False, "INCONSISTENTE"),
    (T1, [_r("ERRO")], False, "INCONSISTENTE"),
])
def test_status_final(fim, resultados, parcial, esperado):
    assert status_final(T0, fim, resultados, parcial) == esperado


class ClienteFalso:
    def __init__(self, *datas):
        self.datas = list(datas)

    def data_atualizacao(self):
        return self.datas.pop(0) if len(self.datas) > 1 else self.datas[0]

    def close(self):
        pass


def _carregar_falso(falhar=()):
    chamadas = []

    def carregar(cliente, conn, ep, id_execucao, cfg):
        chamadas.append(ep.endpoint)
        return _r("ERRO" if ep.endpoint in falhar else "SUCESSO", ep.endpoint)
    carregar.chamadas = chamadas
    return carregar


def _ultima(conn):
    return conn.execute("select status, forcada, endpoints_solicitados, dt_atualizacao_origem, "
                        "dt_atualizacao_origem_fim from controle_execucao order by id_execucao desc limit 1").fetchone()




@pytest.mark.integracao
def test_fluxo_completo_ignorada_forcada_e_parcial(banco):
    cfg, conn = banco
    c = _carregar_falso()
    assert executar(cfg, cliente=ClienteFalso(T0), carregar=c) == 0
    assert len(c.chamadas) == 20 and _ultima(conn)[0] == "SUCESSO"

    c2 = _carregar_falso()  # mesma data de origem: ignorada, sem carregar nada
    assert executar(cfg, cliente=ClienteFalso(T0), carregar=c2) == 0
    assert c2.chamadas == [] and _ultima(conn)[0] == "IGNORADA"

    c3 = _carregar_falso()  # forçada + parcial: só o pedido, SUCESSO_PARCIAL, código 3
    assert executar(cfg, forcar=True, pedidos="programas", cliente=ClienteFalso(T0), carregar=c3) == 3
    assert c3.chamadas == ["/programas"]
    assert _ultima(conn)[:3] == ("SUCESSO_PARCIAL", True, "programas")

    # origem nova: recarrega tudo
    c4 = _carregar_falso()
    assert executar(cfg, cliente=ClienteFalso(T1), carregar=c4) == 0 and len(c4.chamadas) == 20


@pytest.mark.integracao
def test_inconsistente_falha_parcial_e_erro_inesperado(banco):
    cfg, conn = banco
    assert executar(cfg, forcar=True, cliente=ClienteFalso(T0, T1), carregar=_carregar_falso()) == 3
    assert _ultima(conn)[0] == "INCONSISTENTE"

    assert executar(cfg, forcar=True, cliente=ClienteFalso(T0), carregar=_carregar_falso(falhar={"/empenhos"})) == 3
    assert _ultima(conn)[0] == "SUCESSO_PARCIAL"

    def explode(*a):
        raise RuntimeError("boom")
    assert executar(cfg, forcar=True, cliente=ClienteFalso(T0), carregar=explode) == 1
    status, *_ = _ultima(conn)
    assert status == "ERRO"
    assert "boom" in conn.execute("select mensagem from controle_execucao order by id_execucao desc limit 1").fetchone()[0]


@pytest.mark.integracao
def test_segunda_execucao_simultanea_sai_com_codigo_2(banco):
    cfg, conn = banco
    outra = db.conectar(cfg)
    assert db.obter_trava(outra)
    try:
        c = _carregar_falso()
        assert executar(cfg, forcar=True, cliente=ClienteFalso(T0), carregar=c) == 2
        assert c.chamadas == []
    finally:
        db.liberar_trava(outra)
        outra.close()


@pytest.mark.integracao
def test_execucao_travada_de_processo_morto_vira_erro(banco):
    cfg, conn = banco
    id_velho = db.iniciar_execucao(conn, False, None)
    assert executar(cfg, forcar=True, cliente=ClienteFalso(T0), carregar=_carregar_falso()) == 0
    assert conn.execute("select status from controle_execucao where id_execucao = %s", (id_velho,)).fetchone()[0] == "ERRO"


@pytest.mark.integracao
def test_registra_no_controle_corporativo(banco):
    cfg, conn = banco
    conn.execute("delete from controle_carga_dia")
    conn.execute("delete from controle_execucao")  # sem carga completa anterior que faça ignorar
    assert executar(cfg, cliente=ClienteFalso(T0), carregar=_carregar_falso(falhar={"/empenhos"})) == 3
    assert executar(cfg, cliente=ClienteFalso(T0), carregar=_carregar_falso()) == 0  # carrega tudo de novo
    assert executar(cfg, forcar=True, pedidos="programas", cliente=ClienteFalso(T0), carregar=_carregar_falso()) == 3
    linhas = conn.execute("select seq_execucao_dia, status, qtd_arquivos_extraidos, qtd_arquivos_carregados, "
                          "qtd_arquivos_erro, qtd_arquivos_pulados, dt_fim is not null from controle_carga_dia "
                          "order by seq_execucao_dia").fetchall()
    assert linhas == [(1, "PARCIAL", 20, 19, 1, 0, True), (2, "SUCESSO", 20, 20, 0, 0, True),
                      (3, "PARCIAL", 1, 1, 0, 19, True)]


def test_nome_endpoint_no_padrao_corporativo():
    from faf_carga.controle_padrao import nome_endpoint

    assert nome_endpoint("/programas") == "fundoafundo/programas"

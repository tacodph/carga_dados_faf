"""Integração: carga + merge incremental em esquemas temporários do PostgreSQL de .env (marcador `integracao`)."""

from pathlib import Path

import pytest

from faf_carga import db
from faf_carga.carga import carregar_endpoint
from faf_carga.catalogo import por_endpoint

SQL_DIR = Path(__file__).resolve().parents[1] / "sql"

pytestmark = pytest.mark.integracao


class VarreduraFalsa:
    def __init__(self, registros, total_items=None, falhar_apos=None):
        self.registros, self.falhar_apos = registros, falhar_apos
        self.total_items = len(registros) if total_items is None else total_items
        self.paginas = 1

    def __iter__(self):
        for i, r in enumerate(self.registros):
            if self.falhar_apos is not None and i == self.falhar_apos:
                raise RuntimeError("queda da API no meio do download")
            yield r


class ClienteFalso:
    def __init__(self, varredura):
        self.varredura = varredura

    def iterar_registros(self, endpoint):
        return self.varredura


def _empenho(i, valor=None, **extra):
    r = {c: None for c in por_endpoint("/empenhos").colunas}
    r.update({"id_empenho": i, "numero_empenho": f"2026NE{i:04d}", "valor_empenho": valor or 1000.5 + i, **extra})
    return r


@pytest.fixture(autouse=True)
def _limpar(banco):
    cfg, conn = banco
    for tabela in ("empenhos_faf", "programas_faf", "programas_natureza_despesa_faf", "programas_acao_orcamentaria_faf"):
        conn.execute(f"delete from {tabela}")
    yield


def _rodar(banco, endpoint, registros, id_exec=None, **kw):
    cfg, conn = banco
    id_exec = id_exec or db.nova_execucao(conn, "teste")
    r = carregar_endpoint(ClienteFalso(VarreduraFalsa(registros, **kw)), conn, por_endpoint(endpoint), id_exec, cfg)
    return r, id_exec


def _linhas(conn, sql):
    return conn.execute(sql).fetchall()


def test_primeira_carga_insere_e_repetir_nao_toca_em_nada(banco):
    cfg, conn = banco
    dados = [_empenho(1), _empenho(2), _empenho(3)]
    r1, id1 = _rodar(banco, "/empenhos", dados)
    assert (r1.status, r1.linhas_gravadas, r1.inseridos, r1.atualizados, r1.removidos) == ("SUCESSO", 3, 3, 0, 0)
    antes = _linhas(conn, "select id_empenho, dt_carga, dt_atualizacao, id_execucao, hash_registro from empenhos_faf order by 1")
    r2, id2 = _rodar(banco, "/empenhos", dados)
    assert (r2.inseridos, r2.atualizados, r2.removidos) == (0, 0, 0) and id2 != id1
    depois = _linhas(conn, "select id_empenho, dt_carga, dt_atualizacao, id_execucao, hash_registro from empenhos_faf order by 1")
    assert depois == antes  # nenhuma linha reescrita: id_execucao, datas e hash intactos
    assert all(x[3] == id1 for x in depois)
    controle = conn.execute("select status, total_items_api, linhas_gravadas, qtd_inseridos, qtd_atualizados, qtd_removidos "
                            "from controle_execucao_endpoint where id_execucao = %s", (id2,)).fetchone()
    assert controle == ("SUCESSO", 3, 3, 0, 0, 0)
    padrao = conn.execute("select endpoint, status, total_registros, mensagem from controle_carga order by id desc limit 1").fetchone()
    assert padrao[:3] == ("fundoafundo/empenhos", "SUCESSO", 3) and "inseridos 0" in padrao[3]


def test_atualiza_somente_o_que_mudou(banco):
    cfg, conn = banco
    _, id1 = _rodar(banco, "/empenhos", [_empenho(1), _empenho(2), _empenho(3)])
    r, id2 = _rodar(banco, "/empenhos", [_empenho(1), _empenho(2, valor=9999.99), _empenho(3)])
    assert (r.inseridos, r.atualizados, r.removidos) == (0, 1, 0)
    linhas = {x[0]: x for x in _linhas(conn, "select id_empenho, valor_empenho, id_execucao, dt_atualizacao > dt_carga from empenhos_faf")}
    assert str(linhas[2][1]) == "9999.99" and linhas[2][2] == id2 and linhas[2][3] is True
    assert linhas[1][2] == id1 and linhas[1][3] is False and linhas[3][2] == id1


def test_novo_removido_e_reaparecido(banco):
    cfg, conn = banco
    _rodar(banco, "/empenhos", [_empenho(1), _empenho(2), _empenho(3)])
    r, _ = _rodar(banco, "/empenhos", [_empenho(1), _empenho(4)])
    assert (r.inseridos, r.atualizados, r.removidos, r.linhas_gravadas) == (1, 0, 2, 2)
    estado = dict(_linhas(conn, "select id_empenho, dt_remocao_origem is not null from empenhos_faf"))
    assert estado == {1: False, 2: True, 3: True, 4: False}  # removidos continuam na tabela, só marcados
    r, _ = _rodar(banco, "/empenhos", [_empenho(1), _empenho(2), _empenho(4)])  # o 2 volta com o mesmo conteúdo
    assert (r.inseridos, r.atualizados, r.removidos) == (0, 1, 0)
    estado = dict(_linhas(conn, "select id_empenho, dt_remocao_origem is not null from empenhos_faf"))
    assert estado == {1: False, 2: False, 3: True, 4: False}
    assert db.contar(conn, cfg.db_esquema, "empenhos_faf", somente_ativos=True) == 3


def test_api_vazia_nao_remove_nada(banco):
    cfg, conn = banco
    _rodar(banco, "/empenhos", [_empenho(1), _empenho(2)])
    r, _ = _rodar(banco, "/empenhos", [])
    assert r.status == "ERRO" and "devolveu 0 registros" in r.mensagem
    assert db.contar(conn, cfg.db_esquema, "empenhos_faf", somente_ativos=True) == 2


def test_queda_no_meio_mantem_a_base(banco):
    cfg, conn = banco
    _rodar(banco, "/empenhos", [_empenho(1), _empenho(2)])
    antes = _linhas(conn, "select * from empenhos_faf order by id_empenho")
    r, _ = _rodar(banco, "/empenhos", [_empenho(i) for i in range(10, 20)], falhar_apos=5)
    assert r.status == "ERRO" and "queda da API" in r.mensagem
    assert _linhas(conn, "select * from empenhos_faf order by id_empenho") == antes


def test_divergencia_de_contagem_nao_altera_a_base(banco):
    cfg, conn = banco
    _rodar(banco, "/empenhos", [_empenho(1), _empenho(2)])
    r, _ = _rodar(banco, "/empenhos", [_empenho(1)], total_items=5)
    assert r.status == "ERRO" and "esperado 5, gravado 1" in r.mensagem
    assert db.contar(conn, cfg.db_esquema, "empenhos_faf", somente_ativos=True) == 2
    assert conn.execute("select status, total_registros from controle_carga order by id desc limit 1").fetchone() == ("ERRO", None)


def test_chave_duplicada_e_valor_grande_demais(banco):
    r, _ = _rodar(banco, "/empenhos", [_empenho(1), _empenho(1)])
    assert r.status == "ERRO" and "duplicada" in r.mensagem and "(1,)" in r.mensagem
    r, _ = _rodar(banco, "/empenhos", [_empenho(1, numero_empenho="x" * 300)])
    assert r.status == "ERRO" and "numero_empenho" in r.mensagem and "máx. observado 300" in r.mensagem


def test_derivadas_de_programas_tambem_sao_incrementais(banco):
    cfg, conn = banco
    base = {c: None for c in por_endpoint("/programas").colunas}
    acao = [{"codigo_acao_orcamentaria_programa": "00R2", "descricao_acao_orcamentaria_programa": "A"}]
    nat = [{"grupo_natureza_despesa_programa": "CUSTEIO"}, {"grupo_natureza_despesa_programa": "INVESTIMENTO"}]
    regs = [{**base, "id_programa": 1, "programa_natureza_despesa": nat, "programa_acao_orcamentaria": acao},
            {**base, "id_programa": 2, "programa_natureza_despesa": None, "programa_acao_orcamentaria": None}]
    r, _ = _rodar(banco, "/programas", regs)
    assert r.status == "SUCESSO", r.mensagem
    assert r.por_tabela == {"programas_faf": (2, 0, 0), "programas_natureza_despesa_faf": (2, 0, 0),
                            "programas_acao_orcamentaria_faf": (1, 0, 0)}
    regs[0] = {**regs[0], "programa_natureza_despesa": nat[:1]}  # o programa 1 perde uma natureza de despesa
    r, _ = _rodar(banco, "/programas", regs)
    assert r.por_tabela == {"programas_faf": (0, 0, 0), "programas_natureza_despesa_faf": (0, 0, 1),
                            "programas_acao_orcamentaria_faf": (0, 0, 0)}
    assert db.contar(conn, cfg.db_esquema, "programas_natureza_despesa_faf", somente_ativos=True) == 1


def test_programas_reais(banco):
    from faf_carga.api_client import ClienteFaF

    cfg, conn = banco
    with ClienteFaF(cfg) as cliente:
        r = carregar_endpoint(cliente, conn, por_endpoint("/programas"), db.nova_execucao(conn, "teste"), cfg)
        assert r.status == "SUCESSO", r.mensagem
        assert r.linhas_gravadas == r.total_items_api == db.contar(conn, cfg.db_esquema, "programas_faf", somente_ativos=True)
        r2 = carregar_endpoint(cliente, conn, por_endpoint("/programas"), db.nova_execucao(conn, "teste"), cfg)
    assert (r2.inseridos, r2.atualizados, r2.removidos) == (0, 0, 0)  # mesma origem: nada muda


def test_validacao_sql_executa_sem_erro(banco):
    import re

    # o arquivo começa com `set search_path` do esquema real: o teste roda no esquema temporário da conexão
    sql = re.sub(r"(?m)^set search_path to .*;$", "", (SQL_DIR / "validacao.sql").read_text(encoding="utf-8"))
    cfg, conn = banco
    consultas = [c.strip() for c in sql.split(";\n") if c.strip() and not c.strip().startswith("--\n")]
    assert len(consultas) >= 9
    for consulta in consultas:
        conn.execute(consulta)

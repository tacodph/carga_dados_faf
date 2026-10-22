from datetime import datetime

import httpx
import pytest
import respx

from faf_carga.api_client import ClienteFaF, ErroApi
from faf_carga.config import Config

BASE = "https://api.teste/fundoafundo"


def _config(**extra) -> Config:
    base = dict(
        api_base_url=BASE, api_tamanho_pagina=2, api_timeout=5, api_max_tentativas=4, api_concorrencia=3,
        api_user_agent="teste", db_host="x", db_porta=5432, db_nome="x", db_usuario="x", db_senha="x",
        db_esquema="x", db_esquema_stg="x", db_tablespace="", db_statement_timeout="4h", db_merge_timeout="30min", log_nivel="INFO", log_dir="logs",
    )
    return Config(**{**base, **extra})


@pytest.fixture
def cliente():
    c = ClienteFaF(_config())
    c._dormir = lambda s: None
    yield c
    c.close()


def _envelope(registros, pagina, total_paginas, total_items):
    return {"data": registros, "total_pages": total_paginas, "total_items": total_items,
            "page_number": pagina, "page_size": len(registros)}


@respx.mock
def test_paginacao_devolve_tudo_em_ordem(cliente):
    paginas = {1: [{"id": 1}, {"id": 2}], 2: [{"id": 3}, {"id": 4}], 3: [{"id": 5}]}
    rota = respx.get(f"{BASE}/programas")
    rota.side_effect = lambda req: httpx.Response(
        200, json=_envelope(paginas[int(req.url.params["pagina"])], int(req.url.params["pagina"]), 3, 5)
    )
    varredura = cliente.iterar_registros("/programas")
    assert [r["id"] for r in varredura] == [1, 2, 3, 4, 5]
    assert (varredura.total_items, varredura.paginas, varredura.registros) == (5, 3, 5)
    assert rota.calls.last.request.url.params["tamanho_da_pagina"] == "2"


@respx.mock
def test_filtros_vao_na_query(cliente):
    rota = respx.get(f"{BASE}/planos-acao").mock(return_value=httpx.Response(200, json=_envelope([], 1, 0, 0)))
    assert list(cliente.iterar_registros("/planos-acao", id_programa="7")) == []
    assert rota.calls.last.request.url.params["id_programa"] == "7"


@respx.mock
def test_retry_em_503_e_depois_sucesso(cliente):
    rota = respx.get(f"{BASE}/programas").mock(
        side_effect=[httpx.Response(503), httpx.Response(503), httpx.Response(200, json=_envelope([{"id": 1}], 1, 1, 1))]
    )
    assert list(cliente.iterar_registros("/programas")) == [{"id": 1}]
    assert rota.call_count == 3


@respx.mock
def test_retry_respeita_retry_after():
    esperas = []
    c = ClienteFaF(_config())
    c._dormir = esperas.append
    respx.get(f"{BASE}/programas").mock(
        side_effect=[httpx.Response(429, headers={"Retry-After": "7"}), httpx.Response(200, json=_envelope([], 1, 0, 0))]
    )
    c.pagina("/programas", 1)
    assert esperas == [7.0]
    c.close()


@respx.mock
def test_timeout_e_retentado_e_esgota_tentativas(cliente):
    rota = respx.get(f"{BASE}/programas").mock(side_effect=httpx.ConnectTimeout("lento"))
    with pytest.raises(ErroApi, match="4 tentativas"):
        cliente.pagina("/programas", 1)
    assert rota.call_count == 4


@respx.mock
def test_422_falha_sem_retry_com_detail(cliente):
    rota = respx.get(f"{BASE}/programas").mock(
        return_value=httpx.Response(422, json={"detail": [{"msg": "Input should be less than or equal to 1000"}]})
    )
    with pytest.raises(ErroApi, match="422.*less than or equal"):
        cliente.pagina("/programas", 1)
    assert rota.call_count == 1


@respx.mock
def test_corpo_html_gera_erro_claro(cliente):
    respx.get(f"{BASE}/programas").mock(return_value=httpx.Response(200, text="<html>Cloudflare</html>"))
    with pytest.raises(ErroApi, match="não é JSON.*Cloudflare"):
        cliente.pagina("/programas", 1)


@respx.mock
def test_envelope_invalido(cliente):
    respx.get(f"{BASE}/programas").mock(return_value=httpx.Response(200, json={"foo": 1}))
    with pytest.raises(ErroApi, match="envelope inesperado"):
        cliente.pagina("/programas", 1)


@respx.mock
def test_falha_em_pagina_intermediaria_propaga(cliente):
    def resp(req):
        n = int(req.url.params["pagina"])
        return httpx.Response(200, json=_envelope([{"id": n}], n, 3, 3)) if n != 2 else httpx.Response(400, json={"detail": "ruim"})
    respx.get(f"{BASE}/programas").mock(side_effect=resp)
    with pytest.raises(ErroApi, match="ruim"):
        list(cliente.iterar_registros("/programas"))


@respx.mock
def test_data_atualizacao(cliente):
    respx.get(f"{BASE}/data-atualizacao").mock(
        return_value=httpx.Response(200, json={"data_ultima_atualizacao": "2026-10-21T06:02:11"})
    )
    assert cliente.data_atualizacao() == datetime(2026, 10, 21, 6, 2, 11)


@pytest.mark.integracao
def test_programas_reais_batem_com_total_items():
    with ClienteFaF(_config(api_base_url="https://api-publica.transferegov.gestao.gov.br/fundoafundo",
                            api_tamanho_pagina=50, api_timeout=120, api_max_tentativas=6)) as c:
        varredura = c.iterar_registros("/programas")
        registros = list(varredura)
    assert len(registros) == varredura.total_items > 0
    assert len({r["id_programa"] for r in registros}) == len(registros)

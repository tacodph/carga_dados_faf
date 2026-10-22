"""Cliente HTTP da API Fundo a Fundo: data de atualização e varredura paginada com retry."""

import logging
import random
import time
from collections import deque
from concurrent.futures import ThreadPoolExecutor
from datetime import datetime
from typing import Iterator

import httpx

from .config import Config

log = logging.getLogger(__name__)

STATUS_RETRY = {429, 500, 502, 503, 504}


class ErroApi(Exception):
    pass


class Varredura:
    """Percorre todas as páginas de um endpoint. Iterável uma única vez.

    Ao final (ou durante), `total_items` e `paginas` informam o que a API declarou e quantas páginas foram lidas;
    `registros` conta o que foi entregue.
    """

    def __init__(self, cliente: "ClienteFaF", endpoint: str, filtros: dict):
        self._cliente = cliente
        self.endpoint = endpoint
        self._filtros = filtros
        self.total_items: int | None = None
        self.total_paginas: int | None = None
        self.paginas = 0
        self.registros = 0

    def __iter__(self) -> Iterator[dict]:
        cliente = self._cliente
        primeira = cliente.pagina(self.endpoint, 1, **self._filtros)
        self.total_items = primeira["total_items"]
        self.total_paginas = primeira["total_pages"]
        self.paginas = 1
        passo = max(1, self.total_paginas // 10)
        log.info("%s: %d registros em %d páginas", self.endpoint, self.total_items, self.total_paginas)

        self.registros += len(primeira["data"])
        yield from primeira["data"]

        # janela deslizante de requisições simultâneas, entregando na ordem das páginas
        with ThreadPoolExecutor(max_workers=cliente.config.api_concorrencia) as pool:
            pendentes: deque = deque()
            proxima = 2
            while proxima <= self.total_paginas or pendentes:
                while proxima <= self.total_paginas and len(pendentes) < cliente.config.api_concorrencia:
                    pendentes.append((proxima, pool.submit(cliente.pagina, self.endpoint, proxima, **self._filtros)))
                    proxima += 1
                numero, futuro = pendentes.popleft()
                try:
                    resposta = futuro.result()
                except BaseException:
                    for _, f in pendentes:
                        f.cancel()
                    raise
                dados = resposta["data"]
                self.paginas += 1
                if not dados:
                    log.warning("%s: página %d veio vazia (total_pages=%d)", self.endpoint, numero, self.total_paginas)
                self.registros += len(dados)
                yield from dados
                if numero % passo == 0:
                    log.info("%s: página %d/%d", self.endpoint, numero, self.total_paginas)


class ClienteFaF:
    def __init__(self, config: Config):
        self.config = config
        self._http = httpx.Client(
            base_url=config.api_base_url,
            timeout=config.api_timeout,
            headers={"User-Agent": config.api_user_agent, "Accept": "application/json"},
            trust_env=True,
        )
        self._dormir = time.sleep  # substituível nos testes

    def __enter__(self):
        return self

    def __exit__(self, *exc):
        self.close()

    def close(self):
        self._http.close()

    def _espera(self, tentativa: int, resposta: httpx.Response | None) -> float:
        if resposta is not None and (ra := resposta.headers.get("Retry-After", "").strip()).isdigit():
            return float(ra)
        return 2.0 ** tentativa + random.uniform(0, 1)  # 2, 4, 8, 16, 32 s (+ jitter)

    def _get(self, caminho: str, params: dict | None = None) -> dict:
        maximo = self.config.api_max_tentativas
        for tentativa in range(1, maximo + 1):
            resposta = None
            try:
                resposta = self._http.get(caminho, params=params)
                log.debug("GET %s %s -> %d (%.2fs)", caminho, params, resposta.status_code, resposta.elapsed.total_seconds())
                if resposta.status_code not in STATUS_RETRY:
                    return self._interpretar(caminho, params, resposta)
                motivo = f"HTTP {resposta.status_code}"
            except httpx.TransportError as e:  # timeout, conexão, leitura
                motivo = f"{type(e).__name__}: {e}"
            if tentativa == maximo:
                raise ErroApi(f"GET {caminho} {params or ''}: falhou após {maximo} tentativas ({motivo})")
            espera = self._espera(tentativa, resposta)
            log.warning("GET %s %s: %s; nova tentativa %d/%d em %.0fs", caminho, params or "", motivo, tentativa + 1, maximo, espera)
            self._dormir(espera)
        raise AssertionError("inalcançável")

    @staticmethod
    def _interpretar(caminho: str, params: dict | None, resposta: httpx.Response) -> dict:
        try:
            corpo = resposta.json()
        except ValueError:
            corpo = None
        if resposta.status_code >= 400:
            detalhe = corpo.get("detail") if isinstance(corpo, dict) else resposta.text[:500]
            raise ErroApi(f"GET {caminho} {params or ''}: HTTP {resposta.status_code}: {detalhe}")
        if not isinstance(corpo, dict):
            raise ErroApi(f"GET {caminho} {params or ''}: corpo inesperado (não é JSON): {resposta.text[:500]!r}")
        return corpo

    def data_atualizacao(self) -> datetime:
        corpo = self._get("/data-atualizacao")
        try:
            return datetime.fromisoformat(corpo["data_ultima_atualizacao"])
        except (KeyError, TypeError, ValueError):
            raise ErroApi(f"/data-atualizacao: resposta inesperada: {str(corpo)[:500]}") from None

    def pagina(self, endpoint: str, numero: int, **filtros) -> dict:
        """Envelope cru da API para uma página (validado)."""
        params = {"pagina": numero, "tamanho_da_pagina": self.config.api_tamanho_pagina, **filtros}
        corpo = self._get(endpoint, params)
        if not isinstance(corpo.get("data"), list) or not isinstance(corpo.get("total_pages"), int):
            raise ErroApi(f"GET {endpoint} {params}: envelope inesperado: {str(corpo)[:500]}")
        return corpo

    def iterar_registros(self, endpoint: str, **filtros) -> Varredura:
        return Varredura(self, endpoint, filtros)

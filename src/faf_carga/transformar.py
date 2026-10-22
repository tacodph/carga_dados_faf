"""Transformação pura: registro da API -> linha(s) das tabelas, conforme o catálogo."""

import logging
from decimal import Decimal

from .catalogo import Endpoint

log = logging.getLogger(__name__)


def converter(valor):
    """Ajusta um valor JSON para o COPY: float vira Decimal (sem erro binário) e NUL é removido de textos."""
    if isinstance(valor, float):
        return Decimal(repr(valor))
    if isinstance(valor, str) and "\x00" in valor:
        return valor.replace("\x00", "")
    return valor


class Transformador:
    """Converte os registros de um endpoint. Guarda as linhas das tabelas derivadas, deduplicadas pela chave
    (o último valor vence), e avisa uma única vez sobre campos novos ou ausentes."""

    def __init__(self, ep: Endpoint):
        self.ep = ep
        achatados = {campo for campo, _ in ep.achatar.values()}
        self._esperado = (
            {c for c in ep.colunas if c not in ep.achatar} | achatados | {d.campo for d in ep.derivadas}
        )
        self._derivadas = {d.tabela: {} for d in ep.derivadas}
        self._indices_chave = {
            d.tabela: [d.colunas.index(c) for c in d.chave] for d in ep.derivadas
        }
        self._avisados: set[tuple[str, str]] = set()

    def _avisar(self, registro: dict):
        for campo in registro.keys() - self._esperado:
            if ("novo", campo) not in self._avisados:
                self._avisados.add(("novo", campo))
                log.warning("%s: campo novo na API, ignorado (ajustar DDL e catálogo): %s", self.ep.endpoint, campo)
        for campo in self._esperado - registro.keys():
            if ("ausente", campo) not in self._avisados:
                self._avisados.add(("ausente", campo))
                log.warning("%s: campo do catálogo ausente na resposta, gravado como nulo: %s", self.ep.endpoint, campo)

    def linha(self, registro: dict) -> tuple:
        if registro.keys() != self._esperado:
            self._avisar(registro)
        achatar = self.ep.achatar
        valores = []
        for coluna in self.ep.colunas:
            if coluna in achatar:
                campo, sub = achatar[coluna]
                no = registro.get(campo)
                valores.append(converter(no.get(sub)) if no else None)
            else:
                valores.append(converter(registro.get(coluna)))
        return tuple(valores)

    def acumular_derivadas(self, registro: dict):
        for d in self.ep.derivadas:
            indices = self._indices_chave[d.tabela]
            destino = self._derivadas[d.tabela]
            for linha in d.extrair(registro):
                linha = tuple(converter(v) for v in linha)
                destino[tuple(linha[i] for i in indices)] = linha

    def linhas_derivadas(self, tabela: str):
        return self._derivadas[tabela].values()

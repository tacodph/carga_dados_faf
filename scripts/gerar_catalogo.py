"""Gera src/faf_carga/catalogo.py a partir da mesma fonte do DDL (scripts/gerar_ddl.py).

Reexecutável: python scripts/gerar_catalogo.py
"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import gerar_ddl as g  # noqa: E402

DESTINO = g.RAIZ / "src" / "faf_carga" / "catalogo.py"

# campo aninhado (objeto) -> subcampo que vira coluna
SUBCAMPO = {
    "saldo_final_dado_bancario": "saldo_final_gestao_financeira",
    "categorias_despesa_lancamento": "caminho_categoria_lancamento",
    "categorias_despesa_subtransacao": "caminho_categoria_subtransacao",
}
# tabela derivada -> (endpoint pai, campo aninhado do pai, função extratora)
DERIVADAS = {
    "programas_natureza_despesa_faf": ("/programas", "programa_natureza_despesa", "_natureza_despesa"),
    "programas_acao_orcamentaria_faf": ("/programas", "programa_acao_orcamentaria", "_acao_orcamentaria"),
    "gestao_financeira_saldo_conta_faf": (
        "/planos-acao-dados-bancarios", "saldo_final_dado_bancario", "_saldo_conta"),
}

CABECALHO = '''"""Catálogo declarativo dos endpoints da API Fundo a Fundo.

GERADO por scripts/gerar_catalogo.py (a partir de docs/openapi.json + modelo SchemaSpy). Não editar à mão:
ajuste o gerador e rode-o de novo. As colunas seguem exatamente o DDL de sql/003_tabelas_dados.sql.
"""

from dataclasses import dataclass, field
from typing import Callable, Iterable


@dataclass(frozen=True)
class Derivada:
    """Tabela alimentada por um campo aninhado do registro do endpoint."""

    tabela: str
    campo: str  # campo aninhado da API de onde as linhas saem
    colunas: tuple[str, ...]
    chave: tuple[str, ...]
    extrair: Callable[[dict], Iterable[tuple]]  # registro -> linhas (valores na ordem de `colunas`)


@dataclass(frozen=True)
class Endpoint:
    endpoint: str
    tabela: str
    chave: tuple[str, ...]
    colunas: tuple[str, ...]  # ordem do DDL (sem dt_carga/id_execucao)
    achatar: dict = field(default_factory=dict)  # coluna -> (campo aninhado, subcampo)
    derivadas: tuple[Derivada, ...] = ()

    @property
    def tabelas(self) -> tuple[str, ...]:
        return (self.tabela, *(d.tabela for d in self.derivadas))


def _natureza_despesa(r: dict):
    return [
        (r["id_programa"], x.get("grupo_natureza_despesa_programa"))
        for x in r.get("programa_natureza_despesa") or []
        if x.get("grupo_natureza_despesa_programa") is not None
    ]


def _acao_orcamentaria(r: dict):
    return [
        (r["id_programa"], x.get("codigo_acao_orcamentaria_programa"), x.get("descricao_acao_orcamentaria_programa"))
        for x in r.get("programa_acao_orcamentaria") or []
        if x.get("codigo_acao_orcamentaria_programa") is not None
    ]


def _saldo_conta(r: dict):
    conta, saldo = r.get("id_agencia_conta"), r.get("saldo_final_dado_bancario")
    return [(conta, saldo.get("saldo_final_gestao_financeira"))] if conta and saldo else []


'''


def lista(itens, recuo: int) -> str:
    esp = " " * recuo
    return "(\n" + "".join(f'{esp}    "{i}",\n' for i in itens) + f"{esp})"


def main():
    tabelas, _ = g.montar()
    por_nome = {t["nome"]: t for t in tabelas}
    deriv_por_pai: dict[str, list[str]] = {}
    for tabela, (pai, _, _) in DERIVADAS.items():
        deriv_por_pai.setdefault(pai, []).append(tabela)

    saida = [CABECALHO, "CATALOGO: tuple[Endpoint, ...] = (\n"]
    for caminho, (tabela, pk) in g.ENDPOINTS.items():
        colunas = [c for c, _, _ in por_nome[tabela]["colunas"]]
        achatar = {col: (campo, SUBCAMPO[campo]) for campo, (col, _, _) in g.ACHATADOS.get(tabela, {}).items()}
        saida.append(f'    Endpoint(\n        endpoint="{caminho}",\n        tabela="{tabela}",\n')
        saida.append(f"        chave={tuple(pk)!r},\n        colunas={lista(colunas, 8)},\n")
        if achatar:
            saida.append(f"        achatar={achatar!r},\n")
        if caminho in deriv_por_pai:
            saida.append("        derivadas=(\n")
            for dt in deriv_por_pai[caminho]:
                _, campo, func = DERIVADAS[dt]
                cols = [c for c, _, _ in por_nome[dt]["colunas"]]
                saida.append(
                    f'            Derivada(\n                tabela="{dt}",\n                campo="{campo}",\n'
                    f"                colunas={tuple(cols)!r},\n                chave={tuple(por_nome[dt]['pk'])!r},\n"
                    f"                extrair={func},\n            ),\n"
                )
            saida.append("        ),\n")
        saida.append("    ),\n")
    saida.append(")\n\n\ndef por_endpoint(endpoint: str) -> Endpoint:\n")
    saida.append("    return next(e for e in CATALOGO if e.endpoint == endpoint)\n")
    DESTINO.write_text("".join(saida), encoding="utf-8", newline="\n")
    print(f"{len(tabelas)} tabelas -> {DESTINO}")


if __name__ == "__main__":
    main()

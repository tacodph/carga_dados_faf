"""Gera sql/003_tabelas_dados.sql, sql/004_tabelas_staging.sql e sql/relatorio_mapeamento.md.

Fontes: docs/openapi.json (campos e tipos da API) e o XML do modelo SchemaSpy (tamanhos e descrições).
Reexecutável: python scripts/gerar_ddl.py
"""

import hashlib
import json
import re
import xml.etree.ElementTree as ET
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
OPENAPI = RAIZ / "docs" / "openapi.json"
MODELO = RAIZ / "docs" / "modelo_dados_api-faf" / "api-transferegov.api_transferegov_faf.xml"
SQL = RAIZ / "sql"
ESQUEMA = "base_transferencias_fundo_fundo"
ESQUEMA_STG = "stg_transferencias_fundo_fundo"

# Tamanho mínimo dos varchar. O modelo SchemaSpy tem tamanhos justos demais (ex.: nome de ente com varchar(5),
# situacao_plano_acao com 35 e valores reais de 42); em PostgreSQL varchar(255) não custa mais que varchar(5).
PISO_VARCHAR = 255
PISO_VARCHAR_NOME = 255

# endpoint -> (tabela, chave primária)
ENDPOINTS = {
    "/programas": ("programas_faf", ["id_programa"]),
    "/programas-beneficiarios": ("programas_beneficiarios_faf", ["id_beneficiario_programa"]),
    "/programas-gestao-agil": ("programas_ageis_faf", ["id_programa_agil"]),
    "/planos-acao": ("planos_acao_faf", ["id_plano_acao"]),
    "/planos-acao-dados-bancarios": ("planos_acao_dados_bancarios_faf", ["id_plano_acao_dado_bancario"]),
    "/planos-acao-metas": ("planos_acao_metas_faf", ["id_meta_plano_acao"]),
    "/planos-acao-metas-acoes": ("planos_acao_metas_acoes_faf", ["id_acao_meta_plano_acao"]),
    "/planos-acao-destinacao-recursos": ("planos_acao_destinacao_recursos_faf", ["id_destinacao_recursos_plano_acao"]),
    "/planos-acao-historico": ("planos_acao_historico_faf", ["id_historico_plano_acao"]),
    "/planos-acao-analises": ("planos_acao_analises_faf", ["id_analise_plano_acao"]),
    "/planos-acao-analises-responsaveis": ("planos_acao_analises_responsaveis_faf", ["id_analise_responsavel_plano_acao"]),
    "/termos-adesao": ("termos_adesao_faf", ["id_termo_adesao"]),
    "/termos-adesao-historico": ("termos_adesao_historico_faf", ["id_historico_termo_adesao"]),
    "/empenhos": ("empenhos_faf", ["id_empenho"]),
    "/gestao-financeira-lancamentos": ("gestao_financeira_lancamentos_faf", ["id_lancamento_gestao_financeira"]),
    "/gestao-financeira-subtransacoes": ("gestao_financeira_subtransacoes_faf", ["id_subtransacao_gestao_financeira"]),
    "/relatorios-gestao": ("relatorios_gestao_faf", ["id_relatorio_gestao"]),
    "/relatorios-gestao-acoes": ("relatorios_gestao_acoes_faf", ["id_acao_relatorio_gestao"]),
    "/relatorios-gestao-analises": ("relatorios_gestao_analises_faf", ["id_relatorio_gestao_analise"]),
    "/relatorios-gestao-analises-responsaveis": (
        "relatorios_gestao_analises_responsaveis_faf",
        ["id_relatorio_gestao_analise_responsavel"],
    ),
}

# coluna de relacionamento -> "tabela.coluna" (só comentário e índice; sem foreign key)
RELACOES = {
    "programas_beneficiarios_faf": {"id_programa": "programas_faf.id_programa"},
    "programas_ageis_faf": {"id_programa": "programas_faf.id_programa"},
    "planos_acao_faf": {"id_programa": "programas_faf.id_programa"},
    "planos_acao_dados_bancarios_faf": {
        "id_plano_acao": "planos_acao_faf.id_plano_acao",
        "id_agencia_conta": "gestao_financeira_saldo_conta_faf.id_agencia_conta",
    },
    "planos_acao_metas_faf": {"id_plano_acao": "planos_acao_faf.id_plano_acao"},
    "planos_acao_metas_acoes_faf": {"id_meta_plano_acao": "planos_acao_metas_faf.id_meta_plano_acao"},
    "planos_acao_destinacao_recursos_faf": {"id_plano_acao": "planos_acao_faf.id_plano_acao"},
    "planos_acao_historico_faf": {"id_plano_acao": "planos_acao_faf.id_plano_acao"},
    "planos_acao_analises_faf": {
        "id_plano_acao": "planos_acao_faf.id_plano_acao",
        "id_historico_plano_acao": "planos_acao_historico_faf.id_historico_plano_acao",
    },
    "planos_acao_analises_responsaveis_faf": {"id_analise_plano_acao": "planos_acao_analises_faf.id_analise_plano_acao"},
    "termos_adesao_faf": {"id_plano_acao": "planos_acao_faf.id_plano_acao"},
    "termos_adesao_historico_faf": {"id_termo_adesao": "termos_adesao_faf.id_termo_adesao"},
    "empenhos_faf": {"id_plano_acao": "planos_acao_faf.id_plano_acao"},
    "gestao_financeira_lancamentos_faf": {"id_agencia_conta": "gestao_financeira_saldo_conta_faf.id_agencia_conta"},
    "gestao_financeira_subtransacoes_faf": {
        "id_lancamento_gestao_financeira": "gestao_financeira_lancamentos_faf.id_lancamento_gestao_financeira"
    },
    "relatorios_gestao_faf": {"id_plano_acao": "planos_acao_faf.id_plano_acao"},
    "relatorios_gestao_acoes_faf": {
        "id_relatorio_gestao": "relatorios_gestao_faf.id_relatorio_gestao",
        "id_acao_meta_plano_acao": "planos_acao_metas_acoes_faf.id_acao_meta_plano_acao",
    },
    "relatorios_gestao_analises_faf": {"id_relatorio_gestao": "relatorios_gestao_faf.id_relatorio_gestao"},
    "relatorios_gestao_analises_responsaveis_faf": {
        "id_relatorio_gestao_analise": "relatorios_gestao_analises_faf.id_relatorio_gestao_analise"
    },
}

# campo da API -> coluna equivalente no modelo SchemaSpy (quando os nomes diferem)
ALIAS = {
    "empenhos_faf": {
        "ug_emitente_empenho": "ug_emitente",
        "data_emissao_empenho": "dt_emissao",
        "fonte_recurso_empenho": "fonte_recurso",
        "natureza_despesa_empenho": "natureza_despesa",
        "versao_empenho": "versao",
    },
    "gestao_financeira_lancamentos_faf": {"valor_lancamento_gestao_financeira": "valor_gestao_financeira"},
    "gestao_financeira_subtransacoes_faf": {
        "descricao_tp_pessoa_beneficiario_subtransacao_gestao_financeira": "descricao_tipo_pessoa_beneficiario_subtransacao_gestao_financeira",
        "doc_beneficiario_subtransacao_gestao_financeira_mask": "numero_documento_beneficiario_subtransacao_gestao_financeira_mask",
    },
    "planos_acao_analises_faf": {
        "tipo_resultado_analise_plano_acao": "resultado_analise_plano_acao",
        "tipo_origem_analise_plano_acao": "origem_analise_plano_acao",
    },
    "planos_acao_dados_bancarios_faf": {
        f"{base}_plano_acao_dado_bancario": base
        for base in [
            "codigo_banco", "nome_banco", "numero_agencia", "dv_agencia", "numero_conta", "dv_conta",
            "situacao_conta", "data_abertura_conta",
        ]
    }
    | {"nome_programa_agil_conta_plano_acao_dado_bancario": "nome_programa_agil_conta"},
}

# campos aninhados que viram coluna da própria tabela: campo -> (coluna, sql, descrição)
ACHATADOS = {
    "planos_acao_dados_bancarios_faf": {
        "saldo_final_dado_bancario": (
            "saldo_final_conta_plano_acao_dado_bancario",
            "numeric(15,2)",
            "Saldo Final da Conta Bancária (campo aninhado saldo_final_dado_bancario.saldo_final_gestao_financeira)",
        )
    },
    "gestao_financeira_lancamentos_faf": {
        "categorias_despesa_lancamento": (
            "caminho_categoria_despesa_lancamento_gestao_financeira",
            "varchar(255)",
            "Caminho Hierárquico da Categoria de Despesa do Lançamento (campo aninhado categorias_despesa_lancamento)",
        )
    },
    "gestao_financeira_subtransacoes_faf": {
        "categorias_despesa_subtransacao": (
            "caminho_categoria_despesa_subtransacao_gestao_financeira",
            "varchar(255)",
            "Caminho Hierárquico da Categoria de Despesa da Subtransação (campo aninhado categorias_despesa_subtransacao)",
        )
    },
}
# campos aninhados que viram tabela derivada (ficam fora da tabela principal)
DERIVADOS = {"programas_faf": {"programa_natureza_despesa", "programa_acao_orcamentaria"}}

# tabelas derivadas: (nome, comentário, [(coluna, sql, descrição, nome na tabela do modelo)], pk, relações)
TABELAS_DERIVADAS = [
    (
        "programas_natureza_despesa_faf",
        "Naturezas de Despesa dos Programas FAF (derivada da lista programa_natureza_despesa de /programas)",
        [
            ("id_programa", "bigint", "Identificador Único do Programa", None),
            ("grupo_natureza_despesa_programa", "varchar(15)", None, "grupo_natureza_despesa_programa"),
        ],
        ["id_programa", "grupo_natureza_despesa_programa"],
        {"id_programa": "programas_faf.id_programa"},
    ),
    (
        "programas_acao_orcamentaria_faf",
        "Ações Orçamentárias dos Programas FAF (derivada da lista programa_acao_orcamentaria de /programas)",
        [
            ("id_programa", "bigint", "Identificador Único do Programa", None),
            ("codigo_acao_orcamentaria_programa", "varchar(20)", None, "codigo_acao_orcamentaria_programa"),
            ("descricao_acao_orcamentaria_programa", "varchar(180)", None, "descricao_acao_orcamentaria_programa"),
        ],
        ["id_programa", "codigo_acao_orcamentaria_programa"],
        {"id_programa": "programas_faf.id_programa"},
    ),
    (
        "gestao_financeira_saldo_conta_faf",
        "Saldos em Conta dos Planos de Ação FAF (derivada de saldo_final_dado_bancario de /planos-acao-dados-bancarios, "
        "um registro por id_agencia_conta)",
        [
            ("id_agencia_conta", "varchar(20)", None, "id_agencia_conta"),
            ("saldo_final_gestao_financeira", "numeric(15,2)", None, "saldo_final_gestao_financeira"),
        ],
        ["id_agencia_conta"],
        {},
    ),
]


COMENTARIOS_TECNICOS = {
    "dt_carga": "Quando o registro apareceu pela primeira vez na base (não muda mais)",
    "id_execucao": "Última execução (controle_execucao) que inseriu, alterou ou removeu o registro",
    "dt_atualizacao": "Última vez em que o conteúdo do registro mudou",
    "hash_registro": "md5 das colunas de dados (row(...)::text); detecta alteração no merge incremental",
    "dt_remocao_origem": "Preenchida quando o registro deixou de vir da API; nula = ativo",
}


def ident(nome: str) -> str:
    assert len(nome) <= 63, f"identificador com mais de 63 caracteres: {nome}"
    return nome


def aspas(texto: str) -> str:
    return "'" + texto.replace("'", "''") + "'"


def nome_indice(tabela: str, coluna: str) -> str:
    nome = f"ix_{tabela}_{coluna}"
    if len(nome) > 63:
        nome = nome[:54] + "_" + hashlib.md5(nome.encode()).hexdigest()[:8]
    return nome


class Modelo:
    def __init__(self):
        raiz = ET.parse(MODELO).getroot()
        self.tabelas = {}
        for t in raiz.iter("table"):
            colunas = {
                c.get("name"): {
                    "tipo": c.get("type"),
                    "tamanho": int(c.get("size")),
                    "digitos": int(c.get("digits") or 0),
                    "descricao": (c.get("remarks") or "").strip(),
                }
                for c in t.findall("column")
            }
            self.tabelas[t.get("name")] = {"descricao": (t.get("remarks") or "").strip(), "colunas": colunas}

    def coluna(self, tabela: str, nome: str):
        cols = self.tabelas.get(tabela, {}).get("colunas", {})
        return cols.get(nome) or cols.get(nome[:63])  # SchemaSpy/Postgres truncam em 63


def desembrulhar(p: dict) -> dict:
    if "anyOf" in p:
        return next(a for a in p["anyOf"] if a.get("type") != "null")
    return p


def sql_string(tamanho_modelo, nome: str) -> str:
    n = tamanho_modelo or 255
    if n > 4000:
        return "text"
    piso = PISO_VARCHAR_NOME if ("nome" in nome or "municipio" in nome) else PISO_VARCHAR
    return f"varchar({max(n, piso)})"


def montar():
    api = json.load(open(OPENAPI, encoding="utf-8"))
    schemas = api["components"]["schemas"]
    modelo = Modelo()
    tabelas = []  # dicts: nome, descricao, colunas [(nome, sql, descricao)], pk, relacoes
    rel = {"sem_modelo": [], "tipo_divergente": [], "alargadas": [], "sem_api": []}

    for caminho, (tabela, pk) in ENDPOINTS.items():
        resposta = api["paths"][caminho]["get"]["responses"]["200"]["content"]["application/json"]["schema"]
        item = schemas[resposta["$ref"].split("/")[-1]]
        item = schemas[item["properties"]["data"]["items"]["$ref"].split("/")[-1]]
        params = {p["name"]: p.get("description", "") for p in api["paths"][caminho]["get"].get("parameters", [])}
        achatados = ACHATADOS.get(tabela, {})
        colunas, usadas = [], set()
        for campo, prop in item["properties"].items():
            if campo in DERIVADOS.get(tabela, ()):
                continue
            if campo in achatados:
                nome, sql, desc = achatados[campo]
                colunas.append((ident(nome), sql, desc))
                continue
            real = desembrulhar(prop)
            tipo, formato = real.get("type"), real.get("format")
            nome_modelo = ALIAS.get(tabela, {}).get(campo, campo)
            m = modelo.coluna(tabela, nome_modelo)
            if m:
                usadas.add(nome_modelo[:63])
            else:
                rel["sem_modelo"].append((tabela, campo, tipo))
            if formato == "date":
                sql = "date"
            elif formato == "date-time":
                sql = "timestamp"
            elif tipo == "string":
                if m and m["tipo"] == "varchar":
                    sql = sql_string(m["tamanho"], campo)
                    if sql != f"varchar({m['tamanho']})" and not (sql == "text" and m["tamanho"] > 4000):
                        rel["alargadas"].append((tabela, campo, m["tamanho"], sql))
                else:
                    # código numérico no modelo (ex.: banco, agência), mas texto na API: preserva zeros à esquerda
                    sql = "varchar(30)" if m else sql_string(None, campo)
                    if m:
                        rel["tipo_divergente"].append((tabela, campo, f"API string × modelo {m['tipo']}", sql))
            elif tipo == "integer":
                sql = "bigint"
                if m and m["tipo"] == "varchar":
                    rel["tipo_divergente"].append((tabela, campo, "API integer × modelo varchar", sql))
            elif tipo == "number":
                sql = f"numeric(15,{m['digitos'] if m and m['tipo'] == 'numeric' else 2})"
            elif tipo == "boolean":
                sql = "boolean"
            else:
                raise SystemExit(f"tipo não tratado: {tabela}.{campo} {real}")
            desc = (m["descricao"] if m else "") or params.get(campo, "")
            colunas.append((ident(campo), sql, desc))
        for col in modelo.tabelas.get(tabela, {}).get("colunas", {}):
            if col not in usadas and col not in {a[0] for a in achatados.values()}:
                rel["sem_api"].append((tabela, col))
        tabelas.append(
            {
                "nome": tabela,
                "descricao": modelo.tabelas.get(tabela, {}).get("descricao", "") + f" (endpoint {caminho})",
                "colunas": colunas,
                "pk": pk,
                "relacoes": RELACOES.get(tabela, {}),
            }
        )

    for nome, desc, cols, pk, relacoes in TABELAS_DERIVADAS:
        colunas = []
        for c, sql, d, ref in cols:
            m = modelo.coluna(nome, ref) if ref else None
            colunas.append((c, sql, d or (m["descricao"] if m else "")))
        tabelas.append({"nome": nome, "descricao": desc, "colunas": colunas, "pk": pk, "relacoes": relacoes})
    return tabelas, rel


def gerar_dados(tabelas) -> str:
    out = [
        "-- Gerado por scripts/gerar_ddl.py — não editar à mão.",
        f"set search_path to {ESQUEMA};",
        "",
    ]
    for t in tabelas:
        nome = t["nome"]
        linhas = [f"    {c} {sql}" for c, sql, _ in t["colunas"]]
        linhas += [
            "    dt_carga timestamptz not null default now()",
            "    id_execucao bigint not null",
            "    dt_atualizacao timestamptz not null default now()",
            "    hash_registro char(32) not null",
            "    dt_remocao_origem timestamptz",
        ]
        # vírgulas
        corpo = ",\n".join(l if i else l for i, l in enumerate(linhas))
        pk = ", ".join(t["pk"])
        out.append(f"create table if not exists {nome} (\n{corpo},\n    primary key ({pk})\n);")
        for col in t["relacoes"]:
            if col not in t["pk"][:1]:
                out.append(f"create index if not exists {nome_indice(nome, col)} on {nome} ({col});")
        out.append(f"comment on table {nome} is {aspas(t['descricao'])};")
        for c, _, d in t["colunas"]:
            texto = d
            if c in t["relacoes"]:
                texto = (texto + " — " if texto else "") + f"Relaciona com {t['relacoes'][c]}"
            if texto:
                out.append(f"comment on column {nome}.{c} is {aspas(texto)};")
        # dt_atualizacao/hash_registro/dt_remocao_origem (comentários e índice) ficam em 007, que também as adiciona em
        # tabelas já existentes; aqui só o que as tabelas antigas já têm
        for coluna in ("dt_carga", "id_execucao"):
            out.append(f"comment on column {nome}.{coluna} is {aspas(COMENTARIOS_TECNICOS[coluna])};")
        out.append("")
    return "\n".join(out)


def gerar_staging(tabelas) -> str:
    out = [
        "-- Gerado por scripts/gerar_ddl.py — não editar à mão.",
        "-- Staging: cópia bruta do último download, mesmos nomes das tabelas finais (esquema próprio).",
        f"set search_path to {ESQUEMA_STG};",
        "",
    ]
    for t in tabelas:
        corpo = ",\n".join(f"    {c} {sql}" for c, sql, _ in t["colunas"])
        out.append(f"create unlogged table if not exists {t['nome']} (\n{corpo}\n);")
        out.append("")
    return "\n".join(out)


def gerar_alargamento(tabelas) -> str:
    """006: alarga os varchar das tabelas que já existem (003/004 são create-if-not-exists e não os alteram)."""
    out = [
        "-- Gerado por scripts/gerar_ddl.py — alarga colunas varchar já criadas com o tamanho do modelo SchemaSpy.",
        "-- Aumentar varchar(n) em PostgreSQL é só catálogo (sem reescrita da tabela). Idempotente.",
        "",
    ]
    for esquema in (ESQUEMA, ESQUEMA_STG):
        for t in tabelas:
            for c, sql, _ in t["colunas"]:
                if sql.startswith("varchar"):
                    out.append(f"alter table {esquema}.{t['nome']} alter column {c} type {sql};")
    out.append("")
    return "\n".join(out)


def gerar_migracao_incremental(tabelas) -> str:
    """007: leva um banco já carregado (modelo antigo: delete+insert, stg_* no esquema base) ao modelo incremental."""
    out = [
        "-- Gerado por scripts/gerar_ddl.py — migra o banco existente para o modelo incremental. Idempotente.",
        "-- Em banco novo, 003 já cria tudo isto e este script não altera nada.",
        f"set search_path to {ESQUEMA};",
        "",
        "alter table controle_execucao_endpoint",
        "    add column if not exists qtd_inseridos bigint,",
        "    add column if not exists qtd_atualizados bigint,",
        "    add column if not exists qtd_removidos bigint;",
        "",
    ]
    for t in tabelas:
        n = t["nome"]
        cols = ", ".join(c for c, _, _ in t["colunas"])
        out += [
            f"alter table {n}",
            "    add column if not exists dt_atualizacao timestamptz,",
            "    add column if not exists hash_registro char(32),",
            "    add column if not exists dt_remocao_origem timestamptz;",
            f"update {n} set hash_registro = md5(row({cols})::text), dt_atualizacao = coalesce(dt_atualizacao, dt_carga)",
            "    where hash_registro is null;",
            f"alter table {n} alter column dt_atualizacao set default now(), alter column dt_atualizacao set not null,",
            "    alter column hash_registro set not null;",
            f"create index if not exists {nome_indice(n, 'dt_atualizacao')} on {n} (dt_atualizacao);",
        ]
        for coluna, texto in COMENTARIOS_TECNICOS.items():
            out.append(f"comment on column {n}.{coluna} is {aspas(texto)};")
        out.append("")
    out.append("-- staging antigo (mesmo esquema da base): era só cópia temporária do último download")
    out += [f"drop table if exists stg_{t['nome']};" for t in tabelas]
    out.append("")
    return "\n".join(out)


def gerar_relatorio(tabelas, rel) -> str:
    r = [
        "# Relatório de mapeamento API × modelo",
        "",
        "Gerado por `scripts/gerar_ddl.py`. Para revisão humana.",
        "",
        f"Tabelas de dados: **{len(tabelas)}** · colunas (sem as técnicas): **{sum(len(t['colunas']) for t in tabelas)}**",
        "",
        "## Campos da API sem coluna correspondente no modelo",
        "Tipo e tamanho vêm só do OpenAPI (`varchar(255)` quando string); descrição vem do parâmetro de filtro.",
        "",
    ]
    r += [f"- `{t}.{c}` ({tp})" for t, c, tp in rel["sem_modelo"]] or ["- (nenhum)"]
    r += ["", "## Tipos divergentes (API × modelo) — prevaleceu a API", ""]
    r += [f"- `{t}.{c}`: {msg} → `{sql}`" for t, c, msg, sql in rel["tipo_divergente"]] or ["- (nenhum)"]
    r += [
        "",
        f"## Varchar alargados (modelo muito justo; piso {PISO_VARCHAR}, {PISO_VARCHAR_NOME} para nomes/municípios)",
        "",
    ]
    r += [f"- `{t}.{c}`: {antigo} → `{sql}`" for t, c, antigo, sql in rel["alargadas"]] or ["- (nenhum)"]
    r += [
        "",
        "## Colunas do modelo que a API não expõe (não criadas)",
        "Sensíveis (CPF, documentos não mascarados, contas de favorecidos) ou internas.",
        "",
    ]
    r += [f"- `{t}.{c}`" for t, c in rel["sem_api"]] or ["- (nenhuma)"]
    r.append("")
    return "\n".join(r)


def main():
    tabelas, rel = montar()
    SQL.mkdir(exist_ok=True)
    (SQL / "003_tabelas_dados.sql").write_text(gerar_dados(tabelas), encoding="utf-8", newline="\n")
    (SQL / "004_tabelas_staging.sql").write_text(gerar_staging(tabelas), encoding="utf-8", newline="\n")
    (SQL / "006_alargar_varchar.sql").write_text(gerar_alargamento(tabelas), encoding="utf-8", newline="\n")
    (SQL / "007_incremental.sql").write_text(gerar_migracao_incremental(tabelas), encoding="utf-8", newline="\n")
    (SQL / "relatorio_mapeamento.md").write_text(gerar_relatorio(tabelas, rel), encoding="utf-8", newline="\n")
    print(f"{len(tabelas)} tabelas; sem modelo: {len(rel['sem_modelo'])}; tipo divergente: {len(rel['tipo_divergente'])}; "
          f"alargadas: {len(rel['alargadas'])}; modelo sem API: {len(rel['sem_api'])}")


if __name__ == "__main__":
    main()

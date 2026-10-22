"""Gera sql/validacao.sql (consultas de conferência pós-carga). Reexecutável: python scripts/gerar_validacao.py"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import gerar_ddl as g  # noqa: E402

DESTINO = g.SQL / "validacao.sql"


def main():
    tabelas, _ = g.montar()
    nomes = [t["nome"] for t in tabelas]
    sai = [
        "-- Gerado por scripts/gerar_validacao.py — consultas de conferência após a carga (somente leitura).",
        f"set search_path to {g.ESQUEMA};",
        "",
        "-- 1. Última execução completa (SUCESSO): total da API x linhas gravadas por endpoint",
        "select e.endpoint, e.tabela, e.total_items_api, e.linhas_gravadas,",
        "       (e.total_items_api = e.linhas_gravadas) as bate, e.status, e.paginas,",
        "       e.qtd_inseridos, e.qtd_atualizados, e.qtd_removidos,"
        "       round(extract(epoch from e.dt_fim - e.dt_inicio)) as segundos",
        "from controle_execucao_endpoint e",
        "where e.id_execucao = (select max(id_execucao) from controle_execucao where status = 'SUCESSO')",
        "order by e.dt_inicio;",
        "",
        "-- 2. Contagem atual de cada tabela (ativos x removidos da origem)",
        "\nunion all\n".join(
            f"select '{n}' as tabela, count(*) filter (where dt_remocao_origem is null) as ativos, "
            f"count(*) filter (where dt_remocao_origem is not null) as removidos from {n}" for n in nomes)
        + "\norder by 1;",
        "",
        "-- 3. Órfãos por relacionamento (informativo: dados abertos podem ter órfãos; não é erro)",
    ]
    rels = [(t, c, d) for t, cols in g.RELACOES.items() for c, d in cols.items()]
    rels += [("programas_natureza_despesa_faf", "id_programa", "programas_faf.id_programa"),
             ("programas_acao_orcamentaria_faf", "id_programa", "programas_faf.id_programa")]
    sai.append("\nunion all\n".join(
        f"select '{t}.{c} -> {d}' as relacao, count(*) as orfaos from {t} f "
        f"where f.dt_remocao_origem is null and f.{c} is not null and not exists "
        f"(select 1 from {d.split('.')[0]} p where p.{d.split('.')[1]} = f.{c} and p.dt_remocao_origem is null)"
        for t, c, d in rels) + "\norder by 2 desc;")
    sai += ["", "-- 4. Nulos nas colunas de relacionamento (deveriam estar sempre preenchidas)"]
    sai.append("\nunion all\n".join(
        f"select '{t}.{c}' as coluna, count(*) as nulos from {t} where dt_remocao_origem is null and {c} is null"
        for t, c, _ in rels)
        + "\norder by 2 desc;")
    sai += [
        "",
        "-- 5. Somatórios de controle por ano",
        "select extract(year from data_inicio_vigencia_plano_acao)::int as ano, count(*) as planos,",
        "       sum(valor_total_plano_acao) as valor_total_plano, sum(valor_total_repasse_plano_acao) as valor_repasse",
        "from planos_acao_faf where dt_remocao_origem is null group by 1 order by 1;",
        "",
        "select extract(year from data_lancamento_gestao_financeira)::int as ano, tipo_operacao_gestao_financeira as tipo,",
        "       count(*) as lancamentos, sum(valor_lancamento_gestao_financeira) as valor",
        "from gestao_financeira_lancamentos_faf where dt_remocao_origem is null group by 1, 2 order by 1, 2;",
        "",
        "select ano_empenho, count(*) as empenhos, sum(valor_empenho) as valor",
        "from empenhos_faf where dt_remocao_origem is null group by 1 order by 1;",
        "",
        "-- 6. Registros alterados depois de inseridos e registros removidos da origem, por tabela",
        "\nunion all\n".join(
            f"select '{n}' as tabela, "
            f"count(*) filter (where dt_atualizacao > dt_carga and dt_remocao_origem is null) as alterados, "
            f"count(*) filter (where dt_remocao_origem is not null) as removidos, "
            f"max(dt_atualizacao) as ultima_alteracao from {n}" for n in nomes)
        + "\norder by 1;",
        "",
        "-- 7. Últimas 10 execuções",
        "select id_execucao, dt_inicio, round(extract(epoch from dt_fim - dt_inicio)) as segundos, status, forcada,",
        "       endpoints_solicitados, dt_atualizacao_origem, left(mensagem, 120) as mensagem",
        "from controle_execucao order by id_execucao desc limit 10;",
        "",
    ]
    DESTINO.write_text("\n".join(sai), encoding="utf-8", newline="\n")
    print(f"{DESTINO} ({len(rels)} relacionamentos)")


if __name__ == "__main__":
    main()

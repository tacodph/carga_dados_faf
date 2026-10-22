-- Gerado por scripts/gerar_validacao.py — consultas de conferência após a carga (somente leitura).
set search_path to base_transferencias_fundo_fundo;

-- 1. Última execução completa (SUCESSO): total da API x linhas gravadas por endpoint
select e.endpoint, e.tabela, e.total_items_api, e.linhas_gravadas,
       (e.total_items_api = e.linhas_gravadas) as bate, e.status, e.paginas,
       e.qtd_inseridos, e.qtd_atualizados, e.qtd_removidos,       round(extract(epoch from e.dt_fim - e.dt_inicio)) as segundos
from controle_execucao_endpoint e
where e.id_execucao = (select max(id_execucao) from controle_execucao where status = 'SUCESSO')
order by e.dt_inicio;

-- 2. Contagem atual de cada tabela (ativos x removidos da origem)
select 'programas_faf' as tabela, count(*) filter (where dt_remocao_origem is null) as ativos, count(*) filter (where dt_remocao_origem is not null) as removidos from programas_faf
union all
select 'programas_beneficiarios_faf' as tabela, count(*) filter (where dt_remocao_origem is null) as ativos, count(*) filter (where dt_remocao_origem is not null) as removidos from programas_beneficiarios_faf
union all
select 'programas_ageis_faf' as tabela, count(*) filter (where dt_remocao_origem is null) as ativos, count(*) filter (where dt_remocao_origem is not null) as removidos from programas_ageis_faf
union all
select 'planos_acao_faf' as tabela, count(*) filter (where dt_remocao_origem is null) as ativos, count(*) filter (where dt_remocao_origem is not null) as removidos from planos_acao_faf
union all
select 'planos_acao_dados_bancarios_faf' as tabela, count(*) filter (where dt_remocao_origem is null) as ativos, count(*) filter (where dt_remocao_origem is not null) as removidos from planos_acao_dados_bancarios_faf
union all
select 'planos_acao_metas_faf' as tabela, count(*) filter (where dt_remocao_origem is null) as ativos, count(*) filter (where dt_remocao_origem is not null) as removidos from planos_acao_metas_faf
union all
select 'planos_acao_metas_acoes_faf' as tabela, count(*) filter (where dt_remocao_origem is null) as ativos, count(*) filter (where dt_remocao_origem is not null) as removidos from planos_acao_metas_acoes_faf
union all
select 'planos_acao_destinacao_recursos_faf' as tabela, count(*) filter (where dt_remocao_origem is null) as ativos, count(*) filter (where dt_remocao_origem is not null) as removidos from planos_acao_destinacao_recursos_faf
union all
select 'planos_acao_historico_faf' as tabela, count(*) filter (where dt_remocao_origem is null) as ativos, count(*) filter (where dt_remocao_origem is not null) as removidos from planos_acao_historico_faf
union all
select 'planos_acao_analises_faf' as tabela, count(*) filter (where dt_remocao_origem is null) as ativos, count(*) filter (where dt_remocao_origem is not null) as removidos from planos_acao_analises_faf
union all
select 'planos_acao_analises_responsaveis_faf' as tabela, count(*) filter (where dt_remocao_origem is null) as ativos, count(*) filter (where dt_remocao_origem is not null) as removidos from planos_acao_analises_responsaveis_faf
union all
select 'termos_adesao_faf' as tabela, count(*) filter (where dt_remocao_origem is null) as ativos, count(*) filter (where dt_remocao_origem is not null) as removidos from termos_adesao_faf
union all
select 'termos_adesao_historico_faf' as tabela, count(*) filter (where dt_remocao_origem is null) as ativos, count(*) filter (where dt_remocao_origem is not null) as removidos from termos_adesao_historico_faf
union all
select 'empenhos_faf' as tabela, count(*) filter (where dt_remocao_origem is null) as ativos, count(*) filter (where dt_remocao_origem is not null) as removidos from empenhos_faf
union all
select 'gestao_financeira_lancamentos_faf' as tabela, count(*) filter (where dt_remocao_origem is null) as ativos, count(*) filter (where dt_remocao_origem is not null) as removidos from gestao_financeira_lancamentos_faf
union all
select 'gestao_financeira_subtransacoes_faf' as tabela, count(*) filter (where dt_remocao_origem is null) as ativos, count(*) filter (where dt_remocao_origem is not null) as removidos from gestao_financeira_subtransacoes_faf
union all
select 'relatorios_gestao_faf' as tabela, count(*) filter (where dt_remocao_origem is null) as ativos, count(*) filter (where dt_remocao_origem is not null) as removidos from relatorios_gestao_faf
union all
select 'relatorios_gestao_acoes_faf' as tabela, count(*) filter (where dt_remocao_origem is null) as ativos, count(*) filter (where dt_remocao_origem is not null) as removidos from relatorios_gestao_acoes_faf
union all
select 'relatorios_gestao_analises_faf' as tabela, count(*) filter (where dt_remocao_origem is null) as ativos, count(*) filter (where dt_remocao_origem is not null) as removidos from relatorios_gestao_analises_faf
union all
select 'relatorios_gestao_analises_responsaveis_faf' as tabela, count(*) filter (where dt_remocao_origem is null) as ativos, count(*) filter (where dt_remocao_origem is not null) as removidos from relatorios_gestao_analises_responsaveis_faf
union all
select 'programas_natureza_despesa_faf' as tabela, count(*) filter (where dt_remocao_origem is null) as ativos, count(*) filter (where dt_remocao_origem is not null) as removidos from programas_natureza_despesa_faf
union all
select 'programas_acao_orcamentaria_faf' as tabela, count(*) filter (where dt_remocao_origem is null) as ativos, count(*) filter (where dt_remocao_origem is not null) as removidos from programas_acao_orcamentaria_faf
union all
select 'gestao_financeira_saldo_conta_faf' as tabela, count(*) filter (where dt_remocao_origem is null) as ativos, count(*) filter (where dt_remocao_origem is not null) as removidos from gestao_financeira_saldo_conta_faf
order by 1;

-- 3. Órfãos por relacionamento (informativo: dados abertos podem ter órfãos; não é erro)
select 'programas_beneficiarios_faf.id_programa -> programas_faf.id_programa' as relacao, count(*) as orfaos from programas_beneficiarios_faf f where f.dt_remocao_origem is null and f.id_programa is not null and not exists (select 1 from programas_faf p where p.id_programa = f.id_programa and p.dt_remocao_origem is null)
union all
select 'programas_ageis_faf.id_programa -> programas_faf.id_programa' as relacao, count(*) as orfaos from programas_ageis_faf f where f.dt_remocao_origem is null and f.id_programa is not null and not exists (select 1 from programas_faf p where p.id_programa = f.id_programa and p.dt_remocao_origem is null)
union all
select 'planos_acao_faf.id_programa -> programas_faf.id_programa' as relacao, count(*) as orfaos from planos_acao_faf f where f.dt_remocao_origem is null and f.id_programa is not null and not exists (select 1 from programas_faf p where p.id_programa = f.id_programa and p.dt_remocao_origem is null)
union all
select 'planos_acao_dados_bancarios_faf.id_plano_acao -> planos_acao_faf.id_plano_acao' as relacao, count(*) as orfaos from planos_acao_dados_bancarios_faf f where f.dt_remocao_origem is null and f.id_plano_acao is not null and not exists (select 1 from planos_acao_faf p where p.id_plano_acao = f.id_plano_acao and p.dt_remocao_origem is null)
union all
select 'planos_acao_dados_bancarios_faf.id_agencia_conta -> gestao_financeira_saldo_conta_faf.id_agencia_conta' as relacao, count(*) as orfaos from planos_acao_dados_bancarios_faf f where f.dt_remocao_origem is null and f.id_agencia_conta is not null and not exists (select 1 from gestao_financeira_saldo_conta_faf p where p.id_agencia_conta = f.id_agencia_conta and p.dt_remocao_origem is null)
union all
select 'planos_acao_metas_faf.id_plano_acao -> planos_acao_faf.id_plano_acao' as relacao, count(*) as orfaos from planos_acao_metas_faf f where f.dt_remocao_origem is null and f.id_plano_acao is not null and not exists (select 1 from planos_acao_faf p where p.id_plano_acao = f.id_plano_acao and p.dt_remocao_origem is null)
union all
select 'planos_acao_metas_acoes_faf.id_meta_plano_acao -> planos_acao_metas_faf.id_meta_plano_acao' as relacao, count(*) as orfaos from planos_acao_metas_acoes_faf f where f.dt_remocao_origem is null and f.id_meta_plano_acao is not null and not exists (select 1 from planos_acao_metas_faf p where p.id_meta_plano_acao = f.id_meta_plano_acao and p.dt_remocao_origem is null)
union all
select 'planos_acao_destinacao_recursos_faf.id_plano_acao -> planos_acao_faf.id_plano_acao' as relacao, count(*) as orfaos from planos_acao_destinacao_recursos_faf f where f.dt_remocao_origem is null and f.id_plano_acao is not null and not exists (select 1 from planos_acao_faf p where p.id_plano_acao = f.id_plano_acao and p.dt_remocao_origem is null)
union all
select 'planos_acao_historico_faf.id_plano_acao -> planos_acao_faf.id_plano_acao' as relacao, count(*) as orfaos from planos_acao_historico_faf f where f.dt_remocao_origem is null and f.id_plano_acao is not null and not exists (select 1 from planos_acao_faf p where p.id_plano_acao = f.id_plano_acao and p.dt_remocao_origem is null)
union all
select 'planos_acao_analises_faf.id_plano_acao -> planos_acao_faf.id_plano_acao' as relacao, count(*) as orfaos from planos_acao_analises_faf f where f.dt_remocao_origem is null and f.id_plano_acao is not null and not exists (select 1 from planos_acao_faf p where p.id_plano_acao = f.id_plano_acao and p.dt_remocao_origem is null)
union all
select 'planos_acao_analises_faf.id_historico_plano_acao -> planos_acao_historico_faf.id_historico_plano_acao' as relacao, count(*) as orfaos from planos_acao_analises_faf f where f.dt_remocao_origem is null and f.id_historico_plano_acao is not null and not exists (select 1 from planos_acao_historico_faf p where p.id_historico_plano_acao = f.id_historico_plano_acao and p.dt_remocao_origem is null)
union all
select 'planos_acao_analises_responsaveis_faf.id_analise_plano_acao -> planos_acao_analises_faf.id_analise_plano_acao' as relacao, count(*) as orfaos from planos_acao_analises_responsaveis_faf f where f.dt_remocao_origem is null and f.id_analise_plano_acao is not null and not exists (select 1 from planos_acao_analises_faf p where p.id_analise_plano_acao = f.id_analise_plano_acao and p.dt_remocao_origem is null)
union all
select 'termos_adesao_faf.id_plano_acao -> planos_acao_faf.id_plano_acao' as relacao, count(*) as orfaos from termos_adesao_faf f where f.dt_remocao_origem is null and f.id_plano_acao is not null and not exists (select 1 from planos_acao_faf p where p.id_plano_acao = f.id_plano_acao and p.dt_remocao_origem is null)
union all
select 'termos_adesao_historico_faf.id_termo_adesao -> termos_adesao_faf.id_termo_adesao' as relacao, count(*) as orfaos from termos_adesao_historico_faf f where f.dt_remocao_origem is null and f.id_termo_adesao is not null and not exists (select 1 from termos_adesao_faf p where p.id_termo_adesao = f.id_termo_adesao and p.dt_remocao_origem is null)
union all
select 'empenhos_faf.id_plano_acao -> planos_acao_faf.id_plano_acao' as relacao, count(*) as orfaos from empenhos_faf f where f.dt_remocao_origem is null and f.id_plano_acao is not null and not exists (select 1 from planos_acao_faf p where p.id_plano_acao = f.id_plano_acao and p.dt_remocao_origem is null)
union all
select 'gestao_financeira_lancamentos_faf.id_agencia_conta -> gestao_financeira_saldo_conta_faf.id_agencia_conta' as relacao, count(*) as orfaos from gestao_financeira_lancamentos_faf f where f.dt_remocao_origem is null and f.id_agencia_conta is not null and not exists (select 1 from gestao_financeira_saldo_conta_faf p where p.id_agencia_conta = f.id_agencia_conta and p.dt_remocao_origem is null)
union all
select 'gestao_financeira_subtransacoes_faf.id_lancamento_gestao_financeira -> gestao_financeira_lancamentos_faf.id_lancamento_gestao_financeira' as relacao, count(*) as orfaos from gestao_financeira_subtransacoes_faf f where f.dt_remocao_origem is null and f.id_lancamento_gestao_financeira is not null and not exists (select 1 from gestao_financeira_lancamentos_faf p where p.id_lancamento_gestao_financeira = f.id_lancamento_gestao_financeira and p.dt_remocao_origem is null)
union all
select 'relatorios_gestao_faf.id_plano_acao -> planos_acao_faf.id_plano_acao' as relacao, count(*) as orfaos from relatorios_gestao_faf f where f.dt_remocao_origem is null and f.id_plano_acao is not null and not exists (select 1 from planos_acao_faf p where p.id_plano_acao = f.id_plano_acao and p.dt_remocao_origem is null)
union all
select 'relatorios_gestao_acoes_faf.id_relatorio_gestao -> relatorios_gestao_faf.id_relatorio_gestao' as relacao, count(*) as orfaos from relatorios_gestao_acoes_faf f where f.dt_remocao_origem is null and f.id_relatorio_gestao is not null and not exists (select 1 from relatorios_gestao_faf p where p.id_relatorio_gestao = f.id_relatorio_gestao and p.dt_remocao_origem is null)
union all
select 'relatorios_gestao_acoes_faf.id_acao_meta_plano_acao -> planos_acao_metas_acoes_faf.id_acao_meta_plano_acao' as relacao, count(*) as orfaos from relatorios_gestao_acoes_faf f where f.dt_remocao_origem is null and f.id_acao_meta_plano_acao is not null and not exists (select 1 from planos_acao_metas_acoes_faf p where p.id_acao_meta_plano_acao = f.id_acao_meta_plano_acao and p.dt_remocao_origem is null)
union all
select 'relatorios_gestao_analises_faf.id_relatorio_gestao -> relatorios_gestao_faf.id_relatorio_gestao' as relacao, count(*) as orfaos from relatorios_gestao_analises_faf f where f.dt_remocao_origem is null and f.id_relatorio_gestao is not null and not exists (select 1 from relatorios_gestao_faf p where p.id_relatorio_gestao = f.id_relatorio_gestao and p.dt_remocao_origem is null)
union all
select 'relatorios_gestao_analises_responsaveis_faf.id_relatorio_gestao_analise -> relatorios_gestao_analises_faf.id_relatorio_gestao_analise' as relacao, count(*) as orfaos from relatorios_gestao_analises_responsaveis_faf f where f.dt_remocao_origem is null and f.id_relatorio_gestao_analise is not null and not exists (select 1 from relatorios_gestao_analises_faf p where p.id_relatorio_gestao_analise = f.id_relatorio_gestao_analise and p.dt_remocao_origem is null)
union all
select 'programas_natureza_despesa_faf.id_programa -> programas_faf.id_programa' as relacao, count(*) as orfaos from programas_natureza_despesa_faf f where f.dt_remocao_origem is null and f.id_programa is not null and not exists (select 1 from programas_faf p where p.id_programa = f.id_programa and p.dt_remocao_origem is null)
union all
select 'programas_acao_orcamentaria_faf.id_programa -> programas_faf.id_programa' as relacao, count(*) as orfaos from programas_acao_orcamentaria_faf f where f.dt_remocao_origem is null and f.id_programa is not null and not exists (select 1 from programas_faf p where p.id_programa = f.id_programa and p.dt_remocao_origem is null)
order by 2 desc;

-- 4. Nulos nas colunas de relacionamento (deveriam estar sempre preenchidas)
select 'programas_beneficiarios_faf.id_programa' as coluna, count(*) as nulos from programas_beneficiarios_faf where dt_remocao_origem is null and id_programa is null
union all
select 'programas_ageis_faf.id_programa' as coluna, count(*) as nulos from programas_ageis_faf where dt_remocao_origem is null and id_programa is null
union all
select 'planos_acao_faf.id_programa' as coluna, count(*) as nulos from planos_acao_faf where dt_remocao_origem is null and id_programa is null
union all
select 'planos_acao_dados_bancarios_faf.id_plano_acao' as coluna, count(*) as nulos from planos_acao_dados_bancarios_faf where dt_remocao_origem is null and id_plano_acao is null
union all
select 'planos_acao_dados_bancarios_faf.id_agencia_conta' as coluna, count(*) as nulos from planos_acao_dados_bancarios_faf where dt_remocao_origem is null and id_agencia_conta is null
union all
select 'planos_acao_metas_faf.id_plano_acao' as coluna, count(*) as nulos from planos_acao_metas_faf where dt_remocao_origem is null and id_plano_acao is null
union all
select 'planos_acao_metas_acoes_faf.id_meta_plano_acao' as coluna, count(*) as nulos from planos_acao_metas_acoes_faf where dt_remocao_origem is null and id_meta_plano_acao is null
union all
select 'planos_acao_destinacao_recursos_faf.id_plano_acao' as coluna, count(*) as nulos from planos_acao_destinacao_recursos_faf where dt_remocao_origem is null and id_plano_acao is null
union all
select 'planos_acao_historico_faf.id_plano_acao' as coluna, count(*) as nulos from planos_acao_historico_faf where dt_remocao_origem is null and id_plano_acao is null
union all
select 'planos_acao_analises_faf.id_plano_acao' as coluna, count(*) as nulos from planos_acao_analises_faf where dt_remocao_origem is null and id_plano_acao is null
union all
select 'planos_acao_analises_faf.id_historico_plano_acao' as coluna, count(*) as nulos from planos_acao_analises_faf where dt_remocao_origem is null and id_historico_plano_acao is null
union all
select 'planos_acao_analises_responsaveis_faf.id_analise_plano_acao' as coluna, count(*) as nulos from planos_acao_analises_responsaveis_faf where dt_remocao_origem is null and id_analise_plano_acao is null
union all
select 'termos_adesao_faf.id_plano_acao' as coluna, count(*) as nulos from termos_adesao_faf where dt_remocao_origem is null and id_plano_acao is null
union all
select 'termos_adesao_historico_faf.id_termo_adesao' as coluna, count(*) as nulos from termos_adesao_historico_faf where dt_remocao_origem is null and id_termo_adesao is null
union all
select 'empenhos_faf.id_plano_acao' as coluna, count(*) as nulos from empenhos_faf where dt_remocao_origem is null and id_plano_acao is null
union all
select 'gestao_financeira_lancamentos_faf.id_agencia_conta' as coluna, count(*) as nulos from gestao_financeira_lancamentos_faf where dt_remocao_origem is null and id_agencia_conta is null
union all
select 'gestao_financeira_subtransacoes_faf.id_lancamento_gestao_financeira' as coluna, count(*) as nulos from gestao_financeira_subtransacoes_faf where dt_remocao_origem is null and id_lancamento_gestao_financeira is null
union all
select 'relatorios_gestao_faf.id_plano_acao' as coluna, count(*) as nulos from relatorios_gestao_faf where dt_remocao_origem is null and id_plano_acao is null
union all
select 'relatorios_gestao_acoes_faf.id_relatorio_gestao' as coluna, count(*) as nulos from relatorios_gestao_acoes_faf where dt_remocao_origem is null and id_relatorio_gestao is null
union all
select 'relatorios_gestao_acoes_faf.id_acao_meta_plano_acao' as coluna, count(*) as nulos from relatorios_gestao_acoes_faf where dt_remocao_origem is null and id_acao_meta_plano_acao is null
union all
select 'relatorios_gestao_analises_faf.id_relatorio_gestao' as coluna, count(*) as nulos from relatorios_gestao_analises_faf where dt_remocao_origem is null and id_relatorio_gestao is null
union all
select 'relatorios_gestao_analises_responsaveis_faf.id_relatorio_gestao_analise' as coluna, count(*) as nulos from relatorios_gestao_analises_responsaveis_faf where dt_remocao_origem is null and id_relatorio_gestao_analise is null
union all
select 'programas_natureza_despesa_faf.id_programa' as coluna, count(*) as nulos from programas_natureza_despesa_faf where dt_remocao_origem is null and id_programa is null
union all
select 'programas_acao_orcamentaria_faf.id_programa' as coluna, count(*) as nulos from programas_acao_orcamentaria_faf where dt_remocao_origem is null and id_programa is null
order by 2 desc;

-- 5. Somatórios de controle por ano
select extract(year from data_inicio_vigencia_plano_acao)::int as ano, count(*) as planos,
       sum(valor_total_plano_acao) as valor_total_plano, sum(valor_total_repasse_plano_acao) as valor_repasse
from planos_acao_faf where dt_remocao_origem is null group by 1 order by 1;

select extract(year from data_lancamento_gestao_financeira)::int as ano, tipo_operacao_gestao_financeira as tipo,
       count(*) as lancamentos, sum(valor_lancamento_gestao_financeira) as valor
from gestao_financeira_lancamentos_faf where dt_remocao_origem is null group by 1, 2 order by 1, 2;

select ano_empenho, count(*) as empenhos, sum(valor_empenho) as valor
from empenhos_faf where dt_remocao_origem is null group by 1 order by 1;

-- 6. Registros alterados depois de inseridos e registros removidos da origem, por tabela
select 'programas_faf' as tabela, count(*) filter (where dt_atualizacao > dt_carga and dt_remocao_origem is null) as alterados, count(*) filter (where dt_remocao_origem is not null) as removidos, max(dt_atualizacao) as ultima_alteracao from programas_faf
union all
select 'programas_beneficiarios_faf' as tabela, count(*) filter (where dt_atualizacao > dt_carga and dt_remocao_origem is null) as alterados, count(*) filter (where dt_remocao_origem is not null) as removidos, max(dt_atualizacao) as ultima_alteracao from programas_beneficiarios_faf
union all
select 'programas_ageis_faf' as tabela, count(*) filter (where dt_atualizacao > dt_carga and dt_remocao_origem is null) as alterados, count(*) filter (where dt_remocao_origem is not null) as removidos, max(dt_atualizacao) as ultima_alteracao from programas_ageis_faf
union all
select 'planos_acao_faf' as tabela, count(*) filter (where dt_atualizacao > dt_carga and dt_remocao_origem is null) as alterados, count(*) filter (where dt_remocao_origem is not null) as removidos, max(dt_atualizacao) as ultima_alteracao from planos_acao_faf
union all
select 'planos_acao_dados_bancarios_faf' as tabela, count(*) filter (where dt_atualizacao > dt_carga and dt_remocao_origem is null) as alterados, count(*) filter (where dt_remocao_origem is not null) as removidos, max(dt_atualizacao) as ultima_alteracao from planos_acao_dados_bancarios_faf
union all
select 'planos_acao_metas_faf' as tabela, count(*) filter (where dt_atualizacao > dt_carga and dt_remocao_origem is null) as alterados, count(*) filter (where dt_remocao_origem is not null) as removidos, max(dt_atualizacao) as ultima_alteracao from planos_acao_metas_faf
union all
select 'planos_acao_metas_acoes_faf' as tabela, count(*) filter (where dt_atualizacao > dt_carga and dt_remocao_origem is null) as alterados, count(*) filter (where dt_remocao_origem is not null) as removidos, max(dt_atualizacao) as ultima_alteracao from planos_acao_metas_acoes_faf
union all
select 'planos_acao_destinacao_recursos_faf' as tabela, count(*) filter (where dt_atualizacao > dt_carga and dt_remocao_origem is null) as alterados, count(*) filter (where dt_remocao_origem is not null) as removidos, max(dt_atualizacao) as ultima_alteracao from planos_acao_destinacao_recursos_faf
union all
select 'planos_acao_historico_faf' as tabela, count(*) filter (where dt_atualizacao > dt_carga and dt_remocao_origem is null) as alterados, count(*) filter (where dt_remocao_origem is not null) as removidos, max(dt_atualizacao) as ultima_alteracao from planos_acao_historico_faf
union all
select 'planos_acao_analises_faf' as tabela, count(*) filter (where dt_atualizacao > dt_carga and dt_remocao_origem is null) as alterados, count(*) filter (where dt_remocao_origem is not null) as removidos, max(dt_atualizacao) as ultima_alteracao from planos_acao_analises_faf
union all
select 'planos_acao_analises_responsaveis_faf' as tabela, count(*) filter (where dt_atualizacao > dt_carga and dt_remocao_origem is null) as alterados, count(*) filter (where dt_remocao_origem is not null) as removidos, max(dt_atualizacao) as ultima_alteracao from planos_acao_analises_responsaveis_faf
union all
select 'termos_adesao_faf' as tabela, count(*) filter (where dt_atualizacao > dt_carga and dt_remocao_origem is null) as alterados, count(*) filter (where dt_remocao_origem is not null) as removidos, max(dt_atualizacao) as ultima_alteracao from termos_adesao_faf
union all
select 'termos_adesao_historico_faf' as tabela, count(*) filter (where dt_atualizacao > dt_carga and dt_remocao_origem is null) as alterados, count(*) filter (where dt_remocao_origem is not null) as removidos, max(dt_atualizacao) as ultima_alteracao from termos_adesao_historico_faf
union all
select 'empenhos_faf' as tabela, count(*) filter (where dt_atualizacao > dt_carga and dt_remocao_origem is null) as alterados, count(*) filter (where dt_remocao_origem is not null) as removidos, max(dt_atualizacao) as ultima_alteracao from empenhos_faf
union all
select 'gestao_financeira_lancamentos_faf' as tabela, count(*) filter (where dt_atualizacao > dt_carga and dt_remocao_origem is null) as alterados, count(*) filter (where dt_remocao_origem is not null) as removidos, max(dt_atualizacao) as ultima_alteracao from gestao_financeira_lancamentos_faf
union all
select 'gestao_financeira_subtransacoes_faf' as tabela, count(*) filter (where dt_atualizacao > dt_carga and dt_remocao_origem is null) as alterados, count(*) filter (where dt_remocao_origem is not null) as removidos, max(dt_atualizacao) as ultima_alteracao from gestao_financeira_subtransacoes_faf
union all
select 'relatorios_gestao_faf' as tabela, count(*) filter (where dt_atualizacao > dt_carga and dt_remocao_origem is null) as alterados, count(*) filter (where dt_remocao_origem is not null) as removidos, max(dt_atualizacao) as ultima_alteracao from relatorios_gestao_faf
union all
select 'relatorios_gestao_acoes_faf' as tabela, count(*) filter (where dt_atualizacao > dt_carga and dt_remocao_origem is null) as alterados, count(*) filter (where dt_remocao_origem is not null) as removidos, max(dt_atualizacao) as ultima_alteracao from relatorios_gestao_acoes_faf
union all
select 'relatorios_gestao_analises_faf' as tabela, count(*) filter (where dt_atualizacao > dt_carga and dt_remocao_origem is null) as alterados, count(*) filter (where dt_remocao_origem is not null) as removidos, max(dt_atualizacao) as ultima_alteracao from relatorios_gestao_analises_faf
union all
select 'relatorios_gestao_analises_responsaveis_faf' as tabela, count(*) filter (where dt_atualizacao > dt_carga and dt_remocao_origem is null) as alterados, count(*) filter (where dt_remocao_origem is not null) as removidos, max(dt_atualizacao) as ultima_alteracao from relatorios_gestao_analises_responsaveis_faf
union all
select 'programas_natureza_despesa_faf' as tabela, count(*) filter (where dt_atualizacao > dt_carga and dt_remocao_origem is null) as alterados, count(*) filter (where dt_remocao_origem is not null) as removidos, max(dt_atualizacao) as ultima_alteracao from programas_natureza_despesa_faf
union all
select 'programas_acao_orcamentaria_faf' as tabela, count(*) filter (where dt_atualizacao > dt_carga and dt_remocao_origem is null) as alterados, count(*) filter (where dt_remocao_origem is not null) as removidos, max(dt_atualizacao) as ultima_alteracao from programas_acao_orcamentaria_faf
union all
select 'gestao_financeira_saldo_conta_faf' as tabela, count(*) filter (where dt_atualizacao > dt_carga and dt_remocao_origem is null) as alterados, count(*) filter (where dt_remocao_origem is not null) as removidos, max(dt_atualizacao) as ultima_alteracao from gestao_financeira_saldo_conta_faf
order by 1;

-- 7. Últimas 10 execuções
select id_execucao, dt_inicio, round(extract(epoch from dt_fim - dt_inicio)) as segundos, status, forcada,
       endpoints_solicitados, dt_atualizacao_origem, left(mensagem, 120) as mensagem
from controle_execucao order by id_execucao desc limit 10;

-- Gerado por scripts/gerar_ddl.py — migra o banco existente para o modelo incremental. Idempotente.
-- Em banco novo, 003 já cria tudo isto e este script não altera nada.
set search_path to base_transferencias_fundo_fundo;

alter table controle_execucao_endpoint
    add column if not exists qtd_inseridos bigint,
    add column if not exists qtd_atualizados bigint,
    add column if not exists qtd_removidos bigint;

alter table programas_faf
    add column if not exists dt_atualizacao timestamptz,
    add column if not exists hash_registro char(32),
    add column if not exists dt_remocao_origem timestamptz;
update programas_faf set hash_registro = md5(row(id_programa, ano_programa, modalidade_programa, codigo_programa, nome_programa, id_unidade_gestora_programa, nome_institucional_programa, permite_transferencia_sem_fundo_programa, objetivo_programa, descricao_programa, situacao_programa, valor_global_programa, quantidade_parcelas_programa, id_orgao_superior_programa, sigla_orgao_superior_programa, cnpj_orgao_superior_programa, nome_orgao_superior_programa, id_fundo_programa, cnpj_fundo_programa, nome_fundo_programa, uf_fundo_programa, municipio_fundo_programa, codigo_ibge_fundo_programa, data_inicio_recebimento_planos_acao_beneficiarios_especificos, data_fim_recebimento_planos_acao_beneficiarios_especificos, data_inicio_recebimento_planos_acao_beneficiarios_emendas, data_fim_recebimento_planos_acao_beneficiarios_emendas, data_inicio_recebimento_planos_acao_beneficiarios_voluntarios, data_fim_recebimento_planos_acao_beneficiarios_voluntarios)::text), dt_atualizacao = coalesce(dt_atualizacao, dt_carga)
    where hash_registro is null;
alter table programas_faf alter column dt_atualizacao set default now(), alter column dt_atualizacao set not null,
    alter column hash_registro set not null;
create index if not exists ix_programas_faf_dt_atualizacao on programas_faf (dt_atualizacao);
comment on column programas_faf.dt_carga is 'Quando o registro apareceu pela primeira vez na base (não muda mais)';
comment on column programas_faf.id_execucao is 'Última execução (controle_execucao) que inseriu, alterou ou removeu o registro';
comment on column programas_faf.dt_atualizacao is 'Última vez em que o conteúdo do registro mudou';
comment on column programas_faf.hash_registro is 'md5 das colunas de dados (row(...)::text); detecta alteração no merge incremental';
comment on column programas_faf.dt_remocao_origem is 'Preenchida quando o registro deixou de vir da API; nula = ativo';

alter table programas_beneficiarios_faf
    add column if not exists dt_atualizacao timestamptz,
    add column if not exists hash_registro char(32),
    add column if not exists dt_remocao_origem timestamptz;
update programas_beneficiarios_faf set hash_registro = md5(row(id_beneficiario_programa, cnpj_beneficiario_programa, nome_beneficiario_programa, valor_beneficiario_programa, numero_emenda_beneficiario_programa, nome_parlamentar_beneficiario_programa, tipo_beneficiario_programa, nome_ente_beneficiario_programa, uf_ente_beneficiario_programa, nome_municipio_ente_beneficiario_programa, codigo_ibge_municipio_ente_beneficiario_programa, id_ente_beneficiario_programa, id_programa)::text), dt_atualizacao = coalesce(dt_atualizacao, dt_carga)
    where hash_registro is null;
alter table programas_beneficiarios_faf alter column dt_atualizacao set default now(), alter column dt_atualizacao set not null,
    alter column hash_registro set not null;
create index if not exists ix_programas_beneficiarios_faf_dt_atualizacao on programas_beneficiarios_faf (dt_atualizacao);
comment on column programas_beneficiarios_faf.dt_carga is 'Quando o registro apareceu pela primeira vez na base (não muda mais)';
comment on column programas_beneficiarios_faf.id_execucao is 'Última execução (controle_execucao) que inseriu, alterou ou removeu o registro';
comment on column programas_beneficiarios_faf.dt_atualizacao is 'Última vez em que o conteúdo do registro mudou';
comment on column programas_beneficiarios_faf.hash_registro is 'md5 das colunas de dados (row(...)::text); detecta alteração no merge incremental';
comment on column programas_beneficiarios_faf.dt_remocao_origem is 'Preenchida quando o registro deixou de vir da API; nula = ativo';

alter table programas_ageis_faf
    add column if not exists dt_atualizacao timestamptz,
    add column if not exists hash_registro char(32),
    add column if not exists dt_remocao_origem timestamptz;
update programas_ageis_faf set hash_registro = md5(row(id_programa_agil, id_programa_agil_bb, nome_programa_agil, codigo_programa_agil, id_orgao_programa_agil, codigo_siorg_orgao_programa_agil, sigla_orgao_programa_agil, cnpj_orgao_programa_agil, nome_orgao_programa_agil, id_programa)::text), dt_atualizacao = coalesce(dt_atualizacao, dt_carga)
    where hash_registro is null;
alter table programas_ageis_faf alter column dt_atualizacao set default now(), alter column dt_atualizacao set not null,
    alter column hash_registro set not null;
create index if not exists ix_programas_ageis_faf_dt_atualizacao on programas_ageis_faf (dt_atualizacao);
comment on column programas_ageis_faf.dt_carga is 'Quando o registro apareceu pela primeira vez na base (não muda mais)';
comment on column programas_ageis_faf.id_execucao is 'Última execução (controle_execucao) que inseriu, alterou ou removeu o registro';
comment on column programas_ageis_faf.dt_atualizacao is 'Última vez em que o conteúdo do registro mudou';
comment on column programas_ageis_faf.hash_registro is 'md5 das colunas de dados (row(...)::text); detecta alteração no merge incremental';
comment on column programas_ageis_faf.dt_remocao_origem is 'Preenchida quando o registro deixou de vir da API; nula = ativo';

alter table planos_acao_faf
    add column if not exists dt_atualizacao timestamptz,
    add column if not exists hash_registro char(32),
    add column if not exists dt_remocao_origem timestamptz;
update planos_acao_faf set hash_registro = md5(row(id_plano_acao, codigo_plano_acao, data_inicio_vigencia_plano_acao, data_fim_vigencia_plano_acao, diagnostico_plano_acao, objetivos_plano_acao, situacao_plano_acao, valor_repasse_emenda_plano_acao, valor_repasse_especifico_plano_acao, valor_repasse_voluntario_plano_acao, valor_total_repasse_plano_acao, valor_recursos_proprios_plano_acao, valor_outros_plano_acao, valor_rendimentos_aplicacao_plano_acao, valor_total_plano_acao, valor_total_investimento_plano_acao, valor_total_custeio_plano_acao, valor_saldo_disponivel_plano_acao, id_orgao_repassador_plano_acao, sigla_orgao_repassador_plano_acao, cnpj_orgao_repassador_plano_acao, nome_orgao_repassador_plano_acao, id_ente_repassador_plano_acao, cnpj_ente_repassador_plano_acao, nome_ente_repassador_plano_acao, uf_ente_repassador_plano_acao, nome_municipio_ente_repassador_plano_acao, codigo_ibge_municipio_ente_repassador_plano_acao, id_ente_recebedor_plano_acao, cnpj_ente_recebedor_plano_acao, nome_ente_recebedor_plano_acao, uf_ente_recebedor_plano_acao, nome_municipio_ente_recebedor_plano_acao, codigo_ibge_municipio_ente_recebedor_plano_acao, tipo_unidade_recebedora_plano_acao, descricao_tipo_unidade_ente_plano_acao, id_fundo_repassador_plano_acao, cnpj_fundo_repassador_plano_acao, nome_fundo_repassador_plano_acao, uf_fundo_repassador_plano_acao, municipio_fundo_repassador_plano_acao, codigo_ibge_fundo_repassador_plano_acao, id_fundo_vinculado_plano_acao, cnpj_fundo_vinculado_plano_acao, nome_fundo_vinculado_plano_acao, uf_fundo_vinculado_plano_acao, municipio_fundo_vinculado_plano_acao, codigo_ibge_fundo_vinculado_plano_acao, tipo_unidade_recebedora_vinculada_plano_acao, descricao_tipo_unidade_recebedora_vinculada_plano_acao, id_programa)::text), dt_atualizacao = coalesce(dt_atualizacao, dt_carga)
    where hash_registro is null;
alter table planos_acao_faf alter column dt_atualizacao set default now(), alter column dt_atualizacao set not null,
    alter column hash_registro set not null;
create index if not exists ix_planos_acao_faf_dt_atualizacao on planos_acao_faf (dt_atualizacao);
comment on column planos_acao_faf.dt_carga is 'Quando o registro apareceu pela primeira vez na base (não muda mais)';
comment on column planos_acao_faf.id_execucao is 'Última execução (controle_execucao) que inseriu, alterou ou removeu o registro';
comment on column planos_acao_faf.dt_atualizacao is 'Última vez em que o conteúdo do registro mudou';
comment on column planos_acao_faf.hash_registro is 'md5 das colunas de dados (row(...)::text); detecta alteração no merge incremental';
comment on column planos_acao_faf.dt_remocao_origem is 'Preenchida quando o registro deixou de vir da API; nula = ativo';

alter table planos_acao_dados_bancarios_faf
    add column if not exists dt_atualizacao timestamptz,
    add column if not exists hash_registro char(32),
    add column if not exists dt_remocao_origem timestamptz;
update planos_acao_dados_bancarios_faf set hash_registro = md5(row(id_plano_acao_dado_bancario, id_agencia_conta, codigo_banco_plano_acao_dado_bancario, nome_banco_plano_acao_dado_bancario, numero_agencia_plano_acao_dado_bancario, dv_agencia_plano_acao_dado_bancario, numero_conta_plano_acao_dado_bancario, dv_conta_plano_acao_dado_bancario, situacao_conta_plano_acao_dado_bancario, data_abertura_conta_plano_acao_dado_bancario, nome_programa_agil_conta_plano_acao_dado_bancario, saldo_final_conta_plano_acao_dado_bancario, id_plano_acao)::text), dt_atualizacao = coalesce(dt_atualizacao, dt_carga)
    where hash_registro is null;
alter table planos_acao_dados_bancarios_faf alter column dt_atualizacao set default now(), alter column dt_atualizacao set not null,
    alter column hash_registro set not null;
create index if not exists ix_planos_acao_dados_bancarios_faf_dt_atualizacao on planos_acao_dados_bancarios_faf (dt_atualizacao);
comment on column planos_acao_dados_bancarios_faf.dt_carga is 'Quando o registro apareceu pela primeira vez na base (não muda mais)';
comment on column planos_acao_dados_bancarios_faf.id_execucao is 'Última execução (controle_execucao) que inseriu, alterou ou removeu o registro';
comment on column planos_acao_dados_bancarios_faf.dt_atualizacao is 'Última vez em que o conteúdo do registro mudou';
comment on column planos_acao_dados_bancarios_faf.hash_registro is 'md5 das colunas de dados (row(...)::text); detecta alteração no merge incremental';
comment on column planos_acao_dados_bancarios_faf.dt_remocao_origem is 'Preenchida quando o registro deixou de vir da API; nula = ativo';

alter table planos_acao_metas_faf
    add column if not exists dt_atualizacao timestamptz,
    add column if not exists hash_registro char(32),
    add column if not exists dt_remocao_origem timestamptz;
update planos_acao_metas_faf set hash_registro = md5(row(id_meta_plano_acao, numero_meta_plano_acao, nome_meta_plano_acao, descricao_meta_plano_acao, valor_meta_plano_acao, versao_meta_plano_acao, sequencial_meta_plano_acao, id_plano_acao)::text), dt_atualizacao = coalesce(dt_atualizacao, dt_carga)
    where hash_registro is null;
alter table planos_acao_metas_faf alter column dt_atualizacao set default now(), alter column dt_atualizacao set not null,
    alter column hash_registro set not null;
create index if not exists ix_planos_acao_metas_faf_dt_atualizacao on planos_acao_metas_faf (dt_atualizacao);
comment on column planos_acao_metas_faf.dt_carga is 'Quando o registro apareceu pela primeira vez na base (não muda mais)';
comment on column planos_acao_metas_faf.id_execucao is 'Última execução (controle_execucao) que inseriu, alterou ou removeu o registro';
comment on column planos_acao_metas_faf.dt_atualizacao is 'Última vez em que o conteúdo do registro mudou';
comment on column planos_acao_metas_faf.hash_registro is 'md5 das colunas de dados (row(...)::text); detecta alteração no merge incremental';
comment on column planos_acao_metas_faf.dt_remocao_origem is 'Preenchida quando o registro deixou de vir da API; nula = ativo';

alter table planos_acao_metas_acoes_faf
    add column if not exists dt_atualizacao timestamptz,
    add column if not exists hash_registro char(32),
    add column if not exists dt_remocao_origem timestamptz;
update planos_acao_metas_acoes_faf set hash_registro = md5(row(id_acao_meta_plano_acao, numero_acao_meta_plano_acao, nome_acao_meta_plano_acao, descricao_acao_meta_plano_acao, valor_acao_meta_plano_acao, versao_acao_meta_plano_acao, sequencial_acao_meta_plano_acao, id_meta_plano_acao)::text), dt_atualizacao = coalesce(dt_atualizacao, dt_carga)
    where hash_registro is null;
alter table planos_acao_metas_acoes_faf alter column dt_atualizacao set default now(), alter column dt_atualizacao set not null,
    alter column hash_registro set not null;
create index if not exists ix_planos_acao_metas_acoes_faf_dt_atualizacao on planos_acao_metas_acoes_faf (dt_atualizacao);
comment on column planos_acao_metas_acoes_faf.dt_carga is 'Quando o registro apareceu pela primeira vez na base (não muda mais)';
comment on column planos_acao_metas_acoes_faf.id_execucao is 'Última execução (controle_execucao) que inseriu, alterou ou removeu o registro';
comment on column planos_acao_metas_acoes_faf.dt_atualizacao is 'Última vez em que o conteúdo do registro mudou';
comment on column planos_acao_metas_acoes_faf.hash_registro is 'md5 das colunas de dados (row(...)::text); detecta alteração no merge incremental';
comment on column planos_acao_metas_acoes_faf.dt_remocao_origem is 'Preenchida quando o registro deixou de vir da API; nula = ativo';

alter table planos_acao_destinacao_recursos_faf
    add column if not exists dt_atualizacao timestamptz,
    add column if not exists hash_registro char(32),
    add column if not exists dt_remocao_origem timestamptz;
update planos_acao_destinacao_recursos_faf set hash_registro = md5(row(id_destinacao_recursos_plano_acao, codigo_natureza_despesa_destinacao_recursos_plano_acao, descricao_natureza_despesa_destinacao_recursos_plano_acao, tipo_despesa_destinacao_recursos_plano_acao, valor_destinacao_recursos_plano_acao, id_plano_acao)::text), dt_atualizacao = coalesce(dt_atualizacao, dt_carga)
    where hash_registro is null;
alter table planos_acao_destinacao_recursos_faf alter column dt_atualizacao set default now(), alter column dt_atualizacao set not null,
    alter column hash_registro set not null;
create index if not exists ix_planos_acao_destinacao_recursos_faf_dt_atualizacao on planos_acao_destinacao_recursos_faf (dt_atualizacao);
comment on column planos_acao_destinacao_recursos_faf.dt_carga is 'Quando o registro apareceu pela primeira vez na base (não muda mais)';
comment on column planos_acao_destinacao_recursos_faf.id_execucao is 'Última execução (controle_execucao) que inseriu, alterou ou removeu o registro';
comment on column planos_acao_destinacao_recursos_faf.dt_atualizacao is 'Última vez em que o conteúdo do registro mudou';
comment on column planos_acao_destinacao_recursos_faf.hash_registro is 'md5 das colunas de dados (row(...)::text); detecta alteração no merge incremental';
comment on column planos_acao_destinacao_recursos_faf.dt_remocao_origem is 'Preenchida quando o registro deixou de vir da API; nula = ativo';

alter table planos_acao_historico_faf
    add column if not exists dt_atualizacao timestamptz,
    add column if not exists hash_registro char(32),
    add column if not exists dt_remocao_origem timestamptz;
update planos_acao_historico_faf set hash_registro = md5(row(id_historico_plano_acao, situacao_historico_plano_acao, data_historico_plano_acao, versao_historico_plano_acao, id_plano_acao)::text), dt_atualizacao = coalesce(dt_atualizacao, dt_carga)
    where hash_registro is null;
alter table planos_acao_historico_faf alter column dt_atualizacao set default now(), alter column dt_atualizacao set not null,
    alter column hash_registro set not null;
create index if not exists ix_planos_acao_historico_faf_dt_atualizacao on planos_acao_historico_faf (dt_atualizacao);
comment on column planos_acao_historico_faf.dt_carga is 'Quando o registro apareceu pela primeira vez na base (não muda mais)';
comment on column planos_acao_historico_faf.id_execucao is 'Última execução (controle_execucao) que inseriu, alterou ou removeu o registro';
comment on column planos_acao_historico_faf.dt_atualizacao is 'Última vez em que o conteúdo do registro mudou';
comment on column planos_acao_historico_faf.hash_registro is 'md5 das colunas de dados (row(...)::text); detecta alteração no merge incremental';
comment on column planos_acao_historico_faf.dt_remocao_origem is 'Preenchida quando o registro deixou de vir da API; nula = ativo';

alter table planos_acao_analises_faf
    add column if not exists dt_atualizacao timestamptz,
    add column if not exists hash_registro char(32),
    add column if not exists dt_remocao_origem timestamptz;
update planos_acao_analises_faf set hash_registro = md5(row(id_analise_plano_acao, tipo_analise_plano_acao, tipo_resultado_analise_plano_acao, data_analise_plano_acao, parecer_analise_plano_acao, tipo_origem_analise_plano_acao, id_plano_acao, id_historico_plano_acao)::text), dt_atualizacao = coalesce(dt_atualizacao, dt_carga)
    where hash_registro is null;
alter table planos_acao_analises_faf alter column dt_atualizacao set default now(), alter column dt_atualizacao set not null,
    alter column hash_registro set not null;
create index if not exists ix_planos_acao_analises_faf_dt_atualizacao on planos_acao_analises_faf (dt_atualizacao);
comment on column planos_acao_analises_faf.dt_carga is 'Quando o registro apareceu pela primeira vez na base (não muda mais)';
comment on column planos_acao_analises_faf.id_execucao is 'Última execução (controle_execucao) que inseriu, alterou ou removeu o registro';
comment on column planos_acao_analises_faf.dt_atualizacao is 'Última vez em que o conteúdo do registro mudou';
comment on column planos_acao_analises_faf.hash_registro is 'md5 das colunas de dados (row(...)::text); detecta alteração no merge incremental';
comment on column planos_acao_analises_faf.dt_remocao_origem is 'Preenchida quando o registro deixou de vir da API; nula = ativo';

alter table planos_acao_analises_responsaveis_faf
    add column if not exists dt_atualizacao timestamptz,
    add column if not exists hash_registro char(32),
    add column if not exists dt_remocao_origem timestamptz;
update planos_acao_analises_responsaveis_faf set hash_registro = md5(row(id_analise_responsavel_plano_acao, nome_responsavel_analise_plano_acao, cargo_responsavel_analise_plano_acao, id_analise_plano_acao)::text), dt_atualizacao = coalesce(dt_atualizacao, dt_carga)
    where hash_registro is null;
alter table planos_acao_analises_responsaveis_faf alter column dt_atualizacao set default now(), alter column dt_atualizacao set not null,
    alter column hash_registro set not null;
create index if not exists ix_planos_acao_analises_responsaveis_faf_dt_atualizacao on planos_acao_analises_responsaveis_faf (dt_atualizacao);
comment on column planos_acao_analises_responsaveis_faf.dt_carga is 'Quando o registro apareceu pela primeira vez na base (não muda mais)';
comment on column planos_acao_analises_responsaveis_faf.id_execucao is 'Última execução (controle_execucao) que inseriu, alterou ou removeu o registro';
comment on column planos_acao_analises_responsaveis_faf.dt_atualizacao is 'Última vez em que o conteúdo do registro mudou';
comment on column planos_acao_analises_responsaveis_faf.hash_registro is 'md5 das colunas de dados (row(...)::text); detecta alteração no merge incremental';
comment on column planos_acao_analises_responsaveis_faf.dt_remocao_origem is 'Preenchida quando o registro deixou de vir da API; nula = ativo';

alter table termos_adesao_faf
    add column if not exists dt_atualizacao timestamptz,
    add column if not exists hash_registro char(32),
    add column if not exists dt_remocao_origem timestamptz;
update termos_adesao_faf set hash_registro = md5(row(id_termo_adesao, numero_processo_termo_adesao, situacao_termo_adesao, objeto_termo_adesao, data_assinatura_termo_adesao, ano_termo_adesao, secao_publicacao_dou_termo_adesao, pagina_publicacao_dou_termo_adesao, data_publicacao_dou_termo_adesao, id_plano_acao)::text), dt_atualizacao = coalesce(dt_atualizacao, dt_carga)
    where hash_registro is null;
alter table termos_adesao_faf alter column dt_atualizacao set default now(), alter column dt_atualizacao set not null,
    alter column hash_registro set not null;
create index if not exists ix_termos_adesao_faf_dt_atualizacao on termos_adesao_faf (dt_atualizacao);
comment on column termos_adesao_faf.dt_carga is 'Quando o registro apareceu pela primeira vez na base (não muda mais)';
comment on column termos_adesao_faf.id_execucao is 'Última execução (controle_execucao) que inseriu, alterou ou removeu o registro';
comment on column termos_adesao_faf.dt_atualizacao is 'Última vez em que o conteúdo do registro mudou';
comment on column termos_adesao_faf.hash_registro is 'md5 das colunas de dados (row(...)::text); detecta alteração no merge incremental';
comment on column termos_adesao_faf.dt_remocao_origem is 'Preenchida quando o registro deixou de vir da API; nula = ativo';

alter table termos_adesao_historico_faf
    add column if not exists dt_atualizacao timestamptz,
    add column if not exists hash_registro char(32),
    add column if not exists dt_remocao_origem timestamptz;
update termos_adesao_historico_faf set hash_registro = md5(row(id_historico_termo_adesao, situacao_historico_termo_adesao, data_historico_termo_adesao, id_termo_adesao)::text), dt_atualizacao = coalesce(dt_atualizacao, dt_carga)
    where hash_registro is null;
alter table termos_adesao_historico_faf alter column dt_atualizacao set default now(), alter column dt_atualizacao set not null,
    alter column hash_registro set not null;
create index if not exists ix_termos_adesao_historico_faf_dt_atualizacao on termos_adesao_historico_faf (dt_atualizacao);
comment on column termos_adesao_historico_faf.dt_carga is 'Quando o registro apareceu pela primeira vez na base (não muda mais)';
comment on column termos_adesao_historico_faf.id_execucao is 'Última execução (controle_execucao) que inseriu, alterou ou removeu o registro';
comment on column termos_adesao_historico_faf.dt_atualizacao is 'Última vez em que o conteúdo do registro mudou';
comment on column termos_adesao_historico_faf.hash_registro is 'md5 das colunas de dados (row(...)::text); detecta alteração no merge incremental';
comment on column termos_adesao_historico_faf.dt_remocao_origem is 'Preenchida quando o registro deixou de vir da API; nula = ativo';

alter table empenhos_faf
    add column if not exists dt_atualizacao timestamptz,
    add column if not exists hash_registro char(32),
    add column if not exists dt_remocao_origem timestamptz;
update empenhos_faf set hash_registro = md5(row(id_empenho, numero_empenho, ano_empenho, gestao_emitente_empenho, ug_emitente_empenho, data_emissao_empenho, fonte_recurso_empenho, esfera_orcamentaria_empenho, descricao_esfera_orcamentaria_empenho, plano_interno_empenho, unidade_gestora_responsavel_empenho, observacao_empenho, cnpj_favorecido_empenho, numero_lista_empenho, unidade_gestora_referencia_empenho, gestao_referencia_empenho, numero_interno_empenho, objeto_empenho, numero_sistema_empenho, natureza_despesa_empenho, natureza_despesa_sub_item_empenho, tipo_empenho, descricao_tipo_empenho, codigo_tipo_nota_empenho, descricao_tipo_nota_empenho, situacao_empenho, descricao_situacao_empenho, valor_empenho, versao_empenho, id_plano_acao)::text), dt_atualizacao = coalesce(dt_atualizacao, dt_carga)
    where hash_registro is null;
alter table empenhos_faf alter column dt_atualizacao set default now(), alter column dt_atualizacao set not null,
    alter column hash_registro set not null;
create index if not exists ix_empenhos_faf_dt_atualizacao on empenhos_faf (dt_atualizacao);
comment on column empenhos_faf.dt_carga is 'Quando o registro apareceu pela primeira vez na base (não muda mais)';
comment on column empenhos_faf.id_execucao is 'Última execução (controle_execucao) que inseriu, alterou ou removeu o registro';
comment on column empenhos_faf.dt_atualizacao is 'Última vez em que o conteúdo do registro mudou';
comment on column empenhos_faf.hash_registro is 'md5 das colunas de dados (row(...)::text); detecta alteração no merge incremental';
comment on column empenhos_faf.dt_remocao_origem is 'Preenchida quando o registro deixou de vir da API; nula = ativo';

alter table gestao_financeira_lancamentos_faf
    add column if not exists dt_atualizacao timestamptz,
    add column if not exists hash_registro char(32),
    add column if not exists dt_remocao_origem timestamptz;
update gestao_financeira_lancamentos_faf set hash_registro = md5(row(id_lancamento_gestao_financeira, origem_solicitacao_gestao_financeira, descricao_origem_solicitacao_gestao_financeira, cnpj_ente_solicitante_gestao_financeira, nome_ente_solicitante_gestao_financeira, nome_personalizado_ente_solicitante_gestao_financeira, codigo_programa_agil_ente_solicitante_gestao_financeira, codigo_banco_gestao_financeira, codigo_agencia_gestao_financeira, dv_agencia_gestao_financeira, codigo_conta_gestao_financeira, dv_conta_gestao_financeira, tipo_operacao_gestao_financeira, descricao_tipo_operacao_gestao_financeira, descricao_gestao_financeira, data_lancamento_gestao_financeira, data_evento_lancamento_gestao_financeira, numero_ordem_gestao_financeira, numero_referencia_unica_gestao_financeira, tipo_favorecido_gestao_financeira, descricao_tipo_favorecido_gestao_financeira, doc_favorecido_gestao_financeira_mask, nome_favorecido_gestao_financeira, valor_lancamento_gestao_financeira, codigo_categoria_despesa_lancamento_gestao_financeira, caminho_categoria_despesa_lancamento_gestao_financeira, quantidade_subtransacoes_lancamento_gestao_financeira, id_agencia_conta)::text), dt_atualizacao = coalesce(dt_atualizacao, dt_carga)
    where hash_registro is null;
alter table gestao_financeira_lancamentos_faf alter column dt_atualizacao set default now(), alter column dt_atualizacao set not null,
    alter column hash_registro set not null;
create index if not exists ix_gestao_financeira_lancamentos_faf_dt_atualizacao on gestao_financeira_lancamentos_faf (dt_atualizacao);
comment on column gestao_financeira_lancamentos_faf.dt_carga is 'Quando o registro apareceu pela primeira vez na base (não muda mais)';
comment on column gestao_financeira_lancamentos_faf.id_execucao is 'Última execução (controle_execucao) que inseriu, alterou ou removeu o registro';
comment on column gestao_financeira_lancamentos_faf.dt_atualizacao is 'Última vez em que o conteúdo do registro mudou';
comment on column gestao_financeira_lancamentos_faf.hash_registro is 'md5 das colunas de dados (row(...)::text); detecta alteração no merge incremental';
comment on column gestao_financeira_lancamentos_faf.dt_remocao_origem is 'Preenchida quando o registro deixou de vir da API; nula = ativo';

alter table gestao_financeira_subtransacoes_faf
    add column if not exists dt_atualizacao timestamptz,
    add column if not exists hash_registro char(32),
    add column if not exists dt_remocao_origem timestamptz;
update gestao_financeira_subtransacoes_faf set hash_registro = md5(row(id_subtransacao_gestao_financeira, estado_subtransacao_gestao_financeira, situacao_pagamento_subtransacao_gestao_financeira, descricao_situacao_pagamento_subtransacao_gestao_financeira, data_pagamento_subtransacao_gestao_financeira, tipo_pessoa_beneficiario_subtransacao_gestao_financeira, descricao_tp_pessoa_beneficiario_subtransacao_gestao_financeira, doc_beneficiario_subtransacao_gestao_financeira_mask, nome_beneficiario_subtransacao_gestao_financeira, descricao_subtransacao_gestao_financeira, valor_subtransacao_gestao_financeira, codigo_categoria_despesa_subtransacao_gestao_financeira, caminho_categoria_despesa_subtransacao_gestao_financeira, id_lancamento_gestao_financeira)::text), dt_atualizacao = coalesce(dt_atualizacao, dt_carga)
    where hash_registro is null;
alter table gestao_financeira_subtransacoes_faf alter column dt_atualizacao set default now(), alter column dt_atualizacao set not null,
    alter column hash_registro set not null;
create index if not exists ix_gestao_financeira_subtransacoes_faf_dt_atualizacao on gestao_financeira_subtransacoes_faf (dt_atualizacao);
comment on column gestao_financeira_subtransacoes_faf.dt_carga is 'Quando o registro apareceu pela primeira vez na base (não muda mais)';
comment on column gestao_financeira_subtransacoes_faf.id_execucao is 'Última execução (controle_execucao) que inseriu, alterou ou removeu o registro';
comment on column gestao_financeira_subtransacoes_faf.dt_atualizacao is 'Última vez em que o conteúdo do registro mudou';
comment on column gestao_financeira_subtransacoes_faf.hash_registro is 'md5 das colunas de dados (row(...)::text); detecta alteração no merge incremental';
comment on column gestao_financeira_subtransacoes_faf.dt_remocao_origem is 'Preenchida quando o registro deixou de vir da API; nula = ativo';

alter table relatorios_gestao_faf
    add column if not exists dt_atualizacao timestamptz,
    add column if not exists hash_registro char(32),
    add column if not exists dt_remocao_origem timestamptz;
update relatorios_gestao_faf set hash_registro = md5(row(id_relatorio_gestao, data_relatorio_gestao, data_e_hora_relatorio_gestao, tipo_relatorio_gestao, situacao_relatorio_gestao, valor_executado_relatorio_gestao, valor_pendente_relatorio_gestao, resultados_alcancados_metas_relatorio_gestao, descritivo_relatorio_gestao, contrapartida_relatorio_gestao, endereco_eletronico_publicidade_acoes_relatorio_gestao, declaracao_conformidade_relatorio_gestao, id_plano_acao)::text), dt_atualizacao = coalesce(dt_atualizacao, dt_carga)
    where hash_registro is null;
alter table relatorios_gestao_faf alter column dt_atualizacao set default now(), alter column dt_atualizacao set not null,
    alter column hash_registro set not null;
create index if not exists ix_relatorios_gestao_faf_dt_atualizacao on relatorios_gestao_faf (dt_atualizacao);
comment on column relatorios_gestao_faf.dt_carga is 'Quando o registro apareceu pela primeira vez na base (não muda mais)';
comment on column relatorios_gestao_faf.id_execucao is 'Última execução (controle_execucao) que inseriu, alterou ou removeu o registro';
comment on column relatorios_gestao_faf.dt_atualizacao is 'Última vez em que o conteúdo do registro mudou';
comment on column relatorios_gestao_faf.hash_registro is 'md5 das colunas de dados (row(...)::text); detecta alteração no merge incremental';
comment on column relatorios_gestao_faf.dt_remocao_origem is 'Preenchida quando o registro deixou de vir da API; nula = ativo';

alter table relatorios_gestao_acoes_faf
    add column if not exists dt_atualizacao timestamptz,
    add column if not exists hash_registro char(32),
    add column if not exists dt_remocao_origem timestamptz;
update relatorios_gestao_acoes_faf set hash_registro = md5(row(id_acao_relatorio_gestao, percentual_execucao_fisica_acao_relatorio_gestao_acao, observacoes_justificativas_relatorio_gestao_acao, id_relatorio_gestao, id_acao_meta_plano_acao)::text), dt_atualizacao = coalesce(dt_atualizacao, dt_carga)
    where hash_registro is null;
alter table relatorios_gestao_acoes_faf alter column dt_atualizacao set default now(), alter column dt_atualizacao set not null,
    alter column hash_registro set not null;
create index if not exists ix_relatorios_gestao_acoes_faf_dt_atualizacao on relatorios_gestao_acoes_faf (dt_atualizacao);
comment on column relatorios_gestao_acoes_faf.dt_carga is 'Quando o registro apareceu pela primeira vez na base (não muda mais)';
comment on column relatorios_gestao_acoes_faf.id_execucao is 'Última execução (controle_execucao) que inseriu, alterou ou removeu o registro';
comment on column relatorios_gestao_acoes_faf.dt_atualizacao is 'Última vez em que o conteúdo do registro mudou';
comment on column relatorios_gestao_acoes_faf.hash_registro is 'md5 das colunas de dados (row(...)::text); detecta alteração no merge incremental';
comment on column relatorios_gestao_acoes_faf.dt_remocao_origem is 'Preenchida quando o registro deixou de vir da API; nula = ativo';

alter table relatorios_gestao_analises_faf
    add column if not exists dt_atualizacao timestamptz,
    add column if not exists hash_registro char(32),
    add column if not exists dt_remocao_origem timestamptz;
update relatorios_gestao_analises_faf set hash_registro = md5(row(id_relatorio_gestao_analise, tipo_analise_relatorio_gestao_analise, resultado_analise_relatorio_gestao_analise, parecer_analise_relatorio_gestao_analise, origem_analise_relatorio_gestao_analise, data_analise_relatorio_gestao_analise, versao_analise_relatorio_gestao_analise, id_relatorio_gestao)::text), dt_atualizacao = coalesce(dt_atualizacao, dt_carga)
    where hash_registro is null;
alter table relatorios_gestao_analises_faf alter column dt_atualizacao set default now(), alter column dt_atualizacao set not null,
    alter column hash_registro set not null;
create index if not exists ix_relatorios_gestao_analises_faf_dt_atualizacao on relatorios_gestao_analises_faf (dt_atualizacao);
comment on column relatorios_gestao_analises_faf.dt_carga is 'Quando o registro apareceu pela primeira vez na base (não muda mais)';
comment on column relatorios_gestao_analises_faf.id_execucao is 'Última execução (controle_execucao) que inseriu, alterou ou removeu o registro';
comment on column relatorios_gestao_analises_faf.dt_atualizacao is 'Última vez em que o conteúdo do registro mudou';
comment on column relatorios_gestao_analises_faf.hash_registro is 'md5 das colunas de dados (row(...)::text); detecta alteração no merge incremental';
comment on column relatorios_gestao_analises_faf.dt_remocao_origem is 'Preenchida quando o registro deixou de vir da API; nula = ativo';

alter table relatorios_gestao_analises_responsaveis_faf
    add column if not exists dt_atualizacao timestamptz,
    add column if not exists hash_registro char(32),
    add column if not exists dt_remocao_origem timestamptz;
update relatorios_gestao_analises_responsaveis_faf set hash_registro = md5(row(id_relatorio_gestao_analise_responsavel, nome_responsavel_analise_relatorio_gestao_analise, cargo_responsavel_analise_relatorio_gestao_analise, id_relatorio_gestao_analise)::text), dt_atualizacao = coalesce(dt_atualizacao, dt_carga)
    where hash_registro is null;
alter table relatorios_gestao_analises_responsaveis_faf alter column dt_atualizacao set default now(), alter column dt_atualizacao set not null,
    alter column hash_registro set not null;
create index if not exists ix_relatorios_gestao_analises_responsaveis_faf_dt_atualizacao on relatorios_gestao_analises_responsaveis_faf (dt_atualizacao);
comment on column relatorios_gestao_analises_responsaveis_faf.dt_carga is 'Quando o registro apareceu pela primeira vez na base (não muda mais)';
comment on column relatorios_gestao_analises_responsaveis_faf.id_execucao is 'Última execução (controle_execucao) que inseriu, alterou ou removeu o registro';
comment on column relatorios_gestao_analises_responsaveis_faf.dt_atualizacao is 'Última vez em que o conteúdo do registro mudou';
comment on column relatorios_gestao_analises_responsaveis_faf.hash_registro is 'md5 das colunas de dados (row(...)::text); detecta alteração no merge incremental';
comment on column relatorios_gestao_analises_responsaveis_faf.dt_remocao_origem is 'Preenchida quando o registro deixou de vir da API; nula = ativo';

alter table programas_natureza_despesa_faf
    add column if not exists dt_atualizacao timestamptz,
    add column if not exists hash_registro char(32),
    add column if not exists dt_remocao_origem timestamptz;
update programas_natureza_despesa_faf set hash_registro = md5(row(id_programa, grupo_natureza_despesa_programa)::text), dt_atualizacao = coalesce(dt_atualizacao, dt_carga)
    where hash_registro is null;
alter table programas_natureza_despesa_faf alter column dt_atualizacao set default now(), alter column dt_atualizacao set not null,
    alter column hash_registro set not null;
create index if not exists ix_programas_natureza_despesa_faf_dt_atualizacao on programas_natureza_despesa_faf (dt_atualizacao);
comment on column programas_natureza_despesa_faf.dt_carga is 'Quando o registro apareceu pela primeira vez na base (não muda mais)';
comment on column programas_natureza_despesa_faf.id_execucao is 'Última execução (controle_execucao) que inseriu, alterou ou removeu o registro';
comment on column programas_natureza_despesa_faf.dt_atualizacao is 'Última vez em que o conteúdo do registro mudou';
comment on column programas_natureza_despesa_faf.hash_registro is 'md5 das colunas de dados (row(...)::text); detecta alteração no merge incremental';
comment on column programas_natureza_despesa_faf.dt_remocao_origem is 'Preenchida quando o registro deixou de vir da API; nula = ativo';

alter table programas_acao_orcamentaria_faf
    add column if not exists dt_atualizacao timestamptz,
    add column if not exists hash_registro char(32),
    add column if not exists dt_remocao_origem timestamptz;
update programas_acao_orcamentaria_faf set hash_registro = md5(row(id_programa, codigo_acao_orcamentaria_programa, descricao_acao_orcamentaria_programa)::text), dt_atualizacao = coalesce(dt_atualizacao, dt_carga)
    where hash_registro is null;
alter table programas_acao_orcamentaria_faf alter column dt_atualizacao set default now(), alter column dt_atualizacao set not null,
    alter column hash_registro set not null;
create index if not exists ix_programas_acao_orcamentaria_faf_dt_atualizacao on programas_acao_orcamentaria_faf (dt_atualizacao);
comment on column programas_acao_orcamentaria_faf.dt_carga is 'Quando o registro apareceu pela primeira vez na base (não muda mais)';
comment on column programas_acao_orcamentaria_faf.id_execucao is 'Última execução (controle_execucao) que inseriu, alterou ou removeu o registro';
comment on column programas_acao_orcamentaria_faf.dt_atualizacao is 'Última vez em que o conteúdo do registro mudou';
comment on column programas_acao_orcamentaria_faf.hash_registro is 'md5 das colunas de dados (row(...)::text); detecta alteração no merge incremental';
comment on column programas_acao_orcamentaria_faf.dt_remocao_origem is 'Preenchida quando o registro deixou de vir da API; nula = ativo';

alter table gestao_financeira_saldo_conta_faf
    add column if not exists dt_atualizacao timestamptz,
    add column if not exists hash_registro char(32),
    add column if not exists dt_remocao_origem timestamptz;
update gestao_financeira_saldo_conta_faf set hash_registro = md5(row(id_agencia_conta, saldo_final_gestao_financeira)::text), dt_atualizacao = coalesce(dt_atualizacao, dt_carga)
    where hash_registro is null;
alter table gestao_financeira_saldo_conta_faf alter column dt_atualizacao set default now(), alter column dt_atualizacao set not null,
    alter column hash_registro set not null;
create index if not exists ix_gestao_financeira_saldo_conta_faf_dt_atualizacao on gestao_financeira_saldo_conta_faf (dt_atualizacao);
comment on column gestao_financeira_saldo_conta_faf.dt_carga is 'Quando o registro apareceu pela primeira vez na base (não muda mais)';
comment on column gestao_financeira_saldo_conta_faf.id_execucao is 'Última execução (controle_execucao) que inseriu, alterou ou removeu o registro';
comment on column gestao_financeira_saldo_conta_faf.dt_atualizacao is 'Última vez em que o conteúdo do registro mudou';
comment on column gestao_financeira_saldo_conta_faf.hash_registro is 'md5 das colunas de dados (row(...)::text); detecta alteração no merge incremental';
comment on column gestao_financeira_saldo_conta_faf.dt_remocao_origem is 'Preenchida quando o registro deixou de vir da API; nula = ativo';

-- staging antigo (mesmo esquema da base): era só cópia temporária do último download
drop table if exists stg_programas_faf;
drop table if exists stg_programas_beneficiarios_faf;
drop table if exists stg_programas_ageis_faf;
drop table if exists stg_planos_acao_faf;
drop table if exists stg_planos_acao_dados_bancarios_faf;
drop table if exists stg_planos_acao_metas_faf;
drop table if exists stg_planos_acao_metas_acoes_faf;
drop table if exists stg_planos_acao_destinacao_recursos_faf;
drop table if exists stg_planos_acao_historico_faf;
drop table if exists stg_planos_acao_analises_faf;
drop table if exists stg_planos_acao_analises_responsaveis_faf;
drop table if exists stg_termos_adesao_faf;
drop table if exists stg_termos_adesao_historico_faf;
drop table if exists stg_empenhos_faf;
drop table if exists stg_gestao_financeira_lancamentos_faf;
drop table if exists stg_gestao_financeira_subtransacoes_faf;
drop table if exists stg_relatorios_gestao_faf;
drop table if exists stg_relatorios_gestao_acoes_faf;
drop table if exists stg_relatorios_gestao_analises_faf;
drop table if exists stg_relatorios_gestao_analises_responsaveis_faf;
drop table if exists stg_programas_natureza_despesa_faf;
drop table if exists stg_programas_acao_orcamentaria_faf;
drop table if exists stg_gestao_financeira_saldo_conta_faf;

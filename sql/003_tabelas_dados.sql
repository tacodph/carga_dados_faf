-- Gerado por scripts/gerar_ddl.py — não editar à mão.
set search_path to base_transferencias_fundo_fundo;

create table if not exists programas_faf (
    id_programa bigint,
    ano_programa bigint,
    modalidade_programa varchar(255),
    codigo_programa bigint,
    nome_programa varchar(255),
    id_unidade_gestora_programa bigint,
    nome_institucional_programa varchar(255),
    permite_transferencia_sem_fundo_programa boolean,
    objetivo_programa varchar(2110),
    descricao_programa varchar(3800),
    situacao_programa varchar(255),
    valor_global_programa numeric(15,2),
    quantidade_parcelas_programa bigint,
    id_orgao_superior_programa bigint,
    sigla_orgao_superior_programa varchar(255),
    cnpj_orgao_superior_programa varchar(255),
    nome_orgao_superior_programa varchar(255),
    id_fundo_programa bigint,
    cnpj_fundo_programa varchar(255),
    nome_fundo_programa varchar(255),
    uf_fundo_programa varchar(255),
    municipio_fundo_programa varchar(255),
    codigo_ibge_fundo_programa bigint,
    data_inicio_recebimento_planos_acao_beneficiarios_especificos date,
    data_fim_recebimento_planos_acao_beneficiarios_especificos date,
    data_inicio_recebimento_planos_acao_beneficiarios_emendas date,
    data_fim_recebimento_planos_acao_beneficiarios_emendas date,
    data_inicio_recebimento_planos_acao_beneficiarios_voluntarios date,
    data_fim_recebimento_planos_acao_beneficiarios_voluntarios date,
    dt_carga timestamptz not null default now(),
    id_execucao bigint not null,
    dt_atualizacao timestamptz not null default now(),
    hash_registro char(32) not null,
    dt_remocao_origem timestamptz,
    primary key (id_programa)
);
comment on table programas_faf is 'Tabela que armazena os Programas Fundo a Fundo (FAF) (endpoint /programas)';
comment on column programas_faf.id_programa is 'Identificador Único do Programa';
comment on column programas_faf.ano_programa is 'Ano do Programa';
comment on column programas_faf.modalidade_programa is 'Modalidade do Programa';
comment on column programas_faf.codigo_programa is 'Código do Programa';
comment on column programas_faf.nome_programa is 'Nome do Programa';
comment on column programas_faf.id_unidade_gestora_programa is 'Identificador Único do Código UG - Unidade Gestora do Orgão do Programa';
comment on column programas_faf.nome_institucional_programa is 'Nome Institucional do Programa';
comment on column programas_faf.permite_transferencia_sem_fundo_programa is 'Permite Transferência Sem Fundo do Programa';
comment on column programas_faf.objetivo_programa is 'Objetivo do Programa';
comment on column programas_faf.descricao_programa is 'Descrição do Programa';
comment on column programas_faf.situacao_programa is 'Situação do Programa';
comment on column programas_faf.valor_global_programa is 'Valor Global do Programa';
comment on column programas_faf.quantidade_parcelas_programa is 'Quantidade de Parcelas do Programa';
comment on column programas_faf.id_orgao_superior_programa is 'Identificador Único do Órgão Superior do Programa';
comment on column programas_faf.sigla_orgao_superior_programa is 'Sigla do Órgão Superior do Programa';
comment on column programas_faf.cnpj_orgao_superior_programa is 'CNPJ do Órgão Superior do Programa';
comment on column programas_faf.nome_orgao_superior_programa is 'Nome do Órgão Superior do Programa';
comment on column programas_faf.id_fundo_programa is 'Identificador Único do Fundo do Programa';
comment on column programas_faf.cnpj_fundo_programa is 'CNPJ do Fundo do Programa';
comment on column programas_faf.nome_fundo_programa is 'Nome do Fundo do Programa';
comment on column programas_faf.uf_fundo_programa is 'Sigla da Unidade da Federação do Fundo do Programa';
comment on column programas_faf.municipio_fundo_programa is 'Nome do Município do Fundo do Programa';
comment on column programas_faf.codigo_ibge_fundo_programa is 'Código IBGE do Município do Fundo do Programa';
comment on column programas_faf.data_inicio_recebimento_planos_acao_beneficiarios_especificos is 'Data de Início do Recebimento dos Planos de Ação para Beneficiários Específicos';
comment on column programas_faf.data_fim_recebimento_planos_acao_beneficiarios_especificos is 'Data Final do Recebimento dos Planos de Ação para Beneficiários Específicos';
comment on column programas_faf.data_inicio_recebimento_planos_acao_beneficiarios_emendas is 'Data de Início do Recebimento dos Planos de Ação para Beneficiários de Emendas';
comment on column programas_faf.data_fim_recebimento_planos_acao_beneficiarios_emendas is 'Data Final do Recebimento dos Planos de Ação para Beneficiários de Emendas';
comment on column programas_faf.data_inicio_recebimento_planos_acao_beneficiarios_voluntarios is 'Data de Início do Recebimento dos Planos de Ação para Beneficiários Voluntários';
comment on column programas_faf.data_fim_recebimento_planos_acao_beneficiarios_voluntarios is 'Data Final do Recebimento dos Planos de Ação para Beneficiários Voluntários';
comment on column programas_faf.dt_carga is 'Quando o registro apareceu pela primeira vez na base (não muda mais)';
comment on column programas_faf.id_execucao is 'Última execução (controle_execucao) que inseriu, alterou ou removeu o registro';

create table if not exists programas_beneficiarios_faf (
    id_beneficiario_programa bigint,
    cnpj_beneficiario_programa varchar(255),
    nome_beneficiario_programa varchar(255),
    valor_beneficiario_programa numeric(15,2),
    numero_emenda_beneficiario_programa varchar(255),
    nome_parlamentar_beneficiario_programa varchar(255),
    tipo_beneficiario_programa varchar(255),
    nome_ente_beneficiario_programa varchar(255),
    uf_ente_beneficiario_programa varchar(255),
    nome_municipio_ente_beneficiario_programa varchar(255),
    codigo_ibge_municipio_ente_beneficiario_programa bigint,
    id_ente_beneficiario_programa bigint,
    id_programa bigint,
    dt_carga timestamptz not null default now(),
    id_execucao bigint not null,
    dt_atualizacao timestamptz not null default now(),
    hash_registro char(32) not null,
    dt_remocao_origem timestamptz,
    primary key (id_beneficiario_programa)
);
create index if not exists ix_programas_beneficiarios_faf_id_programa on programas_beneficiarios_faf (id_programa);
comment on table programas_beneficiarios_faf is 'Tabela que armazena os Beneficiários de Programas FAF (endpoint /programas-beneficiarios)';
comment on column programas_beneficiarios_faf.id_beneficiario_programa is 'Identificador Único do Beneficiário do Programa';
comment on column programas_beneficiarios_faf.cnpj_beneficiario_programa is 'CNPJ do Beneficiário do Programa';
comment on column programas_beneficiarios_faf.nome_beneficiario_programa is 'Nome do Beneficiário do Programa';
comment on column programas_beneficiarios_faf.valor_beneficiario_programa is 'Valor Destinado ao Beneficiário do Programa';
comment on column programas_beneficiarios_faf.numero_emenda_beneficiario_programa is 'Número da Emenda do Beneficiário do Programa';
comment on column programas_beneficiarios_faf.nome_parlamentar_beneficiario_programa is 'Nome do Parlamentar Autor da Emenda do Beneficiário do Programa';
comment on column programas_beneficiarios_faf.tipo_beneficiario_programa is 'Tipo do Beneficiário do Programa';
comment on column programas_beneficiarios_faf.nome_ente_beneficiario_programa is 'Nome do Ente do Beneficiário do Programa';
comment on column programas_beneficiarios_faf.uf_ente_beneficiario_programa is 'Sigla da Unidade da Federação do Beneficiário do Programa';
comment on column programas_beneficiarios_faf.nome_municipio_ente_beneficiario_programa is 'Nome do Município do Ente Beneficiário do Programa';
comment on column programas_beneficiarios_faf.codigo_ibge_municipio_ente_beneficiario_programa is 'Código IBGE do Município do Ente Beneficiário do Programa';
comment on column programas_beneficiarios_faf.id_ente_beneficiario_programa is 'Identificador Único do Ente Beneficiário do Programa';
comment on column programas_beneficiarios_faf.id_programa is 'Identificador Único do Programa — Relaciona com programas_faf.id_programa';
comment on column programas_beneficiarios_faf.dt_carga is 'Quando o registro apareceu pela primeira vez na base (não muda mais)';
comment on column programas_beneficiarios_faf.id_execucao is 'Última execução (controle_execucao) que inseriu, alterou ou removeu o registro';

create table if not exists programas_ageis_faf (
    id_programa_agil bigint,
    id_programa_agil_bb bigint,
    nome_programa_agil varchar(255),
    codigo_programa_agil varchar(30),
    id_orgao_programa_agil bigint,
    codigo_siorg_orgao_programa_agil bigint,
    sigla_orgao_programa_agil varchar(255),
    cnpj_orgao_programa_agil varchar(255),
    nome_orgao_programa_agil varchar(255),
    id_programa bigint,
    dt_carga timestamptz not null default now(),
    id_execucao bigint not null,
    dt_atualizacao timestamptz not null default now(),
    hash_registro char(32) not null,
    dt_remocao_origem timestamptz,
    primary key (id_programa_agil)
);
create index if not exists ix_programas_ageis_faf_id_programa on programas_ageis_faf (id_programa);
comment on table programas_ageis_faf is 'Tabela que armazena os Programas Ágeis FAF (endpoint /programas-gestao-agil)';
comment on column programas_ageis_faf.id_programa_agil is 'Identificador Único do Programa Ágil';
comment on column programas_ageis_faf.id_programa_agil_bb is 'Identificador Único do Programa Ágil no BB';
comment on column programas_ageis_faf.nome_programa_agil is 'Nome do Programa Ágil';
comment on column programas_ageis_faf.codigo_programa_agil is 'Código do Programa Ágil';
comment on column programas_ageis_faf.id_orgao_programa_agil is 'Identificador Único do Órgão do Programa Ágil';
comment on column programas_ageis_faf.codigo_siorg_orgao_programa_agil is 'Código SIORG do Órgão do Programa Ágil';
comment on column programas_ageis_faf.sigla_orgao_programa_agil is 'Sigla do Órgão do Programa Ágil';
comment on column programas_ageis_faf.cnpj_orgao_programa_agil is 'CNPJ do Órgão do Programa Ágil';
comment on column programas_ageis_faf.nome_orgao_programa_agil is 'Nome do Órgão do Programa Ágil';
comment on column programas_ageis_faf.id_programa is 'Identificador Único do Programa — Relaciona com programas_faf.id_programa';
comment on column programas_ageis_faf.dt_carga is 'Quando o registro apareceu pela primeira vez na base (não muda mais)';
comment on column programas_ageis_faf.id_execucao is 'Última execução (controle_execucao) que inseriu, alterou ou removeu o registro';

create table if not exists planos_acao_faf (
    id_plano_acao bigint,
    codigo_plano_acao varchar(255),
    data_inicio_vigencia_plano_acao date,
    data_fim_vigencia_plano_acao date,
    diagnostico_plano_acao text,
    objetivos_plano_acao text,
    situacao_plano_acao varchar(255),
    valor_repasse_emenda_plano_acao numeric(15,2),
    valor_repasse_especifico_plano_acao numeric(15,2),
    valor_repasse_voluntario_plano_acao numeric(15,2),
    valor_total_repasse_plano_acao numeric(15,2),
    valor_recursos_proprios_plano_acao numeric(15,2),
    valor_outros_plano_acao numeric(15,2),
    valor_rendimentos_aplicacao_plano_acao numeric(15,2),
    valor_total_plano_acao numeric(15,2),
    valor_total_investimento_plano_acao numeric(15,2),
    valor_total_custeio_plano_acao numeric(15,2),
    valor_saldo_disponivel_plano_acao numeric(15,2),
    id_orgao_repassador_plano_acao bigint,
    sigla_orgao_repassador_plano_acao varchar(255),
    cnpj_orgao_repassador_plano_acao varchar(255),
    nome_orgao_repassador_plano_acao varchar(255),
    id_ente_repassador_plano_acao bigint,
    cnpj_ente_repassador_plano_acao varchar(255),
    nome_ente_repassador_plano_acao varchar(255),
    uf_ente_repassador_plano_acao varchar(255),
    nome_municipio_ente_repassador_plano_acao varchar(255),
    codigo_ibge_municipio_ente_repassador_plano_acao bigint,
    id_ente_recebedor_plano_acao bigint,
    cnpj_ente_recebedor_plano_acao varchar(255),
    nome_ente_recebedor_plano_acao varchar(255),
    uf_ente_recebedor_plano_acao varchar(255),
    nome_municipio_ente_recebedor_plano_acao varchar(255),
    codigo_ibge_municipio_ente_recebedor_plano_acao bigint,
    tipo_unidade_recebedora_plano_acao varchar(255),
    descricao_tipo_unidade_ente_plano_acao varchar(255),
    id_fundo_repassador_plano_acao bigint,
    cnpj_fundo_repassador_plano_acao varchar(255),
    nome_fundo_repassador_plano_acao varchar(255),
    uf_fundo_repassador_plano_acao varchar(255),
    municipio_fundo_repassador_plano_acao varchar(255),
    codigo_ibge_fundo_repassador_plano_acao bigint,
    id_fundo_vinculado_plano_acao bigint,
    cnpj_fundo_vinculado_plano_acao varchar(255),
    nome_fundo_vinculado_plano_acao varchar(255),
    uf_fundo_vinculado_plano_acao varchar(255),
    municipio_fundo_vinculado_plano_acao varchar(255),
    codigo_ibge_fundo_vinculado_plano_acao bigint,
    tipo_unidade_recebedora_vinculada_plano_acao varchar(255),
    descricao_tipo_unidade_recebedora_vinculada_plano_acao varchar(255),
    id_programa bigint,
    dt_carga timestamptz not null default now(),
    id_execucao bigint not null,
    dt_atualizacao timestamptz not null default now(),
    hash_registro char(32) not null,
    dt_remocao_origem timestamptz,
    primary key (id_plano_acao)
);
create index if not exists ix_planos_acao_faf_id_programa on planos_acao_faf (id_programa);
comment on table planos_acao_faf is 'Tabela que armazena os Planos de Ação FAF (endpoint /planos-acao)';
comment on column planos_acao_faf.id_plano_acao is 'Identificador Único do Plano de Ação';
comment on column planos_acao_faf.codigo_plano_acao is 'Código do Plano de Ação';
comment on column planos_acao_faf.data_inicio_vigencia_plano_acao is 'Data do Ínicio da Vigência do Plano de Ação';
comment on column planos_acao_faf.data_fim_vigencia_plano_acao is 'Data do Fim da Vigência do Plano de Ação';
comment on column planos_acao_faf.diagnostico_plano_acao is 'Diagnóstico do Plano de Ação';
comment on column planos_acao_faf.objetivos_plano_acao is 'Objetivos do Plano de Ação';
comment on column planos_acao_faf.situacao_plano_acao is 'Situação do Plano de Ação';
comment on column planos_acao_faf.valor_repasse_emenda_plano_acao is 'Valor de Repasse da Emenda Parlamentar do Plano de Ação';
comment on column planos_acao_faf.valor_repasse_especifico_plano_acao is 'Valor do Repasse Específico do Plano de Ação';
comment on column planos_acao_faf.valor_repasse_voluntario_plano_acao is 'Valor do Repasse Voluntário do Plano de Ação';
comment on column planos_acao_faf.valor_total_repasse_plano_acao is 'Valor Total do Repasse do Plano de Ação';
comment on column planos_acao_faf.valor_recursos_proprios_plano_acao is 'Valor dos Recursos Próprios do Plano de Ação';
comment on column planos_acao_faf.valor_outros_plano_acao is 'Valor Outros do Plano de Ação';
comment on column planos_acao_faf.valor_rendimentos_aplicacao_plano_acao is 'Valor dos Rendimentos da Aplicação do Plano de Ação';
comment on column planos_acao_faf.valor_total_plano_acao is 'Valor Total do Plano de Ação';
comment on column planos_acao_faf.valor_total_investimento_plano_acao is 'Valor Total de Investimento do Plano de Ação';
comment on column planos_acao_faf.valor_total_custeio_plano_acao is 'Valor Total de Custeio do Plano de Ação';
comment on column planos_acao_faf.valor_saldo_disponivel_plano_acao is 'Valor do Saldo Disponível do Plano de Ação';
comment on column planos_acao_faf.id_orgao_repassador_plano_acao is 'Identificador Único do Órgão Repassador no cadastro do Plano de Ação';
comment on column planos_acao_faf.sigla_orgao_repassador_plano_acao is 'Sigla do Órgão Repassador do Plano de Ação';
comment on column planos_acao_faf.cnpj_orgao_repassador_plano_acao is 'CNPJ do Órgão Repassador do Plano de Ação';
comment on column planos_acao_faf.nome_orgao_repassador_plano_acao is 'Nome do Órgão Repassador do Plano de Ação';
comment on column planos_acao_faf.id_ente_repassador_plano_acao is 'Identificador Único do Ente Repassador no cadastro do Plano de Ação';
comment on column planos_acao_faf.cnpj_ente_repassador_plano_acao is 'CNPJ do Ente Repassador do Plano de Ação';
comment on column planos_acao_faf.nome_ente_repassador_plano_acao is 'Nome do Ente Repassador do Plano de Ação';
comment on column planos_acao_faf.uf_ente_repassador_plano_acao is 'Sigla da Unidade da Federação do Ente Repassador do Plano de Ação';
comment on column planos_acao_faf.nome_municipio_ente_repassador_plano_acao is 'Nome do Município do Ente Repassador do Plano de Ação';
comment on column planos_acao_faf.codigo_ibge_municipio_ente_repassador_plano_acao is 'Código IBGE do Município do Ente Repassador do Plano de Ação';
comment on column planos_acao_faf.id_ente_recebedor_plano_acao is 'Identificador Único do Ente Recebedor no cadastro do Plano de Ação';
comment on column planos_acao_faf.cnpj_ente_recebedor_plano_acao is 'CNPJ do Ente Recebedor do Plano de Ação';
comment on column planos_acao_faf.nome_ente_recebedor_plano_acao is 'Nome do Ente Recebedor do Plano de Ação';
comment on column planos_acao_faf.uf_ente_recebedor_plano_acao is 'Sigla da Unidade da Federação do Ente Recebedor do Plano de Ação';
comment on column planos_acao_faf.nome_municipio_ente_recebedor_plano_acao is 'Nome do Município do Ente Recebedor do Plano de Ação';
comment on column planos_acao_faf.codigo_ibge_municipio_ente_recebedor_plano_acao is 'Código IBGE do Município do Ente Recebedor do Plano de Ação';
comment on column planos_acao_faf.tipo_unidade_recebedora_plano_acao is 'Tipo da Unidade Recebedora do Plano de Ação';
comment on column planos_acao_faf.descricao_tipo_unidade_ente_plano_acao is 'Descrição do Tipo da Unidade do Ente do Plano de Ação';
comment on column planos_acao_faf.id_fundo_repassador_plano_acao is 'Identificador Único do Fundo Repassador no cadastro do Plano de Ação';
comment on column planos_acao_faf.cnpj_fundo_repassador_plano_acao is 'CNPJ do Fundo Repassador do Plano de Ação';
comment on column planos_acao_faf.nome_fundo_repassador_plano_acao is 'Nome do Fundo Repassador do Plano de Ação';
comment on column planos_acao_faf.uf_fundo_repassador_plano_acao is 'Sigla da Unidade da Federação do Fundo Repassador do Plano de Ação';
comment on column planos_acao_faf.municipio_fundo_repassador_plano_acao is 'Nome do Município do Fundo Repassador do Plano de Ação';
comment on column planos_acao_faf.codigo_ibge_fundo_repassador_plano_acao is 'Código IBGE do Município do Fundo Repassador do Plano de Ação';
comment on column planos_acao_faf.id_fundo_vinculado_plano_acao is 'Identificador Único do Fundo Vinculado no cadastro do Plano de Ação';
comment on column planos_acao_faf.cnpj_fundo_vinculado_plano_acao is 'CNPJ do Fundo Vinculado ao Plano de Ação';
comment on column planos_acao_faf.nome_fundo_vinculado_plano_acao is 'Nome do Fundo Vinculado ao Plano de Ação';
comment on column planos_acao_faf.uf_fundo_vinculado_plano_acao is 'Sigla da Unidade da Federação do Fundo Vinculado ao Plano de Ação';
comment on column planos_acao_faf.municipio_fundo_vinculado_plano_acao is 'Nome do Município do Fundo Vinculado ao Plano de Ação';
comment on column planos_acao_faf.codigo_ibge_fundo_vinculado_plano_acao is 'Código IBGE do Município do Fundo Vinculado ao Plano de Ação';
comment on column planos_acao_faf.tipo_unidade_recebedora_vinculada_plano_acao is 'Tipo da Unidade Recebedora Vinculada ao Plano de Ação';
comment on column planos_acao_faf.descricao_tipo_unidade_recebedora_vinculada_plano_acao is 'Descrição do Tipo da Unidade Recebedora Vinculada ao Plano de Ação';
comment on column planos_acao_faf.id_programa is 'Identificador Único do Programa — Relaciona com programas_faf.id_programa';
comment on column planos_acao_faf.dt_carga is 'Quando o registro apareceu pela primeira vez na base (não muda mais)';
comment on column planos_acao_faf.id_execucao is 'Última execução (controle_execucao) que inseriu, alterou ou removeu o registro';

create table if not exists planos_acao_dados_bancarios_faf (
    id_plano_acao_dado_bancario bigint,
    id_agencia_conta varchar(255),
    codigo_banco_plano_acao_dado_bancario varchar(30),
    nome_banco_plano_acao_dado_bancario varchar(255),
    numero_agencia_plano_acao_dado_bancario varchar(30),
    dv_agencia_plano_acao_dado_bancario varchar(255),
    numero_conta_plano_acao_dado_bancario varchar(30),
    dv_conta_plano_acao_dado_bancario varchar(255),
    situacao_conta_plano_acao_dado_bancario varchar(255),
    data_abertura_conta_plano_acao_dado_bancario date,
    nome_programa_agil_conta_plano_acao_dado_bancario varchar(255),
    saldo_final_conta_plano_acao_dado_bancario numeric(15,2),
    id_plano_acao bigint,
    dt_carga timestamptz not null default now(),
    id_execucao bigint not null,
    dt_atualizacao timestamptz not null default now(),
    hash_registro char(32) not null,
    dt_remocao_origem timestamptz,
    primary key (id_plano_acao_dado_bancario)
);
create index if not exists ix_planos_acao_dados_bancarios_faf_id_plano_acao on planos_acao_dados_bancarios_faf (id_plano_acao);
create index if not exists ix_planos_acao_dados_bancarios_faf_id_agencia_conta on planos_acao_dados_bancarios_faf (id_agencia_conta);
comment on table planos_acao_dados_bancarios_faf is 'Tabela que armazena os Dados Bancários dos Planos de Ação FAF (endpoint /planos-acao-dados-bancarios)';
comment on column planos_acao_dados_bancarios_faf.id_plano_acao_dado_bancario is 'Identificador Único do Dado Bancário do Plano de Ação';
comment on column planos_acao_dados_bancarios_faf.id_agencia_conta is 'Identificador Único da Conta Bancária (Número da Agência Bancária seguida do Número da Conta Bancária) do Plano de Ação — Relaciona com gestao_financeira_saldo_conta_faf.id_agencia_conta';
comment on column planos_acao_dados_bancarios_faf.codigo_banco_plano_acao_dado_bancario is 'Código do Banco do Plano de Ação';
comment on column planos_acao_dados_bancarios_faf.nome_banco_plano_acao_dado_bancario is 'Nome do Banco do Plano de Ação';
comment on column planos_acao_dados_bancarios_faf.numero_agencia_plano_acao_dado_bancario is 'Número da Agência Bancária do Plano de Ação';
comment on column planos_acao_dados_bancarios_faf.dv_agencia_plano_acao_dado_bancario is 'Dígito Verificador da Agência Bancária do Plano de Ação';
comment on column planos_acao_dados_bancarios_faf.numero_conta_plano_acao_dado_bancario is 'Número da Conta Bancária do Plano de Ação';
comment on column planos_acao_dados_bancarios_faf.dv_conta_plano_acao_dado_bancario is 'Dígito Verificador da Conta Bancária do Plano de Ação';
comment on column planos_acao_dados_bancarios_faf.situacao_conta_plano_acao_dado_bancario is 'Situação da Conta Bancária do Plano de Ação';
comment on column planos_acao_dados_bancarios_faf.data_abertura_conta_plano_acao_dado_bancario is 'Data de Abertura da Conta Bancária do Plano de Ação';
comment on column planos_acao_dados_bancarios_faf.nome_programa_agil_conta_plano_acao_dado_bancario is 'Nome do Programa Ágil da Conta Bancária do Plano de Ação';
comment on column planos_acao_dados_bancarios_faf.saldo_final_conta_plano_acao_dado_bancario is 'Saldo Final da Conta Bancária (campo aninhado saldo_final_dado_bancario.saldo_final_gestao_financeira)';
comment on column planos_acao_dados_bancarios_faf.id_plano_acao is 'Identificador Único do Plano de Ação — Relaciona com planos_acao_faf.id_plano_acao';
comment on column planos_acao_dados_bancarios_faf.dt_carga is 'Quando o registro apareceu pela primeira vez na base (não muda mais)';
comment on column planos_acao_dados_bancarios_faf.id_execucao is 'Última execução (controle_execucao) que inseriu, alterou ou removeu o registro';

create table if not exists planos_acao_metas_faf (
    id_meta_plano_acao bigint,
    numero_meta_plano_acao varchar(255),
    nome_meta_plano_acao varchar(255),
    descricao_meta_plano_acao text,
    valor_meta_plano_acao numeric(15,2),
    versao_meta_plano_acao bigint,
    sequencial_meta_plano_acao bigint,
    id_plano_acao bigint,
    dt_carga timestamptz not null default now(),
    id_execucao bigint not null,
    dt_atualizacao timestamptz not null default now(),
    hash_registro char(32) not null,
    dt_remocao_origem timestamptz,
    primary key (id_meta_plano_acao)
);
create index if not exists ix_planos_acao_metas_faf_id_plano_acao on planos_acao_metas_faf (id_plano_acao);
comment on table planos_acao_metas_faf is 'Tabela que armazena as Metas dos Planos de Ação FAF (endpoint /planos-acao-metas)';
comment on column planos_acao_metas_faf.id_meta_plano_acao is 'Identificador Único da Meta do Plano de Ação';
comment on column planos_acao_metas_faf.numero_meta_plano_acao is 'Número da Meta do Plano de Ação (Letra "M" seguida do Sequencial da Meta do Plano de Ação)';
comment on column planos_acao_metas_faf.nome_meta_plano_acao is 'Nome da Meta do Plano de Ação';
comment on column planos_acao_metas_faf.descricao_meta_plano_acao is 'Descrição da Meta do Plano de Ação';
comment on column planos_acao_metas_faf.valor_meta_plano_acao is 'Somatório dos Valores das Ações da Meta do Plano de Ação';
comment on column planos_acao_metas_faf.versao_meta_plano_acao is 'Versão da Meta do Plano de Ação';
comment on column planos_acao_metas_faf.sequencial_meta_plano_acao is 'Número Sequencial da Meta do Plano de Ação';
comment on column planos_acao_metas_faf.id_plano_acao is 'Identificador Único do Plano de Ação — Relaciona com planos_acao_faf.id_plano_acao';
comment on column planos_acao_metas_faf.dt_carga is 'Quando o registro apareceu pela primeira vez na base (não muda mais)';
comment on column planos_acao_metas_faf.id_execucao is 'Última execução (controle_execucao) que inseriu, alterou ou removeu o registro';

create table if not exists planos_acao_metas_acoes_faf (
    id_acao_meta_plano_acao bigint,
    numero_acao_meta_plano_acao varchar(255),
    nome_acao_meta_plano_acao varchar(255),
    descricao_acao_meta_plano_acao text,
    valor_acao_meta_plano_acao numeric(15,2),
    versao_acao_meta_plano_acao bigint,
    sequencial_acao_meta_plano_acao bigint,
    id_meta_plano_acao bigint,
    dt_carga timestamptz not null default now(),
    id_execucao bigint not null,
    dt_atualizacao timestamptz not null default now(),
    hash_registro char(32) not null,
    dt_remocao_origem timestamptz,
    primary key (id_acao_meta_plano_acao)
);
create index if not exists ix_planos_acao_metas_acoes_faf_id_meta_plano_acao on planos_acao_metas_acoes_faf (id_meta_plano_acao);
comment on table planos_acao_metas_acoes_faf is 'Tabela que armazena as Ações das Metas dos Planos de Ação FAF (endpoint /planos-acao-metas-acoes)';
comment on column planos_acao_metas_acoes_faf.id_acao_meta_plano_acao is 'Identificador Único da Ação da Meta do Plano de Ação';
comment on column planos_acao_metas_acoes_faf.numero_acao_meta_plano_acao is 'Número da Ação da Meta do Plano de Ação (Letra "A" seguida do sequencial da Meta do Plano de Ação, seguido de ".", seguida do Sequencial da Ação da Meta do Plano de Ação)';
comment on column planos_acao_metas_acoes_faf.nome_acao_meta_plano_acao is 'Nome da Ação da Meta do Plano de Ação';
comment on column planos_acao_metas_acoes_faf.descricao_acao_meta_plano_acao is 'Descrição da Ação da Meta do Plano de Ação';
comment on column planos_acao_metas_acoes_faf.valor_acao_meta_plano_acao is 'Valor da Ação da Meta do Plano de Ação';
comment on column planos_acao_metas_acoes_faf.versao_acao_meta_plano_acao is 'Versão da Ação da Meta do Plano de Ação';
comment on column planos_acao_metas_acoes_faf.sequencial_acao_meta_plano_acao is 'Número Sequencial da Ação da Meta do Plano de Ação';
comment on column planos_acao_metas_acoes_faf.id_meta_plano_acao is 'Identificador Único da Meta do Plano de Ação — Relaciona com planos_acao_metas_faf.id_meta_plano_acao';
comment on column planos_acao_metas_acoes_faf.dt_carga is 'Quando o registro apareceu pela primeira vez na base (não muda mais)';
comment on column planos_acao_metas_acoes_faf.id_execucao is 'Última execução (controle_execucao) que inseriu, alterou ou removeu o registro';

create table if not exists planos_acao_destinacao_recursos_faf (
    id_destinacao_recursos_plano_acao bigint,
    codigo_natureza_despesa_destinacao_recursos_plano_acao bigint,
    descricao_natureza_despesa_destinacao_recursos_plano_acao varchar(255),
    tipo_despesa_destinacao_recursos_plano_acao varchar(255),
    valor_destinacao_recursos_plano_acao numeric(15,2),
    id_plano_acao bigint,
    dt_carga timestamptz not null default now(),
    id_execucao bigint not null,
    dt_atualizacao timestamptz not null default now(),
    hash_registro char(32) not null,
    dt_remocao_origem timestamptz,
    primary key (id_destinacao_recursos_plano_acao)
);
create index if not exists ix_planos_acao_destinacao_recursos_faf_id_plano_acao on planos_acao_destinacao_recursos_faf (id_plano_acao);
comment on table planos_acao_destinacao_recursos_faf is 'Tabela que armazena a Destinação de Recursos dos Planos de Ação FAF (endpoint /planos-acao-destinacao-recursos)';
comment on column planos_acao_destinacao_recursos_faf.id_destinacao_recursos_plano_acao is 'Identificador Único do Item de Despesa Cadastrado no Plano de Ação';
comment on column planos_acao_destinacao_recursos_faf.codigo_natureza_despesa_destinacao_recursos_plano_acao is 'Código da Natureza de Despesa no SIAFI do Item de Despesa Cadastrado no Plano de Ação';
comment on column planos_acao_destinacao_recursos_faf.descricao_natureza_despesa_destinacao_recursos_plano_acao is 'Descrição da Natureza de Despesa no SIAFI do Item de Despesa Cadastrado no Plano de Ação';
comment on column planos_acao_destinacao_recursos_faf.tipo_despesa_destinacao_recursos_plano_acao is 'Tipo da Natureza de Despesa do Item de Despesa Cadastrado no Plano de Ação';
comment on column planos_acao_destinacao_recursos_faf.valor_destinacao_recursos_plano_acao is 'Valor do Recurso destinado ao Item de Despesa Cadastrado no Plano de Ação';
comment on column planos_acao_destinacao_recursos_faf.id_plano_acao is 'Identificador Único do Plano de Ação — Relaciona com planos_acao_faf.id_plano_acao';
comment on column planos_acao_destinacao_recursos_faf.dt_carga is 'Quando o registro apareceu pela primeira vez na base (não muda mais)';
comment on column planos_acao_destinacao_recursos_faf.id_execucao is 'Última execução (controle_execucao) que inseriu, alterou ou removeu o registro';

create table if not exists planos_acao_historico_faf (
    id_historico_plano_acao bigint,
    situacao_historico_plano_acao varchar(255),
    data_historico_plano_acao date,
    versao_historico_plano_acao bigint,
    id_plano_acao bigint,
    dt_carga timestamptz not null default now(),
    id_execucao bigint not null,
    dt_atualizacao timestamptz not null default now(),
    hash_registro char(32) not null,
    dt_remocao_origem timestamptz,
    primary key (id_historico_plano_acao)
);
create index if not exists ix_planos_acao_historico_faf_id_plano_acao on planos_acao_historico_faf (id_plano_acao);
comment on table planos_acao_historico_faf is 'Tabela que armazena o Histórico das Situações dos Planos de Ação FAF (endpoint /planos-acao-historico)';
comment on column planos_acao_historico_faf.id_historico_plano_acao is 'Identificador Único do Histórico do Plano de Ação';
comment on column planos_acao_historico_faf.situacao_historico_plano_acao is 'Situação do Histórico do Plano de Ação';
comment on column planos_acao_historico_faf.data_historico_plano_acao is 'Data do Registro no Histórico do Plano de Ação';
comment on column planos_acao_historico_faf.versao_historico_plano_acao is 'Versão do Histórico do Plano de Ação';
comment on column planos_acao_historico_faf.id_plano_acao is 'Identificador Único do Plano de Ação — Relaciona com planos_acao_faf.id_plano_acao';
comment on column planos_acao_historico_faf.dt_carga is 'Quando o registro apareceu pela primeira vez na base (não muda mais)';
comment on column planos_acao_historico_faf.id_execucao is 'Última execução (controle_execucao) que inseriu, alterou ou removeu o registro';

create table if not exists planos_acao_analises_faf (
    id_analise_plano_acao bigint,
    tipo_analise_plano_acao varchar(255),
    tipo_resultado_analise_plano_acao varchar(255),
    data_analise_plano_acao date,
    parecer_analise_plano_acao text,
    tipo_origem_analise_plano_acao varchar(255),
    id_plano_acao bigint,
    id_historico_plano_acao bigint,
    dt_carga timestamptz not null default now(),
    id_execucao bigint not null,
    dt_atualizacao timestamptz not null default now(),
    hash_registro char(32) not null,
    dt_remocao_origem timestamptz,
    primary key (id_analise_plano_acao)
);
create index if not exists ix_planos_acao_analises_faf_id_plano_acao on planos_acao_analises_faf (id_plano_acao);
create index if not exists ix_planos_acao_analises_faf_id_historico_plano_acao on planos_acao_analises_faf (id_historico_plano_acao);
comment on table planos_acao_analises_faf is 'Tabela que armazena as Análises dos Planos de Ação FAF (endpoint /planos-acao-analises)';
comment on column planos_acao_analises_faf.id_analise_plano_acao is 'Identificador Único da Análise do Plano de Ação';
comment on column planos_acao_analises_faf.tipo_analise_plano_acao is 'Tipo de Análise do Plano de Ação ("MERITO", "TECNICA", "FINANCEIRA", "TECNICA_FINANCEIRA")';
comment on column planos_acao_analises_faf.tipo_resultado_analise_plano_acao is 'Tipo de Resultado da Análise do Plano de Ação ("COMPLEMENTACAO", "APROVADO", "COM_RESSALVA", "REJEITADO")';
comment on column planos_acao_analises_faf.data_analise_plano_acao is 'Data da Análise do Plano de Ação';
comment on column planos_acao_analises_faf.parecer_analise_plano_acao is 'Parecer da Análise do Plano de Ação';
comment on column planos_acao_analises_faf.tipo_origem_analise_plano_acao is 'Tipo de Origem da Análise realizada no Plano de Ação';
comment on column planos_acao_analises_faf.id_plano_acao is 'Identificador Único do Plano de Ação — Relaciona com planos_acao_faf.id_plano_acao';
comment on column planos_acao_analises_faf.id_historico_plano_acao is 'Identificador Único do Histórico do Plano de Ação — Relaciona com planos_acao_historico_faf.id_historico_plano_acao';
comment on column planos_acao_analises_faf.dt_carga is 'Quando o registro apareceu pela primeira vez na base (não muda mais)';
comment on column planos_acao_analises_faf.id_execucao is 'Última execução (controle_execucao) que inseriu, alterou ou removeu o registro';

create table if not exists planos_acao_analises_responsaveis_faf (
    id_analise_responsavel_plano_acao bigint,
    nome_responsavel_analise_plano_acao varchar(255),
    cargo_responsavel_analise_plano_acao varchar(255),
    id_analise_plano_acao bigint,
    dt_carga timestamptz not null default now(),
    id_execucao bigint not null,
    dt_atualizacao timestamptz not null default now(),
    hash_registro char(32) not null,
    dt_remocao_origem timestamptz,
    primary key (id_analise_responsavel_plano_acao)
);
create index if not exists ix_planos_acao_analises_responsaveis_faf_id_analise_plano_acao on planos_acao_analises_responsaveis_faf (id_analise_plano_acao);
comment on table planos_acao_analises_responsaveis_faf is 'Tabela que armazena os Responsáveis pelas Análises dos Planos de Ação FAF (endpoint /planos-acao-analises-responsaveis)';
comment on column planos_acao_analises_responsaveis_faf.id_analise_responsavel_plano_acao is 'Identificador Único do Responsável pela Análise do Plano de Ação';
comment on column planos_acao_analises_responsaveis_faf.nome_responsavel_analise_plano_acao is 'Nome do Responsável pela Análise do Plano de Ação';
comment on column planos_acao_analises_responsaveis_faf.cargo_responsavel_analise_plano_acao is 'Cargo do Responsável pela Análise do Plano de Ação';
comment on column planos_acao_analises_responsaveis_faf.id_analise_plano_acao is 'Identificador Único da Análise do Plano de Ação — Relaciona com planos_acao_analises_faf.id_analise_plano_acao';
comment on column planos_acao_analises_responsaveis_faf.dt_carga is 'Quando o registro apareceu pela primeira vez na base (não muda mais)';
comment on column planos_acao_analises_responsaveis_faf.id_execucao is 'Última execução (controle_execucao) que inseriu, alterou ou removeu o registro';

create table if not exists termos_adesao_faf (
    id_termo_adesao bigint,
    numero_processo_termo_adesao varchar(255),
    situacao_termo_adesao varchar(255),
    objeto_termo_adesao text,
    data_assinatura_termo_adesao date,
    ano_termo_adesao bigint,
    secao_publicacao_dou_termo_adesao bigint,
    pagina_publicacao_dou_termo_adesao bigint,
    data_publicacao_dou_termo_adesao date,
    id_plano_acao bigint,
    dt_carga timestamptz not null default now(),
    id_execucao bigint not null,
    dt_atualizacao timestamptz not null default now(),
    hash_registro char(32) not null,
    dt_remocao_origem timestamptz,
    primary key (id_termo_adesao)
);
create index if not exists ix_termos_adesao_faf_id_plano_acao on termos_adesao_faf (id_plano_acao);
comment on table termos_adesao_faf is 'Tabela que armazena os Termos de Adesão FAF (endpoint /termos-adesao)';
comment on column termos_adesao_faf.id_termo_adesao is 'Identificador Único do Termo de Adesão';
comment on column termos_adesao_faf.numero_processo_termo_adesao is 'Número do Processo do Termo de Adesão';
comment on column termos_adesao_faf.situacao_termo_adesao is 'Situação do Termo de Adesão (Podendo ser: "Em Elaboração"; "Enviado para o Recebedor"; "Assinado")';
comment on column termos_adesao_faf.objeto_termo_adesao is 'Objeto do Termo de Adesão';
comment on column termos_adesao_faf.data_assinatura_termo_adesao is 'Data de Assinatura do Termo de Adesão';
comment on column termos_adesao_faf.ano_termo_adesao is 'Ano do Termo de Adesão';
comment on column termos_adesao_faf.secao_publicacao_dou_termo_adesao is 'Seção no DOU (Diário Oficial da União) do Termo de Adesão';
comment on column termos_adesao_faf.pagina_publicacao_dou_termo_adesao is 'Página no DOU (Diário Oficial da União) do Termo de Adesão';
comment on column termos_adesao_faf.data_publicacao_dou_termo_adesao is 'Data da Publicação no DOU (Diário Oficial da União) do Termo de Adesão';
comment on column termos_adesao_faf.id_plano_acao is 'Identificador Único do Plano de Ação — Relaciona com planos_acao_faf.id_plano_acao';
comment on column termos_adesao_faf.dt_carga is 'Quando o registro apareceu pela primeira vez na base (não muda mais)';
comment on column termos_adesao_faf.id_execucao is 'Última execução (controle_execucao) que inseriu, alterou ou removeu o registro';

create table if not exists termos_adesao_historico_faf (
    id_historico_termo_adesao bigint,
    situacao_historico_termo_adesao varchar(255),
    data_historico_termo_adesao date,
    id_termo_adesao bigint,
    dt_carga timestamptz not null default now(),
    id_execucao bigint not null,
    dt_atualizacao timestamptz not null default now(),
    hash_registro char(32) not null,
    dt_remocao_origem timestamptz,
    primary key (id_historico_termo_adesao)
);
create index if not exists ix_termos_adesao_historico_faf_id_termo_adesao on termos_adesao_historico_faf (id_termo_adesao);
comment on table termos_adesao_historico_faf is 'Tabela que armazena os Históricos dos Termos de Adesão FAF (endpoint /termos-adesao-historico)';
comment on column termos_adesao_historico_faf.id_historico_termo_adesao is 'Identificador Único do Histórico do Termo de Adesão';
comment on column termos_adesao_historico_faf.situacao_historico_termo_adesao is 'Situação do Histórico do Termo de Adesão';
comment on column termos_adesao_historico_faf.data_historico_termo_adesao is 'Data do Registro no Histórico do Termo de Adesão';
comment on column termos_adesao_historico_faf.id_termo_adesao is 'Identificador Único do Termo de Adesão — Relaciona com termos_adesao_faf.id_termo_adesao';
comment on column termos_adesao_historico_faf.dt_carga is 'Quando o registro apareceu pela primeira vez na base (não muda mais)';
comment on column termos_adesao_historico_faf.id_execucao is 'Última execução (controle_execucao) que inseriu, alterou ou removeu o registro';

create table if not exists empenhos_faf (
    id_empenho bigint,
    numero_empenho varchar(255),
    ano_empenho bigint,
    gestao_emitente_empenho varchar(30),
    ug_emitente_empenho bigint,
    data_emissao_empenho date,
    fonte_recurso_empenho varchar(30),
    esfera_orcamentaria_empenho bigint,
    descricao_esfera_orcamentaria_empenho varchar(255),
    plano_interno_empenho varchar(255),
    unidade_gestora_responsavel_empenho bigint,
    observacao_empenho varchar(255),
    cnpj_favorecido_empenho varchar(255),
    numero_lista_empenho varchar(255),
    unidade_gestora_referencia_empenho bigint,
    gestao_referencia_empenho varchar(30),
    numero_interno_empenho bigint,
    objeto_empenho varchar(255),
    numero_sistema_empenho varchar(255),
    natureza_despesa_empenho bigint,
    natureza_despesa_sub_item_empenho bigint,
    tipo_empenho bigint,
    descricao_tipo_empenho varchar(255),
    codigo_tipo_nota_empenho varchar(30),
    descricao_tipo_nota_empenho varchar(255),
    situacao_empenho bigint,
    descricao_situacao_empenho varchar(255),
    valor_empenho numeric(15,2),
    versao_empenho bigint,
    id_plano_acao bigint,
    dt_carga timestamptz not null default now(),
    id_execucao bigint not null,
    dt_atualizacao timestamptz not null default now(),
    hash_registro char(32) not null,
    dt_remocao_origem timestamptz,
    primary key (id_empenho)
);
create index if not exists ix_empenhos_faf_id_plano_acao on empenhos_faf (id_plano_acao);
comment on table empenhos_faf is 'Tabela que armazena os Dados dos Empenhos FAF (endpoint /empenhos)';
comment on column empenhos_faf.id_empenho is 'Identificador Único da Nota de Empenho';
comment on column empenhos_faf.numero_empenho is 'Número da Nota de Empenho gerada e enviada pelo SIAFI (Sistema Integrado de Administração Financeira)';
comment on column empenhos_faf.ano_empenho is 'Ano do Empenho';
comment on column empenhos_faf.gestao_emitente_empenho is 'Gestão Emitente no SIAFI';
comment on column empenhos_faf.ug_emitente_empenho is 'Unidade Gestora Emitente no SIAFI';
comment on column empenhos_faf.data_emissao_empenho is 'Data da Emissão da Nota de Empenho';
comment on column empenhos_faf.fonte_recurso_empenho is 'Fonte de Recurso da Nota de Empenho no SIAFI';
comment on column empenhos_faf.esfera_orcamentaria_empenho is 'Indicador da Esfera Orçamentária podendo assumir os seguintes valores: ("0", "1", "2", "3", "4" ou "5")';
comment on column empenhos_faf.descricao_esfera_orcamentaria_empenho is 'Descrição do Indicador da Esfera Orçamentária podendo assumir os seguintes valores: (0 - "Federal", 1 - "Estadual"; 2 - "Municipal"; 3 - "Estatal"; 4 - "Privada"; 5 - "Organismos Internacionais")';
comment on column empenhos_faf.plano_interno_empenho is 'Instrumento de planejamento e de acompanhamento da ação planejada, usado como forma de detalhamento desta, de uso exclusivo de cada Ministério/órgão, com as seguintes características: - Há um atributo na tabela de órgão para indicar se o órgão utiliza ou não o Plano Interno (PI). Este atributo é mantido pela STN decorrente da solicitação do órgão. - A unidade setorial de orçamento do órgão é responsável por registrar na tabela os códigos de PI. - O SIAFI (Sistema Integrado de Administração Financeira), de acordo com o cadastramento previsto acima, só aceitará a emissão de nota de empenho com o código de PI existente. - Os códigos de PI poderão ter até 11 (onze) posições alfa-numéricas';
comment on column empenhos_faf.unidade_gestora_responsavel_empenho is 'Unidade Gestora do Favorecido';
comment on column empenhos_faf.observacao_empenho is 'Observação referente a Nota de Empenho informada pelo usuário';
comment on column empenhos_faf.cnpj_favorecido_empenho is 'CNPJ do Favorecido';
comment on column empenhos_faf.numero_lista_empenho is 'Número da Lista gerado e enviado pelo SIAFI';
comment on column empenhos_faf.unidade_gestora_referencia_empenho is 'Unidade Gestora de referência no SIAFI';
comment on column empenhos_faf.gestao_referencia_empenho is 'Gestão de referência no SIAFI';
comment on column empenhos_faf.numero_interno_empenho is 'Número Interno Sequencial';
comment on column empenhos_faf.objeto_empenho is 'Objeto da Nota de Empenho informado pelo usuário';
comment on column empenhos_faf.numero_sistema_empenho is 'Campo preenchido com Nota de Sistema "NS" ou Nota de Lançamento "NL", pelo usuário, sobre Nota de Empenho registrada diretamente no SIAFI (Sistema Integrado de Administração Financeira)';
comment on column empenhos_faf.natureza_despesa_empenho is 'Identificador da tabela de Natureza Despesa, recuperado do SICONV';
comment on column empenhos_faf.natureza_despesa_sub_item_empenho is 'Identificador da tabela de Natureza Despesa Subitem, recuperado do SICONV';
comment on column empenhos_faf.tipo_empenho is 'Tipo de Empenho podendo assumir os valores: ("1", "3" ou "5")';
comment on column empenhos_faf.descricao_tipo_empenho is 'Descrição do Tipo de Empenho podendo assumir os valores: (1 - "Empenho Ordinário"; 3 - "Estimado"; 5 - "Global")';
comment on column empenhos_faf.codigo_tipo_nota_empenho is 'Código do Tipo da Nota de Empenho';
comment on column empenhos_faf.descricao_tipo_nota_empenho is 'Descrição do Tipo da Nota de Empenho';
comment on column empenhos_faf.situacao_empenho is 'Situação da Nota de Empenho, podendo assumir os valores: ("1", "4", "5" ou "6")';
comment on column empenhos_faf.descricao_situacao_empenho is 'Descrição da Situação da Nota de Empenho, podendo assumir os valores: (1 - "Minuta de Empenho"; 4 - "Enviado"; 5 - "Pendente"; 6 - "Registrado no SIAFI")';
comment on column empenhos_faf.valor_empenho is 'Valor Total da Nota de Empenho';
comment on column empenhos_faf.versao_empenho is 'Versão da Nota de Empenho';
comment on column empenhos_faf.id_plano_acao is 'Identificador Único do Plano de Ação — Relaciona com planos_acao_faf.id_plano_acao';
comment on column empenhos_faf.dt_carga is 'Quando o registro apareceu pela primeira vez na base (não muda mais)';
comment on column empenhos_faf.id_execucao is 'Última execução (controle_execucao) que inseriu, alterou ou removeu o registro';

create table if not exists gestao_financeira_lancamentos_faf (
    id_lancamento_gestao_financeira bigint,
    origem_solicitacao_gestao_financeira varchar(255),
    descricao_origem_solicitacao_gestao_financeira varchar(255),
    cnpj_ente_solicitante_gestao_financeira varchar(255),
    nome_ente_solicitante_gestao_financeira varchar(255),
    nome_personalizado_ente_solicitante_gestao_financeira varchar(255),
    codigo_programa_agil_ente_solicitante_gestao_financeira varchar(30),
    codigo_banco_gestao_financeira varchar(30),
    codigo_agencia_gestao_financeira varchar(30),
    dv_agencia_gestao_financeira varchar(255),
    codigo_conta_gestao_financeira varchar(30),
    dv_conta_gestao_financeira varchar(255),
    tipo_operacao_gestao_financeira varchar(255),
    descricao_tipo_operacao_gestao_financeira varchar(255),
    descricao_gestao_financeira varchar(255),
    data_lancamento_gestao_financeira date,
    data_evento_lancamento_gestao_financeira date,
    numero_ordem_gestao_financeira bigint,
    numero_referencia_unica_gestao_financeira varchar(255),
    tipo_favorecido_gestao_financeira bigint,
    descricao_tipo_favorecido_gestao_financeira varchar(255),
    doc_favorecido_gestao_financeira_mask varchar(255),
    nome_favorecido_gestao_financeira varchar(255),
    valor_lancamento_gestao_financeira numeric(15,2),
    codigo_categoria_despesa_lancamento_gestao_financeira bigint,
    caminho_categoria_despesa_lancamento_gestao_financeira varchar(255),
    quantidade_subtransacoes_lancamento_gestao_financeira bigint,
    id_agencia_conta varchar(255),
    dt_carga timestamptz not null default now(),
    id_execucao bigint not null,
    dt_atualizacao timestamptz not null default now(),
    hash_registro char(32) not null,
    dt_remocao_origem timestamptz,
    primary key (id_lancamento_gestao_financeira)
);
create index if not exists ix_gestao_financeira_lancamentos_faf_id_agencia_conta on gestao_financeira_lancamentos_faf (id_agencia_conta);
comment on table gestao_financeira_lancamentos_faf is 'Tabela que armazena os Lançamentos da Gestão Financeira FAF (endpoint /gestao-financeira-lancamentos)';
comment on column gestao_financeira_lancamentos_faf.id_lancamento_gestao_financeira is 'Identificador Único do Lançamento';
comment on column gestao_financeira_lancamentos_faf.origem_solicitacao_gestao_financeira is 'Origem da solicitação de abertura de contas';
comment on column gestao_financeira_lancamentos_faf.descricao_origem_solicitacao_gestao_financeira is 'Descrição da Origem da solicitação de abertura de contas';
comment on column gestao_financeira_lancamentos_faf.cnpj_ente_solicitante_gestao_financeira is 'CNPJ do Ente Solicitante da Conta Bancária';
comment on column gestao_financeira_lancamentos_faf.nome_ente_solicitante_gestao_financeira is 'Nome do Ente Solicitante da Conta Bancária';
comment on column gestao_financeira_lancamentos_faf.nome_personalizado_ente_solicitante_gestao_financeira is 'Nome Personalizado do Ente Solicitante da Conta Bancária';
comment on column gestao_financeira_lancamentos_faf.codigo_programa_agil_ente_solicitante_gestao_financeira is 'Código do Programa Ágil cadastrado no BB';
comment on column gestao_financeira_lancamentos_faf.codigo_banco_gestao_financeira is 'Código do Banco do Lançamento';
comment on column gestao_financeira_lancamentos_faf.codigo_agencia_gestao_financeira is 'Número da Agência Bancária do Lançamento';
comment on column gestao_financeira_lancamentos_faf.dv_agencia_gestao_financeira is 'Dígito Verificador (DV) da Agência Bancária do Lançamento';
comment on column gestao_financeira_lancamentos_faf.codigo_conta_gestao_financeira is 'Número da Conta Corrente do Lançamento';
comment on column gestao_financeira_lancamentos_faf.dv_conta_gestao_financeira is 'Dígito Verificador (DV) da Conta Corrente do Lançamento';
comment on column gestao_financeira_lancamentos_faf.tipo_operacao_gestao_financeira is 'Tipo da Operação ("D" ou "C")';
comment on column gestao_financeira_lancamentos_faf.descricao_tipo_operacao_gestao_financeira is 'Descrição do Tipo da Operação ("Débito" ou "Crédito")';
comment on column gestao_financeira_lancamentos_faf.descricao_gestao_financeira is 'Descrição do Lançamento';
comment on column gestao_financeira_lancamentos_faf.data_lancamento_gestao_financeira is 'Data do Lançamento';
comment on column gestao_financeira_lancamentos_faf.data_evento_lancamento_gestao_financeira is 'Data do Evento do Lançamento';
comment on column gestao_financeira_lancamentos_faf.numero_ordem_gestao_financeira is 'Número de Ordem do Lançamento';
comment on column gestao_financeira_lancamentos_faf.numero_referencia_unica_gestao_financeira is 'Número de Referência do Lançamento';
comment on column gestao_financeira_lancamentos_faf.tipo_favorecido_gestao_financeira is 'Tipo do Favorecido ("1", "2" ou "0")';
comment on column gestao_financeira_lancamentos_faf.descricao_tipo_favorecido_gestao_financeira is 'Descrição do Tipo do Favorecido (1 - "CPF", 2 - "CNPJ" ou 0 - "Não Identificado")';
comment on column gestao_financeira_lancamentos_faf.doc_favorecido_gestao_financeira_mask is 'Identificação Anonimizada do Favorecido do Lançamento';
comment on column gestao_financeira_lancamentos_faf.nome_favorecido_gestao_financeira is 'Nome do Favorecido do Lançamento';
comment on column gestao_financeira_lancamentos_faf.valor_lancamento_gestao_financeira is 'Valor do Lançamento';
comment on column gestao_financeira_lancamentos_faf.codigo_categoria_despesa_lancamento_gestao_financeira is 'Código da Categoria de Despesa do Lançamento';
comment on column gestao_financeira_lancamentos_faf.caminho_categoria_despesa_lancamento_gestao_financeira is 'Caminho Hierárquico da Categoria de Despesa do Lançamento (campo aninhado categorias_despesa_lancamento)';
comment on column gestao_financeira_lancamentos_faf.quantidade_subtransacoes_lancamento_gestao_financeira is 'Quantidade de Subtransações do Lançamento';
comment on column gestao_financeira_lancamentos_faf.id_agencia_conta is 'Identificador Único da Conta Bancária (Número da Agência Bancária seguida do Número da Conta Bancária) do Plano de Ação — Relaciona com gestao_financeira_saldo_conta_faf.id_agencia_conta';
comment on column gestao_financeira_lancamentos_faf.dt_carga is 'Quando o registro apareceu pela primeira vez na base (não muda mais)';
comment on column gestao_financeira_lancamentos_faf.id_execucao is 'Última execução (controle_execucao) que inseriu, alterou ou removeu o registro';

create table if not exists gestao_financeira_subtransacoes_faf (
    id_subtransacao_gestao_financeira varchar(255),
    estado_subtransacao_gestao_financeira bigint,
    situacao_pagamento_subtransacao_gestao_financeira bigint,
    descricao_situacao_pagamento_subtransacao_gestao_financeira varchar(255),
    data_pagamento_subtransacao_gestao_financeira date,
    tipo_pessoa_beneficiario_subtransacao_gestao_financeira bigint,
    descricao_tp_pessoa_beneficiario_subtransacao_gestao_financeira varchar(255),
    doc_beneficiario_subtransacao_gestao_financeira_mask varchar(255),
    nome_beneficiario_subtransacao_gestao_financeira varchar(255),
    descricao_subtransacao_gestao_financeira varchar(255),
    valor_subtransacao_gestao_financeira numeric(15,2),
    codigo_categoria_despesa_subtransacao_gestao_financeira bigint,
    caminho_categoria_despesa_subtransacao_gestao_financeira varchar(255),
    id_lancamento_gestao_financeira bigint,
    dt_carga timestamptz not null default now(),
    id_execucao bigint not null,
    dt_atualizacao timestamptz not null default now(),
    hash_registro char(32) not null,
    dt_remocao_origem timestamptz,
    primary key (id_subtransacao_gestao_financeira)
);
create index if not exists ix_gestao_financeira_subtransacoes_faf_id_lancamento_g_871c6ea7 on gestao_financeira_subtransacoes_faf (id_lancamento_gestao_financeira);
comment on table gestao_financeira_subtransacoes_faf is 'Tabela que armazena os dados das Subtransações dos Lançamentos da Gestão Financeira FAF (endpoint /gestao-financeira-subtransacoes)';
comment on column gestao_financeira_subtransacoes_faf.id_subtransacao_gestao_financeira is 'Identificador Único da Subtransação';
comment on column gestao_financeira_subtransacoes_faf.estado_subtransacao_gestao_financeira is 'Estado da Subtransação';
comment on column gestao_financeira_subtransacoes_faf.situacao_pagamento_subtransacao_gestao_financeira is 'Situação do Pagamento ("3" ou "6") da Subtransação';
comment on column gestao_financeira_subtransacoes_faf.descricao_situacao_pagamento_subtransacao_gestao_financeira is 'Descrição da Situação do Pagamento (3 - "Pago" ou 6 - "Cancelado") da Subtransação';
comment on column gestao_financeira_subtransacoes_faf.data_pagamento_subtransacao_gestao_financeira is 'Data do Pagamento da Subtransação';
comment on column gestao_financeira_subtransacoes_faf.tipo_pessoa_beneficiario_subtransacao_gestao_financeira is 'Tipo do Favorecido ("1", "2" ou "0") da Subtransação';
comment on column gestao_financeira_subtransacoes_faf.descricao_tp_pessoa_beneficiario_subtransacao_gestao_financeira is 'Descrição do Tipo do Favorecido (1 - "CPF", 2 - "CNPJ" ou 0 - "Não Identificado") da Subtransação';
comment on column gestao_financeira_subtransacoes_faf.doc_beneficiario_subtransacao_gestao_financeira_mask is 'Identificação Anonimizada do Favorecido da Subtransação';
comment on column gestao_financeira_subtransacoes_faf.nome_beneficiario_subtransacao_gestao_financeira is 'Nome do Favorecido da Subtransação';
comment on column gestao_financeira_subtransacoes_faf.descricao_subtransacao_gestao_financeira is 'Descrição da Subtransação';
comment on column gestao_financeira_subtransacoes_faf.valor_subtransacao_gestao_financeira is 'Valor da Subtransação';
comment on column gestao_financeira_subtransacoes_faf.codigo_categoria_despesa_subtransacao_gestao_financeira is 'Código da Categoria de Despesa da Subtransação';
comment on column gestao_financeira_subtransacoes_faf.caminho_categoria_despesa_subtransacao_gestao_financeira is 'Caminho Hierárquico da Categoria de Despesa da Subtransação (campo aninhado categorias_despesa_subtransacao)';
comment on column gestao_financeira_subtransacoes_faf.id_lancamento_gestao_financeira is 'Identificador Único do Lançamento — Relaciona com gestao_financeira_lancamentos_faf.id_lancamento_gestao_financeira';
comment on column gestao_financeira_subtransacoes_faf.dt_carga is 'Quando o registro apareceu pela primeira vez na base (não muda mais)';
comment on column gestao_financeira_subtransacoes_faf.id_execucao is 'Última execução (controle_execucao) que inseriu, alterou ou removeu o registro';

create table if not exists relatorios_gestao_faf (
    id_relatorio_gestao bigint,
    data_relatorio_gestao date,
    data_e_hora_relatorio_gestao timestamp,
    tipo_relatorio_gestao varchar(255),
    situacao_relatorio_gestao varchar(255),
    valor_executado_relatorio_gestao numeric(15,2),
    valor_pendente_relatorio_gestao numeric(15,2),
    resultados_alcancados_metas_relatorio_gestao text,
    descritivo_relatorio_gestao text,
    contrapartida_relatorio_gestao text,
    endereco_eletronico_publicidade_acoes_relatorio_gestao text,
    declaracao_conformidade_relatorio_gestao boolean,
    id_plano_acao bigint,
    dt_carga timestamptz not null default now(),
    id_execucao bigint not null,
    dt_atualizacao timestamptz not null default now(),
    hash_registro char(32) not null,
    dt_remocao_origem timestamptz,
    primary key (id_relatorio_gestao)
);
create index if not exists ix_relatorios_gestao_faf_id_plano_acao on relatorios_gestao_faf (id_plano_acao);
comment on table relatorios_gestao_faf is 'Tabela que armazena os dados dos Relatórios de Gestão FAF (endpoint /relatorios-gestao)';
comment on column relatorios_gestao_faf.id_relatorio_gestao is 'Identificador Único do Relatório de Gestão';
comment on column relatorios_gestao_faf.data_relatorio_gestao is 'Data do Envio do Relatório de Gestão';
comment on column relatorios_gestao_faf.data_e_hora_relatorio_gestao is 'Data e Hora do Envio do Relatório de Gestão';
comment on column relatorios_gestao_faf.tipo_relatorio_gestao is 'Tipo do Relatório de Gestão: ("PARCIAL" ou "FINAL")';
comment on column relatorios_gestao_faf.situacao_relatorio_gestao is 'Situação do Relatório de Gestão: ("EM_ELABORACAO", "ENVIADO_ANALISE_CONSELHO", "ENVIADO_ANALISE", "EM_COMPLEMENTACAO", "ANALISE_CONCLUIDA_CONSELHO", "ANALISE_CONCLUIDA" ou "REJEITADO")';
comment on column relatorios_gestao_faf.valor_executado_relatorio_gestao is 'Valor Repassado do Relatório de Gestão';
comment on column relatorios_gestao_faf.valor_pendente_relatorio_gestao is 'Valor Pendente do Relatório de Gestão';
comment on column relatorios_gestao_faf.resultados_alcancados_metas_relatorio_gestao is 'Resultados Alcançados das Metas do Relatório de Gestão';
comment on column relatorios_gestao_faf.descritivo_relatorio_gestao is 'Descritivo do Parecer do Relatório de Gestão';
comment on column relatorios_gestao_faf.contrapartida_relatorio_gestao is 'Contrapartida do Relatório de Gestão';
comment on column relatorios_gestao_faf.endereco_eletronico_publicidade_acoes_relatorio_gestao is 'URL de Publicidade das Ações Pactuadas no Relatório de Gestão';
comment on column relatorios_gestao_faf.declaracao_conformidade_relatorio_gestao is 'Indicador da Declaração de Conformidade do Relatório de Gestão';
comment on column relatorios_gestao_faf.id_plano_acao is 'Identificador Único do Plano de Ação — Relaciona com planos_acao_faf.id_plano_acao';
comment on column relatorios_gestao_faf.dt_carga is 'Quando o registro apareceu pela primeira vez na base (não muda mais)';
comment on column relatorios_gestao_faf.id_execucao is 'Última execução (controle_execucao) que inseriu, alterou ou removeu o registro';

create table if not exists relatorios_gestao_acoes_faf (
    id_acao_relatorio_gestao bigint,
    percentual_execucao_fisica_acao_relatorio_gestao_acao numeric(15,2),
    observacoes_justificativas_relatorio_gestao_acao text,
    id_relatorio_gestao bigint,
    id_acao_meta_plano_acao bigint,
    dt_carga timestamptz not null default now(),
    id_execucao bigint not null,
    dt_atualizacao timestamptz not null default now(),
    hash_registro char(32) not null,
    dt_remocao_origem timestamptz,
    primary key (id_acao_relatorio_gestao)
);
create index if not exists ix_relatorios_gestao_acoes_faf_id_relatorio_gestao on relatorios_gestao_acoes_faf (id_relatorio_gestao);
create index if not exists ix_relatorios_gestao_acoes_faf_id_acao_meta_plano_acao on relatorios_gestao_acoes_faf (id_acao_meta_plano_acao);
comment on table relatorios_gestao_acoes_faf is 'Tabela que armazena os dados das Ações dos Relatórios de Gestão FAF (endpoint /relatorios-gestao-acoes)';
comment on column relatorios_gestao_acoes_faf.id_acao_relatorio_gestao is 'Identificador Único da Ação associada ao Relatório de Gestão';
comment on column relatorios_gestao_acoes_faf.percentual_execucao_fisica_acao_relatorio_gestao_acao is 'Percentual de Conclusão da Ação do Relatório de Gestão';
comment on column relatorios_gestao_acoes_faf.observacoes_justificativas_relatorio_gestao_acao is 'Justificativa referente ao Percentual de Conclusão da Ação do Relatório de Gestão';
comment on column relatorios_gestao_acoes_faf.id_relatorio_gestao is 'Identificador Único do Relatório de Gestão — Relaciona com relatorios_gestao_faf.id_relatorio_gestao';
comment on column relatorios_gestao_acoes_faf.id_acao_meta_plano_acao is 'Identificador Único da Ação da Meta do Plano de Ação — Relaciona com planos_acao_metas_acoes_faf.id_acao_meta_plano_acao';
comment on column relatorios_gestao_acoes_faf.dt_carga is 'Quando o registro apareceu pela primeira vez na base (não muda mais)';
comment on column relatorios_gestao_acoes_faf.id_execucao is 'Última execução (controle_execucao) que inseriu, alterou ou removeu o registro';

create table if not exists relatorios_gestao_analises_faf (
    id_relatorio_gestao_analise bigint,
    tipo_analise_relatorio_gestao_analise varchar(255),
    resultado_analise_relatorio_gestao_analise varchar(255),
    parecer_analise_relatorio_gestao_analise text,
    origem_analise_relatorio_gestao_analise varchar(255),
    data_analise_relatorio_gestao_analise date,
    versao_analise_relatorio_gestao_analise bigint,
    id_relatorio_gestao bigint,
    dt_carga timestamptz not null default now(),
    id_execucao bigint not null,
    dt_atualizacao timestamptz not null default now(),
    hash_registro char(32) not null,
    dt_remocao_origem timestamptz,
    primary key (id_relatorio_gestao_analise)
);
create index if not exists ix_relatorios_gestao_analises_faf_id_relatorio_gestao on relatorios_gestao_analises_faf (id_relatorio_gestao);
comment on table relatorios_gestao_analises_faf is 'Tabela que armazena os dados das Análises dos Relatórios de Gestão FAF (endpoint /relatorios-gestao-analises)';
comment on column relatorios_gestao_analises_faf.id_relatorio_gestao_analise is 'Identificador Único da Análise do Relatório de Gestão';
comment on column relatorios_gestao_analises_faf.tipo_analise_relatorio_gestao_analise is 'Tipo de Análise realizada no Relatório de Gestão';
comment on column relatorios_gestao_analises_faf.resultado_analise_relatorio_gestao_analise is 'Tipo do Resultado da Análise do Relatório de Gestão';
comment on column relatorios_gestao_analises_faf.parecer_analise_relatorio_gestao_analise is 'Parecer da Análise do Relatório de Gestão';
comment on column relatorios_gestao_analises_faf.origem_analise_relatorio_gestao_analise is 'Tipo de Origem da Análise realizada no Relatório de Gestão';
comment on column relatorios_gestao_analises_faf.data_analise_relatorio_gestao_analise is 'Data de Realização da Análise no Relatório de Gestão';
comment on column relatorios_gestao_analises_faf.versao_analise_relatorio_gestao_analise is 'Versão da Análise do Relatório de Gestão';
comment on column relatorios_gestao_analises_faf.id_relatorio_gestao is 'Identificador Único do Relatório de Gestão — Relaciona com relatorios_gestao_faf.id_relatorio_gestao';
comment on column relatorios_gestao_analises_faf.dt_carga is 'Quando o registro apareceu pela primeira vez na base (não muda mais)';
comment on column relatorios_gestao_analises_faf.id_execucao is 'Última execução (controle_execucao) que inseriu, alterou ou removeu o registro';

create table if not exists relatorios_gestao_analises_responsaveis_faf (
    id_relatorio_gestao_analise_responsavel bigint,
    nome_responsavel_analise_relatorio_gestao_analise varchar(255),
    cargo_responsavel_analise_relatorio_gestao_analise varchar(255),
    id_relatorio_gestao_analise bigint,
    dt_carga timestamptz not null default now(),
    id_execucao bigint not null,
    dt_atualizacao timestamptz not null default now(),
    hash_registro char(32) not null,
    dt_remocao_origem timestamptz,
    primary key (id_relatorio_gestao_analise_responsavel)
);
create index if not exists ix_relatorios_gestao_analises_responsaveis_faf_id_rela_fff5447a on relatorios_gestao_analises_responsaveis_faf (id_relatorio_gestao_analise);
comment on table relatorios_gestao_analises_responsaveis_faf is 'Tabela que armazena os dados dos Responsáveis pelas Análises dos Relatórios de Gestão FAF (endpoint /relatorios-gestao-analises-responsaveis)';
comment on column relatorios_gestao_analises_responsaveis_faf.id_relatorio_gestao_analise_responsavel is 'Identificador Único do Responsável pela Análise do Relatório de Gestão';
comment on column relatorios_gestao_analises_responsaveis_faf.nome_responsavel_analise_relatorio_gestao_analise is 'Nome do Responsável pela Análise do Relatório de Gestão';
comment on column relatorios_gestao_analises_responsaveis_faf.cargo_responsavel_analise_relatorio_gestao_analise is 'Cargo do Responsável pela Análise do Relatório de Gestão';
comment on column relatorios_gestao_analises_responsaveis_faf.id_relatorio_gestao_analise is 'Identificador Único da Análise do Relatório de Gestão — Relaciona com relatorios_gestao_analises_faf.id_relatorio_gestao_analise';
comment on column relatorios_gestao_analises_responsaveis_faf.dt_carga is 'Quando o registro apareceu pela primeira vez na base (não muda mais)';
comment on column relatorios_gestao_analises_responsaveis_faf.id_execucao is 'Última execução (controle_execucao) que inseriu, alterou ou removeu o registro';

create table if not exists programas_natureza_despesa_faf (
    id_programa bigint,
    grupo_natureza_despesa_programa varchar(15),
    dt_carga timestamptz not null default now(),
    id_execucao bigint not null,
    dt_atualizacao timestamptz not null default now(),
    hash_registro char(32) not null,
    dt_remocao_origem timestamptz,
    primary key (id_programa, grupo_natureza_despesa_programa)
);
comment on table programas_natureza_despesa_faf is 'Naturezas de Despesa dos Programas FAF (derivada da lista programa_natureza_despesa de /programas)';
comment on column programas_natureza_despesa_faf.id_programa is 'Identificador Único do Programa — Relaciona com programas_faf.id_programa';
comment on column programas_natureza_despesa_faf.grupo_natureza_despesa_programa is 'Grupo Natureza de Despesa do Programa';
comment on column programas_natureza_despesa_faf.dt_carga is 'Quando o registro apareceu pela primeira vez na base (não muda mais)';
comment on column programas_natureza_despesa_faf.id_execucao is 'Última execução (controle_execucao) que inseriu, alterou ou removeu o registro';

create table if not exists programas_acao_orcamentaria_faf (
    id_programa bigint,
    codigo_acao_orcamentaria_programa varchar(20),
    descricao_acao_orcamentaria_programa varchar(180),
    dt_carga timestamptz not null default now(),
    id_execucao bigint not null,
    dt_atualizacao timestamptz not null default now(),
    hash_registro char(32) not null,
    dt_remocao_origem timestamptz,
    primary key (id_programa, codigo_acao_orcamentaria_programa)
);
comment on table programas_acao_orcamentaria_faf is 'Ações Orçamentárias dos Programas FAF (derivada da lista programa_acao_orcamentaria de /programas)';
comment on column programas_acao_orcamentaria_faf.id_programa is 'Identificador Único do Programa — Relaciona com programas_faf.id_programa';
comment on column programas_acao_orcamentaria_faf.codigo_acao_orcamentaria_programa is 'Código da Ação Orçamentária do Programa';
comment on column programas_acao_orcamentaria_faf.descricao_acao_orcamentaria_programa is 'Descrição da Ação Orçamentária do Programa';
comment on column programas_acao_orcamentaria_faf.dt_carga is 'Quando o registro apareceu pela primeira vez na base (não muda mais)';
comment on column programas_acao_orcamentaria_faf.id_execucao is 'Última execução (controle_execucao) que inseriu, alterou ou removeu o registro';

create table if not exists gestao_financeira_saldo_conta_faf (
    id_agencia_conta varchar(20),
    saldo_final_gestao_financeira numeric(15,2),
    dt_carga timestamptz not null default now(),
    id_execucao bigint not null,
    dt_atualizacao timestamptz not null default now(),
    hash_registro char(32) not null,
    dt_remocao_origem timestamptz,
    primary key (id_agencia_conta)
);
comment on table gestao_financeira_saldo_conta_faf is 'Saldos em Conta dos Planos de Ação FAF (derivada de saldo_final_dado_bancario de /planos-acao-dados-bancarios, um registro por id_agencia_conta)';
comment on column gestao_financeira_saldo_conta_faf.id_agencia_conta is 'Identificador Único da Conta Bancária (Número da Agência Bancária seguida do Número da Conta Bancária) do Plano de Ação';
comment on column gestao_financeira_saldo_conta_faf.saldo_final_gestao_financeira is 'Saldo Final da Conta Bancária';
comment on column gestao_financeira_saldo_conta_faf.dt_carga is 'Quando o registro apareceu pela primeira vez na base (não muda mais)';
comment on column gestao_financeira_saldo_conta_faf.id_execucao is 'Última execução (controle_execucao) que inseriu, alterou ou removeu o registro';

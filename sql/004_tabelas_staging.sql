-- Gerado por scripts/gerar_ddl.py — não editar à mão.
-- Staging: cópia bruta do último download, mesmos nomes das tabelas finais (esquema próprio).
set search_path to stg_transferencias_fundo_fundo;

create unlogged table if not exists programas_faf (
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
    data_fim_recebimento_planos_acao_beneficiarios_voluntarios date
);

create unlogged table if not exists programas_beneficiarios_faf (
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
    id_programa bigint
);

create unlogged table if not exists programas_ageis_faf (
    id_programa_agil bigint,
    id_programa_agil_bb bigint,
    nome_programa_agil varchar(255),
    codigo_programa_agil varchar(30),
    id_orgao_programa_agil bigint,
    codigo_siorg_orgao_programa_agil bigint,
    sigla_orgao_programa_agil varchar(255),
    cnpj_orgao_programa_agil varchar(255),
    nome_orgao_programa_agil varchar(255),
    id_programa bigint
);

create unlogged table if not exists planos_acao_faf (
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
    id_programa bigint
);

create unlogged table if not exists planos_acao_dados_bancarios_faf (
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
    id_plano_acao bigint
);

create unlogged table if not exists planos_acao_metas_faf (
    id_meta_plano_acao bigint,
    numero_meta_plano_acao varchar(255),
    nome_meta_plano_acao varchar(255),
    descricao_meta_plano_acao text,
    valor_meta_plano_acao numeric(15,2),
    versao_meta_plano_acao bigint,
    sequencial_meta_plano_acao bigint,
    id_plano_acao bigint
);

create unlogged table if not exists planos_acao_metas_acoes_faf (
    id_acao_meta_plano_acao bigint,
    numero_acao_meta_plano_acao varchar(255),
    nome_acao_meta_plano_acao varchar(255),
    descricao_acao_meta_plano_acao text,
    valor_acao_meta_plano_acao numeric(15,2),
    versao_acao_meta_plano_acao bigint,
    sequencial_acao_meta_plano_acao bigint,
    id_meta_plano_acao bigint
);

create unlogged table if not exists planos_acao_destinacao_recursos_faf (
    id_destinacao_recursos_plano_acao bigint,
    codigo_natureza_despesa_destinacao_recursos_plano_acao bigint,
    descricao_natureza_despesa_destinacao_recursos_plano_acao varchar(255),
    tipo_despesa_destinacao_recursos_plano_acao varchar(255),
    valor_destinacao_recursos_plano_acao numeric(15,2),
    id_plano_acao bigint
);

create unlogged table if not exists planos_acao_historico_faf (
    id_historico_plano_acao bigint,
    situacao_historico_plano_acao varchar(255),
    data_historico_plano_acao date,
    versao_historico_plano_acao bigint,
    id_plano_acao bigint
);

create unlogged table if not exists planos_acao_analises_faf (
    id_analise_plano_acao bigint,
    tipo_analise_plano_acao varchar(255),
    tipo_resultado_analise_plano_acao varchar(255),
    data_analise_plano_acao date,
    parecer_analise_plano_acao text,
    tipo_origem_analise_plano_acao varchar(255),
    id_plano_acao bigint,
    id_historico_plano_acao bigint
);

create unlogged table if not exists planos_acao_analises_responsaveis_faf (
    id_analise_responsavel_plano_acao bigint,
    nome_responsavel_analise_plano_acao varchar(255),
    cargo_responsavel_analise_plano_acao varchar(255),
    id_analise_plano_acao bigint
);

create unlogged table if not exists termos_adesao_faf (
    id_termo_adesao bigint,
    numero_processo_termo_adesao varchar(255),
    situacao_termo_adesao varchar(255),
    objeto_termo_adesao text,
    data_assinatura_termo_adesao date,
    ano_termo_adesao bigint,
    secao_publicacao_dou_termo_adesao bigint,
    pagina_publicacao_dou_termo_adesao bigint,
    data_publicacao_dou_termo_adesao date,
    id_plano_acao bigint
);

create unlogged table if not exists termos_adesao_historico_faf (
    id_historico_termo_adesao bigint,
    situacao_historico_termo_adesao varchar(255),
    data_historico_termo_adesao date,
    id_termo_adesao bigint
);

create unlogged table if not exists empenhos_faf (
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
    id_plano_acao bigint
);

create unlogged table if not exists gestao_financeira_lancamentos_faf (
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
    id_agencia_conta varchar(255)
);

create unlogged table if not exists gestao_financeira_subtransacoes_faf (
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
    id_lancamento_gestao_financeira bigint
);

create unlogged table if not exists relatorios_gestao_faf (
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
    id_plano_acao bigint
);

create unlogged table if not exists relatorios_gestao_acoes_faf (
    id_acao_relatorio_gestao bigint,
    percentual_execucao_fisica_acao_relatorio_gestao_acao numeric(15,2),
    observacoes_justificativas_relatorio_gestao_acao text,
    id_relatorio_gestao bigint,
    id_acao_meta_plano_acao bigint
);

create unlogged table if not exists relatorios_gestao_analises_faf (
    id_relatorio_gestao_analise bigint,
    tipo_analise_relatorio_gestao_analise varchar(255),
    resultado_analise_relatorio_gestao_analise varchar(255),
    parecer_analise_relatorio_gestao_analise text,
    origem_analise_relatorio_gestao_analise varchar(255),
    data_analise_relatorio_gestao_analise date,
    versao_analise_relatorio_gestao_analise bigint,
    id_relatorio_gestao bigint
);

create unlogged table if not exists relatorios_gestao_analises_responsaveis_faf (
    id_relatorio_gestao_analise_responsavel bigint,
    nome_responsavel_analise_relatorio_gestao_analise varchar(255),
    cargo_responsavel_analise_relatorio_gestao_analise varchar(255),
    id_relatorio_gestao_analise bigint
);

create unlogged table if not exists programas_natureza_despesa_faf (
    id_programa bigint,
    grupo_natureza_despesa_programa varchar(15)
);

create unlogged table if not exists programas_acao_orcamentaria_faf (
    id_programa bigint,
    codigo_acao_orcamentaria_programa varchar(20),
    descricao_acao_orcamentaria_programa varchar(180)
);

create unlogged table if not exists gestao_financeira_saldo_conta_faf (
    id_agencia_conta varchar(20),
    saldo_final_gestao_financeira numeric(15,2)
);

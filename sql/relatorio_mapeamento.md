# Relatório de mapeamento API × modelo

Gerado por `scripts/gerar_ddl.py`. Para revisão humana.

Tabelas de dados: **23** · colunas (sem as técnicas): **278**

## Campos da API sem coluna correspondente no modelo
Tipo e tamanho vêm só do OpenAPI (`varchar(255)` quando string); descrição vem do parâmetro de filtro.

- (nenhum)

## Tipos divergentes (API × modelo) — prevaleceu a API

- `programas_ageis_faf.codigo_programa_agil`: API string × modelo int8 → `varchar(30)`
- `planos_acao_faf.codigo_ibge_municipio_ente_repassador_plano_acao`: API integer × modelo varchar → `bigint`
- `planos_acao_dados_bancarios_faf.codigo_banco_plano_acao_dado_bancario`: API string × modelo int8 → `varchar(30)`
- `planos_acao_dados_bancarios_faf.numero_agencia_plano_acao_dado_bancario`: API string × modelo int8 → `varchar(30)`
- `planos_acao_dados_bancarios_faf.numero_conta_plano_acao_dado_bancario`: API string × modelo int8 → `varchar(30)`
- `empenhos_faf.gestao_emitente_empenho`: API string × modelo int8 → `varchar(30)`
- `empenhos_faf.fonte_recurso_empenho`: API string × modelo int8 → `varchar(30)`
- `empenhos_faf.gestao_referencia_empenho`: API string × modelo int8 → `varchar(30)`
- `empenhos_faf.codigo_tipo_nota_empenho`: API string × modelo int8 → `varchar(30)`
- `gestao_financeira_lancamentos_faf.codigo_programa_agil_ente_solicitante_gestao_financeira`: API string × modelo int8 → `varchar(30)`
- `gestao_financeira_lancamentos_faf.codigo_banco_gestao_financeira`: API string × modelo int8 → `varchar(30)`
- `gestao_financeira_lancamentos_faf.codigo_agencia_gestao_financeira`: API string × modelo int8 → `varchar(30)`
- `gestao_financeira_lancamentos_faf.codigo_conta_gestao_financeira`: API string × modelo int8 → `varchar(30)`

## Varchar alargados (modelo muito justo; piso 255, 255 para nomes/municípios)

- `programas_faf.modalidade_programa`: 15 → `varchar(255)`
- `programas_faf.nome_programa`: 190 → `varchar(255)`
- `programas_faf.nome_institucional_programa`: 190 → `varchar(255)`
- `programas_faf.situacao_programa`: 20 → `varchar(255)`
- `programas_faf.sigla_orgao_superior_programa`: 10 → `varchar(255)`
- `programas_faf.cnpj_orgao_superior_programa`: 15 → `varchar(255)`
- `programas_faf.nome_orgao_superior_programa`: 45 → `varchar(255)`
- `programas_faf.cnpj_fundo_programa`: 15 → `varchar(255)`
- `programas_faf.nome_fundo_programa`: 40 → `varchar(255)`
- `programas_faf.uf_fundo_programa`: 5 → `varchar(255)`
- `programas_faf.municipio_fundo_programa`: 10 → `varchar(255)`
- `programas_beneficiarios_faf.cnpj_beneficiario_programa`: 15 → `varchar(255)`
- `programas_beneficiarios_faf.nome_beneficiario_programa`: 90 → `varchar(255)`
- `programas_beneficiarios_faf.numero_emenda_beneficiario_programa`: 15 → `varchar(255)`
- `programas_beneficiarios_faf.nome_parlamentar_beneficiario_programa`: 30 → `varchar(255)`
- `programas_beneficiarios_faf.tipo_beneficiario_programa`: 20 → `varchar(255)`
- `programas_beneficiarios_faf.nome_ente_beneficiario_programa`: 90 → `varchar(255)`
- `programas_beneficiarios_faf.uf_ente_beneficiario_programa`: 5 → `varchar(255)`
- `programas_beneficiarios_faf.nome_municipio_ente_beneficiario_programa`: 35 → `varchar(255)`
- `programas_ageis_faf.nome_programa_agil`: 25 → `varchar(255)`
- `programas_ageis_faf.sigla_orgao_programa_agil`: 10 → `varchar(255)`
- `programas_ageis_faf.cnpj_orgao_programa_agil`: 15 → `varchar(255)`
- `programas_ageis_faf.nome_orgao_programa_agil`: 45 → `varchar(255)`
- `planos_acao_faf.codigo_plano_acao`: 25 → `varchar(255)`
- `planos_acao_faf.situacao_plano_acao`: 35 → `varchar(255)`
- `planos_acao_faf.sigla_orgao_repassador_plano_acao`: 10 → `varchar(255)`
- `planos_acao_faf.cnpj_orgao_repassador_plano_acao`: 15 → `varchar(255)`
- `planos_acao_faf.nome_orgao_repassador_plano_acao`: 50 → `varchar(255)`
- `planos_acao_faf.cnpj_ente_repassador_plano_acao`: 5 → `varchar(255)`
- `planos_acao_faf.nome_ente_repassador_plano_acao`: 5 → `varchar(255)`
- `planos_acao_faf.uf_ente_repassador_plano_acao`: 5 → `varchar(255)`
- `planos_acao_faf.nome_municipio_ente_repassador_plano_acao`: 5 → `varchar(255)`
- `planos_acao_faf.cnpj_ente_recebedor_plano_acao`: 15 → `varchar(255)`
- `planos_acao_faf.nome_ente_recebedor_plano_acao`: 90 → `varchar(255)`
- `planos_acao_faf.uf_ente_recebedor_plano_acao`: 5 → `varchar(255)`
- `planos_acao_faf.nome_municipio_ente_recebedor_plano_acao`: 35 → `varchar(255)`
- `planos_acao_faf.tipo_unidade_recebedora_plano_acao`: 5 → `varchar(255)`
- `planos_acao_faf.descricao_tipo_unidade_ente_plano_acao`: 25 → `varchar(255)`
- `planos_acao_faf.cnpj_fundo_repassador_plano_acao`: 15 → `varchar(255)`
- `planos_acao_faf.nome_fundo_repassador_plano_acao`: 40 → `varchar(255)`
- `planos_acao_faf.uf_fundo_repassador_plano_acao`: 5 → `varchar(255)`
- `planos_acao_faf.municipio_fundo_repassador_plano_acao`: 10 → `varchar(255)`
- `planos_acao_faf.cnpj_fundo_vinculado_plano_acao`: 15 → `varchar(255)`
- `planos_acao_faf.nome_fundo_vinculado_plano_acao`: 130 → `varchar(255)`
- `planos_acao_faf.uf_fundo_vinculado_plano_acao`: 5 → `varchar(255)`
- `planos_acao_faf.municipio_fundo_vinculado_plano_acao`: 30 → `varchar(255)`
- `planos_acao_faf.tipo_unidade_recebedora_vinculada_plano_acao`: 5 → `varchar(255)`
- `planos_acao_faf.descricao_tipo_unidade_recebedora_vinculada_plano_acao`: 25 → `varchar(255)`
- `planos_acao_dados_bancarios_faf.id_agencia_conta`: 15 → `varchar(255)`
- `planos_acao_dados_bancarios_faf.nome_banco_plano_acao_dado_bancario`: 15 → `varchar(255)`
- `planos_acao_dados_bancarios_faf.dv_agencia_plano_acao_dado_bancario`: 5 → `varchar(255)`
- `planos_acao_dados_bancarios_faf.dv_conta_plano_acao_dado_bancario`: 5 → `varchar(255)`
- `planos_acao_dados_bancarios_faf.situacao_conta_plano_acao_dado_bancario`: 50 → `varchar(255)`
- `planos_acao_dados_bancarios_faf.nome_programa_agil_conta_plano_acao_dado_bancario`: 25 → `varchar(255)`
- `planos_acao_metas_faf.numero_meta_plano_acao`: 5 → `varchar(255)`
- `planos_acao_metas_acoes_faf.numero_acao_meta_plano_acao`: 10 → `varchar(255)`
- `planos_acao_destinacao_recursos_faf.descricao_natureza_despesa_destinacao_recursos_plano_acao`: 70 → `varchar(255)`
- `planos_acao_destinacao_recursos_faf.tipo_despesa_destinacao_recursos_plano_acao`: 15 → `varchar(255)`
- `planos_acao_historico_faf.situacao_historico_plano_acao`: 45 → `varchar(255)`
- `planos_acao_analises_faf.tipo_analise_plano_acao`: 20 → `varchar(255)`
- `planos_acao_analises_faf.tipo_resultado_analise_plano_acao`: 15 → `varchar(255)`
- `planos_acao_analises_faf.tipo_origem_analise_plano_acao`: 10 → `varchar(255)`
- `planos_acao_analises_responsaveis_faf.nome_responsavel_analise_plano_acao`: 50 → `varchar(255)`
- `planos_acao_analises_responsaveis_faf.cargo_responsavel_analise_plano_acao`: 105 → `varchar(255)`
- `termos_adesao_faf.situacao_termo_adesao`: 15 → `varchar(255)`
- `termos_adesao_historico_faf.situacao_historico_termo_adesao`: 15 → `varchar(255)`
- `empenhos_faf.numero_empenho`: 15 → `varchar(255)`
- `empenhos_faf.descricao_esfera_orcamentaria_empenho`: 10 → `varchar(255)`
- `empenhos_faf.plano_interno_empenho`: 15 → `varchar(255)`
- `empenhos_faf.observacao_empenho`: 225 → `varchar(255)`
- `empenhos_faf.cnpj_favorecido_empenho`: 15 → `varchar(255)`
- `empenhos_faf.numero_lista_empenho`: 15 → `varchar(255)`
- `empenhos_faf.objeto_empenho`: 130 → `varchar(255)`
- `empenhos_faf.numero_sistema_empenho`: 15 → `varchar(255)`
- `empenhos_faf.descricao_tipo_empenho`: 20 → `varchar(255)`
- `empenhos_faf.descricao_tipo_nota_empenho`: 20 → `varchar(255)`
- `empenhos_faf.descricao_situacao_empenho`: 20 → `varchar(255)`
- `gestao_financeira_lancamentos_faf.origem_solicitacao_gestao_financeira`: 5 → `varchar(255)`
- `gestao_financeira_lancamentos_faf.descricao_origem_solicitacao_gestao_financeira`: 30 → `varchar(255)`
- `gestao_financeira_lancamentos_faf.cnpj_ente_solicitante_gestao_financeira`: 15 → `varchar(255)`
- `gestao_financeira_lancamentos_faf.nome_ente_solicitante_gestao_financeira`: 130 → `varchar(255)`
- `gestao_financeira_lancamentos_faf.nome_personalizado_ente_solicitante_gestao_financeira`: 145 → `varchar(255)`
- `gestao_financeira_lancamentos_faf.dv_agencia_gestao_financeira`: 5 → `varchar(255)`
- `gestao_financeira_lancamentos_faf.dv_conta_gestao_financeira`: 5 → `varchar(255)`
- `gestao_financeira_lancamentos_faf.tipo_operacao_gestao_financeira`: 5 → `varchar(255)`
- `gestao_financeira_lancamentos_faf.descricao_tipo_operacao_gestao_financeira`: 10 → `varchar(255)`
- `gestao_financeira_lancamentos_faf.descricao_gestao_financeira`: 30 → `varchar(255)`
- `gestao_financeira_lancamentos_faf.numero_referencia_unica_gestao_financeira`: 15 → `varchar(255)`
- `gestao_financeira_lancamentos_faf.descricao_tipo_favorecido_gestao_financeira`: 20 → `varchar(255)`
- `gestao_financeira_lancamentos_faf.doc_favorecido_gestao_financeira_mask`: 15 → `varchar(255)`
- `gestao_financeira_lancamentos_faf.nome_favorecido_gestao_financeira`: 65 → `varchar(255)`
- `gestao_financeira_lancamentos_faf.id_agencia_conta`: 15 → `varchar(255)`
- `gestao_financeira_subtransacoes_faf.id_subtransacao_gestao_financeira`: 15 → `varchar(255)`
- `gestao_financeira_subtransacoes_faf.descricao_situacao_pagamento_subtransacao_gestao_financeira`: 10 → `varchar(255)`
- `gestao_financeira_subtransacoes_faf.descricao_tp_pessoa_beneficiario_subtransacao_gestao_financeira`: 20 → `varchar(255)`
- `gestao_financeira_subtransacoes_faf.doc_beneficiario_subtransacao_gestao_financeira_mask`: 15 → `varchar(255)`
- `gestao_financeira_subtransacoes_faf.nome_beneficiario_subtransacao_gestao_financeira`: 65 → `varchar(255)`
- `gestao_financeira_subtransacoes_faf.descricao_subtransacao_gestao_financeira`: 20 → `varchar(255)`
- `relatorios_gestao_faf.tipo_relatorio_gestao`: 10 → `varchar(255)`
- `relatorios_gestao_faf.situacao_relatorio_gestao`: 25 → `varchar(255)`
- `relatorios_gestao_analises_faf.tipo_analise_relatorio_gestao_analise`: 20 → `varchar(255)`
- `relatorios_gestao_analises_faf.resultado_analise_relatorio_gestao_analise`: 15 → `varchar(255)`
- `relatorios_gestao_analises_faf.origem_analise_relatorio_gestao_analise`: 10 → `varchar(255)`
- `relatorios_gestao_analises_responsaveis_faf.nome_responsavel_analise_relatorio_gestao_analise`: 50 → `varchar(255)`
- `relatorios_gestao_analises_responsaveis_faf.cargo_responsavel_analise_relatorio_gestao_analise`: 70 → `varchar(255)`

## Colunas do modelo que a API não expõe (não criadas)
Sensíveis (CPF, documentos não mascarados, contas de favorecidos) ou internas.

- `programas_beneficiarios_faf.uf_ente_recebedor_plano_acao`
- `planos_acao_historico_faf.cpf_historico_plano_acao`
- `planos_acao_analises_faf.cpf_responsavel_analise_plano_acao`
- `termos_adesao_historico_faf.cpf_historico_termo_adesao`
- `gestao_financeira_lancamentos_faf.doc_favorecido_gestao_financeira`
- `gestao_financeira_lancamentos_faf.codigo_banco_favorecido_gestao_financeira`
- `gestao_financeira_lancamentos_faf.codigo_agencia_favorecido_gestao_financeira`
- `gestao_financeira_lancamentos_faf.dv_agencia_favorecido_gestao_financeira`
- `gestao_financeira_lancamentos_faf.codigo_conta_favorecido_gestao_financeira`
- `gestao_financeira_lancamentos_faf.dv_conta_favorecido_gestao_financeira`
- `gestao_financeira_subtransacoes_faf.numero_documento_beneficiario_subtransacao_gestao_financeira`
- `gestao_financeira_subtransacoes_faf.codigo_banco_beneficiario_subtransacao_gestao_financeira`
- `gestao_financeira_subtransacoes_faf.codigo_agencia_beneficiario_subtransacao_gestao_financeira`
- `gestao_financeira_subtransacoes_faf.codigo_conta_beneficiario_subtransacao_gestao_financeira`
- `relatorios_gestao_faf.ultima_versao_relatorio`

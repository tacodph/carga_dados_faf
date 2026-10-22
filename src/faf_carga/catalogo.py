"""Catálogo declarativo dos endpoints da API Fundo a Fundo.

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


CATALOGO: tuple[Endpoint, ...] = (
    Endpoint(
        endpoint="/programas",
        tabela="programas_faf",
        chave=('id_programa',),
        colunas=(
            "id_programa",
            "ano_programa",
            "modalidade_programa",
            "codigo_programa",
            "nome_programa",
            "id_unidade_gestora_programa",
            "nome_institucional_programa",
            "permite_transferencia_sem_fundo_programa",
            "objetivo_programa",
            "descricao_programa",
            "situacao_programa",
            "valor_global_programa",
            "quantidade_parcelas_programa",
            "id_orgao_superior_programa",
            "sigla_orgao_superior_programa",
            "cnpj_orgao_superior_programa",
            "nome_orgao_superior_programa",
            "id_fundo_programa",
            "cnpj_fundo_programa",
            "nome_fundo_programa",
            "uf_fundo_programa",
            "municipio_fundo_programa",
            "codigo_ibge_fundo_programa",
            "data_inicio_recebimento_planos_acao_beneficiarios_especificos",
            "data_fim_recebimento_planos_acao_beneficiarios_especificos",
            "data_inicio_recebimento_planos_acao_beneficiarios_emendas",
            "data_fim_recebimento_planos_acao_beneficiarios_emendas",
            "data_inicio_recebimento_planos_acao_beneficiarios_voluntarios",
            "data_fim_recebimento_planos_acao_beneficiarios_voluntarios",
        ),
        derivadas=(
            Derivada(
                tabela="programas_natureza_despesa_faf",
                campo="programa_natureza_despesa",
                colunas=('id_programa', 'grupo_natureza_despesa_programa'),
                chave=('id_programa', 'grupo_natureza_despesa_programa'),
                extrair=_natureza_despesa,
            ),
            Derivada(
                tabela="programas_acao_orcamentaria_faf",
                campo="programa_acao_orcamentaria",
                colunas=('id_programa', 'codigo_acao_orcamentaria_programa', 'descricao_acao_orcamentaria_programa'),
                chave=('id_programa', 'codigo_acao_orcamentaria_programa'),
                extrair=_acao_orcamentaria,
            ),
        ),
    ),
    Endpoint(
        endpoint="/programas-beneficiarios",
        tabela="programas_beneficiarios_faf",
        chave=('id_beneficiario_programa',),
        colunas=(
            "id_beneficiario_programa",
            "cnpj_beneficiario_programa",
            "nome_beneficiario_programa",
            "valor_beneficiario_programa",
            "numero_emenda_beneficiario_programa",
            "nome_parlamentar_beneficiario_programa",
            "tipo_beneficiario_programa",
            "nome_ente_beneficiario_programa",
            "uf_ente_beneficiario_programa",
            "nome_municipio_ente_beneficiario_programa",
            "codigo_ibge_municipio_ente_beneficiario_programa",
            "id_ente_beneficiario_programa",
            "id_programa",
        ),
    ),
    Endpoint(
        endpoint="/programas-gestao-agil",
        tabela="programas_ageis_faf",
        chave=('id_programa_agil',),
        colunas=(
            "id_programa_agil",
            "id_programa_agil_bb",
            "nome_programa_agil",
            "codigo_programa_agil",
            "id_orgao_programa_agil",
            "codigo_siorg_orgao_programa_agil",
            "sigla_orgao_programa_agil",
            "cnpj_orgao_programa_agil",
            "nome_orgao_programa_agil",
            "id_programa",
        ),
    ),
    Endpoint(
        endpoint="/planos-acao",
        tabela="planos_acao_faf",
        chave=('id_plano_acao',),
        colunas=(
            "id_plano_acao",
            "codigo_plano_acao",
            "data_inicio_vigencia_plano_acao",
            "data_fim_vigencia_plano_acao",
            "diagnostico_plano_acao",
            "objetivos_plano_acao",
            "situacao_plano_acao",
            "valor_repasse_emenda_plano_acao",
            "valor_repasse_especifico_plano_acao",
            "valor_repasse_voluntario_plano_acao",
            "valor_total_repasse_plano_acao",
            "valor_recursos_proprios_plano_acao",
            "valor_outros_plano_acao",
            "valor_rendimentos_aplicacao_plano_acao",
            "valor_total_plano_acao",
            "valor_total_investimento_plano_acao",
            "valor_total_custeio_plano_acao",
            "valor_saldo_disponivel_plano_acao",
            "id_orgao_repassador_plano_acao",
            "sigla_orgao_repassador_plano_acao",
            "cnpj_orgao_repassador_plano_acao",
            "nome_orgao_repassador_plano_acao",
            "id_ente_repassador_plano_acao",
            "cnpj_ente_repassador_plano_acao",
            "nome_ente_repassador_plano_acao",
            "uf_ente_repassador_plano_acao",
            "nome_municipio_ente_repassador_plano_acao",
            "codigo_ibge_municipio_ente_repassador_plano_acao",
            "id_ente_recebedor_plano_acao",
            "cnpj_ente_recebedor_plano_acao",
            "nome_ente_recebedor_plano_acao",
            "uf_ente_recebedor_plano_acao",
            "nome_municipio_ente_recebedor_plano_acao",
            "codigo_ibge_municipio_ente_recebedor_plano_acao",
            "tipo_unidade_recebedora_plano_acao",
            "descricao_tipo_unidade_ente_plano_acao",
            "id_fundo_repassador_plano_acao",
            "cnpj_fundo_repassador_plano_acao",
            "nome_fundo_repassador_plano_acao",
            "uf_fundo_repassador_plano_acao",
            "municipio_fundo_repassador_plano_acao",
            "codigo_ibge_fundo_repassador_plano_acao",
            "id_fundo_vinculado_plano_acao",
            "cnpj_fundo_vinculado_plano_acao",
            "nome_fundo_vinculado_plano_acao",
            "uf_fundo_vinculado_plano_acao",
            "municipio_fundo_vinculado_plano_acao",
            "codigo_ibge_fundo_vinculado_plano_acao",
            "tipo_unidade_recebedora_vinculada_plano_acao",
            "descricao_tipo_unidade_recebedora_vinculada_plano_acao",
            "id_programa",
        ),
    ),
    Endpoint(
        endpoint="/planos-acao-dados-bancarios",
        tabela="planos_acao_dados_bancarios_faf",
        chave=('id_plano_acao_dado_bancario',),
        colunas=(
            "id_plano_acao_dado_bancario",
            "id_agencia_conta",
            "codigo_banco_plano_acao_dado_bancario",
            "nome_banco_plano_acao_dado_bancario",
            "numero_agencia_plano_acao_dado_bancario",
            "dv_agencia_plano_acao_dado_bancario",
            "numero_conta_plano_acao_dado_bancario",
            "dv_conta_plano_acao_dado_bancario",
            "situacao_conta_plano_acao_dado_bancario",
            "data_abertura_conta_plano_acao_dado_bancario",
            "nome_programa_agil_conta_plano_acao_dado_bancario",
            "saldo_final_conta_plano_acao_dado_bancario",
            "id_plano_acao",
        ),
        achatar={'saldo_final_conta_plano_acao_dado_bancario': ('saldo_final_dado_bancario', 'saldo_final_gestao_financeira')},
        derivadas=(
            Derivada(
                tabela="gestao_financeira_saldo_conta_faf",
                campo="saldo_final_dado_bancario",
                colunas=('id_agencia_conta', 'saldo_final_gestao_financeira'),
                chave=('id_agencia_conta',),
                extrair=_saldo_conta,
            ),
        ),
    ),
    Endpoint(
        endpoint="/planos-acao-metas",
        tabela="planos_acao_metas_faf",
        chave=('id_meta_plano_acao',),
        colunas=(
            "id_meta_plano_acao",
            "numero_meta_plano_acao",
            "nome_meta_plano_acao",
            "descricao_meta_plano_acao",
            "valor_meta_plano_acao",
            "versao_meta_plano_acao",
            "sequencial_meta_plano_acao",
            "id_plano_acao",
        ),
    ),
    Endpoint(
        endpoint="/planos-acao-metas-acoes",
        tabela="planos_acao_metas_acoes_faf",
        chave=('id_acao_meta_plano_acao',),
        colunas=(
            "id_acao_meta_plano_acao",
            "numero_acao_meta_plano_acao",
            "nome_acao_meta_plano_acao",
            "descricao_acao_meta_plano_acao",
            "valor_acao_meta_plano_acao",
            "versao_acao_meta_plano_acao",
            "sequencial_acao_meta_plano_acao",
            "id_meta_plano_acao",
        ),
    ),
    Endpoint(
        endpoint="/planos-acao-destinacao-recursos",
        tabela="planos_acao_destinacao_recursos_faf",
        chave=('id_destinacao_recursos_plano_acao',),
        colunas=(
            "id_destinacao_recursos_plano_acao",
            "codigo_natureza_despesa_destinacao_recursos_plano_acao",
            "descricao_natureza_despesa_destinacao_recursos_plano_acao",
            "tipo_despesa_destinacao_recursos_plano_acao",
            "valor_destinacao_recursos_plano_acao",
            "id_plano_acao",
        ),
    ),
    Endpoint(
        endpoint="/planos-acao-historico",
        tabela="planos_acao_historico_faf",
        chave=('id_historico_plano_acao',),
        colunas=(
            "id_historico_plano_acao",
            "situacao_historico_plano_acao",
            "data_historico_plano_acao",
            "versao_historico_plano_acao",
            "id_plano_acao",
        ),
    ),
    Endpoint(
        endpoint="/planos-acao-analises",
        tabela="planos_acao_analises_faf",
        chave=('id_analise_plano_acao',),
        colunas=(
            "id_analise_plano_acao",
            "tipo_analise_plano_acao",
            "tipo_resultado_analise_plano_acao",
            "data_analise_plano_acao",
            "parecer_analise_plano_acao",
            "tipo_origem_analise_plano_acao",
            "id_plano_acao",
            "id_historico_plano_acao",
        ),
    ),
    Endpoint(
        endpoint="/planos-acao-analises-responsaveis",
        tabela="planos_acao_analises_responsaveis_faf",
        chave=('id_analise_responsavel_plano_acao',),
        colunas=(
            "id_analise_responsavel_plano_acao",
            "nome_responsavel_analise_plano_acao",
            "cargo_responsavel_analise_plano_acao",
            "id_analise_plano_acao",
        ),
    ),
    Endpoint(
        endpoint="/termos-adesao",
        tabela="termos_adesao_faf",
        chave=('id_termo_adesao',),
        colunas=(
            "id_termo_adesao",
            "numero_processo_termo_adesao",
            "situacao_termo_adesao",
            "objeto_termo_adesao",
            "data_assinatura_termo_adesao",
            "ano_termo_adesao",
            "secao_publicacao_dou_termo_adesao",
            "pagina_publicacao_dou_termo_adesao",
            "data_publicacao_dou_termo_adesao",
            "id_plano_acao",
        ),
    ),
    Endpoint(
        endpoint="/termos-adesao-historico",
        tabela="termos_adesao_historico_faf",
        chave=('id_historico_termo_adesao',),
        colunas=(
            "id_historico_termo_adesao",
            "situacao_historico_termo_adesao",
            "data_historico_termo_adesao",
            "id_termo_adesao",
        ),
    ),
    Endpoint(
        endpoint="/empenhos",
        tabela="empenhos_faf",
        chave=('id_empenho',),
        colunas=(
            "id_empenho",
            "numero_empenho",
            "ano_empenho",
            "gestao_emitente_empenho",
            "ug_emitente_empenho",
            "data_emissao_empenho",
            "fonte_recurso_empenho",
            "esfera_orcamentaria_empenho",
            "descricao_esfera_orcamentaria_empenho",
            "plano_interno_empenho",
            "unidade_gestora_responsavel_empenho",
            "observacao_empenho",
            "cnpj_favorecido_empenho",
            "numero_lista_empenho",
            "unidade_gestora_referencia_empenho",
            "gestao_referencia_empenho",
            "numero_interno_empenho",
            "objeto_empenho",
            "numero_sistema_empenho",
            "natureza_despesa_empenho",
            "natureza_despesa_sub_item_empenho",
            "tipo_empenho",
            "descricao_tipo_empenho",
            "codigo_tipo_nota_empenho",
            "descricao_tipo_nota_empenho",
            "situacao_empenho",
            "descricao_situacao_empenho",
            "valor_empenho",
            "versao_empenho",
            "id_plano_acao",
        ),
    ),
    Endpoint(
        endpoint="/gestao-financeira-lancamentos",
        tabela="gestao_financeira_lancamentos_faf",
        chave=('id_lancamento_gestao_financeira',),
        colunas=(
            "id_lancamento_gestao_financeira",
            "origem_solicitacao_gestao_financeira",
            "descricao_origem_solicitacao_gestao_financeira",
            "cnpj_ente_solicitante_gestao_financeira",
            "nome_ente_solicitante_gestao_financeira",
            "nome_personalizado_ente_solicitante_gestao_financeira",
            "codigo_programa_agil_ente_solicitante_gestao_financeira",
            "codigo_banco_gestao_financeira",
            "codigo_agencia_gestao_financeira",
            "dv_agencia_gestao_financeira",
            "codigo_conta_gestao_financeira",
            "dv_conta_gestao_financeira",
            "tipo_operacao_gestao_financeira",
            "descricao_tipo_operacao_gestao_financeira",
            "descricao_gestao_financeira",
            "data_lancamento_gestao_financeira",
            "data_evento_lancamento_gestao_financeira",
            "numero_ordem_gestao_financeira",
            "numero_referencia_unica_gestao_financeira",
            "tipo_favorecido_gestao_financeira",
            "descricao_tipo_favorecido_gestao_financeira",
            "doc_favorecido_gestao_financeira_mask",
            "nome_favorecido_gestao_financeira",
            "valor_lancamento_gestao_financeira",
            "codigo_categoria_despesa_lancamento_gestao_financeira",
            "caminho_categoria_despesa_lancamento_gestao_financeira",
            "quantidade_subtransacoes_lancamento_gestao_financeira",
            "id_agencia_conta",
        ),
        achatar={'caminho_categoria_despesa_lancamento_gestao_financeira': ('categorias_despesa_lancamento', 'caminho_categoria_lancamento')},
    ),
    Endpoint(
        endpoint="/gestao-financeira-subtransacoes",
        tabela="gestao_financeira_subtransacoes_faf",
        chave=('id_subtransacao_gestao_financeira',),
        colunas=(
            "id_subtransacao_gestao_financeira",
            "estado_subtransacao_gestao_financeira",
            "situacao_pagamento_subtransacao_gestao_financeira",
            "descricao_situacao_pagamento_subtransacao_gestao_financeira",
            "data_pagamento_subtransacao_gestao_financeira",
            "tipo_pessoa_beneficiario_subtransacao_gestao_financeira",
            "descricao_tp_pessoa_beneficiario_subtransacao_gestao_financeira",
            "doc_beneficiario_subtransacao_gestao_financeira_mask",
            "nome_beneficiario_subtransacao_gestao_financeira",
            "descricao_subtransacao_gestao_financeira",
            "valor_subtransacao_gestao_financeira",
            "codigo_categoria_despesa_subtransacao_gestao_financeira",
            "caminho_categoria_despesa_subtransacao_gestao_financeira",
            "id_lancamento_gestao_financeira",
        ),
        achatar={'caminho_categoria_despesa_subtransacao_gestao_financeira': ('categorias_despesa_subtransacao', 'caminho_categoria_subtransacao')},
    ),
    Endpoint(
        endpoint="/relatorios-gestao",
        tabela="relatorios_gestao_faf",
        chave=('id_relatorio_gestao',),
        colunas=(
            "id_relatorio_gestao",
            "data_relatorio_gestao",
            "data_e_hora_relatorio_gestao",
            "tipo_relatorio_gestao",
            "situacao_relatorio_gestao",
            "valor_executado_relatorio_gestao",
            "valor_pendente_relatorio_gestao",
            "resultados_alcancados_metas_relatorio_gestao",
            "descritivo_relatorio_gestao",
            "contrapartida_relatorio_gestao",
            "endereco_eletronico_publicidade_acoes_relatorio_gestao",
            "declaracao_conformidade_relatorio_gestao",
            "id_plano_acao",
        ),
    ),
    Endpoint(
        endpoint="/relatorios-gestao-acoes",
        tabela="relatorios_gestao_acoes_faf",
        chave=('id_acao_relatorio_gestao',),
        colunas=(
            "id_acao_relatorio_gestao",
            "percentual_execucao_fisica_acao_relatorio_gestao_acao",
            "observacoes_justificativas_relatorio_gestao_acao",
            "id_relatorio_gestao",
            "id_acao_meta_plano_acao",
        ),
    ),
    Endpoint(
        endpoint="/relatorios-gestao-analises",
        tabela="relatorios_gestao_analises_faf",
        chave=('id_relatorio_gestao_analise',),
        colunas=(
            "id_relatorio_gestao_analise",
            "tipo_analise_relatorio_gestao_analise",
            "resultado_analise_relatorio_gestao_analise",
            "parecer_analise_relatorio_gestao_analise",
            "origem_analise_relatorio_gestao_analise",
            "data_analise_relatorio_gestao_analise",
            "versao_analise_relatorio_gestao_analise",
            "id_relatorio_gestao",
        ),
    ),
    Endpoint(
        endpoint="/relatorios-gestao-analises-responsaveis",
        tabela="relatorios_gestao_analises_responsaveis_faf",
        chave=('id_relatorio_gestao_analise_responsavel',),
        colunas=(
            "id_relatorio_gestao_analise_responsavel",
            "nome_responsavel_analise_relatorio_gestao_analise",
            "cargo_responsavel_analise_relatorio_gestao_analise",
            "id_relatorio_gestao_analise",
        ),
    ),
)


def por_endpoint(endpoint: str) -> Endpoint:
    return next(e for e in CATALOGO if e.endpoint == endpoint)

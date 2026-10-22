# CLAUDE.md — faf-carga

Rotina batch que extrai todos os dados da API pública Transferências Fundo a Fundo (Transferegov) e grava no
PostgreSQL local, banco `transferepro`, esquema `base_transferencias_fundo_fundo` (cópia fiel da origem, sem regras
de negócio).

## Documentos de referência (ler antes de trabalhar)
- `docs/prompts/00_contexto_projeto.md` — contexto, fatos da API, destino, padrões.
- `docs/prompts/referencia/api_endpoints.md` — endpoint × tabela, PKs, campos aninhados, diferenças de tipo.
- `docs/prompts/referencia/dicionario_campos_api.md` — campos de cada endpoint.
- `docs/prompts/referencia/decisoes_arquitetura.md` — decisões (download completo; staging em esquema próprio + merge incremental na base — D11).
- `docs/prompts/01..07_*.md` — etapas de desenvolvimento, em ordem.
- `docs/openapi.json` e `docs/modelo_dados_api-faf/` — fontes primárias. Não alterar `docs/` sem pedido explícito.

## Fatos-chave da API
Base `https://api-publica.transferegov.gestao.gov.br/fundoafundo`; paginação `pagina` + `tamanho_da_pagina` (máx. 1000);
envelope `{data,total_pages,total_items,page_number,page_size}`; filtros só por igualdade (sem incremental);
`GET /data-atualizacao` indica a última atualização (origem atualiza ~06:00).

## Convenções
- Python 3.11+, pacote `faf_carga` em `src/`. Dependências mínimas: httpx, psycopg 3, python-dotenv. Sem ORM/pandas.
- Código, comentários, mensagens e nomes de tabelas/colunas em português, sem acento nos identificadores.
- Colunas = nomes dos campos da API; tipos do modelo SchemaSpy; campo `string` na API → `varchar`.
- SQL idempotente em `sql/`; sem `foreign key` (só índices).
- Específico de endpoint fica em um catálogo declarativo único (`catalogo.py`).
- Configuração por variáveis `FAF_*` / `.env` (nunca versionar credenciais).

## Comandos
```
python -m venv .venv && .venv\Scripts\activate
pip install -e .[dev]
python -m faf_carga          # mostra a configuração carregada
pytest                       # unitários (integração: pytest -m integracao)
```

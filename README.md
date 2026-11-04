# faf-carga

Rotina batch que consome a API de dados abertos do módulo **Transferências Fundo a Fundo** do Transferegov e grava
uma cópia fiel dos dados no PostgreSQL local, banco `transferepro`, esquema `base_transferencias_fundo_fundo`.

- API: <https://api-publica.transferegov.gestao.gov.br/fundoafundo/docs> (20 endpoints, ~2,4 milhões de registros)
- Operação do dia a dia: [docs/RUNBOOK.md](docs/RUNBOOK.md) · Prompts de desenvolvimento: [docs/prompts/README.md](docs/prompts/README.md)

## Como funciona

```
  API Transferegov FaF                         PostgreSQL  transferepro
 ┌───────────────────┐  páginas de 1000    COPY ┌──────────────────────────┐  merge incremental   ┌──────────────────────────┐
 │ /data-atualizacao │  (4 em paralelo,   ─────▶│ stg_transferencias_      │  (1 transação:       │ base_transferencias_     │
 │ /programas ...    ├─ retry/backoff) ────────▶│ fundo_fundo.<tabela>     ├─ insere / atualiza /─▶│ fundo_fundo.<tabela>_faf │
 └───────────────────┘                          │ (cópia bruta do download)│  marca removido)     └──────────────────────────┘
                                                └──────────────────────────┘
                 controle (esquema base): controle_execucao*, controle_carga, controle_carga_dia
```

1. Lê `GET /data-atualizacao`. Se for igual à da última carga **completa** com sucesso, a execução é `IGNORADA`
   (use `--forcar` para recarregar mesmo assim).
2. Para cada endpoint: baixa todas as páginas → recarrega a tabela do **esquema de staging** (`stg_…`, cópia bruta) →
   confere a contagem com o `total_items` da API → numa única transação faz o **merge incremental** na base:
   insere o que é novo, atualiza só o que mudou (`hash_registro`) e marca como removido (`dt_remocao_origem`) o que
   deixou de vir. Se algo falhar, a base fica como estava.
3. Lê a data de atualização de novo no fim; se mudou durante a carga, a execução fica `INCONSISTENTE` e será refeita.

A API só filtra por igualdade e não expõe data de alteração por registro, por isso o **download** é sempre completo;
o incremental acontece no banco (nada é reescrito sem necessidade, e cada registro guarda quando apareceu e quando mudou). Decisões detalhadas: [docs/prompts/referencia/decisoes_arquitetura.md](docs/prompts/referencia/decisoes_arquitetura.md).

## Instalação

Requisitos: Python 3.11+, PostgreSQL com o banco `transferepro` e acesso à internet (proxy: `HTTPS_PROXY`).

```
python -m venv .venv
.venv\Scripts\activate
pip install -e .[dev]
copy .env.example .env       # preencher FAF_DB_USUARIO e FAF_DB_SENHA (e FAF_DB_PORT se não for 5433)
faf-carga config             # confere a configuração (senha mascarada)
faf-carga ddl                # cria esquema e tabelas (idempotente)
faf-carga executar           # primeira carga completa (~20-30 min)
```

## Configuração (`.env`)

| Variável | Padrão | Descrição |
|---|---|---|
| `FAF_DB_HOST` / `FAF_DB_PORT` / `FAF_DB_NOME` | `localhost` / `5432` / `transferepro` | conexão (neste ambiente a porta é **5433**) |
| `FAF_DB_USUARIO` / `FAF_DB_SENHA` | — (obrigatórias) | credenciais |
| `FAF_DB_ESQUEMA` / `FAF_DB_ESQUEMA_STG` | `base_transferencias_fundo_fundo` / `stg_transferencias_fundo_fundo` | esquemas da base e do staging |
| `FAF_DB_TABLESPACE` | vazio | tablespace para tabelas, índices e arquivos temporários (neste ambiente `ts_faf`, em `D:\pgdata_faf`) |
| `FAF_DB_STATEMENT_TIMEOUT` | `4h` | limite de cada comando da sessão de carga (o `COPY` do download é um comando único e longo; o servidor tem 50 min) |
| `FAF_DB_MERGE_TIMEOUT` | `30min` | limite de cada comando do merge incremental (normalmente dura segundos) |
| `FAF_API_BASE_URL` | URL pública da API | |
| `FAF_API_TAMANHO_PAGINA` | `1000` | máximo aceito pela API |
| `FAF_API_CONCORRENCIA` | `4` | requisições simultâneas |
| `FAF_API_TIMEOUT` / `FAF_API_MAX_TENTATIVAS` | `120` s / `6` | timeout e tentativas por requisição |
| `FAF_LOG_NIVEL` / `FAF_LOG_DIR` | `INFO` / `logs` | log |

## Comandos

| Comando | O que faz |
|---|---|
| `faf-carga executar [--forcar] [--endpoints programas,planos-acao]` | executa a carga |
| `faf-carga status [--ultimas N]` | últimas execuções e endpoints da mais recente |
| `faf-carga verificar` | compara `total_items` da API com `count(*)` de cada tabela, sem carregar |
| `faf-carga parlamentares` | liga as emendas de `/programas-beneficiarios` ao parlamentar (roda sozinho no fim de `executar`) |
| `faf-carga endpoints` | lista endpoint → tabela |
| `faf-carga ddl` | aplica `sql/*.sql` |
| `faf-carga config` | mostra a configuração |

Códigos de saída de `executar`: `0` sucesso/ignorada · `1` erro · `2` já existe carga em execução · `3` parcial ou inconsistente.
Uma carga com `--endpoints` nunca vale como completa (grava `SUCESSO_PARCIAL`).

## Agendamento (Windows)

```
powershell -ExecutionPolicy Bypass -File scripts\agendar_tarefa.ps1      # como Administrador
```

Em servidor Linux (VPS da Hostinger): `sudo bash scripts/agendar_linux.sh --usuario faf` (systemd timer) ou
`bash scripts/agendar_linux.sh --cron`; passo a passo em `docs/RUNBOOK.md`, seção 6b. O banco do `.env` precisa ser
alcançável a partir do servidor.

No Windows, o script acima cria a tarefa **FAF - Carga Transferegov**: diária às 07:30, com novas tentativas às 10:30 e 14:30 (a rotina se
auto-ignora se a data do dia já foi carregada). A senha do Windows é pedida numa janela segura e não é gravada;
`-SomenteLogado` dispensa a senha. Execução manual: `scripts\executar_carga.ps1` (aceita os mesmos argumentos da CLI).

## Logs

- `logs\faf_carga_AAAAMMDD.log` — log da aplicação; `logs\execucao_*.txt` — saída de cada chamada do script.
- `executar_carga.ps1` apaga arquivos de `logs\` com mais de 90 dias.

## Tabelas criadas

- **23 de dados** (nomes do modelo de origem, colunas com os nomes dos campos da API, mais `dt_carga` e `id_execucao`):
  `programas_faf`, `programas_beneficiarios_faf`, `programas_ageis_faf`, `programas_natureza_despesa_faf`,
  `programas_acao_orcamentaria_faf`, `planos_acao_faf`, `planos_acao_dados_bancarios_faf`, `planos_acao_metas_faf`,
  `planos_acao_metas_acoes_faf`, `planos_acao_destinacao_recursos_faf`, `planos_acao_historico_faf`,
  `planos_acao_analises_faf`, `planos_acao_analises_responsaveis_faf`, `termos_adesao_faf`,
  `termos_adesao_historico_faf`, `empenhos_faf`, `gestao_financeira_lancamentos_faf`,
  `gestao_financeira_subtransacoes_faf`, `gestao_financeira_saldo_conta_faf`, `relatorios_gestao_faf`,
  `relatorios_gestao_acoes_faf`, `relatorios_gestao_analises_faf`, `relatorios_gestao_analises_responsaveis_faf`.
- **Colunas técnicas** em toda tabela de dados: `dt_carga` (1ª vez que o registro apareceu), `dt_atualizacao` (última
  mudança), `id_execucao` (última execução que o tocou), `hash_registro` e `dt_remocao_origem` (preenchida quando o
  registro some da API; **consultas devem filtrar `dt_remocao_origem is null`** para ver só os ativos).
- **23 de staging** no esquema `stg_transferencias_fundo_fundo` (mesmos nomes, não logadas) e **controle**: `controle_execucao`, `controle_execucao_endpoint` e, no
  padrão corporativo, `controle_carga` (por endpoint) e `controle_carga_dia` (por execução).
- **View** `vw_emendas_faf_parlamentar`: beneficiários de emenda ativos com o parlamentar normalizado (ver abaixo).
- Sem `foreign key` (dados abertos podem ter órfãos); há índices nas colunas de relacionamento.
  Consultas de conferência: `sql/validacao.sql`.

## Emendas e parlamentar

Mesmo padrão das emendas do Transferegov (`carga_arquivos_transferegov/docs/EMENDAS_PARLAMENTAR.md`): o
parlamentar é identificado pelo **código do autor**, nunca pelo nome. Código: `src/faf_carga/parlamentar.py`;
DDL: `sql/008_emendas_parlamentar.sql` (migration do transferepro
`base_transferencias_fundo_fundo/2026_10_23_110001_create_vw_emendas_faf_parlamentar.php`).

- `numero_emenda_beneficiario_programa` tem 12 dígitos: **ano (4) + autor (4) + sequencial (4)**. Ex.:
  `202013310016` → ano 2020, autor `1331`, `nr_emenda` `13310016` (formato do siconv). Com 8 dígitos vale como
  `nr_emenda` sem ano; outros formatos ficam sem autor (contados no log).
- O parlamentar fica em `transfere_pro_transferegov` (`tab_autores_emendas`, `tab_parlamentares`,
  `tab_parlamentares_alias`), mantidas pela carga de emendas. Depois de cada execução que carregue
  `/programas-beneficiarios`, esta carga grava os códigos que lá ainda não existem (`origem = 'faf'`), liga cada
  código a um parlamentar pelo nome normalizado, grava as grafias daqui como alias e marca
  `tab_autores_emendas.fl_revisar` quando uma grafia já pertence a outro parlamentar. O nome do siconv nunca é
  sobrescrito. Mesma trava (`pg_advisory_xact_lock(7465100)`) das outras cargas que gravam parlamentar; uma falha
  aqui é logada e não muda o status da carga; sem as tabelas de parlamentar o passo é pulado com aviso.
- `vw_emendas_faf_parlamentar`: uma linha por beneficiário ativo com número de emenda (`ano_emenda`, `cod_autor`,
  `nr_emenda`, `id_parlamentar`, `nome_parlamentar`, `nome_parlamentar_origem`, `fl_revisar`, CNPJ, valor, ente).
  Junte por `id_parlamentar` ou `(ano_emenda, nr_emenda)`.

Conferência (só leitura):

```sql
-- o código do autor do FaF bate com o do siconv? (nomes lado a lado)
select v.cod_autor, a.origem, a.nome_parlamentar as nome_siconv,
       min(v.nome_parlamentar_origem) as nome_faf, count(*) as beneficiarios
from base_transferencias_fundo_fundo.vw_emendas_faf_parlamentar v
join transfere_pro_transferegov.tab_autores_emendas a on a.cod_autor = v.cod_autor
group by 1, 2, 3 order by a.origem, beneficiarios desc;

-- formatos de número de emenda e vínculos
select length(regexp_replace(numero_emenda, '\D', '', 'g')) as digitos, count(*) as total,
       count(id_parlamentar) as com_parlamentar, count(*) filter (where fl_revisar) as revisar
from base_transferencias_fundo_fundo.vw_emendas_faf_parlamentar group by 1 order by 1;
```

## Desenvolvimento

```
pytest                    # unitários (sem rede e sem banco)
pytest -m integracao      # exige banco (.env) e internet; usa esquema temporário
python scripts/gerar_ddl.py && python scripts/gerar_catalogo.py && python scripts/gerar_validacao.py
```

Se a API mudar (campo novo), `tests/test_transformar_endpoints.py` falha; veja o RUNBOOK.
#   c a r g a _ d a d o s _ f a f  
 #   t r a n s f e r e n c i a s _ f u n d o _ a _ f u n d o  
 
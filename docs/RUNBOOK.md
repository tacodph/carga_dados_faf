# RUNBOOK — Carga FaF Transferegov

Banco: `transferepro` · esquema `base_transferencias_fundo_fundo` · comando: `faf-carga` (no `.venv` da raiz do projeto).

## 1. A carga de hoje rodou?

```
faf-carga status
```

Mostra as últimas execuções e, para a mais recente, cada endpoint (total da API × gravado). Equivalente em SQL:

```sql
select id_execucao, dt_inicio, status, dt_atualizacao_origem, left(mensagem, 120)
from base_transferencias_fundo_fundo.controle_execucao order by id_execucao desc limit 5;

select * from base_transferencias_fundo_fundo.controle_carga_dia order by id desc limit 5;
```

Para conferir os dados sem carregar: `faf-carga verificar` (todas as tabelas devem estar `ok`) e `sql/validacao.sql`.

## 2. O que fazer em cada status

| Status | Significa | Ação |
|---|---|---|
| `SUCESSO` | todos os endpoints carregados e a origem não mudou | nada |
| `IGNORADA` | origem sem alteração desde a última carga completa | nada (esperado nas tentativas das 10:30 e 14:30) |
| `SUCESSO_PARCIAL` | algum endpoint falhou **ou** foi uma carga com `--endpoints` | ver endpoints com erro em `faf-carga status`; corrigir a causa (seção 4) e reprocessar |
| `INCONSISTENTE` | a origem foi atualizada durante a carga | nada: a próxima execução refaz tudo; se persistir, rodar fora do horário de atualização |
| `ERRO` | todos falharam ou erro inesperado | ler a mensagem e o log (`log_arquivo` em `controle_carga_dia`) |
| `EM_ANDAMENTO` por horas | o processo morreu | a próxima execução marca como `ERRO` e segue |

Códigos de saída: `0` sucesso/ignorada · `1` erro · `2` já existe carga em execução (nada foi feito) · `3` parcial/inconsistente.
A falha de um endpoint **não** altera a tabela dele: ela continua com a carga anterior.

No padrão corporativo (`controle_carga_dia`), `SUCESSO_PARCIAL` e `INCONSISTENTE` aparecem como `PARCIAL`, e `IGNORADA` como `SUCESSO`
(a mensagem explica). O status detalhado fica em `controle_execucao`.

## 3. Reprocessar

```
faf-carga executar --forcar                                  # tudo, mesmo sem mudança na origem
faf-carga executar --forcar --endpoints empenhos,programas   # só alguns (grava SUCESSO_PARCIAL)
```

Nunca rode duas cargas ao mesmo tempo: a segunda sai com código 2 (trava do banco).

## 4. Erros comuns

| Sintoma (mensagem) | Causa provável | Ação |
|---|---|---|
| `falhou após N tentativas (HTTP 502/503/504, timeout)` | API ou Cloudflare instável | aguardar e reexecutar; a rotina já faz retry com espera (respeita `Retry-After`) |
| `HTTP 422 ... less than or equal to 1000` | `FAF_API_TAMANHO_PAGINA` > 1000 ou parâmetro removido pela API | ajustar o `.env`; se a API mudou, seção 5 |
| `corpo inesperado (não é JSON)` | página de erro do Cloudflare/proxy | verificar rede/proxy (`HTTPS_PROXY`) e reexecutar |
| `campo novo na API, ignorado` (aviso no log) | a API ganhou um campo | seção 5; os dados continuam sendo carregados sem ele |
| `campo do catálogo ausente na resposta` (aviso) | a API removeu/renomeou um campo | seção 5 |
| `valor maior que a coluna em <tabela>: <coluna> (máx. observado X > limite Y)` | texto maior que o `varchar` | ajustar o tamanho em `scripts/gerar_ddl.py`, regenerar e criar `sql/00N_*.sql` com `alter table ... type` |
| `chave primária duplicada em <tabela>` (no staging) | a API devolveu o mesmo id duas vezes | reexecutar (pode ser mudança da origem durante a paginação); se repetir, acionar o Transferegov |
| `esperado X, gravado Y` | a origem mudou durante o download | reexecutar |
| `a API devolveu 0 registros para <tabela>, mas a base tem N ativos` | resposta vazia da API (falha) | reexecutar; nada foi alterado (trava contra remoção em massa) |
| `após o merge, <tabela> tem X ativos, mas o staging tem Y` | inconsistência no merge | nada foi gravado (rollback); reexecutar com `--forcar` e investigar se repetir |
| `QueryCanceled ... timeout` no `insert` do merge (visto 3 vezes em `/gestao-financeira-lancamentos`, 22/10/2026) | **causa não identificada**: o `INSERT` fica ativo em CPU, sem espera nem bloqueio, e depois passa quando reexecutado | a base fica intacta (rollback). Reexecute `faf-carga executar --forcar --endpoints gestao-financeira-lancamentos`. Se repetir, rode `EXPLAIN` do `INSERT` de `db.mesclar` com o staging já carregado e veja `pg_stat_activity` (staging fica confirmado e analisado no esquema `stg_…`) |
| `DiskFull ... No space left on device` | disco do PostgreSQL cheio (dados e WAL) | liberar espaço no disco do servidor (ou mover tablespace); a base fica como estava; o PostgreSQL pode entrar em modo de recuperação e voltar sozinho |
| `connection refused` / `password authentication failed` | banco fora do ar ou credencial/porta erradas | conferir `.env` (neste ambiente a porta é 5433) e o serviço `postgresql-x64-17` |
| código de saída `2` | outra carga em andamento | aguardar; conferir com `faf-carga status` |

## 5. Quando a API mudar (campo novo, removido ou renomeado)

1. Baixe o novo OpenAPI: `https://api-publica.transferegov.gestao.gov.br/fundoafundo/openapi.json` → `docs/openapi.json`.
2. Regenere o dicionário em `docs/prompts/referencia/dicionario_campos_api.md` (peça ao Claude Code) e, se preciso,
   atualize `ALIAS`/`ACHATADOS` em `scripts/gerar_ddl.py`.
3. `python scripts/gerar_ddl.py && python scripts/gerar_catalogo.py && python scripts/gerar_validacao.py`
4. Para colunas novas, crie um script **novo** `sql/00N_descricao.sql` com `alter table ... add column` nas tabelas de
   dados (esquema base) **e** de staging (esquema `stg_…`) (003/004 são `create if not exists` e não alteram tabelas existentes).
   Coluna nova entra no `hash_registro` nas cargas seguintes (a primeira carga depois da mudança marcará os registros como
   "atualizados" uma vez). Se mudar o **tipo** de uma coluna, recalcule o hash (veja o `update` de `sql/007_incremental.sql`).
5. `faf-carga ddl` e `pytest`; depois `faf-carga executar --forcar`.

## 5b. Tablespace e disco

- Tabelas, índices e arquivos temporários ficam no tablespace `ts_faf` (`D:\pgdata_faf`), definido por `FAF_DB_TABLESPACE`.
  `faf-carga ddl` cria objetos novos lá e move para lá o que estiver fora (idempotente).
- O WAL do PostgreSQL continua no disco do servidor (C:). Mantenha alguns GB livres nele: o disco cheio derrubou o banco
  em 21/10/2026 durante uma carga (`DiskFull`), com recuperação automática.

## 6. Agendamento

- Tarefa: **FAF - Carga Transferegov** (07:30, 10:30, 14:30). Criar/atualizar: `scripts\agendar_tarefa.ps1` (como Administrador).
  Remover: `scripts\agendar_tarefa.ps1 -Remover`. Disparo manual: `Start-ScheduledTask -TaskName 'FAF - Carga Transferegov'`.
- A tarefa roda `scripts\executar_carga.ps1`, que grava `logs\execucao_*.txt` e apaga logs com mais de 90 dias.

## 6b. Agendamento em servidor Linux (VPS da Hostinger)

**Antes de tudo:** a rotina grava no PostgreSQL configurado no `.env`. O banco `transferepro` deste ambiente é local (Windows,
`localhost:5433`) e **não é alcançável da Hostinger**. No servidor, o `.env` precisa apontar para um PostgreSQL acessível a ele:
instalado no próprio VPS, ou um banco remoto via túnel SSH/VPN. **Não exponha a porta do PostgreSQL na internet.**
Se o banco continuar só no Windows, mantenha o agendamento do Windows (seção 6).

Pré-requisitos no VPS: Linux com systemd (Ubuntu 24.04 tem Python 3.12; o 22.04 tem 3.10, e a rotina exige Python 3.11+),
acesso SSH e um usuário sem privilégios para rodar a carga.

```bash
# 1. dependências e usuário dedicado (como root/sudo)
sudo apt update && sudo apt install -y python3 python3-venv python3-pip git
sudo adduser --disabled-password --gecos "" faf

# 2. enviar o projeto (do seu PC, sem .env, .venv e logs) -- ou git clone, se houver repositório
rsync -av --exclude '.venv' --exclude '.env' --exclude 'logs' --exclude '__pycache__' \
      ./ faf@SEU_SERVIDOR:/home/faf/faf-carga/

# 3. ambiente e configuração (como o usuário faf)
sudo -iu faf
cd ~/faf-carga && python3 -m venv .venv && .venv/bin/pip install -e .
cp .env.example .env && chmod 600 .env && nano .env     # FAF_DB_HOST/PORT/USUARIO/SENHA; deixe FAF_DB_TABLESPACE vazio
.venv/bin/faf-carga config       # confere a configuração (senha mascarada)
.venv/bin/faf-carga ddl          # cria esquemas e tabelas (idempotente)
.venv/bin/faf-carga executar     # primeira carga completa (~30 min)
exit

# 4. agendar (como root) -- systemd timer, 07:30 / 10:30 / 14:30 de Brasília
sudo bash /home/faf/faf-carga/scripts/agendar_linux.sh --usuario faf
```

Operação:

```bash
systemctl list-timers faf-carga.timer         # próximas execuções
sudo systemctl start faf-carga.service        # disparo manual
journalctl -u faf-carga.service -n 100        # saída da última execução (e ~/faf-carga/logs/)
sudo bash scripts/agendar_linux.sh --remover  # remove o agendamento
```

Alternativa com **cron** (sem root, ou se o plano não tiver systemd): `bash scripts/agendar_linux.sh --cron` instala a entrada no
crontab do usuário, convertendo os horários de Brasília para o fuso do servidor (normalmente UTC: 10:30, 13:30 e 17:30).
Conferir com `crontab -l`; log em `logs/cron.log`. Para remover: `bash scripts/agendar_linux.sh --cron --remover`.

No **hospedagem compartilhada/hPanel** (sem SSH/root): crie o cron em *Avançado > Tarefas Cron* com o comando
`/home/USUARIO/faf-carga/scripts/executar_carga.sh` e os horários em UTC (10:30, 13:30, 17:30 = 07:30, 10:30, 14:30 de Brasília).

As tentativas extras são seguras: carga já feita para a data da origem vira `IGNORADA`, e carga ainda em andamento sai com código 2.
Se o Windows e o servidor agendarem a mesma base, a trava do banco impede que rodem ao mesmo tempo.

## 7. Sobre os dados

- **Filtre `dt_remocao_origem is null`** para ver só registros ativos; os removidos continuam na tabela (marcados).
- `dt_carga` = quando o registro apareceu; `dt_atualizacao` = última mudança; para consumo incremental use
  `where dt_atualizacao > :ultima_leitura` (inclui registros removidos, que também têm `dt_atualizacao` atualizada).
- O esquema de staging é a cópia bruta do último download de cada endpoint: serve só à carga, não consulte.

- Cada linha tem `dt_carga` e `id_execucao` (liga a `controle_execucao`).
- Campos sensíveis do modelo de origem (CPF de responsáveis, documentos sem máscara, contas de favorecidos) **não** são
  expostos pela API e não existem no banco.
- Decisões de tipos e divergências API × modelo: `sql/relatorio_mapeamento.md`.

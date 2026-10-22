set search_path to base_transferencias_fundo_fundo;

create table if not exists controle_execucao (
    id_execucao               bigint generated always as identity primary key,
    dt_inicio                 timestamptz not null default now(),
    dt_fim                    timestamptz,
    status                    varchar(20) not null,
    dt_atualizacao_origem     timestamp,
    dt_atualizacao_origem_fim timestamp,
    forcada                   boolean not null default false,
    endpoints_solicitados     text,
    mensagem                  text
);
comment on table controle_execucao is 'Uma linha por execução da rotina de carga';
comment on column controle_execucao.status is 'EM_ANDAMENTO | SUCESSO | SUCESSO_PARCIAL | ERRO | INCONSISTENTE | IGNORADA';
comment on column controle_execucao.dt_atualizacao_origem is '/data-atualizacao da API no início da execução';
comment on column controle_execucao.dt_atualizacao_origem_fim is '/data-atualizacao da API no fim da execução';
comment on column controle_execucao.endpoints_solicitados is 'Lista de endpoints pedidos; nulo = todos';

create table if not exists controle_execucao_endpoint (
    id_execucao     bigint not null,
    endpoint        varchar(60) not null,
    tabela          varchar(80) not null,
    dt_inicio       timestamptz not null,
    dt_fim          timestamptz,
    status          varchar(20) not null,
    paginas         integer,
    total_items_api bigint,
    linhas_gravadas bigint,
    qtd_inseridos   bigint,
    qtd_atualizados bigint,
    qtd_removidos   bigint,
    mensagem        text,
    primary key (id_execucao, endpoint)
);
comment on table controle_execucao_endpoint is 'Uma linha por endpoint em cada execução';
comment on column controle_execucao_endpoint.status is 'EM_ANDAMENTO | SUCESSO | ERRO';
comment on column controle_execucao_endpoint.total_items_api is 'total_items informado pela API (para reconciliação)';
comment on column controle_execucao_endpoint.id_execucao is 'Relaciona com controle_execucao.id_execucao';

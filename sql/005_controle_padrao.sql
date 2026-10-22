-- Controle no padrão corporativo (mesmo formato das demais cargas, ex.: carga_arquivos_transferegov).
-- Idempotente: se as tabelas já existirem no esquema, nada é alterado.
set search_path to base_transferencias_fundo_fundo;

create sequence if not exists controle_carga_id_seq;
create sequence if not exists controle_carga_dia_id_seq;

-- uma linha por execução (várias no mesmo dia)
create table if not exists controle_carga_dia (
    id                      integer not null default nextval('controle_carga_dia_id_seq'::regclass),
    dt_carga                date not null default current_date,
    seq_execucao_dia        smallint not null,
    dt_inicio               timestamp without time zone not null,
    dt_fim                  timestamp without time zone,
    status                  varchar not null default 'EXECUTANDO',
    qtd_arquivos_extraidos  integer not null default 0,
    qtd_arquivos_carregados integer not null default 0,
    qtd_arquivos_erro       integer not null default 0,
    qtd_arquivos_pulados    integer not null default 0,
    mensagem                text,
    log_arquivo             varchar,
    constraint controle_carga_dia_pkey primary key (id),
    constraint uq_controle_carga_dia_data_seq unique (dt_carga, seq_execucao_dia),
    constraint chk_controle_carga_dia_status check (status in
        ('EXECUTANDO', 'CARREGANDO', 'SUCESSO', 'CORRIGIDO/SUCESSO', 'ERRO', 'PARCIAL'))
);

-- uma linha por endpoint/tabela processado
create table if not exists controle_carga (
    id              integer not null default nextval('controle_carga_id_seq'::regclass),
    endpoint        varchar not null,
    dt_inicio       timestamp without time zone not null,
    dt_fim          timestamp without time zone,
    status          varchar not null default 'EXECUTANDO',
    total_registros integer,
    mensagem        text,
    constraint controle_carga_pkey primary key (id),
    constraint chk_status check (status in
        ('EXECUTANDO', 'CARREGANDO', 'SUCESSO', 'CORRIGIDO/SUCESSO', 'ERRO', 'PARCIAL'))
);

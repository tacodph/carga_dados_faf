create schema if not exists stg_transferencias_fundo_fundo;
comment on schema stg_transferencias_fundo_fundo is
    'Staging: cópia bruta do último download da API (recarregada por inteiro a cada endpoint)';

create schema if not exists base_transferencias_fundo_fundo;
comment on schema base_transferencias_fundo_fundo is
    'Cópia fiel dos dados abertos da API Transferências Fundo a Fundo (Transferegov), carregada por faf-carga';

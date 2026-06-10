DELETE FROM mnt_if_edge_client_connect;
DELETE FROM mnt_if_edge_manage;

insert into mnt_if_edge_manage (
  facility_cd,
  response_status,
  edge_result,
  is_del,
  reg_date,
  up_date
) values (
  '003',
  '0',
  '{}'::JSONB,
  '0',
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP
);
insert into mnt_if_edge_manage (
  facility_cd,
  response_status,
  edge_result,
  is_del,
  reg_date,
  up_date
) values (
  '004',
  '0',
  null,
  '0',
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP
);

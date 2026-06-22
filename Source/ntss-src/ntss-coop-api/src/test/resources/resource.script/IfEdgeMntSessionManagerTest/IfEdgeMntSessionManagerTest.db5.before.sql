DELETE FROM mnt_if_edge_client_connect;
DELETE FROM mnt_if_edge_manage;

insert into mnt_if_edge_client_connect (
  facility_cd,
  reg_date,
  up_date
) values (
  '002',
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP
);
insert into mnt_if_edge_client_connect (
  facility_cd,
  reg_date,
  up_date
) values (
  '004',
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP
);
insert into mnt_if_edge_client_connect (
  facility_cd,
  reg_date,
  up_date
) values (
  '009',
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP
);
insert into mnt_if_edge_client_connect (
  facility_cd,
  reg_date,
  up_date
) values (
  '010',
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
  '005',
  '0',
  null,
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
  '006',
  '0',
  null,
  '0',
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP
);
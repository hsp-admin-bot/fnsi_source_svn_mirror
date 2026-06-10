DELETE FROM mnt_if_edge_manage;

insert into mnt_if_edge_manage (
  facility_cd,
  response_status,
  edge_result,
  is_del,
  reg_date,
  up_date
) values (
  '001',
  '0',
  '{"system":"NTSS","status":"result","facility_cd":"99999","result":{"ctl_no":"18","status": "200","message": "OK"}}'::JSONB,
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
  '001',
  '0',
  '{"system":"NTSS","status":"result","facility_cd":"99999","result":{"ctl_no":"16","status": "200","message": "OK"}}'::JSONB,
  '1',
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
  '002',
  '0',
  '{"system":"NTSS","status":"result","facility_cd":"99999","result":{"ctl_no":"19","status": "200","message": "OK"}}'::JSONB,
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
  '001',
  '-1',
  '{"system":"NTSS","status":"result","facility_cd":"99999","result":{"ctl_no":"20","status": "200","message": "OK"}}'::JSONB,
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
  '{"system":"NTSS","status":"result","facility_cd":"99999","result":{"ctl_no":"18","status": "200","message": "OK"}}'::JSONB,
  '0',
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP
);
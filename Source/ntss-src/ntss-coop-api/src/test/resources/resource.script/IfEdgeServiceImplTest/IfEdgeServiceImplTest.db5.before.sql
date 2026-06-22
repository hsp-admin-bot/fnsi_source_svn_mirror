DELETE FROM mnt_if_edge_client_connect;
DELETE FROM mnt_if_edge_manage;
DELETE FROM mst_if_edge_command;

/* 異常系_指示種別がコマンドの場合指定のコマンドが取得できない */
insert into mnt_if_edge_client_connect (
  facility_cd,
  ip_address,
  reg_date,
  up_date
) values (
  '007',
  '127.0.0.1',
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
  '100',
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
  '101',
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
  '102',
  '0',
  null,
  '0',
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP
);

INSERT INTO
  mst_if_edge_command
(
  command_key
  ,command
  ,is_del
  ,reg_date
  ,up_date

) VALUES (
   'test'
 , 'commandtest'
 , '0'
 , '2019-11-12 15:00:00'
 , '2019-11-12 15:00:00'
 );

INSERT INTO
  mst_if_edge_command
(
  command_key
  ,command
  ,add_setting
  ,is_del
  ,reg_date
  ,up_date

) VALUES (
   'testsetting'
 , 'commmm'
 , '1'
 , '0'
 , '2019-11-12 15:00:00'
 , '2019-11-12 15:00:00'
 );

 INSERT into
  mst_coop_facility
 (
  facility_cd
  , description
  , is_disp
  , is_del
  , if_edge_setting
  , common_setting
  , user_id
  , reg_date
  , up_date
 ) VALUES (
  '202'
  ,''
  ,'1'
  ,'0'
  ,'{"ddd": "eee", "test": "ok"}'
  ,'{}'
  ,2
  ,'2019-11-12 15:00:00'
  ,'2019-11-12 15:00:00'
 );
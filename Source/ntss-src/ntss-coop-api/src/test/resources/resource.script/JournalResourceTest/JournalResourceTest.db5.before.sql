TRUNCATE sys_coop_journal RESTART IDENTITY;
DELETE FROM mst_coop_distribute;
DELETE FROM mst_if_edge;
DELETE FROM mnt_if_edge_healthmon;
DELETE FROM mst_coop_layout;
DELETE FROM mst_coop_facility;

INSERT INTO
  sys_coop_journal
  (
  facility_cd
  , coop_cd
  , coop_cd_index
  , crud
  , direction
  , hosp_pat_id
  , ana_result
  , out_reg_date
  , out_ana_date
  , coop_result
  , in_reg_date
  , in_ana_date
  , dump_path
  , dump
  , is_editable
  , reg_date
  , up_date
  , is_del
  )
  VALUES
  ('TEST01', '1', '',  'C', 'S' , '000000000000', '9', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '0' , '2019-11-12 15:00:00' , '2019-11-12 15:00:00' , 'TEST.txt' , null , '1' , current_timestamp , current_timestamp , '0'),
  ('TEST01', '1', '',  'C', 'S' , '000000000000', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '0' , '2019-11-12 15:00:00' , '2019-11-12 15:00:00' , 'TEST.txt' , null , '1' , current_timestamp , current_timestamp , '0'),
  ('TEST02', '1', '1', 'C', 'S' , '000000000000', '9', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', 'TEST.txt', null, '1', current_timestamp, current_timestamp, '0'),
  ('TEST02', '2', '',  'C', 'S' , '000000000000', '9', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', 'TEST.txt', null, '1', current_timestamp, current_timestamp, '0'),
  ('TEST02', '2', '',  'C', 'S' , '000000000000', '9', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '9', '2019-11-12 15:00:00', '2019-11-12 15:00:00', 'TEST.txt', null, '1', current_timestamp, current_timestamp, '0'),
  ('TEST03', '1', '',  'C', 'S' , '000000000000', '9', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', 'TEST.txt', 'TEST_MOCK', '1', current_timestamp, current_timestamp, '0'),
  ('TEST03', '1', '',  'C', 'S' , '000000000000', '9', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', 'TEST.txt', null, '1', current_timestamp, current_timestamp, '0'),
  ('TEST03', '1', '',  'C', 'R' , '000000000000', '9', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', 'TEST.txt', null, '1', current_timestamp, current_timestamp, '0'),
  ('TEST07', '1', '',  'C', 'S' , '000000000000', '9', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', 'TEST.txt', null, '1', current_timestamp, current_timestamp, '0'),
  ('TEST07', '1', '',  'C', 'S' , '000000000000', '9', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', 'TEST.txt', null, '1', current_timestamp, current_timestamp, '1'),
  ('TEST08', '1', '',  'C', 'S' , '000000000000', '9', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', 'TEST.txt', null, '1', current_timestamp, current_timestamp, '0');

INSERT INTO
  sys_coop_journal
  (
  ctl_no
  , facility_cd
  , coop_cd
  , coop_cd_index
  , crud
  , direction
  , hosp_pat_id
  , ana_result
  , out_reg_date
  , out_ana_date
  , coop_result
  , in_reg_date
  , in_ana_date
  , dump_path
  , dump
  , is_editable
  , reg_date
  , up_date
  , is_del
  )
  VALUES
  (9999999, 'TEST05', '1', '', 'C' , 'S', '000000000000' , '0' , '2019-11-12 15:00:00' , '2019-11-12 15:00:00' , '0' , '2019-11-12 15:00:00' , '2019-11-12 15:00:00' , null, null , '1' , current_timestamp , current_timestamp , '0');

INSERT INTO
  mst_coop_distribute
  (
  facility_cd
  , coop_cd
  , coop_cd_index
  , direction
  , distribute_setting
  , reg_date
  , up_date
  )
  VALUES
  ('TEST01', '1', '', 'S', '{"protocolInfo": {"dummy": "true", "delete": "true", "address": "C:\\work\\distination\\", "protocol": "file", "renameWhenCopying": "true"}}', current_timestamp, current_timestamp),
  ('TEST02', '2', '', 'S', '{"protocolInfo": {"dummy": "false", "delete": "true", "address": "C:\\work\\distination\\", "protocol": "file", "renameWhenCopying": "true"}}', current_timestamp, current_timestamp),
  ('TEST02', '1', '1', 'S', '{"protocolInfo": {"dummy": "false", "delete": "true", "address": "C:\\work\\distination\\", "protocol": "file", "renameWhenCopying": "true"}}', current_timestamp, current_timestamp),
  ('TEST03', '1', '', 'S', '{"protocolInfo": {"dummy": "false", "delete": "true", "address": "C:\\work\\distination\\", "protocol": "file", "renameWhenCopying": "true"}}', current_timestamp, current_timestamp),
  ('TEST07', '1', '', 'S', '{"protocolInfo": {"dummy": "true", "delete": "true", "address": "C:\\work\\distination\\", "protocol": "file", "renameWhenCopying": "true"}}', current_timestamp, current_timestamp),
  ('TEST08', '1', '', 'S', '{"protocol": {"dummy": "true", "delete": "true", "address": "C:\\work\\distination\\", "protocol": "file", "renameWhenCopying": "true"}}', current_timestamp, current_timestamp);


INSERT INTO
  mnt_if_edge_healthmon
  (
  facility_cd
  , if_edge_no
  , healthmon_facility_conn
  , healthmon_server_conn
  , reg_date
  , up_date
  )
  VALUES
  ('TEST05', 1
    , '{"1": {"status": "01","type" : "receive","moni_time": "2020-01-01 00:00:01" }, "profile": { "status": "01", "type" : "request", "moni_time": "2020-01-01 00:00:01" }, "exam_rst": { "status": "01", "type" : "send", "moni_time": "2020-01-01 00:00:01"} }'
    , '{ "status": "01", "moni_time": "2020-01-01 00:00:01" }'
    , '2019-12-10 12:50:00'
    , '2019-12-10 13:00:03'
  ),
  ('TEST06', 1
    , '{"1": {"status": "xx","type" : "receive","moni_time": "2020-01-01 00:00:01" }, "profile": { "status": "xx", "type" : "request", "moni_time": "2020-01-01 00:00:01" }, "exam_rst": { "status": "xx", "type" : "send", "moni_time": "2020-01-01 00:00:01"} }'
    , '{ "status": "01", "moni_time": "2020-01-01 00:00:01" }'
    , '2019-12-10 12:50:00'
    , '2019-12-10 13:00:03'
  ),
  ('TEST07', 1
    , '{"1": {"status": "xx","type" : "receive","moni_time": "2020-01-01 00:00:01" }, "profile": { "status": "xx", "type" : "request", "moni_time": "2020-01-01 00:00:01" }, "exam_rst": { "status": "xx", "type" : "send", "moni_time": "2020-01-01 00:00:01"} }'
    , '{ "status": "01", "moni_time": "2020-01-01 00:00:01" }'
    , '2019-12-10 12:50:00'
    , '2019-12-10 13:00:03'
  );

INSERT INTO
  mst_if_edge
  (
  serial_no
  , facility_cd
  , if_edge_no
  , if_edge_name
  , is_disp
  , is_del
  , setting_date
  , delete_date
  , memo
  , reg_date
  , up_date
  )
  VALUES
  ('1', 'TEST05', 1, 'test1', '1', '0', '2019-12-10 12:50:00', NULL, 'memo1', '2019-12-10 12:50:00', '2019-12-10 13:00:03'),
  ('2', 'TEST06', 1, 'test2', '1', '0', '2019-12-10 11:50:00', NULL, 'memo2', '2019-12-10 11:50:00', '2019-12-10 11:50:00'),
  ('3', 'TEST07', 1, 'test3', '1', '0', '2019-12-10 11:50:00', NULL, 'memo3', '2019-12-10 11:50:00', '2019-12-10 11:50:00');

INSERT INTO
  mst_coop_facility
  (
  ctl_no
  , facility_cd
  , reg_date
  , up_date
  , if_edge_setting
  , common_setting
  , user_id
  )
  VALUES
  (
    1
    , 'TEST06'
    , '2019-11-12 15:00:00'
    , '2019-11-12 15:00:00'
    , '{"receive": {"pat": {"data": "C:\\work\\tmpDir\\data", "watch": "C:\\work\\tmpDir\\watch", "protocol": "file"}}, "facility_cd": "1"}'
    , '{"coop_ord_cd": [ {"ord_cd": "0", "createIndex" : "true"}, {"ord_cd": "1"} ] }'
    , 1
  );
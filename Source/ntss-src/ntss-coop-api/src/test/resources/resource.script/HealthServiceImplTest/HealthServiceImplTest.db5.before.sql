TRUNCATE sys_coop_journal RESTART IDENTITY;
DELETE FROM mnt_if_edge_healthmon;
DELETE FROM mst_if_edge;

INSERT INTO
  sys_coop_journal
  (
  ctl_no
  , facility_cd
  , coop_cd
  , coop_cd_index
  , crud
  , direction
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
  (9999999, '000001', 'ini_dial', '', 'C' , 'S' , '0' , '2019-11-12 15:00:00' , '2019-11-12 15:00:00' , '0' , '2019-11-12 15:00:00' , '2019-11-12 15:00:00' , null, null , '1' , current_timestamp , current_timestamp , '0'),
  (999999, '000001', 'dummy', '', 'C' , 'S' , '0' , '2019-11-12 15:00:00' , '2019-11-12 15:00:00' , '0' , '2019-11-12 15:00:00' , '2019-11-12 15:00:00' , null, null , '1' , current_timestamp , current_timestamp , '0');

INSERT INTO
  mnt_if_edge_healthmon
  (
  ctl_no
  , facility_cd
  , if_edge_no
  , healthmon_facility_conn
  , healthmon_server_conn
  , reg_date
  , up_date
  )
  VALUES
  (1, '000001', 1
    , '{"ini_dial": {"status": "01","type" : "receive","moni_time": "2020-01-01 00:00:01" }, "profile": { "status": "01", "type" : "request", "moni_time": "2020-01-01 00:00:01" }, "exam_rst": { "status": "01", "type" : "send", "moni_time": "2020-01-01 00:00:01"} }'
    , '{ "status": "01", "moni_time": "2020-01-01 00:00:01" }'
    , '2019-12-10 12:50:00'
    , '2019-12-10 13:00:03'
  ),
  (2, '000011', 3
    , '{"ini_dial": {"status": "xx","type" : "receive","moni_time": "2020-01-01 00:00:01" }, "profile": { "status": "xx", "type" : "request", "moni_time": "2020-01-01 00:00:01" }, "exam_rst": { "status": "xx", "type" : "send", "moni_time": "2020-01-01 00:00:01"} }'
    , '{ }'
    , '2019-12-10 11:50:00'
    , '2019-12-10 19:00:03'
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
  ('1', '000001', 1, 'test1', '1', '0', '2019-12-10 12:50:00', NULL, 'memo1', '2019-12-10 12:50:00', '2019-12-10 13:00:03'),
  ('2', '000011', 3, 'test2', '1', '0', '2019-12-10 11:50:00', NULL, 'memo2', '2019-12-10 11:50:00', '2019-12-10 11:50:00');

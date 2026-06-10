DELETE FROM mnt_if_edge_healthmon;
DELETE FROM mst_if_edge;

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
  (1, '000001', 12
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
  ('1', '000001', 12, 'test1', '1', '0', '2019-12-10 12:50:00', NULL, 'memo1', '2019-12-10 12:50:00', '2019-12-10 13:00:03'),
  ('2', '000011', 3, 'test2', '1', '0', '2019-12-10 11:50:00', NULL, 'memo2', '2019-12-10 11:50:00', '2019-12-10 11:50:00');

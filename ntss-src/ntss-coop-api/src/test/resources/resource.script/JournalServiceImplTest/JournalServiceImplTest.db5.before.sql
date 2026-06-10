TRUNCATE sys_coop_journal;
DELETE FROM mst_coop_facility;

SELECT setval('sys_coop_journal_ctl_no_seq', 12345);

INSERT INTO
  sys_coop_journal
  (
  facility_cd
  , ctl_no
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
  , is_editable
  , reg_date
  , up_date
  , is_del
  )
  VALUES
  (
    'TEST02'
    , 1
    , '1'
    , ''
    , 'C'
    , 'S'
    , '0'
    , '2019-11-12 15:00:00'
    , '2019-11-12 15:00:00'
    , '0'
    , '2019-11-12 15:00:00'
    , '2019-11-12 15:00:00'
    , 'DUMMY'
    , '1'
    , current_timestamp
    , current_timestamp
    , '0'
  );

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
    , 'TEST01'
    , '2019-11-12 15:00:00'
    , '2019-11-12 15:00:00'
    , '{"receive": {"pat": {"data": "C:\\work\\tmpDir\\data", "watch": "C:\\work\\tmpDir\\watch", "protocol": "file"}}, "facility_cd": "1"}'
    , '{"coop_ord_cd": [ {"ord_cd": "0", "createIndex": "true"}, {"ord_cd": "1"} ] }'
    , 1
  );

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
    2
    , 'TEST03'
    , '2019-11-12 15:00:00'
    , '2019-11-12 15:00:00'
    , '{"receive": {"pat": {"data": "C:\\work\\tmpDir\\data", "watch": "C:\\work\\tmpDir\\watch", "protocol": "file"}}, "facility_cd": "1"}'
    , '{"coop_ord_cd": [ {"ord_cd": "0", "createIndex": "true"}, {"ord_cd": "1"},{"ord_cd": "2", "is_get_no":"true"}] }'
    , 1
  );

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
    3
    , 'TEST04'
    , '2019-11-12 15:00:00'
    , '2019-11-12 15:00:00'
    , '{"receive": {"pat": {"data": "C:\\work\\tmpDir\\data", "watch": "C:\\work\\tmpDir\\watch", "protocol": "file"}}, "facility_cd": "1"}'
    , '{"coop_ord_cd": [ {"ord_cd": "0", "createIndex": "true"}, {"ord_cd": "1"},{"ord_cd": "2", "is_get_no":"false"} ] }'
    , 1
  );

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
  (4, 'ERROR1', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '{}', '{"coop_ord_cd": [ {"ord_cd": "rep_dial", "report": true} ] }', 1),
  (5, 'TEST05', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '{}', '{"coop_ord_cd": [ {"ord_cd": "rep_dial", "report": true} ], "report_type": [{"rep_dial": "xml"}] }', 1),
  (6, 'TEST06', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '{}', '{"coop_ord_cd": [ {"ord_cd": "rep_dial", "report": true} ], "report_type": [{"rep_dial": "pdf"}] }', 1),
  (7, 'TEST07', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '{}', '{"coop_ord_cd": [ {"ord_cd": "rep_dial", "report": true} ], "report_type": [{"rep_dial": "tar"}] }', 1),
  (8, 'TEST08', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '{}', '{"coop_ord_cd": [ {"ord_cd": "rep_dial", "report": true} ], "report_type": [{"rep_dial": "xmlpdf"}] }', 1),
  (9, 'TEST09', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '{}', '{"coop_ord_cd": [ {"ord_cd": "rep_dial", "report": true} ], "report_type": [{"rep_dial": "pdfxml"}] }', 1);


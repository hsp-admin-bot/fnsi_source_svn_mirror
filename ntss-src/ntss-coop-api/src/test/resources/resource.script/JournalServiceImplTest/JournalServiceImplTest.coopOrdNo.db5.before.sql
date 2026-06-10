TRUNCATE sys_coop_journal;
DELETE FROM mst_coop_facility;
TRUNCATE sys_coop_no;
TRUNCATE ord_coop_no;

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
  sys_coop_no
  (
  ctl_no
  , facility_cd
  , coop_ord_cd
  , cur_coop_ord_no
  , no_of_digit
  , padding_char
  , padding_pos
  , range_max
  , range_min
  , prefix_char
  , suffix_char
  , is_del
  , user_id
  , reg_date
  , up_date
  )
  VALUES
  (
    1
    , 'TEST01'
    , '[{"ord_cd": "ini_dial"}, {"ord_cd": "1"}]'
    , 1
    , 10
    , '0'
    , 'left'
    , 10000
    , 0
    , 'A'
    , 'Z'
    , '0'
    , 1
    , '2020-03-09 15:00:00'
    , '2020-03-09 15:00:00'
  );

INSERT INTO
  ord_coop_no
  (
    facility_cd
    , pat_id
    , ord_no
    , coop_cd
    , coop_ord_no
    , is_disp
    , is_del
    , user_id
    , reg_date
    , up_date
  )
  VALUES
    ('TEST01', 201, 100, '1', 'A0000000001Z', 1, 0, 1, '2019-11-12 15:00:00', '2019-11-12 15:00:00')
  , ('TEST01', 202, 102, '1', 'A0000000001Z', 1, 0, 1, '2019-11-12 15:00:00', '2019-11-12 15:00:00')
  , ('TEST01', 202, 100, '2', 'A0000000002Z', 1, 0, 1, '2019-11-12 15:00:00', '2019-11-12 15:00:00')
  , ('TEST01', 203, 100, '1', 'A0000000003Z', 1, 0, 1, '2019-11-12 15:00:00', '2019-11-12 15:00:00')
  , ('TEST01', 202, 101, '1', 'A0000000004Z', 1, 1, 1, '2019-11-12 15:00:00', '2019-11-12 15:00:00')
;

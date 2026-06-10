DELETE FROM mst_coop_facility;

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
   , '{"coop_ord_cd": [ {"ord_cd": "0"}, {"ord_cd": "1"} ] }'
   , 1
   );

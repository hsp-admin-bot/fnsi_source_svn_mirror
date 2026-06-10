DELETE FROM ord_main;

INSERT INTO
  ord_main
  (
    ord_no
    , pat_id
    , facility_cd
    , rst_device_set_info
    , is_del
  )
VALUES
  (
    1
    , 11
    , '009999'
    , '{"cd": 11, "name": "name11"}'
    , '0'
  )
  ,(
    2
    , 12
    , '009999'
    , '{"cd": 11, "name": "name11"}'
    , '1'
  )
;

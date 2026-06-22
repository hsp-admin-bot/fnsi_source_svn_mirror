DELETE FROM ord_main;

INSERT INTO
  ord_main
  (
    ord_no
    , rst_dialysis_state
    , rst_equip_info
    , is_del
    , up_date
    , reg_date
  )
VALUES
  (
    1
    , '0'
    , '[{"cd": 1, "name": "name1"}, {"cd": 2, "name": "name2"}]'
    , '0'
    , '2019-03-25 13:00:00'
    , '2019-03-25 13:10:00'
  )
  ,(
    2
    , '0'
    , '[{"no": 0, "cd": 1, "name": "name1"}]'
    , '1'
    , '2019-03-25 13:00:00'
    , '2019-03-25 13:10:00'
  )
;

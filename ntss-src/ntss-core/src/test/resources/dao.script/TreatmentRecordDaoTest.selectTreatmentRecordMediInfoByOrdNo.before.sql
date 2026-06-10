DELETE FROM ord_main;

INSERT INTO
  ord_main
  (
    ord_no
    , treat_date
    , rst_dialysis_state
    , rst_start_date
    , rst_medi_info
    , is_del
    , up_date
    , reg_date
  )
VALUES
  (
    1
    , '20190201'
    , '0'
    , '2019-03-01 12:00:00'
    , '[{"cd": 1, "name": "name1"}, {"cd": 2, "name": "name2"}]'
    , '0'
    , '2019-03-01 13:00:00'
    , '2019-03-01 13:10:00'
  )
  ,(
    2
    , '20190202'
    , '0'
    , '2019-03-02 12:00:00'
    , '[{"no": 0, "cd": 1, "name": "name1"}]'
    , '1'
    , '2019-03-02 13:00:00'
    , '2019-03-02 13:10:00'
  )
;

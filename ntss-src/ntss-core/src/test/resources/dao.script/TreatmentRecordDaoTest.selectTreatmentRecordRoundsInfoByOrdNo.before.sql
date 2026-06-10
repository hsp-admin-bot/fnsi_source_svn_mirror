DELETE FROM ord_main;

INSERT INTO
  ord_main
  (
    ord_no
    , rst_rounds_info
    , up_date
    , reg_date
  )
VALUES
  (
    1
    , '[{"cd": 1, "name": "name1"}, {"cd": 2, "name": "name2"}]'
    , '2019-03-01 13:00:00'
    , '2019-03-01 13:10:00'
  ),
  (
    2
    , null
    , '2019-03-01 13:00:00'
    , '2019-03-01 13:10:00'
  )
;

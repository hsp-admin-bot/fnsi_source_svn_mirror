DELETE FROM ord_main;

INSERT INTO
  ord_main
  (
    ord_no
    , pat_id
    , facility_cd
    , rst_start_date
    , treat_date
    , rst_vital_info
    , is_del
    , up_date
    , reg_date
  )
VALUES
  (
    1
    , 2
    , '009999'
    , '2019/05/10 13:10:00.000'
    , '20190416'
    , '[{"cd": 1, "name": "name1"}, {"cd": 2, "name": "name2"}]'
    , '0'
    , '2019-03-01 13:00:00'
    , '2019-03-01 13:10:00'
  )
  ,(
    2
    , 2
    , '009999'
    , '2019/05/10 13:11:00.000'
    , '20190416'
    , '[{"cd": 1, "name": "name1"}, {"cd": 2, "name": "name2"}]'
    , '1'
    , '2019-03-02 13:00:00'
    , '2019-03-02 13:10:00'
  )
;

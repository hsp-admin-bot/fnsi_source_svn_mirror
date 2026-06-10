DELETE FROM ord_main;

INSERT INTO
  ord_main
  (
    ord_no
    , pat_id
    , facility_cd
    , treat_date
    , rst_kur_cd
    , rst_treatment_cd
    , rst_ind_comment_info
    , is_del
    , up_date
    , reg_date
  )
VALUES
  (
    1
    , 10
    , '009999'
    , '20190415'
    , 20
    , 30
    , '[{"cd": 1, "name": "name1"}, {"cd": 2, "name": "name2"}]'
    , '0'
    , '2019-03-01 13:00:00'
    , '2019-03-01 13:10:00'
  )
  ,(
    2
    , 2
    , '009999'
    , '20190416'
    , 3
    , 4
    , '[{"cd": 1, "name": "name1"}, {"cd": 2, "name": "name2"}]'
    , '1'
    , '2019-03-02 13:00:00'
    , '2019-03-02 13:10:00'
  )
;

DELETE FROM ord_main;

INSERT INTO
  ord_main
  (
    ord_no
    , pat_id
    , facility_cd
    , treat_date
    , ind_kur_cd
    , ind_treatment_cd
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
    , 2
    , '009999'
    , '20190416'
    , 1001
    , 1002
    , 3
    , 4
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
    , 1001
    , 1002
    , 3
    , 4
    , '[{"cd": 1, "name": "name1"}, {"cd": 2, "name": "name2"}]'
    , '1'
    , '2019-03-02 13:00:00'
    , '2019-03-02 13:10:00'
  )
;

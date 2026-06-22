DELETE FROM ord_main;

INSERT INTO
  ord_main
  (
    ord_no
    , pat_id
    , facility_cd
    , rst_start_date
    , rst_end_date
    , rst_complaint_info
    , rst_treatment_info
    , rst_treat_staff_info
    , is_del
    , up_date
    , reg_date
  )
VALUES
  (
    1
    , 2
    , '009999'
    , '2019-05-29 13:00:00'
    , '2019-05-29 18:00:00'
    , '[{"cd": 11, "name": "name11"}, {"cd": 2, "name": "name2"}]'
    , '[{"cd": 12, "name": "name12"}, {"cd": 2, "name": "name2"}]'
    , '[{"cd": 13, "name": "name13"}, {"cd": 2, "name": "name2"}]'
    , '0'
    , '2019-03-01 13:00:00'
    , '2019-03-01 13:10:00'
  )
  ,(
    2
    , 2
    , '009999'
    , '2019-05-29 13:00:00'
    , '2019-05-29 18:00:00'
    , '[{"cd": 11, "name": "name11"}, {"cd": 2, "name": "name2"}]'
    , '[{"cd": 12, "name": "name12"}, {"cd": 2, "name": "name2"}]'
    , '[{"cd": 13, "name": "name13"}, {"cd": 2, "name": "name2"}]'
    , '1'
    , '2019-03-02 13:00:00'
    , '2019-03-02 13:10:00'
  )
;

INSERT INTO
  ord_main
  (
    ord_no
    , pat_id
    , facility_cd
    , rst_start_date
    , rst_edition
    , rst_is_update_edition
    , rst_dialysis_state
    , is_del
    , up_date
    , reg_date
  )
VALUES
  (
    100001
    , 1
    , '009999'
    , '2019/08/27 12:00:00.000'
    , 0
    , '0'
    , '6'
    , '0'
    , '2019/08/27 12:00:00.000'
    , '2019/08/27 13:00:00.000'
  )
  ,(
    100002
    , 1
    , '009999'
    , '2019/08/27 12:00:00.000'
    , 0
    , '0'
    , '1'
    , '0'
    , '2019/08/27 12:00:00.000'
    , '2019/08/27 13:00:00.000'
  )
;

DELETE FROM ord_main;

INSERT INTO
  ord_main
  (
    ord_no
    , facility_cd
    , treat_date
    , treat_week
    , rst_dialysis_state
    , rst_bed_cd
    , rst_bed_name
    , rst_kur_cd
    , rst_kur_name
    , rst_treatment_cd
    , rst_treatment_name
    , is_del
  )
VALUES
  (
    1
    , '009999'
    , '20190412'
    , 5
    , '1'
    , 1
    , 'ベッド１'
    , 2
    , 'クール１'
    , 3
    , '治療方法１'
    , '0'
  )
  ,(
    2
    , '009999'
    , '20190412'
    , 5
    , '0'
    , 1
    , 'ベッド１'
    , 2
    , 'クール１'
    , 3
    , '治療方法１'
    , '1'
  )
;

DELETE FROM pat_personal_main;
INSERT INTO
  pat_personal_main
  (
    pat_id
    , fn_pat_id
    , hosp_pat_id
    , facility_cd
    , is_del
    , up_date
    , reg_date
  )
VALUES
  (
    1
    , '1'
    , '000000000001'
    , '009991'
    , '0'
    , '2019-05-29 17:24:00.000'
    , '2019-05-29 17:24:00.000'
  )
  ,(
     2
     , '2'
     , '000000000002'
     , '009992'
     , '1'
     , '2019-05-29 17:24:00.000'
     , '2019-05-29 17:24:00.000'
  )
;

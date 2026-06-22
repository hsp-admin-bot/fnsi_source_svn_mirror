DELETE FROM sys_coop_journal;
INSERT INTO
  sys_coop_journal
  (
  facility_cd
  , ctl_no
  , coop_cd
  , coop_cd_index
  , crud
  , direction
  , ana_result
  , out_reg_date
  , out_ana_date
  , coop_result
  , in_reg_date
  , in_ana_date
  , dump_path
  , is_editable
  , reg_date
  , up_date
  , is_del
  )
  VALUES
  (
    'TEST01'
    , 1
    , '1'
    , ''
    , 'C'
    , 'S'
    , '9'
    , '2019-11-12 15:00:00'
    , '2019-11-12 15:00:00'
    , '0'
    , '2019-11-12 15:00:00'
    , '2019-11-12 15:00:00'
    , 'TEST.txt'
    , '1'
    , '2019-11-12 15:00:00'
    , '2019-11-12 15:00:00'
    , '0'
  ),
  (
    'TEST01'
    , 3
    , '1'
    , ''
    , 'R'
    , 'R'
    , '0'
    , '2019-11-12 15:00:00'
    , '2019-11-12 15:00:00'
    , '0'
    , '2019-11-12 15:00:00'
    , '2019-11-12 15:00:00'
    , 'TEST3.txt'
    , '1'
    , '2019-11-12 15:00:00'
    , '2019-11-12 15:00:00'
    , '0'
  );
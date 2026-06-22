DELETE FROM mst_facility where facility_cd in ('1001', '1002', '1003', '9999');
INSERT INTO
  mst_facility
  (
    facility_cd
    , facility_name
  )
VALUES
  (
    '1001'
    , 'sisetu1'
  )
  , (
    '1002'
    , 'sisetu2'
  )
  , (
    '1003'
    , 'sisetu3'
  )
;

TRUNCATE TABLE mst_selector;
INSERT INTO
  mst_selector
  (
    facility_cd
    , master_physical_name
    , order_settings
  )
VALUES
  (
    '1001'
    , 'mst_complaint'
    , '{"items": [ {"code": 1, "name": "name1"}, {"code": 5, "name": "name5"}, {"code": 4, "name": "name4"} ]}'
  ),
  (
    '1001'
    , 'mst_comp_treatment'
    , '{"items": [ {"code": 1, "name": "name1"}, {"code": 5, "name": "name5"}, {"code": 4, "name": "name4"} ]}'
   )
;

TRUNCATE TABLE mst_complaint;
INSERT INTO
  mst_complaint
  (
    complaint_cd
    , facility_cd
    , complaint_name
    , is_disp
    , is_del
    , reg_date
    , up_date
  )
VALUES
  (
    1
    , '1001'
    , 'name1'
    , '1'
    , '0'
    , '2019-07-08 13:00:00'
    , '2019-07-08 14:00:00'
  )
  , (
    2
    , '1001'
    , 'name2'
    , '0'
    , '0'
    , '2019-07-08 13:00:00'
    , '2019-07-08 14:00:00'
  )
  , (
    3
    , '1001'
    , 'name3'
    , '0'
    , '0'
    , '2019-07-08 13:00:00'
    , '2019-07-08 14:00:00'
  )
  , (
    4
    , '1001'
    , 'name4'
    , '1'
    , '0'
    , '2019-07-08 13:00:00'
    , '2019-07-08 14:00:00'
  )
  , (
    5
    , '1001'
    , 'name5'
    , '1'
    , '0'
    , '2019-07-08 13:00:00'
    , '2019-07-08 14:00:00'
  )
  , (
    6
    , '1001'
    , 'name6'
    , '1'
    , '1'
    , '2019-07-08 13:00:00'
    , '2019-07-08 14:00:00'
  )
  , (
    7
    , '1003'
    , 'name7'
    , '0'
    , '0'
    , '2019-07-08 13:00:00'
    , '2019-07-08 14:00:00'
  )
;
SELECT setval('mst_complaint_complaint_cd_seq', 7);

TRUNCATE TABLE mst_comp_treatment;
INSERT INTO
  mst_comp_treatment
  (
    comp_treatment_cd
    , facility_cd
    , treatment
    , treat_class
    , treat_medicine_cd
    , amount
    , procedure_cd
    , take_medicine_cd
    , is_disp
    , is_del
    , reg_date
    , up_date
  )
VALUES
  (
    1
    , '1001'
    , 'name1'
    , '2'
    , null
    , null
    , null
    , null
    , '1'
    , '0'
    , '2019-07-08 13:00:00'
    , '2019-07-08 14:00:00'
  )
  , (
    2
    , '1001'
    , 'name2'
    , '2'
    , null
    , null
    , null
    , null
    , '0'
    , '0'
    , '2019-07-08 13:00:00'
    , '2019-07-08 14:00:00'
  )
  , (
    3
    , '1001'
    , 'name3'
    , '2'
    , null
    , null
    , null
    , null
    , '0'
    , '0'
    , '2019-07-08 13:00:00'
    , '2019-07-08 14:00:00'
  )
  , (
    4
    , '1001'
    , 'name4'
    , '1'
    , 2
    , 3.12
    , 4
    , 5
    , '1'
    , '0'
    , '2019-07-08 13:00:00'
    , '2019-07-08 14:00:00'
  )
  , (
    5
    , '1001'
    , 'name5'
    , '0'
    , 12
    , 13.12
    , 14
    , 15
    , '1'
    , '0'
    , '2019-07-08 13:00:00'
    , '2019-07-08 14:00:00'
  )
  , (
    6
    , '1001'
    , 'name6'
    , '2'
    , null
    , null
    , null
    , null
    , '1'
    , '1'
    , '2019-07-08 13:00:00'
    , '2019-07-08 14:00:00'
  )
  , (
    7
    , '1003'
    , 'name7'
    , '2'
    , null
    , null
    , null
    , null
    , '0'
    , '0'
    , '2019-07-08 13:00:00'
    , '2019-07-08 14:00:00'
  )
;
SELECT setval('mst_comp_treatment_comp_treatment_cd_seq', 7);

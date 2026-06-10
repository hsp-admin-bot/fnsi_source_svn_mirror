TRUNCATE TABLE mst_facility CASCADE;
TRUNCATE TABLE mst_destination_group CASCADE;

INSERT INTO
  mst_facility
  (
    facility_cd
    , facility_name
    , facility_name_kana
    , department_cd
    , prefectures_cd
  )
VALUES
   (
     '000001'
     , 'テスト施設1'
     , 'テストシセツ1'
     , '9001'
     , '01'
   ),
   (
     '000002'
     , 'テスト施設2'
     , 'テストシセツ2'
     , '9002'
     , '02'
   )
;

INSERT INTO
  mst_destination_group
  (
    destination_group_cd
    , facility_cd
    , destination_group_name
    , destination_target
    , is_disp
    , is_del
  )
VALUES
  (
    1
    , '000001'
    , 'グループ1'
    , '{"users":[]}'
    , '1'
    , '0'
  ),
  (
    2
    , '000001'
    , 'グループ2'
    , '{"users":[]}'
    , '1'
    , '0'
  ),
  (
    3
    , '000001'
    , 'グループ3'
    , '{"users":[]}'
    , '1'
    , '0'
  ),
  (
    4
    , '000002'
    , 'グループ1'
    , '{"users":[]}'
    , '1'
    , '0'
  ),
  (
    5
    , '000002'
    , 'グループ1'
    , '{"users":[]}'
    , '1'
    , '0'
  )
;

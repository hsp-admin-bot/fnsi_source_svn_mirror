DELETE FROM mst_staff_facility;
DELETE FROM mst_alarm_notification;
DELETE FROM mst_destination_group;
delete from mst_checklist;
DELETE FROM mst_device_set_info_default;
DELETE FROM mst_facility;

INSERT INTO
  mst_facility
  (
    facility_cd
    , facility_name
  )
VALUES
  (
    '0001'
    , 'sisetu1'
  )
  , (
    '0002'
    , 'sisetu2'
  )
;

INSERT INTO
  mst_destination_group
  (
    destination_group_cd
    , facility_cd
    , destination_group_name
    , destination_target
  )
VALUES
  (
    1
    , '0001'
    , 'group1'
    , '{
        "users": [
           {
             "user_id": 1000,
             "is_address1_send": true,
             "is_address2_send": true
           }
           , {
             "user_id": 1500,
             "is_address1_send": true,
             "is_address2_send": false
           }
         ]
      }'
  )
  , (
    2
    , '0001'
    , 'group2'
    , '{
        "users": [
           {
             "user_id": 1000,
             "is_address1_send": true,
             "is_address2_send": false
           }
           , {
             "user_id": 2000,
             "is_address1_send": true,
             "is_address2_send": false
           }
         ]
      }'
  )
  , (
    3
    , '0001'
    , 'group3'
    , '{ "users": [] }'
  )
  , (
    4
    , '0001'
    , 'group4'
    , '{ "users": [] }'
  )
  , (
    5
    , '0002'
    , 'group1'
    , '{
        "users": [
           {
             "user_id": 1000,
             "is_address1_send": true,
             "is_address2_send": false
           }
         ]
      }'
  )
;

-- テスト前にmst_staff_facilityにダミー列を追加
ALTER TABLE
  mst_staff_facility
ADD COLUMN dummy character varying(1) -- ダミー列
;

-- テスト前にmst_alarm_notificationにダミー列を追加
ALTER TABLE
  mst_alarm_notification
ADD COLUMN dummy character varying(1) -- ダミー列
;

-- テスト前にmst_destination_groupにダミー列を追加
ALTER TABLE
  mst_destination_group
ADD COLUMN dummy character varying(1) -- ダミー列
;

-- テスト前にmst_checklistにダミー列を追加
ALTER TABLE
  mst_checklist
ADD COLUMN dummy character varying(1) -- ダミー列
;

-- テスト前にmst_facility;にダミー列を追加
ALTER TABLE
  mst_facility
ADD COLUMN dummy character varying(1) -- ダミー列
;

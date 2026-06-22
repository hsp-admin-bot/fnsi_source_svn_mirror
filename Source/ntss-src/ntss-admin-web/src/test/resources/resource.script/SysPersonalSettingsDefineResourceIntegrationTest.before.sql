DELETE FROM sys_personal_settings_define;
DELETE FROM sys_master_define;
DELETE FROM mst_selector;

INSERT INTO
  mst_test_table
  (
    facility_cd
    , die_cd
    , die_name
    , memo
    , test_numeric
  )
VALUES
  (
    '999999'
    ,100
    , 'name1'
    , 'memo1'
    , 11
  ),
  (
    '999999'
    , 200
    , 'name2'
    , 'memo2'
    , 22
  ),
  (
    'cd3'
    , 300
    , 'name3'
    , 'memo3'
    , 33
  ),
  (
    '999999'
    , 400
    , 'name4'
    , 'memo4'
    , 44
  ),
  (
    'cd5'
    , 500
    , 'name5'
    , 'memo5'
    , 55
  )
;

INSERT INTO
  mst_selector(
    facility_cd
    , master_physical_name
    , order_settings
  )
VALUES
  (
    '999999'
    , 'mst_test_table'
    , '{
        "items": [
          {"code": 100, "name": "name1"}
          , {"code": 400, "name": "name4"}
          , {"code": 200, "name": "name2"}
        ]
      }'
  ),
  (
    '009998'
    , 'mst_test_table'
    , '{
        "items": [
          {"code": 111, "name": "name111"}
          , {"code": 222, "name": "name222"}
        ]
      }'
  )
;

INSERT INTO
  sys_personal_settings_define(
    personal_settings_cd
    , tab_define_cd
    , edit_level
    , item_info
    , combo_data
    , reference_combo_def
  )
VALUES
  (11, 1, '1',
  '{
    "item_info": [
      {
        "type": "string",
        "title": "項目3-1",
        "identifier": "1"
      },
      {
        "type": "number",
        "title": "項目3-2",
        "identifier": "2",
        "validation": {
          "max": 5000,
          "min": null
         }
      },
      {
        "type": "combo2",
        "title": "項目3-4",
        "identifier": "4",
        "validation": {
          "maxlength": 100,
          "min": 0.5,
          "max": 100,
          "digit": 2,
          "required": true
        }
      }
    ]
  }',
  '{
    "combos": [
      {
        "values": [
          {"text": "データ1", "value": 1},
          {"text": "データ2", "value": 2},
          {"text": "データ5", "value": 5}
        ],
        "setting_identifier": "1"
      }
      ,{
        "values": [
          {"text": "データ6", "value": "hoge"},
          {"text": "データ7", "value": "fuga"}
        ],
        "setting_identifier": "2"
      }
    ]
  }',
  '{
    "combos": [
      {
        "target_table": {
          "name": "mst_test_table",
          "identifier": "die_cd",
          "display_column": "die_name",
          "referenced_column": "die_cd"
        },
        "setting_identifier": "4"
      }
    ]
  }')
;

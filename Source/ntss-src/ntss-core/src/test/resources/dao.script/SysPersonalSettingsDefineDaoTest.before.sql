DELETE FROM sys_personal_settings_define;

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
  (1, 11, '1',
  '{
    "item_info": [
      {
        "type": "string",
        "title": "項目3-1",
        "identifier": "1",
        "validation": {
          "required": true,
          "maxlength": 4
        }
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
        "identifier": "4"
      }
    ]
  }',
  '{
    "combos": [
      {
        "values": [
          { "text": "データ1", "value": 1},
          {"text": "データ2", "value": 2},
          {"text": "データ5", "value": 5}
        ],
        "setting_identifier": "1"
      }
      ,{
        "values": [
          {"text": "データ6", "value": 6},
          {"text": "データ7", "value": 7}
        ],
        "setting_identifier": "2"
      }
    ]
  }',
  '{
    "combos": [
      {
        "target_table": {
          "name": "mst_treatment",
          "identifier": "treatment_cd",
          "display_column": "treatment_name",
          "referenced_column": "treatment_cd"
        },
        "setting_identifier": "4"
      }
    ]
  }')
, (2, 22, '2',
  '{
    "item_info": [
      {
        "type": "number",
        "title": "項目4-1",
        "identifier": "1",
        "validation": {
          "max": 99999.99,
          "min": 0,
          "digit": 2,
          "required": true
        }
      },
      {
        "type": "combo1",
        "title": "項目4-2",
        "identifier": "2"
      },
      {
        "type": "combo1",
        "title": "項目4-3",
        "identifier": "3",
        "validation": {
          "required": true
        }
      }
    ]
  }',
  '{
    "combos": [
      {
        "setting_identifier": "2",
        "values": [
          {
            "text": "データ21",
            "value": 21
          },
          {
            "text": "データ22",
            "value": 22
          },
          {
            "text": "データ23",
            "value": 23
          },
          {
            "text": "データ24",
            "value": 24
          },
          {
            "text": "データ25",
            "value": 25
          }
        ]
      },
      {
        "setting_identifier": "3",
        "values": [
          {
            "text": "データ31",
            "value": 31
          },
          {
            "text": "データ32",
            "value": 32
          },
          {
            "text": "データ33",
            "value": 33
          },
          {
            "text": "データ34",
            "value": 34
          },
          {
            "text": "データ35",
            "value": 35
          }
        ]
      }
    ]
  }', NULL)
, (3, 33, '4',
  '{
    "item_info": [
      {
        "type": "string",
        "title": "項目6-1",
        "identifier": "1",
        "validation": {
          "required": true,
          "maxlength": 10
        }
      },
      {
        "type": "number",
        "title": "項目6-2",
        "identifier": "2",
        "validation": {
          "max": 9999.999,
          "min": 0,
          "digit": 3,
          "required": true
        }
      }
    ]
  }',
  NULL, NULL)
;

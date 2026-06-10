-- 施設ごとの個人設定タブ定義テーブル
-- 共通設定タブを追加
INSERT INTO mst_personal_tab_define
(facility_cd, display_name, contents_id, disp_order, is_disp, is_del, reg_date, up_date, "mode")
VALUES
    ('009999', '共通タブ（全員）', 'common-tab-contents-3', 3, '1', '0', '2019-07-05 14:20:00.000', '2019-07-05 14:20:00.000', '1')
  , ('009999', '共通タブ（管理者）', 'common-tab-contents-4', 4, '1', '0', '2019-07-05 14:20:00.000', '2019-07-05 14:20:00.000', '1')
  , ('009999', '共通タブ（日機装）', 'common-tab-contents-5', 5, '1', '0', '2019-07-05 14:20:00.000', '2019-07-05 14:20:00.000','1')
  , ('009999', '共通タブ（日機装・管理者）', 'common-tab-contents-6', 6, '1', '0', '2019-07-05 14:20:00.000', '2019-07-05 14:20:00.000', '1')
  , ('009999', '共通タブ（非表示）', 'common-tab-contents-7', 7, '1', '0', '2019-07-05 14:20:00.000', '2019-07-05 14:20:00.000', '1')
;

-- 共通設定タブ定義テーブル
INSERT INTO sys_personal_settings_define
(tab_define_cd, edit_level, item_info, combo_data, reference_combo_def, reg_date, up_date)
VALUES
-- 個別定義の分
  (1, '1', null,null,null, '2019-07-05 14:20:00.000', '2019-07-05 14:20:00.000'),
  (2, '1', null,null,null, '2019-07-05 14:20:00.000', '2019-07-05 14:20:00.000'),
-- 全員に表示される定義
  (3, '1',
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
          "min": 10
         }
       },
       {
        "type": "combo1",
        "title": "項目3-3",
        "identifier": "3",
        "validation": {
          "required": true
        }
       },
      {
        "type": "combo1",
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
          {"text": "データ3", "value": 3},
          {"text": "データ4", "value": 4},
          {"text": "データ5", "value": 5}
        ],
        "setting_identifier": "3"
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
  }', '2019-07-05 14:20:00.000', '2019-07-05 14:20:00.000')
-- 管理者のみ表示のデータ
, (4, '2',
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
  }', NULL, '2019-07-05 14:20:00.000', '2019-07-05 14:20:00.000')
-- 日機装社員のみ表示のデータ
, (5, '3',
  '{
    "item_info": [
      {
        "type": "combo2",
        "title": "項目5-1",
        "identifier": "1"
      },
      {
        "type": "combo2",
        "title": "項目5-2",
        "identifier": "2",
        "validation": {
          "required": true
        }
      }
    ]
  }',
  NULL,
  '{
    "combos": [
      {
        "setting_identifier": "1",
        "target_table": {
          "name": "mst_kur",
          "identifier": "kur_cd",
          "display_column": "kur_name",
          "referenced_column": "kur_cd"
        }
      },
      {
        "setting_identifier": "2",
        "target_table": {
          "name": "mst_course",
          "identifier": "course_cd",
          "display_column": "course_name",
          "referenced_column": "course_cd"
        }
      }
    ]
  }', '2019-07-05 14:20:00.000', '2019-07-05 14:20:00.000')
-- 日機装社員または管理者のみ表示のデータ
, (6, '4',
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
  NULL, NULL, '2019-07-05 14:20:00.000', '2019-07-05 14:20:00.000')
-- 非表示のデータ
, (7, '0',
  '{
    "item_info": [
      {
        "type": "string",
        "title": "項目7-1",
        "identifier": "1",
        "validation": {
          "maxlength": 6
        }
      },
      {
        "type": "number",
        "title": "項目7-2",
        "identifier": "2",
        "validation": {
          "max": 9999,
          "min": 0
        }
      }
    ]
  }',
  NULL, NULL, '2019-07-05 14:20:00.000', '2019-07-05 14:20:00.000')
;

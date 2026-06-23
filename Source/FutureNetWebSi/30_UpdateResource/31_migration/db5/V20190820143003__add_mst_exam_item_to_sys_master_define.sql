---------------------------------------------------
-- sys_master_defineの項目追加
---------------------------------------------------
-- 検査項目マスタの項目を追加
delete from sys_master_define where master_physical_name = 'mst_exam_item';
insert into sys_master_define(
  master_physical_name
  , master_name
  , disp_class
  , mode
  , allow_sort
  , allow_add_record
  , disp_order
  , column_info
  , combo_data
  , reg_date
  , up_date
  , reference_combo_def
  , edit_level
)
values (
  'mst_exam_item'
  , '検査項目マスタ'
  , '2'
  , '1'
  , '1'
  , '1'
  , 553
  , '{
    "fields": [
      {
        "type": "number",
        "alias": "code",
        "title": "検査項目コード",
        "hidden":"false",
        "physical_name": "exam_item_cd"
      },
      {
        "type": "string",
        "alias": "name",
        "title": "検査項目名",
        "validation": {
          "required": "true",
          "maxlength": 40
        },
        "hidden":"false",
        "editable":"false",
        "physical_name": "exam_item_name"
      },
      {
        "type":"modal",
        "title":"詳細",
        "hidden":"false",
        "physical_name":"data_type",
        "editable":"true"
      },
      {
        "type": "combo1",
        "title": "データ形式",
        "hidden":"true",
        "physical_name": "data_type"
      },
      {
        "type": "string",
        "title": "単位",
        "validation": {
          "required": "false",
          "maxlength": 20
        },
        "hidden":"true",
        "physical_name": "unit"
      },
      {
        "type": "combo1",
        "title": "正常値区分",
        "hidden":"true",
        "physical_name": "normal_value_class"
      },
      {
        "type": "number",
        "title": "正常値(上限)",
        "format": "n2",
        "validation": {
          "max": 99999999.99,
          "min": 0.0
        },
        "hidden":"true",
        "physical_name": "normal_value_upper"
      },
      {
        "type": "number",
        "title": "正常値(下限)",
        "format": "n2",
        "validation": {
          "max": 99999999.99,
          "min": 0.0
        },
        "hidden":"true",
        "physical_name": "normal_value_lower"
      },
      {
        "type": "number",
        "title": "正常値(男性上限)",
        "format": "n2",
        "validation": {
          "max": 99999999.99,
          "min": 0.0
        },
        "hidden":"true",
        "physical_name": "normal_value_upper_m"
      },
      {
        "type": "number",
        "title": "正常値(男性下限)",
        "format": "n2",
        "validation": {
          "max": 99999999.99,
          "min": 0.0
        },
        "hidden":"true",
        "physical_name": "normal_value_lower_m"
      },
      {
        "type": "number",
        "title": "正常値(女性上限)",
        "format": "n2",
        "validation": {
          "max": 99999999.99,
          "min": 0.0
        },
        "hidden":"true",
        "physical_name": "normal_value_upper_w"
      },
      {
        "type": "number",
        "title": "正常値(女性下限)",
        "format": "n2",
        "validation": {
          "max": 99999999.99,
          "min": 0.0
        },
        "hidden":"true",
        "physical_name": "normal_value_lower_w"
      },
      {
        "type": "number",
        "title": "入力整数部桁数",
        "validation": {
          "maxlength": 2
        },
        "hidden":"true",
        "physical_name": "input_integer_figure"
      },
      {
        "type": "number",
        "title": "入力小数部桁数",
        "validation": {
          "maxlength": 2
        },
        "hidden":"true",
        "physical_name": "input_decimal_figure"
      },
      {
        "type": "number",
        "title": "入力上限値",
        "format": "n2",
        "validation": {
          "max": 99999999.99,
          "min": 0.0
        },
        "hidden":"true",
        "physical_name": "input_upper"
      },
      {
        "type": "number",
        "title": "入力下限値",
        "format": "n2",
        "validation": {
          "max": 99999999.99,
          "min": 0.0
        },
        "hidden":"true",
        "physical_name": "input_lower"
      },
      {
        "type": "number",
        "title": "グラフ上限値",
        "format": "n2",
        "validation": {
          "max": 99999999.99,
          "min": 0.0
        },
        "hidden":"true",
        "physical_name": "graph_upper"
      },
      {
        "type": "number",
        "title": "グラフ下限値",
        "format": "n2",
        "validation": {
          "max": 99999999.99,
          "min": 0.0
        },
        "hidden":"true",
        "physical_name": "graph_lower"
      },
      {
        "type": "combo1",
        "title": "仮想端末表示対象区分",
        "hidden":"true",
        "physical_name": "console_class"
      },
      {
        "type": "combo1",
        "title": "検査使用区分",
        "hidden":"true",
        "physical_name": "exam_class"
      },
      {
        "type": "string",
        "title": "院内コード１",
        "validation": {
          "required": "false",
          "maxlength": 20
        },
        "hidden":"true",
        "physical_name": "in_hospital_cd1"
      },
      {
        "type": "string",
        "title": "属性コード１",
        "validation": {
          "required": "false",
          "maxlength": 20
        },
        "hidden":"true",
        "physical_name": "sbt_cd1"
      },
      {
        "type": "string",
        "title": "院内コード２",
        "validation": {
          "required": "false",
          "maxlength": 20
        },
        "hidden":"true",
        "physical_name": "in_hospital_cd2"
      },
      {
        "type": "string",
        "title": "属性コード２",
        "validation": {
          "required": "false",
          "maxlength": 20
        },
        "hidden":"true",
        "physical_name": "sbt_cd2"
      },
      {
        "type": "string",
        "title": "院内コード３",
        "validation": {
          "required": "false",
          "maxlength": 20
        },
        "hidden":"true",
        "physical_name": "in_hospital_cd3"
      },
      {
        "type": "string",
        "title": "属性コード３",
        "validation": {
          "required": "false",
          "maxlength": 20
        },
        "hidden":"true",
        "physical_name": "sbt_cd3"
      },
      {
        "type": "combo2",
        "title": "採血管コード",
        "hidden":"true",
        "physical_name": "spitz_cd"
      },
      {
        "type": "string",
        "title": "JLAC10コード",
        "validation": {
          "required": "false",
          "maxlength": 17
        },
        "hidden":"true",
        "physical_name": "jlac10_cd"
      },
      {
        "type": "combo2",
        "title": "感染症",
        "hidden":"true",
        "physical_name": "infection_cd"
      },
      {
        "type": "combo1",
        "title": "システム標準計算検査項目",
        "hidden":"true",
        "physical_name": "default_calc_exam_item_cd"
      },
      {
        "type": "string",
        "title": "計算式領域",
        "validation": {
          "required": "false",
          "maxlength": 40
        },
        "hidden":"true",
        "physical_name": "free_calc"
      },
      {
        "type":"disp",
        "title":"削除",
        "physical_name":"is_disp",
        "hidden":"false",
        "editable":"true",
        "validation":{"required":null,"max":null,"min":null,"maxlength":"1"}
      },
      {
        "type":"del",
        "title":"削除フラグ",
        "physical_name":"is_del",
        "hidden":"true",
        "editable":"true",
        "validation":{"required":null,"max":null,"min":null,"maxlength":"1"}
      }
    ]}'
  , '{
    "combos": [
      {
        "values": [
          {
            "text": "文字",
            "value": "0"
          },
          {
            "text": "数値",
            "value": "1"
          }
        ],
        "physical_name": "data_type"
      },
      {
        "values": [
          {
            "text": "共通",
            "value": "0"
          },
          {
            "text": "男女",
            "value": "1"
          }
        ],
        "physical_name": "normal_value_class"
      },
      {
        "values": [
          {
            "text": "対象外",
            "value": "0"
          },
          {
            "text": "対象",
            "value": "1"
          }
        ],
        "physical_name": "console_class"
      },
      {
        "values": [
          {
            "text": "検査項目",
            "value": "0"
          },
          {
            "text": "システム標準計算項目",
            "value": "1"
          },
          {
            "text": "検査計算項目",
            "value": "2"
          }
        ],
        "physical_name": "exam_class"
      },
      {
        "values": [
          {
            "text": "未使用",
            "value": "0"
          },
          {
            "text": "BUN",
            "value": "1"
          },
          {
            "text": "血清Ca濃度",
            "value": "2"
          },
          {
            "text": "血清アルブミン",
            "value": "3"
          },
          {
            "text": "クレアチニン",
            "value": "4"
          },
          {
            "text": "血清鉄",
            "value": "5"
          },
          {
            "text": "総鉄結合能",
            "value": "6"
          },
          {
            "text": "ヘマトクリット",
            "value": "7"
          },
          {
            "text": "検査計算使用",
            "value": "8"
          }
        ],
        "physical_name": "default_calc_exam_item_cd"
      }
    ]}'
  , now()
  , now()
  , '{
      "combos": [
        {
          "target_table": {
            "name": "mst_spitz",
            "identifier": "spitz_cd",
            "display_column": "spitz_name",
            "referenced_column": "spitz_cd"
          },
          "physical_name": "spitz_cd"
        },
        {
          "target_table": {
            "name": "mst_infection",
            "identifier": "infection_cd",
            "display_column": "infection_name",
            "referenced_column": "infection_cd"
          },
          "physical_name": "infection_cd"
        }
      ]
    }'
  , '2'
);

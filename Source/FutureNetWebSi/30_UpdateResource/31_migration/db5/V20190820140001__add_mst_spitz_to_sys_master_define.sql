---------------------------------------------------
-- sys_master_defineの項目追加　MOR大屋　2019/08/20
---------------------------------------------------
-- 採血管マスタの項目を追加
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
  'mst_spitz'
  , '採血管マスタ'
  , '2'
  , '1'
  , '1'
  , '1'
  , 550
  , '{
    "fields": [
      {
        "type": "number",
        "alias": "code",
        "title": "採血管ID",
        "physical_name": "spitz_cd"
      },
      {
        "type": "string",
        "alias": "name",
        "title": "採血管名",
        "validation": {
          "required": "true",
          "maxlength": 40
        },
        "physical_name": "spitz_name"
      },
      {
        "type": "string",
        "title": "ラベル印字項目",
        "validation": {
          "maxlength": 10
        },
        "physical_name": "label_print"
      },
      {
        "type": "combo1",
        "title": "院内院外フラグ",
        "physical_name": "is_in_hospital"
      },
      {
        "type": "combo1",
        "title": "至急フラグ",
        "physical_name": "emergency_flg"
      },
      {
        "type": "disp",
        "title": "削除",
        "physical_name": "is_disp"
      }
    ]}'
  ,  '{
    "combos": [
      {
        "values": [
          {
            "text": "院内",
            "value": "0"
          },
          {
            "text": "院外",
            "value": "1"
          }
        ],
        "physical_name": "is_in_hospital"
      },
      {
        "values": [
          {
            "text": "通常",
            "value": "0"
          },
          {
            "text": "至急可",
            "value": "1"
          }
        ],
        "physical_name": "emergency_flg"
      }
    ]}'
  , now()
  , now()
  , null
  , '2'
)

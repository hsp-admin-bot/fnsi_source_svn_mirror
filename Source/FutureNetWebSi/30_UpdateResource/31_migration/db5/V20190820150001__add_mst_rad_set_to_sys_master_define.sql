---------------------------------------------------
-- sys_master_defineの項目追加　MOR大屋　2019/08/21
---------------------------------------------------
-- 放射線検査セットマスタの項目を追加
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
  'mst_rad_set'
  , '放射線検査セットマスタ'
  , '2'
  , '1'
  , '1'
  , '1'
  , 556
  , '{
    "fields": [
      {
        "type": "number",
        "alias": "code",
        "title": "放射線検査セットコード",
        "physical_name": "rad_set_cd"
      },
      {
        "type": "string",
        "alias": "name",
        "title": "放射線検査名",
        "validation": {
          "required": "true",
          "maxlength": 40
        },
        "editable": "false",
        "physical_name": "rad_set_name"
      },
      {
        "type": "string",
        "title": "省略 放射線検査名",
        "validation": {
          "maxlength": 40
        },
        "editable": "false",
        "physical_name": "rad_set_abb_name"
      },
      {
        "type": "modal",
        "title": "検査内容"
      },
      {
        "type": "disp",
        "title": "削除",
        "physical_name": "is_disp"
      },
      {
        "type": "json",
        "title": "コード情報",
        "physical_name": "rad_item_info",
        "hidden": "true"
      },
      {
        "type": "string",
        "title": "放射線検査項目コード",
        "validation": {
          "maxlength": 10
        },
        "hidden": "true",
        "physical_name": "fn_exam_set_cd"
      },
      {
        "type": "string",
        "title": "院内コード1",
        "validation": {
          "maxlength": 20
        },
        "hidden": "true",
        "physical_name": "in_hospital_cd1"
      },
      {
        "type": "string",
        "title": "院内コード2",
        "validation": {
          "maxlength": 20
        },
        "hidden": "true",
        "physical_name": "in_hospital_cd2"
      },
      {
        "type": "string",
        "title": "院内コード3",
        "validation": {
          "maxlength": 20
        },
        "hidden": "true",
        "physical_name": "in_hospital_cd3"
      },
      {
        "type": "string",
        "title": "属性コード1",
        "validation": {
          "maxlength": 20
        },
        "hidden": "true",
        "physical_name": "sbt_cd1"
      },
      {
        "type": "string",
        "title": "属性コード2",
        "validation": {
          "maxlength": 20
        },
        "hidden": "true",
        "physical_name": "sbt_cd2"
      },
      {
        "type": "string",
        "title": "属性コード3",
        "validation": {
          "maxlength": 20
        },
        "hidden": "true",
        "physical_name": "sbt_cd3"
      }
    ]}'
  , null
  , now()
  , now()
  , null
  , '2'
)

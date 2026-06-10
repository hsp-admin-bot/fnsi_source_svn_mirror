-- 検査セットマスタの項目を追加
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
  'mst_exam_set'
  , '検査セットマスタ'
  , '2'
  , '1'
  , '1'
  , '1'
  , 554
  , '{
    "fields": [
      {
        "type": "number",
        "alias": "code",
        "title": "検査セットID",
        "physical_name": "exam_set_cd"
      },
      {
        "type": "string",
        "alias": "name",
        "title": "検査セット名",
        "editable": "false",
        "validation": {
          "required": "true",
          "maxlength": 40
        },
        "physical_name": "exam_set_name"
      },
      {
        "type": "string",
        "alias": "shortname",
        "title": "省略検査セット名",
        "editable": "false",
        "validation": {
          "maxlength": 40
        },
        "physical_name": "exam_set_short_name"
      },
      {
        "type": "modal",
        "title": "セット情報"
      },
      {
        "type": "string",
        "alias": "examsetclass",
        "title": "セット使用区分",
        "hidden": "true",
        "physical_name": "exam_set_class"
      },
      {
        "type": "string",
        "alias": "hospitalflg",
        "title": "院内院外フラグ",
        "hidden": "true",
        "physical_name": "is_in_hospital"
      },
      {
        "type": "string",
        "alias": "emergencyflg",
        "title": "至急フラグ",
        "hidden": "true",
        "physical_name": "can_emergency"
      },
      {
        "type": "string",
        "alias": "examtime",
        "title": "その他検査時刻",
        "hidden": "true",
        "physical_name": "other_exam_time"
      },
      {
        "type": "json",
        "alias": "iteminfo",
        "title": "検査項目情報",
        "hidden": "true",
        "physical_name": "exam_item_info"
      },
      {
        "type": "json",
        "alias": "labelinfo",
        "title": "ラベル情報",
        "hidden": "true",
        "physical_name": "label_info"
      },
      {
        "type": "disp",
        "title": "削除",
        "physical_name": "is_disp"
      }
    ]}'
  , null
  , now()
  , now()
  , null
  , '2'
);

---------------------------------------------------
-- sys_master_defineの項目追加　MOR藤野　2019/05/27
---------------------------------------------------
-- 職種マスタの項目を追加
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
  'mst_job'
  , '職種マスタ'
  , '2'
  , '1'
  , '1'
  , '1'
  , 38
  , '{
    "fields": [
      {
        "type": "number",
        "alias": "code",
        "title": "職種コード",
        "physical_name": "job_cd"
      },
      {
        "type": "string",
        "alias": "name",
        "title": "職種名",
        "validation": {
          "required": "true",
          "maxlength": 40
        },
        "physical_name": "job_name"
      },
      {
        "type": "combo1",
        "title": "医師フラグ",
        "physical_name": "is_doctor"
      },
      {
        "type": "json",
        "title": "デフォルトメニュー設定",
        "hidden": "true",
        "validation": {
          "required": "true"
        },
        "defaultValue": "{\"initial_menu_function\": \"005\", \"default_menu_functions\": [\"005\"]}",
        "physical_name": "default_menu_settings"
      },
      {
        "type": "modal",
        "title": "デフォルトメニュー設定",
        "physical_name": "default_menu_settings"
      },
      {
        "type": "disp",
        "title": "削除",
        "physical_name": "is_disp"
      }
    ]}'
  , '{
    "combos": [
      {
        "values": [
          {
            "text": " ",
            "value": "0"
          },
          {
            "text": "医師",
            "value": "1"
          }
        ],
        "physical_name": "is_doctor"
      }
    ]}'
  , now()
  , now()
  , null
  , '2'
);

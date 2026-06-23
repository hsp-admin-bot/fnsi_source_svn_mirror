-- 種別マスタの項目を追加
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
  'mst_round_type'
  , '回診記録マスタ'
  , '2'
  , '1'
  , '1'
  , '1'
  , 530
  , '{
    "fields": [
      {
        "type": "number",
        "alias": "code",
        "title": "種別コード",
        "physical_name": "round_type_cd"
      },
      {
        "type": "string",
        "alias": "name",
        "title": "回診記録カテゴリ",
        "validation": {
          "required": "true",
          "maxlength": 40
        },
        "physical_name": "round_type_name"
      },
      {
        "type": "modal",
        "title": "内容",
        "physical_name": "content"
      },
      {
        "type": "combo1",
        "title": "内容省略フラグ",
        "physical_name": "is_content_omission"
      },
      {
        "type": "combo1",
        "title": "指示コメント転記初期値",
        "physical_name": "comment_post_default"
      },
      {
        "type": "combo1",
        "title": "転記区分初期値",
        "physical_name": "posting_class_default"
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
            "text": "省略しない",
            "value": "0"
          },
          {
            "text": "省略する",
            "value": "1"
          }
        ],
        "physical_name": "is_content_omission"
      },
      {
        "values": [
          {
            "text": "チェックなし",
            "value": "0"
          },
          {
            "text": "チェックあり",
            "value": "1"
          }
        ],
        "physical_name": "comment_post_default"
      },
      {
        "values": [
          {
            "text": "継続",
            "value": "0"
          },
          {
            "text": "当日のみ",
            "value": "1"
          }
        ],
        "physical_name": "posting_class_default"
      }
    ]}'
  , now()
  , now()
  , null
  , '1'
);

UPDATE
  sys_master_define
SET
  column_info =
    '{
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
          "title": "種別名",
          "validation": {
            "required": "true",
            "maxlength": 40
          },
          "physical_name": "round_type_name"
        },
        {
          "type": "string",
          "title": "内容",
          "physical_name": "content",
          "hidden":true
        },
        {
          "type": "modal",
          "title": "内容"
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
        },
        {
          "type": "del",
          "title": "削除フラグ",
          "physical_name": "is_del"
        }
      ]
    }'
WHERE
  master_physical_name = 'mst_round_type';

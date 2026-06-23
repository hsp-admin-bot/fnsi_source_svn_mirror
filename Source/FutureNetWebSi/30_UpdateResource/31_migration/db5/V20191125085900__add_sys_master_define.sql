update sys_master_define
set column_info='{
    "fields": [
        {
            "type": "number",
            "alias": "code",
            "title": "テンプレートコード",
            "physical_name": "template_cd"
        },
        {
            "type": "string",
            "alias": "name",
            "title": "テンプレート名",
            "format": null,
            "hidden": "false",
            "editable": "true",
            "validation": {
                "max": null,
                "min": null,
                "required": "true",
                "maxlength": 20
            },
            "physical_name": "template_name"
        },
        {
            "type": "modal",
            "title": "詳細"
        },
        {
            "type": "number",
            "alias": null,
            "title": "カテゴリコード",
            "format": null,
            "hidden": "true",
            "editable": "false",
            "validation": {
                "max": null,
                "min": null,
                "required": null,
                "maxlength": null
            },
            "physical_name": "category_cd"
        },
        {
            "type": "string",
            "alias": null,
            "title": "VA画像フラグ",
            "format": null,
            "hidden": "true",
            "editable": "false",
            "validation": {
                "max": null,
                "min": null,
                "required": null,
                "maxlength": null
            },
            "physical_name": "is_va"
        },
        {
            "type": "string",
            "alias": null,
            "title": "観察記録対象フラグ",
            "format": null,
            "hidden": "true",
            "editable": "false",
            "validation": {
                "max": null,
                "min": null,
                "required": null,
                "maxlength": null
            },
            "physical_name": "is_observe"
        },
        {
            "type": "string",
            "alias": null,
            "title": "紹介状フラグ",
            "format": null,
            "hidden": "true",
            "editable": "false",
            "validation": {
                "max": null,
                "min": null,
                "required": null,
                "maxlength": null
            },
            "physical_name": "is_intro_letter"
        },
        {
            "type": "json",
            "alias": null,
            "title": "項目情報",
            "format": null,
            "hidden": "true",
            "editable": "false",
            "validation": {
                "max": null,
                "min": null,
                "required": null,
                "maxlength": null
            },
            "physical_name": "input_params"
        },
        {
            "type": "del",
            "title": "削除",
            "physical_name": "is_del"
        },
        {
            "type": "disp",
            "title": "削除",
            "physical_name": "is_disp"
        }
    ]
}'
where master_physical_name='mst_pat_event_data_template'
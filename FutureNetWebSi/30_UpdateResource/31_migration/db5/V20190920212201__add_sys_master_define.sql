-- sys_master_define定義用

delete from sys_master_define where master_physical_name='mst_pat_event_data_template';
insert into sys_master_define
  (master_physical_name,master_name,
  disp_class,mode,allow_sort,allow_add_record,
  disp_order,
  column_info,
  combo_data,reference_combo_def,reg_date,up_date,edit_level
  ) values (
  'mst_pat_event_data_template','患者イベント項目テンプレートマスタ',
  '2','1','1','1',
  null,
  '{"fields": [{"type": "number", "alias": "code", "title": "テンプレートコード", "physical_name": "template_cd"}, {"type": "string", "alias": "name", "title": "テンプレート名", "format": null, "hidden": "false", "editable": "true", "validation": {"max": null, "min": null, "required": "true", "maxlength": 20}, "physical_name": "template_name"}, {"type": "modal", "title": "詳細"}, {"type": "number", "alias": null, "title": "カテゴリコード", "format": null, "hidden": "true", "editable": "false", "validation": {"max": null, "min": null, "required": null, "maxlength": null}, "physical_name": "category_cd"}, {"type": "string", "alias": null, "title": "VA画像フラグ", "format": null, "hidden": "true", "editable": "false", "validation": {"max": null, "min": null, "required": null, "maxlength": null}, "physical_name": "is_va"}, {"type": "string", "alias": null, "title": "観察記録対象フラグ", "format": null, "hidden": "true", "editable": "false", "validation": {"max": null, "min": null, "required": null, "maxlength": null}, "physical_name": "is_observe"}, {"type": "json", "alias": null, "title": "項目情報", "format": null, "hidden": "true", "editable": "false", "validation": {"max": null, "min": null, "required": null, "maxlength": null}, "physical_name": "input_params"}, {"type": "del", "title": "削除", "physical_name": "is_del"}, {"type": "disp", "title": "削除", "physical_name": "is_disp"}]}',
  null,null,now(),now(), '1');



delete from sys_master_define where master_physical_name='mst_trend_graph_template';
insert into sys_master_define
  (master_physical_name,master_name,
  disp_class,mode,allow_sort,allow_add_record,
  disp_order,
  column_info,
  combo_data,reference_combo_def,reg_date,up_date,edit_level
  ) values (
  'mst_trend_graph_template','トレンドグラフテンプレートマスタ',
  '2','1','1','1',
  null,
'{
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
                "maxlength": 50
            },
            "physical_name": "template_name"
        },
        {
            "type": "modal",
            "title": "詳細"
        },
        {
            "type": "string",
            "alias": null,
            "title": "装置種別",
            "format": null,
            "hidden": "true",
            "editable": "false",
            "validation": {
                "max": null,
                "min": null,
                "required": null,
                "maxlength": 3
            },
            "physical_name": "model"
        },
        {
            "type": "number",
            "alias": null,
            "title": "縦軸範囲(右)最大値",
            "format": null,
            "hidden": "true",
            "editable": "false",
            "validation": {
                "max": null,
                "min": null,
                "required": null,
                "maxlength": null
            },
            "physical_name": "vertical_range_right_max"
        },
        {
            "type": "number",
            "alias": null,
            "title": "縦軸範囲(右)最小値",
            "format": null,
            "hidden": "true",
            "editable": "false",
            "validation": {
                "max": null,
                "min": null,
                "required": null,
                "maxlength": null
            },
            "physical_name": "vertical_range_right_min"
        },
        {
            "type": "number",
            "alias": null,
            "title": "縦軸範囲(左)最大値",
            "format": null,
            "hidden": "true",
            "editable": "false",
            "validation": {
                "max": null,
                "min": null,
                "required": null,
                "maxlength": null
            },
            "physical_name": "vertical_range_left_max"
        },
        {
            "type": "number",
            "alias": null,
            "title": "縦軸範囲(左)最小値",
            "format": null,
            "hidden": "true",
            "editable": "false",
            "validation": {
                "max": null,
                "min": null,
                "required": null,
                "maxlength": null
            },
            "physical_name": "vertical_range_left_min"
        },
        {
            "type": "json",
            "alias": null,
            "title": "グラフ系列情報",
            "format": null,
            "hidden": "true",
            "editable": "false",
            "validation": {
                "max": null,
                "min": null,
                "required": null,
                "maxlength": null
            },
            "physical_name": "series_info"
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
}', null,null,now(),now(), '1');




delete from sys_master_define where master_physical_name='mst_trend_graph_monitor_set';
insert into sys_master_define
  (master_physical_name,master_name,
  disp_class,mode,allow_sort,allow_add_record,
  disp_order,
  column_info,
  combo_data,reference_combo_def,reg_date,up_date,edit_level
  ) values (
  'mst_trend_graph_monitor_set','トレンドグラフモニタ項目一覧セットマスタ',
  '2','1','1','1',
  null,
'{
    "fields": [
        {
            "type": "number",
            "alias": "code",
            "title": "項目セットコード",
            "physical_name": "monitor_set_cd"
        },
        {
            "type": "string",
            "alias": "name",
            "title": "項目セット名",
            "format": null,
            "hidden": "false",
            "editable": "true",
            "validation": {
                "max": null,
                "min": null,
                "required": "true",
                "maxlength": 50
            },
            "physical_name": "monitor_set_name"
        },
        {
            "type": "modal",
            "title": "詳細"
        },
        {
            "type": "string",
            "alias": null,
            "title": "装置種別",
            "format": null,
            "hidden": "true",
            "editable": "false",
            "validation": {
                "max": null,
                "min": null,
                "required": null,
                "maxlength": 3
            },
            "physical_name": "model"
        },
        {
            "type": "json",
            "alias": null,
            "title": "モニタ項目一覧セット",
            "format": null,
            "hidden": "true",
            "editable": "false",
            "validation": {
                "max": null,
                "min": null,
                "required": null,
                "maxlength": null
            },
            "physical_name": "series_info"
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
}', null,null,now(),now(), '1');
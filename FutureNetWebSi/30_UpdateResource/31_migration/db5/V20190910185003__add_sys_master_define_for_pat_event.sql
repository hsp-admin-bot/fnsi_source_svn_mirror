-- sys_master_define定義用

delete from sys_master_define where master_physical_name='mst_pat_event_category';
insert into sys_master_define
  (master_physical_name,master_name,
  disp_class,mode,allow_sort,allow_add_record,
  disp_order,
  column_info,
  combo_data,reference_combo_def,reg_date,up_date,edit_level
  ) values (
  'mst_pat_event_category','患者イベントカテゴリマスタ',
  '2','1','1','1',
  null,
  '{"fields": [{"type": "number", "alias": "code", "title": "カテゴリコード", "physical_name": "category_cd"}, {"type": "string", "alias": "name", "title": "カテゴリ名", "format": null, "hidden": "false", "editable": "true", "validation": {"max": null, "min": null, "required": "true", "maxlength": 20}, "physical_name": "category_name"}, {"type": "del", "title": "削除", "physical_name": "is_del"}, {"type": "disp", "title": "削除", "physical_name": "is_disp"}]}',
  null,null,now(),now(), '1');

delete from sys_master_define where master_physical_name='mst_pat_event_sub_category';
insert into sys_master_define
  (master_physical_name,master_name,
  disp_class,mode,allow_sort,allow_add_record,
  disp_order,
  column_info,
  combo_data,reference_combo_def,reg_date,up_date,edit_level
  ) values (
  'mst_pat_event_sub_category','患者イベントサブカテゴリマスタ',
  '2','1','1','1',
  null,
  '{"fields": [{"type": "number", "alias": "code", "title": "サブカテゴリコード", "physical_name": "sub_category_cd"}, {"type": "string", "alias": "name", "title": "サブカテゴリ名", "format": null, "hidden": "false", "editable": "true", "validation": {"max": null, "min": null, "required": "true", "maxlength": 20}, "physical_name": "sub_category_name"}, {"type": "combo2", "title": "カテゴリ", "physical_name": "category_cd"}, {"type": "del", "title": "削除", "physical_name": "is_del"}, {"type": "disp", "title": "削除", "physical_name": "is_disp"}]}',
  null,'{"combos": [{"target_table": {"name": "mst_pat_event_category", "identifier": "category_cd", "display_column": "category_name", "referenced_column": "category_cd"}, "physical_name": "category_cd"}]}',now(),now(), '1');

delete from sys_master_define where master_physical_name='mst_pat_event_data_template';
insert into sys_master_define
  (master_physical_name,master_name,
  disp_class,mode,allow_sort,allow_add_record,
  disp_order,
  column_info,
  combo_data,reference_combo_def,reg_date,up_date,edit_level
  ) values (
  'mst_pat_event_data_template','患者イベント項目テンプレート',
  '2','1','1','1',
  null,
  '{"fields": [{"type": "number", "alias": "code", "title": "テンプレートコード", "physical_name": "template_cd"}, {"type": "string", "alias": "name", "title": "テンプレート名", "format": null, "hidden": "false", "editable": "true", "validation": {"max": null, "min": null, "required": "true", "maxlength": 20}, "physical_name": "template_name"}, {"type": "modal", "title": "詳細"}, {"type": "number", "alias": null, "title": "カテゴリコード", "format": null, "hidden": "true", "editable": "false", "validation": {"max": null, "min": null, "required": null, "maxlength": null}, "physical_name": "category_cd"}, {"type": "string", "alias": null, "title": "VA画像フラグ", "format": null, "hidden": "true", "editable": "false", "validation": {"max": null, "min": null, "required": null, "maxlength": null}, "physical_name": "is_va"}, {"type": "string", "alias": null, "title": "観察記録対象フラグ", "format": null, "hidden": "true", "editable": "false", "validation": {"max": null, "min": null, "required": null, "maxlength": null}, "physical_name": "is_observe"}, {"type": "json", "alias": null, "title": "項目情報", "format": null, "hidden": "false", "editable": "false", "validation": {"max": null, "min": null, "required": null, "maxlength": null}, "physical_name": "input_params"}, {"type": "del", "title": "削除", "physical_name": "is_del"}, {"type": "disp", "title": "削除", "physical_name": "is_disp"}]}',
  null,null,now(),now(), '1');





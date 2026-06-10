--メニューグループマスタ
DELETE FROM sys_master_define WHERE master_physical_name = 'mst_menu_group';

INSERT INTO sys_master_define (
	master_physical_name,
	master_name,
	disp_class,
	MODE,
	allow_sort,
	allow_add_record,
	disp_order,
	column_info,
	combo_data,
	reg_date,
	up_date,
	reference_combo_def,
	edit_level,
	system_use_disp 
)
VALUES
	(
	'mst_menu_group',
	'メニューグループマスタ',
	'2',
	'1',
	'1',
	'1',
	670,
	'{"fields": [{"type": "number", "alias": "code", "title": "主キー", "format": null, "hidden": "true", "editable": "true", "validation": {"max": null, "min": null, "required": "true", "maxlength": null}, "physical_name": "menu_group_cd"}, {"type": "string", "alias": "name", "title": "メニューグループ名", "format": null, "hidden": "false", "editable": "true", "validation": {"max": null, "min": null, "required": "true", "maxlength": 256}, "physical_name": "menu_group_name"}, {"type": "modal", "alias": null, "title": "詳細", "format": null, "hidden": "false", "editable": "true", "validation": {"max": null, "min": null, "required": null, "maxlength": null}, "physical_name": "menu_list"}, {"type": "json", "alias": null, "title": "メニューリスト", "format": null, "hidden": "true", "editable": "true", "validation": {"max": null, "min": null, "required": null, "maxlength": null}, "physical_name": "menu_list"}, {"type": "json", "alias": null, "title": "アイコン情報", "format": null, "hidden": "true", "editable": "true", "validation": {"max": null, "min": null, "required": null, "maxlength": null}, "physical_name": "icon_info"}, {"type": "del", "title": "削除", "physical_name": "is_del"}, {"type": "disp", "title": "削除", "physical_name": "is_disp"}]}',
	NULL,
	now( ),
	now( ),
	NULL,
	'1',
	'2' 
	);

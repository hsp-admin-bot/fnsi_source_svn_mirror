--投薬支援マスタ
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
	'mst_medicine_support',
	'投薬支援マスタ',
	'2',
	'1',
	'1',
	'1',
	'485',
	'{"fields": [{"type": "number", "alias": "code", "title": "投薬支援コード", "format": null, "hidden": "true", "editable": "false", "validation": {"max": null, "min": null, "required": "true", "maxlength": null}, "physical_name": "medicine_support_cd"}, {"type": "string", "alias": "name", "title": "投薬支援パターン名", "format": null, "hidden": "false", "editable": "true", "validation": {"max": null, "min": null, "required": "true", "maxlength": "80"}, "physical_name": "medicine_support_name"}, {"type": "number", "alias": null, "title": "目標検査値", "format": null, "hidden": "false", "editable": "true", "validation": {"max": null, "min": null, "required": null, "maxlength": null}, "physical_name": "target_inspection"}, {"type": "modal", "alias": null, "title": "詳細", "format": null, "hidden": "false", "editable": "true", "validation": {"max": null, "min": null, "required": null, "maxlength": null}, "physical_name": "detail_info"}, {"type": "json", "alias": null, "title": "詳細", "format": null, "hidden": "true", "editable": "true", "validation": {"max": null, "min": null, "required": null, "maxlength": null}, "physical_name": "detail_info"}, {"type": "disp", "alias": null, "title": "削除", "format": null, "hidden": "false", "editable": "true", "validation": {"max": null, "min": null, "required": null, "maxlength": "1"}, "physical_name": "is_disp"}, {"type": "del", "alias": null, "title": "削除フラグ", "format": null, "hidden": "true", "editable": "true", "validation": {"max": null, "min": null, "required": null, "maxlength": "1"}, "physical_name": "is_del"}]}',
	NULL,
	now( ),
	now( ),
	NULL,
	'1',
	'2' 
	);
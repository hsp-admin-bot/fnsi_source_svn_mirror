-- #11318 処方セットマスタ
DELETE FROM sys_master_define WHERE master_physical_name = 'mst_prescription_set';

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
	'mst_prescription_set',
	'処方セットマスタ',
	'2',
	'1',
	'1',
	'1',
	650,
	'{"fields": [{"type": "number", "alias": "code", "title": "主キー", "format": null, "hidden": "true", "editable": "true", "validation": {"max": null, "min": null, "required": "true", "maxlength": null}, "physical_name": "prescription_set_cd"}, {"type": "string", "alias": "name", "title": "処方セット名", "format": null, "hidden": "false", "editable": "true", "validation": {"max": null, "min": null, "required": "true", "maxlength": 256}, "physical_name": "prescription_set_name"}, {"type": "modal", "alias": null, "title": "詳細", "format": null, "hidden": "false", "editable": "true", "validation": {"max": null, "min": null, "required": null, "maxlength": null}, "physical_name": "set_info"}, {"type": "json", "alias": null, "title": "セット情報", "format": null, "hidden": "true", "editable": "true", "validation": {"max": null, "min": null, "required": null, "maxlength": null}, "physical_name": "set_info"}, {"type": "string", "alias": null, "title": "連携コード1", "format": null, "hidden": "false", "locked": "false", "editable": "true", "validation": {"max": null, "min": null, "required": "false", "maxlength": "20"}, "physical_name": "in_hospital_cd_1"}, {"type": "string", "alias": null, "title": "連携コード2", "format": null, "hidden": "false", "locked": "false", "editable": "true", "validation": {"max": null, "min": null, "required": "false", "maxlength": "20"}, "physical_name": "in_hospital_cd_2"}, {"type": "del", "title": "削除", "physical_name": "is_del"}, {"type": "disp", "title": "削除", "physical_name": "is_disp"}]}',
	NULL,
	CURRENT_TIMESTAMP,
	CURRENT_TIMESTAMP,
	NULL,
	'1',
	'2' 
	);

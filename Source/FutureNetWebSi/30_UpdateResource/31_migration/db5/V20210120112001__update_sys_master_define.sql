--csv 機能の追加
UPDATE ntss.sys_master_define
SET column_info='{"fields": [{"type": "number", "alias": "code", "title": "主キー", "hidden": "true", "physical_name": "insu_cd"}, {"type": "string", "alias": "name", "title": "保険名", "validation": {"required": "true"}, "physical_name": "name"}, {"type": "string", "alias": "insu_name", "title": "保険者名", "physical_name": "insu_name"}, {"type": "string", "alias": "insu_name_short", "title": "保険略称", "validation": {"maxlength": 4}, "physical_name": "insu_name_short"}, {"type": "combo1", "alias": "insu_type", "title": "保険区分", "physical_name": "insu_type"}, {"type": "number", "alias": "futan_g", "title": "負担率（外来）", "validation": {"max": 200, "min": 0, "required": "true", "maxlength": null}, "physical_name": "futan_g"}, {"type": "number", "alias": "futan_n", "title": "負担率（入院）", "validation": {"max": 200, "min": 0, "required": "true", "maxlength": null}, "physical_name": "futan_n"}, {"type": "string", "alias": null, "title": "連携コード1", "format": null, "hidden": "false", "locked": "false", "editable": "true", "validation": {"max": null, "min": null, "required": "false", "maxlength": "20"}, "physical_name": "in_hospital_cd_1"}, {"type": "string", "alias": null, "title": "連携コード2", "format": null, "hidden": "false", "locked": "false", "editable": "true", "validation": {"max": null, "min": null, "required": "false", "maxlength": "20"}, "physical_name": "in_hospital_cd_2"}, {"type": "del", "title": "削除", "physical_name": "is_del"}, {"type": "disp", "title": "削除", "physical_name": "is_disp"}]}'
WHERE master_physical_name='mst_insurance';

UPDATE ntss.sys_master_define
SET combo_data='{"combos": [{"values": [{"text": "未分類", "value": 0}, {"text": "抗凝固剤", "value": 1}, {"text": "透析液", "value": 2}, {"text": "補液", "value": 3}], "physical_name": "class_type"}]}'
WHERE master_physical_name='mst_medicine_class';

UPDATE ntss.sys_master_define
SET combo_data='{"combos": [{"values": [{"text": "未分類", "value": 0}, {"text": "血液回路", "value": 1}, {"text": "穿刺針(SN以外)", "value": 2}, {"text": "穿刺針(SN)", "value": 3}, {"text": "吸着カラム", "value": 4}, {"text": "吸着器", "value": 5}, {"text": "分離器", "value": 6}], "physical_name": "class_type"}]}'
WHERE master_physical_name='mst_equipment_class';

UPDATE ntss.sys_master_define
SET column_info='{"fields": [{"type": "number", "alias": "code", "title": "主キー", "format": null, "hidden": "true", "editable": "true", "validation": {"max": null, "min": null, "required": "true", "maxlength": null}, "physical_name": "url_cd"}, {"type": "string", "alias": "name", "title": "機能名", "format": null, "hidden": "false", "editable": "true", "validation": {"max": null, "min": null, "required": "true", "maxlength": null}, "physical_name": "function_name"}, {"type": "modal", "alias": null, "title": "詳細", "format": null, "hidden": "false", "editable": "true", "validation": {"max": null, "min": null, "required": null, "maxlength": null}, "physical_name": "url_info"}, {"type": "json", "alias": null, "title": "URL", "format": null, "hidden": "true", "editable": "true", "validation": {"max": null, "min": null, "required": null, "maxlength": null}, "physical_name": "url_info"}, {"type": "del", "title": "削除", "physical_name": "is_del"}, {"type": "disp", "title": "削除", "physical_name": "is_disp"}]}'
WHERE master_physical_name='mst_url_link_register';

UPDATE ntss.sys_master_define
SET allow_add_record='1'
WHERE master_physical_name='sys_medicine';

UPDATE ntss.sys_master_define
SET allow_add_record='1'
WHERE master_physical_name='mst_take_medicine';
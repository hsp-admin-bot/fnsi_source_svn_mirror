UPDATE sys_master_define
SET column_info = replace(column_info::text, '{"type": "string", "title": "算定順番", "hidden": "true", "editable": "true", "validation": {"maxlength": "1"}, "physical_name": "add_cnt_1"}', '{"type": "number", "title": "算定順番", "hidden": "true", "editable": "true", "validation": {"maxlength": "1"}, "physical_name": "add_cnt_1"}')::jsonb
WHERE master_physical_name = 'mst_addition';

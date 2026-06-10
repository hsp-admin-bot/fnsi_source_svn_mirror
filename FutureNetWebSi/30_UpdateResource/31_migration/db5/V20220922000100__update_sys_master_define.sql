-- #7571-用法・用語マスタの画面名と画面内の表記が不一致 徐博
update sys_master_define
set column_info = replace(column_info::text, '"用法・用量"', '"用法・用語"')::jsonb
where master_physical_name = 'mst_take_medicine';

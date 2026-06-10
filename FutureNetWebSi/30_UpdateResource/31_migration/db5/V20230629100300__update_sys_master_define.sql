update sys_master_define set column_info = jsonb_set(column_info,'{fields,1, editable}', '"true"', true)  where master_physical_name = 'mst_pat_list_layout';

UPDATE ntss.sys_data_list_detail
	SET master_display_sql='select mainte_layout_group_cd as id, group_name as name from mst_mainte_layout_group where facility_cd = @facilityCd AND is_del = ''0''',function_display_sql='select mainte_layout_group_cd as id, group_name as name from mst_mainte_layout_group where facility_cd = @facilityCd AND is_del = ''0'''
	WHERE data_list_detail_cd=1351;
update
  sys_data_list_detail
set
  function_display_sql = 'select mainte_layout_cd as id, layout_name as name from mst_mainte_layout where facility_cd = @facilityCd AND layout_class = ''1'' AND mainte_layout_cd IN (@ids) AND is_del = ''0'''
where
  data_list_detail_cd = 1390;
update
  sys_data_list_detail
set
  function_display_sql = 'select mainte_layout_group_cd as id, group_name as name from mst_mainte_layout_group where facility_cd = @facilityCd AND mainte_layout_group_cd IN (@ids) AND is_del = ''0'''
where
  data_list_detail_cd = 1391;

update
  sys_data_list_detail
set
  function_display_sql = 'select addition_cd as id, addition_name as name from mst_addition where facility_cd = @facilityCd AND addition_cd IN (@ids) AND is_del = ''0'''
where
  data_list_detail_cd between 1348 and 1349;

update
  sys_data_list_detail
set
  function_display_sql = 'select survey_type_cd as id, survey_type_name as name from mst_water_survey_type where facility_cd = @facilityCd AND survey_type_cd IN (@ids) AND is_del = ''0'''
where
  data_list_detail_cd = 1361;

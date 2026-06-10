update
  sys_data_list_detail
set
  function_display_sql = 'select survey_point_cd as id, point_name as name from mst_water_survey_point where facility_cd = @facilityCd AND survey_point_cd IN (@ids) AND is_del = ''0'''
where
  data_list_detail_cd = 1384;

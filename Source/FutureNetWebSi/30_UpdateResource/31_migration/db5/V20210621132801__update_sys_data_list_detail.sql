update ntss.sys_data_list_detail set function_display_name = '[name] 使用予定数', function_display_type = '1', function_display_sql = 'select medicine_cd as id, medicine_name as name from mst_medicine where class_cd = -1 and facility_cd = @facilityCd AND is_del = ''0'' AND is_disp = ''1''', data_set = '[{"param": "count", "sql_cd": -11045}, {"param": "unit", "sql_cd": -11044}]', cell_display = '[count]  [unit] 集計' where data_list_detail_cd = 1405;
update ntss.sys_data_list_detail set function_display_name = '[name] 使用予定数', function_display_type = '1', function_display_sql = 'select medicine_cd as id, medicine_name as name, 1 as kubun from mst_medicine where class_cd = -1 AND is_del = ''0''
 AND is_disp = ''1'' union 
select medicine_mix_cd as id, medicine_mix_name as name, 2 as kubun from mst_medicine_mix where class_cd = -1 AND is_del = ''0''
 AND is_disp = ''1'' 
', data_set = '[{"param": "count", "sql_cd": -11003}, {"param": "unit", "sql_cd": -11004}]', cell_display = '[count]  [unit] 集計' where data_list_detail_cd = 1406;
update ntss.sys_data_list_detail set function_display_name = '[name] 使用予定数', function_display_type = '1', function_display_sql = 'select medicine_cd as id, medicine_name as name from mst_medicine where class_cd = -1 and facility_cd = @facilityCd AND is_del = ''0'' AND is_disp = ''1''', data_set = '[{"param": "count", "sql_cd": -11043}, {"param": "unit", "sql_cd": -11044}]', cell_display = '[count]  [unit] 集計' where data_list_detail_cd = 1407;
update ntss.sys_data_list_detail set function_display_name = '[name] 使用予定数', function_display_type = '1', function_display_sql = 'select medicine_cd as id, medicine_name as name, 1 as kubun from mst_medicine where class_cd = -1 AND is_del = ''0''
 AND is_disp = ''1'' union 
select medicine_mix_cd as id, medicine_mix_name as name, 2 as kubun from mst_medicine_mix where class_cd = -1 AND is_del = ''0''
 AND is_disp = ''1''
', data_set = '[{"param": "count", "sql_cd": -11009}, {"param": "unit", "sql_cd": -11004}]', cell_display = '[count]  [unit] 集計' where data_list_detail_cd = 1408;
update ntss.sys_data_list_detail set function_display_name = '[name] 使用予定数', function_display_type = '1', function_display_sql = 'select medicine_cd as id, medicine_name as name from mst_medicine where class_cd = -1 and facility_cd = @facilityCd AND is_del = ''0'' AND is_disp = ''1''', data_set = '[{"param": "count", "sql_cd": -11045}, {"param": "unit", "sql_cd": -11044}]', cell_display = '[count]  [unit] 集計' where data_list_detail_cd = 1409;
update ntss.sys_data_list_detail set function_display_name = '[name] 使用予定数', function_display_type = '1', function_display_sql = 'select medicine_cd as id, medicine_name as name, 1 as kubun from mst_medicine where class_cd = -1 AND is_del = ''0'' AND is_disp = ''1'' 
union 
select medicine_mix_cd as id, medicine_mix_name as name, 2 as kubun from mst_medicine_mix where class_cd = -1 AND is_del = ''0''
  AND is_disp = ''1''', data_set = '[{"param": "count", "sql_cd": -11003}, {"param": "unit", "sql_cd": -11004}]', cell_display = '[count]  [unit] 集計' where data_list_detail_cd = 1410;
update ntss.sys_data_list_detail set function_display_name = '[name] 使用予定数', function_display_type = '1', function_display_sql = 'select medicine_cd as id, medicine_name as name from mst_medicine where class_cd = -1 and facility_cd = @facilityCd AND is_del = ''0'' AND is_disp = ''1''', data_set = '[{"param": "count", "sql_cd": -11043}, {"param": "unit", "sql_cd": -11044}]', cell_display = '[count]  [unit] 集計' where data_list_detail_cd = 1411;
update ntss.sys_data_list_detail set function_display_name = '[name] 使用予定数', function_display_type = '1', function_display_sql = 'select medicine_cd as id, medicine_name as name, 1 as kubun from mst_medicine where class_cd = -1 AND is_del = ''0''
 AND is_disp = ''1'' union 
select medicine_mix_cd as id, medicine_mix_name as name, 2 as kubun from mst_medicine_mix where class_cd = -1 AND is_del = ''0''
 AND is_disp = ''1''
', data_set = '[{"param": "count", "sql_cd": -11009}, {"param": "unit", "sql_cd": -11004}]', cell_display = '[count]  [unit] 集計' where data_list_detail_cd = 1412;

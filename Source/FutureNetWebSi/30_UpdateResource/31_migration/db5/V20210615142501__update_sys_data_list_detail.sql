UPDATE "ntss"."sys_data_list_detail" SET "function_display_sql" = 'select medicine_cd as id, medicine_name as name from mst_medicine where class_cd in (@ids) and facility_cd = @facilityCd AND is_del = ''0'' AND is_disp = ''1''' WHERE "data_list_detail_cd" = 1;
UPDATE "ntss"."sys_data_list_detail" SET "function_display_sql" = 'select medicine_cd as id, medicine_name as name, 1 as kubun from mst_medicine where class_cd in (@ids) AND is_del = ''0''
 AND is_disp = ''1'' union 
select medicine_mix_cd as id, medicine_mix_name as name, 2 as kubun from mst_medicine_mix where class_cd in (@ids) AND is_del = ''0''
 AND is_disp = ''1'' 
', "data_set" = '[{"param": "count", "sql_cd": -11003}, {"param": "unit", "sql_cd": -11004}]', "cell_display" = '[count]  [unit] 集計' WHERE "data_list_detail_cd" = 2;
UPDATE "ntss"."sys_data_list_detail" SET "function_display_sql" = 'select equipment_cd as id, equipment_name as name from mst_equipment where facility_cd = @facilityCd and class_cd in (@ids) AND is_del = ''0'' AND is_disp = ''1''' WHERE "data_list_detail_cd" = 3;
UPDATE "ntss"."sys_data_list_detail" SET "function_display_sql" = 'select medicine_cd as id, medicine_name as name from mst_medicine where class_cd in (@ids) and facility_cd = @facilityCd AND is_del = ''0'' AND is_disp = ''1''' WHERE "data_list_detail_cd" = 5;
UPDATE "ntss"."sys_data_list_detail" SET "function_display_sql" = 'select medicine_cd as id, medicine_name as name, 1 as kubun from mst_medicine where class_cd in (@ids) AND is_del = ''0''
 AND is_disp = ''1'' union 
select medicine_mix_cd as id, medicine_mix_name as name, 2 as kubun from mst_medicine_mix where class_cd in (@ids) AND is_del = ''0''
 AND is_disp = ''1''
', "data_set" = '[{"param": "count", "sql_cd": -11009}, {"param": "unit", "sql_cd": -11004}]', "cell_display" = '[count]  [unit] 集計' WHERE "data_list_detail_cd" = 6;
UPDATE "ntss"."sys_data_list_detail" SET "function_display_sql" = 'select equipment_cd as id, equipment_name as name from mst_equipment where facility_cd = @facilityCd and class_cd in (@ids) AND is_del = ''0'' AND is_disp = ''1''' WHERE "data_list_detail_cd" = 7;
UPDATE "ntss"."sys_data_list_detail" SET "function_display_sql" = 'select medicine_cd as id, medicine_name as name from mst_medicine where class_cd in (@ids) and facility_cd = @facilityCd AND is_del = ''0'' AND is_disp = ''1''' WHERE "data_list_detail_cd" = 38;
UPDATE "ntss"."sys_data_list_detail" SET "function_display_sql" = 'select medicine_cd as id, medicine_name as name, 1 as kubun from mst_medicine where class_cd in (@ids) AND is_del = ''0'' AND is_disp = ''1'' 
union 
select medicine_mix_cd as id, medicine_mix_name as name, 2 as kubun from mst_medicine_mix where class_cd in (@ids) AND is_del = ''0''
  AND is_disp = ''1''
', "data_set" = '[{"param": "count", "sql_cd": -11003}, {"param": "unit", "sql_cd": -11004}]', "cell_display" = '[count]  [unit] 集計' WHERE "data_list_detail_cd" = 39;
UPDATE "ntss"."sys_data_list_detail" SET "function_display_sql" = 'select equipment_cd as id, equipment_name as name from mst_equipment where facility_cd = @facilityCd and class_cd in (@ids) AND is_del = ''0'' AND is_disp = ''1''' WHERE "data_list_detail_cd" = 40;
UPDATE "ntss"."sys_data_list_detail" SET "function_display_sql" = 'select medicine_cd as id, medicine_name as name from mst_medicine where class_cd in (@ids) and facility_cd = @facilityCd AND is_del = ''0'' AND is_disp = ''1''' WHERE "data_list_detail_cd" = 42;
UPDATE "ntss"."sys_data_list_detail" SET "function_display_sql" = 'select medicine_cd as id, medicine_name as name, 1 as kubun from mst_medicine where class_cd in (@ids) AND is_del = ''0''
 AND is_disp = ''1'' union 
select medicine_mix_cd as id, medicine_mix_name as name, 2 as kubun from mst_medicine_mix where class_cd in (@ids) AND is_del = ''0''
 AND is_disp = ''1''
', "data_set" = '[{"param": "count", "sql_cd": -11009}, {"param": "unit", "sql_cd": -11004}]', "cell_display" = '[count]  [unit] 集計' WHERE "data_list_detail_cd" = 43;
UPDATE "ntss"."sys_data_list_detail" SET "function_display_sql" = 'select equipment_cd as id, equipment_name as name from mst_equipment where facility_cd = @facilityCd and class_cd in (@ids) AND is_del = ''0'' AND is_disp = ''1''' WHERE "data_list_detail_cd" = 44;

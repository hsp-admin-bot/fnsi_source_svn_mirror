DELETE FROM ntss.sys_data_list_detail
WHERE data_list_detail_cd IN (1410,1447,1412,74,1349);

INSERT INTO ntss.sys_data_list_detail
(data_list_detail_cd, disp_order, category_cd, master_display_name, master_display_type, master_display_sql, function_display_name, function_display_type, function_display_sql, data_set, cell_display)
VALUES(1410, 0, 14, '未分類', '2', NULL, '[name] 予定薬剤集計(指示単位)使用数', '1', 'select medicine_cd as id, medicine_name as name, 1 as kubun from mst_medicine where class_cd = -1 AND facility_cd = @facilityCd union select medicine_mix_cd as id, medicine_mix_name as name, 2 as kubun from mst_medicine_mix where class_cd = -1 and facility_cd = @facilityCd', '[{"param": "count", "sql_cd": -21003}, {"param": "unit", "sql_cd": -11004}]'::jsonb, '[count]  [unit] ');

INSERT INTO ntss.sys_data_list_detail
(data_list_detail_cd, disp_order, category_cd, master_display_name, master_display_type, master_display_sql, function_display_name, function_display_type, function_display_sql, data_set, cell_display)
VALUES(1447, 2, 15, '未分類', '2', NULL, '[name] 予定医療材料集計使用数', '1', 'select equipment_cd as id, equipment_name as name from mst_equipment where facility_cd = @facilityCd and class_cd = -1 AND is_del = ''0'' AND is_disp = ''1''', '[{"param": "count", "sql_cd": -21005}, {"param": "unit", "sql_cd": -11006}]'::jsonb, '[count]  [unit] ');

INSERT INTO ntss.sys_data_list_detail
(data_list_detail_cd, disp_order, category_cd, master_display_name, master_display_type, master_display_sql, function_display_name, function_display_type, function_display_sql, data_set, cell_display)
VALUES(1412, 0, 18, '未分類', '2', NULL, '[name] 実績薬剤集計(指示単位)使用数', '1', 'select medicine_cd as id, medicine_name as name, 1 as kubun from mst_medicine where class_cd = -1 AND facility_cd = @facilityCd union select medicine_mix_cd as id, medicine_mix_name as name, 2 as kubun from mst_medicine_mix where class_cd = -1 and facility_cd = @facilityCd', '[{"param": "count", "sql_cd": -21009}, {"param": "unit", "sql_cd": -11004}]'::jsonb, '[count]  [unit] ');

INSERT INTO ntss.sys_data_list_detail
(data_list_detail_cd, disp_order, category_cd, master_display_name, master_display_type, master_display_sql, function_display_name, function_display_type, function_display_sql, data_set, cell_display)
VALUES(74, 1, 24, '[name]件数', '1', 'select sub_category_cd as id, sub_category_name as name from mst_pat_event_sub_category where facility_cd = @facilityCd AND is_del = ''0''', '[name]件数', '1', 'select T01.sub_category_cd as id,T01.sub_category_name as name from mst_pat_event_sub_category T01 inner join(select row_number() over () as row_num,(value->>''code'')::int as code from mst_selector ms,jsonb_array_elements(ms.order_settings -> ''items'') json_table where ms.facility_cd = @facilityCd and ms.master_physical_name = ''mst_pat_event_sub_category'') as T02 on T01.sub_category_cd = T02.code where T01.sub_category_cd in (@ids) and T01.facility_cd = @facilityCd and T01.is_del = ''0'' order by T02.row_num', '[{"param": "count", "sql_cd": -21038}]'::jsonb, '[count] 件');

INSERT INTO ntss.sys_data_list_detail
(data_list_detail_cd, disp_order, category_cd, master_display_name, master_display_type, master_display_sql, function_display_name, function_display_type, function_display_sql, data_set, cell_display)
VALUES(1349, 1, 133, '[name]', '1', 'select addition_cd as id, addition_name as name from mst_addition where facility_cd = @facilityCd AND is_del = ''0''', '[name]', '1', 'select T01.addition_cd as id,T01.addition_name as name from mst_addition T01 inner join (select row_number() over () as row_num,(value->>''code'')::int as code from mst_selector ms,jsonb_array_elements(ms.order_settings -> ''items'') json_table where ms.facility_cd = @facilityCd and ms.master_physical_name = ''mst_addition'') as T02 on T01.addition_cd = T02.code where T01.facility_cd = @facilityCd and T01.addition_cd in (@ids) and T01.is_del = ''0'' order by T02.row_num', '[{"param": "count", "sql_cd": -21039}]'::jsonb, '[count] 件');


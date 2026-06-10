update ntss.sys_data_list_detail set master_display_name = '点検台数' where data_list_detail_cd = 1353;
update ntss.sys_data_list_detail set disp_order = 4 where data_list_detail_cd = 1355;
update ntss.sys_data_list_detail set disp_order = 3 where data_list_detail_cd = 1354;
INSERT INTO ntss.sys_data_list_detail
(data_list_detail_cd, disp_order, category_cd, master_display_name, master_display_type, master_display_sql, function_display_name, function_display_type, function_display_sql, data_set, cell_display)
VALUES(1440, 2, 137, '予定台数', '2', NULL, '予定台数', '2', NULL, NULL, NULL);
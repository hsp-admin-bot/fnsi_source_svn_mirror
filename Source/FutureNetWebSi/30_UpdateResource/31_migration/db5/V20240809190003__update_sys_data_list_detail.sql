UPDATE sys_data_list_detail
SET master_display_name = '装置台数', function_display_name = '装置台数'
WHERE data_list_detail_cd = 1440;

DELETE FROM sys_data_list_detail WHERE data_list_detail_cd = 1353;
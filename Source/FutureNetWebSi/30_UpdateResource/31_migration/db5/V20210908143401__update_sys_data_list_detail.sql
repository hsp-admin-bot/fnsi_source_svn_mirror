update ntss.sys_data_list_detail set function_display_name = '点検台数' where data_list_detail_cd = 1353;
update ntss.sys_data_set set sql = 'select count(*) as count from ord_main where rst_dialysis_state = ''6'' AND treat_date between @dateFrom and @dateTo and (rst_in_out_class = 0 or rst_in_out_class = 3) and facility_cd = @facilityCd AND is_del = ''0''' where sql_cd = -11019;

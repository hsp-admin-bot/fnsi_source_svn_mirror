update ntss.sys_data_set set sql = ' select
  COALESCE(
(select count(*) from ord_main where  to_number(rst_cond_info->''25''->>''value'',''9999999999999999999.9999999999999999999'') =  @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null) + 
(select case
		when sum(to_number( mediInfo ->> ''amount'', ''9999999999999999999.9999999999999999999'' )) is not null then sum(to_number( mediInfo ->> ''amount'', ''9999999999999999999.9999999999999999999'' )) 
		else 0
	end from ord_main  
    cross join lateral  
      json_array_elements (rst_medi_info::json) mediInfo 
      where to_number(mediInfo->>''cd'',''9999999999999999999.9999999999999999999'')  =  @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null) +
(select case
		when sum(to_number( mediInfo ->> ''amount'', ''9999999999999999999.9999999999999999999'' )) is not null then sum(to_number( mediInfo ->> ''amount'', ''9999999999999999999.9999999999999999999'' )) 
		else 0
	end  from ord_main  
    cross join lateral  
      json_array_elements (rst_treatment_info::json) mediInfo 
      where to_number(mediInfo->>''treat_medicine_cd'',''9999999999999999999.9999999999999999999'')  =  @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null)
, 0) 
as count', db_class = 2, detail = '[]', can_repeat = '0', use_application = '{"applications": []}', report_class = '{"classes": []}', memo = 'データリスト', reg_date = '2020/07/31 18:29:49', up_date = '2020/07/31 18:29:49', pre_sql_info = null where sql_cd = -11009;

update ntss.sys_data_set set sql = 'WITH exchange AS ( SELECT unit_converted_amount, unit_converted_amount_second, is_exchange FROM mst_medicine WHERE medicine_cd = @id AND is_del = ''0'' AND facility_cd = @facilityCd ),
ord1 AS (
	SELECT COUNT
		( * ) AS ord1 
	FROM
		ord_main 
	WHERE
		to_number( rst_cond_info -> ''25'' ->> ''value'', ''9999999999999999999.9999999999999999999'' ) =  @id 
		AND treat_date BETWEEN @dateFrom 
		AND @dateTo 
		AND is_del = ''0'' 
		AND facility_cd = @facilityCd  and pat_id is not null
	),
	ord2 AS (
	SELECT SUM
		( to_number( mediInfo ->> ''amount'', ''9999999999999999999.9999999999999999999'' ) ) AS ord2 
	FROM
		ord_main
		CROSS JOIN LATERAL json_array_elements ( rst_medi_info :: json ) mediInfo 
	WHERE
		to_number( mediInfo ->> ''cd'', ''9999999999999999999.9999999999999999999'' ) =  @id 
		AND treat_date BETWEEN @dateFrom 
		AND @dateTo 
		AND is_del = ''0'' 
		AND facility_cd = @facilityCd  and pat_id is not null
	),
	ord3 AS (
	SELECT SUM
		( to_number( mediInfo ->> ''amount'', ''9999999999999999999.9999999999999999999'' ) ) AS ord3 
	FROM
		ord_main
		CROSS JOIN LATERAL json_array_elements ( rst_treatment_info :: json ) mediInfo 
	WHERE
		to_number( mediInfo ->> ''treat_medicine_cd'', ''9999999999999999999.9999999999999999999'' ) =  @id 
		AND treat_date BETWEEN @dateFrom 
		AND @dateTo 
		AND is_del = ''0'' 
		AND facility_cd = @facilityCd  and pat_id is not null
	)

 select
  COALESCE(
(SELECT COALESCE
	(
	CASE
			
			WHEN exchange.is_exchange = ''0'' 
			AND ( exchange.unit_converted_amount_second IS NOT NULL OR exchange.unit_converted_amount IS NOT NULL ) 
			AND exchange.unit_converted_amount_second != 0 THEN
				round( ( ( ord3.ord3 ) / exchange.unit_converted_amount ) * exchange.unit_converted_amount_second, 1 ) 
				WHEN exchange.is_exchange = ''1'' 
				AND ( exchange.unit_converted_amount_second IS NOT NULL OR exchange.unit_converted_amount IS NOT NULL ) 
				AND exchange.unit_converted_amount_second != 0 THEN
					CEILING ( ( ord3.ord3 ) / exchange.unit_converted_amount ) * exchange.unit_converted_amount_second 
					WHEN exchange.is_exchange = ''2'' 
					AND exchange.unit_converted_amount_second IS NOT NULL THEN
						exchange.unit_converted_amount_second ELSE 0 
						END,
					0 
				) AS COUNT 
			FROM
				exchange,
				ord1,
			    ord2,
	            ord3) +
(SELECT COALESCE
	(
	CASE
			
			WHEN exchange.is_exchange = ''0'' 
			AND ( exchange.unit_converted_amount_second IS NOT NULL OR exchange.unit_converted_amount IS NOT NULL ) 
			AND exchange.unit_converted_amount_second != 0 THEN
				round( ( ( ord1.ord1 ) / exchange.unit_converted_amount ) * exchange.unit_converted_amount_second, 1 ) 
				WHEN exchange.is_exchange = ''1'' 
				AND ( exchange.unit_converted_amount_second IS NOT NULL OR exchange.unit_converted_amount IS NOT NULL ) 
				AND exchange.unit_converted_amount_second != 0 THEN
					CEILING ( ( ord1.ord1 ) / exchange.unit_converted_amount ) * exchange.unit_converted_amount_second 
					WHEN exchange.is_exchange = ''2'' 
					AND exchange.unit_converted_amount_second IS NOT NULL THEN
						exchange.unit_converted_amount_second ELSE 0 
						END,
					0 
				) AS COUNT 
			FROM
				exchange,
				ord1,
			    ord2,
	            ord3) +
(SELECT COALESCE
	(
	CASE
			
			WHEN exchange.is_exchange = ''0'' 
			AND ( exchange.unit_converted_amount_second IS NOT NULL OR exchange.unit_converted_amount IS NOT NULL ) 
			AND exchange.unit_converted_amount_second != 0 THEN
				round( ( ( ord2.ord2 ) / exchange.unit_converted_amount ) * exchange.unit_converted_amount_second, 1 ) 
				WHEN exchange.is_exchange = ''1'' 
				AND ( exchange.unit_converted_amount_second IS NOT NULL OR exchange.unit_converted_amount IS NOT NULL ) 
				AND exchange.unit_converted_amount_second != 0 THEN
					CEILING ( ( ord2.ord2 ) / exchange.unit_converted_amount ) * exchange.unit_converted_amount_second 
					WHEN exchange.is_exchange = ''2'' 
					AND exchange.unit_converted_amount_second IS NOT NULL THEN
						exchange.unit_converted_amount_second ELSE 0 
						END,
					0 
				) AS COUNT 
			FROM
				exchange,
				ord1,
			    ord2,
	            ord3), 0) 
as count', db_class = 2, detail = '[]', can_repeat = '0', use_application = '{"applications": []}', report_class = '{"classes": []}', memo = 'データリスト', reg_date = '2020/07/31 18:29:49', up_date = '2020/07/31 18:29:49', pre_sql_info = null where sql_cd = -11043;
update ntss.sys_data_set set sql = 'select
  COALESCE(
(select count(*) from ord_main where  to_number(rst_cond_info->''5''->>''value'',''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null) + 
(select count(*) from ord_main  
    cross join lateral  
      json_array_elements (rst_equip_info::json) equipInfo 
      where to_number(equipInfo->>''cd'',''9999999999999999999.9999999999999999999'')  = @id and to_number(equipInfo->>''equip_type'',''9'') = 1 and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null)
, 0) as count', db_class = 2, detail = '[]', can_repeat = '0', use_application = '{"applications": []}', report_class = '{"classes": []}', memo = 'データリスト', reg_date = '2020/07/31 18:29:49', up_date = '2020/07/31 18:29:49', pre_sql_info = null where sql_cd = -11011;
update ntss.sys_data_set set sql = 'select
  COALESCE(
(select count(*) from ord_main where  to_number(rst_cond_info->''5''->>''value'',''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null) + 
(select count(*) from ord_main where  to_number(rst_cond_info->''6''->>''value'',''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null) + 
(select count(*) from ord_main where  to_number(rst_cond_info->''7''->>''value'',''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null) + 
(select count(*) from ord_main where  to_number(rst_cond_info->''8''->>''value'',''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null) + 
(select count(*) from ord_main where  to_number(rst_cond_info->''9''->>''value'',''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null) + 
(select count(*) from ord_main where  to_number(rst_cond_info->''10''->>''value'',''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null) + 
(select count(*) from ord_main where  to_number(rst_cond_info->''11''->>''value'',''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null) + 
(select count(*) from ord_main where  to_number(rst_cond_info->''12''->>''value'',''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null) + 
(select count(*) from ord_main where  to_number(rst_cond_info->''13''->>''value'',''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null) + 
(select 
  case
    when sum(to_number(equipInfo->>''amount'',''9999999999999999999.9999999999999999999'')) is not null then sum(to_number(equipInfo->>''amount'',''9999999999999999999.9999999999999999999'')) 
    else 0
  end
from ord_main
    cross join lateral  
      json_array_elements (rst_equip_info::json) equipInfo 
      where to_number(equipInfo->>''cd'',''9999999999999999999.9999999999999999999'')  = @id and to_number(equipInfo->>''equip_type'',''9'') = 0 and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null)
, 0) as count', db_class = 2, detail = '[]', can_repeat = '0', use_application = '{"applications": []}', report_class = '{"classes": []}', memo = 'データリスト', reg_date = '2020/07/31 18:29:49', up_date = '2020/07/31 18:29:49', pre_sql_info = null where sql_cd = -11010;
update ntss.sys_data_set set sql = 'select
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
update ntss.sys_data_set set sql = 'select
  COALESCE(
(select count(*) from ord_main where  to_number(rst_cond_info->''25''->>''value'',''9999999999999999999.9999999999999999999'') =  @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null) + 
(select count(*) from ord_main  
    cross join lateral  
      json_array_elements (rst_medi_info::json) mediInfo 
      where to_number(mediInfo->>''cd'',''9999999999999999999'')  =  @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null) +
(select count(*) from ord_main  
    cross join lateral  
      json_array_elements (rst_treatment_info::json) mediInfo 
      where to_number(mediInfo->>''treat_medicine_cd'',''9999999999999999999'')  =  @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null)
, 0) 
as count', db_class = 2, detail = '[]', can_repeat = '0', use_application = '{"applications": []}', report_class = '{"classes": []}', memo = 'データリスト', reg_date = '2020/07/31 18:29:49', up_date = '2020/07/31 18:29:49', pre_sql_info = null where sql_cd = -11008;
update ntss.sys_data_set set sql = 'select
  COALESCE(
(select count(*) from ord_main where  to_number(ind_cond_info->''5''->>''value'',''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null) + 
(select count(*) from ord_main  
    cross join lateral  
      json_array_elements (ind_equip_info::json) equipInfo 
      where to_number(equipInfo->>''cd'',''9999999999999999999'')  = @id and to_number(equipInfo->>''equip_type'',''9'') = 1 and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null)
, 0) as count', db_class = 2, detail = '[]', can_repeat = '0', use_application = '{"applications": []}', report_class = '{"classes": []}', memo = 'データリスト', reg_date = '2020/07/31 18:29:49', up_date = '2020/07/31 18:29:49', pre_sql_info = null where sql_cd = -11007;
update ntss.sys_data_set set sql = 'select
  COALESCE(
(select count(*) from ord_main where  to_number(ind_cond_info->''5''->>''value'',''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null) + 
(select count(*) from ord_main where  to_number(ind_cond_info->''6''->>''value'',''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null) + 
(select count(*) from ord_main where  to_number(ind_cond_info->''7''->>''value'',''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null) + 
(select count(*) from ord_main where  to_number(ind_cond_info->''8''->>''value'',''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null) + 
(select count(*) from ord_main where  to_number(ind_cond_info->''9''->>''value'',''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null) + 
(select count(*) from ord_main where  to_number(ind_cond_info->''10''->>''value'',''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null) + 
(select count(*) from ord_main where  to_number(ind_cond_info->''11''->>''value'',''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null) + 
(select count(*) from ord_main where  to_number(ind_cond_info->''12''->>''value'',''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null) + 
(select count(*) from ord_main where  to_number(ind_cond_info->''13''->>''value'',''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null) + 
(select 
  case
    when sum(to_number(equipInfo->>''amount'',''9999999999999999999.9999999999999999999'')) is not null then sum(to_number(equipInfo->>''amount'',''9999999999999999999.9999999999999999999'')) 
    else 0
  end
from ord_main
    cross join lateral  
      json_array_elements (ind_equip_info::json) equipInfo 
      where to_number(equipInfo->>''cd'',''9999999999999999999'')  = @id and to_number(equipInfo->>''equip_type'',''9'') = 0 and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null)
, 0) as count', db_class = 2, detail = '[]', can_repeat = '0', use_application = '{"applications": []}', report_class = '{"classes": []}', memo = 'データリスト', reg_date = '2020/07/31 18:29:49', up_date = '2020/07/31 18:29:49', pre_sql_info = null where sql_cd = -11005;
update ntss.sys_data_set set sql = 'select
  COALESCE(
(select count(*) from ord_main where  to_number(ind_cond_info->''25''->>''value'',''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null) + 
(select count(*) from ord_main  
    cross join lateral  
      json_array_elements (ind_medi_info::json) mediInfo 
      where to_number(mediInfo->>''cd'',''9999999999999999999'')  = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null)
, 0) as count', db_class = 2, detail = '[]', can_repeat = '0', use_application = '{"applications": []}', report_class = '{"classes": []}', memo = 'データリスト', reg_date = '2020/07/31 18:29:49', up_date = '2020/07/31 18:29:49', pre_sql_info = null where sql_cd = -11001;

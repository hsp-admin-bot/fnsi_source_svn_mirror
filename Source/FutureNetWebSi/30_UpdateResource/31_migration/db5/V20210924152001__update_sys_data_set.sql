update ntss.sys_data_set set sql = 'select count(*) from ord_main 
where rst_dialysis_state = ''6'' AND treat_date between @dateFrom and @dateTo and facility_cd = @facilityCd and (rst_kur_cd is null or rst_kur_cd = 0) AND is_del = ''0'' and pat_id is not null', db_class = 2, detail = '[]', can_repeat = '0', use_application = '{"applications": []}', report_class = '{"classes": []}', memo = 'データリスト', reg_date = '2020/07/31 18:29:49', up_date = '2020/07/31 18:29:49', pre_sql_info = null where sql_cd = -11047;
update ntss.sys_data_set set sql = 'select count(*) from ord_main 
where treat_date between @dateFrom and @dateTo and facility_cd = @facilityCd and (ind_kur_cd is null or ind_kur_cd = 0) AND is_del = ''0'' and rst_dialysis_state = ''0'' and pat_id is not null', db_class = 2, detail = '[]', can_repeat = '0', use_application = '{"applications": []}', report_class = '{"classes": []}', memo = 'データリスト', reg_date = '2020/07/31 18:29:49', up_date = '2020/07/31 18:29:49', pre_sql_info = null where sql_cd = -11046;
update ntss.sys_data_set set sql = 'WITH exchange AS ( SELECT unit_converted_amount, unit_converted_amount_second, is_exchange FROM mst_medicine WHERE medicine_cd = @id AND is_del = ''0'' AND facility_cd = @facilityCd
 ),
ord1 AS (
		SELECT COUNT
			( * ) as ord1
		FROM
			ord_main 
		WHERE
			to_number( ind_cond_info -> ''25'' ->> ''value'', ''9999999999999999999'' ) = @id
			AND treat_date BETWEEN @dateFrom
 
			AND @dateTo
 
			AND is_del = ''0'' 
			AND facility_cd = @facilityCd and pat_id is not null
),
ord2 AS (
		SELECT COUNT
			( * ) as ord2
		FROM
			ord_main
			CROSS JOIN LATERAL json_array_elements ( ind_medi_info :: json ) mediInfo 
		WHERE
			to_number( mediInfo ->> ''cd'', ''9999999999999999999'' ) = @id
			AND treat_date BETWEEN @dateFrom
 
			AND @dateTo
 
			AND is_del = ''0'' 
			AND facility_cd = @facilityCd and pat_id is not null

) 


SELECT COALESCE (
(SELECT COALESCE
	(
	case when exchange.is_exchange = ''0'' 
			AND ( exchange.unit_converted_amount_second is NOT NULL OR exchange.unit_converted_amount is NOT NULL ) 
			AND exchange.unit_converted_amount_second != 0 then
				round(((ord1.ord1) / exchange.unit_converted_amount ) * exchange.unit_converted_amount_second, 1)
when exchange.is_exchange = ''1'' 
					AND ( exchange.unit_converted_amount_second is NOT NULL OR exchange.unit_converted_amount is NOT NULL ) 
					AND exchange.unit_converted_amount_second != 0 then
						CEILING ((ord1.ord1) / exchange.unit_converted_amount ) * exchange.unit_converted_amount_second
when exchange.is_exchange = ''2'' 
							AND exchange.unit_converted_amount_second  is NOT NULL then
								exchange.unit_converted_amount_second 
ELSE 0 END
, 0) as count
from
exchange,
ord1,
ord2) +
(SELECT COALESCE
	(
	case when exchange.is_exchange = ''0'' 
			AND ( exchange.unit_converted_amount_second is NOT NULL OR exchange.unit_converted_amount is NOT NULL ) 
			AND exchange.unit_converted_amount_second != 0 then
				round(((ord2.ord2) / exchange.unit_converted_amount ) * exchange.unit_converted_amount_second, 1)
when exchange.is_exchange = ''1'' 
					AND ( exchange.unit_converted_amount_second is NOT NULL OR exchange.unit_converted_amount is NOT NULL ) 
					AND exchange.unit_converted_amount_second != 0 then
						CEILING ((ord2.ord2) / exchange.unit_converted_amount ) * exchange.unit_converted_amount_second
when exchange.is_exchange = ''2'' 
							AND exchange.unit_converted_amount_second  is NOT NULL then
								exchange.unit_converted_amount_second 
ELSE 0 END
, 0) as count
from
exchange,
ord1,
ord2)
, 0) as count
', db_class = 2, detail = '[]', can_repeat = '0', use_application = '{"applications": []}', report_class = '{"classes": []}', memo = 'データリスト', reg_date = '2020/07/31 18:29:49', up_date = '2020/07/31 18:29:49', pre_sql_info = null where sql_cd = -11045;
update ntss.sys_data_set set sql = 'WITH exchange AS ( SELECT unit_converted_amount, unit_converted_amount_second, is_exchange FROM mst_medicine WHERE medicine_cd = @id AND is_del = ''0'' AND facility_cd = @facilityCd ),
ord1 AS (
	SELECT COUNT
		( * ) AS ord1 
	FROM
		ord_main 
	WHERE
		to_number( rst_cond_info -> ''25'' ->> ''value'', ''9999999999999999999'' ) =  @id 
		AND treat_date BETWEEN @dateFrom 
		AND @dateTo 
		AND is_del = ''0'' 
		AND facility_cd = @facilityCd  and pat_id is not null
	),
	ord2 AS (
	SELECT COUNT
		( * ) AS ord2 
	FROM
		ord_main
		CROSS JOIN LATERAL json_array_elements ( rst_medi_info :: json ) mediInfo 
	WHERE
		to_number( mediInfo ->> ''cd'', ''9999999999999999999'' ) =  @id 
		AND treat_date BETWEEN @dateFrom 
		AND @dateTo 
		AND is_del = ''0'' 
		AND facility_cd = @facilityCd  and pat_id is not null
	),
	ord3 AS (
	SELECT COUNT
		( * ) AS ord3 
	FROM
		ord_main
		CROSS JOIN LATERAL json_array_elements ( rst_treatment_info :: json ) mediInfo 
	WHERE
		to_number( mediInfo ->> ''treat_medicine_cd'', ''9999999999999999999'' ) =  @id 
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
update ntss.sys_data_set set sql = 'WITH A AS (
	SELECT
		pat_id,
		MAX ( inOutInfo ->> ''ctl_no'' ) AS ctl_no 
	FROM
		pat_unique
		CROSS JOIN LATERAL json_array_elements ( in_out_visit_history_info :: json ) inOutInfo 
	WHERE
		is_del = ''0'' 
		AND facility_cd = @facilityCd 
    GROUP BY
        pat_id 
    ),
    B AS (
    SELECT
        pat_id,
        inOutInfo ->> ''ctl_no'' AS ctl_no,
        inOutInfo ->> ''in_out'' AS in_out 
    FROM
        pat_unique
        CROSS JOIN LATERAL json_array_elements ( in_out_visit_history_info :: json ) inOutInfo 
    WHERE
        is_del = ''0'' 
        AND facility_cd = @facilityCd 
    ),
    in_out AS (
    SELECT
        B.pat_id,
        B.in_out
        
    FROM
        A INNER JOIN B ON A.pat_id = B.pat_id 
        AND A.ctl_no = B.ctl_no 
    )
SELECT COUNT
    ( * ) AS COUNT 
FROM
    ord_main
    LEFT JOIN in_out ON ord_main.pat_id = in_out.pat_id 
WHERE
    ord_main.treat_date BETWEEN @dateFrom 
    AND @dateTo 
    AND (in_out.in_out <> ''1'' or in_out.in_out is null)
    AND ord_main.facility_cd = @facilityCd 
    AND ord_main.is_del = ''0''
	AND ord_main.rst_dialysis_state = ''0'' and ord_main.pat_id is not null
    ;', db_class = 2, detail = '[]', can_repeat = '0', use_application = '{"applications": []}', report_class = '{"classes": []}', memo = 'データリスト', reg_date = '2020/05/26 16:49:16', up_date = '2020/05/26 16:49:21', pre_sql_info = null where sql_cd = -11042;
update ntss.sys_data_set set sql = 'WITH A AS (
    SELECT
        pat_id,
        MAX ( inOutInfo ->> ''ctl_no'' ) AS ctl_no 
    FROM
        pat_unique
        CROSS JOIN LATERAL json_array_elements ( in_out_visit_history_info :: json ) inOutInfo 
    WHERE
        is_del = ''0'' 
        AND facility_cd = @facilityCd 
    GROUP BY
        pat_id 
    ),
    B AS (
    SELECT
        pat_id,
        inOutInfo ->> ''ctl_no'' AS ctl_no,
        inOutInfo ->> ''in_out'' AS in_out 
    FROM
        pat_unique
        CROSS JOIN LATERAL json_array_elements ( in_out_visit_history_info :: json ) inOutInfo 
    WHERE
        is_del = ''0'' 
        AND facility_cd = @facilityCd 
    ),
    in_out AS (
    SELECT
        B.pat_id,
        B.in_out
        
    FROM
        A INNER JOIN B ON A.pat_id = B.pat_id 
        AND A.ctl_no = B.ctl_no 
    )
SELECT COUNT
    ( * ) AS COUNT 
FROM
    ord_main
    LEFT JOIN in_out ON ord_main.pat_id = in_out.pat_id 
WHERE
    ord_main.treat_date BETWEEN @dateFrom 
    AND @dateTo 
    AND in_out.in_out = ''1''
    AND ord_main.facility_cd = @facilityCd 
    AND ord_main.is_del = ''0''
	AND ord_main.rst_dialysis_state = ''0'' and ord_main.pat_id is not null
    ;', db_class = 2, detail = '[]', can_repeat = '0', use_application = '{"applications": []}', report_class = '{"classes": []}', memo = 'データリスト', reg_date = '2020/05/26 16:49:16', up_date = '2020/05/26 16:49:21', pre_sql_info = null where sql_cd = -11041;
update ntss.sys_data_set set sql = 'SELECT COUNT
		( * ) 
		FROM
		ord_main,
		jsonb_to_recordset ( addition_info ) AS j1 ( cd TEXT, reg_date TEXT, is_enable TEXT ) 
		WHERE
		treat_date BETWEEN @dateFrom 
		AND @dateTo 
		AND is_del = ''0'' 
	AND facility_cd = @facilityCd 
	AND j1.cd = @itemId::text and pat_id is not null', db_class = 2, detail = '[]', can_repeat = '0', use_application = '{"applications": []}', report_class = '{"classes": []}', memo = 'データリスト', reg_date = '2021/04/25 16:40:02', up_date = '2021/04/25 16:40:02', pre_sql_info = null where sql_cd = -11039;
update ntss.sys_data_set set sql = 'select count(*) from ord_main 
where rst_dialysis_state = ''6'' AND treat_date between @dateFrom and @dateTo and facility_cd = @facilityCd and rst_kur_cd = @id AND is_del = ''0'' and pat_id is not null', db_class = 2, detail = '[]', can_repeat = '0', use_application = '{"applications": []}', report_class = '{"classes": []}', memo = 'データリスト', reg_date = '2020/07/31 18:29:49', up_date = '2020/07/31 18:29:49', pre_sql_info = null where sql_cd = -11023;
update ntss.sys_data_set set sql = 'select count(*) from ord_main 
where rst_dialysis_state = ''6'' AND treat_date between @dateFrom and @dateTo and facility_cd = @facilityCd and rst_treatment_cd = @id AND is_del = ''0'' and pat_id is not null', db_class = 2, detail = '[]', can_repeat = '0', use_application = '{"applications": []}', report_class = '{"classes": []}', memo = 'データリスト', reg_date = '2020/07/31 18:29:49', up_date = '2020/07/31 18:29:49', pre_sql_info = null where sql_cd = -11022;
update ntss.sys_data_set set sql = 'select count(*) as count from ord_main as ordMain left join mst_treatment as mstTreatment on ordMain.rst_treatment_cd = mstTreatment.treatment_cd
where ordMain.rst_dialysis_state = ''6'' AND mstTreatment.device_mode = ''9'' and ordMain.treat_date between @dateFrom and @dateTo and ordMain.facility_cd = @facilityCd AND ordMain.is_del = ''0'' and ordMain.pat_id is not null', db_class = 2, detail = '[]', can_repeat = '0', use_application = '{"applications": []}', report_class = '{"classes": []}', memo = 'データリスト', reg_date = '2020/07/31 18:29:49', up_date = '2020/07/31 18:29:49', pre_sql_info = null where sql_cd = -11021;
update ntss.sys_data_set set sql = 'select count(*) as count from ord_main as ordMain left join mst_treatment as mstTreatment on ordMain.rst_treatment_cd = mstTreatment.treatment_cd
where ordMain.rst_dialysis_state = ''6'' AND mstTreatment.device_mode != ''9'' and ordMain.treat_date between @dateFrom and @dateTo and ordMain.facility_cd = @facilityCd AND ordMain.is_del = ''0'' and ordMain.pat_id is not null', db_class = 2, detail = '[]', can_repeat = '0', use_application = '{"applications": []}', report_class = '{"classes": []}', memo = 'データリスト', reg_date = '2020/07/31 18:29:49', up_date = '2020/07/31 18:29:49', pre_sql_info = null where sql_cd = -11020;
update ntss.sys_data_set set sql = 'select count(*) as count from ord_main where rst_dialysis_state = ''6'' AND treat_date between @dateFrom and @dateTo and (rst_in_out_class <> 1 or rst_in_out_class is null) and facility_cd = @facilityCd AND is_del = ''0'' and pat_id is not null', db_class = 2, detail = '[]', can_repeat = '0', use_application = '{"applications": []}', report_class = '{"classes": []}', memo = 'データリスト', reg_date = '2020/07/31 18:29:49', up_date = '2020/07/31 18:29:49', pre_sql_info = null where sql_cd = -11019;
update ntss.sys_data_set set sql = 'select count(*) as count from ord_main where rst_dialysis_state = ''6'' AND treat_date between @dateFrom and @dateTo and rst_in_out_class = 1 and facility_cd = @facilityCd AND is_del = ''0'' and pat_id is not null', db_class = 2, detail = '[]', can_repeat = '0', use_application = '{"applications": []}', report_class = '{"classes": []}', memo = 'データリスト', reg_date = '2020/07/31 18:29:49', up_date = '2020/07/31 18:29:49', pre_sql_info = null where sql_cd = -11018;
update ntss.sys_data_set set sql = 'select count(*) as count from ord_main where treat_date between @dateFrom and @dateTo and rst_dialysis_state = ''6'' and facility_cd = @facilityCd AND is_del = ''0'' and pat_id is not null', db_class = 2, detail = '[]', can_repeat = '0', use_application = '{"applications": []}', report_class = '{"classes": []}', memo = 'データリスト', reg_date = '2020/07/31 18:29:49', up_date = '2020/07/31 18:29:49', pre_sql_info = null where sql_cd = -11017;
update ntss.sys_data_set set sql = 'select count(*) from ord_main 
where treat_date between @dateFrom and @dateTo and facility_cd = @facilityCd and ind_kur_cd = @id AND is_del = ''0'' and rst_dialysis_state = ''0'' and pat_id is not null', db_class = 2, detail = '[]', can_repeat = '0', use_application = '{"applications": []}', report_class = '{"classes": []}', memo = 'データリスト', reg_date = '2020/07/31 18:29:49', up_date = '2020/07/31 18:29:49', pre_sql_info = null where sql_cd = -11016;
update ntss.sys_data_set set sql = 'select count(*) from ord_main 
where treat_date between @dateFrom and @dateTo and facility_cd = @facilityCd and ind_treatment_cd = @id AND is_del = ''0'' and rst_dialysis_state = ''0'' and pat_id is not null', db_class = 2, detail = '[]', can_repeat = '0', use_application = '{"applications": []}', report_class = '{"classes": []}', memo = 'データリスト', reg_date = '2020/07/31 18:29:49', up_date = '2020/07/31 18:29:49', pre_sql_info = null where sql_cd = -11015;
update ntss.sys_data_set set sql = 'select count(*) as count from ord_main as ordMain left join mst_treatment as mstTreatment on ordMain.ind_treatment_cd = mstTreatment.treatment_cd
where mstTreatment.device_mode = ''9'' and ordMain.treat_date between @dateFrom and @dateTo and ordMain.facility_cd = @facilityCd AND ordMain.is_del = ''0''
 AND ordMain.rst_dialysis_state = ''0'' and ordMain.pat_id is not null', db_class = 2, detail = '[]', can_repeat = '0', use_application = '{"applications": []}', report_class = '{"classes": []}', memo = 'データリスト', reg_date = '2020/07/31 18:29:49', up_date = '2020/07/31 18:29:49', pre_sql_info = null where sql_cd = -11014;
update ntss.sys_data_set set sql = 'select count(*) as count from ord_main as ordMain left join mst_treatment as mstTreatment on ordMain.ind_treatment_cd = mstTreatment.treatment_cd
where mstTreatment.device_mode != ''9'' and ordMain.treat_date between @dateFrom and @dateTo and ordMain.facility_cd = @facilityCd AND ordMain.is_del = ''0''
	AND ordMain.rst_dialysis_state = ''0'' and ordMain.pat_id is not null', db_class = 2, detail = '[]', can_repeat = '0', use_application = '{"applications": []}', report_class = '{"classes": []}', memo = 'データリスト', reg_date = '2020/07/31 18:29:49', up_date = '2020/07/31 18:29:49', pre_sql_info = null where sql_cd = -11013;
update ntss.sys_data_set set sql = 'select count(*) as count from ord_main where treat_date between @dateFrom and @dateTo and facility_cd = @facilityCd AND is_del = ''0'' and rst_dialysis_state = ''0'' and pat_id is not null', db_class = 2, detail = '[]', can_repeat = '0', use_application = '{"applications": []}', report_class = '{"classes": []}', memo = 'データリスト', reg_date = '2020/07/31 18:29:49', up_date = '2020/07/31 18:29:49', pre_sql_info = null where sql_cd = -11012;
update ntss.sys_data_set set sql = ' select
  COALESCE(
(select count(*) from ord_main where  to_number(rst_cond_info->''5''->>''value'',''9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null) + 
(select count(*) from ord_main  
    cross join lateral  
      json_array_elements (rst_equip_info::json) equipInfo 
      where to_number(equipInfo->>''cd'',''9999999999999999999'')  = @id and to_number(equipInfo->>''equip_type'',''9'') = 1 and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null)
, 0) as count', db_class = 2, detail = '[]', can_repeat = '0', use_application = '{"applications": []}', report_class = '{"classes": []}', memo = 'データリスト', reg_date = '2020/07/31 18:29:49', up_date = '2020/07/31 18:29:49', pre_sql_info = null where sql_cd = -11011;
update ntss.sys_data_set set sql = ' select
  COALESCE(
(select count(*) from ord_main where  to_number(rst_cond_info->''5''->>''value'',''9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null) + 
(select count(*) from ord_main where  to_number(rst_cond_info->''6''->>''value'',''9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null) + 
(select count(*) from ord_main where  to_number(rst_cond_info->''7''->>''value'',''9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null) + 
(select count(*) from ord_main where  to_number(rst_cond_info->''8''->>''value'',''9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null) + 
(select count(*) from ord_main where  to_number(rst_cond_info->''9''->>''value'',''9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null) + 
(select count(*) from ord_main where  to_number(rst_cond_info->''10''->>''value'',''9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null) + 
(select count(*) from ord_main where  to_number(rst_cond_info->''11''->>''value'',''9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null) + 
(select count(*) from ord_main where  to_number(rst_cond_info->''12''->>''value'',''9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null) + 
(select count(*) from ord_main where  to_number(rst_cond_info->''13''->>''value'',''9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null) + 
(select 
  case
    when sum(to_number(equipInfo->>''amount'',''9999999999999999999'')) is not null then sum(to_number(equipInfo->>''amount'',''9999999999999999999'')) 
    else 0
  end
from ord_main
    cross join lateral  
      json_array_elements (rst_equip_info::json) equipInfo 
      where to_number(equipInfo->>''cd'',''9999999999999999999'')  = @id and to_number(equipInfo->>''equip_type'',''9'') = 0 and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null)
, 0) as count', db_class = 2, detail = '[]', can_repeat = '0', use_application = '{"applications": []}', report_class = '{"classes": []}', memo = 'データリスト', reg_date = '2020/07/31 18:29:49', up_date = '2020/07/31 18:29:49', pre_sql_info = null where sql_cd = -11010;
update ntss.sys_data_set set sql = ' select
  COALESCE(
(select count(*) from ord_main where  to_number(rst_cond_info->''25''->>''value'',''9999999999999999999'') =  @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null) + 
(select case
		when sum(to_number( mediInfo ->> ''amount'', ''9999999999999999999'' )) is not null then sum(to_number( mediInfo ->> ''amount'', ''9999999999999999999'' )) 
		else 0
	end from ord_main  
    cross join lateral  
      json_array_elements (rst_medi_info::json) mediInfo 
      where to_number(mediInfo->>''cd'',''9999999999999999999'')  =  @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null) +
(select case
		when sum(to_number( mediInfo ->> ''amount'', ''9999999999999999999'' )) is not null then sum(to_number( mediInfo ->> ''amount'', ''9999999999999999999'' )) 
		else 0
	end  from ord_main  
    cross join lateral  
      json_array_elements (rst_treatment_info::json) mediInfo 
      where to_number(mediInfo->>''treat_medicine_cd'',''9999999999999999999'')  =  @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null)
, 0) 
as count', db_class = 2, detail = '[]', can_repeat = '0', use_application = '{"applications": []}', report_class = '{"classes": []}', memo = 'データリスト', reg_date = '2020/07/31 18:29:49', up_date = '2020/07/31 18:29:49', pre_sql_info = null where sql_cd = -11009;
update ntss.sys_data_set set sql = ' select
  COALESCE(
(select count(*) from ord_main where  to_number(rst_cond_info->''25''->>''value'',''9999999999999999999'') =  @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null) + 
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
update ntss.sys_data_set set sql = ' select
  COALESCE(
(select count(*) from ord_main where  to_number(ind_cond_info->''5''->>''value'',''9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null) + 
(select count(*) from ord_main  
    cross join lateral  
      json_array_elements (ind_equip_info::json) equipInfo 
      where to_number(equipInfo->>''cd'',''9999999999999999999'')  = @id and to_number(equipInfo->>''equip_type'',''9'') = 1 and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null)
, 0) as count', db_class = 2, detail = '[]', can_repeat = '0', use_application = '{"applications": []}', report_class = '{"classes": []}', memo = 'データリスト', reg_date = '2020/07/31 18:29:49', up_date = '2020/07/31 18:29:49', pre_sql_info = null where sql_cd = -11007;
update ntss.sys_data_set set sql = ' select
  COALESCE(
(select count(*) from ord_main where  to_number(ind_cond_info->''5''->>''value'',''9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null) + 
(select count(*) from ord_main where  to_number(ind_cond_info->''6''->>''value'',''9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null) + 
(select count(*) from ord_main where  to_number(ind_cond_info->''7''->>''value'',''9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null) + 
(select count(*) from ord_main where  to_number(ind_cond_info->''8''->>''value'',''9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null) + 
(select count(*) from ord_main where  to_number(ind_cond_info->''9''->>''value'',''9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null) + 
(select count(*) from ord_main where  to_number(ind_cond_info->''10''->>''value'',''9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null) + 
(select count(*) from ord_main where  to_number(ind_cond_info->''11''->>''value'',''9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null) + 
(select count(*) from ord_main where  to_number(ind_cond_info->''12''->>''value'',''9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null) + 
(select count(*) from ord_main where  to_number(ind_cond_info->''13''->>''value'',''9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null) + 
(select 
  case
    when sum(to_number(equipInfo->>''amount'',''9999999999999999999'')) is not null then sum(to_number(equipInfo->>''amount'',''9999999999999999999'')) 
    else 0
  end
from ord_main
    cross join lateral  
      json_array_elements (ind_equip_info::json) equipInfo 
      where to_number(equipInfo->>''cd'',''9999999999999999999'')  = @id and to_number(equipInfo->>''equip_type'',''9'') = 0 and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null)
, 0) as count', db_class = 2, detail = '[]', can_repeat = '0', use_application = '{"applications": []}', report_class = '{"classes": []}', memo = 'データリスト', reg_date = '2020/07/31 18:29:49', up_date = '2020/07/31 18:29:49', pre_sql_info = null where sql_cd = -11005;
update ntss.sys_data_set set sql = ' select
  COALESCE(
(select count(*) from ord_main where  to_number(ind_cond_info->''25''->>''value'',''9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null) + 
(select case
		when sum(to_number( mediInfo ->> ''amount'', ''9999999999999999999'' )) is not null then sum(to_number( mediInfo ->> ''amount'', ''9999999999999999999'' )) 
		else 0
	end from ord_main  
    cross join lateral  
      json_array_elements (ind_medi_info::json) mediInfo 
      where to_number(mediInfo->>''cd'',''9999999999999999999'')  = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null)
, 0) as count', db_class = 2, detail = '[]', can_repeat = '0', use_application = '{"applications": []}', report_class = '{"classes": []}', memo = 'データリスト', reg_date = '2020/07/31 18:29:49', up_date = '2020/07/31 18:29:49', pre_sql_info = null where sql_cd = -11003;
update ntss.sys_data_set set sql = ' select
  COALESCE(
(select count(*) from ord_main where  to_number(ind_cond_info->''25''->>''value'',''9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null) + 
(select count(*) from ord_main  
    cross join lateral  
      json_array_elements (ind_medi_info::json) mediInfo 
      where to_number(mediInfo->>''cd'',''9999999999999999999'')  = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null)
, 0) as count

', db_class = 2, detail = '[]', can_repeat = '0', use_application = '{"applications": []}', report_class = '{"classes": []}', memo = 'データリスト', reg_date = '2020/07/31 18:29:49', up_date = '2020/07/31 18:29:49', pre_sql_info = null where sql_cd = -11001;

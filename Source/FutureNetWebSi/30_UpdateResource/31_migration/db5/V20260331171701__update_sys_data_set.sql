DELETE FROM "ntss"."sys_data_set" where sql_cd in (262);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (262, 'with
survey_type_order AS(
	SELECT
		ms.code AS survey_type_cd,
		ms.name,
		row_number() over() AS survey_type_order
	FROM
		mst_selector
	cross join lateral jsonb_to_recordset(order_settings->''items'') AS ms (code bigint, name text)
	WHERE
		facility_cd = @facilityCd
	AND
		master_physical_name = ''mst_water_survey_type''
)
, water_survey_type_tbl AS (
	SELECT
		survey_type_cd,
		survey_type_name,
		integer_digits,
		decimal_digits,
		unit,
		upper_threshold,
		lower_threshold,
		graph_upper_limit,
		graph_lower_limit
	FROM
		mst_water_survey_type
	WHERE
		facility_cd = @facilityCd
	AND
		is_disp = ''1''
	AND
		is_del = ''0''
)
, survey_point_order AS(
	SELECT
		ms.code AS survey_point_cd,
		ms.name,
		row_number() over() AS survey_point_order
	FROM
		mst_selector
	cross join lateral jsonb_to_recordset(order_settings->''items'') AS ms (code bigint, name text)
	WHERE
		facility_cd = @facilityCd
	AND
		master_physical_name = ''mst_water_survey_point''
)
, water_survey_point_select AS(
	SELECT
		*
	FROM
		mst_water_survey_point
	WHERE
		facility_cd = @facilityCd
	AND
		is_del = ''0''
	AND
		is_disp = ''1''
)
, water_survey_point_tb AS (
	SELECT
		case
			when mwsp.machine_no is not null then mwsp.machine_no
			else -1 
		end as machine_no,
		mwsp.survey_type_cd,
		wstt.survey_type_name,
		wstt.unit,
		wstt.upper_threshold,
		wstt.lower_threshold,
		wstt.graph_upper_limit,
		wstt.graph_lower_limit,
		sto.survey_type_order,
		mwsp.survey_point_cd,
		mwsp.point_name AS survey_point_name,
		mwsp.in_hospital_cd_1 AS survey_point_in_hospital_cd_1,
		mwsp.in_hospital_cd_2 AS survey_point_in_hospital_cd_2,
		ms.survey_point_order
	FROM
		water_survey_point_select AS mwsp
	LEFT JOIN water_survey_type_tbl AS wstt ON mwsp.survey_type_cd = wstt.survey_type_cd
	LEFT JOIN survey_type_order AS sto ON mwsp.survey_type_cd = sto.survey_type_cd
	LEFT JOIN survey_point_order AS ms ON mwsp.survey_point_cd = ms.survey_point_cd
	ORDER BY
		ms.survey_point_order
)
, water_survey_point_tbl as (
	SELECT
		*
	FROM
		water_survey_point_tb
	WHERE
		machine_no IN (@machineNos)
)
, water_servey_tbl AS (
	SELECT
		mws.facility_cd,
		mws.inspection_date,
		survey_data_json ->> ''point_cd'' as point_cd,
		survey_data_json ->> ''plan'' as plan,
		CASE
			WHEN survey_data_json ->> ''time'' IS NOT NULL AND survey_data_json ->> ''time'' <> ''''
			THEN (to_char(mws.inspection_date, ''YYYY-MM-DD'') || '' '' || to_char(TO_TIMESTAMP(survey_data_json ->> ''time'', ''HH24:MI''), ''HH24:MI'') || '':00'')::TIMESTAMP
			ELSE NULL
		END	as time,
		CASE
			WHEN survey_data_json ->> ''picker'' <> ''0'' THEN survey_data_json ->> ''picker''
			ELSE NULL
		END AS picker,
		survey_data_json ->> ''value'' as value,
		survey_data_json ->> ''unit'' as unit,
		survey_data_json ->> ''text'' as text,
		CASE
			WHEN survey_data_json ->> ''inspector'' <> ''0'' THEN survey_data_json ->> ''inspector''
			ELSE NULL
		END AS inspector,
		survey_data_json ->> ''memo'' as memo
	FROM
		mnt_water_survey AS mws
	CROSS JOIN LATERAL json_array_elements(mws.survey_data ::json) survey_data_json
		LEFT JOIN water_survey_point_tbl AS wsp ON CAST(wsp.survey_point_cd AS TEXT) = survey_data_json ->> ''point_cd''
	WHERE
		facility_cd = @facilityCd
	AND
		inspection_date between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
	AND 
		wsp.survey_point_cd is not null	
	AND
		is_disp = ''1''
	AND
		is_del = ''0''
)
select a.* from (
	SELECT
		wspt.machine_no
		
		,wspt.survey_type_order
		,wspt.survey_type_cd
		,case
			when (wspt.survey_type_cd is not null) then wstt.survey_type_name
			else null
		end as survey_type_name
		,case
			when (wspt.survey_type_cd is not null) then wstt.unit
			else null
		end as survey_type_unit
		,case
			when (wspt.survey_type_cd is not null) then wstt.upper_threshold
			else null
		end as survey_type_upper_threshold
		,case
			when (wspt.survey_type_cd is not null) then wstt.lower_threshold
			else null
		end as survey_type_lower_threshold
		,case
			when (wspt.survey_type_cd is not null) then wstt.graph_upper_limit
			else null
		end as survey_type_graph_upper_limit
		,case
			when (wspt.survey_type_cd is not null) then wstt.graph_lower_limit
			else null
		end as survey_type_graph_lower_limit
		
		,wspt.survey_point_order
		,wspt.survey_point_cd
		,wspt.survey_point_name
		,wspt.survey_point_in_hospital_cd_1
		,wspt.survey_point_in_hospital_cd_2
		
		,wst.*
		,case
			when (wst.value <> '''') then 
				(CASE WHEN wst.value::numeric < (FLOOR(wst.value::numeric * POW(10, wstt.decimal_digits)) / POW(10, wstt.decimal_digits)) AND LENGTH(TRIM(TRAILING ''0'' FROM CAST(SPLIT_PART(wst.value, ''.'', 2) AS TEXT))) <> wstt.decimal_digits
					THEN (FLOOR(wst.value::numeric * POW(10, wstt.decimal_digits)) / POW(10, wstt.decimal_digits))::text
					WHEN wst.value::numeric = (FLOOR(wst.value::numeric * POW(10, wstt.decimal_digits)) / POW(10, wstt.decimal_digits)) AND LENGTH(TRIM(TRAILING ''0'' FROM CAST(SPLIT_PART(wst.value, ''.'', 2) AS TEXT))) <> wstt.decimal_digits
					THEN ROUND(wst.value::numeric, wstt.decimal_digits)::text
				WHEN wst.value::numeric >= ROUND(wst.value::numeric, wstt.decimal_digits) AND LENGTH(SPLIT_PART(wst.value, ''.'', 2)) > wstt.decimal_digits
					THEN SPLIT_PART(wst.value, ''.'', 1) || ''.'' || TRIM(TRAILING ''0'' FROM CAST(SPLIT_PART(wst.value, ''.'', 2) AS TEXT))
				ELSE wst.value::text END) 
				|| coalesce(wst.unit, '''') 
			else null
		end as result
	FROM
		water_servey_tbl AS wst
	LEFT JOIN water_survey_point_tbl AS wspt ON wst.point_cd = wspt.survey_point_cd::TEXT
	LEFT JOIN water_survey_type_tbl AS wstt ON wspt.survey_type_cd = wstt.survey_type_cd
) a ORDER BY ARRAY_POSITION(ARRAY[@machineNos], a.machine_no), a.survey_point_order, a.survey_type_order, a.inspection_date;
', 2, '[{"preview":"ET","can_calc":"0","data_code":"survey_type_name","data_name":"種別名","data_type":"string","conv_table":[],"data_class":"水質検査","field_name":"survey_type_name","disp_format":"","filter_type":"WQTestType","data_category":"水質管理","facility_table":"","facility_filter_type":"0"},{"preview":"mg/dL","can_calc":"0","data_code":"survey_type_unit","data_name":"種別単位","data_type":"string","conv_table":[],"data_class":"水質検査","field_name":"survey_type_unit","disp_format":"","filter_type":"WQTestType","data_category":"水質管理","facility_table":"","facility_filter_type":"0"},{"preview":"100","can_calc":"0","data_code":"survey_type_upper_threshold","data_name":"種別閾値上限","data_type":"decimal","conv_table":[],"data_class":"水質検査","field_name":"survey_type_upper_threshold","disp_format":"0","filter_type":"WQTestType","data_category":"水質管理","facility_table":"","facility_filter_type":"0"},{"preview":"0","can_calc":"0","data_code":"survey_type_lower_threshold","data_name":"種別閾値下限","data_type":"decimal","conv_table":[],"data_class":"水質検査","field_name":"survey_type_lower_threshold","disp_format":"0","filter_type":"WQTestType","data_category":"水質管理","facility_table":"","facility_filter_type":"0"},{"preview":"100","can_calc":"0","data_code":"survey_type_graph_upper_limit","data_name":"種別グラフ上限","data_type":"decimal","conv_table":[],"data_class":"水質検査","field_name":"survey_type_graph_upper_limit","disp_format":"0","filter_type":"WQTestType","data_category":"水質管理","facility_table":"","facility_filter_type":"0"},{"preview":"0","can_calc":"0","data_code":"survey_type_graph_lower_limit","data_name":"種別グラフ下限","data_type":"decimal","conv_table":[],"data_class":"水質検査","field_name":"survey_type_graph_lower_limit","disp_format":"0","filter_type":"WQTestType","data_category":"水質管理","facility_table":"","facility_filter_type":"0"},{"preview":"B原液タンク(ET)","can_calc":"0","data_code":"survey_point_name","data_name":"箇所名","data_type":"string","conv_table":[],"data_class":"水質検査","field_name":"survey_point_name","disp_format":"","filter_type":"WQTestType","data_category":"水質管理","facility_table":"","facility_filter_type":"0"},{"preview":"123456789","can_calc":"0","data_code":"survey_point_in_hospital_cd_1","data_name":"箇所連携コード1","data_type":"string","conv_table":[],"data_class":"水質検査","field_name":"survey_point_in_hospital_cd_1","disp_format":"","filter_type":"WQTestType","data_category":"水質管理","facility_table":"","facility_filter_type":"0"},{"preview":"123456789","can_calc":"0","data_code":"survey_point_in_hospital_cd_2","data_name":"箇所連携コード2","data_type":"string","conv_table":[],"data_class":"水質検査","field_name":"survey_point_in_hospital_cd_2","disp_format":"","filter_type":"WQTestType","data_category":"水質管理","facility_table":"","facility_filter_type":"0"},{"preview":"2026/03/12","can_calc":"0","data_code":"inspection_date","data_name":"検査日","data_type":"DateTime","conv_table":[],"data_class":"水質検査","field_name":"inspection_date","disp_format":"yyyy/mm/dd","filter_type":"WQTestType","data_category":"水質管理","facility_table":"","facility_filter_type":"0"},{"preview":"〇","can_calc":"0","data_code":"plan","data_name":"予定","data_type":"string","conv_table":[{"code":"0","disp":"×","item":"予定無し"},{"code":"1","disp":"〇","item":"予定有り"}],"data_class":"水質検査","field_name":"plan","disp_format":"","filter_type":"WQTestType","data_category":"水質管理","facility_table":"","facility_filter_type":"0"},{"preview":"00:00","can_calc":"0","data_code":"time","data_name":"採取時刻","data_type":"DateTime","conv_table":[],"data_class":"水質検査","field_name":"time","disp_format":"hh:mm","filter_type":"WQTestType","data_category":"水質管理","facility_table":"","facility_filter_type":"0"},{"preview":"テスト技士１","can_calc":"0","conv_sql":{"sql_cd":-2,"field_name":"user_name","target_var":"@userId"},"data_code":"picker","data_name":"採取者","data_type":"string","conv_table":[],"data_class":"水質検査","field_name":"picker","disp_format":"","filter_type":"WQTestType","data_category":"水質管理","facility_table":"","facility_filter_type":"0"},{"preview":"200EU/mL","can_calc":"0","data_code":"result","data_name":"検査結果","data_type":"string","conv_table":[],"data_class":"水質検査","field_name":"result","disp_format":"","filter_type":"WQTestType","data_category":"水質管理","facility_table":"","facility_filter_type":"0"},{"preview":"未満","can_calc":"0","data_code":"result_flag","data_name":"検査結果しきい値区分","data_type":"string","conv_table":[],"data_class":"水質検査","field_name":"text","disp_format":"","filter_type":"WQTestType","data_category":"水質管理","facility_table":"","facility_filter_type":"0"},{"preview":"テスト技士１","can_calc":"0","conv_sql":{"sql_cd":-2,"field_name":"user_name","target_var":"@userId"},"data_code":"inspector","data_name":"検査者","data_type":"string","conv_table":[],"data_class":"水質検査","field_name":"inspector","disp_format":"","filter_type":"WQTestType","data_category":"水質管理","facility_table":"","facility_filter_type":"0"},{"preview":"未満","can_calc":"0","data_code":"memo","data_name":"備考","data_type":"string","conv_table":[],"data_class":"水質検査","field_name":"memo","disp_format":"","filter_type":"WQTestType","data_category":"水質管理","facility_table":"","facility_filter_type":"0"}]', '1', '{"applications": [1]}', '{"classes": [7]}', '水質管理：水質検査 @machineNos @facilityCd @fromDate @toDate', '2026-03-04 21:18:37.51', CURRENT_TIMESTAMP, NULL);

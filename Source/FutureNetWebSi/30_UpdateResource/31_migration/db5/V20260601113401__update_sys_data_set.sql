DELETE FROM "ntss"."sys_data_set" where sql_cd in (197);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (197, 'with examSet_table as (
	SELECT DISTINCT
		CAST(info ->> ''exam_item_cd'' AS NUMERIC) AS exam_item_cd
	FROM
	  mst_exam_set as mes cross join lateral jsonb_array_elements(mes.exam_item_info) with ordinality as tmp(info, json_idx)
	WHERE
		facility_Cd = @facilityCd
		AND exam_set_cd = @selectExamSetCd
		AND is_disp = ''1''
		AND is_del = ''0''
)
, normal_value_set as (
	SELECT value FROM mst_facility_setting WHERE facility_cd = @facilityCd AND facility_setting_no = ''1017''
)
, exam_item_order AS(
	SELECT
		one_json ->> ''code'' AS exam_item_cd
		, json_idx AS exam_item_order
	FROM
		mst_selector
		CROSS JOIN lateral jsonb_array_elements (order_settings -> ''items'') with ordinality as tmp (one_json, json_idx)
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_exam_item''
)
, exam_item_tbl as (
	SELECT
		mei.exam_item_cd,
		exam_item_name,
		unit AS exam_unit,
		CASE
			WHEN normal_value_class = ''1'' AND (SELECT value FROM normal_value_set) = ''1'' THEN normal_value_upper_m
			WHEN normal_value_class = ''1'' AND (SELECT value FROM normal_value_set) = ''2'' THEN normal_value_upper_w
			ELSE normal_value_upper
		END AS exam_upper,
		CASE
			WHEN normal_value_class = ''1'' AND (SELECT value FROM normal_value_set) = ''1'' THEN normal_value_lower_m
			WHEN normal_value_class = ''1'' AND (SELECT value FROM normal_value_set) = ''2'' THEN normal_value_lower_w
			ELSE normal_value_lower
		END AS exam_lower,
		CASE
			WHEN normal_value_class = ''1'' AND (SELECT value FROM normal_value_set) = ''1'' THEN 
				(CASE
					WHEN normal_value_lower_m IS NULL OR normal_value_lower_m = ''null'' THEN ''''
					WHEN normal_value_upper_m IS NULL OR normal_value_upper_m = ''null'' THEN ''''
					ELSE normal_value_lower_m || ''~'' || normal_value_upper_m
				END)
			WHEN normal_value_class = ''1'' AND (SELECT value FROM normal_value_set) = ''2'' THEN 
				(CASE
					WHEN normal_value_lower_w IS NULL OR normal_value_lower_w = ''null'' THEN ''''
					WHEN normal_value_upper_w IS NULL OR normal_value_upper_w = ''null'' THEN ''''
					ELSE normal_value_lower_w || ''~'' || normal_value_upper_w
				END)
			ELSE 
				(CASE
					WHEN normal_value_lower IS NULL OR normal_value_lower = ''null'' THEN ''''
					WHEN normal_value_upper IS NULL OR normal_value_upper = ''null'' THEN ''''
					ELSE normal_value_lower || ''~'' || normal_value_upper
				END)
		END AS exam_normal_value,
		in_hospital_cd1,
		in_hospital_cd2,
		in_hospital_cd3,
		sbt_cd1,
		sbt_cd2,
		sbt_cd3,
		inf.exam_item_order
	FROM
	  mst_exam_item as mei
	LEFT JOIN examSet_table AS et ON et.exam_item_cd = mei.exam_item_cd
	LEFT JOIN exam_item_order as inf on mei.exam_item_cd::text = inf.exam_item_cd
	WHERE
		facility_Cd = @facilityCd
		AND is_disp = ''1''
		AND is_del = ''0''
		AND @selectExamSetCd = -1 OR et.exam_item_cd IS NOT NULL
)
, result_table as (
	SELECT
		p.pat_id AS pat_id,
		p.exam_main_cd as exam_main_cd,
		p.result_exam_date AS result_exam_date,
		p.reg_exam_date,
		p.reg_order_class,
		CAST(info ->> ''item_cd'' AS NUMERIC) AS item_cd,
		info ->> ''item_name'' AS item_name,
		info ->> ''result'' AS RESULT,
		info ->> ''unit'' AS unit,
		info ->> ''freememo'' AS freememo,
		info ->> ''upper'' AS UPPER,
		info ->> ''lower'' AS LOWER,
		CASE
				WHEN info ->> ''lower'' IS NULL OR info ->> ''lower'' = ''null'' THEN ''''
				WHEN info ->> ''upper'' IS NULL OR info ->> ''upper'' = ''null'' THEN ''''
				ELSE CAST(info ->> ''lower'' AS VARCHAR) || ''~'' || CAST(info ->> ''upper'' AS VARCHAR)
		END AS normal_value
	FROM
	(
		SELECT
			m.*
		FROM
			pat_exam_main AS M
		WHERE
			m.pat_id in (@patIds)
			AND m.facility_Cd = @facilityCd
			AND m.result_exam_date BETWEEN date_trunc( ''day'', @fromDate :: TIMESTAMP ) AND date_trunc( ''day'', @toDate :: TIMESTAMP ) + ''1 days - 1 milliseconds''
			AND m.is_del = ''0''
			AND m.exam_status = ''1''
			AND m.reg_order_class in (@regOrderClassList)
	) AS p
	cross join lateral jsonb_array_elements(p.exam_result_info) with ordinality as tmp(info, json_idx)
	LEFT JOIN examSet_table AS et ON et.exam_item_cd::TEXT = info ->> ''item_cd''
	WHERE
		@selectExamSetCd = -1 OR et.exam_item_cd IS NOT NULL
)

SELECT
	rt.pat_id,
	rt.exam_main_cd,
	rt.result_exam_date,
	rt.reg_exam_date,
	CASE
		WHEN rt.reg_order_class IS NULL THEN ''9''
		WHEN rt.reg_order_class = ''0'' THEN ''9''
		ELSE rt.reg_order_class
	END AS reg_order_class_sort,
	CASE 
		WHEN rt.reg_order_class IS NOT NULL AND rt.reg_order_class != '''' THEN rt.reg_order_class
		ELSE ''''
	END AS reg_order_class,
	eit.exam_item_order,
	eit.exam_item_cd AS item_cd,
	CASE 
		WHEN rt.item_name IS NOT NULL AND rt.item_name != '''' THEN rt.item_name
		ELSE eit.exam_item_name
	END AS item_name,
	CASE 
		WHEN rt.unit IS NOT NULL AND rt.unit != '''' THEN rt.unit
		ELSE eit.exam_unit
	END AS unit,
	CASE 
		WHEN rt.UPPER IS NOT NULL AND rt.UPPER != '''' THEN rt.UPPER
		ELSE eit.exam_upper
	END AS UPPER,
	CASE 
		WHEN rt.LOWER IS NOT NULL AND rt.LOWER != '''' THEN rt.LOWER
		ELSE eit.exam_lower
	END AS LOWER,
	CASE 
		WHEN rt.normal_value IS NOT NULL AND rt.normal_value != '''' THEN rt.normal_value
		ELSE eit.exam_normal_value
	END AS normal_value,
	CASE WHEN rt.RESULT is not null AND rt.RESULT != '''' THEN ''1''
		ELSE ''0''
	END AS has_result,
	CASE WHEN rt.pat_id is not null THEN 1
		ELSE 0
	END AS exam_count,
	rt.RESULT,
	rt.freememo
FROM
	exam_item_tbl AS eit
LEFT JOIN result_table AS rt ON eit.exam_item_cd = rt.item_cd
ORDER BY
	exam_item_order, pat_id, rt.result_exam_date, ARRAY_POSITION(ARRAY[''1'',''2'',''0''], rt.reg_order_class)
', 2, '[{"preview": "検査項目テスト", "can_calc": "0", "data_code": "item_name", "data_name": "検査項目名", "data_type": "string", "conv_table": [], "data_class": "検査結果(フィルタなし)", "field_name": "item_name", "disp_format": "", "filter_type": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "11.2", "can_calc": "0", "data_code": "result", "data_name": "検査結果", "data_type": "string", "conv_table": [], "data_class": "検査結果(フィルタなし)", "field_name": "result", "disp_format": "", "filter_type": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mg/dL", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "検査結果(フィルタなし)", "field_name": "unit", "disp_format": "", "filter_type": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/12", "can_calc": "0", "data_code": "result_exam_date", "data_name": "検査日", "data_type": "DateTime", "conv_table": [], "data_class": "検査結果(フィルタなし)", "field_name": "result_exam_date", "disp_format": "yyyy/mm/dd", "filter_type": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析前", "can_calc": "0", "data_code": "reg_order_class", "data_name": "検査区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "その他", "item": "その他"}, {"code": "1", "disp": "透析前", "item": "透析前"}, {"code": "2", "disp": "透析後", "item": "透析後"}], "data_class": "検査結果(フィルタなし)", "field_name": "reg_order_class", "disp_format": "", "filter_type": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234", "can_calc": "0", "data_code": "in_hospital_cd1", "data_name": "院内コード1", "data_type": "string", "conv_table": [], "data_class": "検査結果(フィルタなし)", "field_name": "in_hospital_cd1", "disp_format": "", "filter_type": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4567", "can_calc": "0", "data_code": "in_hospital_cd2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "検査結果(フィルタなし)", "field_name": "in_hospital_cd2", "disp_format": "", "filter_type": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7890", "can_calc": "0", "data_code": "in_hospital_cd3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "検査結果(フィルタなし)", "field_name": "in_hospital_cd3", "disp_format": "", "filter_type": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0123", "can_calc": "0", "data_code": "sbt_cd1", "data_name": "属性コード1", "data_type": "string", "conv_table": [], "data_class": "検査結果(フィルタなし)", "field_name": "sbt_cd1", "disp_format": "", "filter_type": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3456", "can_calc": "0", "data_code": "sbt_cd2", "data_name": "属性コード2", "data_type": "string", "conv_table": [], "data_class": "検査結果(フィルタなし)", "field_name": "sbt_cd2", "disp_format": "", "filter_type": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6789", "can_calc": "0", "data_code": "sbt_cd3", "data_name": "属性コード3", "data_type": "string", "conv_table": [], "data_class": "検査結果(フィルタなし)", "field_name": "sbt_cd3", "disp_format": "", "filter_type": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15.0", "can_calc": "0", "data_code": "upper", "data_name": "正常値上限", "data_type": "decimal", "conv_table": [], "data_class": "検査結果(フィルタなし)", "field_name": "upper", "disp_format": "0.0", "filter_type": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10.0", "can_calc": "0", "data_code": "lower", "data_name": "正常値下限", "data_type": "decimal", "conv_table": [], "data_class": "検査結果(フィルタなし)", "field_name": "lower", "disp_format": "0.0", "filter_type": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10.0~15.0", "can_calc": "0", "data_code": "normal_value", "data_name": "正常値範囲", "data_type": "string", "conv_table": [], "data_class": "検査結果(フィルタなし)", "field_name": "normal_value", "disp_format": "", "filter_type": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "検査結果のテストです。", "can_calc": "0", "data_code": "freememo", "data_name": "検査コメント", "data_type": "string", "conv_table": [], "data_class": "検査結果(フィルタなし)", "field_name": "freememo", "disp_format": "", "filter_type": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "●", "can_calc": "0", "data_code": "has_result", "data_name": "検査有無", "data_type": "string", "conv_table": [{"code": "0", "disp": "", "item": "検査無し(変換不可)"}, {"code": "1", "disp": "●", "item": "検査有り"}], "data_class": "検査結果(フィルタなし)", "field_name": "has_result", "disp_format": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "1", "data_code": "exam_count", "data_name": "検査数", "data_type": "decimal", "conv_table": [], "data_class": "検査結果(フィルタなし)", "field_name": "exam_count", "disp_format": "0", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [9, 10, 11]}', '検査結果(フィルタなし) @patIds @facilityCd @fromDate @toDate @selectExamSetCd @regOrderClassList 使用', '2020-03-25 18:00:00', CURRENT_TIMESTAMP, NULL);

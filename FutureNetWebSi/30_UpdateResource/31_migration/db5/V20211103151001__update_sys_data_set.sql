update ntss.sys_data_set set sql = 'SELECT
	info ->> ''item_cd'' AS item_cd,
	item.in_hospital_cd1 AS in_hospital_cd1,
	item.in_hospital_cd2 AS in_hospital_cd2,
	item.in_hospital_cd3 AS in_hospital_cd3,
	item.sbt_cd1 AS sbt_cd1,
	item.sbt_cd2 AS sbt_cd2,
	item.sbt_cd3 AS sbt_cd3,
	info ->> ''item_name'' AS item_name,
	info ->> ''result'' AS RESULT,
	info ->> ''unit'' AS unit,
	info ->> ''freememo'' AS freememo,
	P.result_exam_date AS result_exam_date,
	P.reg_exam_date,
	P.reg_order_class,
	info ->> ''upper'' AS UPPER,
	info ->> ''lower'' AS LOWER,
	P.pat_id AS pat_id,
	P.pat_id AS pat_name
FROM
	(
	SELECT M
		.* 
	FROM
		pat_exam_main AS M 
	WHERE
		M.is_del = ''0'' 
		AND M.exam_status = ''1'' 
		AND M.pat_id = @patId 
		AND M.result_exam_date BETWEEN date_trunc( ''day'', @fromDate :: TIMESTAMP ) 
		AND date_trunc( ''day'', @toDate :: TIMESTAMP ) + ''1 days - 1 milliseconds'' 
	ORDER BY
		M.result_exam_date DESC 
	)
	AS P CROSS JOIN LATERAL json_array_elements ( P.exam_result_info :: json ) info
	Inner JOIN mst_exam_item AS item ON info ->> ''item_cd'' = ( item.exam_item_cd || '''' ) 
	AND ((@examItemCd
::text is not null and @examItemCd
::text  <> '''') and (item.exam_item_cd = @examItemCd
))
	AND item.facility_Cd = @facilityCd
	AND item.is_del = ''0'' 
	AND is_disp = ''1'' 
ORDER BY
	item_cd;', db_class = 2, detail = '[{"preview": "検査項目テスト", "can_calc": "0", "data_code": "item_name", "data_name": "検査項目名", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)複", "field_name": "item_name", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "11.2", "can_calc": "0", "data_code": "result", "data_name": "検査結果", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)複", "field_name": "result", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mg/dL", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)複", "field_name": "unit", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/12", "can_calc": "0", "data_code": "result_exam_date", "data_name": "検査日", "data_type": "DateTime", "conv_table": [], "data_class": "検査結果(指定日)複", "field_name": "result_exam_date", "disp_format": "yyyy/mm/dd", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析前", "can_calc": "0", "data_code": "reg_order_class", "data_name": "検査区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "その他", "item": "その他"}, {"code": "1", "disp": "透析前", "item": "透析前"}, {"code": "2", "disp": "透析後", "item": "透析後"}], "data_class": "検査結果(指定日)複", "field_name": "reg_order_class", "disp_format": "", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789012", "can_calc": "0", "conv_sql": {"sql_cd": 198, "field_name": "hosp_pat_id", "target_var": "@patId"}, "data_code": "pat_id", "data_name": "患者ID", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)複", "field_name": "pat_id", "disp_format": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日機装　太郎", "can_calc": "0", "conv_sql": {"sql_cd": 198, "field_name": "pat_name", "target_var": "@patId"}, "data_code": "pat_name", "data_name": "氏名", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日)複", "field_name": "pat_name", "disp_format": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}]', can_repeat = '1', use_application = '{"applications": [1]}', report_class = '{"classes": [1, 2, 3, 9, 10, 11]}', memo = '検査結果(指定日)複@patId @date 使用', reg_date = '2020/03/25 18:00:00', up_date = '2020/05/22', pre_sql_info = null where sql_cd = 197;


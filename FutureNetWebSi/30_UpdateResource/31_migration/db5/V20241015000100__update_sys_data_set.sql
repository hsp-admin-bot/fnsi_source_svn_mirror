DELETE FROM "ntss"."sys_data_set" where sql_cd in (197);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (197, 'with result_table as (
SELECT
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
	p.exam_main_cd as exam_main_cd,
	info ->> ''upper'' AS UPPER,
	info ->> ''lower'' AS LOWER,
	P.pat_id AS pat_id,
	P.pat_id AS pat_name,
	p.pat_id AS pat_birthday,
	p.pat_id AS pat_age,
	p.pat_id AS pat_sex,
	p.pat_id AS in_out_class,
	p.pat_id AS pat_blood_type_abo_rh
FROM
	(
	SELECT M
		.*
	FROM
		pat_exam_main AS M
	WHERE
		M.is_del = ''0''
		AND M.exam_status = ''1''
		AND M.pat_id in (@patIds)
		AND M.result_exam_date BETWEEN date_trunc( ''day'', @fromDate :: TIMESTAMP )
		AND date_trunc( ''day'', @toDate :: TIMESTAMP ) + ''1 days - 1 milliseconds''
	ORDER BY
		M.result_exam_date DESC
	)
	AS P cross join lateral jsonb_array_elements(P.exam_result_info) with ordinality as tmp(info, json_idx)
	Inner JOIN mst_exam_item AS item ON info ->> ''item_cd'' = ( item.exam_item_cd || '''' )
	AND item.facility_Cd = @facilityCd
	AND item.is_del = ''0''
	AND is_disp = ''1''
ORDER BY
	pat_id,json_idx
),
examSet_table as (
	SELECT
		info ->> ''exam_item_cd'' AS exam_item_cd,
		exam_set_cd
	FROM
	  mst_exam_set as mes cross join lateral jsonb_array_elements(mes.exam_item_info) with ordinality as tmp(info, json_idx)
	WHERE
		exam_set_cd = @selectExamSetCd
		AND is_disp = ''1''
		AND is_del = ''0''
		AND facility_Cd = @facilityCd
)

SELECT
    rt.*,
    et.*,
    CASE
        WHEN LOWER IS NULL OR LOWER = ''null'' THEN ''''
        WHEN UPPER IS NULL OR UPPER = ''null'' THEN ''''
        ELSE LOWER || ''~'' || UPPER
    END AS normal_value
FROM
    result_table AS rt
left JOIN
    examSet_table AS et ON et.exam_item_cd = rt.item_cd
WHERE
    @selectExamSetCd = -1 OR et.exam_item_cd IS NOT NULL;', 2, '[{"preview": "検査項目テスト", "can_calc": "0", "data_code": "item_name", "data_name": "検査項目名", "data_type": "string", "conv_table": [], "data_class": "検査結果(フィルタなし)", "field_name": "item_name", "disp_format": "", "filter_type": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "11.2", "can_calc": "0", "data_code": "result", "data_name": "検査結果", "data_type": "string", "conv_table": [], "data_class": "検査結果(フィルタなし)", "field_name": "result", "disp_format": "", "filter_type": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mg/dL", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "検査結果(フィルタなし)", "field_name": "unit", "disp_format": "", "filter_type": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/12", "can_calc": "0", "data_code": "result_exam_date", "data_name": "検査日", "data_type": "DateTime", "conv_table": [], "data_class": "検査結果(フィルタなし)", "field_name": "result_exam_date", "disp_format": "yyyy/mm/dd", "filter_type": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析前", "can_calc": "0", "data_code": "reg_order_class", "data_name": "検査区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "その他", "item": "その他"}, {"code": "1", "disp": "透析前", "item": "透析前"}, {"code": "2", "disp": "透析後", "item": "透析後"}], "data_class": "検査結果(フィルタなし)", "field_name": "reg_order_class", "disp_format": "", "filter_type": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234", "can_calc": "0", "data_code": "in_hospital_cd1", "data_name": "院内コード1", "data_type": "string", "conv_table": [], "data_class": "検査結果(フィルタなし)", "field_name": "in_hospital_cd1", "disp_format": "", "filter_type": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4567", "can_calc": "0", "data_code": "in_hospital_cd2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "検査結果(フィルタなし)", "field_name": "in_hospital_cd2", "disp_format": "", "filter_type": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7890", "can_calc": "0", "data_code": "in_hospital_cd3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "検査結果(フィルタなし)", "field_name": "in_hospital_cd3", "disp_format": "", "filter_type": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0123", "can_calc": "0", "data_code": "sbt_cd1", "data_name": "属性コード1", "data_type": "string", "conv_table": [], "data_class": "検査結果(フィルタなし)", "field_name": "sbt_cd1", "disp_format": "", "filter_type": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3456", "can_calc": "0", "data_code": "sbt_cd2", "data_name": "属性コード2", "data_type": "string", "conv_table": [], "data_class": "検査結果(フィルタなし)", "field_name": "sbt_cd2", "disp_format": "", "filter_type": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6789", "can_calc": "0", "data_code": "sbt_cd3", "data_name": "属性コード3", "data_type": "string", "conv_table": [], "data_class": "検査結果(フィルタなし)", "field_name": "sbt_cd3", "disp_format": "", "filter_type": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15.0", "can_calc": "0", "data_code": "upper", "data_name": "正常値上限", "data_type": "decimal", "conv_table": [], "data_class": "検査結果(フィルタなし)", "field_name": "upper", "disp_format": "0.0", "filter_type": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10.0", "can_calc": "0", "data_code": "lower", "data_name": "正常値下限", "data_type": "decimal", "conv_table": [], "data_class": "検査結果(フィルタなし)", "field_name": "lower", "disp_format": "0.0", "filter_type": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10.0～15.0", "can_calc": "0", "data_code": "normal_value", "data_name": "正常値範囲", "data_type": "string", "conv_table": [], "data_class": "検査結果(フィルタなし)", "field_name": "normal_value", "disp_format": "", "filter_type": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "検査結果のテストです。", "can_calc": "0", "data_code": "freememo", "data_name": "検査コメント", "data_type": "string", "conv_table": [], "data_class": "検査結果(フィルタなし)", "field_name": "freememo", "disp_format": "", "filter_type": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [9, 10]}', '検査結果(フィルタなし)@patIds @fromDate @toDate @examItemCd @facilityCd 使用', '2020-03-25 18:00:00', CURRENT_TIMESTAMP, NULL);

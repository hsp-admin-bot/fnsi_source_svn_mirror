DELETE FROM "ntss"."sys_data_set" WHERE sql_cd = 255;
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (255, 'WITH 
patIds_tbl AS (
	SELECT
		ord.pat_id,
		ord.treat_date,
		ord.ord_no
	FROM
		ord_schedule AS ord
	INNER JOIN ord_main 
		ON ord.ord_no = ord_main.ord_no 
		AND ord.facility_cd = ord_main.facility_cd
	LEFT JOIN mst_bed 
		ON mst_bed.bed_cd = ord.bed_cd
	WHERE
		ord.treat_date BETWEEN to_char(date_trunc(''day'', (@fromDate)::timestamp), ''yyyymmdd'')
    AND to_char(date_trunc(''day'', (@toDate)::timestamp), ''yyyymmdd'')
		AND ord.facility_cd = @facilityCd
		AND ord.pat_id IN ( @patIds )
		AND ord.is_dummy = ''0''
		AND (
			mst_bed.machine_no IS NOT NULL OR 
			(mst_bed.machine_no IS NULL AND mst_bed.bed_cd IS NULL)
		)
)
,Selunique AS (
	SELECT DISTINCT ON (pat_id, in_out_date)
		pat_id,
		ELEMENT->> ''period_start'' AS in_out_date,
		ELEMENT ->> ''move_in_out'' AS move_in_out,
		ELEMENT ->> ''ctl_no'' AS ctl_no,
		CASE
			WHEN ELEMENT ->> ''move_in_out'' = ''4'' THEN ''入院''
			WHEN ELEMENT ->> ''move_in_out'' = ''11'' THEN ''死亡''
			ELSE ''外来''
		END AS move_in_out_name 
	FROM
		pat_unique,
		jsonb_array_elements (in_out_visit_history_info) AS ELEMENT 
	WHERE
		pat_id IN ( @patIds )
		AND facility_cd = @facilityCd
	ORDER BY pat_id, in_out_date DESC, ctl_no DESC
)
,joined_tbl AS (
	SELECT
		pt.pat_id,
		pt.treat_date,
    pt.ord_no,
		se.in_out_date,
		se.move_in_out,
		se.move_in_out_name
	FROM
		patIds_tbl pt
	LEFT JOIN Selunique se 
		ON pt.pat_id = se.pat_id 
		AND pt.treat_date >= se.in_out_date
)
,deduplicated AS (
	SELECT DISTINCT ON (pat_id, treat_date, ord_no)
		pat_id,
		treat_date,
    ord_no,
		COALESCE(move_in_out_name, ''外来'') AS move_in_out_name
	FROM joined_tbl
	ORDER BY pat_id, treat_date, ord_no, in_out_date DESC
)

SELECT
	COUNT(*) FILTER (WHERE move_in_out_name = ''入院'')  AS in_count,
	COUNT(*) FILTER (WHERE move_in_out_name = ''外来'')  AS out_count,
	COUNT(*) FILTER (WHERE move_in_out_name = ''死亡'')  AS death_count,
	COUNT(*) FILTER (WHERE move_in_out_name != ''死亡'') AS total_count
FROM
	deduplicated;
', 2, '[{"preview": "11", "can_calc": "0", "data_code": "in_count", "data_name": "対象患者数(入院)", "data_type": "string", "conv_table": [], "data_class": "入外・転入出", "field_name": "in_count", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "22", "can_calc": "0", "data_code": "out_count", "data_name": "対象患者数(外来)", "data_type": "string", "conv_table": [], "data_class": "入外・転入出", "field_name": "out_count", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "33", "can_calc": "0", "data_code": "total_count", "data_name": "対象患者数(総数)", "data_type": "string", "conv_table": [], "data_class": "入外・転入出", "field_name": "total_count", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [3, 11]}', '患者情報：入外・転入出　@patIds @fromDate @toDate', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

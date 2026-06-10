DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (43)
;
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(43, 'WITH pat_in_out_visit_history_tbl AS (
SELECT
	to_number ( info ->> ''ctl_no'', ''99999'' ) AS ctl_no,
	to_number ( info ->> ''disp_order'', ''99999'' ) AS disp_order,
	info ->> ''facility_cd'' AS facility_cd,
	info ->> ''move_in_out'' AS move_in_out,
	info ->> ''period_start'' AS period_start,
	info ->> ''period_end'' period_end,
	info ->> ''in_out'' AS in_out,
	info ->> ''reason'' AS reason,
	info ->> ''from_facility'' AS from_facility,
	info ->> ''from_course'' AS from_course,
	info ->> ''from_doctor'' AS from_doctor,
	info ->> ''to_facility'' AS to_facility,
	info ->> ''to_course'' AS to_course,
	info ->> ''to_doctor'' AS to_doctor,
	info ->> ''is_reply'' AS is_reply,
	info ->> ''comment'' AS COMMENT 
FROM
	pat_unique
	CROSS JOIN lateral json_array_elements ( pat_unique.in_out_visit_history_info :: json ) info 
WHERE
	pat_id = @patId 
	AND is_del = ''0'' 
	) 
SELECT
	to_date ( pat_in_out_visit_history_tbl.period_start, ''YYYYMMDD'' ) AS period_start,
	pat_in_out_visit_history_tbl.ctl_no,
	pat_in_out_visit_history_tbl.disp_order,
	pat_in_out_visit_history_tbl.facility_cd,
	pat_in_out_visit_history_tbl.move_in_out,
	to_date ( pat_in_out_visit_history_tbl.period_end, ''YYYYMMDD'' ) AS period_end,
	pat_in_out_visit_history_tbl.in_out,
	pat_in_out_visit_history_tbl.reason,
	pat_in_out_visit_history_tbl.from_facility,
	pat_in_out_visit_history_tbl.from_course,
	pat_in_out_visit_history_tbl.from_doctor,
	pat_in_out_visit_history_tbl.to_facility,
	pat_in_out_visit_history_tbl.to_course,
	pat_in_out_visit_history_tbl.to_doctor,
	pat_in_out_visit_history_tbl.is_reply,
	pat_in_out_visit_history_tbl.COMMENT,
	CASE
		WHEN pat_in_out_visit_history_tbl.move_in_out = ''3'' 
		OR pat_in_out_visit_history_tbl.move_in_out = ''9'' THEN NULL
		ELSE CASE
			WHEN from_facility_tbl.facility_name IS NULL THEN CASE
				WHEN from_sys_facility_tbl.facility_name IS NOT NULL THEN from_sys_facility_tbl.facility_name
			END
			ELSE from_facility_tbl.facility_name
		END
	END AS from_facility_name,
	CASE
		WHEN pat_in_out_visit_history_tbl.move_in_out = ''3'' 
		OR pat_in_out_visit_history_tbl.move_in_out = ''9'' THEN NULL
		ELSE CASE
			WHEN from_course_tbl.course_name IS NULL THEN pat_in_out_visit_history_tbl.from_course
			ELSE from_course_tbl.course_name
		END
	END AS from_course_name,
	CASE
		WHEN pat_in_out_visit_history_tbl.move_in_out = ''1'' 
		OR pat_in_out_visit_history_tbl.move_in_out = ''2''
		OR pat_in_out_visit_history_tbl.move_in_out = ''4''
		OR pat_in_out_visit_history_tbl.move_in_out = ''5''
		OR pat_in_out_visit_history_tbl.move_in_out = ''6''
		OR pat_in_out_visit_history_tbl.move_in_out = ''7''
		OR pat_in_out_visit_history_tbl.move_in_out = ''8''
		OR pat_in_out_visit_history_tbl.move_in_out = ''10''
		OR pat_in_out_visit_history_tbl.move_in_out = ''11'' THEN NULL
		ELSE CASE
			WHEN to_facility_tbl.facility_name IS NULL THEN CASE
				WHEN to_sys_facility_tbl.facility_name IS NOT NULL THEN to_sys_facility_tbl.facility_name
				ELSE CASE
					WHEN from_sys_facility_tbl.facility_name IS NULL THEN from_facility_tbl.facility_name
					ELSE from_sys_facility_tbl.facility_name
				END
			END
			ELSE to_facility_tbl.facility_name
		END
	END AS to_facility_name,
	CASE
		WHEN facility_cd_tbl.facility_name IS NULL THEN pat_in_out_visit_history_tbl.facility_cd
		ELSE facility_cd_tbl.facility_name
	END AS facility_cd_name,
	CASE
		WHEN pat_in_out_visit_history_tbl.move_in_out = ''1'' 
		OR pat_in_out_visit_history_tbl.move_in_out = ''2''
		OR pat_in_out_visit_history_tbl.move_in_out = ''4''
		OR pat_in_out_visit_history_tbl.move_in_out = ''5''
		OR pat_in_out_visit_history_tbl.move_in_out = ''6''
		OR pat_in_out_visit_history_tbl.move_in_out = ''7''
		OR pat_in_out_visit_history_tbl.move_in_out = ''8''
		OR pat_in_out_visit_history_tbl.move_in_out = ''10''
		OR pat_in_out_visit_history_tbl.move_in_out = ''11'' THEN NULL
		ELSE CASE
			WHEN to_course_tbl.course_name IS NULL THEN CASE
				WHEN from_course_tbl.course_name IS NOT NULL THEN from_course_tbl.course_name
			END
			ELSE to_course_tbl.course_name
		END
	END AS to_course_name

FROM
	pat_in_out_visit_history_tbl
	LEFT JOIN mst_facility AS from_facility_tbl ON pat_in_out_visit_history_tbl.from_facility = from_facility_tbl.facility_cd
	LEFT JOIN mst_course AS from_course_tbl ON pat_in_out_visit_history_tbl.from_course = from_course_tbl.course_cd :: text 
	AND from_course_tbl.is_disp = ''1'' 
	AND from_course_tbl.is_del = ''0''
	LEFT JOIN mst_facility AS to_facility_tbl ON pat_in_out_visit_history_tbl.to_facility = to_facility_tbl.facility_cd
	LEFT JOIN mst_course AS to_course_tbl ON pat_in_out_visit_history_tbl.to_course = to_course_tbl.course_cd :: text 
	AND to_course_tbl.is_disp = ''1'' 
	AND to_course_tbl.is_del = ''0''
	LEFT JOIN mst_facility AS facility_cd_tbl ON pat_in_out_visit_history_tbl.facility_cd = facility_cd_tbl.facility_cd 
	LEFT JOIN sys_facility AS from_sys_facility_tbl ON pat_in_out_visit_history_tbl.from_facility = from_sys_facility_tbl.medical_institution_cd
	LEFT JOIN sys_facility AS to_sys_facility_tbl ON pat_in_out_visit_history_tbl.to_facility = to_sys_facility_tbl.medical_institution_cd
ORDER BY
	period_start desc
', 2, '[{"preview": "2011/04/21", "can_calc": "0", "data_code": "period_start", "data_name": "発生日", "data_type": "DateTime", "conv_table": [], "data_class": "転入・転出", "field_name": "period_start", "disp_format": "yyyy/mm/dd", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/04/21", "can_calc": "0", "data_code": "period_end", "data_name": "転入出期間(終了)", "data_type": "DateTime", "conv_table": [], "data_class": "転入・転出", "field_name": "period_end", "disp_format": "yyyy/mm/dd", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "facility_cd_name", "data_name": "登録施設名", "data_type": "DateTime", "conv_table": [], "data_class": "転入・転出", "field_name": "facility_cd_name", "disp_format": "yyyy/mm/dd", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "転出", "can_calc": "0", "data_code": "move_in_out", "data_name": "区分", "data_type": "string", "conv_table": [{"code": "1", "disp": "導入", "item": "導入"}, {"code": "2", "disp": "転入", "item": "転入"}, {"code": "3", "disp": "転出", "item": "転出"}, {"code": "4", "disp": "入院", "item": "入院"}, {"code": "5", "disp": "退院", "item": "退院"}, {"code": "6", "disp": "外来", "item": "外来"}, {"code": "7", "disp": "離脱", "item": "離脱"}, {"code": "8", "disp": "移植", "item": "移植"}, {"code": "9", "disp": "一時転出", "item": "一時転出"}, {"code": "10", "disp": "通院拒否・不明", "item": "通院拒否・不明"}, {"code": "11", "disp": "死亡", "item": "死亡"}], "data_class": "転入・転出", "field_name": "move_in_out", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "入院", "can_calc": "0", "data_code": "in_out", "data_name": "入外区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "外来", "item": "外来"}, {"code": "1", "disp": "入院", "item": "入院"}, {"code": "2", "disp": "死亡", "item": "死亡"}, {"code": "3", "disp": "－(不在)", "item": "－(不在)"}], "data_class": "転入・転出", "field_name": "in_out", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日機装第二クリニック", "can_calc": "0", "data_code": "from_facility_name", "data_name": "転入元施設名", "data_type": "string", "conv_table": [], "data_class": "転入・転出", "field_name": "from_facility_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "第二透析科", "can_calc": "0", "data_code": "from_course_name", "data_name": "転入元科", "data_type": "string", "conv_table": [], "data_class": "転入・転出", "field_name": "from_course_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト医師１", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "from_doctor", "data_name": "転入元医師", "data_type": "string", "conv_table": [], "data_class": "転入・転出", "field_name": "from_doctor", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日機装第一クリニック", "can_calc": "0", "data_code": "to_facility_name", "data_name": "転出先施設名", "data_type": "string", "conv_table": [], "data_class": "転入・転出", "field_name": "to_facility_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "第一透析科", "can_calc": "0", "data_code": "to_course_name", "data_name": "転出先科", "data_type": "string", "conv_table": [], "data_class": "転入・転出", "field_name": "to_course_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト医師２", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "to_doctor", "data_name": "転出先医師", "data_type": "string", "conv_table": [], "data_class": "転入・転出", "field_name": "to_doctor", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "転入・転出コメントです。", "can_calc": "0", "data_code": "reason", "data_name": "コメント", "data_type": "string", "conv_table": [], "data_class": "転入・転出", "field_name": "reason", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]'::jsonb, '1', '{"applications": [1]}'::jsonb, '{"classes": [1, 2, 3, 9, 10, 11]}'::jsonb, '患者情報：転入・転出　@patId', '2020-03-26 14:18:00.000', CURRENT_TIMESTAMP, NULL);


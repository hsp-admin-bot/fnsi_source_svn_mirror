DELETE FROM "ntss"."sys_data_set" where sql_cd in (233);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (233, 'SELECT
	p.pat_event_cd
	,to_date(p.report_date, ''YYYY-MM-DD'') as report_date
	,(SELECT sys_facility.facility_name FROM sys_facility 
			WHERE CASE WHEN p.letter_info->>''to_facility_cd'' is not null and p.letter_info->>''to_facility_cd'' <> '''' THEN sys_facility.medical_institution_cd = p.letter_info->>''to_facility_cd''
					 WHEN p.letter_info->>''to_medical_institution_cd'' is not null and p.letter_info->>''to_medical_institution_cd'' <> '''' THEN sys_facility.medical_institution_cd = p.letter_info->>''to_medical_institution_cd''
					 ELSE sys_facility.medical_institution_cd = ''''
					 END
	) as medical_institution_name
	,p.reg_staff_info->>''reg_staff_cd'' as reg_staff_cd
	,p.reg_staff_info->>''reg_staff_name'' as reg_staff_name
	,p.up_staff_info->>''up_staff_cd'' as up_staff_cd
	,p.up_staff_info->>''up_staff_name'' as up_staff_name
	,p.reg_date
	,p.up_date
FROM
	pat_event as p
WHERE
	p.is_del = ''0''
	and p.use_type = 3 
	and p.pat_id = @patId 
	and p.facility_cd = @facilityCd
	and cast(p.event_start_date as date) between date_trunc(''day'', @fromDate::timestamp) and date_trunc(''day'', @toDate::timestamp)
ORDER BY p.report_date asc;', 2, '[{"preview": "2024/12/11", "can_calc": "0", "data_code": "report_date", "data_name": "転入出日", "data_type": "DateTime", "conv_table": [], "data_class": "登録情報", "field_name": "report_date", "disp_format": "yyyy/mm/dd", "data_category": "紹介状", "facility_table": "", "facility_filter_type": "0"}, {"preview": "北海道銀行医務室", "can_calc": "0", "data_code": "medical_institution_name", "data_name": "転入出先名", "data_type": "string", "conv_table": [], "data_class": "登録情報", "field_name": "medical_institution_name", "disp_format": "", "data_category": "紹介状", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxxxxx", "can_calc": "0", "data_code": "reg_staff_cd", "data_name": "起票者ID", "data_type": "string", "conv_table": [], "data_class": "登録情報", "field_name": "reg_staff_cd", "disp_format": "", "data_category": "紹介状", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師１", "can_calc": "0", "data_code": "reg_staff_name", "data_name": "起票者名", "data_type": "string", "conv_table": [], "data_class": "登録情報", "field_name": "reg_staff_name", "disp_format": "", "data_category": "紹介状", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxxxxx", "can_calc": "0", "data_code": "up_staff_cd", "data_name": "編集者ID", "data_type": "string", "conv_table": [], "data_class": "登録情報", "field_name": "up_staff_cd", "disp_format": "", "data_category": "紹介状", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師２", "can_calc": "0", "data_code": "up_staff_name", "data_name": "編集者名", "data_type": "string", "conv_table": [], "data_class": "登録情報", "field_name": "up_staff_name", "disp_format": "", "data_category": "紹介状", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2024/12/11", "can_calc": "0", "data_code": "reg_date", "data_name": "登録日時", "data_type": "DateTime", "conv_table": [], "data_class": "登録情報", "field_name": "reg_date", "disp_format": "yyyy/mm/dd", "data_category": "紹介状", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2024/12/11", "can_calc": "0", "data_code": "up_date", "data_name": "更新日時", "data_type": "DateTime", "conv_table": [], "data_class": "登録情報", "field_name": "up_date", "disp_format": "yyyy/mm/dd", "data_category": "紹介状", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [9]}', '紹介状： @facilityCd @patId @fromDate @toDate 使用', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);


DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (103, 235);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (103, 'SELECT
	occur_date,
	CAST ( monitor_data ->> ''90'' AS DECIMAL) AS bp_high,
	CAST ( monitor_data ->> ''91'' AS DECIMAL) AS bp_low,
	CAST ( monitor_data ->> ''92'' AS DECIMAL) AS bp_ave,
	CAST ( monitor_data ->> ''93'' AS DECIMAL) AS pulse,
	CAST ( monitor_data ->> ''94'' AS DECIMAL) AS body_temperature,
	CAST ( monitor_data ->> ''-1'' AS DECIMAL) AS blood_glucose_level,
	ord_no
FROM
	mni_monitor
WHERE
	ord_no = @ordNo
	AND data_type IN ( 0, 2, 4, 5, 6)
	AND is_del = ''0''
ORDER BY
	occur_date;', 2, '[{"preview": "130", "can_calc": "0", "data_code": "bp_high", "data_name": "最高血圧", "data_type": "decimal", "conv_table": [], "data_class": "バイタル(昇順)", "field_name": "bp_high", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "88", "can_calc": "0", "data_code": "bp_low", "data_name": "最低血圧", "data_type": "decimal", "conv_table": [], "data_class": "バイタル(昇順)", "field_name": "bp_low", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "0", "data_code": "bp_ave", "data_name": "平均血圧", "data_type": "decimal", "conv_table": [], "data_class": "バイタル(昇順)", "field_name": "bp_ave", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10:02", "can_calc": "0", "data_code": "occur_date", "data_name": "測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "バイタル(昇順)", "field_name": "occur_date", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "66", "can_calc": "0", "data_code": "pulse", "data_name": "脈拍", "data_type": "decimal", "conv_table": [], "data_class": "バイタル(昇順)", "field_name": "pulse", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "36.4", "can_calc": "0", "data_code": "body_temperature", "data_name": "体温", "data_type": "decimal", "conv_table": [], "data_class": "バイタル(昇順)", "field_name": "body_temperature", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "110.0", "can_calc": "0", "data_code": "blood_glucose_level", "data_name": "血糖値", "data_type": "decimal", "conv_table": [], "data_class": "バイタル(昇順)", "field_name": "blood_glucose_level", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：バイタル(昇順) @ordNo 使用', '2020-03-31 23:59:59', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (235, 'SELECT
	occur_date,
	CAST ( monitor_data ->> ''90'' AS DECIMAL) AS bp_high,
	CAST ( monitor_data ->> ''91'' AS DECIMAL) AS bp_low,
	CAST ( monitor_data ->> ''92'' AS DECIMAL) AS bp_ave,
	CAST ( monitor_data ->> ''93'' AS DECIMAL) AS pulse,
	CAST ( monitor_data ->> ''94'' AS DECIMAL) AS body_temperature,
	CAST ( monitor_data ->> ''-1'' AS DECIMAL) AS blood_glucose_level,
	ord_no
FROM
	mni_monitor
WHERE
	ord_no = @ordNo
	AND data_type IN ( 0, 2, 4, 5, 6)
	AND is_del = ''0''
ORDER BY
	occur_date desc;', 2, '[{"preview": "130", "can_calc": "0", "data_code": "bp_high", "data_name": "最高血圧", "data_type": "decimal", "conv_table": [], "data_class": "バイタル(降順)", "field_name": "bp_high", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "88", "can_calc": "0", "data_code": "bp_low", "data_name": "最低血圧", "data_type": "decimal", "conv_table": [], "data_class": "バイタル(降順)", "field_name": "bp_low", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "0", "data_code": "bp_ave", "data_name": "平均血圧", "data_type": "decimal", "conv_table": [], "data_class": "バイタル(降順)", "field_name": "bp_ave", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10:02", "can_calc": "0", "data_code": "occur_date", "data_name": "測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "バイタル(降順)", "field_name": "occur_date", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "66", "can_calc": "0", "data_code": "pulse", "data_name": "脈拍", "data_type": "decimal", "conv_table": [], "data_class": "バイタル(降順)", "field_name": "pulse", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "36.4", "can_calc": "0", "data_code": "body_temperature", "data_name": "体温", "data_type": "decimal", "conv_table": [], "data_class": "バイタル(降順)", "field_name": "body_temperature", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "110.0", "can_calc": "0", "data_code": "blood_glucose_level", "data_name": "血糖値", "data_type": "decimal", "conv_table": [], "data_class": "バイタル(降順)", "field_name": "blood_glucose_level", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：バイタル(降順) @ordNo 使用', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

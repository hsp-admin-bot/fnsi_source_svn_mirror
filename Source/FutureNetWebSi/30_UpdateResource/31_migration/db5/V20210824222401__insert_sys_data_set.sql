DELETE FROM sys_data_set a WHERE a.sql_cd in (-2020,-2021);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2020, 'SELECT
	'''' AS hosppatid --患者ID
	,'''' AS names --氏名
	,ntss_db5_pm_json ->> ''ctl_no'' AS ctlno --管理番号
	,to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
	,ntss_db5_pm_json ->> ''content'' AS taboo --禁忌
	,ntss_db5_pm_json ->> ''memo'' AS memo --備考
	,ntss_db5_pm.pat_id AS patid ----patid 外部キー
FROM
	pat_main ntss_db5_pm
	CROSS JOIN LATERAL json_array_elements(ntss_db5_pm.taboo_allergy_info ::json) ntss_db5_pm_json
WHERE ntss_db5_pm.is_del=''0''
	AND ntss_db5_pm.facility_cd =  @facilityCd
	AND ntss_db5_pm.up_date 
		BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' ) 
		AND to_date( @toDate , ''YYYYMMDDHH24MISS'' );', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者情報1：患者イベント テキスト　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2021, 'SELECT
	ntss_db6_ppm.hosp_pat_id AS hosppatid --患者ID
	,personal_info_decrypt(ntss_db6_ppm.pat_last_name)|| '' '' || personal_info_decrypt(ntss_db6_ppm.pat_first_name) AS names --氏名
	,ntss_db6_ppm.pat_id AS patid ----patid 外部キー
FROM
	pat_personal_main ntss_db6_ppm
WHERE ntss_db6_ppm.is_del=''0''
	AND ntss_db6_ppm.facility_cd=@facilityCd;', 3, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者情報1：患者イベント テキスト　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);

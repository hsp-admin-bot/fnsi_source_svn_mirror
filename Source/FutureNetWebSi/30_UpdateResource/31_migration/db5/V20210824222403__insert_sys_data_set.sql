DELETE FROM sys_data_set a WHERE a.sql_cd in (-2050,-2051);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2050, 'with ntss_db5_mst_mi as (
	SELECT
		ntss_db5_mst_infection.in_hospital_cd_1 AS inhospitalcd1
		,ntss_db5_mst_infection.infection_cd AS infectioncd
		,ntss_db5_mst_infection.infection_name AS infectionname
	FROM mst_infection ntss_db5_mst_infection
	WHERE ntss_db5_mst_infection.facility_cd=@facilityCd
)
SELECT
	'''' AS hosppatid --患者ID
	,ntss_db5_mst_mi.inhospitalcd1 AS infectioncd --感染症コード
	,ntss_db5_mst_mi.infectionname AS infectionname --感染症名
	,to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
	,ntss_db5_pm_json ->> ''infect'' AS infect --結果コード
	,ntss_db5_pm.pat_id AS patid
FROM
	pat_main ntss_db5_pm
	CROSS JOIN LATERAL json_array_elements(ntss_db5_pm.infect_info ::json) ntss_db5_pm_json
	LEFT JOIN ntss_db5_mst_mi
	ON CAST(ntss_db5_mst_mi.infectioncd as varchar(4)) = ntss_db5_pm_json ->> ''infection_cd''
WHERE 
	ntss_db5_pm.is_del = ''0''
	AND ntss_db5_pm.facility_cd = @facilityCd
	AND ntss_db5_pm.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
	AND to_date( @toDate , ''YYYYMMDDHH24MISS'' );', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2051, 'SELECT
	ntss_db6_ppm.hosp_pat_id AS hosppatid,
	ntss_db6_ppm.pat_id AS patid
FROM
	pat_personal_main ntss_db6_ppm
WHERE ntss_db6_ppm.is_del = ''0''
	AND ntss_db6_ppm.facility_cd = @facilityCd;', 3, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);

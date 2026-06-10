DELETE FROM sys_data_set a WHERE a.sql_cd in (-2060,-2061);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2060, 'with ntss_db5_mst_add as (
	SELECT
		ntss_db5_mst_addition.addition_cd AS additioncd
		,ntss_db5_mst_addition.addition_class AS additionclass
		,ntss_db5_mst_addition.up_date AS addupdate
		,ntss_db5_mst_addition.in_hospital_cd_1 AS inhospitalcd1
		,ntss_db5_mst_addition.in_hospital_cd_2 AS inhospitalcd2
	FROM mst_addition ntss_db5_mst_addition
	WHERE ntss_db5_mst_addition.facility_cd = @facilityCd
)
SELECT
	'''' AS hosppatid --患者ID
	,to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
	,CASE
		WHEN ntss_db5_mst_add.additionclass = ''2''
		THEN ''1''
		ELSE ''0''
	 END AS division --レセプトメモ区分
	,ntss_db5_pm_json ->> ''cd'' AS codes --コード
	,to_char(ntss_db5_mst_add.addupdate, ''YYYY-MM-DD hh24:mi:ss'') AS codeupdate --コード更新日時
	,CASE
		WHEN jsonb_array_length(ntss_db5_pm.addition_info) > 0
		THEN ''1''
		ELSE ''0''
	 END AS addflg --レセプトメモ区分
	 ,ntss_db5_pm_json ->> ''name'' AS itemname --項目名称
	 ,CASE
		WHEN ntss_db5_mst_add.additionclass = ''2''
		THEN ''1''
		ELSE ''0''
	 END AS maindialdiff --主たる透析困難
	 ,ntss_db5_mst_add.inhospitalcd1 AS inhospitalcd --院内コード
	 ,ntss_db5_mst_add.inhospitalcd2 AS inhospitalcd2 --院内コード２
	 ,ntss_db5_pm.pat_id AS patid
FROM
	pat_main ntss_db5_pm
	CROSS JOIN LATERAL json_array_elements(ntss_db5_pm.addition_info ::json) ntss_db5_pm_json
	LEFT JOIN ntss_db5_mst_add
	ON CAST(ntss_db5_mst_add.additioncd as varchar(4)) = ntss_db5_pm_json ->> ''cd''
WHERE 
	ntss_db5_pm.is_del = ''0''
	AND ntss_db5_pm.facility_cd = @facilityCd
	AND ntss_db5_pm.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
	AND to_date( @toDate , ''YYYYMMDDHH24MISS'' );', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
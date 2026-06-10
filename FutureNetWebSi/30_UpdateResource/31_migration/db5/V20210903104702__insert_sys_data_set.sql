DELETE FROM sys_data_set a WHERE a.sql_cd in (-2240,-2241);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2240, 'with ntss_db5_mm_1 as (
	SELECT
		ntss_db5_mm_1.facility_cd
		,ntss_db5_mm_1.ord_no AS ord_no
		,ntss_db5_mm_1.data_type AS data_type
		,ntss_db5_mm_1.monitor_data AS monitor_data
		,min(ntss_db5_mm_1.occur_date) AS occur_date
		,min(ntss_db5_mm_1.up_date) AS up_date
	FROM
		mni_monitor ntss_db5_mm_1
	WHERE
		ntss_db5_mm_1.ord_no IS NOT NULL
		AND ntss_db5_mm_1.data_type IN(''2'',''4'',''5'',''6'',''-1'')
		AND ntss_db5_mm_1.facility_cd = @facilityCd
	GROUP BY
		ntss_db5_mm_1.facility_cd,
		ntss_db5_mm_1.ord_no,
		ntss_db5_mm_1.data_type,
		ntss_db5_mm_1.monitor_data
)
SELECT
	'''' AS hosppatid --患者ID
	,ntss_db5_om.pat_id AS patid
	,to_char(ntss_db5_om.rst_start_date, ''YYYY-MM-DD hh24:mi:ss'') AS startdate --開始日時
	,to_char(ntss_db5_mm_1.occur_date, ''YYYY-MM-DD hh24:mi:ss'') AS occurdate --発生日時
	,CASE
        WHEN ntss_db5_mm_1.data_type IN (''2'',''4'',''5'',''6'') THEN ntss_db5_mm_1.monitor_data ->> ''90''
     END AS bpmax --最高血圧
    ,CASE
        WHEN ntss_db5_mm_1.data_type IN (''2'',''4'',''5'',''6'') THEN ntss_db5_mm_1.monitor_data ->> ''91''
     END AS bpmin --最低血圧
    ,CASE
        WHEN ntss_db5_mm_1.data_type IN (''2'',''4'',''5'',''6'') THEN ntss_db5_mm_1.monitor_data ->> ''92''
     END AS bpave --平均血圧
    ,CASE
        WHEN ntss_db5_mm_1.data_type IN (''2'',''4'',''5'',''6'') THEN ntss_db5_mm_1.monitor_data ->> ''93''
     END AS pulse --脈拍
    ,CASE
        WHEN ntss_db5_mm_1.data_type IN (''2'',''4'',''5'',''6'') THEN ntss_db5_mm_1.monitor_data ->> ''93''
     END AS temperature --体温
    ,CASE
        WHEN ntss_db5_mm_1.data_type IN (''2'',''4'',''5'',''6'') THEN ntss_db5_mm_1.monitor_data ->> ''-1''
     END AS bloodsugarlevel --血糖値
    ,to_char(ntss_db5_mm_1.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update --更新日時
    ,ntss_db5_mm_1.ord_no AS diadysisno --透析番号
    ,ntss_db5_mm_1.data_type AS bpclass --血圧区分
FROM
	ord_main ntss_db5_om
	INNER JOIN ntss_db5_mm_1
	ON ntss_db5_mm_1.ord_no = ntss_db5_om.ord_no
WHERE ntss_db5_om.is_del = ''0''
	AND ntss_db5_om.facility_cd = @facilityCd
	AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
    AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
	AND ntss_db5_om.pat_id IS NOT NULL;', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);

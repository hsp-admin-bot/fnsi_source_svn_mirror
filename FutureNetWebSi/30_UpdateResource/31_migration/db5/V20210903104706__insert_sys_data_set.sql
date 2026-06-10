DELETE FROM sys_data_set a WHERE a.sql_cd in (-2210,-2211);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2210, 'WITH ntss_db5_om_1 AS (
	SELECT
		ntss_db5_om_1.ord_no AS ord_no
		,ntss_db5_om_1.pat_id
		,ntss_db5_om_1.treat_date AS treat_date
		,COUNT( ntss_db5_om_1.treat_date ) AS treat_date_count
	FROM
		ord_main ntss_db5_om_1
	WHERE 1=1
		AND ntss_db5_om_1.facility_cd = @facilityCd
		AND ntss_db5_om_1.treat_date IS NOT NULL 
	GROUP BY
		ntss_db5_om_1.ord_no,
		ntss_db5_om_1.pat_id,
		ntss_db5_om_1.treat_date
),
ntss_db5_mst_m AS (
	SELECT
		ntss_db5_om.ord_no AS ord_no
		,ntss_db5_mst_m.in_hospital_cd_1 AS in_hospital_cd_1
		,ntss_db5_mst_m.in_hospital_cd_2 AS in_hospital_cd_2
	FROM ord_main ntss_db5_om
		CROSS JOIN LATERAL json_array_elements(ntss_db5_om.ind_medi_info ::json) ntss_db5_om_imi_json
		LEFT JOIN mst_medicine ntss_db5_mst_m
		ON cast(ntss_db5_mst_m.medicine_cd as char(10)) = cast(ntss_db5_om_imi_json ->> ''cd'' as char(10))
	WHERE ntss_db5_om.facility_cd = @facilityCd
),
ntss_db5_mst_p AS (
	SELECT
		ntss_db5_om.ord_no AS ord_no
		,ntss_db5_mst_p.in_hospital_cd_a1 AS in_hospital_cd_1
		,ntss_db5_mst_p.in_hospital_cd_a2 AS in_hospital_cd_2
	FROM ord_main ntss_db5_om
		CROSS JOIN LATERAL json_array_elements(ntss_db5_om.rst_medi_info ::json) ntss_db5_om_rmi_json
		LEFT JOIN mst_procedure ntss_db5_mst_p
		ON cast(ntss_db5_mst_p.procedure_cd as char(10)) = cast(ntss_db5_om_rmi_json ->> ''procedure_cd'' as char(10))
	WHERE ntss_db5_om.facility_cd = @facilityCd
)
SELECT
	'''' AS hosppatid --患者ID
	,ntss_db5_om.pat_id AS patid
	,ntss_db5_om.treat_date AS dialysisdate --透析日
	,CASE
		WHEN ntss_db5_om_1.treat_date_count > 1
		THEN 1
		ELSE 0
	 END AS plural --同日複数回
	,row_number() over(ORDER BY ntss_db5_om.treat_date DESC) AS ctlno --項目番号
	,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
	,ntss_db5_mst_m.in_hospital_cd_1 AS medicinecd --薬剤コード(院内コード1)
	,ntss_db5_mst_m.in_hospital_cd_2 AS medicinecd2 --薬剤コード(院内コード2)
	,ntss_db5_om_imi_json ->> ''name'' AS medicinename --薬剤名
	,ntss_db5_om_imi_json ->> ''class_name'' AS mediclassname --薬剤分類名
	,ntss_db5_om_imi_json ->> ''amount'' AS amount --数量
	,ntss_db5_om_imi_json ->> ''unit'' AS unit --単位
	,ntss_db5_om_imi_json ->> ''timing_name'' AS timingname --投与時間帯名
	,ntss_db5_mst_p.in_hospital_cd_1 AS procedurecd --手技コード(院内コード1)
	,ntss_db5_mst_p.in_hospital_cd_2 AS procedurecd2 --手技コード(院内コード2)
	,ntss_db5_om_imi_json ->> ''procedure_name'' AS procedurename --手技名
	,ntss_db5_om_imi_json ->> ''comment'' AS comments --コメント
	,'''' AS indicatorcd --指示者
	,ntss_db5_om_iic_json ->> ''ind_user_id''	 AS userid
	,CASE
		WHEN ntss_db5_om.treat_type = 0
		THEN ''1''
		ELSE ''0''
	 END AS opeindplan --予定作成区分
FROM
	ord_main ntss_db5_om
	INNER JOIN ntss_db5_om_1
	ON ntss_db5_om_1.ord_no = ntss_db5_om.ord_no
	INNER JOIN ntss_db5_mst_m
	ON ntss_db5_mst_m.ord_no = ntss_db5_om.ord_no
	INNER JOIN ntss_db5_mst_p
	ON ntss_db5_mst_p.ord_no = ntss_db5_om.ord_no
	CROSS JOIN LATERAL json_array_elements(ntss_db5_om.ind_ind_comment_info ::json) ntss_db5_om_iic_json
	CROSS JOIN LATERAL json_array_elements(ntss_db5_om.ind_medi_info ::json) ntss_db5_om_imi_json
WHERE ntss_db5_om.is_del = ''0''
	AND ntss_db5_om.facility_cd = @facilityCd
	AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
	AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
	AND ntss_db5_om.pat_id IS NOT NULL;', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid,userid"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);

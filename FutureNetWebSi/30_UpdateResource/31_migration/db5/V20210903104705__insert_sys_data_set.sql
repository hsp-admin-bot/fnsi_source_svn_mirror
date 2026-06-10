DELETE FROM sys_data_set a WHERE a.sql_cd in (-2200,-2201);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2200, 'WITH ntss_db5_om_1 AS (
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
ntss_db5_mst_e AS (
	SELECT
		ntss_db5_mst_e.*
	FROM
		mst_equipment ntss_db5_mst_e
	WHERE 
		ntss_db5_mst_e.is_del = ''0''
		AND ntss_db5_mst_e.is_disp = ''1''
		AND ntss_db5_mst_e.facility_cd = @facilityCd
),
ntss_db5_mst_list AS (
	SELECT
		ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1
		,''0'' AS puncture_class
		,ntss_db5_mst_e.in_hospital_cd_1 || cast(ntss_db5_om_rei_json ->> ''class_name'' as char(20)) AS class_name
		,ntss_db5_mst_e.equipment_name || cast(ntss_db5_om_rei_json ->> ''name'' as char(20)) AS names
		,ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
		,om.ord_no AS ord_no
		,ntss_db5_om_rei_json ->> ''amount'' AS amount
		,ntss_db5_om_iei_json ->> ''unit'' AS unit
		,ntss_db5_om_iei_json ->> ''comment'' AS comments
	FROM
		ord_main om
		LEFT JOIN ntss_db5_mst_e
		ON TO_NUMBER( om.ind_cond_info::json #>> ''{6,value}'', ''99999999'' ) = ntss_db5_mst_e.equipment_cd
		CROSS JOIN LATERAL json_array_elements(om.rst_equip_info ::json) ntss_db5_om_rei_json
		CROSS JOIN LATERAL json_array_elements(om.ind_equip_info ::json) ntss_db5_om_iei_json
	WHERE ntss_db5_mst_e.facility_cd = @facilityCd
		AND om.ind_cond_info::json #>> ''{6,value}'' IS NOT NULL
		AND om.is_del = ''0''
	UNION ALL
	SELECT
		ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1
		,''0'' AS puncture_class
		,ntss_db5_mst_e.in_hospital_cd_1 || cast(ntss_db5_om_rei_json ->> ''class_name'' as char(20)) AS class_name
		,ntss_db5_mst_e.equipment_name || cast(ntss_db5_om_rei_json ->> ''name'' as char(20)) AS names
		,ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
		,om.ord_no AS ord_no
		,ntss_db5_om_rei_json ->> ''amount'' AS amount
		,ntss_db5_om_iei_json ->> ''unit'' AS unit
		,ntss_db5_om_iei_json ->> ''comment'' AS comments
	FROM
		ord_main om
		LEFT JOIN ntss_db5_mst_e
		ON TO_NUMBER( om.ind_cond_info::json #>> ''{7,value}'', ''99999999'' ) = ntss_db5_mst_e.equipment_cd
		CROSS JOIN LATERAL json_array_elements(om.rst_equip_info ::json) ntss_db5_om_rei_json
		CROSS JOIN LATERAL json_array_elements(om.ind_equip_info ::json) ntss_db5_om_iei_json
	WHERE ntss_db5_mst_e.facility_cd = @facilityCd
		AND om.ind_cond_info::json #>> ''{7,value}'' IS NOT NULL
		AND om.is_del = ''0''
	UNION ALL
	SELECT
		ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1
		,''0'' AS puncture_class
		,ntss_db5_mst_e.in_hospital_cd_1 || cast(ntss_db5_om_rei_json ->> ''class_name'' as char(20)) AS class_name
		,ntss_db5_mst_e.equipment_name || cast(ntss_db5_om_rei_json ->> ''name'' as char(20)) AS names
		,ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
		,om.ord_no AS ord_no
		,ntss_db5_om_rei_json ->> ''amount'' AS amount
		,ntss_db5_om_iei_json ->> ''unit'' AS unit
		,ntss_db5_om_iei_json ->> ''comment'' AS comments
	FROM
		ord_main om
		LEFT JOIN ntss_db5_mst_e
		ON TO_NUMBER( om.ind_cond_info::json #>> ''{8,value}'', ''99999999'' ) = ntss_db5_mst_e.equipment_cd
		CROSS JOIN LATERAL json_array_elements(om.rst_equip_info ::json) ntss_db5_om_rei_json
		CROSS JOIN LATERAL json_array_elements(om.ind_equip_info ::json) ntss_db5_om_iei_json
	WHERE ntss_db5_mst_e.facility_cd = @facilityCd
		AND om.ind_cond_info::json #>> ''{8,value}'' IS NOT NULL
		AND om.is_del = ''0''
	UNION ALL
	SELECT
		ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1
		,''1'' AS puncture_class
		,ntss_db5_mst_e.in_hospital_cd_1 || cast(ntss_db5_om_rei_json ->> ''class_name'' as char(20)) AS class_name
		,ntss_db5_mst_e.equipment_name || cast(ntss_db5_om_rei_json ->> ''name'' as char(20)) AS names
		,ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
		,om.ord_no AS ord_no
		,ntss_db5_om_rei_json ->> ''amount'' AS amount
		,ntss_db5_om_iei_json ->> ''unit'' AS unit
		,ntss_db5_om_iei_json ->> ''comment'' AS comments
	FROM
		ord_main om
		LEFT JOIN ntss_db5_mst_e
		ON TO_NUMBER( om.ind_cond_info::json #>> ''{9,value}'', ''99999999'' ) = ntss_db5_mst_e.equipment_cd
		CROSS JOIN LATERAL json_array_elements(om.rst_equip_info ::json) ntss_db5_om_rei_json
		CROSS JOIN LATERAL json_array_elements(om.ind_equip_info ::json) ntss_db5_om_iei_json
	WHERE ntss_db5_mst_e.facility_cd = @facilityCd
		AND om.ind_cond_info::json #>> ''{9,value}'' IS NOT NULL
		AND om.is_del = ''0''
	UNION ALL
	SELECT
		ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1
		,''2'' AS puncture_class
		,ntss_db5_mst_e.in_hospital_cd_1 || cast(ntss_db5_om_rei_json ->> ''class_name'' as char(20)) AS class_name
		,ntss_db5_mst_e.equipment_name || cast(ntss_db5_om_rei_json ->> ''name'' as char(20)) AS names
		,ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
		,om.ord_no AS ord_no
		,ntss_db5_om_rei_json ->> ''amount'' AS amount
		,ntss_db5_om_iei_json ->> ''unit'' AS unit
		,ntss_db5_om_iei_json ->> ''comment'' AS comments
	FROM
		ord_main om
		LEFT JOIN ntss_db5_mst_e
		ON TO_NUMBER( om.ind_cond_info::json #>> ''{10,value}'', ''99999999'' ) = ntss_db5_mst_e.equipment_cd
		CROSS JOIN LATERAL json_array_elements(om.rst_equip_info ::json) ntss_db5_om_rei_json
		CROSS JOIN LATERAL json_array_elements(om.ind_equip_info ::json) ntss_db5_om_iei_json
	WHERE ntss_db5_mst_e.facility_cd = @facilityCd
		AND om.ind_cond_info::json #>> ''{10,value}'' IS NOT NULL
		AND om.is_del = ''0''
	UNION ALL
	SELECT
		ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1
		,''3'' AS puncture_class
		,ntss_db5_mst_e.in_hospital_cd_1 || cast(ntss_db5_om_rei_json ->> ''class_name'' as char(20)) AS class_name
		,ntss_db5_mst_e.equipment_name || cast(ntss_db5_om_rei_json ->> ''name'' as char(20)) AS names
		,ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
		,om.ord_no AS ord_no
		,ntss_db5_om_rei_json ->> ''amount'' AS amount
		,ntss_db5_om_iei_json ->> ''unit'' AS unit
		,ntss_db5_om_iei_json ->> ''comment'' AS comments
	FROM
		ord_main om
		LEFT JOIN ntss_db5_mst_e
		ON TO_NUMBER( om.ind_cond_info::json #>> ''{11,value}'', ''99999999'' ) = ntss_db5_mst_e.equipment_cd
		CROSS JOIN LATERAL json_array_elements(om.rst_equip_info ::json) ntss_db5_om_rei_json
		CROSS JOIN LATERAL json_array_elements(om.ind_equip_info ::json) ntss_db5_om_iei_json
	WHERE ntss_db5_mst_e.facility_cd = @facilityCd
		AND om.ind_cond_info::json #>> ''{11,value}'' IS NOT NULL
		AND om.is_del = ''0''
	UNION ALL
	SELECT
		ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1
		,''0'' AS puncture_class
		,ntss_db5_mst_e.in_hospital_cd_1 || cast(ntss_db5_om_rei_json ->> ''class_name'' as char(20)) AS class_name
		,ntss_db5_mst_e.equipment_name || cast(ntss_db5_om_rei_json ->> ''name'' as char(20)) AS names
		,ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
		,om.ord_no AS ord_no
		,ntss_db5_om_rei_json ->> ''amount'' AS amount
		,ntss_db5_om_iei_json ->> ''unit'' AS unit
		,ntss_db5_om_iei_json ->> ''comment'' AS comments
	FROM
		ord_main om
		LEFT JOIN ntss_db5_mst_e
		ON TO_NUMBER( om.ind_cond_info::json #>> ''{12,value}'', ''99999999'' ) = ntss_db5_mst_e.equipment_cd
		CROSS JOIN LATERAL json_array_elements(om.rst_equip_info ::json) ntss_db5_om_rei_json
		CROSS JOIN LATERAL json_array_elements(om.ind_equip_info ::json) ntss_db5_om_iei_json
	WHERE ntss_db5_mst_e.facility_cd = @facilityCd
		AND om.ind_cond_info::json #>> ''{12,value}'' IS NOT NULL
		AND om.is_del = ''0''
	UNION ALL
	SELECT
		ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1
		,''0'' AS puncture_class
		,ntss_db5_mst_e.in_hospital_cd_1 || cast(ntss_db5_om_rei_json ->> ''class_name'' as char(20)) AS class_name
		,ntss_db5_mst_e.equipment_name || cast(ntss_db5_om_rei_json ->> ''name'' as char(20)) AS names
		,ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
		,om.ord_no AS ord_no
		,ntss_db5_om_rei_json ->> ''amount'' AS amount
		,ntss_db5_om_iei_json ->> ''unit'' AS unit
		,ntss_db5_om_iei_json ->> ''comment'' AS comments
	FROM
		ord_main om
		LEFT JOIN ntss_db5_mst_e
		ON TO_NUMBER( om.ind_cond_info::json #>> ''{13,value}'', ''99999999'' ) = ntss_db5_mst_e.equipment_cd
		CROSS JOIN LATERAL json_array_elements(om.rst_equip_info ::json) ntss_db5_om_rei_json
		CROSS JOIN LATERAL json_array_elements(om.ind_equip_info ::json) ntss_db5_om_iei_json
	WHERE ntss_db5_mst_e.facility_cd = @facilityCd
		AND om.ind_cond_info::json #>> ''{13,value}'' IS NOT NULL
		AND om.is_del = ''0''
	UNION ALL
	SELECT
		ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1
		,'''' AS puncture_class
		,'''' AS class_name
		,'''' AS names
		,ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
		,om.ord_no AS ord_no
		,'''' AS amount
		,'''' AS unit
		,'''' AS comments
	FROM
		ord_main om
		CROSS JOIN LATERAL json_array_elements(om.rst_equip_info ::json) ntss_db5_om_rei_json
		LEFT JOIN ntss_db5_mst_e
		ON ntss_db5_om_rei_json ->> ''cd'' = cast(ntss_db5_mst_e.equipment_cd as char(4))
	WHERE ntss_db5_mst_e.facility_cd = @facilityCd
		AND om.is_del = ''0''
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
	,ntss_db5_mst_list.in_hospital_cd_1 AS equipcd --医療材料コード(院内コード1)
	,ntss_db5_mst_list.in_hospital_cd_2 AS equipcd2 --医療材料コード(院内コード2)
	,ntss_db5_mst_list.class_name AS equipclassname --医療材料分類名
	,ntss_db5_mst_list.names AS equipname --医療材料名
	,ntss_db5_mst_list.puncture_class AS punctureclass --医療材料名
	,ntss_db5_mst_list.amount AS amount --数量
	,ntss_db5_mst_list.unit AS unit --数量
	,ntss_db5_mst_list.comments AS comments --コメント
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
	INNER JOIN ntss_db5_mst_list
	ON ntss_db5_mst_list.ord_no = ntss_db5_om.ord_no
	CROSS JOIN LATERAL json_array_elements(ntss_db5_om.ind_ind_comment_info ::json) ntss_db5_om_iic_json
WHERE ntss_db5_om.is_del = ''0''
	AND ntss_db5_om.facility_cd = @facilityCd
	AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
	AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
	AND ntss_db5_om.pat_id IS NOT NULL;', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid,userid"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);

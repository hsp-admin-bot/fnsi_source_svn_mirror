DELETE FROM sys_data_set a WHERE a.sql_cd in (-2190,-2191);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2190, 'with ntss_db5_mst_v as (
	SELECT
		ntss_db5_mst_v.*
	FROM
		mst_va ntss_db5_mst_v
	WHERE 
		ntss_db5_mst_v.is_del = ''0''
		AND ntss_db5_mst_v.is_disp = ''1''
		AND ntss_db5_mst_v.facility_cd = @facilityCd
),
ntss_db5_mst_d as (
	SELECT
		ntss_db5_mst_d.*
	FROM
		mst_dialyzer ntss_db5_mst_d
	WHERE 
		ntss_db5_mst_d.is_del = ''0''
		AND ntss_db5_mst_d.is_disp = ''1''
		AND ntss_db5_mst_d.facility_cd = @facilityCd
),
ntss_db5_mst_e as (
	SELECT
		ntss_db5_mst_e.*
	FROM
		mst_equipment ntss_db5_mst_e
	WHERE 
		ntss_db5_mst_e.is_del = ''0''
		AND ntss_db5_mst_e.is_disp = ''1''
		AND ntss_db5_mst_e.facility_cd = @facilityCd
),
ntss_db5_mst_m as (
	SELECT
		ntss_db5_mst_m.*
	FROM
		mst_medicine ntss_db5_mst_m
	WHERE 
		ntss_db5_mst_m.is_del = ''0''
		AND ntss_db5_mst_m.is_disp = ''1''
		AND ntss_db5_mst_m.facility_cd = @facilityCd
),
ntss_db5_mst_t as (
	SELECT
		ntss_db5_mst_t.*
	FROM
		mst_treatment ntss_db5_mst_t
	WHERE 
		ntss_db5_mst_t.is_del = ''0''
		AND ntss_db5_mst_t.is_disp = ''1''
		AND ntss_db5_mst_t.facility_cd = @facilityCd
),
ntss_db5_mst_list as (
	--VA
	SELECT
		''003'' AS fnw_code
		,''VA'' AS fnw_name
		,om.ind_cond_info::json #>> ''{2,value}'' AS value
		,om.ind_cond_info::json #>> ''{2,value_name_1}'' AS value_name_1
		,om.ind_cond_info::json #>> ''{2,unit}'' AS unit
		,om.ord_no AS ord_no
		,ntss_db5_mst_v.in_hospital_cd_2 AS in_hospital_cd_2
	FROM
		ord_main om
	LEFT JOIN ntss_db5_mst_v
		ON TO_NUMBER( om.ind_cond_info::json #>> ''{2,value}'', ''99999999'' ) = ntss_db5_mst_v.va_cd
	WHERE ntss_db5_mst_v.facility_cd = @facilityCd
		AND om.ind_cond_info::json #>> ''{2,value}'' IS NOT NULL
		AND om.is_del = ''0''
	UNION ALL
	--ダイアライザ
	SELECT
		''008'' AS fnw_code
		,''ダイアライザ'' AS fnw_name
		,om.ind_cond_info::json #>> ''{5,value}'' AS value
		,om.ind_cond_info::json #>> ''{5,value_name_1}'' AS value_name_1
		,om.ind_cond_info::json #>> ''{5,unit}'' AS unit
		,om.ord_no AS ord_no
		,ntss_db5_mst_d.in_hospital_cd_2 AS in_hospital_cd_2
	FROM
		ord_main om
	LEFT JOIN ntss_db5_mst_d
		ON TO_NUMBER( om.ind_cond_info::json #>> ''{5,value}'', ''99999999'' ) = ntss_db5_mst_d.dialyzer_cd
	WHERE ntss_db5_mst_d.facility_cd = @facilityCd
		AND om.ind_cond_info::json #>> ''{5,value}'' IS NOT NULL
		AND om.is_del = ''0''
	UNION ALL
	--吸着カラム
	SELECT
		''009'' AS fnw_code
		,''吸着カラム'' AS fnw_name
		,om.ind_cond_info::json #>> ''{6,value}'' AS value
		,om.ind_cond_info::json #>> ''{6,value_name_1}'' AS value_name_1
		,om.ind_cond_info::json #>> ''{6,unit}'' AS unit
		,om.ord_no AS ord_no
		,ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
	FROM
		ord_main om
	LEFT JOIN ntss_db5_mst_e
		ON TO_NUMBER( om.ind_cond_info::json #>> ''{6,value}'', ''99999999'' ) = ntss_db5_mst_e.equipment_cd
	WHERE ntss_db5_mst_e.facility_cd = @facilityCd
		AND om.ind_cond_info::json #>> ''{6,value}'' IS NOT NULL
		AND om.is_del = ''0''
	UNION ALL
	--1次膜
	SELECT
		''039'' AS fnw_code
		,''1次膜'' AS fnw_name
		,om.ind_cond_info::json #>> ''{7,value}'' AS value
		,om.ind_cond_info::json #>> ''{7,value_name_1}'' AS value_name_1
		,om.ind_cond_info::json #>> ''{7,unit}'' AS unit
		,om.ord_no AS ord_no
		,ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
	FROM
		ord_main om
	LEFT JOIN ntss_db5_mst_e
		ON TO_NUMBER( om.ind_cond_info::json #>> ''{7,value}'', ''99999999'' ) = ntss_db5_mst_e.equipment_cd
	WHERE ntss_db5_mst_e.facility_cd = @facilityCd
		AND om.ind_cond_info::json #>> ''{7,value}'' IS NOT NULL
		AND om.is_del = ''0''
	UNION ALL
	--2次膜
	SELECT
		''040'' AS fnw_code
		,''2次膜'' AS fnw_name
		,om.ind_cond_info::json #>> ''{8,value}'' AS value
		,om.ind_cond_info::json #>> ''{8,value_name_1}'' AS value_name_1
		,om.ind_cond_info::json #>> ''{8,unit}'' AS unit
		,om.ord_no AS ord_no
		,ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
	FROM
		ord_main om
	LEFT JOIN ntss_db5_mst_e
		ON TO_NUMBER( om.ind_cond_info::json #>> ''{8,value}'', ''99999999'' ) = ntss_db5_mst_e.equipment_cd
	WHERE ntss_db5_mst_e.facility_cd = @facilityCd
		AND om.ind_cond_info::json #>> ''{8,value}'' IS NOT NULL
		AND om.is_del = ''0''
	UNION ALL
	--穿刺針(A針)
	SELECT
		'''' AS fnw_code
		,''穿刺針(A針)'' AS fnw_name
		,om.ind_cond_info::json #>> ''{9,value}'' AS value
		,om.ind_cond_info::json #>> ''{9,value_name_1}'' AS value_name_1
		,om.ind_cond_info::json #>> ''{9,unit}'' AS unit
		,om.ord_no AS ord_no
		,ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
	FROM
		ord_main om
	LEFT JOIN ntss_db5_mst_e
		ON TO_NUMBER( om.ind_cond_info::json #>> ''{9,value}'', ''99999999'' ) = ntss_db5_mst_e.equipment_cd
	WHERE ntss_db5_mst_e.facility_cd = @facilityCd
		AND om.ind_cond_info::json #>> ''{9,value}'' IS NOT NULL
		AND om.is_del = ''0''
	UNION ALL
	--穿刺針(V針)
	SELECT
		'''' AS fnw_code
		,''穿刺針(V針)'' AS fnw_name
		,om.ind_cond_info::json #>> ''{10,value}'' AS value
		,om.ind_cond_info::json #>> ''{10,value_name_1}'' AS value_name_1
		,om.ind_cond_info::json #>> ''{10,unit}'' AS unit
		,om.ord_no AS ord_no
		,ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
	FROM
		ord_main om
	LEFT JOIN ntss_db5_mst_e
		ON TO_NUMBER( om.ind_cond_info::json #>> ''{10,value}'', ''99999999'' ) = ntss_db5_mst_e.equipment_cd
	WHERE ntss_db5_mst_e.facility_cd = @facilityCd
		AND om.ind_cond_info::json #>> ''{10,value}'' IS NOT NULL
		AND om.is_del = ''0''
	UNION ALL
	--穿刺針(SN)
	SELECT
		'''' AS fnw_code
		,''穿刺針(SN)'' AS fnw_name
		,om.ind_cond_info::json #>> ''{11,value}'' AS value
		,om.ind_cond_info::json #>> ''{11,value_name_1}'' AS value_name_1
		,om.ind_cond_info::json #>> ''{11,unit}'' AS unit
		,om.ord_no AS ord_no
		,ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
	FROM
		ord_main om
	LEFT JOIN ntss_db5_mst_e
		ON TO_NUMBER( om.ind_cond_info::json #>> ''{11,value}'', ''99999999'' ) = ntss_db5_mst_e.equipment_cd
	WHERE ntss_db5_mst_e.facility_cd = @facilityCd
		AND om.ind_cond_info::json #>> ''{11,value}'' IS NOT NULL
		AND om.is_del = ''0''
	UNION ALL
	--血液回路
	SELECT
		'''' AS fnw_code
		,''血液回路'' AS fnw_name
		,om.ind_cond_info::json #>> ''{13,value}'' AS value
		,om.ind_cond_info::json #>> ''{13,value_name_1}'' AS value_name_1
		,om.ind_cond_info::json #>> ''{13,unit}'' AS unit
		,om.ord_no AS ord_no
		,ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
	FROM
		ord_main om
	LEFT JOIN ntss_db5_mst_e
		ON TO_NUMBER( om.ind_cond_info::json #>> ''{13,value}'', ''99999999'' ) = ntss_db5_mst_e.equipment_cd
	WHERE ntss_db5_mst_e.facility_cd = @facilityCd
		AND om.ind_cond_info::json #>> ''{13,value}'' IS NOT NULL
		AND om.is_del = ''0''
	UNION ALL
	--透析液
	SELECT
		''018'' AS fnw_code
		,''透析液'' AS fnw_name
		,om.ind_cond_info::json #>> ''{15,value}'' AS value
		,om.ind_cond_info::json #>> ''{15,value_name_1}'' AS value_name_1
		,om.ind_cond_info::json #>> ''{15,unit}'' AS unit
		,om.ord_no AS ord_no
		,ntss_db5_mst_m.in_hospital_cd_2 AS in_hospital_cd_2
	FROM
		ord_main om
	LEFT JOIN ntss_db5_mst_m
		ON TO_NUMBER( om.ind_cond_info::json #>> ''{15,value}'', ''99999999'' ) = ntss_db5_mst_m.medicine_cd
	WHERE ntss_db5_mst_m.facility_cd = @facilityCd
		AND om.ind_cond_info::json #>> ''{15,value}'' IS NOT NULL
		AND om.is_del = ''0''
	UNION ALL
	--補液
	SELECT
		''022'' AS fnw_code
		,''補液'' AS fnw_name
		,om.ind_cond_info::json #>> ''{19,value}'' AS value
		,om.ind_cond_info::json #>> ''{19,value_name_1}'' AS value_name_1
		,om.ind_cond_info::json #>> ''{19,unit}'' AS unit
		,om.ord_no AS ord_no
		,ntss_db5_mst_m.in_hospital_cd_2 AS in_hospital_cd_2
	FROM
		ord_main om
	LEFT JOIN ntss_db5_mst_m
		ON TO_NUMBER( om.ind_cond_info::json #>> ''{19,value}'', ''99999999'' ) = ntss_db5_mst_m.medicine_cd
	WHERE ntss_db5_mst_m.facility_cd = @facilityCd
		AND om.ind_cond_info::json #>> ''{19,value}'' IS NOT NULL
		AND om.is_del = ''0''
	UNION ALL
	--抗凝固剤ワンショット量
	SELECT
		''012'' AS fnw_code
		,''抗凝固剤ワンショット量'' AS fnw_name
		,om.ind_cond_info::json #>> ''{26,value}'' AS value
		,om.ind_cond_info::json #>> ''{26,value_name_1}'' AS value_name_1
		,om.ind_cond_info::json #>> ''{26,unit}'' AS unit
		,om.ord_no AS ord_no
		,ntss_db5_mst_m.in_hospital_cd_2 AS in_hospital_cd_2
	FROM
		ord_main om
	LEFT JOIN ntss_db5_mst_m
		ON TO_NUMBER( om.ind_cond_info::json #>> ''{26,value}'', ''99999999'' ) = ntss_db5_mst_m.medicine_cd
	WHERE ntss_db5_mst_m.facility_cd = @facilityCd
		AND om.ind_cond_info::json #>> ''{26,value}'' IS NOT NULL
		AND om.is_del = ''0''
),
ntss_db5_om_1 as (
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
	,ntss_db5_mst_list.fnw_code AS ctlno --透析条件項目コード
	,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
	,ntss_db5_mst_list.fnw_name AS dialysisitemname --透析条件項目名
	,ntss_db5_mst_list.value AS value --設定値
	,ntss_db5_mst_list.value_name_1 AS valuename --名称
	,ntss_db5_mst_list.unit AS unit --単位
	,ntss_db5_mst_list.in_hospital_cd_2 AS valuecd2 --院内コード2
	,'''' AS indicatorcd --指示者
	,ntss_db5_om_iic_json ->> ''ind_user_id''	 AS userid
	,CASE
		WHEN ntss_db5_om.treat_type = 0
		THEN ''1''
		ELSE ''0''
	 END AS opeindplan --予定作成区分
FROM
	ord_main ntss_db5_om
	INNER JOIN ntss_db5_mst_list
	ON ntss_db5_mst_list.ord_no = ntss_db5_om.ord_no
	INNER JOIN ntss_db5_om_1
	ON ntss_db5_om_1.ord_no = ntss_db5_om.ord_no
	CROSS JOIN LATERAL json_array_elements(ntss_db5_om.ind_ind_comment_info ::json) ntss_db5_om_iic_json
WHERE ntss_db5_om.is_del = ''0''
	AND ntss_db5_om.facility_cd = @facilityCd
	AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
    AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
	AND ntss_db5_om.pat_id IS NOT NULL;', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid,userid"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);

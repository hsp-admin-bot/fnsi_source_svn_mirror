DELETE FROM sys_data_set a WHERE a.sql_cd in (-2250,-2251);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2250, 'WITH ntss_db5_mst_mm AS (
	SELECT
		ntss_db5_medicine_mix.medicine_mix_cd AS medicinemixcd
		,ntss_db5_medicine_mix.in_hospital_cd_1 AS inhospitalcd1
		,ntss_db5_medicine_mix.in_hospital_cd_2 AS inhospitalcd2
	FROM mst_medicine_mix ntss_db5_medicine_mix
	WHERE ntss_db5_medicine_mix.facility_cd = @facilityCd
),
ntss_db5_mst_m AS (
	SELECT
		ntss_db5_medicine.medicine_cd AS medicinecd
		,ntss_db5_medicine.in_hospital_cd_1 AS inhospitalcd1
		,ntss_db5_medicine.in_hospital_cd_2 AS inhospitalcd2
	FROM mst_medicine ntss_db5_medicine
	WHERE ntss_db5_medicine.facility_cd = @facilityCd
),
ntss_db5_mst_p AS (
	SELECT
		ntss_db5_procedure.procedure_cd AS procedurecd
		,ntss_db5_procedure.in_hospital_cd_a1 AS inhospitalcda1
		,ntss_db5_procedure.in_hospital_cd_a2 AS inhospitalcda2
	FROM mst_procedure ntss_db5_procedure
	WHERE ntss_db5_procedure.facility_cd = @facilityCd
)
SELECT
	'''' AS hosppatid --患者ID
	,ntss_db5_om.pat_id AS patid
	,COALESCE(to_char(to_timestamp(ntss_db5_om_rci_json ->> ''occur_date'', ''YYYY-MM-DD hh24:mi:ss''), ''YYYY-MM-DD hh24:mi:ss''),
			to_char(to_timestamp(ntss_db5_om_rti_json ->> ''occur_date'', ''YYYY-MM-DD hh24:mi:ss''), ''YYYY-MM-DD hh24:mi:ss'')) AS occurdate --発生日時
	,CASE
		WHEN ntss_db5_om_rti_json ->> ''medicine_type'' = ''2'' THEN ''0''
		WHEN ntss_db5_om_rti_json ->> ''medicine_type'' = ''1'' THEN ''1''
		WHEN ntss_db5_om_rti_json ->> ''medicine_type'' IS NULL THEN ''2''
		WHEN ntss_db5_om_rti_json ->> ''medicine_type'' = ''3'' THEN ''3''
	 END AS measureclass --区分
	,ntss_db5_om_rci_json ->> ''comp_cd'' AS reqcode --愁訴コード
	,ntss_db5_om_rci_json ->> ''complaint'' AS complaint --愁訴内容
	,ntss_db5_om_rti_json ->> ''treat_name'' AS treatname --処置名
	,CASE
		WHEN ntss_db5_om_rci_json ->> ''medicine_type'' = ''2'' THEN ntss_db5_mst_mm.inhospitalcd1
		WHEN ntss_db5_om_rti_json ->> ''medicine_type'' = ''1'' THEN ntss_db5_mst_m.inhospitalcd1
	 END AS medicinecd1 --薬剤コード1
	 ,CASE
		WHEN ntss_db5_om_rci_json ->> ''medicine_type'' = ''2'' THEN ntss_db5_mst_mm.inhospitalcd2
		WHEN ntss_db5_om_rti_json ->> ''medicine_type'' = ''1'' THEN ntss_db5_mst_m.inhospitalcd2
	 END AS medicinecd2 --薬剤コード2
	 ,ntss_db5_om_rti_json ->> ''medicine_name'' AS medicinename --薬剤名称
	 ,ntss_db5_om_rti_json ->> ''amount'' AS amount --数量
	 ,ntss_db5_om_rti_json ->> ''unit'' AS unit --単位
	 ,ntss_db5_om_rti_json ->> ''procedure_name'' AS procedurename --手技名
	 ,ntss_db5_mst_p.inhospitalcda1 AS procedurecd1 --手技コード1
	 ,ntss_db5_mst_p.inhospitalcda2 AS procedurecd2 --手技コード2
	 ,ntss_db5_om_tsi_json ->> ''treat_staff_name'' treatpersonname --処置者名
	 ,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
FROM
	ord_main ntss_db5_om
	cross join lateral json_array_elements(ntss_db5_om.rst_complaint_info ::json) ntss_db5_om_rci_json
	cross join lateral json_array_elements(ntss_db5_om.rst_treatment_info ::json) ntss_db5_om_rti_json
	LEFT JOIN ntss_db5_mst_mm
	ON cast(ntss_db5_mst_mm.medicinemixcd AS char(4)) = ntss_db5_om_rti_json ->> ''treat_medicine_cd''
	LEFT JOIN ntss_db5_mst_m
	ON cast(ntss_db5_mst_m.medicinecd AS char(4)) = ntss_db5_om_rti_json ->> ''treat_medicine_cd''
	LEFT JOIN ntss_db5_mst_p
	ON cast(ntss_db5_mst_p.procedurecd AS char(4)) = ntss_db5_om_rti_json ->> ''procedure_cd''
	cross join lateral json_array_elements(ntss_db5_om.rst_treat_staff_info ::json) ntss_db5_om_tsi_json
WHERE ntss_db5_om.is_del = ''0''
    AND ntss_db5_om.facility_cd = @facilityCd 
    AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' ) 
    AND to_date( @toDate, ''YYYYMMDDHH24MISS'' );', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);

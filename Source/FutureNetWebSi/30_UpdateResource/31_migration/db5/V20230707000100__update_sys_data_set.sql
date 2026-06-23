DELETE FROM "ntss"."sys_data_set" where sql_cd in (-2250);
INSERT INTO ntss.sys_data_set(sql_cd,"sql",db_class,detail,can_repeat,use_application,report_class,memo,reg_date,up_date,pre_sql_info) VALUES
    (-2250,'SELECT
	'''' AS hosppatid --患者ID
	,ntss_db5_om.pat_id AS patid
	,COALESCE(to_char(to_timestamp(ntss_db5_om_rci_json ->> ''occur_date'', ''YYYY-MM-DD"T"HH24:MI:SS.FF3TZH:TZM''), ''YYYY-MM-DD hh24:mi:ss''),
			to_char(to_timestamp(ntss_db5_om_rti_json ->> ''occur_date'', ''YYYY-MM-DD"T"HH24:MI:SS.FF3TZH:TZM''), ''YYYY-MM-DD hh24:mi:ss'')) AS occurdate --発生日時
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
		WHEN ntss_db5_om_rci_json ->> ''medicine_type'' = ''2'' THEN ntss_db5_mst_mm.in_hospital_cd_1
		WHEN ntss_db5_om_rti_json ->> ''medicine_type'' = ''1'' THEN ntss_db5_mst_m.in_hospital_cd_1
	 END AS medicinecd1 --薬剤コード1
	 ,CASE
		WHEN ntss_db5_om_rci_json ->> ''medicine_type'' = ''2'' THEN ntss_db5_mst_mm.in_hospital_cd_2
		WHEN ntss_db5_om_rti_json ->> ''medicine_type'' = ''1'' THEN ntss_db5_mst_m.in_hospital_cd_2
	 END AS medicinecd2 --薬剤コード2
	 ,ntss_db5_om_rti_json ->> ''medicine_name'' AS medicinename --薬剤名称
	 ,ntss_db5_om_rti_json ->> ''amount'' AS amount --数量
	 ,ntss_db5_om_rti_json ->> ''unit'' AS unit --単位
	 ,ntss_db5_om_rti_json ->> ''procedure_name'' AS procedurename --手技名
	 ,ntss_db5_mst_p.in_hospital_cd_a1 AS procedurecd1 --手技コード1
	 ,ntss_db5_mst_p.in_hospital_cd_a2 AS procedurecd2 --手技コード2
	 ,SUBSTR(ntss_db5_om_tsi_json ->> ''treat_staff_name'', 0, 10) treatpersonname --処置者名
	 ,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
FROM
	    ord_main ntss_db5_om
	cross join lateral json_array_elements(ntss_db5_om.rst_complaint_info ::json) ntss_db5_om_rci_json
	cross join lateral json_array_elements(ntss_db5_om.rst_treatment_info ::json) ntss_db5_om_rti_json
	LEFT JOIN     mst_medicine_mix ntss_db5_mst_mm
	ON cast(ntss_db5_mst_mm.medicine_mix_cd AS char(4)) = ntss_db5_om_rti_json ->> ''treat_medicine_cd''
	AND ntss_db5_mst_mm.facility_cd = @facilityCd
	AND ntss_db5_mst_mm.up_date BETWEEN to_timestamp( @fromDate, ''YYYYMMDDHH24MISS'' )
	AND to_timestamp( @toDate, ''YYYYMMDDHH24MISS'' )
	LEFT JOIN     mst_medicine ntss_db5_mst_m
	ON cast(ntss_db5_mst_m.medicine_cd AS char(4)) = ntss_db5_om_rti_json ->> ''treat_medicine_cd''
	AND ntss_db5_mst_m.facility_cd = @facilityCd
	AND ntss_db5_mst_m.up_date BETWEEN to_timestamp( @fromDate, ''YYYYMMDDHH24MISS'' )
	AND to_timestamp( @toDate, ''YYYYMMDDHH24MISS'' )
	LEFT JOIN      mst_procedure ntss_db5_mst_p
	ON cast(ntss_db5_mst_p.procedure_cd AS char(4)) = ntss_db5_om_rti_json ->> ''procedure_cd''
	AND ntss_db5_mst_p.facility_cd = @facilityCd
	AND ntss_db5_mst_p.up_date BETWEEN to_timestamp( @fromDate, ''YYYYMMDDHH24MISS'' )
	AND to_timestamp( @toDate, ''YYYYMMDDHH24MISS'' )
	cross join lateral json_array_elements(ntss_db5_om.rst_treat_staff_info ::json) ntss_db5_om_tsi_json
WHERE ntss_db5_om.is_del = ''0''
	AND ntss_db5_om.facility_cd = @facilityCd
	AND ntss_db5_om.up_date BETWEEN to_timestamp( @fromDate, ''YYYYMMDDHH24MISS'' )
	AND to_timestamp( @toDate, ''YYYYMMDDHH24MISS'' );	',2,'[]','1','{"applications": [5]}','{"classes": []}','患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}','2021/02/26 17:51:54.726','2021/02/26 17:51:54.726',NULL);

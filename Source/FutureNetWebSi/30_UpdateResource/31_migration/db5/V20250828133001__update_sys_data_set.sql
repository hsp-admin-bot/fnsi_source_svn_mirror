DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307001;
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307001, 'WITH pat_info AS (
	SELECT
			staff_info ->> ''ctl_no'' AS ctl_no,
			staff_info ->> ''disp_order'' AS disp_order,
			staff_info ->> ''staff_cd'' AS staff_cd,
			staff_info ->> ''is_main'' AS is_main
	FROM
			pat_main AS pat
	CROSS JOIN LATERAL json_array_elements(pat.charge_staff_info::json) staff_info
	WHERE
		1 = 1
		AND pat.pat_id = @patId
		AND staff_info ->> ''is_main'' = ''1''
	ORDER BY
			staff_info ->> ''disp_order'' ASC
	LIMIT
			1
)
, coop_journal_info AS (
	SELECT
			user_id
	FROM
			sys_coop_journal AS sys
	WHERE
		1 = 1
		AND sys.ctl_no = @ctlNo
)
, coop_ini_info AS (
	-- 設定値全取得
	SELECT
		info ->> ''key1'' AS key1,
		info ->> ''key2'' AS key2,
		UNNEST(
			string_to_array(
				COALESCE(
					NULLIF(info ->> ''value'',''''),
					info ->> ''default_v''
				),
			'',''
			)
		) AS VALUE
	FROM
			mst_coop_ini AS ini
	CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
	WHERE
		1 = 1
		AND facility_cd = @facilityCd
		AND is_del = ''0''
		AND info ->> ''key0'' = @key0
)
, medical_name_setting AS (
-- 診療科名設定区分
	SELECT
			value
	FROM
			coop_ini_info info
	WHERE
		1 = 1
		AND info.key1 = ''PRESCRIPTION_XML_BASIC_INFO''
		AND info.key2 = ''DEPARTMENT_NAME_CLASS''
)
, medical_code_setting AS (
	-- 診療科コード設定区分
	SELECT
			value
	FROM
			coop_ini_info info
	WHERE
		1 = 1
		AND info.key1 = ''PRESCRIPTION_XML_BASIC_INFO''
		AND info.key2 = ''DEPARTMENT_CODE_CLASS''
)
, presciption_in_patient_setting AS (
  SELECT value FROM coop_ini_info WHERE 1 = 1 AND key1 = ''MCOM_COMMON_INFO'' AND key2 = ''INOUT_USE_SET''
)
, presciption_inout_setting AS (
  SELECT value FROM coop_ini_info WHERE 1 = 1 AND key1 = ''PRESCRIPTION_XML_BASIC_INFO'' AND key2 = ''PRESCRIPTION_INOUT''
)
, mcom_xml_info AS(
	-- 固定値取得
	SELECT
			key2,
			value
	FROM
			coop_ini_info
	WHERE
		1 = 1
		AND key1 = ''MCOM_XML_INFO''
)
 , doctor_name_class_setting AS(
	-- 担当医師コード区分
	SELECT
			value
	FROM
			coop_ini_info info
	WHERE
		1 = 1
		AND key1 = ''PRESCRIPTION_XML_BASIC_INFO''
		AND key2 = ''DOCTOR_CODE_CLASS''
)
, ord_info AS (
	-- 治療実績情報
	SELECT
			rst_charge_user_info ->> ''user_last_name_1'' AS last_name1,
			rst_charge_user_info ->> ''user_first_name_1'' AS first_name1,
			rst_charge_user_info ->> ''user_id_1'' AS user_id_1,
			rst_course_cd,
			rst_course_name,
			rst_in_out_class
	FROM
			ord_main
	WHERE
		1 = 1
		AND ord_no = @ordNo
)
, select_staff_cd AS (
	SELECT 
	(
	  CASE (SELECT value FROM doctor_name_class_setting)::text
	    WHEN ''0'' THEN COALESCE(
	      (SELECT CAST(user_id AS CHARACTER VARYING) FROM coop_journal_info),
	      (SELECT user_id_1 FROM ord_info),
	      (SELECT staff_cd FROM pat_info),
	      (SELECT value FROM coop_ini_info WHERE 1 = 1 AND key1 = ''MCOM_XML_INFO'' AND key2 = ''FIXED_DOCTOR_CODE1'')
	    )
	    WHEN ''1'' THEN COALESCE(
	      (SELECT user_id_1 FROM ord_info),
	      (SELECT staff_cd FROM pat_info),
	      (SELECT value FROM coop_ini_info WHERE 1 = 1 AND key1 = ''MCOM_XML_INFO'' AND key2 = ''FIXED_DOCTOR_CODE1'')
	    )
	    WHEN ''2'' THEN COALESCE(
	      (SELECT staff_cd FROM pat_info),
	      (SELECT value FROM coop_ini_info WHERE 1 = 1 AND key1 = ''MCOM_XML_INFO'' AND key2 = ''FIXED_DOCTOR_CODE1'')
	    )
	    WHEN ''3'' THEN (
	      SELECT value FROM coop_ini_info WHERE 1 = 1 AND key1 = ''MCOM_XML_INFO'' AND key2 = ''FIXED_DOCTOR_CODE1''
	    )
	    WHEN ''4'' THEN (
	      SELECT value FROM coop_ini_info WHERE 1 = 1 AND key1 = ''MCOM_XML_INFO'' AND key2 = ''FIXED_DOCTOR_CODE2''
	    )
	    WHEN ''5'' THEN (
	      SELECT value FROM coop_ini_info WHERE 1 = 1 AND key1 = ''MCOM_XML_INFO'' AND key2 = ''FIXED_NURSE_CODE1''
	    )
	    WHEN ''6'' THEN (
	      SELECT value FROM coop_ini_info WHERE 1 = 1 AND key1 = ''MCOM_XML_INFO'' AND key2 = ''FIXED_NURSE_CODE2''
	    )
	  END
	) AS staff_cd,
	-- ▼ staff_cdが取得された元テーブルの識別（0: journal, 1: ord, 2: pat, 3: coop）
	(
	  CASE (SELECT value FROM doctor_name_class_setting)::text
	    WHEN ''0'' THEN
	      CASE
	        WHEN EXISTS (SELECT 1 FROM coop_journal_info WHERE user_id IS NOT NULL) THEN ''0''
	        WHEN EXISTS (SELECT 1 FROM ord_info WHERE user_id_1 IS NOT NULL) THEN ''1''
	        WHEN EXISTS (SELECT 1 FROM pat_info WHERE staff_cd IS NOT NULL) THEN ''2''
	        ELSE ''3''
	      END
	    WHEN ''1'' THEN
	      CASE
	        WHEN EXISTS (SELECT 1 FROM ord_info WHERE user_id_1 IS NOT NULL) THEN ''1''
	        WHEN EXISTS (SELECT 1 FROM pat_info WHERE staff_cd IS NOT NULL) THEN ''2''
	        ELSE ''3''
	      END
	    WHEN ''2'' THEN
	      CASE
	        WHEN EXISTS (SELECT 1 FROM pat_info WHERE staff_cd IS NOT NULL) THEN ''2''
	        ELSE ''3''
	      END
	    WHEN ''3'' THEN ''3''
	    WHEN ''4'' THEN ''4''
	    WHEN ''5'' THEN ''5''
	    WHEN ''6'' THEN ''6''
	  END
	) AS trans_kbn
)
SELECT
	staff_cd,
	trans_kbn,
	(
	  CASE 
	    WHEN (SELECT trans_kbn FROM select_staff_cd) IN (''0'',''1'',''2'') THEN ''0''
	    WHEN (SELECT trans_kbn FROM select_staff_cd)  = ''3'' THEN (
	      SELECT value FROM mcom_xml_info WHERE 1 = 1 AND key2 = ''FIXED_DOCTOR_NAME1''
	    )
	    WHEN (SELECT trans_kbn FROM select_staff_cd)  = ''4'' THEN (
	      SELECT value FROM mcom_xml_info WHERE 1 = 1 AND key2 = ''FIXED_DOCTOR_NAME2''
	    )
	    WHEN (SELECT trans_kbn FROM select_staff_cd)  = ''5'' THEN (
	      SELECT value FROM mcom_xml_info WHERE 1 = 1 AND key2 = ''FIXED_NURSE_NAME1''
	    )
	    WHEN (SELECT trans_kbn FROM select_staff_cd)  = ''6'' THEN (
	      SELECT value FROM mcom_xml_info WHERE 1 = 1 AND key2 = ''FIXED_NURSE_NAME2''
	    )
	  END
	) AS staff_name,
	COALESCE(
	  (SELECT rst_course_name FROM ord_info),
	  (SELECT value FROM coop_ini_info WHERE 1 = 1 AND key1 = ''MCOM_XML_INFO'' AND key2 = ''DEPARTMENT_NAME'')
	) AS department_name,
	COALESCE(
	  (
	    SELECT in_hospital_cd_1
	    FROM ord_info
	    LEFT OUTER JOIN mst_course AS mcs ON mcs.course_cd = ord_info.rst_course_cd
	  ),
	  (
	    SELECT value FROM coop_ini_info WHERE 1 = 1 AND key1 = ''MCOM_XML_INFO'' AND key2 = ''DEPARTMENT_CODE''
	  )
	) AS department_cd,
	CASE
		WHEN (SELECT value FROM presciption_in_patient_setting) = ''1'' 
			THEN 
				CASE (SELECT rst_in_out_class FROM ord_info) 
					WHEN ''1'' THEN ''入院''
					WHEN ''0'' THEN ''外来''
				END
		ELSE ''''
	END AS in_patient_flag,
	CASE (SELECT value FROM presciption_inout_setting) 
		WHEN ''1'' THEN ''院外''
		WHEN ''0'' THEN ''院内''
		ELSE ''''
	END AS presciption_inout
FROM
	select_staff_cd', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
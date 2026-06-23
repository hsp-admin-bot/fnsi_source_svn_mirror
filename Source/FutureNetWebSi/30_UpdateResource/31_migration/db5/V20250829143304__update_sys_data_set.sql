DELETE FROM ntss.sys_data_set
WHERE sql_cd in (-307001, -307086, -307089);
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
	CASE (SELECT rst_in_out_class FROM ord_info) 
		WHEN ''1'' THEN ''院外''
		WHEN ''0'' THEN ''院内''
		ELSE ''''
	END AS presciption_inout
FROM
	select_staff_cd', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, '2023-11-21 23:54:57.716', '2025-06-19 10:54:40.687', NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307086, 'WITH all_values AS (
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value,
        info ->> ''key1'' AS key1,
        info ->> ''key2'' AS key2
    FROM mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = @facilityCd
        AND is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' IN (
            ''PRESCRIPTION_XML_BASIC_INFO'',
            ''PRESCRIPTION_INFO'',
            ''CATEGORY_NAME'',
            ''PRESCRIPTION_DETAILS'',
            ''PRESCRIPTION_XML_TREATMENT_INFO'',
            ''PRESCRIPTION_XML_OXYGEN_INFO'',
            ''PRESCRIPTION_XML_RECE_HOLI_INFO'',
            ''PRESCRIPTION_XML_RECE_DIAL_INFO''
        )
)
, journal AS (
    SELECT
        coop_ord_no
    FROM
        sys_coop_journal
    WHERE
        ctl_no = @ctlNo
        AND facility_cd = @facilityCd
)
SELECT
    (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_XML_BASIC_INFO'' AND key2 = ''S_VERSION'') AS s_version,
    (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_INFO'' AND key2 = ''MODEL_TYPE'') AS device_identifier,
    (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_XML_BASIC_INFO'' AND key2 = ''VISIT_CATEGORY'') AS visit_category,
    (SELECT value FROM all_values WHERE key1 = ''CATEGORY_NAME'' AND key2 = ''MEDICINE'') AS category_name_medicine,
    (SELECT value FROM all_values WHERE key1 = ''CATEGORY_NAME'' AND key2 = ''INJECTION'') AS category_name_injection,
    (SELECT value FROM all_values WHERE key1 = ''CATEGORY_NAME'' AND key2 = ''TREATMENT'') AS category_name_treatment,
    (SELECT value FROM all_values WHERE key1 = ''CATEGORY_NAME'' AND key2 = ''HOLIDAY'') AS category_name_holiday,
    (SELECT value FROM all_values WHERE key1 = ''CATEGORY_NAME'' AND key2 = ''DIALYSIS'') AS category_name_dialysis,
    (SELECT value FROM all_values WHERE key1 = ''CATEGORY_NAME'' AND key2 = ''CONSULTATION'') AS category_name_consultation,
    (SELECT value FROM all_values WHERE key1 = ''CATEGORY_NAME'' AND key2 = ''SURGERY'') AS category_name_surgery,
    (SELECT value FROM all_values WHERE key1 = ''CATEGORY_NAME'' AND key2 = ''EXAMINATION'') AS category_name_examination,
    (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_DETAILS'' AND key2 = ''TREATMENT'') AS prescription_details_treatment,
    (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_DETAILS'' AND key2 = ''OXYGEN'') AS prescription_details_oxygen,
    (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_DETAILS'' AND key2 = ''HOLIDAY'') AS prescription_details_holiday,
    (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_DETAILS'' AND key2 = ''DIALYSIS'') AS prescription_details_dialysis,
    (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_DETAILS'' AND key2 = ''CONSULTATION'') AS prescription_details_consultation,
    LPAD((SELECT coop_ord_no FROM journal) || (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_XML_TREATMENT_INFO'' AND key2 = ''ORDER_UNITS_ID''), 10, ''0'') AS order_units_id_treatment,
    LPAD((SELECT coop_ord_no FROM journal) || (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_XML_OXYGEN_INFO'' AND key2 = ''ORDER_UNITS_ID''), 10, ''0'') AS order_units_id_oxygen,
    LPAD((SELECT coop_ord_no FROM journal) || (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_XML_RECE_HOLI_INFO'' AND key2 = ''ORDER_UNITS_ID''), 10, ''0'') AS order_units_id_rece_holi,
    LPAD((SELECT coop_ord_no FROM journal) || (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_XML_RECE_DIAL_INFO'' AND key2 = ''ORDER_UNITS_ID''), 10, ''0'') AS order_units_id_rece_dial
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, '2025-06-19 10:54:40.687', '2025-08-12 12:18:54.282', NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307089, 'with department_code_class as (
    --診療科コード区分 0：治療情報．実績：診療科コード（診療科マスタの連携コード1）（取得できない場合は固定診療科コード）1：固定診療科名
    select coalesce(
            nullif(info->>''value'', ''''),
            info->>''default_v''
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) as info
    where ini.facility_cd = @facilityCd
        and ini.is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_BASIC_INFO''
        and info->>''key2'' = ''DEPARTMENT_CODE_CLASS''
    limit 1
), department_name_class as (
    --診療科名設定区分 0:治療情報．実績：診療科コードから診療科マスタの診療科名 1:固定診療科名
    select coalesce(
            nullif(info->>''value'', ''''),
            info->>''default_v''
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) as info
    where ini.facility_cd = @facilityCd
        and ini.is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_BASIC_INFO''
        and info->>''key2'' = ''DEPARTMENT_NAME_CLASS''
    limit 1
), fixed_medical_code as (
    --固定診療科コード:治療情報．実績：診療科コードより診療科が取得できなかった場合にセット
    select coalesce(
            nullif(info->>''value'', ''''),
            info->>''default_v''
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) as info
    where ini.facility_cd = @facilityCd
        and ini.is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''MCOM_XML_INFO''
        and info->>''key2'' = ''FIXED_MEDICAL_CODE''
    limit 1
), fixed_medical_name as (
    --固定診療科名:治療情報．実績：診療科名より診療科が取得できなかった場合にセット
    select coalesce(
            nullif(info->>''value'', ''''),
            info->>''default_v''
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) as info
    where ini.facility_cd = @facilityCd
        and ini.is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''MCOM_XML_INFO''
        and info->>''key2'' = ''FIXED_MEDICAL_NAME''
    limit 1
), ord_main_switch AS(
(
      SELECT
        ord.rst_course_cd as rst_course_cd,
        ord.rst_edition_date as up_date_switch
    FROM
        ord_main ord
    WHERE
        ord.ord_no = @ordNo
)
UNION
    (
        SELECT
            ord.rst_course_cd as rst_course_cd,
            ord.del_date as up_date_switch
        FROM
            ord_main_restore AS ord
            JOIN sys_coop_journal AS journal ON ord.ord_no = journal.ord_no
        WHERE
            ord.ord_no = @ordNo
            AND journal.ctl_no = @ctlNo
            AND ord.ord_no = journal.ord_no
            AND journal.reg_date >= ord.del_date
        ORDER BY
            del_date DESC
        LIMIT 1
    )
ORDER BY
      up_date_switch DESC NULLS LAST
LIMIT 1
)

select case
        when dcc.value = ''0'' then case
            when mc.in_hospital_cd_1 is not null
            or mc.in_hospital_cd_1 != '''' then mc.in_hospital_cd_1
            else fmc.value
        end
        when dcc.value = ''1'' then fmc.value
    end as course_cd,
    case
        when dnc.value = ''0'' then 
            case when mc.course_name is not null then mc.course_name
            else fmn.value end
        when dnc.value = ''1'' then fmn.value
    end as course_name
from ord_main_switch ord
    join department_code_class dcc on TRUE
    join department_name_class dnc on TRUE
    join fixed_medical_code fmc on TRUE
    join fixed_medical_name fmn on TRUE
    left join mst_course mc on mc.course_cd = ord.rst_course_cd
limit 1;', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '診療科取得用(削除オーダ)', '2025-06-19 10:54:40.687', '2025-06-19 10:54:40.687', NULL);

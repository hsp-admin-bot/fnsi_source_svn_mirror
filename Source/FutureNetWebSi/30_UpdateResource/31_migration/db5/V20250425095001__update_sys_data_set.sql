DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-306102, -306104, -307001, -307005, -307038, -307040, -307042, -307044, -307046, -307048, -307050, -307052, -307054, -307056, -307058, -307060, -307062, -307070, -309101, -310001, -310014, -317019, -317104, -317106, -317110, -317112, -317113, -317116, -317117, -317121, -317122, -317123, -317124, -317125, -317126, -317127, -317140);


INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-306102, 'WITH id_info AS(
    SELECT
        coop.hosp_pat_id as hosp_pat_id
    FROM
        sys_coop_journal AS coop
    WHERE
        coop.pat_id  = @patId
),
item_info AS(
    SELECT
        UNNEST(string_to_array(COALESCE(
                    NULLIF(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ), '','')) AS VALUE
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(
                ini.coop_ini_info::json
            ) info
    WHERE
        facility_cd = ''P_hosp''
    AND is_del = ''0''
    AND info ->> ''key0'' = @key0
    AND info ->> ''key1'' = ''ACCEPT_SEND''
    AND info ->> ''key2'' = ''FILENAME_NUMBER''
)
SELECT
    TO_CHAR(current_timestamp, ''YYYYMMDD_HH24MISS'') || ''_'' || VALUE || ''_'' || LTRIM(
        hosp_pat_id::TEXT,
        ''0''
    ) || ''.dat'' AS filename
FROM
    id_info,item_info', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom再来受付連携ファイル名取得', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-306104, 'with pat_info as(
select
    staff_info ->> ''ctl_no'' as ctl_no,
    staff_info ->> ''disp_order'' as disp_order,
    staff_info ->> ''staff_cd'' as staff_cd,
    staff_info ->> ''is_main'' as is_main,
    staff_info ->> ''is_charge'' as is_charge,
    staff_info ->> ''is_puncture'' as is_puncture
from
    pat_main as pat
cross join
            lateral json_array_elements(
                pat.charge_staff_info::json
            ) staff_info
where
    pat.pat_id = @patId
    and staff_info ->> ''is_main'' = ''1''
order by
    staff_info ->> ''disp_order'' asc
limit 1
),
accept_send as(
select
    info ->> ''key2'' as key2,
    unnest(string_to_array(coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ), '','')) as VALUE
from
    mst_coop_ini as ini
cross join
            lateral json_array_elements(
                ini.coop_ini_info::json
            ) info
where
    facility_cd = @facilityCd
    and is_del = ''0''
    and info ->> ''key0'' = @key0
    and info ->> ''key1'' = ''ACCEPT_SEND''
)
select
    case
        (
        select
            VALUE
        from
            accept_send
        where
            key2 = ''DOCTOR_CLASSIFICATION''
        )
        when ''0'' then coalesce(staff_cd,(
        select
            VALUE
                from
                    accept_send
                where
                    key2 = ''FIXED_DOCTOR_CODE1''
            ))
        -- 0：患者の担当医１ （取得できない場合は固定医師コード1）
        when ''1'' then(
        select
            VALUE
        from
            accept_send
        where
            key2 = ''FIXED_DOCTOR_CODE1''
        )
        --1：固定医師コード１
        when ''2'' then(
        select
            VALUE
        from
            accept_send
        where
            key2 = ''FIXED_DOCTOR_CODE2''
        )
        --2：固定医師コード２
        when ''3'' then ''''
        --3：空白   
        else ''''
    end as staff_cd,
    (case
        when
        (
        select
            value
        from
            accept_send
        where
            key2 = ''DOCTOR_CLASSIFICATION''
        ) = ''0''
        and staff_cd is not null then 1
        else 0
    end) as is_transformation
from
    (
    select
        (
        select
            staff_cd
        from
            pat_info
            ) as staff_cd
    ) as T01', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom受付情報の「医師１」事前実行SQL', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
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
		AND info.key1 = ''PRES_XML_BASIC_INFO''
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
  SELECT value FROM coop_ini_info WHERE 1 = 1 AND key1 = ''PRES_XML_BASIC_INFO'' AND key2 = ''PRESCRIPTION_INOUT''
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
	select_staff_cd', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307005, 'with pat_info as(
	select
		staff_info ->> ''ctl_no'' as ctl_no,
		staff_info ->> ''disp_order'' as disp_order,
		staff_info ->> ''staff_cd'' as staff_cd,
		staff_info ->> ''is_main'' as is_main
	from
		pat_main as pat
		cross join lateral json_array_elements(pat.charge_staff_info :: json) staff_info
	where
		pat.pat_id = @patId
		and staff_info ->> ''is_main'' = ''1''
	order by
		staff_info ->> ''disp_order'' asc
	limit
		1
), ord_info as (
	select
		rst_charge_user_info ->> ''user_last_name_1'' as last_name1,
		rst_charge_user_info ->> ''user_first_name_1'' as first_name1,
		rst_charge_user_info ->> ''user_id_1'' as user_id_1,
		rst_treat_staff_info ->> ''treat_staff_cd'' as treat_staff_cd,
		rst_treat_staff_info ->> ''treat_staff_name'' as treat_staff_name,
		rst_medi_info ->> ''effect_flg'' as effect_flg,
		rst_medi_info ->> ''cd'' as rst_medicine_cd,
		rst_medi_info ->> ''medicine_type'' as medicine_type,
		rst_treatment_info ->> ''treat_medicine_cd'' as treat_medicine_cd,
		rst_course_cd,
		rst_course_name
	from
		ord_main
	where
		ord_no = @ordNo
),
accept_send as(
	select
		info ->> ''key2'' as key2,
		unnest(
			string_to_array(
				coalesce(
					nullif(info ->> ''value'', ''''),
					info ->> ''default_v''
				),
				'',''
			)
		) as VALUE
	from
		mst_coop_ini as ini
		cross join lateral json_array_elements(ini.coop_ini_info :: json) info
	where
		facility_cd = @facilityCd
		and is_del = ''0''
		and info ->> ''key0'' = @key0
		and info ->> ''key1'' = ''ACCEPT_SEND''
),
rst_dial_value as(
	select
		info ->> ''key2'' as key2,
		unnest(
			string_to_array(
				coalesce(
					nullif(info ->> ''value'', ''''),
					info ->> ''default_v''
				),
				'',''
			)
		) as VALUE
	from
		mst_coop_ini as ini
		cross join lateral json_array_elements(ini.coop_ini_info :: json) info
	where
		facility_cd = @facilityCd
		and is_del = ''0''
		and info ->> ''key0'' = @key0
		and info ->> ''key1'' = ''RST_DIAL''
),
doctor_name_value as(
	select
		info ->> ''key2'' as key2,
		unnest(
			string_to_array(
				coalesce(
					nullif(info ->> ''value'', ''''),
					info ->> ''default_v''
				),
				'',''
			)
		) as VALUE
	from
		mst_coop_ini as ini
		cross join lateral json_array_elements(ini.coop_ini_info :: json) info
	where
		facility_cd = @facilityCd
		and is_del = ''0''
		and info ->> ''key0'' = @key0
		and info ->> ''key1'' = ''KARTE_ORD_SEND''
)
select
	lpad(
		concat(
			@ordNo,
			(
				select
					value
				from
					accept_send
				where
					key2 = ''PRESCRIPTION_INOUT''
			)
		),
		10
	) as order_units_id,
	(
		case
			(
				select
					value
				from
					rst_dial_value
				where
					key2 = ''INPUT_USER_KBN''
			)
			when ''0'' then coalesce(
				(
					select
						staff_cd
					from
						pat_info
				),
				(
					select
						last_name1 || first_name1
					from
						ord_info
				)
			)
			when ''1'' then coalesce(
				(
					select
						last_name1 || first_name1
					from
						ord_info
				),
				(
					select
						treat_staff_name
					from
						ord_info
				)
			)
			when ''2'' then coalesce(
				(
					select
						treat_staff_name
					from
						ord_info
				),
				(
					select
						value
					from
						doctor_name_value
					where
						key2 = ''FIXED_DOCTOR_NAME1''
				)
			)
			when ''3'' then (
				select
					value
				from
					doctor_name_value
				where
					key2 = ''FIXED_DOCTOR_NAME1''
			)
			when ''4'' then (
				select
					value
				from
					doctor_name_value
				where
					key2 = ''FIXED_DOCTOR_NAME2''
			)
			when ''5'' then (
				select
					value
				from
					doctor_name_value
				where
					key2 = ''FIXED_NURSE_NAME1''
			)
			when ''6'' then (
				select
					value
				from
					doctor_name_value
				where
					key2 = ''FIXED_NURSE_NAME1''
			)
		end
	) as staff_name,
	(
		case
			(
				select
					value
				from
					rst_dial_value
				where
					key2 = ''INPUT_USER_KBN''
			)
			when ''0'' then case
				when coalesce(
					(
						select
							staff_cd
						from
							pat_info
					),
					''''
				) = '''' then 0
				else 1
			end
			when ''1'' then case
				when coalesce(
					(
						select
							last_name1 || first_name1
						from
							ord_info
					),
					''''
				) = '''' then 1
				else 0
			end
			when ''2'' then case
				when coalesce(
					(
						select
							treat_staff_cd
						from
							ord_info
					),
					''''
				) = '''' then 0
				else 1
			end
			when ''3'' then 0
			when ''4'' then 0
			when ''5'' then 0
			when ''6'' then 0
		end
	) as trans_kbn,
	(
		case
			(
				select
					value
				from
					rst_dial_value
				where
					key2 = ''INPUT_USER_KBN''
			)
			when ''0'' then coalesce(
				(
					select
						staff_cd
					from
						pat_info
				),
				(
					select
						user_id_1
					from
						ord_info
				)
			)
			when ''1'' then coalesce(
				(
					select
						user_id_1
					from
						ord_info
				),
				(
					select
						treat_staff_cd
					from
						ord_info
				)
			)
			when ''2'' then coalesce(
				(
					select
						treat_staff_cd
					from
						ord_info
				),
				(
					select
						value
					from
						accept_send
					where
						key2 = ''FIXED_DOCTOR_CODE1''
				)
			)
			when ''3'' then (
				select
					value
				from
					accept_send
				where
					key2 = ''FIXED_DOCTOR_CODE1''
			)
			when ''4'' then (
				select
					value
				from
					accept_send
				where
					key2 = ''FIXED_DOCTOR_CODE2''
			)
			when ''5'' then (
				select
					value
				from
					nurse_code_value
				where
					key2 = ''FIXED_NURSE_CODE1''
			)
			when ''6'' then (
				select
					value
				from
					nurse_code_value
				where
					key2 = ''FIXED_NURSE_CODE2''
			)
		end
	) as staff_cd,
	(
		case
			(
				select
					value
				from
					rst_dial_value
				where
					key2 = ''INPUT_USER_KBN''
			)
			when ''0'' then (
				select
					mst_medicine
				from
					ord_info,
					mst_medicine
				where
					ord_info.rst_medicine_cd = mst_medicine.medicine_cd
					and mst_medicine.effect_flg = 1
			)
			when ''0'' then (
				select
					mst_medicine
				from
					ord_info,
					mst_medicine
				where
					ord_info.treat_medicine_cd = mst_medicine.medicine_cd
					and mst_medicine.class_cd = 1
			)
		end
	) as staff_cd', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307038, 'with ord_main_info as(
    select
        ord_addition_info ->> ''cd'' as code
    from
        ord_main
        cross join lateral json_array_elements(ord_main.addition_info :: json) ord_addition_info
    where
        ord_main.ord_no = @ordNo
),
addition_key_value as(
    select
        unnest(
            string_to_array(
                coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ),
                '',''
            )
        ) as VALUE
    from
        mst_coop_ini as ini
        cross join lateral json_array_elements(
            ini.coop_ini_info :: json
        ) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = @key0
        and info ->> ''key1'' = ''RST_DIAL''
        and info ->> ''key2'' = ''ADDITION_KEY''
)
select
    ROW_NUMBER() over(
        order by
            cast(mst_addition.addition_cd as character varying)
    ) AS seq_no,
    left(
        cast(mst_addition.addition_cd as character varying),
        20
    ) as code,
    left(mst_addition.addition_name, 256) as name
from
    ord_main_info,
    mst_addition,
    addition_key_value
where
    ord_main_info.code = cast(mst_addition.addition_cd as character varying)
    and mst_addition.in_hospital_cd_2 = cast(addition_key_value.value as character varying)', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307040, 'with ord_main_info as(
    select
        ord_addition_info ->> ''cd'' as code
    from
        ord_main
        cross join lateral json_array_elements(ord_main.addition_info :: json) ord_addition_info
    where
        ord_main.ord_no = @ordNo
),
addition_key_value as(
    select
        unnest(
            string_to_array(
                coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ),
                '',''
            )
        ) as VALUE
    from
        mst_coop_ini as ini
        cross join lateral json_array_elements(
            ini.coop_ini_info :: json
        ) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = @key0
        and info ->> ''key1'' = ''RST_DIAL''
        and info ->> ''key2'' = ''ADDITION_KEY''
)
select
    ROW_NUMBER() over(
        order by
            cast(mst_addition.addition_cd as character varying)
    ) AS seq_no,
    left(
        cast(mst_addition.addition_cd as character varying),
        20
    ) as code,
    left(mst_addition.addition_name, 256) as name
from
    ord_main_info,
    mst_addition,
    addition_key_value
where
    ord_main_info.code = cast(mst_addition.addition_cd as character varying)
    and mst_addition.in_hospital_cd_2 <> cast(addition_key_value.value as character varying)', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307042, 'with addition_treatment_name as(
    select
        unnest(
            string_to_array(
                coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ),
                '',''
            )
        ) as value
    from
        mst_coop_ini as ini
        cross join lateral json_array_elements(
            ini.coop_ini_info :: json
        ) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = @key0
        and info ->> ''key1'' = ''RST_DIAL''
        and info ->> ''key2'' = ''ADDITION_TREATMENT_NAME''
)
select
    ROW_NUMBER() over(
        order by
            cast(mst_treatment.treatment_cd as character varying)
    ) AS seq_no,
    left(
        cast(mst_treatment.treatment_cd as character varying),
        20
    ) as code,
    left(mst_treatment.treatment_name, 256) as name
from
    mst_treatment,
    addition_treatment_name
where
    mst_treatment.treatment_name = cast(
        addition_treatment_name.value as character varying
    )', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307044, 'with anticoagulant as (
    select
        ind_cond_info -> ''25'' ->> ''value'' AS medicine_cd,
        rst_cond_info -> ''25'' ->> ''medicine_type'' AS medicine_type,
        (
            cast(rst_cond_info -> ''26'' ->> ''value'' as integer) + cast(rst_cond_info -> ''28'' ->> ''value'' as integer)
        ) AS amount
    from
        ord_main
    where
        ord_no = @ordNo
),
treatment_item_value as(
    select
        unnest(
            string_to_array(
                coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ),
                '',''
            )
        ) as VALUE
    from
        mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info :: json) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = @key0
        and info ->> ''key1'' = ''RST_DIAL''
        and info ->> ''key2'' = ''TREATMENT_ITEM''
)
select
    ROW_NUMBER() over(
        order by
            cast(code as character varying)
    ) AS seq_no,
    ord_info.*
from
    (
        select
            (
                case
                    (
                        select
                            value
                        from
                            treatment_item_value
                    )
                    when ''1'' then left(mst_medicine.in_hospital_cd_1, 20)
                    when ''2'' then left(mst_medicine.in_hospital_cd_2, 20)
                    when ''3'' then left(mst_medicine.in_hospital_cd_3, 20)
                end
            ) as code,
            left(mst_medicine.medicine_name, 80) as name,
            anticoagulant.amount,
            mst_medicine.unit
        from
            anticoagulant,
            mst_medicine
        where
            anticoagulant.medicine_cd = cast(mst_medicine.medicine_cd as character varying)
            and anticoagulant.medicine_type = ''1''
        union
        select
            (
                case
                    (
                        select
                            value
                        from
                            treatment_item_value
                    )
                    when ''1'' then left(mst_medicine.in_hospital_cd_1, 20)
                    when ''2'' then left(mst_medicine.in_hospital_cd_2, 20)
                    when ''3'' then left(mst_medicine.in_hospital_cd_3, 20)
                end
            ) as code,
            left(mst_medicine.medicine_name, 80) as name,
            cast(anticoagulant_mix.amount as integer),
            mst_medicine.unit
        from
            (
                select
                    mix_info ->> ''cd'' as medicine_cd,
                    mix_info ->> ''amount'' as amount
                from
                    anticoagulant,
                    mst_medicine_mix
                    cross join lateral json_array_elements(mst_medicine_mix.mix_info :: json) mix_info
                where
                    anticoagulant.medicine_cd = cast(
                        mst_medicine_mix.medicine_mix_cd as character varying
                    )
                    and anticoagulant.medicine_type = ''2''
            ) as anticoagulant_mix,
            mst_medicine
        where
            anticoagulant_mix.medicine_cd = cast(mst_medicine.medicine_cd as character varying)
    ) ord_info', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307046, 'with anticoagulant as (
    select
        ind_cond_info -> ''15'' ->> ''value'' AS medicine_cd,
        rst_cond_info -> ''15'' ->> ''medicine_type'' AS medicine_type,
        rst_cond_info -> ''16'' ->> ''value'' AS amount
    from
        ord_main
    where
        ord_no = @ordNo
),
treatment_item_value as(
    select
        unnest(
            string_to_array(
                coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ),
                '',''
            )
        ) as VALUE
    from
        mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info :: json) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = @key0
        and info ->> ''key1'' = ''RST_DIAL''
        and info ->> ''key2'' = ''TREATMENT_ITEM''
)
select
    ROW_NUMBER() over(
        order by
            cast(code as character varying)
    ) AS seq_no,
    ord_info.*
from
    (
        select
            (
                case
                    (
                        select
                            value
                        from
                            treatment_item_value
                    )
                    when ''1'' then left(mst_medicine.in_hospital_cd_1, 20)
                    when ''2'' then left(mst_medicine.in_hospital_cd_2, 20)
                    when ''3'' then left(mst_medicine.in_hospital_cd_3, 20)
                end
            ) as code,
            left(mst_medicine.medicine_name, 80) as name,
            anticoagulant.amount,
            mst_medicine.unit_second as unit
        from
            anticoagulant,
            mst_medicine
        where
            anticoagulant.medicine_cd = cast(mst_medicine.medicine_cd as character varying)
            and anticoagulant.medicine_type = ''1''
        union
        select
            (
                case
                    (
                        select
                            value
                        from
                            treatment_item_value
                    )
                    when ''1'' then left(mst_medicine.in_hospital_cd_1, 20)
                    when ''2'' then left(mst_medicine.in_hospital_cd_2, 20)
                    when ''3'' then left(mst_medicine.in_hospital_cd_3, 20)
                end
            ) as code,
            left(mst_medicine.medicine_name, 80) as name,
            anticoagulant_mix.amount,
            mst_medicine.unit_second as unit
        from
            (
                select
                    mix_info ->> ''cd'' as medicine_cd,
                    mix_info ->> ''amount'' as amount
                from
                    anticoagulant,
                    mst_medicine_mix
                    cross join lateral json_array_elements(mst_medicine_mix.mix_info :: json) mix_info
                where
                    anticoagulant.medicine_cd = cast(
                        mst_medicine_mix.medicine_mix_cd as character varying
                    )
                    and anticoagulant.medicine_type = ''2''
            ) as anticoagulant_mix,
            mst_medicine
        where
            anticoagulant_mix.medicine_cd = cast(mst_medicine.medicine_cd as character varying)
    ) ord_info', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307048, 'with anticoagulant as (
    select
        ind_cond_info -> ''19'' ->> ''value'' AS medicine_cd,
        rst_cond_info -> ''19'' ->> ''medicine_type'' AS medicine_type,
        rst_cond_info -> ''22'' ->> ''value'' AS amount
    from
        ord_main
    where
        ord_no = @ordNo
),
treatment_item_value as(
    select
        unnest(
            string_to_array(
                coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ),
                '',''
            )
        ) as VALUE
    from
        mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info :: json) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = @key0
        and info ->> ''key1'' = ''RST_DIAL''
        and info ->> ''key2'' = ''TREATMENT_ITEM''
)
select
    ROW_NUMBER() over(
        order by
            cast(code as character varying)
    ) AS seq_no,
    ord_info.*
from
    (
        select
            (
                case
                    (
                        select
                            value
                        from
                            treatment_item_value
                    )
                    when ''1'' then left(mst_medicine.in_hospital_cd_1, 20)
                    when ''2'' then left(mst_medicine.in_hospital_cd_2, 20)
                    when ''3'' then left(mst_medicine.in_hospital_cd_3, 20)
                end
            ) as code,
            left(mst_medicine.medicine_name, 80) as name,
            anticoagulant.amount,
            mst_medicine.unit_second as unit
        from
            anticoagulant,
            mst_medicine
        where
            anticoagulant.medicine_cd = cast(mst_medicine.medicine_cd as character varying)
            and anticoagulant.medicine_type = ''1''
        union
        select
            (
                case
                    (
                        select
                            value
                        from
                            treatment_item_value
                    )
                    when ''1'' then left(mst_medicine.in_hospital_cd_1, 20)
                    when ''2'' then left(mst_medicine.in_hospital_cd_2, 20)
                    when ''3'' then left(mst_medicine.in_hospital_cd_3, 20)
                end
            ) as code,
            left(mst_medicine.medicine_name, 80) as name,
            anticoagulant_mix.amount,
            mst_medicine.unit_second as unit
        from
            (
                select
                    mix_info ->> ''cd'' as medicine_cd,
                    mix_info ->> ''amount'' as amount
                from
                    anticoagulant,
                    mst_medicine_mix
                    cross join lateral json_array_elements(mst_medicine_mix.mix_info :: json) mix_info
                where
                    anticoagulant.medicine_cd = cast(
                        mst_medicine_mix.medicine_mix_cd as character varying
                    )
                    and anticoagulant.medicine_type = ''2''
            ) as anticoagulant_mix,
            mst_medicine
        where
            anticoagulant_mix.medicine_cd = cast(mst_medicine.medicine_cd as character varying)
    ) ord_info', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307050, 'with ord_medi_infos as (
    select
        ord_medi_info ->> ''cd'' as medicine_cd,
        ord_medi_info ->> ''amount'' as amount
    from
        ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info :: json) ord_medi_info
    where
        ord_no = @ordNo
        and ord_medi_info ->> ''effect_flg'' = ''1''
        and ord_medi_info ->> ''medicine_type'' = ''1''
    union
    select
        ord_treatment_info ->> ''medicine_cd'' as medicine_cd,
        ord_treatment_info ->> ''amount'' as amount
    from
        ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info :: json) ord_treatment_info
    where
        ord_no = @ordNo
),
ord_medi_mix_infos as (
    select
        ord_medi_info ->> ''cd'' as medicine_mix_cd,
        ord_medi_info ->> ''amount'' as amount
    from
        ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info :: json) ord_medi_info
    where
        ord_no = @ordNo
        and ord_medi_info ->> ''effect_flg'' = ''1''
        and ord_medi_info ->> ''medicine_type'' = ''2''
),
treatment_item_value as(
    select
        unnest(
            string_to_array(
                coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ),
                '',''
            )
        ) as VALUE
    from
        mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info :: json) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = @key0
        and info ->> ''key1'' = ''RST_DIAL''
        and info ->> ''key2'' = ''TREATMENT_ITEM''
)
select
    ROW_NUMBER() over(
        order by
            cast(code as character varying)
    ) AS seq_no,
    ord_info.*
from
    (
        select
            (
                case
                    (
                        select
                            value
                        from
                            treatment_item_value
                    )
                    when ''1'' then left(mst_comp_treatment.in_hospital_cd_a1, 20)
                    when ''2'' then left(mst_comp_treatment.in_hospital_cd_a2, 20)
                    when ''3'' then left(mst_comp_treatment.in_hospital_cd_a3, 20)
                end
            ) as code,
            left(mst_comp_treatment.treatment, 256) as name,
            ord_medi_infos.amount,
            mst_medicine.unit
        from
            ord_medi_infos,
            mst_medicine,
            mst_comp_treatment
        where
            ord_medi_infos.medicine_cd = cast(
                mst_medicine.medicine_cd as character varying
            )
            and mst_medicine.class_cd = ''01''
            and mst_medicine.medicine_cd = mst_comp_treatment.comp_treatment_cd
            and mst_comp_treatment.treat_class = ''1''
        union
        select
            (
                case
                    (
                        select
                            value
                        from
                            treatment_item_value
                    )
                    when ''1'' then left(mst_comp_treatment.in_hospital_cd_a1, 20)
                    when ''2'' then left(mst_comp_treatment.in_hospital_cd_a2, 20)
                    when ''3'' then left(mst_comp_treatment.in_hospital_cd_a3, 20)
                end
            ) as code,
            left(mst_comp_treatment.treatment, 256) as name,
            ord_medi_mix_infos.amount,
            mst_medicine_mix.unit
        from
            ord_medi_mix_infos,
            mst_medicine_mix,
            mst_comp_treatment
        where
            ord_medi_mix_infos.medicine_mix_cd = cast(
                mst_medicine_mix.medicine_mix_cd as character varying
            )
            and mst_medicine_mix.class_cd = ''01''
            and mst_medicine_mix.medicine_mix_cd = mst_comp_treatment.comp_treatment_cd
            and mst_comp_treatment.treat_class = ''1''
    ) ord_info', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307052, 'with column_info as (
    select
        ind_cond_info -> ''6'' ->> ''value'' AS equipment_cd,
        1 AS amount
    from
        ord_main
    where
        ord_no = @ordNo
),
equipment_info as (
    select
        rst_equip_info ->> ''cd'' AS equipment_cd,
        rst_equip_info ->> ''amount'' AS amount
    from
        ord_main
        cross join lateral json_array_elements(ord_main.rst_equip_info :: json) rst_equip_info
    where
        ord_no = @ordNo
),
treatment_item_value as(
    select
        unnest(
            string_to_array(
                coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ),
                '',''
            )
        ) as VALUE
    from
        mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info :: json) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = @key0
        and info ->> ''key1'' = ''RST_DIAL''
        and info ->> ''key2'' = ''TREATMENT_ITEM''
)
select
    ROW_NUMBER() over(
        order by
            cast(code as character varying)
    ) AS seq_no,
    ord_info.*
from
    (
        select
            (
                case
                    (
                        select
                            value
                        from
                            treatment_item_value
                    )
                    when ''1'' then left(mst_equipment.in_hospital_cd_1, 20)
                    when ''2'' then left(mst_equipment.in_hospital_cd_2, 20)
                    when ''3'' then left(mst_equipment.in_hospital_cd_3, 20)
                end
            ) as code,
            left(mst_equipment.equipment_name, 80) as name,
            column_info.amount,
            mst_equipment.unit
        from
            column_info,
            mst_equipment
        where
            column_info.equipment_cd = cast(mst_equipment.equipment_cd as character varying)
        union
        select
            (
                case
                    (
                        select
                            value
                        from
                            treatment_item_value
                    )
                    when ''1'' then left(mst_equipment.in_hospital_cd_1, 20)
                    when ''2'' then left(mst_equipment.in_hospital_cd_2, 20)
                    when ''3'' then left(mst_equipment.in_hospital_cd_3, 20)
                end
            ) as code,
            left(mst_equipment.equipment_name, 80) as name,
            cast(equipment_info.amount as integer),
            mst_equipment.unit
        from
            equipment_info,
            mst_equipment
        where
            equipment_info.equipment_cd = cast(mst_equipment.equipment_cd as character varying)
    ) ord_info', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307054, 'with dialyzer_info as (
    select
        ind_cond_info -> ''5'' ->> ''value'' AS dialyzer_cd,
        1 AS amount
    from
        ord_main
    where
        ord_no = @ordNo
),
treatment_item_value as(
    select
        unnest(
            string_to_array(
                coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ),
                '',''
            )
        ) as VALUE
    from
        mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info :: json) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = @key0
        and info ->> ''key1'' = ''RST_DIAL''
        and info ->> ''key2'' = ''TREATMENT_ITEM''
)
select
    ROW_NUMBER() over(
        order by
            cast(code as character varying)
    ) AS seq_no,
    ord_info.*
from
    (
        select
            (
                case
                    (
                        select
                            value
                        from
                            treatment_item_value
                    )
                    when ''1'' then left(mst_dialyzer.in_hospital_cd_1, 20)
                    when ''2'' then left(mst_dialyzer.in_hospital_cd_2, 20)
                    when ''3'' then left(mst_dialyzer.in_hospital_cd_3, 20)
                end
            ) as code,
            left(mst_dialyzer.dialyzer_type, 80) as name,
            dialyzer_info.amount,
            ''1'' as unit
        from
            dialyzer_info,
            mst_dialyzer
        where
            dialyzer_info.dialyzer_cd = cast(mst_dialyzer.dialyzer_cd as character varying)
    ) ord_info', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307056, 'with equipment_info1 as (
    select
        ind_cond_info -> ''7'' ->> ''value'' AS equipment_cd,
        1 AS amount
    from
        ord_main
    where
        ord_no = @ordNo
),
equipment_info2 as (
    select
        ind_cond_info -> ''8'' ->> ''value'' AS equipment_cd,
        1 AS amount
    from
        ord_main
    where
        ord_no = @ordNo
),
treatment_item_value as(
    select
        unnest(
            string_to_array(
                coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ),
                '',''
            )
        ) as VALUE
    from
        mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info :: json) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = @key0
        and info ->> ''key1'' = ''RST_DIAL''
        and info ->> ''key2'' = ''TREATMENT_ITEM''
)
select
    ROW_NUMBER() over(
        order by
            cast(code as character varying)
    ) AS seq_no,
    ord_info.*
from
    (
        select
            (
                case
                    (
                        select
                            value
                        from
                            treatment_item_value
                    )
                    when ''1'' then left(mst_equipment.in_hospital_cd_1, 20)
                    when ''2'' then left(mst_equipment.in_hospital_cd_2, 20)
                    when ''3'' then left(mst_equipment.in_hospital_cd_3, 20)
                end
            ) as code,
            left(mst_equipment.equipment_name, 80) as name,
            equipment_info1.amount,
            mst_equipment.unit
        from
            equipment_info1,
            mst_equipment
        where
            equipment_info1.equipment_cd = cast(mst_equipment.equipment_cd as character varying)
        union
        select
            (
                case
                    (
                        select
                            value
                        from
                            treatment_item_value
                    )
                    when ''1'' then left(mst_equipment.in_hospital_cd_1, 20)
                    when ''2'' then left(mst_equipment.in_hospital_cd_2, 20)
                    when ''3'' then left(mst_equipment.in_hospital_cd_3, 20)
                end
            ) as code,
            left(mst_equipment.equipment_name, 80) as name,
            equipment_info2.amount,
            mst_equipment.unit
        from
            equipment_info2,
            mst_equipment
        where
            equipment_info2.equipment_cd = cast(mst_equipment.equipment_cd as character varying)
    ) ord_info', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307058, 'with oxygen_item_value as(
    select
        unnest(
            string_to_array(
                coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ),
                '',''
            )
        ) as value,
        info ->> ''key2'' as key2
    from
        mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info :: json) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = @key0
        and info ->> ''key1'' = ''OXYGEN_PROCEDURE''
)
select
    1 AS seq_no,
    (
        select
            value
        from
            oxygen_item_value
        where
            key2 = ''MEDI_CD''
    ) as code,
    (
        select
            value
        from
            oxygen_item_value
        where
            key2 = ''MEDI_NAME''
    ) as name', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307060, 'with ord_rst_treatment_info as (
    select
        ord_rst_treatment_info ->> ''oxygen_amount'' as amount
    from
        ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info :: json) ord_rst_treatment_info
    where
        ord_no = @ordNo
),
oxygen_item_value as(
    select
        unnest(
            string_to_array(
                coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ),
                '',''
            )
        ) as value,
        info ->> ''key2'' as key2
    from
        mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info :: json) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = @key0
        and info ->> ''key1'' = ''OXYGEN''
)
select
    1 AS seq_no,
    (
        select
            value
        from
            oxygen_item_value
        where
            key2 = ''MEDI_CD''
    ) as code,
    (
        select
            value
        from
            oxygen_item_value
        where
            key2 = ''MEDI_NAME''
    ) as name,
    sum(cast(ord_rst_treatment_info.amount as integer)) as amount,
    (
        select
            value
        from
            oxygen_item_value
        where
            key2 = ''UNIT''
    ) as unit
from
    ord_rst_treatment_info', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307062, 'with ord_medi_infos as (
    select
        ord_medi_info ->> ''cd'' as medicine_cd,
        ord_medi_info ->> ''amount'' as amount
    from
        ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info :: json) ord_medi_info
    where
        ord_no = @ordNo
        and ord_medi_info ->> ''effect_flg'' = ''1''
        and ord_medi_info ->> ''medicine_type'' = ''1''
    union
    select
        ord_treatment_info ->> ''medicine_cd'' as medicine_cd,
        ord_treatment_info ->> ''amount'' as amount
    from
        ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info :: json) ord_treatment_info
    where
        ord_no = @ordNo
),
ord_medi_mix_infos as (
    select
        ord_medi_info ->> ''cd'' as medicine_mix_cd,
        ord_medi_info ->> ''amount'' as amount
    from
        ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info :: json) ord_medi_info
    where
        ord_no = @ordNo
        and ord_medi_info ->> ''effect_flg'' = ''1''
        and ord_medi_info ->> ''medicine_type'' = ''2''
),
treatment_item_value as(
    select
        unnest(
            string_to_array(
                coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ),
                '',''
            )
        ) as VALUE
    from
        mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info :: json) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = @key0
        and info ->> ''key1'' = ''RST_DIAL''
        and info ->> ''key2'' = ''TREATMENT_ITEM''
)
select
    ROW_NUMBER() over(
        order by
            cast(code as character varying)
    ) AS seq_no,
    ord_info.*
from
    (
        select
            (
                case
                    (
                        select
                            value
                        from
                            treatment_item_value
                    )
                    when ''1'' then left(mst_medicine.in_hospital_cd_1, 20)
                    when ''2'' then left(mst_medicine.in_hospital_cd_2, 20)
                    when ''3'' then left(mst_medicine.in_hospital_cd_3, 20)
                end
            ) as code,
            left(mst_medicine.medicine_name, 80) as name,
            ord_medi_infos.amount,
            mst_medicine.unit
        from
            ord_medi_infos,
            mst_medicine
        where
            ord_medi_infos.medicine_cd = cast(
                mst_medicine.medicine_cd as character varying
            )
            and mst_medicine.class_cd = ''01''
        union
        select
            (
                case
                    (
                        select
                            value
                        from
                            treatment_item_value
                    )
                    when ''1'' then left(mst_medicine_mix.in_hospital_cd_1, 20)
                    when ''2'' then left(mst_medicine_mix.in_hospital_cd_2, 20)
                    when ''3'' then left(mst_medicine_mix.in_hospital_cd_3, 20)
                end
            ) as code,
            left(mst_medicine_mix.medicine_mix_name, 80) as name,
            ord_medi_mix_infos.amount,
            mst_medicine_mix.unit
        from
            ord_medi_mix_infos,
            mst_medicine_mix
        where
            ord_medi_mix_infos.medicine_mix_cd = cast(
                mst_medicine_mix.medicine_mix_cd as character varying
            )
            and mst_medicine_mix.class_cd = ''01''
    ) ord_info', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307070, 'with ord_main_info as(
    select
        ord_addition_info ->> ''cd'' as code
    from
        ord_main
        cross join lateral json_array_elements(ord_main.addition_info :: json) ord_addition_info
    where
        ord_main.ord_no = @ordNo
),
treatment_item_value as(
    select
        unnest(
            string_to_array(
                coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ),
                '',''
            )
        ) as VALUE
    from
        mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info :: json) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = @key0
        and info ->> ''key1'' = ''RST_DIAL''
        and info ->> ''key2'' = ''TREATMENT_ITEM''
)
select
    ROW_NUMBER() over(
        order by
            cast(code as character varying)
    ) AS seq_no,
    (
        case
            (
                select
                    value
                from
                    treatment_item_value
            )
            when ''1'' then left(mst_addition.in_hospital_cd_1, 20)
            when ''2'' then left(mst_addition.in_hospital_cd_2, 20)
            when ''3'' then left(mst_addition.in_hospital_cd_3, 20)
        end
    ) as code,
    left(mst_addition.addition_name, 256) as name
from
    ord_main_info,
    mst_addition
where
    ord_main_info.code = cast(mst_addition.addition_cd as character varying)
    and mst_addition.addition_class = ''1''', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-309101, 'WITH
exam_item AS(
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        ntss.mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(ini.coop_ini_info::json) info
    where
        facility_cd = ''@facilityCd''
    AND is_del = ''0''
    AND info ->> ''key0'' = ''@key0''
    AND info ->> ''key1'' = ''MST''
    AND info ->> ''key2'' = ''EXAM_ITEM''
)
INSERT INTO pat_exam_main (
  pat_id,
  facility_cd,
  ord_no,
  fn_pat_id,
  reg_exam_date,
  reg_order_class,
  exam_status,
  order_comment,
  order_exam_set_info,
  exam_order_info,
  order_label_info,
  data_gen_class,
  result_exam_date,
  result_comment,
  exam_result_info,
  cop_order_no1,
  cop_order_no2,
  is_lock,
  ind_user_id,
  is_del,
  reg_date,
  reg_staff,
  up_date,
  up_staff,
  is_order,
  exam_week,
  exam_from,
  exam_to,
  exam_pattern 
)
VALUES
  (
    @patId,
    ''@facilityCd'',
  CASE
      ''@ordNo'' 
      WHEN '''' THEN
      NULL ELSE to_number( ''@ordNo'', ''9999999999999999999999999999999999999999999999999999999999999999'' ) 
    END,
    NULLIF ( ''@fnPatId'', '''' ),
  CASE
      ''@regExamDate'' 
      WHEN '''' THEN
      CURRENT_TIMESTAMP ELSE to_timestamp( ''@regExamDate_Date'', ''yyyy-MM-dd hh24:mi:ss'' ) 
    END,
	CASE 
	    WHEN ''@regOrderClass'' IN (''1'', ''2'') THEN ''@regOrderClass''
	    ELSE ''0''
	END,
    NULLIF ( ''@examStatus'', '''' ),
    NULLIF ( ''@orderComment'', '''' ),
    ''@orderExamSetInfoValue'',
    ''@examOrderInfoValue'',
    ''@orderLabelInfoValue'',
    NULLIF ( ''@dataGenClass'', '''' ),
  CASE
      ''@resultExamDate'' 
      WHEN '''' THEN
      NULL ELSE to_timestamp( ''@resultExamDate_Date'', ''yyyy-MM-dd hh24:mi:ss'' ) 
    END,
    ''@resultComment'',
    ''@examResultInfoValue'',
  CASE
      ''@copOrderNo1'' 
      WHEN '''' THEN
      NULL ELSE to_number( ''@copOrderNo1'', ''9999999999999999999999999999999999999999999999999999999999999999'' ) 
    END,
  CASE
      ''@copOrderNo2'' 
      WHEN '''' THEN
      NULL ELSE to_number( ''@copOrderNo2'', ''9999999999999999999999999999999999999999999999999999999999999999'' ) 
      END,
    NULLIF ( ''@isLock'', '''' ),
  CASE
      ''@indUserId'' 
      WHEN '''' THEN
      NULL ELSE to_number( ''@indUserId'', ''9999999999999999999999999999999999999999999999999999999999999999'' ) 
    END,
    ''0'',
    CURRENT_TIMESTAMP,
  CASE
      ''@regStaff'' 
      WHEN '''' THEN
      NULL ELSE to_number( ''@regStaff'', ''9999999999999999999999999999999999999999999999999999999999999999'' ) 
    END,
    CURRENT_TIMESTAMP,
  CASE
      ''@upStaff'' 
      WHEN '''' THEN
      NULL ELSE to_number( ''@upStaff'', ''9999999999999999999999999999999999999999999999999999999999999999'' ) 
    END,
    NULLIF ( ''@isOrder'', '''' ),
  CASE
      ''@examWeek'' 
      WHEN '''' THEN
      NULL ELSE to_number( ''@examWeek'', ''9999999999999999'' ) 
    END,
  CASE
      ''@examFrom'' 
      WHEN '''' THEN
      NULL ELSE to_timestamp( ''@examFrom'', ''yyyymmddhh24miss'' ) 
      END,
  CASE
      ''@examTo'' 
      WHEN '''' THEN
      NULL ELSE to_timestamp( ''@examTo'', ''yyyymmddhh24miss'' ) 
      END,
  CASE
      ''@examPattern'' 
      WHEN '''' THEN
      NULL ELSE to_number( ''@examPattern'', ''9999999999999999'' ) 
    END 
  )', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)Medicomの検査結果', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-310001, 'SELECT
        UNNEST(string_to_array(COALESCE(
                    NULLIF(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ), '','')) AS exam_institution_cd
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(
                ini.coop_ini_info::json
            ) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = @key0
    AND info ->> ''key1'' = ''EXAM_ORD''
    AND info ->> ''key2'' = ''EXAM_INSTITUTION_CD''', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom検査オーダ連携用の[連携設定→検査機関コード]値取得', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-310014, 'with
min_staff_ctl_no AS (
SELECT min(staff.value ->> ''ctl_no'') AS min_is_main_ctl_no
FROM pat_main 
        CROSS JOIN
            LATERAL json_array_elements(pat_main.charge_staff_info::json) staff
    WHERE
        pat_id = @patId
        AND staff.value ->> ''is_main'' = ''1'' 
)
,staff AS (
SELECT 
    staff.value ->> ''staff_cd'' staff_cd
from pat_main 
        CROSS JOIN
            LATERAL json_array_elements(pat_main.charge_staff_info::json) staff
    WHERE
        pat_id = @patId
        and staff.value ->> ''ctl_no'' = (SELECT min_is_main_ctl_no FROM min_staff_ctl_no)
)
,def_doctor AS(
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = @key0
    AND info ->> ''key1'' = ''EXAM_ORD''
    AND info ->> ''key2'' = ''DEFAULT_DOCTOR''
)
, doctor_data as(
SELECT 
    CASE 
    WHEN (SELECT min_is_main_ctl_no FROM min_staff_ctl_no) IS NULL THEN (SELECT value FROM def_doctor)
    ELSE (SELECT staff_cd FROM staff)
    END AS staff_cd
)
,exam_data as (
    select
        TO_CHAR(
            reg_exam_date,
            ''YYYYMMDD''
        ) as exam_date,
        case
            reg_order_class
    when ''0'' then '' ''
            else reg_order_class
        end as exam_timing,
        order_exam_set_info
    from
        ntss.pat_exam_main
    where
        exam_main_cd = @ordNo ::integer
        --    )
),
output_item as(
    select
        coalesce(
            nullif(
                info ->> ''value'',
                ''''
            ),
            info ->> ''default_v''
        ) as value
    from
        mst_coop_ini as ini
    cross join
            lateral json_array_elements(
            ini.coop_ini_info::json
        ) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = @key0
        and info ->> ''key1'' = ''EXAM_ORD''
        and info ->> ''key2'' = ''OUTPUT_ITEM''
)
,
exam_set as(
    select
        exam_set.other_exam_time
    from
        (
            select
                order_exam_set_info
            from
                exam_data
        ) p
    cross join lateral json_array_elements(
            p.order_exam_set_info ::json
        ) info
    inner join mst_exam_set as exam_set 
                on
        info ->> ''set_cd'' = (
            exam_set.exam_set_cd || ''''
        )
),
before_margin as(
    select
        coalesce(
            nullif(
                info ->> ''value'',
                ''''
            ),
            info ->> ''default_v''
        ) as value
    from
        mst_coop_ini as ini
    cross join
            lateral json_array_elements(
            ini.coop_ini_info::json
        ) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = @key0
        and info ->> ''key1'' = ''EXAM_ORD''
        and info ->> ''key2'' = ''BEFORE_MARGIN''
),
after_margin as(
    select
        coalesce(
            nullif(
                info ->> ''value'',
                ''''
            ),
            info ->> ''default_v''
        ) as value
    from
        mst_coop_ini as ini
    cross join
            lateral json_array_elements(
            ini.coop_ini_info::json
        ) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = @key0
        and info ->> ''key1'' = ''EXAM_ORD''
        and info ->> ''key2'' = ''AFTER_MARGIN''
),
ord_data as(
    select
        ord.ord_no,
        ord.ind_treat_start_time,
        ind_cond_info -> ''1'' ->> ''value'' as plan_dialysis_time
    from
        (
            select
                *
            from
                ord_main
            where
                pat_id = @patId ::integer
                and treat_date = (
                    select
                        exam_date
                    from
                        exam_data
                )
                and is_del = ''0''
            order by
                ind_treat_start_time asc
            limit 1
        ) ord
),
exam_time as (
    select
        (
            select
                ord_no
            from
                ord_data
        ) as ord_no,
        exam_date,
        exam_timing,
        case
            exam_timing
  when ''1'' then 
  to_char(
                (
                    (
                        select
                            ind_treat_start_time
                        from
                            ord_data
                    )::time - (
                        (
                            select
                                value
                            from
                                before_margin
                        ) || '' minutes''
                    )::interval
                ),
                ''HH24MI''
            )
            when ''2'' then 
  to_char(
                (
                    (
                        select
                            ind_treat_start_time
                        from
                            ord_data
                    )::time + (
                        (
                            select
                                plan_dialysis_time
                            from
                                ord_data
                        ) || '' minutes''
                    )::interval + (
                        (
                            select
                                value
                            from
                                after_margin
                        ) || '' minutes''
                    )::interval
                ),
                ''HH24MI''
            )
            else (
                select
                    other_exam_time
                from
                    exam_set
            )
        end as exam_time
    from
        exam_data
),
output_in_out as(
    select
        coalesce(
            nullif(
                info ->> ''value'',
                ''''
            ),
            info ->> ''default_v''
        ) as value
    from
        mst_coop_ini as ini
    cross join
            lateral json_array_elements(
            ini.coop_ini_info::json
        ) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = @key0
        and info ->> ''key1'' = ''EXAM_ORD''
        and info ->> ''key2'' = ''OUTPUT_IN_OUT''
),
item_set_no as (
    --SELECT info.value ->> ''no'' AS no
    select
        info ->> ''set_cd'' as no
    from
        (
            select
                m.*
            from
                pat_exam_main as m
            where
                m.is_del = ''0''
                and jsonb_array_length(m.order_exam_set_info) > 0
                    and m.exam_main_cd = @ordNo ::integer
        ) p
    cross join lateral json_array_elements(
            p.order_exam_set_info ::json
        ) info
    inner join mst_exam_set as item 
                on
        info ->> ''set_cd'' = (
            item.exam_set_cd || ''''
        )
),
exam_items AS (
select
    item_cd,
    item_name,
    in_hospital_cd1,
    in_hospital_cd2,
    in_hospital_cd3
from
    (
        select
            info ->> ''set_cd'' as seq_no,
            ''6'' as sub_no,
            -- 子（検査項目）
            info ->> ''item_cd'' as item_cd,
            info ->> ''item_name'' as item_name,
            item.in_hospital_cd1,
            item.in_hospital_cd2,
            item.in_hospital_cd3
        from
            (
                select
                    m.*
                from
                    pat_exam_main as m
                where
                    m.is_del = ''0''
                    and jsonb_array_length(m.order_exam_set_info) > 0
                        and m.exam_main_cd = @ordNo ::integer
            ) p
        cross join lateral json_array_elements(
                p.exam_order_info ::json
            ) info
        join mst_exam_item as item 
            on
            info ->> ''item_cd'' = (
                item.exam_item_cd || ''''
            )
            and 
                case (select value from output_in_out)
                when ''1'' then item.is_in_hospital = ''0''
                when ''2'' then item.is_in_hospital = ''1''
                else true
            end
        where
            info ->> ''set_cd'' in (
                select
                    no
                from
                    item_set_no
            )
            and
          case
                (
                    select
                        value
                    from
                        output_item
                )
                when ''1'' then false
                else true
            end
    union all
        select
            info ->> ''set_cd'' as seq_no,
            ''5'' as sub_no,
            -- 親（検査セット）
            info ->> ''set_cd'' as item_cd,
            info ->> ''set_name'' as item_name,
            item.in_hospital_cd1,
            item.in_hospital_cd2,
            item.in_hospital_cd3
        from
            (
                select
                    m.*
                from
                    pat_exam_main as m
                where
                    m.is_del = ''0''
                    and jsonb_array_length(m.order_exam_set_info) > 0
                        and m.exam_main_cd = @ordNo ::integer
            ) p
        cross join lateral json_array_elements(
                p.order_exam_set_info ::json
            ) info
        left outer join mst_exam_set as item
            on
            info ->> ''set_cd'' = (
                item.exam_set_cd || ''''
            )
        where
            info ->> ''set_cd'' in (
                select
                    no
                from
                    item_set_no
            )
            and 
          case
                (
                    select
                        value
                    from
                        output_item
                )
                when ''2'' then false
                else true
            end
    ) exam_all
order by
    item_cd
)
INSERT INTO ntss.pat_coop_detail(
    facility_cd,
    pat_id,
    save_1,
    save_2,
    is_disp,
    is_del,
    user_id,
    up_date,
    reg_date,
    coop_version
)
SELECT
    @facilityCd,
    @patId::integer,
    ''{"pkg": "MED"}''::jsonb,
    jsonb_build_object(
        ''ord_no'', (SELECT ord_no FROM ord_data),
        ''hosp_pat_id'', LPAD(@hospPatId::text, 12, ''0''),
        ''exam_date'', (SELECT exam_date FROM exam_data), 
        ''exam_timing'', (SELECT exam_timing FROM exam_data),
        ''exam_time'', (SELECT exam_time FROM exam_time),
        ''staff_cd'',(SELECT staff_cd FROM doctor_data),
        ''exam_items'',
        (select jsonb_agg(
            jsonb_build_object(
                    ''exam_cd'',item_cd,
                    ''exam_name'',item_name,
                    ''in_hospital_cd1'',in_hospital_cd1,
                    ''in_hospital_cd2'',in_hospital_cd2,
                    ''in_hospital_cd3'',in_hospital_cd3
                )
            )
            from exam_items
        )::jsonb),
    ''1'',
    ''0'',
    - 1,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    ''MED''
FROM
    exam_items
    limit 1', 2, '[]'::jsonb, '0', '{"applications": [6]}'::jsonb, NULL, 'Medicom検査依頼実績連携', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, '[{"sql_cd": -310009, "field_name": "staff_cd", "replace_var": "@doctorCd"}, {"sql_cd": -310009, "field_name": "user_name", "replace_var": "@doctorName"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317019, '
WITH send_change_flag_info AS (
    SELECT
        UNNEST(string_to_array(COALESCE(
                    NULLIF(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ), '','')) AS SEND_CHANGE_FLAG
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(
                ini.coop_ini_info::json
            ) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = @key0
    AND info ->> ''key1'' = ''ELAPSED_INFO''
    AND info ->> ''key2'' = ''SEND_CHANGE_FLAG''
)
SELECT
    CASE SEND_CHANGE_FLAG
        WHEN ''0'' THEN null
        WHEN ''1'' THEN ''1''
    END
FROM
    send_change_flag_info', 2, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携修正連携スキップ用SQL', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317104, '
with medical_name_info as(
select
	info ->> ''key2'' as key2,
	unnest(string_to_array(coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ), '','')) as VALUE
from
	mst_coop_ini as ini
cross join lateral jsON_array_elements(ini.coop_ini_info ::jsON) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and info ->> ''key0'' = @key0
	and info ->> ''key1'' = ''KARTE_ORD_SEND''
)
select
  ord.rst_treatment_name as e01  --血液浄化法
  ,to_char(ord.rst_start_date,''YYYY/MM/DD'') as e02--透析日
  ,RIGHT(''00''||TRUNC(TO_NUMBER(ord.ind_cond_info->''1''->>''value'',''999999'')/60,0),2)||''時間''||RIGHT(''00''||MOD(TO_NUMBER(ord.ind_cond_info->''1''->>''value'',''999999''),60),2)||''分''as e03--予定時間
  ,to_char(ord.rst_start_date,''YYYY/MM/DD HH24:MI:SS'') as e04--開始時刻
  ,to_char(ord.rst_end_date,''YYYY/MM/DD HH24:MI:SS'') as e05--終了時刻
  ,FLOOR(EXTRACT(EPOCH FROM DATE_TRUNC(''minute'', rst_end_date) - DATE_TRUNC(''minute'', rst_start_date)) / 3600) || ''時間'' ||
   FLOOR(MOD(EXTRACT(EPOCH FROM DATE_TRUNC(''minute'', rst_end_date) - DATE_TRUNC(''minute'', rst_start_date)), 3600) / 60) || ''分'' as e06--透析時間・実績時間
  ,to_number(cast(ord.rst_dialysis_cnt as text), ''FM999999'') as e07--透析回数
  ,to_number(ord.rst_cond_info->''14''->>''value'', ''FM999'') as e08--血流量
  ,to_char(cast(ord.rst_weight_info->>''ctr'' as numeric),''FM9990.00'') as e09--CTR
  ,ord.rst_cond_info->''5''->>''value_name_1'' as e10--ダイアライザ
  ,ord.rst_cond_info->''2''->>''value_name_1'' as e11--ブラッドアクセス・バスキュラーアクセス
  , case (
  	select
  		value
  	from
  		medical_name_info
  	where 
  		key2 = ''MEDICAL_NAME''
	) when ''0'' then coalesce(ord.rst_course_name,(
		select 
			value
		from
			medical_name_info
		where
			key2 = ''FIXED_MEDICAL_NAME''
	))when ''1'' then (
		select 
			value
		from
			medical_name_info
		where
			key2 = ''FIXED_MEDICAL_NAME''		
	)
    end as e12--診療科名
	,ord.rst_cond_info->''25''->>''value_name_1''  as e13--抗凝固剤
	,trim(to_char(to_number(ord.rst_cond_info->''26''->>''value'',''9999.99''),''99990.99''))  as e14--初回注入量
	,trim(to_char(to_number(ord.rst_cond_info->''27''->>''value'',''9999.99''),''99990.99'')) as e15--持続注入量
	,trim(to_char(to_number(ord.rst_cond_info->''28''->>''value'',''9999.99''),''99990.99'')) as e16--持続総量
from 
	ord_main ord
where
	ord.ord_no = @ordNo

', 2, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携治療情報テーブルデータ取得SQL', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317106, '
with admission_info AS(
    SELECT
        UNNEST(string_to_array(
                        info ->> ''value'','','')) AS ADMISSION_VALUE
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(
                ini.coop_ini_info::json
            ) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = @key0
    AND info ->> ''key1'' = ''KARTE_ORD_SEND''
    AND info ->> ''key2'' = ''ADMISSION_SUPPORTED''
),
device_info AS(
    SELECT
        UNNEST(string_to_array(COALESCE(
                    NULLIF(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ), '','')) AS DEVICE_VALUE
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(
                ini.coop_ini_info::json
            ) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = @key0
    AND info ->> ''key1'' = ''KARTE_ORD_SEND''
    AND info ->> ''key2'' = ''DEVICE_IDENTIFICATION_NAME''
)
SELECT
    TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDDHH24MISS'') || CASE ADMISSION_VALUE
        WHEN ''0'' THEN ''.xml''        
        WHEN ''1'' THEN ''_'' || ADMISSION_VALUE || ''_'' || DEVICE_VALUE || ''.xml''
    END AS filename
FROM
    admission_info, device_info', 2, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'Medicomカルテ記載連携(透析経過データ連携)ファイル名取得', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317110, 'WITH pat_info AS(
SELECT
    staff_info ->> ''staff_cd'' AS staff_cd
FROM
    pat_main AS pat
CROSS JOIN
    LATERAL json_array_elements(pat.charge_staff_info::json) staff_info
WHERE
    pat.pat_id = @patId
    AND staff_info ->> ''is_main'' = ''1''
ORDER BY
    (staff_info ->> ''disp_order'')::numeric ASC
LIMIT 1
),
sys_coop_info AS(
  SELECT
    user_id
  FROM
    sys_coop_journal AS sys
  WHERE
    sys.ctl_no = @ctlNo
),
ord_info AS (
    SELECT
        rst_charge_user_info ->> ''user_last_name_1'' AS last_name1,
        rst_charge_user_info ->> ''user_first_name_1'' AS first_name1
    FROM
        ord_main
    WHERE
        ord_no = @ordNo
),
doctor_name_value AS(
SELECT
    info ->> ''key2'' AS key2,
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS VALUE
FROM
    mst_coop_ini AS ini
CROSS JOIN
    LATERAL json_array_elements(ini.coop_ini_info::json) info
WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = @key0
    AND info ->> ''key1'' = ''KARTE_ORD_SEND''
)
SELECT
    (SELECT value FROM doctor_name_value WHERE key2 = ''DOCTOR_NAME_CLASSIFICATION'') AS doctor_name_classification,
    (SELECT user_id FROM sys_coop_info) AS user_id,
    (SELECT CONCAT(last_name1, first_name1) FROM ord_info) AS ord_full_name,
    (SELECT staff_cd FROM pat_info) AS staff_cd,
    (SELECT value FROM doctor_name_value WHERE key2 = ''FIXED_DOCTOR_NAME1'') AS fixed_doctor_name1,
    (SELECT value FROM doctor_name_value WHERE key2 = ''FIXED_DOCTOR_NAME2'') AS fixed_doctor_name2,
    (SELECT value FROM doctor_name_value WHERE key2 = ''FIXED_NURSE_NAME1'') AS fixed_nurse_name1,
    (SELECT value FROM doctor_name_value WHERE key2 = ''FIXED_NURSE_NAME2'') AS fixed_nurse_name2', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携医師名取得事前SQL', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317112, 'with puncture_user_value as(
select
	info ->> ''key2'' as key2,
	unnest(string_to_array(coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ), '','')) as value
from
	mst_coop_ini as ini
cross join
            lateral json_array_elements(
                ini.coop_ini_info::json
            ) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and info ->> ''key0'' = @key0
	and info ->> ''key1'' = ''KARTE_ORD_SEND''
),
puncture_user_info as (
	select
        ord.rst_puncture_user_info ->>''user_last_name_1'' as user_last_name_1,
        ord.rst_puncture_user_info ->>''user_first_name_1'' as user_first_name_1,
        ord.rst_puncture_user_info ->>''user_last_name_2'' as user_last_name_2,
        ord.rst_puncture_user_info ->>''user_first_name_2'' as user_first_name_2
    from
        ord_main as ord
    where
		ord.ord_no = @ordNo
)
select
	case (
		select
			value
		from
			puncture_user_value
		where
			key2 = ''PUNCTURE_USER_CLASSIFICATION''
	)
		when ''0'' then coalesce(
      nullif(
        (select
          user_last_name_1 || user_first_name_1
        from
          puncture_user_info),'''')
      ,(
			  coalesce(nullif(
          (select
            user_last_name_2 || user_first_name_2
          from
            puncture_user_info),'''')
		    ,(
          	select
          		value
			      from
				      puncture_user_value
			      where
				      key2 = ''FIXED_DOCTOR_NAME1''
          )
        )
      )
    )
		when ''1'' then coalesce(
      nullif(
        (select 
          user_last_name_2 || user_first_name_2
        from 
          puncture_user_info),'''')
        ,(
    			select
		    		value
			    from
				    puncture_user_value
			    where
				    key2 = ''FIXED_DOCTOR_NAME1''
		))
		when ''2'' then (
			select
				value
			from
				puncture_user_value
			where
				key2 = ''FIXED_DOCTOR_NAME1''
		)
		when ''3'' then(
			select
				value
			from
				puncture_user_value
			where
				key2 = ''FIXED_DOCTOR_NAME2''
		)
		when ''4'' then(
			select
				value
			from
				puncture_user_value
			where
				key2 = ''FIXED_NURSE_NAME1''
		)
		when ''5'' then(
			select
				value
			from
				puncture_user_value
			where
				key2 = ''FIXED_NURSE_NAME2''
		)
	end as e01', 2, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携穿刺者取得SQL', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317113, '
with return_user_value as(
select
	info ->> ''key2'' as key2,
	unnest(string_to_array(coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ), '','')) as value
from
	mst_coop_ini as ini
cross join
            lateral json_array_elements(
                ini.coop_ini_info::json
            ) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and info ->> ''key0'' = @key0
	and info ->> ''key1'' = ''KARTE_ORD_SEND''
),
return_user_info as (
	select
		ord.rst_return_user_info ->>''user_last_name_1'' as user_last_name_1,
		ord.rst_return_user_info ->>''user_first_name_1'' as user_first_name_1,
		ord.rst_return_user_info ->>''user_last_name_2'' as user_last_name_2,
		ord.rst_return_user_info ->>''user_first_name_2'' as user_first_name_2
	from 
		ord_main as ord
where
	ord.ord_no = @ordNo	
)
select
	case (
		select
			value
		from
			return_user_value
		where
			key2 = ''RECOVERY_USER_CLASSIFICATION''
	)
		when ''0'' then coalesce(
      nullif(
        (select
          user_last_name_1 || user_first_name_1
        from
          return_user_info),'''')
      ,(
		coalesce(nullif(
          (select
            user_last_name_2 || user_first_name_2
          from
            return_user_info),'''')
		    ,(
          	select
          		value
			      from
				      return_user_value
			      where
				      key2 = ''FIXED_DOCTOR_NAME1''
          )
        )
      )
    )
		when ''1'' then coalesce(
      nullif(
        (select 
          user_last_name_2 || user_first_name_2
        from 
          return_user_info),'''')
        ,(
    			select
		    		value
			    from
				    return_user_value
			    where
				    key2 = ''FIXED_DOCTOR_NAME1''
		))
		when ''2'' then (
			select
				value
			from
				return_user_value
			where
				key2 = ''FIXED_DOCTOR_NAME1''
		)
		when ''3'' then(
			select
				value
			from
				return_user_value
			where
				key2 = ''FIXED_DOCTOR_NAME2''
		)
		when ''4'' then(
			select
				value
			from
				return_user_value
			where
				key2 = ''FIXED_NURSE_NAME1''
		)
		when ''5'' then(
			select
				value
			from
				return_user_value
			where
				key2 = ''FIXED_NURSE_NAME2''
		)
	end as e01', 2, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携回収者取得SQL', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317116, '
with blood_value as(
select
	info ->> ''key2'' as key2,
	unnest(string_to_array(coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ), '','')) as VALUE
from
	mst_coop_ini as ini
cross join
            lateral json_array_elements(
                ini.coop_ini_info::json
            ) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and info ->> ''key0'' = @key0
	and info ->> ''key1'' = ''KARTE_ORD_SEND''
)
select
	''血液'' as detail_id,
	case abo
	when ''1'' then (
		select
			value
		from
			blood_value
		where
			key2 = ''BLOOD_TYPE_A''
	)
	when ''2'' then(
		select
			value
		from
			blood_value
		where
			key2 = ''BLOOD_TYPE_B''
	)
	when ''4'' then(
		select
			value
		from
			blood_value
		where
			key2 = ''BLOOD_TYPE_AB''
	)
	when ''3'' then(
		select
			value
		from
			blood_value
		where
			key2 = ''BLOOD_TYPE_O''
	)
	else (
		select
			value
		from
			blood_value
		where
			key2 = ''BLOOD_TYPE_UNKNOWN''
	)
	end as abo,
	case rh
	when ''1'' then(
		select
			value
		from
			blood_value
		where
			key2 = ''BLOOD_TYPE_RH+''
	)
	when ''2'' then(
		select
			value
		from
			blood_value
		where
			key2 = ''BLOOD_TYPE_RH-''
	)
	else (
		select
			value
		from
			blood_value
		where
			key2 = ''BLOOD_TYPE_UNKNOWN''
	)
	end as rh
from
	(
		select
			@blood_type_abo as abo,
			@blood_type_rh as rh
	) as blood_type', 2, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携血液取得SQL', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, '[{"sql_cd": -317115, "field_name": "abo", "replace_var": "@blood_type_abo"}, {"sql_cd": -317115, "field_name": "rh", "replace_var": "@blood_type_rh"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317117, '
with ord_info as (
  select
    rst_charge_user_info ->> ''user_last_name_1'' as last_name1,
    rst_charge_user_info ->> ''user_first_name_1'' as first_name1,
    rst_charge_user_info ->> ''user_last_name_2'' as last_name2,
    rst_charge_user_info ->> ''user_first_name_2'' as first_name2
  from
    ord_main
  where
    ord_no = @ordNo
),
dr_value as(
select
	info ->> ''key2'' as key2,
	unnest(string_to_array(coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ), '','')) as VALUE
from
	mst_coop_ini as ini
cross join
            lateral json_array_elements(
                ini.coop_ini_info::json
            ) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and info ->> ''key0'' = @key0
	and info ->> ''key1'' = ''KARTE_ORD_SEND''
)
select
	(
		select 
			value
		from
			dr_value
		where
			key2 = ''DR1_NAME_CLASSIFICATION''
	) as dr1_name_classification,
	(
		select 
			value
		from
			dr_value
		where
			key2 = ''DR2_NAME_CLASSIFICATION''
	) as dr2_name_classification,
	(
		select 
			value
		from
			dr_value
		where
			key2 = ''DR3_NAME_CLASSIFICATION''
	) as dr3_name_classification,
	(
		select 
			value
		from
			dr_value
		where
			key2 = ''DR4_NAME_CLASSIFICATION''
	) as dr4_name_classification,
	(
		select 
			value
		from
			dr_value
		where
			key2 = ''DR5_NAME_CLASSIFICATION''
	) as dr5_name_classification,
	(
		select
			staff_info ->> ''staff_cd'' as staff_cd
		from
			pat_main as pat
		cross join
            lateral json_array_elements(
                pat.charge_staff_info::json
            ) staff_info
		where
			pat.pat_id = @patId
		and staff_info ->> ''is_main'' = ''1''
		order by
			staff_info ->> ''disp_order'' asc
		limit 1
	) as staff_cd,
	ord.last_name1 || ord.first_name1 as ord_full_name1,
	ord.last_name2 || ord.first_name2 as ord_full_name2,
	(
		select
			value
		from
			dr_value
		where
			key2 = ''FIXED_DOCTOR_NAME1''
	) as fixed_doctor_name1,
	(
		select
			value
		from
			dr_value
		where
			key2 = ''FIXED_DOCTOR_NAME2''
	) as fixed_doctor_name2
from
	ord_info as ord', 2, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携Dr事前取得SQL', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317121, 'WITH mst_coop_ini_info AS (
    SELECT
        info ->> ''key2'' AS key2,
        unnest(
            string_to_array(
                COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v''),
                '',''
            )
        ) AS VALUE
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = @facilityCd
        AND is_del = ''0''
        AND info ->> ''key0'' = @key0
        AND info ->> ''key1'' = ''SEND_COMMENT''
),
pat_event_info AS ( 
    SELECT
        pev.pat_event_cd
    FROM
        pat_event AS pev
    INNER JOIN ord_main AS ord 
        ON pev.event_start_date = ord.treat_date 
        AND ord.pat_id = pev.pat_id 
    WHERE
        pev.use_type = 2 
        AND pev.is_del = ''0'' 
        AND ord.ord_no = @ordNo
        AND pev.category_name = (
            SELECT value FROM mst_coop_ini_info WHERE key2 = ''CATEGORY''
        )
        AND pev.sub_category_name = (
            SELECT value FROM mst_coop_ini_info WHERE key2 = ''SUB_CATEGORY''
        )
)
SELECT 
	pei.pat_event_cd AS pat_event_cd,
    @key0 as key0,
	@patId as patId,
	@facilityCd as facility_cd,
    ''01'' AS detail_id
    
FROM 
    pat_event_info pei;
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携SOAP繰り返し取得SQL', '2025-04-22 17:11:55.638', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317122, 'with mst_coop_ini_info as(
select
	info ->> ''key2'' as key2,
	unnest(string_to_array(coalesce(
				nullif(
				info ->> ''value'',
				''''
			),
			info ->> ''default_v''
	        ), '','')
    ) as VALUE
from
	mst_coop_ini as ini
cross join
	lateral json_array_elements(
		ini.coop_ini_info::json
	) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and info ->> ''key0'' = @key0
	and info ->> ''key1'' = ''SEND_COMMENT2''
),
pat_event_info AS ( 
	SELECT
		pev.pat_event_cd,
		pev.up_date AS up_date,
		pev.reg_staff_info ->> ''reg_staff_name'' AS reg_staff_name,
		pev.input_params,
		pev.result_params
	FROM
		pat_event AS pev
	,	ord_main AS ord 
  WHERE
	pev.event_start_date = ord.treat_date 
	AND ord.pat_id = pev.pat_id 
	AND pev.use_type = 2 
	AND pev.is_del = ''0'' 
	AND ord.ord_no = @ordNo
	AND pev.category_name = (select value from mst_coop_ini_info where key2 = ''CATEGORY'')
	AND pev.sub_category_name = (select value from mst_coop_ini_info where key2 = ''SUB_CATEGORY'')
)
SELECT
	pei.pat_event_cd AS pat_event_cd,
    @key0 as key0,
	@patId as patId,
	@facilityCd as facility_cd,
    ''01'' AS detail_id
FROM
    pat_event_info pei
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携看護メモ取得SQL', '2025-04-22 17:11:55.638', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317123, 'with mst_coop_ini_info as(
select
	info ->> ''key2'' as key2,
	unnest(string_to_array(coalesce(
				nullif(
				info ->> ''value'',
				''''
			),
			info ->> ''default_v''
	        ), '','')
    ) as VALUE
from
	mst_coop_ini as ini
cross join
	lateral json_array_elements(
		ini.coop_ini_info::json
	) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and info ->> ''key0'' = @key0
	and info ->> ''key1'' = ''SEND_COMMENT3''
),
pat_event_info AS ( 
	SELECT
		pev.pat_event_cd,
		pev.up_date AS up_date,
		pev.reg_staff_info ->> ''reg_staff_name'' AS reg_staff_name,
		pev.input_params,
		pev.result_params
	FROM
		pat_event AS pev
	,	ord_main AS ord 
  WHERE
	pev.event_start_date = ord.treat_date 
	AND ord.pat_id = pev.pat_id 
	AND pev.use_type = 2 
	AND pev.is_del = ''0'' 
	AND ord.ord_no = @ordNo
	AND pev.category_name = (select value from mst_coop_ini_info where key2 = ''CATEGORY'')
	AND pev.sub_category_name = (select value from mst_coop_ini_info where key2 = ''SUB_CATEGORY'')
)
SELECT
	pei.pat_event_cd AS pat_event_cd,
    @key0 as key0,
	@patId as patId,
	@facilityCd as facility_cd,
    ''01'' AS detail_id
FROM
    pat_event_info pei
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携問診記録繰り返し取得SQL', '2025-04-22 17:11:55.638', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317124, '
with info as(
select
	info ->> ''key2'' as key2,
	unnest(string_to_array(coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ), '','')) as value
from
	mst_coop_ini as ini
cross join
            lateral json_array_elements(
                ini.coop_ini_info::json
            ) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and info ->> ''key0'' = @key0
	and info ->> ''key1'' = ''KARTE_ORD_SEND''
)
select
	(
		select
			value
		from
			info
		where
			key2 = ''COMMENT''
	) as e01,--入力内容を表すコメント
	(
		select
			value
		from
			info
		where
			key2 = ''MEDICAL_INTERVIEWS_INPUT_DATA_FILE_INFO_ID''
	) as e02,--問診入力データファイル情報ＩＤ
	(
		select
			value
		from
			info
		where
			key2 = ''DESCRIBED_CONTENT_TYPE''
	) as e03--記載内容種別', 2, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携コメント・問診入力データファイル情報ID・記載内容種別取得SQL', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317125, 'with mst_coop_ini_info as(
select
	info ->> ''key2'' as key2,
	unnest(string_to_array(coalesce(
				nullif(
				info ->> ''value'',
				''''
			),
			info ->> ''default_v''
	        ), '','')
    ) as VALUE
from
	mst_coop_ini as ini
cross join
	lateral json_array_elements(
		ini.coop_ini_info::json
	) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and info ->> ''key0'' = @key0
	and info ->> ''key1'' = ''SEND_COMMENT''
),
pat_event_info AS ( 
	SELECT
		pev.pat_event_cd,
		pev.up_date AS up_date,
		pev.reg_staff_info ->> ''reg_staff_name'' AS reg_staff_name,
		pev.input_params,
		pev.result_params
	FROM
		pat_event AS pev
  WHERE
        pev.pat_event_cd = @pat_event_cd
	),
input_row as (
	select
		pei.pat_event_cd,
		ROW_NUMBER() OVER (PARTITION by pei.pat_event_cd) as input_row_no,
		input_params.value
	from
		pat_event_info as pei
	cross join
		lateral json_array_elements(
			pei.input_params::json
		) input_params
),
result_row as (
	select
		pei.pat_event_cd,
		ROW_NUMBER() OVER (PARTITION by pei.pat_event_cd) as result_row_no,
		result_params.value
	from
		pat_event_info as pei
	cross join
		lateral json_array_elements(
			pei.result_params::json
		) result_params
),
s_info as (
	SELECT
		result_row.pat_event_cd,
		(unescape_html(REGEXP_REPLACE(substring(REGEXP_REPLACE(result_row.value ->> ''result_value'' , ''</[p^>]*>'', '''', ''g'') from 1 for length(REGEXP_REPLACE(result_row.value ->> ''result_value'' , ''</[p^>]*>'', '''', ''g''))), ''<[^>]*>'', '''', ''g'')))  AS e01
	FROM
		result_row
	INNER JOIN input_row on
		input_row.pat_event_cd = result_row.pat_event_cd
	AND result_row.result_row_no = input_row.input_row_no
	AND input_row.value ->> ''field_name'' = (select value from mst_coop_ini_info where key2 = ''S_FIELD'')
),
o_info as (
	SELECT
		result_row.pat_event_cd,
		(unescape_html(REGEXP_REPLACE(substring(REGEXP_REPLACE(result_row.value ->> ''result_value'' , ''</[p^>]*>'', '''', ''g'') from 1 for length(REGEXP_REPLACE(result_row.value ->> ''result_value'' , ''</[p^>]*>'', '''', ''g''))), ''<[^>]*>'', '''', ''g'')))  AS e01
	FROM
		result_row
	INNER JOIN input_row on
		input_row.pat_event_cd = result_row.pat_event_cd
	AND result_row.result_row_no = input_row.input_row_no
	AND input_row.value ->> ''field_name'' = (select value from mst_coop_ini_info where key2 = ''O_FIELD'')
),
a_info as (
	SELECT
		result_row.pat_event_cd,
		(unescape_html(REGEXP_REPLACE(substring(REGEXP_REPLACE(result_row.value ->> ''result_value'' , ''</[p^>]*>'', '''', ''g'') from 1 for length(REGEXP_REPLACE(result_row.value ->> ''result_value'' , ''</[p^>]*>'', '''', ''g''))), ''<[^>]*>'', '''', ''g'')))  AS e01
	FROM
		result_row
	INNER JOIN input_row on
		input_row.pat_event_cd = result_row.pat_event_cd
	AND result_row.result_row_no = input_row.input_row_no
	AND input_row.value ->> ''field_name'' = (select value from mst_coop_ini_info where key2 = ''A_FIELD'')
),
p_info as (
	SELECT
		result_row.pat_event_cd,
		(unescape_html(REGEXP_REPLACE(substring(REGEXP_REPLACE(result_row.value ->> ''result_value'' , ''</[p^>]*>'', '''', ''g'') from 1 for length(REGEXP_REPLACE(result_row.value ->> ''result_value'' , ''</[p^>]*>'', '''', ''g''))), ''<[^>]*>'', '''', ''g'')))  AS e01
	FROM
		result_row
	INNER JOIN input_row on
		input_row.pat_event_cd = result_row.pat_event_cd
	AND result_row.result_row_no = input_row.input_row_no
	AND input_row.value ->> ''field_name'' = (select value from mst_coop_ini_info where key2 = ''P_FIELD'')
)
SELECT
	s_info.e01 AS s,
	o_info.e01 AS o,
	a_info.e01 AS a,
	p_info.e01 AS p,
	TO_CHAR(pei.up_date, ''YYYY-MM-DD HH24:MI:SS'') AS up_date,
	pei.reg_staff_name as staff_name
FROM
    pat_event_info pei
INNER JOIN s_info ON
	pei.pat_event_cd = s_info.pat_event_cd
INNER JOIN o_info ON
	pei.pat_event_cd = o_info.pat_event_cd
INNER JOIN a_info ON
	pei.pat_event_cd = a_info.pat_event_cd
INNER JOIN p_info ON
	pei.pat_event_cd = p_info.pat_event_cd
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携SOAP繰り返し取得SQL', '2025-04-22 17:11:55.638', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317126, 'with mst_coop_ini_info as(
select
	info ->> ''key2'' as key2,
	unnest(string_to_array(coalesce(
				nullif(
				info ->> ''value'',
				''''
			),
			info ->> ''default_v''
	        ), '','')
    ) as VALUE
from
	mst_coop_ini as ini
cross join
	lateral json_array_elements(
		ini.coop_ini_info::json
	) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and info ->> ''key0'' = @key0
	and info ->> ''key1'' = ''SEND_COMMENT2''
),
pat_event_info AS ( 
	SELECT
		pev.pat_event_cd,
		pev.up_date AS up_date,
		pev.reg_staff_info ->> ''reg_staff_name'' AS reg_staff_name,
		pev.input_params,
		pev.result_params
	FROM
		pat_event AS pev
  WHERE
        pev.pat_event_cd = @pat_event_cd
  ),
input_row as (
	select
		pei.pat_event_cd,
		ROW_NUMBER() OVER (PARTITION by pei.pat_event_cd) as input_row_no,
		input_params.value
	from
		pat_event_info as pei
	cross join
		lateral json_array_elements(
			pei.input_params::json
		) input_params
),
result_row as (
	select
		pei.pat_event_cd,
		ROW_NUMBER() OVER (PARTITION by pei.pat_event_cd) as result_row_no,
		result_params.value
	from
		pat_event_info as pei
	cross join
		lateral json_array_elements(
			pei.result_params::json
		) result_params
),
nursing_notes_info as (
	SELECT
		result_row.pat_event_cd,
		(unescape_html(REGEXP_REPLACE(substring(REGEXP_REPLACE(result_row.value ->> ''result_value'' , ''</[p^>]*>'', '''', ''g'') from 1 for length(REGEXP_REPLACE(result_row.value ->> ''result_value'' , ''</[p^>]*>'', '''', ''g''))), ''<[^>]*>'', '''', ''g'')))  AS e01
	FROM
		result_row
	INNER JOIN input_row on
		input_row.pat_event_cd = result_row.pat_event_cd
	AND result_row.result_row_no = input_row.input_row_no
	AND input_row.value ->> ''field_name'' = (select value from mst_coop_ini_info where key2 = ''FIELD'')
)
SELECT
	nursing_notes_info.e01,
	TO_CHAR(pei.up_date, ''YYYY-MM-DD HH24:MI:SS'') AS up_date,
	pei.reg_staff_name as staff_name
FROM
    pat_event_info pei
INNER JOIN nursing_notes_info ON
	pei.pat_event_cd = nursing_notes_info.pat_event_cd', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携看護メモ録取得SQL', '2025-04-22 17:11:55.638', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317127, 'with mst_coop_ini_info as(
select
	info ->> ''key2'' as key2,
	unnest(string_to_array(coalesce(
				nullif(
				info ->> ''value'',
				''''
			),
			info ->> ''default_v''
	        ), '','')
    ) as VALUE
from
	mst_coop_ini as ini
cross join
	lateral json_array_elements(
		ini.coop_ini_info::json
	) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and info ->> ''key0'' = @key0
	and info ->> ''key1'' = ''SEND_COMMENT3''
),
pat_event_info AS ( 
	SELECT
		pev.pat_event_cd,
		pev.up_date AS up_date,
		pev.reg_staff_info ->> ''reg_staff_name'' AS reg_staff_name,
		pev.input_params,
		pev.result_params
	FROM
		pat_event AS pev
  WHERE
        pev.pat_event_cd = @pat_event_cd
),
input_row as (
	select
		pei.pat_event_cd,
		ROW_NUMBER() OVER (PARTITION by pei.pat_event_cd) as input_row_no,
		input_params.value
	from
		pat_event_info as pei
	cross join
		lateral json_array_elements(
			pei.input_params::json
		) input_params
),
result_row as (
	select
		pei.pat_event_cd,
		ROW_NUMBER() OVER (PARTITION by pei.pat_event_cd) as result_row_no,
		result_params.value
	from
		pat_event_info as pei
	cross join
		lateral json_array_elements(
			pei.result_params::json
		) result_params
),
interview_record_info as (
	SELECT
		result_row.pat_event_cd,
		(unescape_html(REGEXP_REPLACE(substring(REGEXP_REPLACE(result_row.value ->> ''result_value'' , ''</[p^>]*>'', '''', ''g'') from 1 for length(REGEXP_REPLACE(result_row.value ->> ''result_value'' , ''</[p^>]*>'', '''', ''g''))), ''<[^>]*>'', '''', ''g'')))  AS e01
	FROM
		result_row
	INNER JOIN input_row on
		input_row.pat_event_cd = result_row.pat_event_cd
	AND result_row.result_row_no = input_row.input_row_no
	AND input_row.value ->> ''field_name'' = (select value from mst_coop_ini_info where key2 = ''FIELD'')
)
SELECT
	interview_record_info.e01,
	TO_CHAR(pei.up_date, ''YYYY-MM-DD HH24:MI:SS'') AS up_date,
	pei.reg_staff_name as staff_name
FROM
    pat_event_info pei
INNER JOIN interview_record_info ON
	pei.pat_event_cd = interview_record_info.pat_event_cd', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携問診記録取得SQL', '2025-04-22 17:11:55.638', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317140, 'with mst_coop_ini_info as(
select
	info ->> ''key2'' as key2,
	unnest(string_to_array(coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ), '','')) as VALUE
from
	mst_coop_ini as ini
cross join
            lateral json_array_elements(
                ini.coop_ini_info::json
            ) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and info ->> ''key0'' = @key0
	and info ->> ''key1'' = ''KARTE_ORD_SEND''
)
select
	(
	select
		value
	from
		mst_coop_ini_info
	where
		key2 = ''ADMISSION_SUPPORTED''
	) as admission_supported,
	(
	select
		value
	from
		mst_coop_ini_info
	where
		key2 = ''ELAPSED_DATA_OUTPUT''
	) as elapsed_data_output
', 2, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携出力有無事前取得用SQL', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
DELETE FROM sys_data_set WHERE sql_cd IN 
(-1105000);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1105000, 'WITH exam_data AS(
  --登録時検査日時と透析前後フラグの取得
    SELECT
    CASE reg_order_class
        WHEN ''1'' THEN ''1''
        WHEN ''2'' THEN ''2''
        ELSE ''0''
    END AS exam_timing_flag,
    to_char(reg_exam_date, ''YYYY-MM-DD'') as reg_exam_date
    FROM
        ntss.pat_exam_main
    WHERE
        exam_main_cd = @ordNo
        AND facility_cd = @facilityCd
    limit 1
)
, coop_ini_info AS (
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value,
        info ->> ''key1'' AS key1,
        info ->> ''key2'' AS key2
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE
        ini.facility_cd = @facilityCd
        AND ini.is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' in(
            ''SCM_EXAM_ORDER_SEND'',
            ''SCM_COMMON''
        ) 
)
, staff_cd_list AS (
  --担当医の取得
    SELECT
        users ->> ''disp_user_id'' AS disp_user_id,
        ROW_NUMBER() OVER(ORDER BY staff_info ->> ''disp_order'') AS row_no
    FROM
        pat_main pm
    CROSS JOIN jsonb_array_elements(pm.charge_staff_info) AS staff_info
    LEFT JOIN jsonb_array_elements(@userList) AS users ON
        staff_info ->> ''staff_cd'' = users ->> ''user_id''
    WHERE
        pm.facility_cd = @facilityCd
        AND pm.pat_id = @patId
        AND pm.is_del = ''0''
        AND staff_info ->> ''is_main'' = ''1''
)
, exam_staff_cd AS (
  --指示者の取得
    SELECT
        users ->> ''disp_user_id'' AS disp_user_id
    FROM
        pat_exam_main pem
    LEFT JOIN jsonb_array_elements(@userList) AS users ON
        pem.ind_user_id = (users ->> ''user_id'')::numeric
    WHERE
        pem.facility_cd = @facilityCd
        AND pem.exam_main_cd = @ordNo
        AND pem.is_del = ''0''
)
, in_hosp_code AS (
    --検体検査マスタの院内コード参照先
	SELECT
		coalesce(
			nullif(info ->> ''value'', ''''),
			info ->> ''default_v''
		) AS value
	FROM
		mst_coop_ini AS ini
		CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info
	WHERE
		facility_cd = @facilityCd
		AND is_del = ''0''
		AND coalesce(info ->> ''key0'', '''') = @key0
		AND info ->> ''key1'' = ''SCM_EXAM_ORDER_SEND''
		AND info ->> ''key2'' = ''IN_HOSP_CODE''
)
, in_hosp_code_set AS (
	--検体検査マスタの院内コード参照先
	SELECT
		coalesce(
			nullif(info ->> ''value'', ''''),
			info ->> ''default_v''
		) AS value
	FROM
		mst_coop_ini AS ini
		CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info
	WHERE
		facility_cd = @facilityCd
		AND is_del = ''0''
		AND coalesce(info ->> ''key0'', '''') = @key0
		AND info ->> ''key1'' = ''SCM_EXAM_ORDER_SEND''
		AND info ->> ''key2'' = ''IN_HOSP_CODE_SET''
)
, exam_set_count AS (
  --項目数の取得（250まで）
    SELECT --検査項目
        1
    FROM
        pat_exam_main pem
        CROSS JOIN jsonb_array_elements(pem.order_exam_set_info) AS set_info
        LEFT JOIN mst_exam_set mes ON set_info ->> ''set_cd'' = mes.exam_set_cd::text
        CROSS JOIN jsonb_array_elements(mes.exam_item_info) AS item_info
        LEFT JOIN mst_exam_item mei ON item_info ->> ''exam_item_cd'' = mei.exam_item_cd::text
    WHERE
        pem.facility_cd = @facilityCd
        AND pem.pat_id = @patId
        AND pem.exam_main_cd = @ordNo
        AND pem.is_del = ''0''
        AND NULLIF((CASE (SELECT value FROM in_hosp_code_set)
            WHEN ''1'' THEN mes.in_hospital_cd1
            WHEN ''2'' THEN mes.in_hospital_cd2
            WHEN ''3'' THEN mes.in_hospital_cd3
            ELSE mes.in_hospital_cd1
            END), '''') IS NOT NULL
        AND NULLIF((CASE (SELECT value FROM in_hosp_code)
            WHEN ''1'' THEN mei.in_hospital_cd1
            WHEN ''2'' THEN mei.in_hospital_cd2
            WHEN ''3'' THEN mei.in_hospital_cd3
            ELSE mei.in_hospital_cd1
            END), '''') IS NOT NULL
    UNION ALL
    SELECT --検査セット
        1
    FROM
        pat_exam_main pem
        CROSS JOIN jsonb_array_elements(pem.order_exam_set_info) AS set_info
        LEFT JOIN mst_exam_set mes ON set_info ->> ''set_cd'' = mes.exam_set_cd::text
    WHERE
        pem.facility_cd = @facilityCd
        AND pem.pat_id = @patId
        AND pem.exam_main_cd = @ordNo
        AND pem.is_del = ''0''
        AND LEFT(CASE (SELECT value::numeric FROM in_hosp_code_set)
            WHEN 1 THEN mes.in_hospital_cd1
            WHEN 2 THEN mes.in_hospital_cd2
            WHEN 3 THEN mes.in_hospital_cd3
        END, 1) = ''S''
    LIMIT 250
)
SELECT
    exam_timing_flag,
    reg_exam_date,
    LEFT((SELECT value FROM coop_ini_info WHERE key1 = ''SCM_EXAM_ORDER_SEND'' AND key2 = ''EXAM_IDX_TITLE''), 60) AS title,
    (SELECT COUNT(*) FROM exam_set_count) AS exam_set_cnt,
    RIGHT(
        case (SELECT value::numeric FROM coop_ini_info WHERE key1 = ''SCM_EXAM_ORDER_SEND'' AND key2 = ''USER_ID_FLAG'')
        when 0 then 
            (select disp_user_id from exam_staff_cd)
        when 1 then 
            coalesce(
            (select disp_user_id from staff_cd_list where row_no = 1),
            (select disp_user_id from staff_cd_list where row_no = 2),
            (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''DEFAULT_DOCTOR''),
            ''''
            )
        end
    ,6) as user_id
FROM
    exam_data', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Secom連携_検体検査オーダー連携', '2025-07-17 09:48:31.871', CURRENT_TIMESTAMP, '[{"sql_cd": -1100003, "field_name": "user_list", "replace_var": "@userList"}]'::jsonb);

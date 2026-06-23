delete from "ntss"."sys_data_set" where "sql_cd" in (-9);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-9, 'WITH default_user_no AS (-- デフォルト利用者番号（透析実績用)
    SELECT
        0 AS order_no,
        COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS staff_cd 
    FROM
        mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
    WHERE
        facility_cd = @facilityCd 
        AND is_del = ''0'' 
        AND info ->> ''key1'' = ''FJI_COM_INFO'' 
        AND info ->> ''key2'' = ''DIAL_DEFAULT_USER_NO'' UNION
    SELECT
        1 AS order_no,
        '''' AS staff_cd 
    ORDER BY
        order_no ASC 
        LIMIT 1 
    ),
    user_no_setting AS (-- 利用者番号出力設定（透析実績用）
    SELECT
        0 AS order_no,
        COALESCE ( NULLIF ( info ->> ''value'', '''' ), COALESCE ( NULLIF ( info ->> ''default_v'', '''' ), ''0'' ) ) AS setting 
    FROM
        mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
    WHERE
        facility_cd = @facilityCd 
        AND is_del = ''0'' 
        AND info ->> ''key1'' = ''FJI_COM_INFO'' 
        AND info ->> ''key2'' = ''DIAL_USER_NO_SETTING'' UNION
    SELECT
        1 AS order_no,
        ''0'' AS setting 
    ORDER BY
        order_no ASC 
        LIMIT 1 
    ),
    up_user_id_info AS (-- 版確定者
    SELECT
        0 AS order_no,
        NULLIF ( TO_CHAR( om.up_user_id, ''FM9999999999'' ), '''' ) AS staff_cd 
    FROM
        ord_main om 
    WHERE
        om.ord_no = @ordNo 
    ),
    staff_user_info AS (-- 担当医
    SELECT
        1 AS order_no,
        NULLIF ( staff ->> ''staff_cd'', '''' ) AS staff_cd 
    FROM
        pat_main pm
        CROSS JOIN LATERAL json_array_elements ( pm.charge_staff_info :: json ) staff 
    WHERE
        staff ->> ''is_main'' = ''1'' 
        AND pm.pat_id =@patId 
    ORDER BY
        staff ->> ''disp_order'' 
    ) SELECT 
    COALESCE( NULLIF ( MAX ( CASE part WHEN ''comm'' THEN staff_cd ELSE'''' END ), '''' ), '''' ) ||''%%%''||  ( SELECT staff_cd FROM default_user_no )  as staff_cd_comm,
    COALESCE( NULLIF ( MAX ( CASE part WHEN ''data'' THEN staff_cd ELSE'''' END ), '''' ), '''' ) ||''%%%''||  ( SELECT staff_cd FROM default_user_no )  as staff_cd_data 
FROM
    (-- 0：共通部 版確定者
     -- 3：共通部 版確定者
     -- 4：共通部 版確定者
      SELECT ''comm'' AS part, staff_cd  FROM up_user_id_info WHERE ( SELECT setting FROM user_no_setting ) in (''0'', ''3'',''4'')
     -- 1：共通部 担当医１
    UNION
     -- 2：共通部 担当医２
    ( SELECT ''comm'' AS part, staff_cd FROM staff_user_info WHERE ( SELECT setting FROM user_no_setting ) = ''1'' LIMIT 1 OFFSET 0 ) UNION
    ( SELECT ''comm'' AS part, staff_cd FROM staff_user_info WHERE ( SELECT setting FROM user_no_setting ) = ''2'' LIMIT 1 OFFSET 1 ) UNION
    -- 0：共通部 版確定者
      SELECT ''data'' AS part, staff_cd  FROM up_user_id_info  WHERE ( SELECT setting FROM user_no_setting ) =''0'' 	UNION
    -- 1：内容部 担当医１
    -- 3：内容部 担当医１
    ( SELECT ''data'' AS part, staff_cd FROM staff_user_info WHERE ( SELECT setting FROM user_no_setting ) IN ( ''1'', ''3'' )  LIMIT 1 OFFSET 0 ) UNION
    -- 5：内容部 担当医２
    ( SELECT ''data'' AS part, staff_cd FROM staff_user_info WHERE ( SELECT setting FROM user_no_setting ) IN ( ''2'', ''4'' )  LIMIT 1 OFFSET 1 ) 
    ) AS T', 2, '[{}]', '0', '{"applications": [4]}', NULL, '（実績）利用者番号出力設定', CURRENT_TIMESTAMP,CURRENT_TIMESTAMP, NULL);


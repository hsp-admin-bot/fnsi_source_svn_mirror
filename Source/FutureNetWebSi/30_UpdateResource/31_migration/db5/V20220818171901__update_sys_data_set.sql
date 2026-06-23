delete from ntss.sys_data_set where sql_cd in (-61,-68);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-61, 'WITH default_user_no AS (-- デフォルト利用者番号（透析実績用)
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
    ) 
SELECT  
         ( SELECT staff_cd FROM default_user_no ) as default_user_no,
        COALESCE( NULLIF ( MAX ( CASE part WHEN ''comm'' THEN staff_cd ELSE'''' END ), '''' ))  as staff_cd_comm,
        COALESCE( NULLIF ( MAX ( CASE part WHEN ''comm'' THEN staff_cd ELSE'''' END ), '''' ))  as staff_name_comm,
        COALESCE( NULLIF ( MAX ( CASE part WHEN ''data'' THEN staff_cd ELSE'''' END ), '''' ))  as staff_cd_data,
        COALESCE( NULLIF ( MAX ( CASE part WHEN ''data'' THEN staff_cd ELSE'''' END ), '''' ))  as staff_name_data
FROM
    (
		 -- 0：共通部 版確定者
    ( SELECT ''comm'' AS part, staff_cd FROM up_user_id_info WHERE ( SELECT setting FROM user_no_setting ) IN (''0'') LIMIT 1 OFFSET 0 )
    UNION
     -- 1：共通部 担当医１
     -- 3：共通部 担当医１
    ( SELECT ''comm'' AS part, staff_cd FROM staff_user_info WHERE ( SELECT setting FROM user_no_setting ) IN (''1'') LIMIT 1 OFFSET 0 ) 
		UNION
		-- 3：共通部 版確定者
    ( SELECT ''comm'' AS part, staff_cd FROM up_user_id_info WHERE ( SELECT setting FROM user_no_setting ) IN (''3'') LIMIT 1 OFFSET 0 ) 
		  UNION

     -- 2：共通部 担当医２
		( SELECT ''comm'' AS part, staff_cd FROM staff_user_info WHERE ( SELECT setting FROM user_no_setting ) IN (''2'') LIMIT 1 OFFSET 1 ) 
		  UNION
		-- 4：共通部 版確定者
    ( SELECT ''comm'' AS part, staff_cd FROM up_user_id_info WHERE ( SELECT setting FROM user_no_setting ) IN (''4'') LIMIT 1 OFFSET 0 ) 
			UNION
    -- 0：内容部 版確定者
    ( SELECT ''data'' AS part, staff_cd FROM up_user_id_info WHERE ( SELECT setting FROM user_no_setting ) IN (''0'') LIMIT 1 OFFSET 0 )
			UNION
    -- 1：内容部 担当医１
		( SELECT ''data'' AS part, staff_cd FROM staff_user_info WHERE ( SELECT setting FROM user_no_setting ) IN (''1'')  LIMIT 1 OFFSET 0 )      
		UNION
    -- 3：内容部 担当医１
    ( SELECT ''data'' AS part, staff_cd FROM staff_user_info WHERE ( SELECT setting FROM user_no_setting ) IN (''3'')  LIMIT 1 OFFSET 0 )      
		UNION
    -- 2：内容部 担当医２
		( SELECT ''data'' AS part, staff_cd FROM staff_user_info WHERE ( SELECT setting FROM user_no_setting ) IN (''2'')  LIMIT 1 OFFSET 1 ) 
    UNION
    -- 4：内容部 担当医２
    ( SELECT ''data'' AS part, staff_cd FROM staff_user_info WHERE ( SELECT setting FROM user_no_setting ) IN (''4'')  LIMIT 1 OFFSET 1 ) 
    ) AS T ', 2, '[{}]', '0', '{"applications": [4]}', NULL, '（実績）「利用者番号」に設定する値の取得', '2022-03-16 08:52:30.73', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-68, '(SELECT 
 0 AS order_no,
disp_user_id   AS disp_user_id 
FROM 
    mst_user_authentication 
WHERE 
    user_id ::text= @userId)
UNION
(SELECT
 1 AS order_no,
@default_user_no as disp_user_id ) 
ORDER BY order_no ASC LIMIT 1
', 1, '[{}]', '0', '{"applications": [4]}', NULL, '富士通）透析レポート：施設内職員ID取得', '2022-05-02 13:29:18.288', CURRENT_TIMESTAMP, '[{"sql_cd": -61, "field_name": "staff_cd_comm", "replace_var": "@userId"}, {"sql_cd": -61, "field_name": "default_user_no", "replace_var": "@default_user_no"}]');

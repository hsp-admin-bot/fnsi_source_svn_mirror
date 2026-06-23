delete from ntss.sys_data_set where sql_cd = '-44';
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-44, 'WITH default_user_no AS (
    -- デフォルト利用者番号（検査オーダ用）
    SELECT 0                                                            AS order_no
         , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
    FROM mst_coop_ini AS ini
             CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE facility_cd = @facilityCd
      AND is_del = ''0''
      AND info ->> ''key1'' = ''FJI_COM_INFO''
      AND info ->> ''key2'' = ''EXAM_DEFAULT_USER_NO''
    UNION
    SELECT 1  AS order_no
         , '''' AS staff_cd
    ORDER BY order_no ASC
    LIMIT 1)
   , user_no_setting AS (
    -- 利用者番号出力設定（検査オーダ用）
    SELECT 0                                                                                       AS order_no
         , COALESCE(NULLIF(info ->> ''value'', ''''), COALESCE(NULLIF(info ->> ''default_v'', ''''), ''0'')) AS setting
    FROM mst_coop_ini AS ini
             CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE facility_cd = @facilityCd
      AND is_del = ''0''
      AND info ->> ''key1'' = ''FJI_COM_INFO''
      AND info ->> ''key2'' = ''EXAM_USER_NO_SETTING''
    UNION
    SELECT 1   AS order_no
         , ''0'' AS setting
    ORDER BY order_no ASC
    LIMIT 1)
   , ind_user_info AS (
    -- 指示者
    SELECT TO_CHAR(pem.ind_user_id, ''FM9999999999'') AS staff_cd
    FROM pat_exam_main_hst pem
    WHERE pem.exam_main_cd = @ordNo
      AND pem.ind_user_id IS NOT NULL)
   , staff_user_info AS (
    -- 担当者
    SELECT ROW_NUMBER() OVER () AS CNT
         , staff ->> ''staff_cd'' AS staff_cd
    FROM pat_main pm
             CROSS JOIN LATERAL json_array_elements(pm.charge_staff_info ::json) staff
    WHERE pm.is_del = ''0''
      AND pm.pat_id = @patId
      AND staff ->> ''is_main'' = ''1'')
   , up_user_info AS (
    -- 操作者
    SELECT TO_CHAR(pem.up_staff, ''FM9999999999'') AS staff_cd
    FROM pat_exam_main_hst pem
    WHERE pem.exam_main_cd = @ordNo
      AND pem.up_staff IS NOT NULL)
SELECT NULLIF(MAX(CASE part WHEN ''comm'' THEN staff_cd ELSE '''' END), '''') AS staff_cd_comm
     , NULLIF(MAX(CASE part WHEN ''data'' THEN staff_cd ELSE '''' END), '''') AS staff_cd_data
     , (SELECT staff_cd FROM default_user_no)                           AS default_user_no
FROM (SELECT ''comm'' AS part, staff_cd
      FROM ind_user_info
      WHERE (SELECT setting FROM user_no_setting) = ''0''
      UNION
      SELECT ''comm'' AS part, staff_cd
      FROM staff_user_info
      WHERE (SELECT setting FROM user_no_setting) = ''1''
        AND CNT = 1
      UNION
      SELECT ''comm'' AS part, staff_cd
      FROM staff_user_info
      WHERE (SELECT setting FROM user_no_setting) = ''2''
        AND CNT = 2
      UNION
      SELECT ''comm'' AS part, staff_cd
      FROM up_user_info
      WHERE (SELECT setting FROM user_no_setting) IN (''3'', ''4'', ''5'')
      UNION
      SELECT ''data'' AS part, staff_cd
      FROM ind_user_info
      WHERE (SELECT setting FROM user_no_setting) in (''0'', ''3'')
      UNION
      SELECT ''data'' AS part, staff_cd
      FROM staff_user_info
      WHERE (SELECT setting FROM user_no_setting) IN (''1'', ''4'')
        AND CNT = 1
      UNION
      SELECT ''data'' AS part, staff_cd
      FROM staff_user_info
      WHERE (SELECT setting FROM user_no_setting) IN (''2'', ''5'')
        AND CNT = 2) AS T', 2, '[{}]', '0', '{"applications": [4]}', null, '富士通）検査依頼者 ★削除用', '2022-01-17 15:02:47.000', CURRENT_TIMESTAMP, null);

delete from "sys_data_set" where sql_cd = -8;
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-8, 'WITH default_user_no AS (
  -- デフォルト利用者番号（透析予約用）
  SELECT
    0 AS order_no
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''FJI_COM_INFO'' 
    AND info ->> ''key2'' = ''SCH_DEFAULT_USER_NO''
  UNION
  SELECT
    1 AS order_no
    , '''' AS staff_cd
  ORDER BY order_no ASC LIMIT 1
)
, user_no_setting AS (
  -- 利用者番号出力設定（透析予約用）
  SELECT
    0 AS order_no
    , COALESCE(NULLIF(info ->> ''value'', ''''), COALESCE(NULLIF(info ->> ''default_v'', ''''), ''0'')) AS setting 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''FJI_COM_INFO'' 
    AND info ->> ''key2'' = ''SCH_USER_NO_SETTING''
  UNION
  SELECT
    1 AS order_no
    , ''0'' AS setting
  ORDER BY order_no ASC LIMIT 1
)
, ind_upd_user_info AS(
  -- 指示者
  -- 操作者
  SELECT
    0 AS order_no
    , om.ind_schedule_user_info ->> ''ind_user_id'' AS ind_staff_cd 
    , om.ind_schedule_user_info ->> ''upd_user_id'' AS upd_staff_cd 
  FROM
    ord_main AS om
  WHERE
    om.ord_no = @ordNo 
    AND om.facility_cd = @facilityCd 
    AND om.is_del = ''0'' 
  UNION 
  SELECT
    1 AS order_no
    , ind_cond_info ->> ''ind_user_id'' AS ind_staff_cd 
    , ind_cond_info ->> ''upd_user_id'' AS upd_staff_cd 
  FROM
    (SELECT
       om.ind_cond_info -> jsonb_object_keys(om.ind_cond_info) AS ind_cond_info 
     FROM
       ord_main AS om 
     WHERE
       om.ord_no = @ordNo 
     AND om.facility_cd = @facilityCd 
     AND om.is_del = ''0'' 
     LIMIT 1 ) AS T
  UNION 
  SELECT
    2 AS order_no
    , info ->> ''ind_user_id'' AS ind_staff_cd 
    , info ->> ''upd_user_id'' AS upd_staff_cd 
  FROM
    ord_main AS om
    CROSS JOIN LATERAL json_array_elements(om.ind_medi_info ::json) info 
  WHERE
    om.ord_no = @ordNo 
  AND om.facility_cd = @facilityCd 
  AND om.is_del = ''0'' 
  UNION
  SELECT
    3 AS order_no
    , info ->> ''ind_user_id'' AS ind_staff_cd 
    , info ->> ''upd_user_id'' AS upd_staff_cd 
  FROM
    ord_main AS om
    CROSS JOIN LATERAL json_array_elements(om.ind_equip_info ::json) info 
  WHERE
    om.ord_no = @ordNo 
  AND om.facility_cd = @facilityCd 
  AND om.is_del = ''0'' 
  UNION
  SELECT
    4 AS order_no
    , info ->> ''ind_user_id'' AS ind_staff_cd 
    , info ->> ''upd_user_id'' AS upd_staff_cd 
  FROM
    ord_main AS om
    CROSS JOIN LATERAL json_array_elements(om.ind_ind_comment_info ::json) info 
  WHERE
    om.ord_no = @ordNo 
    AND om.facility_cd = @facilityCd 
    AND om.is_del = ''0'' 
  ORDER BY order_no ASC LIMIT 1
)
, staff_user_info AS(
  -- 担当者
  SELECT
    ROW_NUMBER() OVER (ORDER BY staff ->> ''is_main'' DESC, staff ->> ''is_charge'' DESC, staff ->> ''is_puncture'' DESC, staff ->> ''ctl_no'' ASC) AS CNT
    , staff ->> ''staff_cd'' AS staff_cd 
  FROM
    pat_main pm 
    CROSS JOIN LATERAL json_array_elements(pm.charge_staff_info ::json) staff 
  WHERE
    pm.is_del = ''0'' 
    AND pm.pat_id = @patId 
    AND staff ->> ''is_main'' = ''1'' 
)
SELECT
  COALESCE(NULLIF(MAX(CASE part WHEN ''comm'' THEN staff_cd ELSE '''' END), ''''), (SELECT staff_cd FROM default_user_no)) staff_cd_comm
  , COALESCE(NULLIF(MAX(CASE part WHEN ''data'' THEN staff_cd ELSE '''' END), ''''), (SELECT staff_cd FROM default_user_no)) staff_cd_data 
FROM
  ( 
    -- 0：共通部 指示者
    SELECT ''comm'' AS part, ind_staff_cd AS staff_cd FROM ind_upd_user_info WHERE (SELECT setting FROM user_no_setting) = ''0''
    -- 1：共通部 担当医１
    -- 4：共通部 操作者
    UNION 
    SELECT ''comm'' AS part, staff_cd FROM staff_user_info WHERE (SELECT setting FROM user_no_setting) IN (''1'', ''4'') AND CNT = 1
    -- 2：共通部 担当医２
    -- 5：共通部 操作者
    UNION 
    SELECT ''comm'' AS part, staff_cd FROM staff_user_info WHERE (SELECT setting FROM user_no_setting) IN (''2'', ''5'') AND CNT = 2
    -- 3：共通部 操作者
    UNION 
    SELECT ''comm'' AS part, upd_staff_cd AS staff_cd FROM ind_upd_user_info WHERE (SELECT setting FROM user_no_setting) = ''3''

    -- 0：内容部 指示者
    -- 3：内容部 指示者
    UNION 
    SELECT ''data'' AS part, ind_staff_cd AS staff_cd FROM ind_upd_user_info WHERE (SELECT setting FROM user_no_setting) IN (''0'', ''3'')
    -- 1：内容部 担当医１
    -- 4：内容部 担当医１
    UNION 
    SELECT ''data'' AS part, staff_cd FROM staff_user_info WHERE (SELECT setting FROM user_no_setting) IN (''1'', ''4'') AND CNT = 1
    -- 2：内容部 担当医２
    -- 5：内容部 担当医２
    UNION 
    SELECT ''data'' AS part, staff_cd FROM staff_user_info WHERE (SELECT setting FROM user_no_setting) IN (''2'', ''5'') AND CNT = 2
  ) AS T', 2, '[{}]', '0', '{"applications": [4]}', NULL, '富士通）透析予約：共通部と伝票情報の利用者番号取得', '2022-02-28 14:34:34.866', CURRENT_TIMESTAMP, NULL);

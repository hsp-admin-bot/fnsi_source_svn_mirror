DELETE FROM ntss.sys_data_set
WHERE sql_cd=9105;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(9105, 'WITH infection_nec_sub AS ( 
  -- NECから、感染症情報
  SELECT
    1 AS order_no
    , ''@infectInfo1'' AS CONTENT
  UNION 
  SELECT
    2 AS order_no
    , ''@infectInfo2'' AS CONTENT
  UNION 
  SELECT
    3 AS order_no
    , ''@infectInfo3'' AS CONTENT
  UNION 
  SELECT
    4 AS order_no
    , ''@infectInfo4'' AS CONTENT
  UNION 
  SELECT
    5 AS order_no
    , ''@infectInfo5'' AS CONTENT
  UNION 
  SELECT
    6 AS order_no
    , ''@infectInfo6'' AS CONTENT
  UNION 
  SELECT
    7 AS order_no
    , ''@infectInfo7'' AS CONTENT
  UNION 
  SELECT
    8 AS order_no
    , ''@infectInfo8'' AS CONTENT
  UNION 
  SELECT
    9 AS order_no
    , ''@infectInfo9'' AS CONTENT
  UNION 
  SELECT
    10 AS order_no
    , ''@infectInfo10'' AS CONTENT
  UNION 
  SELECT
    11 AS order_no
    , ''@infectInfo11'' AS CONTENT
  UNION 
  SELECT
    12 AS order_no
    , ''@infectInfo12'' AS CONTENT
  UNION 
  SELECT
    13 AS order_no
    , ''@infectInfo13'' AS CONTENT
  UNION 
  SELECT
    14 AS order_no
    , ''@infectInfo14'' AS CONTENT
  UNION 
  SELECT
    15 AS order_no
    , ''@infectInfo15'' AS CONTENT
  UNION 
  SELECT
    16 AS order_no
    , ''@infectInfo16'' AS CONTENT
  UNION 
  SELECT
    17 AS order_no
    , ''@infectInfo17'' AS CONTENT
  UNION 
  SELECT
    18 AS order_no
    , ''@infectInfo18'' AS CONTENT
  UNION 
  SELECT
    19 AS order_no
    , ''@infectInfo19'' AS CONTENT
  UNION 
  SELECT
    20 AS order_no
    , ''@infectInfo20'' AS CONTENT
  ORDER BY
    order_no ASC
) 
, infection_ini AS ( 
  SELECT
    TO_NUMBER( 
      REPLACE (ini_info ->> ''key2'', ''INFECT_'', '''')
      , ''FM99''
    ) AS order_no
    , CASE 
      WHEN NULLIF(ini_info ->> ''value'', '''') IS NULL 
        THEN ini_info ->> ''default_v'' 
      ELSE ini_info ->> ''value'' 
      END AS hospital_cd 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.facility_cd = ''@facilityCd'' 
    AND is_del = ''0''
    AND ini_info ->> ''key1'' = ''NEC'' 
    AND ini_info ->> ''key2'' LIKE ''INFECT_%'' 
  ORDER BY
    TO_NUMBER( 
      REPLACE (ini_info ->> ''key2'', ''INFECT_'', '''')
      , ''FM99''
    ) ASC
) 
, infection_nec AS ( 
  SELECT
    ini.hospital_cd
    , CASE sub.CONTENT 
      WHEN ''+'' THEN ''2'' 
      WHEN ''-'' THEN ''1''  
      ELSE ''0'' 
      END AS CONTENT 
  FROM
    infection_nec_sub AS sub 
    INNER JOIN infection_ini AS ini 
      ON sub.order_no = ini.order_no
) 
, infection_ntss AS ( 
  SELECT
    A.infection_cd
    , A.in_hospital_cd_1 AS hospital_cd 
  FROM
    mst_infection A
    , ( 
      SELECT
        mss.facility_cd
        , ms.*
        , ROW_NUMBER() OVER () AS INDEX 
      FROM
        mst_selector mss 
        CROSS JOIN LATERAL jsonb_to_recordset(mss.order_settings -> ''items'') AS ms(code BIGINT, NAME TEXT) 
      WHERE
        facility_cd = ''@facilityCd'' 
        AND master_physical_name = ''mst_infection''
    ) ms 
  WHERE
    A.facility_cd = ms.facility_cd 
    AND A.infection_cd = ms.code 
    AND A.is_del = ''0'' 
    AND A.is_disp = ''1'' 
  ORDER BY
    ms.INDEX
) 
, infectInfo AS ( 
  SELECT
    array_to_json( 
      ARRAY_AGG( 
        CASE 
          WHEN NULLIF(infection_nec.CONTENT, '''') IS NULL 
            THEN info.* 
          ELSE json_build_object( 
            ''infect''
            , infection_nec.CONTENT
            , ''exam_date''
            , info ->> ''exam_date''
            , ''up_date''
            , TO_CHAR(CURRENT_DATE, ''YYYYMMDD'')
            , ''infection_cd''
            , (info ->> ''infection_cd'')::integer
          ) 
          END
      )
    ) AS infect_info_new 
  FROM
    pat_main AS pat 
    CROSS JOIN LATERAL json_array_elements(pat.infect_info ::json) info 
    LEFT OUTER JOIN infection_ntss 
      ON infection_ntss.infection_cd ::TEXT = info ->> ''infection_cd'' 
    LEFT OUTER JOIN infection_nec 
      ON infection_nec.hospital_cd = infection_ntss.hospital_cd 
      AND NULLIF(infection_nec.CONTENT, '''') IS NOT NULL 
  WHERE
    pat.pat_id = @patId
)
, taboo_allergy_nec_sub AS ( 
  -- NECから、薬剤禁忌情報
  SELECT
    1 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 1, 1) AS CONTENT 
  UNION 
  SELECT
    2 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 2, 1) AS CONTENT 
  UNION 
  SELECT
    3 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 3, 1) AS CONTENT 
  UNION 
  SELECT
    4 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 4, 1) AS CONTENT 
  UNION 
  SELECT
    5 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 5, 1) AS CONTENT 
  UNION 
  SELECT
    6 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 6, 1) AS CONTENT 
  UNION 
  SELECT
    7 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 7, 1) AS CONTENT 
  UNION 
  SELECT
    8 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 8, 1) AS CONTENT 
  UNION 
  SELECT
    9 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 9, 1) AS CONTENT 
  UNION 
  SELECT
    10 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 10, 1) AS CONTENT 
  UNION 
  SELECT
    11 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 11, 1) AS CONTENT 
  UNION 
  SELECT
    12 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 12, 1) AS CONTENT 
  UNION 
  SELECT
    13 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 13, 1) AS CONTENT 
  UNION 
  SELECT
    14 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 14, 1) AS CONTENT 
  UNION 
  SELECT
    15 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 15, 1) AS CONTENT 
  UNION 
  SELECT
    16 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 16, 1) AS CONTENT 
  UNION 
  SELECT
    17 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 17, 1) AS CONTENT 
  UNION 
  SELECT
    18 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 18, 1) AS CONTENT 
  UNION 
  SELECT
    19 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 19, 1) AS CONTENT 
  UNION 
  SELECT
    20 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 20, 1) AS CONTENT 
  ORDER BY
    order_no ASC
) 
, taboo_reg_version AS (
  SELECT
    COALESCE(NULLIF(ini_info ->> ''value'', ''''), ini_info ->> ''default_v'') AS version
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info
  WHERE
    ini.facility_cd = ''@facilityCd''
    AND is_del = ''0''
    AND ini_info ->> ''key1'' = ''NEC''
    AND ini_info ->> ''key2'' = ''TABOO_REG_VERSION''
)
, taboo_allergy_ini AS ( 
  SELECT
    TO_NUMBER( 
      REPLACE (ini_info ->> ''key2'', ''TABOO_'', '''')
      , ''FM99''
    ) AS order_no
    , CASE 
      WHEN NULLIF(ini_info ->> ''value'', '''') IS NULL 
        THEN ini_info ->> ''default_v'' 
      ELSE ini_info ->> ''value'' 
      END AS value
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.facility_cd = ''@facilityCd'' 
    AND is_del = ''0''
    AND ini_info ->> ''key1'' = ''NEC'' 
    AND ini_info ->> ''key2'' LIKE ''TABOO_%'' 
    AND ini_info ->> ''key2'' <> ''TABOO_CTL_NO''
    AND ini_info ->> ''key2'' <> ''TABOO_REG_VERSION''
  ORDER BY
    TO_NUMBER( 
      REPLACE (ini_info ->> ''key2'', ''TABOO_'', '''')
      , ''FM99''
    ) ASC
) 
, taboo_allergy_nec AS ( 
  SELECT
    ini.order_no
    , ini.value
    , ROW_NUMBER() OVER () AS index_no 
  FROM
    taboo_allergy_nec_sub AS sub 
    INNER JOIN taboo_allergy_ini AS ini 
      ON sub.order_no = ini.order_no 
  WHERE
    sub.CONTENT = ''1'' 
  ORDER BY
    ini.order_no
) 
, taboo_allergy_ntss AS ( 
  SELECT
    A.taboo_allergy_cd
    , A.in_hospital_cd_1 AS hospital_cd
    , A.CONTENT 
  FROM
    mst_taboo_allergy A
    , ( 
      SELECT
        mss.facility_cd
        , ms.*
        , ROW_NUMBER() OVER () AS INDEX 
      FROM
        mst_selector mss 
        CROSS JOIN LATERAL jsonb_to_recordset(mss.order_settings -> ''items'') AS ms(code BIGINT, NAME TEXT) 
      WHERE
        facility_cd = ''@facilityCd'' 
        AND master_physical_name = ''mst_taboo_allergy''
    ) ms 
  WHERE
    A.facility_cd = ms.facility_cd 
    AND A.taboo_allergy_cd = ms.code 
    AND A.is_del = ''0'' 
    AND A.is_disp = ''1'' 
  ORDER BY
    ms.INDEX
)
, taboo_list_str AS (
  SELECT
  string_agg(taboo_list.value, ''、'') as content
  FROM (
    SELECT
      tan.order_no,
      tan.value
    FROM taboo_allergy_nec tan
    UNION
    SELECT
      21 AS order_no
      , ''@tabooAllergyComment'' AS value
    WHERE NULLIF(''@tabooAllergyComment'', '''') IS NOT NULL
    ORDER BY order_no ASC
  ) AS taboo_list
)
, tabooAllergyInfo AS ( 
  SELECT
    array_to_json( 
      ARRAY_AGG(
        json_build_object(
          ''memo'',
          NULL,
          ''ctl_no'',
          nec.index_no,
          ''content'',
          ntss_hospital_cd.content,
          ''disp_order'',
          nec.index_no,
          ''category_class'',
          ''0'',
          ''taboo_allergy_cd'',
          ntss_hospital_cd.taboo_allergy_cd,
          ''taboo_allergy_class'',
          ''1''
        )
      )
    ) ::TEXT AS taboo_allergy_info_new
    , ''0'' AS version
  FROM
    taboo_allergy_nec AS nec 
  LEFT OUTER JOIN taboo_allergy_ntss AS ntss_hospital_cd 
      ON nec.value = ntss_hospital_cd.hospital_cd 
  WHERE ntss_hospital_cd.taboo_allergy_cd IS NOT NULL
  UNION
  SELECT
    array_to_json(
      ARRAY_AGG(
        json_build_object(
          ''memo'',
          NULL,
          ''ctl_no'',
          0,
          ''content'',
          str.content,
          ''disp_order'',
          0,
          ''category_class'',
          ''5'',
          ''taboo_allergy_cd'',
          NULL,
          ''taboo_allergy_class'',
          ''1''
        )
      )
    ) ::TEXT AS taboo_allergy_info_new
    , ''1'' AS version
  FROM
    taboo_list_str AS str
)
, check_staff_code AS (
  SELECT (CASE
    -- Case 1: スタッフコードが空またはNULLの場合
    WHEN  '''' = ''@user_id''
         OR ''@'' || ''user_id'' = ''@user_id''
    THEN 
        ''-999999''
    -- Case 2: スタッフコードが数値でない場合
    WHEN NOT ''@user_id'' ~ ''^[0-9]+$''
    THEN
        ''-999999''
    -- Case 3: 該当するユーザーが存在しない場合
    WHEN NOT EXISTS (
        SELECT 1
        FROM mst_user
        WHERE facility_cd = ''@facilityCd''
          AND user_id::text = ''@user_id''
          AND is_disp = ''1''
          AND is_del = ''0''
    )
    THEN
        ''-999999''
    -- Case 4: すでに同じstaff_cdが存在する場合
    WHEN EXISTS (
        SELECT 1
        FROM pat_main, jsonb_array_elements(charge_staff_info) elem
        WHERE pat_id = @patId 
        AND facility_cd = ''@facilityCd''
        AND elem ->> ''staff_cd''::text = ''@user_id''
    )
    THEN
        ''-999999''
    -- Case 5: すべての条件を満たさない場合のみ新規追加
    ELSE ''@user_id''
    END) AS staff_code
)

UPDATE pat_main 
SET
charge_staff_info = CASE 
    WHEN  (SELECT staff_code FROM check_staff_code) = ''-999999''
    THEN 
        charge_staff_info
    ELSE 
        charge_staff_info || jsonb_build_array(
            jsonb_build_object(
                ''ctl_no'', (SELECT jsonb_array_length(charge_staff_info)) + 1,
                ''disp_order'', (SELECT jsonb_array_length(charge_staff_info)) + 1,
                ''staff_cd'', (SELECT staff_code FROM check_staff_code) :: int,
                ''is_main'', ''1'',
                ''is_charge'', ''0'',
                ''is_puncture'', ''0''
            )
        )
END
  , infect_info = (SELECT infect_info_new FROM infectInfo) ::JSONB
  , taboo_allergy_info = COALESCE( 
    NULLIF( 
      ( 
        SELECT
          taboo_allergy_info_new 
        FROM
          tabooAllergyInfo
        WHERE tabooAllergyInfo.version = (SELECT version FROM taboo_reg_version)
      ) ::TEXT
      , ''''
    ) 
    , ''[]''
  ) ::JSONB 
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''
  AND @is_die = ''0''', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECの「担当スタッフ情報、感染症情報、禁忌・アレルギー情報」の更新', '2021-11-23 12:12:12.000', CURRENT_TIMESTAMP, '[{"sql_cd": 1101, "field_name": "is_die", "replace_var": "@is_die"}, {"sql_cd": -600106, "field_name": "user_id", "replace_var": "@user_id"}]'::jsonb);

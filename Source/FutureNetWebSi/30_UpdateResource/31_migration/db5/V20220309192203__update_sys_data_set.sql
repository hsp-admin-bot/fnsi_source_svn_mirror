delete from "sys_data_set" where "sql_cd" in (3104,3105,3106,3107,3108,3109,3110,3111,1103,1008);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1008, 'SELECT
  COALESCE(array_to_json(ARRAY_AGG(user_id)), ''[]'') AS staff_cd_list
FROM
  ( 
    SELECT
      user_id 
    FROM
      mst_personal_user 
    WHERE
      is_del = ''0'' 
      AND is_disp = ''1'' 
      AND user_type != ''2'' 
      AND facility_cd = @facilityCd
    ORDER BY
      user_id ASC
  ) AS T01', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)観察記録(患者イベント情報)_全部利用者の取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1103, 'WITH name_info AS ( 
  SELECT
    ''@patLastName'' ::TEXT AS patLastName
    , ''@patFirstName'' ::TEXT AS patFirstName
    , ''@patLastNmKana'' ::TEXT AS patLastNmKana
    , ''@patFirstNmKana'' ::TEXT AS patFirstNmKana
) 
, tmp_index_info AS ( 
  SELECT
    COALESCE(NULLIF(POSITION(''　'' IN patLastName), 0), LENGTH(patLastName) + 1) AS indexLast1
    , COALESCE(NULLIF(POSITION('' '' IN patLastName), 0), LENGTH(patLastName) + 1) AS indexLast2
    , COALESCE(NULLIF(POSITION(''　'' IN patFirstName), 0), LENGTH(patFirstName) + 1) AS indexFirst1
    , COALESCE(NULLIF(POSITION('' '' IN patFirstName), 0), LENGTH(patFirstName) + 1) AS indexFirst2
    , COALESCE(NULLIF(POSITION(''　'' IN patLastNmKana), 0), LENGTH(patLastNmKana) + 1) AS indexLastK1
    , COALESCE(NULLIF(POSITION('' '' IN patLastNmKana), 0), LENGTH(patLastNmKana) + 1) AS indexLastK2
    , COALESCE(NULLIF(POSITION(''　'' IN patFirstNmKana), 0), LENGTH(patFirstNmKana) + 1) AS indexFirstK1
    , COALESCE(NULLIF(POSITION('' '' IN patFirstNmKana), 0), LENGTH(patFirstNmKana) + 1) AS indexFirstK2 
  FROM
    name_info
) 
, index_info AS ( 
  SELECT
    CASE 
      WHEN indexLast1 > indexLast2 
        THEN indexLast2 
      ELSE indexLast1 
      END AS indexLast
    , CASE 
      WHEN indexFirst1 > indexFirst2 
        THEN indexFirst2 
      ELSE indexFirst1 
      END AS indexFirst
    , CASE 
      WHEN indexLastK1 > indexLastK2 
        THEN indexLastK2 
      ELSE indexLastK1 
      END AS indexLastK
    , CASE 
      WHEN indexFirstK1 > indexFirstK2 
        THEN indexFirstK2 
      ELSE indexFirstK1 
      END AS indexFirstK 
  FROM
    tmp_index_info
)
, new_name_info AS (
  SELECT
    TRIM(TRIM(TRIM(SUBSTRING(patLastName, 1, indexLast-1)), ''　'')) AS patLastName
    , TRIM(TRIM(TRIM(SUBSTRING(patFirstName, indexFirst + 1)), ''　'')) AS patFirstName
    , TRIM(TRIM(TRIM(SUBSTRING(patLastNmKana, 1, indexLastK-1)), ''　'')) AS patLastNmKana
    , TRIM(TRIM(TRIM(SUBSTRING(patFirstNmKana, indexFirstK + 1)), ''　'')) AS patFirstNmKana
  FROM 
    name_info,
    index_info
) 
UPDATE pat_personal_main 
SET
  fn_pat_id = NULLIF(''@fnPatId'', '''')
  , hosp_pat_id = LTRIM(NULLIF(''@hospPatId'', ''''), ''0'')
  , nkk_pat_id = NULLIF(''@nkkPatId'', '''')
  , facility_cd = NULLIF(''@facilityCd'', '''')
  , pat_last_name = CASE WHEN (pat_last_name <> personal_info_encrypt(''ini_dial'') AND pat_first_name <> personal_info_encrypt(''only'')) OR (pat_last_name IS NULL AND pat_first_name IS NULL) THEN personal_info_encrypt((SELECT patLastName FROM new_name_info)) ELSE pat_last_name END 
  , pat_first_name = CASE WHEN (pat_last_name <> personal_info_encrypt(''ini_dial'') AND pat_first_name <> personal_info_encrypt(''only'')) OR (pat_last_name IS NULL AND pat_first_name IS NULL) THEN COALESCE(personal_info_encrypt(NULLIF((SELECT patFirstName FROM new_name_info), '''')), pat_first_name) ELSE pat_first_name END 
  , pat_last_name_kana = personal_info_encrypt((SELECT patLastNmKana FROM new_name_info))
  , pat_first_name_kana = COALESCE(personal_info_encrypt(NULLIF((SELECT patFirstNmKana FROM new_name_info), '''')) , pat_first_name_kana) 
  , pat_last_name_alpha = NULLIF(''@patLastNmAlpha'', '''')
  , pat_first_name_alpha = NULLIF(''@patFirstNmAlpha'', '''')
  , pat_birth_name = NULLIF(''@patBirthName'', '''')
  , pat_birth_name_kana = NULLIF(''@patBirthNmKana'', '''')
  , pat_birth_name_alpha = NULLIF(''@patBirthNmAlpha'', '''')
  , pat_birthday = NULLIF(''@patBirthday'', '''')
  , pat_sex = CASE ''@patSex'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@patSex'', ''FM9999999999999999'') 
    END
  , nationality = NULLIF(''@nationality'', '''')
  , pat_blood_type_abo = CASE ''@patBloodTypeAbo'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@patBloodTypeAbo'', ''FM9999999999999999'') 
    END
  , pat_blood_type_rh = CASE ''@patBloodTypeRh'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@patBloodTypeRh'', ''FM9999999999999999'') 
    END
  , pat_blood_type_serovar = CASE ''@patBloodTypeSerovar'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@patBloodTypeSerovar'', ''FM9999999999999999'') 
    END
  , in_out_class = CASE ''@inOutClass'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@inOutClass'', ''FM9999999999999999'') 
    END
  , is_die = NULLIF(''@isDie'', '''')
  , die_cd = CASE ''@dieCd'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@dieCd'', ''FM99999999999999999999999999999999'') 
    END
  , die_date = CASE ''@dieDate_Date'' 
    WHEN '''' THEN NULL 
    ELSE TO_TIMESTAMP(''@dieDate_Date'', ''YYYY-MM-DD HH24:MI:SS'') 
    END
  , dial_diff_com_info = ''@dialDiffComInfoValue''
  , severity_cd = CASE ''@severityCd'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER( ''@severityCd'', ''FM99999999999999999999999999999999'') 
    END
  , transport_cd = CASE ''@transportCd'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@transportCd'', ''FM99999999999999999999999999999999'') 
    END
  , pat_contact_info = CASE ''@patContactInfoFlg'' 
    WHEN '''' THEN ''@patContactInfoValue'' 
    ELSE json_build_object( 
      ''zip_cd''
      , NULLIF(''@patContactInfo.zipCd'', '''')
      , ''address''
      , NULLIF((TRIM(TRIM(TRIM(''@patContactInfo.address'', ''　''), '' ''), ''　'') || TRIM(TRIM(TRIM(''@patContactInfo.detailsAddress'', ''　''), '' ''), ''　'')), '''') 
      , ''tel1''
      , NULLIF(''@patContactInfo.tel1'', '''')
      , ''tel2''
      , NULLIF(''@patContactInfo.tel2'', '''')
      , ''fax''
      , NULLIF(''@patContactInfo.fax'', '''')
      , ''e_mail''
      , NULLIF(''@patContactInfo.eMail'', '''')
      , ''work_name''
      , NULLIF(''@patContactInfo.workName'', '''')
      , ''work_address''
      , NULLIF(''@patContactInfo.workAddress'', '''')
      , ''work_tel''
      , NULLIF(''@patContactInfo.workTel'', '''')
      , ''memo1''
      , NULLIF(''@patContactInfo.memo1'', '''')
      , ''memo2''
      , NULLIF(''@patContactInfo.memo2'', '''')
    ) 
    END
  , vendor_contact_info = ''@vendorContactInfoValue''
  , insurance_info = ''@insuranceInfoValue''
  , reg_date = ''@regDate''
  , up_date = CURRENT_TIMESTAMP
  , primary_disease_cd = CASE ''@primaryDiseaseCd'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@primaryDiseaseCd'', ''FM99999999999999999999999999999999'') 
    END
  , remote_monitor_service = CASE ''@remoteMonitorService'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@remoteMonitorService'', ''FM99999999999999999999999999999999'') 
    END
  , remote_monitor_user_id = NULLIF(''@remoteMonitorUserId'', '''')
  , remote_monitor_user_pw = NULLIF(''@remoteMonitorUserPw'', '''') 
WHERE
  is_del = ''0'' 
  AND hosp_pat_id = ''@hospPatId'' 
  AND facility_cd = ''@facilityCd''', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)患者個人情報の取得の修正', '2022-01-07 18:21:46', CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (3104, 'WITH taking_title_info AS (
  -- コメントのタイトルを指定※タイトルが未設定の場合、対象の項目属性は取込み対象外とします。
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN TRIM(ini_info ->> ''default_v'')
      ELSE TRIM(ini_info ->> ''value'') 
      END AS taking_title 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = ''@facilityCd'' 
    AND TRIM(ini_info ->> ''key1'') = ''ORDER_RECV_TAKING_TITLE'' 
    AND TRIM(ini_info ->> ''key2'') = ''@patMemoInfo.title'' 
    AND ''@patMemoInfo.title'' != ''''
  UNION 
  SELECT
    2 AS order_no
    , '''' AS taking_title
  ORDER BY
    order_no ASC LIMIT 1
)
, taking_info AS (
  -- 取込先指定:カンマ区切りで複数指定が可能。0または未設定：取込みなし、1：患者メモ、2：観察記録
  SELECT
    1 AS order_no
    , ''1'' AS taking
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = ''@facilityCd'' 
    AND TRIM(ini_info->>''key1'') = ''ORDER_RECV'' 
    AND TRIM(ini_info->>''key2'') = ''ORDER_RECV_TAKING'' 
    AND ((TRIM(ini_info->>''value'') !='''' AND TRIM(ini_info->>''value'') like ''%1%'') 
      OR ((ini_info->>''value'') = '''' AND TRIM(ini_info->>''default_v'') like ''%1%'')) 
  UNION 
  SELECT
    2 AS order_no
    , ''0'' AS taking
  ORDER BY
    order_no ASC LIMIT 1
)
, memo_id_info AS (
  -- 患者メモの番号:患者メモの番号(1~20を設定する、初期値は20)
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''20'') 
      ELSE TRIM(ini_info ->> ''value'') 
      END AS memo_id 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = ''@facilityCd'' 
    AND TRIM(ini_info ->> ''key1'') = ''ORDER_RECV'' 
    AND TRIM(ini_info ->> ''key2'') = ''ORDER_RECV_MEMO_ID'' 
  UNION 
  SELECT
    2 AS order_no
    , ''20'' AS memo_id
  ORDER BY
    order_no ASC LIMIT 1
)
, mstInitInfo AS ( 
  SELECT
    1 AS order_no
    , (idx - 1) AS idx
    , ms->>''ctl_no'' AS ctl_no 
    , ms->>''title'' AS title 
    , ms->>''content'' AS content 
  FROM
    pat_main AS A 
    CROSS JOIN LATERAL jsonb_array_elements(A.pat_memo_info ::jsonb) WITH ORDINALITY AS info(ms, idx)
  WHERE
    A.is_del = ''0'' 
    AND A.facility_cd = ''@facilityCd'' 
    AND A.pat_id = @patId 
    AND (ms->>''ctl_no''::TEXT) = (SELECT memo_id FROM memo_id_info) -- 患者メモの番号が有り
    AND (SELECT taking FROM taking_info) = ''1'' -- 取込先指定＝「1：患者メモ」
    AND (SELECT taking_title FROM taking_title_info) != '''' -- コメントのタイトルを指定済み
  UNION 
  SELECT
    2 AS order_no
    , (idx - 1) AS idx
    , ms ->> ''ctl_no'' AS ctl_no 
    , ms ->> ''title'' AS title 
    , ms ->> ''content'' AS content 
  FROM
    pat_main AS A 
    CROSS JOIN LATERAL jsonb_array_elements(A.pat_memo_info ::jsonb) WITH ORDINALITY AS info(ms, idx)
  WHERE
    A.is_del = ''0'' 
    AND A.facility_cd = ''@facilityCd'' 
    AND A.pat_id = @patId 
    AND (ms->>''ctl_no''::TEXT) = ''20'' -- 患者メモの番号[20]が有り
    AND (SELECT taking FROM taking_info) = ''1'' -- 取込先指定＝「1：患者メモ」
    AND (SELECT taking_title FROM taking_title_info) != '''' -- コメントのタイトルを指定済み
  ORDER BY order_no ASC LIMIT 1
) 
, mstInfo AS (
  SELECT
    idx
    , ctl_no 
    , REPLACE(COALESCE(NULLIF(title, ''''), (SELECT taking_title FROM taking_title_info)), CHR(10), ''\n'') AS title 
    , CASE WHEN NULLIF(content, '''') IS NULL THEN 
        ''【'' || (SELECT taking_title FROM taking_title_info) || ''】'' || ''@patMemoInfo.content'' 
      ELSE
        REPLACE(content, CHR(10), ''\n'') || ''\n'' || (''【'' || (SELECT taking_title FROM taking_title_info) || ''】'' || ''@patMemoInfo.content'') 
      END AS content
  FROM
    mstInitInfo
  WHERE
    ''@patMemoInfo.content'' != ''''
    AND (content IS NULL OR POSITION((''【'' || (SELECT taking_title FROM taking_title_info) || ''】'' || ''@patMemoInfo.content'') IN REPLACE(REPLACE(REPLACE(content, CHR(10), ''''), '' '', ''''), ''　'', '''') )=0) 
)
UPDATE pat_main 
SET pat_memo_info = jsonb_set (
  COALESCE ( pat_memo_info, ''[]'' ) :: JSONB,
  CAST ( ( SELECT ''{'' || idx || ''}'' FROM mstInfo ) AS TEXT [] ),
  CAST ( ( SELECT ''{"ctl_no":'' || ctl_no || '', "title":"'' || title || ''", "content":"'' || content || ''"}'' FROM mstInfo ) AS JSONB ) :: JSONB 
) 
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''
  AND (SELECT idx FROM mstInfo) IS NOT NULL', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の初回申し込み→依頼事項登録→患者メモ', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (3105, 'WITH sub_category_name_info AS (
  -- 観察記録のサブカテゴリ名
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''観察記録'') 
      ELSE TRIM(ini_info ->> ''value'') 
      END AS sub_category_name 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = @facilityCd 
    AND TRIM(ini_info ->> ''key1'') = ''ORDER_RECV'' 
    AND TRIM(ini_info ->> ''key2'') = ''ORDER_RECV_SUB_CATEGORY_NAME'' 
  UNION 
  SELECT
    2 AS order_no
    , ''観察記録'' AS sub_category_name
  ORDER BY
    order_no ASC LIMIT 1
)
, category_name_info AS (
  -- 観察記録カテゴリ名
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''観察記録'') 
      ELSE TRIM(ini_info ->> ''value'') 
      END AS category_name 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = @facilityCd 
    AND TRIM(ini_info ->> ''key1'') = ''ORDER_RECV'' 
    AND TRIM(ini_info ->> ''key2'') = ''ORDER_RECV_CATEGORY_NAME'' 
  UNION 
  SELECT
    2 AS order_no
    , ''観察記録'' AS category_name
  ORDER BY
    order_no ASC LIMIT 1
)
, taking_info AS (
  -- 取込先指定:カンマ区切りで複数指定が可能。0または未設定：取込みなし、1：患者メモ、2：観察記録
  SELECT
    1 AS order_no
    , ''2'' AS taking
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = @facilityCd 
    AND TRIM(ini_info->>''key1'') = ''ORDER_RECV'' 
    AND TRIM(ini_info->>''key2'') = ''ORDER_RECV_TAKING'' 
    AND ((TRIM(ini_info->>''value'') !='''' AND TRIM(ini_info->>''value'') like ''%2%'') 
      OR ((ini_info->>''value'') = '''' AND TRIM(ini_info->>''default_v'') like ''%2%'')) 
  UNION 
  SELECT
    2 AS order_no
    , ''0'' AS taking
  ORDER BY
    order_no ASC LIMIT 1
)
-- 取込先指定＝「2：観察記録」の場合、観察記録のテンプレートを取得する
SELECT
  template.template_cd
  , template.template_name
  , cat.category_cd
  , cat.category_name
  , sub_cat.use_type
  , template.input_params
  , sub_cat.sub_category_cd
  , sub_cat.sub_category_name
FROM
  mst_pat_event_sub_category AS sub_cat
  INNER JOIN mst_pat_event_category AS cat ON cat.is_del = ''0'' AND cat.is_disp=''1'' AND cat.category_cd=sub_cat.category_cd AND category_name = (SELECT category_name FROM category_name_info)
  INNER JOIN mst_pat_event_data_template AS template ON template.is_del = ''0'' AND template.is_disp=''1'' AND template.template_cd = sub_cat.template_cd
  CROSS JOIN LATERAL jsonb_array_elements(template.input_params ::jsonb) AS info 
WHERE
  sub_cat.is_del = ''0'' 
  AND sub_cat.is_disp = ''1'' 
  AND sub_cat.facility_cd = @facilityCd 
  AND sub_cat.sub_category_name = (SELECT sub_category_name FROM sub_category_name_info)
  AND info->>''format_class''  = ''1'' -- テンプレートにテキストエリアが有りか
  AND (SELECT taking FROM taking_info) = ''2'' -- 取込先指定＝「2：観察記録」
-- nullデータ(チェック用)
UNION
SELECT
  null AS template_cd
  , null AS template_name
  , null AS category_cd
  , null AS category_name
  , null AS use_type
  , null AS input_params
  , null AS sub_category_cd
  , null AS sub_category_name
ORDER BY 
 sub_category_cd ASC NULLS LAST LIMIT 1', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の初回申し込み→依頼事項登録→観察記録の連携設定を取得する', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (3106, 'WITH taking_title_info AS (
  -- コメントのタイトルを指定※タイトルが未設定の場合、対象の項目属性は取込み対象外とします。
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN TRIM(ini_info ->> ''default_v'')
      ELSE TRIM(ini_info ->> ''value'') 
      END AS taking_title 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = @facilityCd 
    AND TRIM(ini_info ->> ''key1'') = ''ORDER_RECV_TAKING_TITLE'' 
    AND TRIM(ini_info ->> ''key2'') = @patMemoInfo.title 
    AND @patMemoInfo.title != ''''
  UNION 
  SELECT
    2 AS order_no
    , '''' AS taking_title
  ORDER BY
    order_no ASC LIMIT 1
)
, sub_category_name_info AS (
  -- 観察記録のサブカテゴリ名
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''観察記録'') 
      ELSE TRIM(ini_info ->> ''value'') 
      END AS sub_category_name 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = @facilityCd 
    AND TRIM(ini_info ->> ''key1'') = ''ORDER_RECV'' 
    AND TRIM(ini_info ->> ''key2'') = ''ORDER_RECV_SUB_CATEGORY_NAME'' 
  UNION 
  SELECT
    2 AS order_no
    , ''観察記録'' AS sub_category_name
  ORDER BY
    order_no ASC LIMIT 1
)
, category_name_info AS (
  -- 観察記録カテゴリ名
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''観察記録'') 
      ELSE TRIM(ini_info ->> ''value'') 
      END AS category_name 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = @facilityCd 
    AND TRIM(ini_info ->> ''key1'') = ''ORDER_RECV'' 
    AND TRIM(ini_info ->> ''key2'') = ''ORDER_RECV_CATEGORY_NAME'' 
  UNION 
  SELECT
    2 AS order_no
    , ''観察記録'' AS category_name
  ORDER BY
    order_no ASC LIMIT 1
)
, taking_info AS (
  -- 取込先指定:カンマ区切りで複数指定が可能。0または未設定：取込みなし、1：患者メモ、2：観察記録
  SELECT
    1 AS order_no
    , ''2'' AS taking
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = @facilityCd 
    AND TRIM(ini_info->>''key1'') = ''ORDER_RECV'' 
    AND TRIM(ini_info->>''key2'') = ''ORDER_RECV_TAKING'' 
    AND ((TRIM(ini_info->>''value'') !='''' AND TRIM(ini_info->>''value'') like ''%2%'') 
      OR ((ini_info->>''value'') = '''' AND TRIM(ini_info->>''default_v'') like ''%2%'')) 
  UNION 
  SELECT
    2 AS order_no
    , ''0'' AS taking
  ORDER BY
    order_no ASC LIMIT 1
)
, category_info AS (
    -- 観察記録の内容
    SELECT
        template.template_cd
        , template.template_name
        , cat.category_cd
        , cat.category_name
        , sub_cat.use_type
        , template.input_params
        , sub_cat.sub_category_cd
        , sub_cat.sub_category_name
    FROM
        mst_pat_event_sub_category AS sub_cat
        INNER JOIN mst_pat_event_category AS cat ON cat.is_del = ''0'' AND cat.is_disp=''1'' AND cat.category_cd=sub_cat.category_cd AND category_name = (SELECT category_name FROM category_name_info)
        INNER JOIN mst_pat_event_data_template AS template ON template.is_del = ''0'' AND template.is_disp=''1'' AND template.template_cd = sub_cat.template_cd
        CROSS JOIN LATERAL jsonb_array_elements(template.input_params ::jsonb) AS info 
    WHERE
        sub_cat.is_del = ''0'' 
        AND sub_cat.is_disp = ''1'' 
        AND sub_cat.facility_cd = @facilityCd 
        AND sub_cat.sub_category_name = (SELECT sub_category_name FROM sub_category_name_info)
        AND info->>''format_class''  = ''1'' -- テンプレートにテキストエリアが有りか
    ORDER BY 
     sub_cat.sub_category_cd ASC LIMIT 1
) 
SELECT
  pat.pat_event_cd
FROM 
  pat_event AS pat 
  CROSS JOIN LATERAL jsonb_array_elements(pat.result_params ::jsonb) AS result 
  INNER JOIN category_info AS cat ON pat.template_cd = cat.template_cd 
      AND pat.template_cd = cat.template_cd 
      AND pat.category_cd = cat.category_cd 
      AND pat.use_type = cat.use_type 
      AND pat.input_params = cat.input_params 
      AND pat.input_params = cat.input_params 
      AND pat.sub_category_cd = cat.sub_category_cd 
WHERE 
  pat.is_del = ''0'' 
  AND pat.facility_cd = @facilityCd 
  AND pat.pat_id = @patId 
  AND pat.event_status = ''1'' 
  AND pat.event_start_date = SUBSTR(@regDate, 1, 8)
  AND pat.event_start_time = SUBSTR(@regDate, 9, 4)
  AND result->>''format_class'' = ''1''
  AND result->>''result_value'' = (''【'' || (SELECT taking_title FROM taking_title_info) || ''】'' || @patMemoInfo.content) 
  AND @patMemoInfo.content != ''''
  AND (SELECT taking FROM taking_info) = ''2'' -- 取込先指定＝「2：観察記録」
  AND (SELECT taking_title FROM taking_title_info) != '''' -- コメントのタイトルを指定済み', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の初回申し込み→依頼事項登録→観察記録(患者イベント情報)_取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (3107, 'WITH taking_title_info AS (
  -- コメントのタイトルを指定※タイトルが未設定の場合、対象の項目属性は取込み対象外とします。
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN TRIM(ini_info ->> ''default_v'')
      ELSE TRIM(ini_info ->> ''value'') 
      END AS taking_title 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = ''@facilityCd'' 
    AND TRIM(ini_info ->> ''key1'') = ''ORDER_RECV_TAKING_TITLE'' 
    AND TRIM(ini_info ->> ''key2'') = ''@patMemoInfo.title'' 
    AND ''@patMemoInfo.title'' != ''''
  UNION 
  SELECT
    2 AS order_no
    , '''' AS taking_title
  ORDER BY
    order_no ASC LIMIT 1
)
, taking_info AS (
  -- 取込先指定:カンマ区切りで複数指定が可能。0または未設定：取込みなし、1：患者メモ、2：観察記録
  SELECT
    1 AS order_no
    , ''2'' AS taking
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = ''@facilityCd'' 
    AND TRIM(ini_info->>''key1'') = ''ORDER_RECV'' 
    AND TRIM(ini_info->>''key2'') = ''ORDER_RECV_TAKING'' 
    AND ((TRIM(ini_info->>''value'') !='''' AND TRIM(ini_info->>''value'') like ''%2%'') 
      OR ((ini_info->>''value'') = '''' AND TRIM(ini_info->>''default_v'') like ''%2%'')) 
  UNION 
  SELECT
    2 AS order_no
    , ''0'' AS taking
  ORDER BY
    order_no ASC LIMIT 1
)
, sub_category_name_info AS (
  -- 観察記録のサブカテゴリ名
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''観察記録'') 
      ELSE TRIM(ini_info ->> ''value'') 
      END AS sub_category_name 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = ''@facilityCd'' 
    AND TRIM(ini_info ->> ''key1'') = ''ORDER_RECV'' 
    AND TRIM(ini_info ->> ''key2'') = ''ORDER_RECV_SUB_CATEGORY_NAME'' 
  UNION 
  SELECT
    2 AS order_no
    , ''観察記録'' AS sub_category_name
  ORDER BY
    order_no ASC LIMIT 1
)
, category_name_info AS (
  -- 観察記録カテゴリ名
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''観察記録'') 
      ELSE TRIM(ini_info ->> ''value'') 
      END AS category_name 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = ''@facilityCd'' 
    AND TRIM(ini_info ->> ''key1'') = ''ORDER_RECV'' 
    AND TRIM(ini_info ->> ''key2'') = ''ORDER_RECV_CATEGORY_NAME'' 
  UNION 
  SELECT
    2 AS order_no
    , ''観察記録'' AS category_name
  ORDER BY
    order_no ASC LIMIT 1
)
, category_info AS (
  -- 観察記録の内容
  SELECT
    template.template_cd
    , template.template_name
    , cat.category_cd
    , cat.category_name
    , sub_cat.use_type
    , template.input_params
    , sub_cat.sub_category_cd
    , sub_cat.sub_category_name
  FROM
    mst_pat_event_sub_category AS sub_cat
    INNER JOIN mst_pat_event_category AS cat ON cat.is_del = ''0'' AND cat.is_disp=''1'' AND cat.category_cd=sub_cat.category_cd AND category_name = (SELECT category_name FROM category_name_info)
    INNER JOIN mst_pat_event_data_template AS template ON template.is_del = ''0'' AND template.is_disp=''1'' AND template.template_cd = sub_cat.template_cd
    CROSS JOIN LATERAL jsonb_array_elements(template.input_params ::jsonb) AS info 
  WHERE
    sub_cat.is_del = ''0'' 
    AND sub_cat.is_disp = ''1'' 
    AND sub_cat.facility_cd = ''@facilityCd'' 
    AND sub_cat.sub_category_name = (SELECT sub_category_name FROM sub_category_name_info)
    AND info->>''format_class''  = ''1'' -- テンプレートにテキストエリアが有りか
  ORDER BY 
   sub_cat.sub_category_cd ASC LIMIT 1
) 
, result_params_info AS ( 
  SELECT
    json_build_object(''format_class'', TO_NUMBER((info->>''format_class'' :: TEXT), ''FM999999999999'')
      , ''result_value'' 
      , CASE (info->>''format_class'' :: TEXT)
        WHEN ''1'' THEN to_jsonb(''【'' || (SELECT taking_title FROM taking_title_info) || ''】'' || ''@patMemoInfo.content'') 
        WHEN ''10'' THEN jsonb_build_object(''notice_start_date'',null, ''notice_end_date'',null, ''staff_info'', jsonb_build_object(''target'',''0'', ''staff_cd'',''[-1]''::JSONB))
        ELSE null END
     ) AS result_params 
  FROM
    category_info
    CROSS JOIN LATERAL jsonb_array_elements(input_params ::jsonb) AS info 
)
INSERT 
INTO pat_event (
  pat_id
  , facility_cd
  , fn_ctl_no
  , event_status
  , template_cd
  , template_name
  , category_cd
  , category_name
  , ord_no
  , input_params
  , event_start_date
  , sub_category_cd
  , sub_category_name
  , result_params
  , score_total
  , reg_staff_info
  , up_staff_info
  , bbs_ctl_no
  , is_newest
  , is_del
  , reg_date
  , up_date
  , letter_info
  , use_type
  , event_end_date
  , event_start_time
  , event_end_time
  , report_url
  , report_date
)
SELECT
  @patId AS pat_id
  , ''@facilityCd'' AS facility_cd
  , 0 AS fn_ctl_no
  , ''1'' AS event_status
  , template_cd
  , template_name
  , category_cd
  , category_name
  , 0 AS ord_no
  , input_params
  , SUBSTR(''@regDate'', 1, 8) AS event_start_date
  , sub_category_cd
  , sub_category_name
  , ((SELECT array_to_json(ARRAY_AGG(result_params)) FROM result_params_info)::JSONB || (''[{"upDate":"'' || CURRENT_TIMESTAMP || ''"}]'')::JSONB)AS result_params
  , null AS score_total
  , json_build_object(''reg_staff_cd'', -1, ''reg_staff_name'', null) AS reg_staff_info
  , json_build_object(''up_staff_cd'', -1, ''up_staff_name'', null) AS up_staff_info
  , 0 AS bbs_ctl_no
  , ''1'' AS is_newest
  , ''0'' AS is_del
  , CURRENT_TIMESTAMP AS reg_date
  , CURRENT_TIMESTAMP AS up_date
  , null AS letter_info
  , use_type
  , SUBSTR(''@regDate'', 1, 8) AS event_end_date
  , NULLIF(SUBSTR(''@regDate'', 9, 4), ''0000'') AS event_start_time
  , null AS event_end_time
  , null AS report_url
  , null AS report_date
FROM category_info
WHERE
  ''@patMemoInfo.content'' != ''''
  AND (SELECT taking FROM taking_info) = ''2'' -- 取込先指定＝「2：観察記録」
  AND (SELECT taking_title FROM taking_title_info) != '''' -- コメントのタイトルを指定済み', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の初回申し込み→依頼事項登録→観察記録(患者イベント情報)_登録', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (3108, 'WITH taking_info AS (
  -- 取込先指定:カンマ区切りで複数指定が可能。0または未設定：取込みなし、1：患者メモ、2：観察記録
  SELECT
    1 AS order_no
    , ''2'' AS taking
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = @facilityCd 
    AND TRIM(ini_info->>''key1'') = ''ORDER_RECV'' 
    AND TRIM(ini_info->>''key2'') = ''ORDER_RECV_TAKING'' 
    AND ((TRIM(ini_info->>''value'') !='''' AND TRIM(ini_info->>''value'') like ''%2%'') 
      OR ((ini_info->>''value'') = '''' AND TRIM(ini_info->>''default_v'') like ''%2%'')) 
  UNION 
  SELECT
    2 AS order_no
    , ''0'' AS taking
  ORDER BY
    order_no ASC LIMIT 1
)
, taking_title_info AS (
  -- コメントのタイトルを指定※タイトルが未設定の場合、対象の項目属性は取込み対象外とします。
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN TRIM(ini_info ->> ''default_v'')
      ELSE TRIM(ini_info ->> ''value'') 
      END AS taking_title 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = @facilityCd 
    AND TRIM(ini_info ->> ''key1'') = ''ORDER_RECV_TAKING_TITLE'' 
    AND TRIM(ini_info ->> ''key2'') = @patMemoInfo.title 
    AND @patMemoInfo.title != ''''
  UNION 
  SELECT
    2 AS order_no
    , '''' AS taking_title
  ORDER BY
    order_no ASC LIMIT 1
)
, bbs_flag_info AS (
  -- 掲示板出力フラグ:0または未設定：出力なし、1：出力あり
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''0'') 
      ELSE TRIM(ini_info ->> ''value'')
      END AS bbs_flag 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = @facilityCd 
    AND TRIM(ini_info ->> ''key1'') = ''ORDER_RECV'' 
    AND TRIM(ini_info ->> ''key2'') = ''ORDER_RECV_BBS_FLAG'' 
  UNION 
  SELECT
    2 AS order_no
    , ''0'' AS bbs_flag
  ORDER BY
    order_no ASC LIMIT 1
)
, bbs_life_list_flg_info AS (
  -- 掲示板_観察記録出力フラグ:0または未設定：出力なし、1：出力あり
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''0'') 
      ELSE TRIM(ini_info ->> ''value'') 
      END AS bbs_life_list_flg 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = @facilityCd 
    AND TRIM(ini_info ->> ''key1'') = ''ORDER_RECV'' 
    AND TRIM(ini_info ->> ''key2'') = ''ORDER_RECV_BBS_LIFE_LIST_FLG'' 
  UNION 
  SELECT
    2 AS order_no
    , ''0'' AS bbs_life_list_flg
  ORDER BY
    order_no ASC LIMIT 1
)
, bbs_span_info AS (
  -- 掲示板掲載期間:当日からの掲載日数を指定（0または未設定：当日のみ）
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''0'') 
      ELSE TRIM(ini_info ->> ''value'')
      END AS bbs_span 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = @facilityCd 
    AND TRIM(ini_info ->> ''key1'') = ''ORDER_RECV'' 
    AND TRIM(ini_info ->> ''key2'') = ''ORDER_RECV_BBS_SPAN'' 
  UNION 
  SELECT
    2 AS order_no
    , ''0'' AS bbs_span
  ORDER BY
    order_no ASC LIMIT 1
)
, bbs_stuff_info AS (
  -- 掲示板対象スタッフ:掲示板対象スタッフＩＤ（未設定：全スタッフ）カンマ区切りで複数指定可能
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), '''') 
      ELSE TRIM(ini_info ->> ''value'')
      END AS bbs_stuff 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = @facilityCd 
    AND TRIM(ini_info ->> ''key1'') = ''ORDER_RECV'' 
    AND TRIM(ini_info ->> ''key2'') = ''ORDER_RECV_BBS_STUFF'' 
  UNION 
  SELECT
    2 AS order_no
    , '''' AS bbs_stuff
  ORDER BY
    order_no ASC LIMIT 1
)
, bbs_category_name_info AS (
  -- 掲示板のカテゴリ名
  SELECT
     CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN TRIM(ini_info ->> ''default_v'')
      ELSE TRIM(ini_info ->> ''value'') 
      END AS bbs_category_name 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = @facilityCd 
    AND TRIM(ini_info ->> ''key1'') = ''ORDER_RECV'' 
    AND TRIM(ini_info ->> ''key2'') = ''ORDER_RECV_BBS_CATEGORY_NAME'' 
)
, bbs_kind_info AS (
  -- 掲示板のカテゴリを取得する
  SELECT
    kind_no
    , default_title AS title
    , default_contents AS content
    , CASE WHEN T01.bbs_category_name IS NULL THEN 0 ELSE 1 END AS order_no
  FROM
    mst_bbs_kind AS bbs
    LEFT OUTER JOIN (SELECT bbs_category_name FROM bbs_category_name_info) AS T01 ON bbs.kind_name = T01.bbs_category_name AND NULLIF(T01.bbs_category_name, '''') IS NOT NULL
  WHERE 
    bbs.is_del = ''0'' 
    AND bbs.is_disp= ''1'' 
    AND bbs.facility_cd = @facilityCd 
  ORDER BY
    order_no DESC, kind_no ASC LIMIT 1
)
, notice_date AS (
  -- 掲載開始日時と掲載終了日時
  SELECT
    SUBSTR(@regDate, 1, 8) AS start_date
    , SUBSTR(TO_CHAR((TO_DATE(@regDate, ''YYYYMMDDHH24MISS'') +  (bbs_span || '' day'')::interval), ''YYYYMMDDHH24MISS''), 1, 8) AS end_date
    , SUBSTR(@regDate, 9, 4) AS start_time
    , COALESCE(NULLIF(SUBSTR(@regDate, 9, 4), ''0000''), ''2359'') AS end_time
  FROM bbs_span_info
)
, content_info AS (
  -- 掲載開始日時と掲載終了日時
  SELECT
    (''血液浄化申込情報を受信しました。'' || 
      CASE WHEN (SELECT bbs_life_list_flg FROM bbs_life_list_flg_info) = ''1'' 
      THEN (''\n'' || ''【'' ||  taking_title || ''】'' || @patMemoInfo.content) 
      ELSE ''''
      END) AS content
  FROM taking_title_info
)
, new_bbs_info AS (
  -- 新規データ
  SELECT
    (@facilityCd)::TEXT AS facility_cd
    , jsonb_build_object(''target'', ''0'', ''detail'', (''['' || @patId ||'']'')::JSONB) AS pat_info
    , jsonb_build_object(''target'', (''['' || (SELECT COALESCE(NULLIF(bbs_stuff, ''0''), '''') FROM bbs_stuff_info) || '']'')::JSONB, ''read'', ''[]''::JSONB) AS staff_info
    , (''020'')::TEXT AS func_cd
    , kind.kind_no AS kind_no
    , (SELECT content FROM content_info) AS content
    , ''[]''::JSONB AS file_info
    , nd.start_date AS notice_start_date
    , nd.end_date AS notice_end_date
    , -1 AS reg_staff_id
    , null AS reg_staff_name
    , -1 AS upd_staff_id
    , null AS upd_staff_name
    , (''observe-record'')::TEXT AS transition_router_path
    , 1 AS reg_func_class
    , CURRENT_TIMESTAMP AS reg_date
    , CURRENT_TIMESTAMP AS up_date
    , kind.title AS title
    , nd.start_date AS notice_fac_cal_start_date
    , nd.end_date AS notice_fac_cal_end_date
    , ''1''::TEXT AS is_disp_bbs 
    , (''#ffffff'')::TEXT AS color
    , (''<p style="font-size: 14pt; font-family: メイリオ;">'' || (SELECT content FROM content_info) || ''</p>'')::TEXT AS html_content
    , start_time AS notice_fac_cal_start_time
    , end_time AS notice_fac_cal_end_time
    , ''1''::TEXT AS is_time_start_flg
    , ''1''::TEXT AS is_time_end_flg
    , (''#000000'')::TEXT AS font_color
    , ''0''::TEXT AS is_del
    , ''1''::TEXT AS is_disp
  FROM 
    bbs_kind_info AS kind, notice_date AS nd
)
SELECT
  bbs.bbs_ctl_no
FROM 
  bbs_info AS bbs 
  INNER JOIN new_bbs_info AS new ON new.facility_cd = bbs.facility_cd
      AND new.pat_info = bbs.pat_info
      AND new.kind_no = bbs.kind_no
      AND new.content = bbs.content 
      AND new.notice_start_date = bbs.notice_start_date 
      AND new.notice_end_date = bbs.notice_end_date 
      AND new.transition_router_path = bbs.transition_router_path 
      AND new.reg_func_class = bbs.reg_func_class
      AND new.notice_fac_cal_start_date = bbs.notice_fac_cal_start_date 
      AND new.notice_fac_cal_end_date = bbs.notice_fac_cal_end_date 
      AND new.is_disp_bbs = bbs.is_disp_bbs 
WHERE 
  bbs.is_del = ''0'' 
  AND bbs.is_disp = ''1'' 
  AND bbs.facility_cd = @facilityCd 
  AND (SELECT taking FROM taking_info) = ''2'' -- 取込先指定＝「2：観察記録」
  AND (SELECT taking_title FROM taking_title_info) != '''' -- コメントのタイトルを指定済み
  AND (SELECT bbs_flag FROM bbs_flag_info) = ''1'' -- 掲示板出力フラグ＝「1：出力あり」
  AND @patMemoInfo.content != ''''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の初回申し込み→依頼事項登録→掲示板情報_取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (3109, 'WITH taking_info AS (
  -- 取込先指定:カンマ区切りで複数指定が可能。0または未設定：取込みなし、1：患者メモ、2：観察記録
  SELECT
    1 AS order_no
    , ''2'' AS taking
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = ''@facilityCd'' 
    AND TRIM(ini_info->>''key1'') = ''ORDER_RECV'' 
    AND TRIM(ini_info->>''key2'') = ''ORDER_RECV_TAKING'' 
    AND ((TRIM(ini_info->>''value'') !='''' AND TRIM(ini_info->>''value'') like ''%2%'') 
      OR ((ini_info->>''value'') = '''' AND TRIM(ini_info->>''default_v'') like ''%2%'')) 
  UNION 
  SELECT
    2 AS order_no
    , ''0'' AS taking
  ORDER BY
    order_no ASC LIMIT 1
)
, taking_title_info AS (
  -- コメントのタイトルを指定※タイトルが未設定の場合、対象の項目属性は取込み対象外とします。
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN TRIM(ini_info ->> ''default_v'')
      ELSE TRIM(ini_info ->> ''value'') 
      END AS taking_title 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = ''@facilityCd'' 
    AND TRIM(ini_info ->> ''key1'') = ''ORDER_RECV_TAKING_TITLE'' 
    AND TRIM(ini_info ->> ''key2'') = ''@patMemoInfo.title'' 
    AND ''@patMemoInfo.title'' != ''''
  UNION 
  SELECT
    2 AS order_no
    , '''' AS taking_title
  ORDER BY
    order_no ASC LIMIT 1
)
, bbs_flag_info AS (
  -- 掲示板出力フラグ:0または未設定：出力なし、1：出力あり
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''0'') 
      ELSE TRIM(ini_info ->> ''value'')
      END AS bbs_flag 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = ''@facilityCd'' 
    AND TRIM(ini_info ->> ''key1'') = ''ORDER_RECV'' 
    AND TRIM(ini_info ->> ''key2'') = ''ORDER_RECV_BBS_FLAG'' 
  UNION 
  SELECT
    2 AS order_no
    , ''0'' AS bbs_flag
  ORDER BY
    order_no ASC LIMIT 1
)
, bbs_life_list_flg_info AS (
  -- 掲示板_観察記録出力フラグ:0または未設定：出力なし、1：出力あり
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''0'') 
      ELSE TRIM(ini_info ->> ''value'') 
      END AS bbs_life_list_flg 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = ''@facilityCd'' 
    AND TRIM(ini_info ->> ''key1'') = ''ORDER_RECV'' 
    AND TRIM(ini_info ->> ''key2'') = ''ORDER_RECV_BBS_LIFE_LIST_FLG'' 
  UNION 
  SELECT
    2 AS order_no
    , ''0'' AS bbs_life_list_flg
  ORDER BY
    order_no ASC LIMIT 1
)
, bbs_span_info AS (
  -- 掲示板掲載期間:当日からの掲載日数を指定（0または未設定：当日のみ）
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''0'') 
      ELSE TRIM(ini_info ->> ''value'')
      END AS bbs_span 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = ''@facilityCd'' 
    AND TRIM(ini_info ->> ''key1'') = ''ORDER_RECV'' 
    AND TRIM(ini_info ->> ''key2'') = ''ORDER_RECV_BBS_SPAN'' 
  UNION 
  SELECT
    2 AS order_no
    , ''0'' AS bbs_span
  ORDER BY
    order_no ASC LIMIT 1
)
, bbs_stuff_info AS (
  -- 掲示板対象スタッフ:掲示板対象スタッフＩＤ（未設定：全スタッフ）カンマ区切りで複数指定可能
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), '''') 
      ELSE TRIM(ini_info ->> ''value'')
      END AS bbs_stuff 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = ''@facilityCd'' 
    AND TRIM(ini_info ->> ''key1'') = ''ORDER_RECV'' 
    AND TRIM(ini_info ->> ''key2'') = ''ORDER_RECV_BBS_STUFF'' 
  UNION 
  SELECT
    2 AS order_no
    , '''' AS bbs_stuff
  ORDER BY
    order_no ASC LIMIT 1
)
, bbs_category_name_info AS (
  -- 掲示板のカテゴリ名
  SELECT
     CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN TRIM(ini_info ->> ''default_v'')
      ELSE TRIM(ini_info ->> ''value'') 
      END AS bbs_category_name 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = ''@facilityCd'' 
    AND TRIM(ini_info ->> ''key1'') = ''ORDER_RECV'' 
    AND TRIM(ini_info ->> ''key2'') = ''ORDER_RECV_BBS_CATEGORY_NAME'' 
)
, bbs_kind_info AS (
  -- 掲示板のカテゴリを取得する
  SELECT
    kind_no
    , default_title AS title
    , default_contents AS content
    , CASE WHEN T01.bbs_category_name IS NULL THEN 0 ELSE 1 END AS order_no
  FROM
    mst_bbs_kind AS bbs
    LEFT OUTER JOIN (SELECT bbs_category_name FROM bbs_category_name_info) AS T01 ON bbs.kind_name = T01.bbs_category_name AND NULLIF(T01.bbs_category_name, '''') IS NOT NULL
  WHERE 
    bbs.is_del = ''0'' 
    AND bbs.is_disp= ''1'' 
    AND bbs.facility_cd = ''@facilityCd'' 
  ORDER BY
    order_no DESC, kind_no ASC LIMIT 1
)
, notice_date AS (
  -- 掲載開始日時と掲載終了日時
  SELECT
    SUBSTR(''@regDate'', 1, 8) AS start_date
    , SUBSTR(TO_CHAR((TO_DATE(''@regDate'', ''YYYYMMDDHH24MISS'') +  (bbs_span || '' day'')::interval), ''YYYYMMDDHH24MISS''), 1, 8) AS end_date
    , SUBSTR(''@regDate'', 9, 4) AS start_time
    , COALESCE(NULLIF(SUBSTR(''@regDate'', 9, 4), ''0000''), ''2359'') AS end_time
  FROM bbs_span_info
)
, content_info AS (
  -- 掲載内容
  SELECT
    (''血液浄化申込情報を受信しました。'' || 
      CASE WHEN (SELECT bbs_life_list_flg FROM bbs_life_list_flg_info) = ''1'' 
      THEN (''\n'' || ''【'' ||  taking_title || ''】'' || ''@patMemoInfo.content'') 
      ELSE ''''
      END) AS content
  FROM taking_title_info
)
, new_bbs_info AS (
  -- 新規データ
  SELECT
    (''@facilityCd'')::TEXT AS facility_cd
    , jsonb_build_object(''target'', ''0'', ''detail'', (''['' || @patId ||'']'')::JSONB) AS pat_info
    , jsonb_build_object(''target'', (''['' || (SELECT COALESCE(NULLIF(bbs_stuff, ''0''), '''') FROM bbs_stuff_info) || '']'')::JSONB, ''read'', ''[]''::JSONB) AS staff_info
    , (''020'')::TEXT AS func_cd
    , kind.kind_no AS kind_no
    , (SELECT content FROM content_info) AS content
    , ''[]''::JSONB AS file_info
    , nd.start_date AS notice_start_date
    , nd.end_date AS notice_end_date
    , -1 AS reg_staff_id
    , null AS reg_staff_name
    , -1 AS upd_staff_id
    , null AS upd_staff_name
    , (''observe-record'')::TEXT AS transition_router_path
    , 1 AS reg_func_class
    , CURRENT_TIMESTAMP AS reg_date
    , CURRENT_TIMESTAMP AS up_date
    , kind.title AS title
    , nd.start_date AS notice_fac_cal_start_date
    , nd.end_date AS notice_fac_cal_end_date
    , ''1''::TEXT AS is_disp_bbs 
    , (''#ffffff'')::TEXT AS color
    , (''<p style="font-size: 14pt; font-family: メイリオ;">'' || (SELECT content FROM content_info) || ''</p>'')::TEXT AS html_content
    , start_time AS notice_fac_cal_start_time
    , end_time AS notice_fac_cal_end_time
    , ''1''::TEXT AS is_time_start_flg
    , ''1''::TEXT AS is_time_end_flg
    , (''#000000'')::TEXT AS font_color
    , ''0''::TEXT AS is_del
    , ''1''::TEXT AS is_disp
  FROM 
    bbs_kind_info AS kind, notice_date AS nd
)
INSERT 
INTO bbs_info (
  facility_cd
  , pat_info
  , staff_info
  , func_cd
  , kind_no
  , content
  , file_info
  , notice_start_date
  , notice_end_date
  , reg_staff_id
  , reg_staff_name
  , upd_staff_id
  , upd_staff_name
  , transition_router_path
  , reg_func_class
  , reg_date
  , up_date
  , title
  , notice_fac_cal_start_date
  , notice_fac_cal_end_date
  , is_disp_bbs 
  , color
  , html_content
  , notice_fac_cal_start_time
  , notice_fac_cal_end_time
  , is_time_start_flg
  , is_time_end_flg
  , font_color
  , is_del
  , is_disp
)
SELECT
  facility_cd
  , pat_info
  , staff_info
  , func_cd
  , kind_no
  , content
  , file_info
  , notice_start_date
  , notice_end_date
  , reg_staff_id
  , reg_staff_name
  , upd_staff_id
  , upd_staff_name
  , transition_router_path
  , reg_func_class
  , reg_date
  , up_date
  , title
  , notice_fac_cal_start_date
  , notice_fac_cal_end_date
  , is_disp_bbs 
  , color
  , html_content
  , notice_fac_cal_start_time
  , notice_fac_cal_end_time
  , is_time_start_flg
  , is_time_end_flg
  , font_color
  , is_del
  , is_disp
FROM new_bbs_info
WHERE
  ''@patMemoInfo.content'' != ''''
  AND (SELECT taking FROM taking_info) = ''2'' -- 取込先指定＝「2：観察記録」
  AND (SELECT taking_title FROM taking_title_info) != '''' -- コメントのタイトルを指定済み
  AND (SELECT bbs_flag FROM bbs_flag_info) = ''1'' -- 掲示板出力フラグ＝「1：出力あり」
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の初回申し込み→依頼事項登録→掲示板情報_登録', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (3110, 'SELECT
  @patEventCd AS pat_event_cd
  , @bbsCtlNo AS bbs_ctl_no', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の初回申し込み→依頼事項登録→掲示板情報有り場合、掲示板情報と患者イベント情報の取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": 3106, "field_name": "pat_event_cd", "replace_var": "@patEventCd"}, {"sql_cd": 3108, "field_name": "bbs_ctl_no", "replace_var": "@bbsCtlNo"}]');
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (3111, 'WITH new_data AS (
  SELECT
    (idx - 1) AS idx
    , json_build_object(''format_class'', 10, 
      ''result_value'', json_build_object(''notice_end_date'', TO_CHAR(TO_DATE(bbs.notice_end_date, ''YYYYMMDD''), ''YYYY-MM-DD''),
                     ''notice_start_date'', TO_CHAR(TO_DATE(bbs.notice_start_date, ''YYYYMMDD''), ''YYYY-MM-DD''),
                     ''staff_info'', json_build_object(''target'', CASE WHEN (bbs.staff_info->>''target'')::TEXT = ''[]'' OR (bbs.staff_info->>''target'')::TEXT IS NULL THEN ''1'' ELSE ''0'' END,
                                   ''staff_cd'', COALESCE(NULLIF(''@staffCdList'', ''''), ''[]'') ::JSONB) ) ) AS format_class_10 
  FROM pat_event AS event
    CROSS JOIN LATERAL jsonb_array_elements(event.result_params ::jsonb) WITH ORDINALITY AS info(result, idx)
    , bbs_info AS bbs
  WHERE 
    event.pat_event_cd = @patEventCd
    AND bbs.bbs_ctl_no = @bbsCtlNo
    AND result->>''format_class''::TEXT = ''10''
)
UPDATE pat_event AS event
SET up_date = CURRENT_TIMESTAMP
  , bbs_ctl_no = @bbsCtlNo
  , result_params = jsonb_set(result_params, CAST((SELECT ''{'' || idx || ''}'' FROM new_data) AS TEXT []), CAST((SELECT format_class_10 FROM new_data) AS JSONB)::JSONB)
WHERE
  event.pat_event_cd = @patEventCd', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の初回申し込み→依頼事項登録→掲示板情報有り場合、患者イベント情報の更新', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": 1008, "field_name": "staff_cd_list", "replace_var": "@staffCdList"}]');

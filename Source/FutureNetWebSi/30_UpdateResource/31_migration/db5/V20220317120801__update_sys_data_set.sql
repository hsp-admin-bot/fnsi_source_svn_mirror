delete from "sys_data_set" where "sql_cd" in (3110,3106,3108);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (3106, '-- このSQLは3110のSQLを利用する、変更した場合、3110のSQLを変更してください。
WITH taking_title_info AS (
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
  AND (SELECT taking_title FROM taking_title_info) != '''' -- コメントのタイトルを指定済み', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の初回申し込み→依頼事項登録→観察記録(患者イベント情報)_取得', '2022-03-10 09:51:01.157', CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (3108, '-- このSQLは3110のSQLを利用する、変更した場合、3110のSQLを変更してください。
WITH taking_info AS (
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
  AND @patMemoInfo.content != ''''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の初回申し込み→依頼事項登録→掲示板情報_取得', '2022-03-10 09:51:01.157', CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (3110, 'WITH pat_event_cd_info AS (
  -- この部分SQLは3016のSQLです
  WITH taking_title_info AS (
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
    AND (SELECT taking_title FROM taking_title_info) != '''' -- コメントのタイトルを指定済み
)
, bbs_ctl_no_info AS (
  -- この部分SQLは3018のSQLです
  WITH taking_info AS (
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
    AND @patMemoInfo.content != ''''
)
SELECT
  event.pat_event_cd
  , bbs.bbs_ctl_no
FROM pat_event_cd_info AS event, bbs_ctl_no_info AS bbs', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の初回申し込み→依頼事項登録→掲示板情報有り場合、掲示板情報と患者イベント情報の取得', '2022-03-10 09:51:01.157', CURRENT_TIMESTAMP, NULL);

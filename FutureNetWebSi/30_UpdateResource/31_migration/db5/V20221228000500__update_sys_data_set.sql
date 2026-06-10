DELETE FROM ntss.sys_data_set WHERE sql_cd IN (3109);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (3109, 'WITH taking_info AS (
  -- 取込先指定:カンマ区切りで複数指定が可能。0または未設定：取込みなし、1：患者メモ、2：観察記録jsb
 select case when staff_cd like ''%2%'' then ''2'' else ''0'' end  as taking from (
SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = ''@facilityCd''
    AND info ->> ''key1'' = ''ORDER_RECV''
    AND info ->> ''key2'' = ''ORDER_RECV_TAKING'')   as taking_info 
),
bbs_title AS (
  -- 取込先指定:カンマ区切りで複数指定が可能。0または未設定：取込みなし、1：患者メモ、2：観察記録memo
SELECT COALESCE ( NULLIF( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS bbs_title
FROM mst_coop_ini AS ini
CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info
WHERE
	facility_cd = ''@facilityCd''

	AND is_del = ''0''
	AND info ->> ''key1'' = ''ORDER_RECV''
	AND info ->> ''key2'' = ''ORDER_RECV_BBS_TITLE''
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
    , (select bbs_title from bbs_title) AS title
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
    (CASE WHEN (SELECT bbs_life_list_flg FROM bbs_life_list_flg_info) = ''1'' 
      THEN (REPLACE(''@patMemoInfo.content'','' 【'',E''\n【'')) 
      ELSE ''''
      END) AS content
)
, new_bbs_info AS (
  -- 新規データ
  SELECT
    (''@facilityCd'')::TEXT AS facility_cd
    , jsonb_build_object(''target'', ''0'', ''detail'', (''['' || @patId ||'']'')::JSONB) AS pat_info
    , jsonb_build_object(''target'', ARRAY[@staffCd]::integer[], ''read'', ''[]''::JSONB) AS staff_info
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
    , '''' AS notice_fac_cal_end_date
    , ''1''::TEXT AS is_disp_bbs 
    , (''#ffffff'')::TEXT AS color
    , (''<p style=\"font-size: 14pt; font-family: メイリオ;\">'' || (SELECT content FROM content_info) || ''</p>'')::TEXT AS html_content
    , start_time AS notice_fac_cal_start_time
    , '''' AS notice_fac_cal_end_time
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
--   AND (SELECT taking_title FROM taking_title_info) != '''' -- コメントのタイトルを指定済み
  AND (SELECT bbs_flag FROM bbs_flag_info) = ''1'' -- 掲示板出力フラグ＝「1：出力あり」
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の初回申し込み→依頼事項登録→掲示板情報_登録', '2022-03-14 14:46:10.256',CURRENT_TIMESTAMP, '[{"sql_cd": 2020, "field_name": "staff_cd", "replace_var": "@staffCd"}]');

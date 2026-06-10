DELETE FROM ntss.sys_data_set WHERE sql_cd IN (3104,3107,3109);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (3107, 'WITH taking_info AS (
  -- 取込先指定:カンマ区切りで複数指定が可能。0または未設定：取込みなし、1：患者メモ、2：観察記録GCJL
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
        WHEN ''1'' THEN
				case when (''浄化申込情報'' = (select sub_category_name from sub_category_name_info)
				and ''連携通知'' = (select category_name from category_name_info)
				)
				then
				to_jsonb(''<p>'' || REPLACE(''@patMemoInfo.content'','' 【'',''</p><p>【'')||''</p>'')
				else
				to_jsonb('''' || REPLACE(''@patMemoInfo.content'','' 【'',E''\n【'')) 
				end
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
  AND (SELECT taking FROM taking_info) = ''2'' -- 取込先指定＝「2：観察記録」', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の初回申し込み→依頼事項登録→観察記録(患者イベント情報)_登録', '2022-03-14 14:46:10.256',CURRENT_TIMESTAMP, NULL);
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
    , ''血液浄化申込情報受信 であること。'' AS title
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
      THEN (E''\n'' || REPLACE(''@patMemoInfo.content'','' 【'',E''\n【'')) 
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
    , nd.end_date AS notice_fac_cal_end_date
    , ''1''::TEXT AS is_disp_bbs 
    , (''#ffffff'')::TEXT AS color
    , (''<p style=\"font-size: 14pt; font-family: メイリオ;\">'' || (SELECT content FROM content_info) || ''</p>'')::TEXT AS html_content
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
--   AND (SELECT taking_title FROM taking_title_info) != '''' -- コメントのタイトルを指定済み
  AND (SELECT bbs_flag FROM bbs_flag_info) = ''1'' -- 掲示板出力フラグ＝「1：出力あり」
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の初回申し込み→依頼事項登録→掲示板情報_登録', '2022-03-14 14:46:10.256',CURRENT_TIMESTAMP, '[{"sql_cd": 2020, "field_name": "staff_cd", "replace_var": "@staffCd"}]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (3104, 'WITH taking_info AS (
  -- 取込先指定:カンマ区切りで複数指定が可能。0または未設定：取込みなし、1：患者メモ、2：観察記録
 select case when staff_cd like ''%1%'' then ''1'' else ''0'' end  as taking from (
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
)
, memo_id_info AS (
  -- 患者メモの番号:患者メモの番号(1~20を設定する、初期値は1)
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''1'') 
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
--     AND (SELECT taking_title FROM taking_title_info) != '''' -- コメントのタイトルを指定済み
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
    AND (ms->>''ctl_no''::TEXT) = ''1'' -- 患者メモの番号[1]が有り
    AND (SELECT taking FROM taking_info) = ''1'' -- 取込先指定＝「1：患者メモ」
--     AND (SELECT taking_title FROM taking_title_info) != '''' -- コメントのタイトルを指定済み
  ORDER BY order_no ASC LIMIT 1
),
-- memo_info AS (
-- select
-- case when 
-- (memo_info ->> ''title'') = (select taking_title from taking_title_info)
-- then (memo_info ->> ''content'')::text
-- else '''' end as memo
-- from pat_main  pm
--  CROSS JOIN LATERAL json_array_elements(pm.pat_memo_info ::json) AS memo_info 
-- where 
--      pat_id = @patId
-- AND  facility_cd = ''@facilityCd''
-- AND  memo_info ->> ''ctl_no'' = (SELECT memo_id FROM memo_id_info)
-- AND  is_del = ''0'' 
-- )
 mstInfo AS (
  SELECT
		idx,
	 ctl_no,
    ''血液浄化申込情報 であること''::text AS title ,
		REPLACE(''@patMemoInfo.content'','' 【'',''\n【'')
     AS content
		 from mstInitInfo
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
  AND (SELECT content FROM mstInfo) IS NOT NULL', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の初回申し込み→依頼事項登録→患者メモ', '2022-03-14 14:46:10.256',CURRENT_TIMESTAMP, NULL);

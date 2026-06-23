DELETE FROM ntss.sys_data_set where sql_cd in (3104);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (3104, 'WITH taking_title_info AS (
  -- コメントのタイトルを指定※タイトルが未設定の場合、対象の項目属性は取込み対象外とします。meimo
  SELECT
     CASE TRIM(ini_info ->> ''value'') 
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
)
, taking_info AS (
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
    AND (ms->>''ctl_no''::TEXT) = ''1'' -- 患者メモの番号[1]が有り
    AND (SELECT taking FROM taking_info) = ''1'' -- 取込先指定＝「1：患者メモ」
    AND (SELECT taking_title FROM taking_title_info) != '''' -- コメントのタイトルを指定済み
  ORDER BY order_no ASC LIMIT 1
),
memo_info AS (
select
case when 
(memo_info ->> ''title'') = (select taking_title from taking_title_info)
then (memo_info ->> ''content'')::text
else '''' end as memo
from pat_main  pm
 CROSS JOIN LATERAL json_array_elements(pm.pat_memo_info ::json) AS memo_info 
where 
     pat_id = @patId
AND  facility_cd = ''@facilityCd''
AND  memo_info ->> ''ctl_no'' = (SELECT memo_id FROM memo_id_info)
AND  is_del = ''0'' 
)
, mstInfo AS (
  SELECT
    idx
    , ctl_no 
    , (SELECT taking_title FROM taking_title_info) AS title 
    , CASE WHEN (SELECT memo from memo_info)='''' THEN 
    (''【'' || (SELECT taking_title FROM taking_title_info) || ''】'' || ''@patMemoInfo.content'') 
      ELSE
        REPLACE((select memo from memo_info), CHR(10), ''\n'') || ''\n''  || (''【'' || (SELECT taking_title FROM taking_title_info) || ''】'' || ''@patMemoInfo.content'') 
      END AS content
  FROM
    mstInitInfo
  WHERE
    ''@patMemoInfo.content'' != ''''
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
  AND (SELECT idx FROM mstInfo) IS NOT NULL', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の初回申し込み→依頼事項登録→患者メモ', '2022-03-14 14:46:10.256',CURRENT_TIMESTAMP, NULL);

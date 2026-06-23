DELETE FROM "ntss"."sys_data_set" where "sql_cd" IN (-99986);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-99986, 'WITH report_send_type_info AS ( 
  -- レポートファイル連携方式：0：HTML本文送信連携 1：URL連携
  SELECT
    1 AS order_no
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS report_send_type 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''REPORT_SEND'' 
    AND info ->> ''key2'' = ''REPORT_SEND_TYPE'' 
  UNION 
  SELECT
    2 AS order_no
    , ''0'' AS report_send_type 
  ORDER BY
    order_no ASC LIMIT 1
) 
, permission_change_info AS ( 
  -- パーミッション変更：0：しない、1：する
  SELECT
    1 AS order_no
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS permission_change 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''REPORT_SEND'' 
    AND info ->> ''key2'' = ''PERMISSION_CHANGE'' 
  UNION 
  SELECT
    2 AS order_no
    , ''0'' AS permission_change 
  ORDER BY
    order_no ASC LIMIT 1
) 
, sentence_type_info AS ( 
  -- 文書種別
  SELECT
    1 AS order_no
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS sentence_type 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''REPORT_SEND'' 
    AND info ->> ''key2'' = ''SENTENCE_TYPE'' 
  UNION 
  SELECT
    2 AS order_no
    , '''' AS sentence_type 
  ORDER BY
    order_no ASC LIMIT 1
) 
, document_no_setting_info AS (
  -- 文書番号末尾設定:0：無し、1：01固定
  SELECT
    1 AS order_no
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS document_no_setting 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''FJI_COM_INFO'' 
    AND info ->> ''key2'' = ''DOCUMENT_NO_SETTING'' 
  UNION 
  SELECT
    2 AS order_no
    , '''' AS document_no_setting 
  ORDER BY
    order_no ASC LIMIT 1
) 
, ord_no_info AS (
  SELECT
    TO_CHAR((CASE WHEN rst_fn_dialysis_no IS NOT NULL AND rst_fn_dialysis_no > 0 THEN rst_fn_dialysis_no ELSE ord_no END), ''FM099999999999999999'') AS ord_no
  FROM
    ord_main AS ord
  WHERE
    ord_no = @ordNo
) 
SELECT 
  SUBSTR(RPAD(COALESCE(NULLIF((SELECT sentence_type FROM sentence_type_info), ''''), ''''), 8, '' ''), 1, 4)
  || LPAD(RIGHT(@coopOrdNo, 8), 8, ''0'')
  || CASE WHEN COALESCE(NULLIF((SELECT document_no_setting FROM document_no_setting_info), ''''), ''0'') = ''0'' 
     THEN ord_no
     ELSE RIGHT(ord_no, 16) || ''01''
     END 
  AS ftp_path 
  , COALESCE(NULLIF((SELECT permission_change FROM permission_change_info), ''''), ''0'') AS permission_change
FROM ord_no_info 
WHERE (SELECT report_send_type FROM report_send_type_info) = ''0'' -- 0：HTML本文送信連携 
UNION 
SELECT 
  (''|NULL|'')::TEXT AS ftp_path -- URL連携の場合、空の文字列識別子を返します。
  , (''0'')::TEXT AS permission_change -- URL連携の場合、「0：しない」を返します。
WHERE (SELECT report_send_type FROM report_send_type_info) != ''0'' -- 1：URL連携 
', 2, '[]', '0', '{"applications": [4]}', NULL, '富士通→HTML 本文送信→PDF送信の際→FTPのフォルダを取得する',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP, NULL);

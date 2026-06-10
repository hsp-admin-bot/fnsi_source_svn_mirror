delete from "sys_data_set" where "sql_cd" = -99986;
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-99986, 'WITH sentence_type_info AS ( 
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
    AND info ->> ''key1'' = ''DOCUMENT_NO_SETTING'' 
    AND info ->> ''key2'' = ''FJI_COM_INFO'' 
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
     END AS ftp_path
FROM ord_no_info', 2, '[]', '0', '{"applications": [4]}', NULL, '富士通→HTML 本文送信→PDF送信の際→FTPのフォルダを取得する', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

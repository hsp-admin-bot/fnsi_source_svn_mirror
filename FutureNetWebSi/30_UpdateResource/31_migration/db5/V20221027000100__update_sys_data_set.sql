delete from "sys_data_set" where "sql_cd" = -55;
INSERT INTO "sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-55, 'WITH sentence_type_info AS ( 
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
    TO_CHAR((CASE WHEN rst_fn_dialysis_no IS NOT NULL AND rst_fn_dialysis_no > 0 THEN rst_fn_dialysis_no ELSE ord_no END), ''FM099999999999999'') AS ord_no
  FROM
    ord_main AS ord
  WHERE
    ord_no = @ordNo
)
, crud_info AS (
  -- 作成更新区分を取得
  SELECT crud FROM sys_coop_journal WHERE ctl_no = @ctlNo
)
, del_cnt_info AS (
-- 削除回数（ゼロ詰め3桁）
  SELECT CASE WHEN (SELECT crud FROM crud_info) = ''D'' THEN TO_CHAR(COUNT(1) - 1, ''FM099'') ELSE TO_CHAR(COUNT(1), ''FM099'') END AS del_cnt
    FROM ord_coop_no AS coopno
   WHERE coopno.facility_cd = @facilityCd AND coopno.pat_id = @patId AND coopno.ord_no= @ordNo AND coopno.coop_cd = ''rep_dial'' AND coopno.is_del = ''1'' 
)
SELECT
  SUBSTR(RPAD(COALESCE(NULLIF((SELECT sentence_type FROM sentence_type_info), ''''), ''''), 8, '' ''), 1, 4) AS sentence_type
  , (SELECT del_cnt FROM del_cnt_info) || CASE WHEN COALESCE(NULLIF((SELECT document_no_setting FROM document_no_setting_info), ''''), ''0'') = ''0'' 
    THEN ord_no
    ELSE RIGHT(ord_no, 13) || ''01''
    END AS ord_no
FROM ord_no_info', 2, '[]', '0', '{"applications": [4]}', NULL, '富士通）透析レポートの文書番号を取得', '2022-04-04 16:37:06.134', CURRENT_TIMESTAMP, NULL);

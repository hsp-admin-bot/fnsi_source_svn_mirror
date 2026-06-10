delete from "sys_data_set" where "sql_cd" in (-1004, -1003);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-1004, 'SELECT
  CASE 
    WHEN LENGTH(LTRIM(hosp_pat_id, ''0'')) >= 10 
      THEN LTRIM(hosp_pat_id, ''0'') 
    ELSE LPAD(LTRIM(hosp_pat_id, ''0''), 10, ''0'') 
    END AS hosp_pat_id10
  , CASE 
    WHEN LENGTH(LTRIM(hosp_pat_id, ''0'')) >= 12 
      THEN LTRIM(hosp_pat_id, ''0'') 
    ELSE LPAD(LTRIM(hosp_pat_id, ''0''), 12, ''0'') 
    END AS hosp_pat_id12 
FROM
  sys_coop_journal 
WHERE
  ctl_no = @ctlNo', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(送信用)患者属性連携の患者ID[桁数10(前0埋め),桁数12(前0埋め),]を取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-1003, 'SELECT
  CASE TRIM(ini_info ->> ''value'') 
    WHEN '''' THEN TRIM(ini_info ->> ''default_v'') 
    WHEN ''NULL'' THEN TRIM(ini_info ->> ''default_v'') 
    ELSE TRIM(ini_info ->> ''value'') 
    END AS system_id 
FROM
  mst_coop_ini AS ini 
  CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
WHERE
  ini.is_del = ''0'' 
  AND ini.facility_cd = @facilityCd 
  AND TRIM(ini_info ->> ''key1'') = ''NECIS_COMMON'' 
  AND TRIM(ini_info ->> ''key2'') = ''SYSTEM_ID''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(送信用)NEC-iS(MegaOakiS)要求応答型のリクエストの<SystemId>の取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

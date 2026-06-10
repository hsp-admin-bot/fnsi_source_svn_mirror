DELETE FROM "ntss"."sys_data_set" where "sql_cd" IN (-107);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-107, 'SELECT
      COALESCE( 
        NULLIF(info ->> ''value'', '''')
        , info ->> ''default_v''
      ) AS treatment_cd
    FROM
      mst_coop_ini AS ini 
      CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
    WHERE
      facility_cd = @facilityCd 
      AND is_del = ''0'' 
      AND info ->> ''key1'' = ''TREATMENT'' 
      AND info ->> ''key2'' = ''IN_HOSPITAL_CD'' limit 1', 2, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）実績）透析条件', '2020-03-17 15:42:41', CURRENT_TIMESTAMP, NULL);
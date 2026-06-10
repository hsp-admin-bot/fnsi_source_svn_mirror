DELETE FROM "ntss"."sys_data_set" where "sql_cd" IN (-106);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-106, 'with CONV_INOUT_TO_KARTE as (
(SELECT
      COALESCE( 
        NULLIF(info ->> ''value'', '''')
        , info ->> ''default_v''
      ) AS staff_cd ,
	  info ->> ''key2'' AS CONV_INOUT
    FROM
      mst_coop_ini AS ini 
      CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
    WHERE
      facility_cd = @facilityCd 
      AND is_del = ''0'' 
      AND info ->> ''key1'' = ''CONV_INOUT_TO_KARTE'' 
      AND info ->> ''key2'' = ''0'' limit 1)
UNION ALL
(SELECT
      COALESCE( 
        NULLIF(info ->> ''value'', '''')
        , info ->> ''default_v''
      ) AS staff_cd ,
	  info ->> ''key2'' AS CONV_INOUT
    FROM
      mst_coop_ini AS ini 
      CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
    WHERE
      facility_cd = @facilityCd
      AND is_del = ''0'' 
      AND info ->> ''key1'' = ''CONV_INOUT_TO_KARTE'' 
      AND info ->> ''key2'' = ''1'' limit 1)
)

SELECT
  CONV_INOUT_TO_KARTE.staff_cd AS in_out_class
FROM
  ord_main LEFT JOIN CONV_INOUT_TO_KARTE ON
  ord_main.rst_in_out_class || '''' = CONV_INOUT_TO_KARTE.CONV_INOUT || ''''
WHERE
  ord_no = @ordNo', 2, '[{}]', '0', '{"applications": [4]}', '{"classes": []}', '透析実績：入外区分取得', '2022-06-02 11:22:26', CURRENT_TIMESTAMP, NULL);
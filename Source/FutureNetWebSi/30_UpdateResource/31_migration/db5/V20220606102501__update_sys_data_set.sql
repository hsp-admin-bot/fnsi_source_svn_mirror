UPDATE "ntss"."sys_data_set" SET "sql" = 'with CONV_INOUT_TO_KARTE as (
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
      facility_cd = ''nkknkk'' 
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
      facility_cd = ''nkknkk'' 
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
  ord_no = @ordNo', "db_class" = 2, "detail" = '[{}]', "can_repeat" = '0', "use_application" = '{"applications": [4]}', "report_class" = '{"classes": []}', "memo" = '透析実績：入外区分取得', "reg_date" = '2022-06-02 11:22:26', "up_date" = '2022-06-02 05:35:07.34', "pre_sql_info" = NULL WHERE "sql_cd" = -106;

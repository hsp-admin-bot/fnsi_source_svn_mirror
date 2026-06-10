UPDATE "ntss"."sys_data_set" SET "sql" = 'WITH send_range_info AS ( 
  SELECT
    CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN TRIM(ini_info ->> ''default_v'') 
      WHEN ''NULL'' THEN TRIM(ini_info ->> ''default_v'') 
      ELSE TRIM(ini_info ->> ''value'') 
      END AS day_cnt 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = @facilityCd
    AND TRIM(ini_info ->> ''key1'') = ''NECIS_EXAMSND'' 
    AND TRIM(ini_info ->> ''key2'') = ''SEND_RANGE''
) 
, system_id_info AS ( 
  SELECT
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
    AND TRIM(ini_info ->> ''key2'') = ''SYSTEM_ID''
) 
SELECT
  TO_CHAR((CURRENT_TIMESTAMP - (TO_CHAR(TO_NUMBER(COALESCE(NULLIF((SELECT DAY_CNT FROM send_range_info), ''''), ''1'') , ''FM99'') - 1, ''FM99'') || '' day'') ::INTERVAL) , ''YYYYMMDD'') AS start_date
  , TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDD'') AS end_date
  , (SELECT system_id FROM system_id_info) AS system_id
'
WHERE "sql_cd" = -1003;
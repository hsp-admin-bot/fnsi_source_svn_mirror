DELETE FROM sys_data_set
WHERE sql_cd IN (-500088);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500088, 'WITH pat_info AS ( 
  SELECT
    CASE 
      WHEN EXTRACT(DOW FROM @treatDate ::TIMESTAMP) = ''0'' 
        THEN 7 
      ELSE EXTRACT(DOW FROM @treatDate ::TIMESTAMP) 
    END AS weekday,
    tare_info::jsonb,
    off_water_info::jsonb
  FROM
    pat_main AS pm 
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0'' 
    AND pat_id =  @patId
)
SELECT 
    COALESCE(tare_info_data.value, jsonb_build_object( 
      ''name_1'', NULL,
      ''name_2'', NULL,
      ''name_3'', NULL,
      ''name_4'', NULL,
      ''name_5'', NULL,
      ''weight_1'', NULL,
      ''weight_2'', NULL,
      ''weight_3'', NULL,
      ''weight_4'', NULL,
      ''weight_5'', NULL
    )) AS ind_tare_info,
    COALESCE(off_water_info_data.value, jsonb_build_object( 
      ''name_1'', NULL,
      ''name_2'', NULL,
      ''name_3'', NULL,
      ''name_4'', NULL,
      ''name_5'', NULL,
      ''weight_1'', NULL,
      ''weight_2'', NULL,
      ''weight_3'', NULL,
      ''weight_4'', NULL,
      ''weight_5'', NULL
    )) AS ind_off_water_info
FROM 
  pat_info
LEFT JOIN 
  jsonb_each(pat_info.tare_info) AS tare_info_data(key, value)
  ON TO_NUMBER(tare_info_data.key, ''999999999999999999'') = weekday
LEFT JOIN 
  jsonb_each(pat_info.off_water_info) AS off_water_info_data(key, value) 
  ON TO_NUMBER(off_water_info_data.key, ''999999999999999999'') = weekday
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのオーダ受け(INSERT)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
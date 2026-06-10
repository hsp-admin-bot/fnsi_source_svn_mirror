DELETE FROM ntss.sys_data_set
WHERE sql_cd=-500018;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500018, '
WITH ssi_in_hospital_cd AS ( 
  SELECT
    info->>''key2'' AS key2
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS VALUE 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0'' 
    AND COALESCE(info->>''key0'','''') = @key0
    AND info->>''key1'' = ''SSI_ORDER_RECV''
    AND info->>''key2'' = ''IN_HOSPITAL_CD''
) 
, class_cd_ini AS (
  SELECT
    COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS VALUE 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0'' 
    AND is_disp = ''1'' 
    AND COALESCE(info->>''key0'','''') = @key0
    AND info->>''key1'' = ''SSI_CLASS_NAME''
    AND info->>''key2'' = ''SOLUSION'' -- 透析液''
) 
, class_cd_info AS (
  SELECT
    class_cd AS class_cd
  FROM mst_medicine_class
  WHERE 
    facility_cd = @facilityCd
    AND is_del = ''0'' 
    AND is_disp = ''1'' 
    AND class_name = (SELECT VALUE FROM class_cd_ini)
  LIMIT 1
)
, is_new AS (
  SELECT 
    CASE 
        WHEN (@indCondInfo.015.value='''') 
        THEN 0 
        ELSE 1 
    END AS is_new
)
INSERT INTO mst_medicine( 
      facility_cd
  ,   fn_medicine_cd
  ,   standard_medicine_cd
  ,   is_trial
  ,   medicine_name
  ,   medicine_short_name
  ,   unit
  ,   unit_second
  ,   class_cd
  ,   is_shot
  ,   use_start_date
  ,   use_end_date
  ,   is_medicated
  ,   unit_converted_amount
  ,   unit_converted_amount_second
  ,   anticoagulant_original_quantity
  ,   after_anticoagulant_quantity
  ,   in_hospital_cd_1
  ,   in_hospital_cd_2
  ,   in_hospital_cd_3
  ,   is_disp
  ,   is_del
  ,   reg_date
  ,   up_date
  ,   is_exchange
  ,   medicate_timing_cd
  ,   procedure_cd
  ,   unit_decimal_point
  ,   unit_decimal_point_second
  ,   in_hospital_cd_4
) 
SELECT
      @facilityCd
  ,   NULL
  ,   NULL
  ,   ''0''
  ,   @indCondInfo.015.name
  ,   NULL
  ,   NULL
  ,   @indCondInfo.015.unit
  ,   (SELECT class_cd FROM class_cd_info)
  ,   ''0''
  ,   NULL
  ,   NULL
  ,   ''0''
  ,   ''0''
  ,   ''0''
  ,   ''0''
  ,   ''0''
  ,   CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN @indCondInfo.015.value
        WHEN ''2'' THEN NULL
        WHEN ''3'' THEN NULL
        WHEN ''4'' THEN NULL
      END
  ,   CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN NULL
        WHEN ''2'' THEN @indCondInfo.015.value
        WHEN ''3'' THEN NULL
        WHEN ''4'' THEN NULL
      END
  ,   CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN NULL
        WHEN ''2'' THEN NULL
        WHEN ''3'' THEN @indCondInfo.015.value
        WHEN ''4'' THEN NULL
      END
  ,   ''1''
  ,   ''0''
  ,   CURRENT_TIMESTAMP
  ,   CURRENT_TIMESTAMP
  ,   ''0''
  ,   NULL
  ,   NULL
  ,   ''0''
  ,   ''0''
  ,   CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN NULL
        WHEN ''2'' THEN NULL
        WHEN ''3'' THEN NULL
        WHEN ''4'' THEN @indCondInfo.015.value
      END
FROM is_new
WHERE is_new = 1', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの薬剤(INSERT)', '2025-03-17 09:41:58.788', CURRENT_TIMESTAMP, NULL);

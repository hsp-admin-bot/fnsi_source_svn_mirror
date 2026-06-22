DELETE FROM ntss.sys_data_set
WHERE sql_cd=-500026;
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500026, 'WITH master_define AS ( 
  select
    md.fields->>''physical_name'' as physical_name,
    md.fields->>''defaultValue'' as defaultValue
  from
    (
    select
      jsonb_array_elements(column_info->''fields'') as fields
    from
      sys_master_define
    where
      master_physical_name = ''mst_dialyzer''
  ) as md
) 
,dialyzer_info AS (
  SELECT
    info->>''key2'' AS key2
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS VALUE 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0'' 
    AND is_disp = ''1'' 
    AND COALESCE(info->>''key0'','''') = @key0
    AND info->>''key1'' = ''SSI_ORDER_RECV''
)
, ssi_order_treat_info AS ( 
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
    AND info->>''key1'' = ''SSI_ORDER_TREAT''
    AND info->>''key2'' = @indTreatmentName
)
, is_membrane AS (
  SELECT 
    CASE 
        WHEN EXISTS (
        SELECT 1 FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0'' 
    AND is_disp = ''1'' 
    AND COALESCE(info->>''key0'','''') = @key0
    AND info->>''key1'' = ''SSI_ORDER_MEMBRANE''
    AND info->>''key2'' LIKE ''TREAT%''
    AND COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'')  = (SELECT VALUE FROM ssi_order_treat_info)
    ) 
        THEN 1 
        ELSE 0 
    END AS is_membrane
)
, ssi_in_hospital_cd AS ( 
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

INSERT INTO mst_dialyzer( 
      facility_cd
  ,   fn_dialyzer_cd
  ,   maker
  ,   model_number
  ,   dialyzer_type
  ,   function_class
  ,   area
  ,   ufr
  ,   koa
  ,   material
  ,   wetdry
  ,   sterilization
  ,   ufr_warning_max
  ,   ufr_warning_min
  ,   ufr_warning_reduction
  ,   bloodamt
  ,   alqd_flood_vol
  ,   urea_clearance
  ,   gas_purge_time
  ,   substituent_wash_amt
  ,   membrane_wash
  ,   in_number
  ,   use_start_date
  ,   use_end_date
  ,   in_hospital_cd_1
  ,   in_hospital_cd_2
  ,   in_hospital_cd_3
  ,   is_disp
  ,   is_del
  ,   reg_date
  ,   up_date
  ,   in_hospital_cd_4
) 
SELECT
      @facilityCd
  ,   NULL
  ,   NULL
  ,   @indCondInfo.005.name
  ,   (SELECT defaultValue FROM master_define where physical_name = ''dialyzer_type'')
  ,   NULL
  ,   (SELECT defaultValue FROM master_define where physical_name = ''area'')::numeric 
  ,   (SELECT defaultValue FROM master_define where physical_name = ''ufr'')::numeric 
  ,   (SELECT defaultValue FROM master_define where physical_name = ''koa'')::numeric 
  ,   NULL
  ,   (SELECT defaultValue FROM master_define where physical_name = ''wetdry'')::numeric 
  ,   NULL
  ,   (SELECT VALUE FROM dialyzer_info where key2 = ''UFRWARNINGMAX'')::numeric 
  ,   (SELECT VALUE FROM dialyzer_info where key2 = ''UFRWARNINGMIN'')::numeric 
  ,   (SELECT VALUE FROM dialyzer_info where key2 = ''UFRWARNINGREDUC'')::numeric 
  ,   (SELECT defaultValue FROM master_define where physical_name = ''bloodamt'')::numeric 
  ,   (SELECT defaultValue FROM master_define where physical_name = ''alqd_flood_vol'')::numeric 
  ,   (SELECT defaultValue FROM master_define where physical_name = ''urea_clearance'')::numeric 
  ,   (SELECT defaultValue FROM master_define where physical_name = ''gas_purge_time'')::numeric 
  ,   (SELECT defaultValue FROM master_define where physical_name = ''substituent_wash_amt'')::numeric 
  ,   (SELECT defaultValue FROM master_define where physical_name = ''membrane_wash'')::numeric 
  ,   (SELECT defaultValue FROM master_define where physical_name = ''in_number'')::numeric 
  ,   NULL
  ,   NULL
  ,   CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN @indCondInfo.005.value
        WHEN ''2'' THEN NULL
        WHEN ''3'' THEN NULL
        WHEN ''4'' THEN NULL
      END
  ,   CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN NULL
        WHEN ''2'' THEN @indCondInfo.005.value
        WHEN ''3'' THEN NULL
        WHEN ''4'' THEN NULL
      END
  ,   CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN NULL
        WHEN ''2'' THEN NULL
        WHEN ''3'' THEN @indCondInfo.005.value
        WHEN ''4'' THEN NULL
      END
  ,   ''1''
  ,   ''0''
  ,   CURRENT_TIMESTAMP
  ,   CURRENT_TIMESTAMP
  ,   CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN NULL
        WHEN ''2'' THEN NULL
        WHEN ''3'' THEN NULL
        WHEN ''4'' THEN @indCondInfo.005.value
      END
  FROM is_membrane
  WHERE is_membrane = 0 -- 膜使用する治療方法以外の場合のみ登録
  AND @indCondInfo.005.name <> ''''
  AND @indCondInfo.005.value <> ''''
  ;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのダイアライザ(INSERT)', '2025-05-14 16:52:24.700', '2025-05-14 16:52:24.700', '[{"sql_cd": -500060}]'::jsonb);

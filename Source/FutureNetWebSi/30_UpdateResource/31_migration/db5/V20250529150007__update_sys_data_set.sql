DELETE FROM sys_data_set WHERE sql_cd IN (-500040);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500040, 'WITH ssi_in_hospital_cd AS ( 
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
INSERT INTO mst_va( 
      facility_cd
  ,   fn_va_cd
  ,   va_name
  ,   va_direct
  ,   in_hospital_cd_1
  ,   in_hospital_cd_2
  ,   is_disp
  ,   is_del
  ,   reg_date
  ,   up_date
) 
SELECT
      @facilityCd
  ,   NULL
  ,   @indVaName
  ,   CASE @indVaPart
        WHEN ''0'' THEN ''2'' -- 右
        WHEN ''1'' THEN ''1'' -- 左
        WHEN ''2'' THEN ''0'' -- 両方
        WHEN ''3'' THEN ''3'' -- なし
        ELSE ''-'' -- 不明
      END
  ,   CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN @indVaCd
        WHEN ''2'' THEN NULL
      END
  ,   CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN NULL
        WHEN ''2'' THEN @indVaCd
      END
  ,   ''1''
  ,   ''0''
  ,   CURRENT_TIMESTAMP
  ,   CURRENT_TIMESTAMP
WHERE @indVaCd <> ''''
  AND @indVaName <> ''''', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのVA(INSERT)', '2025-05-28 20:58:27.087', CURRENT_TIMESTAMP, NULL);
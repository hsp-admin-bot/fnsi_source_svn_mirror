DELETE FROM sys_data_set WHERE sql_cd IN (-500093, -500097, -500098, -500099, -500103, -500105);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500093, 'SELECT
  1 AS flg
WHERE
  (
    NULLIF(@indCondInfo.004.value, '''') IS NULL
  )
  OR
  (
    0 <= (COALESCE(NULLIF(@indCondInfo.004.value, '''')::NUMERIC, 0) / 100)
    AND 40 > (COALESCE(NULLIF(@indCondInfo.004.value, '''')::NUMERIC, 0) / 100)
  );
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの入力値チェック(除水量制限)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500097, 'WITH ssi_order_recv_info AS ( 
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
)
SELECT
  1 AS flg
WHERE
  (
    NULLIF(@ind_off_water_info.ind_off_water_info.weight_5,'''') IS NULL
  )
  OR
  (
    0 <= COALESCE(NULLIF(@ind_off_water_info.ind_off_water_info.weight_5,'''')::NUMERIC / 10,0)
    AND 20 >= COALESCE(NULLIF(@ind_off_water_info.ind_off_water_info.weight_5,'''')::NUMERIC / 10,0)
  )
  OR
  (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''IPONESHOT'')<>''1'';
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの入力値チェック(IPワンショット量)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500098, 'WITH ssi_order_recv_info AS ( 
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
)
SELECT
  1 AS flg
WHERE
  (
    NULLIF(@indCondInfo.033.value, '''') IS NULL
  )
  OR
  (
    0 <= (COALESCE(NULLIF(@indCondInfo.033.value, '''')::NUMERIC, 0) / 10)
    AND 10 >= (COALESCE(NULLIF(@indCondInfo.033.value, '''')::NUMERIC, 0) / 10)
  )
  OR 
  (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''IPSPEED'')<>''1''
  ;
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの入力値チェック(IP速度)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500103, 'WITH ssi_order_recv_info AS ( 
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
)
SELECT
  1 AS flg
WHERE
  (
    NULLIF(@ind_tare_info.ind_tare_info.weight_5, '''') IS NULL
  )
  OR
  (
    0 <= (NULLIF(@ind_tare_info.ind_tare_info.weight_5, ''''))::int
    AND 120 >= (NULLIF(@ind_tare_info.ind_tare_info.weight_5, ''''))::int
  )
  OR
  (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''IPPWROK'')<>''1'';
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの入力値チェック(IP電源OKモニタ切り時間)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500099, 'WITH ssi_order_recv_info AS ( 
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
)
SELECT
  1 AS flg
WHERE
  (
    NULLIF(@ind_tare_info.ind_tare_info.weight_4, '''') IS NULL
  )
  OR
  (
    0 <= COALESCE(NULLIF(@ind_tare_info.ind_tare_info.weight_4, '''')::NUMERIC, 0)
    AND 700 >= COALESCE(NULLIF(@ind_tare_info.ind_tare_info.weight_4, '''')::NUMERIC, 0)
  )
  OR 
  (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''SOLUTION'')<>''1''
  ;
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの入力値チェック(透析液流量)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500105, 'WITH ssi_order_recv_info AS ( 
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
    AND info->>''key2'' IN (''OFFWATER1'',''OFFWATER2'',''OFFWATER3'',''OFFWATER4'',''OFFWATER5'',''USE_SUPLIQUID'',''IPONESHOT'')
)
SELECT
  1 AS flg
WHERE
  (
    NULLIF(@ind_off_water_info,'''') IS NULL
  )
  OR
  (
    0 <= COALESCE(NULLIF(@ind_off_water_info, '''')::NUMERIC, 0)
    AND 30000 >= COALESCE(NULLIF(@ind_off_water_info, '''')::NUMERIC, 0)
  )
  OR
  CASE @weight_num
  WHEN ''1'' THEN 
  (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''OFFWATER1'')<>''1''
  WHEN ''2'' THEN 
  (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''OFFWATER2'')<>''1''
  WHEN ''3'' THEN 
  (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''OFFWATER3'')<>''1''
  WHEN ''4'' THEN 
  ((SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''OFFWATER4'')<>''1'')
  OR ((SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''USE_SUPLIQUID'') = ''1'')
  WHEN ''5'' THEN 
  ((SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''OFFWATER5'')<>''1'')
  OR ((SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''IPONESHOT'') = ''1'')
  ELSE TRUE
  END;
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの入力値チェック(徐水量制限)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
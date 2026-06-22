DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-500091,-500092,-500093,-500094,-500095,-500096,-500097,-500098,-500099,-500100,-500101,-500102,-500103,-500104,-500105,-500106,-500107);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500091, '
SELECT
  1 AS flg
WHERE
  (
    NULLIF(@indCondInfo.039.value, '''') IS NULL
  )
  OR
  (
    0 <= (NULLIF(@indCondInfo.039.value, ''''))::int
    AND 300 >= (NULLIF(@indCondInfo.039.value, ''''))::int
  );
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの入力値チェック(DW)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500092, '
SELECT
  1 AS flg
WHERE
  (
    NULLIF(@indCondInfo.039.value, '''') IS NULL
  )
  OR
  (
    0 <= (NULLIF(@indCondInfo.039.value, ''''))::int
    AND 300 >= (NULLIF(@indCondInfo.039.value, ''''))::int
  );
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの入力値チェック(目標体重)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500093, '
SELECT
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
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500094, '
SELECT
  1 AS flg
WHERE
  (
    NULLIF(@indCondInfo.014.value, '''') IS NULL
  )
  OR
  (
    0 <= (NULLIF(@indCondInfo.014.value, ''''))::int
    AND 600 >= (NULLIF(@indCondInfo.014.value, ''''))::int
  );
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの入力値チェック(血流量)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500095, '
SELECT
  1 AS flg
WHERE
  (
    NULLIF(@indCondInfo.026.value, '''') IS NULL
  )
  OR
  (
    0 <= (NULLIF(@indCondInfo.026.value, ''''))::int
    AND 9999999 >= (NULLIF(@indCondInfo.026.value, ''''))::int
  );
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの入力値チェック(抗凝固剤ワンショット量)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500096, '
SELECT
  1 AS flg
WHERE
  (
    NULLIF(@indCondInfo.027.value, '''') IS NULL
  )
  OR
  (
    0 <= (NULLIF(@indCondInfo.027.value, ''''))::int
    AND 9999999 >= (NULLIF(@indCondInfo.027.value, ''''))::int
  );
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの入力値チェック(抗凝固剤持続総量)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500097, '
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
  );
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの入力値チェック(IPワンショット量)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500098, '
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
  );
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの入力値チェック(IP速度)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500099, '
SELECT
  1 AS flg
WHERE
  (
    NULLIF(@indCondInfo.017.value, '''') IS NULL
  )
  OR
  (
    0 <= (NULLIF(@indCondInfo.017.value, ''''))::int
    AND 700 >= (NULLIF(@indCondInfo.017.value, ''''))::int
  );
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの入力値チェック(透析液流量)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500100, '
SELECT
  1 AS flg
WHERE
  (
    NULLIF(@indCondInfo.018.value, '''') IS NULL
  )
  OR
  (
    33 <= (COALESCE(NULLIF(@indCondInfo.018.value, '''')::NUMERIC, 0) / 10)
    AND 40 >= (COALESCE(NULLIF(@indCondInfo.018.value, '''')::NUMERIC, 0) / 10)
  );
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの入力値チェック(透析液温度)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500101, '
SELECT
  1 AS flg
WHERE
  (
    NULLIF(@indCondInfo.022.value, '''') IS NULL
  )
  OR
  (
    0 <= (NULLIF(@indCondInfo.022.value, ''''))::int
    AND 99999 >= (NULLIF(@indCondInfo.022.value, ''''))::int
  );
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの入力値チェック(補液使用数)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500102, 'WITH ssi_order_treat_info AS ( 
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
),
ssi_order_recv_info AS ( 
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
),
ind_cond_info021 AS (
  SELECT
    CASE
      WHEN LTRIM(@ind_off_water_info.ind_off_water_info.weight_4, ''0'')
           = LTRIM((SELECT VALUE
                      FROM ssi_order_recv_info
                     WHERE key2 = ''SUPLIQUID_BEFORE_CD''), ''0'')
      THEN ''1''
      WHEN LTRIM(@ind_off_water_info.ind_off_water_info.weight_4, ''0'')
           = LTRIM((SELECT VALUE
                      FROM ssi_order_recv_info
                     WHERE key2 = ''SUPLIQUID_AFTER_CD''), ''0'')
      THEN ''0''
      ELSE ''1''
    END                                             AS indCondInfo021
),
ssi_in_hospital_cd AS ( 
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
) ,
calc_value AS (
  SELECT
    CASE 
      WHEN LTRIM(@indCondInfo.020.value, ''0'') = '''' AND LTRIM(@indCondInfo.024.value, ''0'') = '''' THEN ''0''
      WHEN LTRIM(@indCondInfo.020.value, ''0'') = '''' AND LTRIM(@indCondInfo.024.value, ''0'') <> '''' THEN  TO_NUMBER(@indCondInfo.024.value, ''FM999999999999999999'') / 100 * (TO_NUMBER(@indCondInfo.001.value, ''FM999999999999999999'') / 60)
      ELSE CAST(TO_NUMBER(@indCondInfo.020.value, ''FM999999999999999999'') / 10 AS FLOAT)
    END AS replenisher_amount,
    CASE 
      WHEN LTRIM(@indCondInfo.020.value, ''0'') = '''' AND LTRIM(@indCondInfo.024.value, ''0'') = '''' THEN ''0''
      WHEN LTRIM(@indCondInfo.020.value, ''0'') <> '''' AND LTRIM(@indCondInfo.024.value, ''0'') = '''' THEN  TO_NUMBER(@indCondInfo.020.value, ''FM999999999999999999'') / 10 / (TO_NUMBER(@indCondInfo.001.value, ''FM999999999999999999'') / 60)
      ELSE CAST(TO_NUMBER(@indCondInfo.024.value, ''FM999999999999999999'') / 100 AS FLOAT)
    END AS replenisher_speed
),
pat_limit AS (
  SELECT 
  (device_set_info#>>''{"ope","dev","A","185"}'')::numeric AS pat_max_limit_hdf,
  (device_set_info#>>''{"ope","dev","A","186"}'')::numeric AS pat_max_limit_hf,
  (device_set_info#>>''{"ope","dev","B","30"}'')::numeric AS pat_min_limit_hd_plus,
  (device_set_info#>>''{"ope","dev","A","396"}'')::numeric AS pat_max_limit_ohdf,
  (device_set_info#>>''{"ope","dev","A","397"}'')::numeric AS pat_max_limit_ohf,
  (device_set_info#>>''{"ope","dev","B","31"}'')::numeric AS pat_max_limit_hdf_a,
  (device_set_info#>>''{"ope","dev","B","32"}'')::numeric AS pat_max_limit_hf_a,
  (device_set_info#>>''{"ope","dev","B","33"}'')::numeric AS pat_min_limit_hd_plus_a,
  (device_set_info#>>''{"ope","dev","B","34"}'')::numeric AS pat_max_limit_ohdf_a,
  (device_set_info#>>''{"ope","dev","B","35"}'')::numeric AS pat_max_limit_ohf_a
  FROM pat_main 
  WHERE pat_id = @patId
),
max_upper_limit_info AS ( 
  select
    CASE 
      WHEN (SELECT indCondInfo021 FROM ind_cond_info021) in (''1'') THEN 
        CASE 
          WHEN device_mode in (2) THEN 
            COALESCE((SELECT pat_max_limit_hdf FROM pat_limit), 999.0)
          WHEN device_mode in (3) THEN 
            COALESCE((SELECT pat_max_limit_hf FROM pat_limit), 999.0)
          WHEN device_mode in (4) THEN 
            COALESCE((SELECT pat_min_limit_hd_plus FROM pat_limit), 999.0)
          WHEN device_mode in (7) THEN 
            COALESCE((SELECT pat_max_limit_ohdf FROM pat_limit), 999.0)
          WHEN device_mode in (8) THEN 
            COALESCE((SELECT pat_max_limit_ohf FROM pat_limit), 999.0)
          ELSE
            999.0
        END
      ELSE
        CASE 
          WHEN device_mode in (2) THEN 
            COALESCE((SELECT pat_max_limit_hdf_a FROM pat_limit), 999.0)
          WHEN device_mode in (3) THEN 
            COALESCE((SELECT pat_max_limit_hf_a FROM pat_limit), 999.0)
          WHEN device_mode in (4) THEN 
            COALESCE((SELECT pat_min_limit_hd_plus_a FROM pat_limit), 999.0)
          WHEN device_mode in (7) THEN 
            COALESCE((SELECT pat_max_limit_ohdf_a FROM pat_limit), 999.0)
          ELSE
            999.0
        END
    END AS max_upper_limit
  from
    mst_treatment
  where
    is_del = ''0''
    and is_disp = ''1''
    and facility_cd = @facilityCd
    and ((
        CASE (SELECT VALUE FROM ssi_in_hospital_cd)
          WHEN ''1'' THEN in_hospital_cd_a1 = (SELECT VALUE FROM ssi_order_treat_info) AND COALESCE(in_hospital_cd_a1,'''') <> ''''
          WHEN ''2'' THEN in_hospital_cd_a2 = (SELECT VALUE FROM ssi_order_treat_info) AND COALESCE(in_hospital_cd_a2,'''') <> ''''
          WHEN ''3'' THEN in_hospital_cd_a3 = (SELECT VALUE FROM ssi_order_treat_info) AND COALESCE(in_hospital_cd_a3,'''') <> ''''
          WHEN ''4'' THEN in_hospital_cd_a4 = (SELECT VALUE FROM ssi_order_treat_info) AND COALESCE(in_hospital_cd_a4,'''') <> ''''
        END
        AND
        CASE
          WHEN @treatDate >= in_hosp_a_startdate
          AND @treatDate >= in_hosp_b_startdate
              THEN CASE
                  WHEN in_hosp_a_startdate >= in_hosp_b_startdate
                      THEN True
                  WHEN in_hosp_a_startdate < in_hosp_b_startdate
                      THEN False
                  END
          WHEN @treatDate >= in_hosp_a_startdate
          AND (@treatDate < in_hosp_b_startdate
              OR in_hosp_b_startdate IS NULL)
              THEN True
          WHEN (@treatDate < in_hosp_a_startdate
              OR in_hosp_a_startdate IS NULL)
          AND @treatDate >= in_hosp_b_startdate
              THEN False
          ELSE False
        END
    )
    or (
        CASE (SELECT VALUE FROM ssi_in_hospital_cd)
          WHEN ''1'' THEN in_hospital_cd_b1 = (SELECT VALUE FROM ssi_order_treat_info) AND COALESCE(in_hospital_cd_b1,'''') <> ''''
          WHEN ''2'' THEN in_hospital_cd_b2 = (SELECT VALUE FROM ssi_order_treat_info) AND COALESCE(in_hospital_cd_b2,'''') <> ''''
          WHEN ''3'' THEN in_hospital_cd_b3 = (SELECT VALUE FROM ssi_order_treat_info) AND COALESCE(in_hospital_cd_b3,'''') <> ''''
          WHEN ''4'' THEN in_hospital_cd_b4 = (SELECT VALUE FROM ssi_order_treat_info) AND COALESCE(in_hospital_cd_b4,'''') <> ''''
        END
        AND
        CASE
          WHEN @treatDate >= in_hosp_a_startdate
          AND @treatDate >= in_hosp_b_startdate
              THEN CASE
                  WHEN in_hosp_a_startdate >= in_hosp_b_startdate
                      THEN False
                  WHEN in_hosp_a_startdate < in_hosp_b_startdate
                      THEN True
                  END
          WHEN @treatDate >= in_hosp_a_startdate
          AND (@treatDate < in_hosp_b_startdate
              OR in_hosp_b_startdate IS NULL)
              THEN False
          WHEN (@treatDate < in_hosp_a_startdate
              OR in_hosp_a_startdate IS NULL)
          AND @treatDate >= in_hosp_b_startdate
              THEN True
          ELSE False
        END
  ))
)
SELECT
  1 AS flg
WHERE
  (SELECT replenisher_speed FROM calc_value) > (SELECT max_upper_limit FROM max_upper_limit_info)
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの入力値チェック(補液速度)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500103, '
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
  );
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの入力値チェック(IP電源OKモニタ切り時間)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500104, 'SELECT
  1 AS flg
WHERE
  (
    NULLIF(@treatDate, '''') IS NULL
  )
  OR
  (
    NULLIF(@treatDate, '''')::date 
      <= (
            date_trunc(''month'', CURRENT_DATE + INTERVAL ''1 year'')
            + INTERVAL ''1 month''
            - INTERVAL ''1 day''
         )::date
  );', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの入力値チェック(開始日時)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500106, '
SELECT
  1 AS flg
WHERE
  (
    NULLIF(@indMediInfo.amount, '''') IS NULL
  )
  OR
  (
    0 <= (NULLIF(@indMediInfo.amount, ''''))::int
    AND 999999 >= (NULLIF(@indMediInfo.amount, ''''))::int
  );
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの入力値チェック(投薬オーダ情報の数量)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500107, '
SELECT
  1 AS flg
WHERE
  (
    NULLIF(@indEquipInfo.amount, '''') IS NULL
  )
  OR
  (
    0 <= (NULLIF(@indEquipInfo.amount, ''''))::int
    AND 9999 >= (NULLIF(@indEquipInfo.amount, ''''))::int
  );
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの入力値チェック(医材オーダ情報の数量)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

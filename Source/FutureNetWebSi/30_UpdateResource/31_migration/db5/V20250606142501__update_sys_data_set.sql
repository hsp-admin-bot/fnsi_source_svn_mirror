DELETE FROM ntss.sys_data_set
WHERE sql_cd in (8104,-500090);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(8104, 'WITH is_new AS (
  SELECT
   reg_date =  up_date AS is_new
  FROM 
    ord_main
  WHERE
    ord_no = @ordNo
),
ssi_in_hospital_cd AS ( 
  SELECT
    info->>''key2'' AS key2
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS VALUE 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = ''@facilityCd''
    AND is_del = ''0'' 
    AND COALESCE(info->>''key0'','''') = ''@key0''
    AND info->>''key1'' = ''SSI_ORDER_RECV''
    AND info->>''key2'' = ''IN_HOSPITAL_CD''
),
ssi_order_treat_info AS ( 
  SELECT
    info->>''key2'' AS key2
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS VALUE 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = ''@facilityCd''
    AND is_del = ''0'' 
    AND COALESCE(info->>''key0'','''') =''@key0''
    AND info->>''key1'' = ''SSI_ORDER_TREAT''
    AND info->>''key2'' = ''@indTreatmentName''
),
 is_membrane AS (
  SELECT 
    CASE 
        WHEN EXISTS (
        SELECT 1 FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = ''@facilityCd''
    AND is_del = ''0'' 
    AND is_disp = ''1'' 
    AND COALESCE(info->>''key0'','''') = ''@key0''
    AND info->>''key1'' = ''SSI_ORDER_MEMBRANE''
    AND info->>''key2'' LIKE ''TREAT%''
    AND COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'')  = (SELECT VALUE FROM ssi_order_treat_info)
    ) 
        THEN 1 
        ELSE 0 
    END AS is_membrane
),
device_mode AS (
      select
        COALESCE(device_mode, ''-1'') AS device_mode,
        treatment_cd,
        treatment_condition_setting
      from
        mst_treatment
      where
        is_del = ''0''
        and is_disp = ''1''
        and facility_cd = ''@facilityCd''
        and ((
            CASE (SELECT VALUE FROM ssi_in_hospital_cd)
              WHEN ''1'' THEN in_hospital_cd_a1 = (SELECT VALUE FROM ssi_order_treat_info) AND COALESCE(in_hospital_cd_a1,'''') <> ''''
              WHEN ''2'' THEN in_hospital_cd_a2 = (SELECT VALUE FROM ssi_order_treat_info) AND COALESCE(in_hospital_cd_a2,'''') <> ''''
              WHEN ''3'' THEN in_hospital_cd_a3 = (SELECT VALUE FROM ssi_order_treat_info) AND COALESCE(in_hospital_cd_a3,'''') <> ''''
              WHEN ''4'' THEN in_hospital_cd_a4 = (SELECT VALUE FROM ssi_order_treat_info) AND COALESCE(in_hospital_cd_a4,'''') <> ''''
            END
            AND
            CASE
              WHEN ''@treatDate'' >= in_hosp_a_startdate
              AND ''@treatDate'' >= in_hosp_b_startdate
                  THEN CASE
                      WHEN in_hosp_a_startdate >= in_hosp_b_startdate
                          THEN True
                      WHEN in_hosp_a_startdate < in_hosp_b_startdate
                          THEN False
                      END
              WHEN ''@treatDate'' >= in_hosp_a_startdate
              AND (''@treatDate'' < in_hosp_b_startdate
                  OR in_hosp_b_startdate IS NULL)
                  THEN True
              WHEN (''@treatDate'' < in_hosp_a_startdate
                  OR in_hosp_a_startdate IS NULL)
              AND ''@treatDate'' >= in_hosp_b_startdate
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
              WHEN ''@treatDate'' >= in_hosp_a_startdate
              AND ''@treatDate'' >= in_hosp_b_startdate
                  THEN CASE
                      WHEN in_hosp_a_startdate >= in_hosp_b_startdate
                          THEN False
                      WHEN in_hosp_a_startdate < in_hosp_b_startdate
                          THEN True
                      END
              WHEN ''@treatDate'' >= in_hosp_a_startdate
              AND (''@treatDate'' < in_hosp_b_startdate
                  OR in_hosp_b_startdate IS NULL)
                  THEN False
              WHEN (''@treatDate'' < in_hosp_a_startdate
                  OR in_hosp_a_startdate IS NULL)
              AND ''@treatDate'' >= in_hosp_b_startdate
                  THEN True
              ELSE False
            END
        ))
),
is_not_use_no AS (
  SELECT item->>''ctl_no'' AS is_not_use_no
        FROM jsonb_array_elements((SELECT treatment_condition_setting ->''items'' FROM device_mode)) AS item
        WHERE item->>''is_use'' = ''0''
),
ssi_order_treat_set_name AS ( 
  SELECT
    info->>''key2'' AS key2
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS VALUE 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = ''@facilityCd''
    AND is_del = ''0'' 
    AND COALESCE(info->>''key0'','''') = ''@key0''
    AND info->>''key1'' = ''SSI_ORDER_TREAT_SET''
    AND info->>''key2'' = ''@indTreatmentName''
),
treatment_set_order AS ( 
  SELECT 
    (item->>''code'')::INTEGER AS treatment_set_cd, row_number() OVER () AS sort_order
  FROM 
    mst_selector ms 
  CROSS JOIN LATERAL jsonb_array_elements(order_settings::jsonb->''items'') as item
    WHERE 
    facility_cd = ''@facilityCd''
      AND master_physical_name = ''mst_treatment_set''
),
is_use_no AS ( 
SELECT cond.key
FROM (
  SELECT
    ind_cond_info,
    0 AS is_ssi_order_treat_set_name,
    0 AS sort_order
  FROM
    mst_treatment_set
  WHERE
    facility_cd = ''@facilityCd''
    AND is_del = ''0'' 
    AND is_disp = ''1'' 
    AND treatment_cd = (SELECT treatment_cd FROM device_mode)
    AND treatment_set_name = (SELECT VALUE FROM ssi_order_treat_set_name)
  UNION ALL
  SELECT
    mst_treatment_set.ind_cond_info,
    1 AS is_ssi_order_treat_set_name,
    treatment_set_order.sort_order
  FROM
    mst_treatment_set
    JOIN treatment_set_order ON mst_treatment_set.treatment_set_cd = treatment_set_order.treatment_set_cd
  WHERE
    mst_treatment_set.facility_cd = ''@facilityCd''
    AND mst_treatment_set.is_del = ''0'' 
    AND mst_treatment_set.is_disp = ''1'' 
    AND mst_treatment_set.treatment_cd = (SELECT treatment_cd FROM device_mode)
  ORDER BY is_ssi_order_treat_set_name, sort_order LIMIT 1
  ) AS T, jsonb_each(T.ind_cond_info) AS cond
),
calc_value AS (
  SELECT
    CASE
      WHEN LTRIM(''@indCondInfo.020.value'', ''0'') = '''' AND LTRIM(''@indCondInfo.001.value'', ''0'') <> '''' THEN TO_CHAR(TO_NUMBER(CASE WHEN ''@indCondInfo.024.value'' <> '''' THEN ''@indCondInfo.024.value'' ELSE ''0'' END, ''FM999999999999999999'') / 100 * (TO_NUMBER(CASE WHEN ''@indCondInfo.001.value'' <> '''' THEN ''@indCondInfo.001.value'' ELSE ''0'' END,''FM999999999999999999'') / 60), ''FM999999999999999990.00'')
      ELSE TO_CHAR(CAST(TO_NUMBER(CASE WHEN ''@indCondInfo.020.value'' <> '''' THEN ''@indCondInfo.020.value'' ELSE ''0'' END,''FM999999999999999999'') / 10 AS FLOAT), ''FM999999999999999990.00'')
    
    END AS replenisher_amount,
    CASE 
      WHEN LTRIM(''@indCondInfo.020.value'', ''0'') = '''' AND LTRIM(''@indCondInfo.024.value'', ''0'') = '''' THEN ''0''
      WHEN LTRIM(''@indCondInfo.020.value'', ''0'') <> '''' AND LTRIM(''@indCondInfo.024.value'', ''0'') = '''' THEN  TO_CHAR(TO_NUMBER(CASE WHEN ''@indCondInfo.020.value''<>'''' THEN ''@indCondInfo.020.value'' ELSE ''0'' END, ''FM999999999999999999'') / 10 / (TO_NUMBER(CASE WHEN ''@indCondInfo.001.value''<>'''' THEN ''@indCondInfo.001.value'' ELSE ''0'' END, ''FM999999999999999999'') / 60) , ''FM999999999999999990.00'')
      ELSE TO_CHAR(CAST(TO_NUMBER(CASE WHEN ''@indCondInfo.024.value''<>'''' THEN ''@indCondInfo.024.value'' ELSE ''0'' END, ''FM999999999999999999'') / 100 AS FLOAT), ''FM999999999999999990.00'')
    END AS replenisher_speed
),
ssi_change_ctrl_info AS ( 
  SELECT
    info->>''key2'' AS key2
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS VALUE 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = ''@facilityCd''
    AND is_del = ''0'' 
    AND COALESCE(info->>''key0'','''') = ''@key0''
    AND info->>''key1'' = ''SSI_CHANGE_CTRL''
),
ssi_order_recv_info AS ( 
  SELECT
    info->>''key2'' AS key2
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS VALUE 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = ''@facilityCd''
    AND is_del = ''0'' 
    AND COALESCE(info->>''key0'','''') = ''@key0''
    AND info->>''key1'' = ''SSI_ORDER_RECV''
),
ssi_check_type_info AS ( 
  SELECT
    info->>''key2'' AS key2
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS VALUE 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = ''@facilityCd''
    AND is_del = ''0'' 
    AND COALESCE(info->>''key0'','''') = ''SSI''
    AND info->>''key1'' = ''SSI_CHANGE_CTRL''
    AND info->>''key2'' = ''CHECK_TYPE''
),
ssi_check_type_infos AS ( 
  SELECT
    case
      when (ssi_check_type_info.value = ''1'') then 
        (
          (coalesce((ord_main.ind_cond_info->''1''->>''input_class'')::text,''0'') <> ''1'')
        )
      when (ssi_check_type_info.value = ''2'') AND (SELECT VALUE FROM ssi_change_ctrl_info WHERE key2 = ''DIALYSIS_TIME'')=''1'' then (coalesce((ord_main.ind_cond_info->''1''->>''input_class'')::text,''0'') <> ''1'')
      else true
    end as check_type_01,
    case
      when (ssi_check_type_info.value = ''1'') then 
        (
          (coalesce((ord_main.ind_cond_info->''2''->>''input_class'')::text,''0'') <> ''1'')
        )
      when (ssi_check_type_info.value = ''2'') AND (SELECT VALUE FROM ssi_change_ctrl_info WHERE key2 = ''VA'')=''1'' then (coalesce((ord_main.ind_cond_info->''2''->>''input_class'')::text,''0'') <> ''1'')
      else true
    end as check_type_02,
    case
      when (ssi_check_type_info.value = ''1'') then 
        (
          (coalesce((ord_main.ind_cond_info->''3''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''4''->>''input_class'')::text,''0'') <> ''1'')
        )
      when (ssi_check_type_info.value = ''2'') AND (SELECT VALUE FROM ssi_change_ctrl_info WHERE key2 = ''TARGET_WEIGHT'')=''1'' then (coalesce((ord_main.ind_cond_info->''3''->>''input_class'')::text,''0'') <> ''1'')
      else true
    end as check_type_03,
    case
      when (ssi_check_type_info.value = ''1'') then 
        (
          (coalesce((ord_main.ind_cond_info->''3''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''4''->>''input_class'')::text,''0'') <> ''1'')
        )
      when (ssi_check_type_info.value = ''2'') AND (SELECT VALUE FROM ssi_change_ctrl_info WHERE key2 = ''REMOVE_LIMIT'')=''1'' then (coalesce((ord_main.ind_cond_info->''4''->>''input_class'')::text,''0'') <> ''1'')
      else true
    end as check_type_04,
    case
      when (ssi_check_type_info.value = ''1'') then 
        (
          (coalesce((ord_main.ind_cond_info->''5''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''6''->>''input_class'')::text,''0'') <> ''1'')
        )
      when (ssi_check_type_info.value = ''2'') AND (SELECT VALUE FROM ssi_change_ctrl_info WHERE key2 = ''DIALYZER'')=''1'' then (coalesce((ord_main.ind_cond_info->''5''->>''input_class'')::text,''0'') <> ''1'')
      else true
    end as check_type_05,
    case
      when (ssi_check_type_info.value = ''1'') then 
        (
          (coalesce((ord_main.ind_cond_info->''5''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''6''->>''input_class'')::text,''0'') <> ''1'')
        )
      when (ssi_check_type_info.value = ''2'') AND (SELECT VALUE FROM ssi_change_ctrl_info WHERE key2 = ''ADHESION'')=''1'' then (coalesce((ord_main.ind_cond_info->''6''->>''input_class'')::text,''0'') <> ''1'')
      else true
    end as check_type_06,
    case
      when (ssi_check_type_info.value = ''1'') then 
        (
          (coalesce((ord_main.ind_cond_info->''7''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''8''->>''input_class'')::text,''0'') <> ''1'')
        )
      when (ssi_check_type_info.value = ''2'') AND (SELECT VALUE FROM ssi_change_ctrl_info WHERE key2 = ''FIRST_FILM'')=''1'' then (coalesce((ord_main.ind_cond_info->''7''->>''input_class'')::text,''0'') <> ''1'')
      else true
    end as check_type_07,
    case
      when (ssi_check_type_info.value = ''1'') then 
        (
          (coalesce((ord_main.ind_cond_info->''7''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''8''->>''input_class'')::text,''0'') <> ''1'')
        )
      when (ssi_check_type_info.value = ''2'') AND (SELECT VALUE FROM ssi_change_ctrl_info WHERE key2 = ''SECOND_FILM'')=''1'' then (coalesce((ord_main.ind_cond_info->''8''->>''input_class'')::text,''0'') <> ''1'')
      else true
    end as check_type_08,
    case
      when (ssi_check_type_info.value = ''1'') then 
        (
          (coalesce((ord_main.ind_cond_info->''9''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''10''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''11''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''12''->>''input_class'')::text,''0'') <> ''1'')
        )
      when (ssi_check_type_info.value = ''2'') AND (SELECT VALUE FROM ssi_change_ctrl_info WHERE key2 = ''EQUIPMENT'')=''1'' then (coalesce((ord_main.ind_cond_info->''9''->>''input_class'')::text,''0'') <> ''1'')
      else true
    end as check_type_09,
    case
      when (ssi_check_type_info.value = ''1'') then 
        (
          (coalesce((ord_main.ind_cond_info->''9''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''10''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''11''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''12''->>''input_class'')::text,''0'') <> ''1'')
        )
      when (ssi_check_type_info.value = ''2'') AND (SELECT VALUE FROM ssi_change_ctrl_info WHERE key2 = ''EQUIPMENT'')=''1'' then (coalesce((ord_main.ind_cond_info->''10''->>''input_class'')::text,''0'') <> ''1'')
      else true
    end as check_type_10,
    case
      when (ssi_check_type_info.value = ''1'') then 
        (
          (coalesce((ord_main.ind_cond_info->''14''->>''input_class'')::text,''0'') <> ''14'')
        )
      when (ssi_check_type_info.value = ''2'') AND (SELECT VALUE FROM ssi_change_ctrl_info WHERE key2 = ''BLOOD_FLOW_VAL'')=''1'' then (coalesce((ord_main.ind_cond_info->''14''->>''input_class'')::text,''0'') <> ''1'')
      else true
    end as check_type_14,
    case
      when (ssi_check_type_info.value = ''1'') then 
        (
          (coalesce((ord_main.ind_cond_info->''15''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''16''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''17''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''18''->>''input_class'')::text,''0'') <> ''1'')
        )
      when (ssi_check_type_info.value = ''2'') AND (SELECT VALUE FROM ssi_change_ctrl_info WHERE key2 = ''LIQUID'')=''1'' then (coalesce((ord_main.ind_cond_info->''15''->>''input_class'')::text,''0'') <> ''1'')
      else true
    end as check_type_15,
    case
      when (ssi_check_type_info.value = ''1'') then 
        (
          (coalesce((ord_main.ind_cond_info->''15''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''16''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''17''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''18''->>''input_class'')::text,''0'') <> ''1'')
        )
      when (ssi_check_type_info.value = ''2'') AND (SELECT VALUE FROM ssi_change_ctrl_info WHERE key2 = ''LIQUID_QUANTITY'')=''1'' then (coalesce((ord_main.ind_cond_info->''16''->>''input_class'')::text,''0'') <> ''1'')
      else true
    end as check_type_16,
    case
      when (ssi_check_type_info.value = ''1'') then 
        (
          (coalesce((ord_main.ind_cond_info->''15''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''16''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''17''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''18''->>''input_class'')::text,''0'') <> ''1'')
        )
      when (ssi_check_type_info.value = ''2'') AND (SELECT VALUE FROM ssi_change_ctrl_info WHERE key2 = ''LIQUID_FLOW'')=''1'' then (coalesce((ord_main.ind_cond_info->''17''->>''input_class'')::text,''0'') <> ''1'')
      else true
    end as check_type_17,
    case
      when (ssi_check_type_info.value = ''1'') then 
        (
          (coalesce((ord_main.ind_cond_info->''15''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''16''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''17''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''18''->>''input_class'')::text,''0'') <> ''1'')
        )
      when (ssi_check_type_info.value = ''2'') AND (SELECT VALUE FROM ssi_change_ctrl_info WHERE key2 = ''LIQUID_TEMP'')=''1'' then (coalesce((ord_main.ind_cond_info->''18''->>''input_class'')::text,''0'') <> ''1'')
      else true
    end as check_type_18,
    case
      when (ssi_check_type_info.value = ''1'') then 
        (
          (coalesce((ord_main.ind_cond_info->''19''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''20''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''21''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''22''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''23''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''24''->>''input_class'')::text,''0'') <> ''1'')
        )
      when (ssi_check_type_info.value = ''2'') AND (SELECT VALUE FROM ssi_change_ctrl_info WHERE key2 = ''SUPLIQUID'')=''1'' then (coalesce((ord_main.ind_cond_info->''19''->>''input_class'')::text,''0'') <> ''1'')
      else true
    end as check_type_19,
    case
      when (ssi_check_type_info.value = ''1'') then 
        (
          (coalesce((ord_main.ind_cond_info->''19''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''20''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''21''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''22''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''23''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''24''->>''input_class'')::text,''0'') <> ''1'')
        )
      when (ssi_check_type_info.value = ''2'') AND (SELECT VALUE FROM ssi_change_ctrl_info WHERE key2 = ''SUPLIQUID_QUANTITY'')=''1'' then (coalesce((ord_main.ind_cond_info->''20''->>''input_class'')::text,''0'') <> ''1'')
      else true
    end as check_type_20,
    case
      when (ssi_check_type_info.value = ''1'') then 
        (
          (coalesce((ord_main.ind_cond_info->''19''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''20''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''21''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''22''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''23''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''24''->>''input_class'')::text,''0'') <> ''1'')
        )
      when (ssi_check_type_info.value = ''2'') AND (SELECT VALUE FROM ssi_change_ctrl_info WHERE key2 = ''SUPLIQUID_SELECT'')=''1'' then (coalesce((ord_main.ind_cond_info->''21''->>''input_class'')::text,''0'') <> ''1'')
      else true
    end as check_type_21,
    case
      when (ssi_check_type_info.value = ''1'') then 
        (
          (coalesce((ord_main.ind_cond_info->''19''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''20''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''21''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''22''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''23''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''24''->>''input_class'')::text,''0'') <> ''1'')
        )
      when (ssi_check_type_info.value = ''2'') AND (SELECT VALUE FROM ssi_change_ctrl_info WHERE key2 = ''SUPLIQUID_USE_COUNT'')=''1'' then (coalesce((ord_main.ind_cond_info->''22''->>''input_class'')::text,''0'') <> ''1'')
      else true
    end as check_type_22,
    case
      when (ssi_check_type_info.value = ''1'') then 
        (
          (coalesce((ord_main.ind_cond_info->''19''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''20''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''21''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''22''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''23''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''24''->>''input_class'')::text,''0'') <> ''1'')
        )
      when (ssi_check_type_info.value = ''2'') AND (SELECT VALUE FROM ssi_change_ctrl_info WHERE key2 = ''SUPLIQUID_SPEED'')=''1'' then (coalesce((ord_main.ind_cond_info->''24''->>''input_class'')::text,''0'') <> ''1'')
      else true
    end as check_type_24,
    case
      when (ssi_check_type_info.value = ''1'') then 
        (
          (coalesce((ord_main.ind_cond_info->''25''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''26''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''27''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''28''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''29''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''30''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''31''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''32''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''33''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''34''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''35''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''36''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''37''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''38''->>''input_class'')::text,''0'') <> ''1'')
        )
      when (ssi_check_type_info.value = ''2'') AND (SELECT VALUE FROM ssi_change_ctrl_info WHERE key2 = ''ANTI_COAGULANT'')=''1'' then (coalesce((ord_main.ind_cond_info->''25''->>''input_class'')::text,''0'') <> ''1'')
      else true
    end as check_type_25,
    case
      when (ssi_check_type_info.value = ''1'') then 
        (
          (coalesce((ord_main.ind_cond_info->''25''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''26''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''27''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''28''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''29''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''30''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''31''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''32''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''33''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''34''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''35''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''36''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''37''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''38''->>''input_class'')::text,''0'') <> ''1'')
        )
      when (ssi_check_type_info.value = ''2'') AND (SELECT VALUE FROM ssi_change_ctrl_info WHERE key2 = ''ONE_SHOT'')=''1'' then (coalesce((ord_main.ind_cond_info->''26''->>''input_class'')::text,''0'') <> ''1'')
      else true
    end as check_type_26,
    case
      when (ssi_check_type_info.value = ''1'') then 
        (
          (coalesce((ord_main.ind_cond_info->''25''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''26''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''27''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''28''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''29''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''30''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''31''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''32''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''33''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''34''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''35''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''36''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''37''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''38''->>''input_class'')::text,''0'') <> ''1'')
        )
      when (ssi_check_type_info.value = ''2'') AND (SELECT VALUE FROM ssi_change_ctrl_info WHERE key2 = ''SPEED'')=''1'' then (coalesce((ord_main.ind_cond_info->''27''->>''input_class'')::text,''0'') <> ''1'')
      else true
    end as check_type_27,
    case
      when (ssi_check_type_info.value = ''1'') then 
        (
          (coalesce((ord_main.ind_cond_info->''25''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''26''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''27''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''28''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''29''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''30''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''31''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''32''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''33''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''34''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''35''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''36''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''37''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''38''->>''input_class'')::text,''0'') <> ''1'')
        )
      when (ssi_check_type_info.value = ''2'') AND (SELECT VALUE FROM ssi_change_ctrl_info WHERE key2 = ''SUM_VAL'')=''1'' then (coalesce((ord_main.ind_cond_info->''28''->>''input_class'')::text,''0'') <> ''1'')
      else true
    end as check_type_28,
    case
      when (ssi_check_type_info.value = ''1'') then 
        (
          (coalesce((ord_main.ind_cond_info->''25''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''26''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''27''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''28''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''29''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''30''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''31''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''32''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''33''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''34''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''35''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''36''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''37''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''38''->>''input_class'')::text,''0'') <> ''1'')
        )
      when (ssi_check_type_info.value = ''2'') AND (SELECT VALUE FROM ssi_change_ctrl_info WHERE key2 = ''IP_ONE_SHOT'')=''1'' then (coalesce((ord_main.ind_cond_info->''31''->>''input_class'')::text,''0'') <> ''1'')
      else true
    end as check_type_31,
    case
      when (ssi_check_type_info.value = ''1'') then 
        (
          (coalesce((ord_main.ind_cond_info->''25''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''26''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''27''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''28''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''29''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''30''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''31''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''32''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''33''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''34''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''35''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''36''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''37''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''38''->>''input_class'')::text,''0'') <> ''1'')
        )
      when (ssi_check_type_info.value = ''2'') AND (SELECT VALUE FROM ssi_change_ctrl_info WHERE key2 = ''IP_SPEED'')=''1'' then (coalesce((ord_main.ind_cond_info->''32''->>''input_class'')::text,''0'') <> ''1'')
      else true
    end as check_type_32,
    case
      when (ssi_check_type_info.value = ''1'') then 
        (
          (coalesce((ord_main.ind_cond_info->''25''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''26''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''27''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''28''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''29''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''30''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''31''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''32''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''33''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''34''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''35''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''36''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''37''->>''input_class'')::text,''0'') <> ''1'') and
          (coalesce((ord_main.ind_cond_info->''38''->>''input_class'')::text,''0'') <> ''1'')
        )
      when (ssi_check_type_info.value = ''2'') AND (SELECT VALUE FROM ssi_change_ctrl_info WHERE key2 = ''IP_POK_MONITOR'')=''1'' then (coalesce((ord_main.ind_cond_info->''38''->>''input_class'')::text,''0'') <> ''1'')
      else true
    end as check_type_38,
    case
      when (ssi_check_type_info.value = ''1'') then 
        (
          (coalesce((ord_main.ind_cond_info->''39''->>''input_class'')::text,''0'') <> ''1'')
        )
      when (ssi_check_type_info.value = ''2'') AND (SELECT VALUE FROM ssi_change_ctrl_info WHERE key2 = ''DW'')=''1'' then (coalesce((ord_main.ind_cond_info->''39''->>''input_class'')::text,''0'') <> ''1'')
      else true
    end as check_type_39
  FROM
    ord_main,
    ssi_check_type_info
  WHERE
    ord_no = @ordNo
),
va_info AS(
    SELECT
        va_cd,
        va_name
    FROM
        mst_va
    WHERE
        facility_cd = ''@facilityCd''
      AND CASE (SELECT VALUE FROM ssi_in_hospital_cd)
          WHEN ''1'' THEN in_hospital_cd_1 = ''@indVaCd'' AND COALESCE(in_hospital_cd_1,'''') <> ''''
          WHEN ''2'' THEN in_hospital_cd_2 = ''@indVaCd'' AND COALESCE(in_hospital_cd_2,'''') <> ''''
        END
    AND is_del = ''0''
    AND is_disp = ''1''
    ORDER BY va_cd DESC
    LIMIT 1
),
dial_time_limit AS (
  SELECT COALESCE(NULLIF(info->>''value'',''''), info->>''default_v'')::INT AS max_minutes
  FROM   mst_coop_ini AS ini
         CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
  WHERE  facility_cd = ''@facilityCd''
    AND  ini.is_del = ''0''
    AND  info->>''key0'' = ''@key0''
    AND  info->>''key1'' = ''SSI_ORDER_RECV''
    AND  info->>''key2'' = ''DIALYSIS_TIME_LIMIT''
    AND  info->>''is_effect'' = ''1''
  LIMIT  1
),
device_name_info AS (
    SELECT
        info ->> ''key2'' AS device_name
    FROM   mst_coop_ini AS ini
           CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE  ini.facility_cd = ''@facilityCd''
      AND  ini.is_del      = ''0''
      AND  info ->> ''key0'' = ''@key0''
      AND  info ->> ''key1'' = ''SSI_ORDER_TREAT''
      AND  COALESCE(NULLIF(info ->> ''value'',''''), info ->> ''default_v'')
           = ''@indTreatmentName''
    LIMIT 1
),
replenisher_limit AS (
    SELECT CASE
             WHEN device_name IN (''OHDF'',''OHF'')              THEN 192.0
             WHEN device_name IN (''HD+補液'',''HD_PLUS_INF'')   THEN  99.9
             WHEN device_name IN (''HDF'',''HF'',''AFBF'')         THEN  30.0
             ELSE                                                 999.0
           END AS max_liters
    FROM device_name_info
),
dialysis_minutes AS (
    SELECT
        LEAST(
            COALESCE(
                NULLIF(LTRIM(''@indCondInfo.001.value'',''0''),'''')::INT,
                (ord_main.ind_cond_info -> ''1'' ->> ''value'')::INT
            ),
            COALESCE((SELECT max_minutes FROM dial_time_limit), 479)
        ) AS minutes
    FROM ord_main
    WHERE ord_no = @ordNo
),
replenisher_speed_cap AS (
    SELECT
        ROUND(
            (SELECT max_liters FROM replenisher_limit) /
            (GREATEST(minutes,1) / 60.0)
        , 2) AS max_Lph
    FROM dialysis_minutes
),
input_data AS (
  SELECT
     -- 001 透析時間 (分)
    TO_CHAR(
      LEAST(                                    -- 上側クリップ
        GREATEST(                               -- 下側クリップ (0 未満は 0)
          COALESCE(
            NULLIF(LTRIM(''@indCondInfo.001.value'',''0''),'''')::int,  -- 新規入力
            (ord_main.ind_cond_info->''1''->>''value'')::int          -- 既存値
          )
        , 0)
      , COALESCE((SELECT max_minutes FROM dial_time_limit), 479) -- INI 上限
      )
    ,''FM9999990'') AS indCondInfo001,

     -- 002 VA コード（文字列）
    CASE
      WHEN (SELECT is_new FROM is_new)
      THEN COALESCE(
             (SELECT va_cd FROM va_info)::TEXT,
             (ord_main.ind_cond_info->''2''->>''value'')::TEXT
           )
      ELSE (SELECT va_cd FROM va_info)::TEXT
    END                                             AS indCondInfo002,

     -- 003 目標体重 (未使用)
    ''-1''                                            AS indCondInfo003,

     -- 004 除水量制限 [0.00–39.99] L
    COALESCE(
      TO_CHAR(
        LEAST(
          39.99,
          GREATEST(
            0.00,
            COALESCE(NULLIF(''@indCondInfo.004.value'', '''')::NUMERIC, 0) / 100
          )
        ),
        ''FM999999990.00''
      ),
      (ord_main.ind_cond_info->''4''->>''value'')::TEXT
    )                                                AS indCondInfo004,

     -- 005 ダイアライザコード（文字列）
    CASE
      WHEN (SELECT is_new FROM is_new)
      THEN COALESCE(
             NULLIF(''@indCondInfo.005.value'', ''''),
             (ord_main.ind_cond_info->''5''->>''value'')::TEXT
           )
      ELSE NULLIF(''@indCondInfo.005.value'', '''')
    END                                             AS indCondInfo005,

     -- 006 吸着器コード（文字列）
    CASE
      WHEN (SELECT is_new FROM is_new)
      THEN COALESCE(
             NULLIF(''@indCondInfo.006.value'', ''''),
             (ord_main.ind_cond_info->''6''->>''value'')::TEXT
           )
      ELSE NULLIF(''@indCondInfo.006.value'', '''')
    END                                             AS indCondInfo006,

     -- 007 第１膜コード —— 文字列 / is_membrane 判定に依存
    CASE
      WHEN (SELECT is_new FROM is_new)
      THEN COALESCE(
             NULLIF(''@indCondInfo.005.value'', ''''),
             (ord_main.ind_cond_info->''5''->>''value'')::TEXT
           )
      ELSE NULLIF(''@indCondInfo.005.value'', '''')
    END                                             AS indCondInfo007,

     -- 008 第２膜コード —— 文字列 / is_membrane 判定に依存
    CASE
      WHEN (SELECT is_new FROM is_new)
      THEN COALESCE(
             NULLIF(''@indCondInfo.008.value'', ''''),
             (ord_main.ind_cond_info->''8''->>''value'')::TEXT
           )
      ELSE NULLIF(''@indCondInfo.008.value'', '''')
    END                                             AS indCondInfo008,

     -- 009 A針コード（文字列）
    COALESCE(
      NULLIF(''@indCondInfo.010.value'', ''''),
      (ord_main.ind_cond_info->''9''->>''value'')::TEXT
    )                                                AS indCondInfo009,

     -- 010 V針コード（文字列）
    COALESCE(
      NULLIF(''@indCondInfo.011.value'', ''''),
      (ord_main.ind_cond_info->''10''->>''value'')::TEXT
    )                                                AS indCondInfo010,

     -- 014 血流量 [0–500] mL/min
    COALESCE(
      TO_CHAR(
        LEAST(
          500,
          GREATEST(
            0,
            COALESCE(NULLIF(''@indCondInfo.014.value'', '''')::INT, 0)
          )
        ),
        ''FM999''
      ),
      (ord_main.ind_cond_info->''14''->>''value'')::TEXT
    )                                                AS indCondInfo014,

     -- 015 透析液コード（文字列）
    CASE
      WHEN (SELECT is_new FROM is_new)
      THEN COALESCE(
             NULLIF(''@indCondInfo.015.value'', ''''),
             (ord_main.ind_cond_info->''15''->>''value'')::TEXT
           )
      ELSE NULLIF(''@indCondInfo.015.value'', '''')
    END                                             AS indCondInfo015,

     -- 016 除水補正量 [0–30,000] g
    COALESCE(
      TO_CHAR(
        LEAST(
          30000,
          GREATEST(
            0,
            COALESCE(
              NULLIF(''@ind_tare_info.ind_tare_info.weight_4'', '''')::INT,
              0
            )
          )
        ),
        ''FM99990''
      ),
      ''0''
    )                                                AS indCondInfo016,

     -- 017 透析液数量 [0.00–32,767.00] L
    TO_CHAR(
      LEAST(
        32767.00,
        GREATEST(
          0.00,
          COALESCE(NULLIF(''@indCondInfo.017.value'', '''')::NUMERIC, 0) / 100
        )
      ),
      ''FM999999990.00''
    )                                                AS indCondInfo017,

     -- 018 透析液温度 [33.0–40.0] ℃
    TO_CHAR(
      LEAST(
        40.0,
        GREATEST(
          33.0,
          COALESCE(NULLIF(''@indCondInfo.018.value'', '''')::NUMERIC, 0) / 10
        )
      ),
      ''FM999999990.0''
    )                                                AS indCondInfo018,

     -- 019 補液コード（文字列）―― device_mode で制御
    CASE
      WHEN (SELECT device_mode FROM device_mode) IN (''1'',''2'')
      THEN NULL
      ELSE CASE
             WHEN (SELECT is_new FROM is_new)
             THEN COALESCE(
                    NULLIF(''@indCondInfo.019.value'', ''''),
                    (ord_main.ind_cond_info->''19''->>''value'')::TEXT
                  )
             ELSE NULLIF(''@indCondInfo.019.value'', '''')
           END
    END                                             AS indCondInfo019,

     -- 020 補液量
    CASE
        WHEN (SELECT device_mode FROM device_mode) IN (''1'',''2'',''10'')
        THEN ''0.0''
        ELSE TO_CHAR(
                 LEAST(
                     (SELECT max_liters
                        FROM replenisher_limit),
                     CASE
                       WHEN ''@indCondInfo.format'' = ''Standard''
                       THEN LEAST( 99.9,
                                  (SELECT replenisher_amount::NUMERIC
                                     FROM calc_value) )
                       ELSE        (SELECT replenisher_amount::NUMERIC
                                     FROM calc_value)
                     END
                 ),
                 ''FM999999990.0''
             )
    END AS indCondInfo020,

     -- 021 補液前後フラグ
    CASE
      WHEN LTRIM(''@ind_off_water_info.ind_off_water_info.weight_4'', ''0'')
           = LTRIM((SELECT VALUE
                      FROM ssi_order_recv_info
                     WHERE key2 = ''SUPLIQUID_BEFORE_CD''), ''0'')
      THEN ''1''
      WHEN LTRIM(''@ind_off_water_info.ind_off_water_info.weight_4'', ''0'')
           = LTRIM((SELECT VALUE
                      FROM ssi_order_recv_info
                     WHERE key2 = ''SUPLIQUID_AFTER_CD''), ''0'')
      THEN ''0''
      ELSE (ord_main.ind_cond_info->''21''->>''value'')::TEXT
    END                                             AS indCondInfo021,

    -- 022 補液使用数
   CASE
       WHEN (SELECT device_mode FROM device_mode) IN (''1'',''2'',''10'') THEN ''0''
       WHEN ''@indCondInfo.format'' = ''Standard'' THEN
            TO_CHAR(
                LEAST(
                    999,
                    GREATEST(
                        0,
                        COALESCE(NULLIF(''@indCondInfo.022.value'','''')::NUMERIC, 0)
                    )
                ),
                ''FM999''
            )
       ELSE
            TO_CHAR(
                LEAST(
                    999.99,
                    GREATEST(
                        0.00,
                        COALESCE(NULLIF(''@indCondInfo.022.value'','''')::NUMERIC,0) / 100
                    )
                ),
                ''FM999999990.00'' 
            )
   END AS indCondInfo022,

     -- 024 補液速度
    CASE
        WHEN (SELECT device_mode FROM device_mode) IN (''1'',''2'',''10'')
        THEN ''0''
        ELSE TO_CHAR(
                 LEAST(
                     (SELECT replenisher_speed::NUMERIC FROM calc_value),
                     (SELECT max_Lph               FROM replenisher_speed_cap)
                 ),
                 ''FM999999990.00''
             )
    END AS indCondInfo024,

     -- 025 抗凝固剤コード（文字列）
    CASE
      WHEN (SELECT is_new FROM is_new)
      THEN COALESCE(
             NULLIF(''@indCondInfo.025.value'', ''''),
             (ord_main.ind_cond_info->''25''->>''value'')::TEXT
           )
      ELSE NULLIF(''@indCondInfo.025.value'', '''')
    END                                             AS indCondInfo025,

     -- 026 抗凝固剤ワンショット量 [0.00–32,767.00] g
    TO_CHAR(
      LEAST(
        32767.00,
        GREATEST(
          0.00,
          COALESCE(NULLIF(''@indCondInfo.026.value'', '''')::NUMERIC, 0) / 100
        )
      ),
      ''FM999999990.00''
    )                                                AS indCondInfo026,

     -- 027 抗凝固剤持続注入量 [0.00–32,767.00] g
    TO_CHAR(
      LEAST(
        32767.00,
        GREATEST(
          0.00,
          COALESCE(NULLIF(''@indCondInfo.027.value'', '''')::NUMERIC, 0) / 100
        )
      ),
      ''FM999999990.00''
    )                                                AS indCondInfo027,

     -- 028 抗凝固剤持続総量 [0.00–32,767.00] g
    TO_CHAR(
      LEAST(
        32767.00,
        GREATEST(
          0.00,
          COALESCE(NULLIF(''@indCondInfo.028.value'', '''')::NUMERIC, 0) / 100
        )
      ),
      ''FM999999990.00''
    )                                                AS indCondInfo028,

     -- 031 IP ワンショット量 [0–30,000] g
    COALESCE(
      TO_CHAR(
        LEAST(
          30000,
          GREATEST(
            0,
            COALESCE(
              NULLIF(''@ind_off_water_info.ind_off_water_info.weight_5'','''')::INT,
              0
            )
          )
        ),
        ''FM99990''
      ),
      (ord_main.ind_cond_info->''31''->>''value'')::TEXT
    )                                                AS indCondInfo031,

     -- 032 IP 速度 [0.0–9.9] mL/h
    COALESCE(
      TO_CHAR(
        LEAST(
          9.9,
          GREATEST(
            0.0,
            COALESCE(NULLIF(''@indCondInfo.033.value'', '''')::NUMERIC, 0) / 10
          )
        ),
        ''FM999999990.0''
      ),
      (ord_main.ind_cond_info->''32''->>''value'')::TEXT
    )                                                AS indCondInfo032,

     -- 038 風袋重 [0–99,999] g
    COALESCE(
      TO_CHAR(
        LEAST(
          99999,
          GREATEST(
            0,
            COALESCE(
              NULLIF(''@ind_tare_info.ind_tare_info.weight_5'', '''')::INT,
              0
            )
          )
        ),
        ''FM999999''
      ),
      TO_CHAR(
        LEAST(
          99999,
          GREATEST(
            0,
            COALESCE((ord_main.ind_cond_info->''38''->>''value'')::INT, 0)
          )
        ),
        ''FM999999''
      )
    )                                                AS indCondInfo038,

     -- 039 DW
    COALESCE(
      NULLIF(''@indCondInfo.039.value'', ''''),
      (ord_main.ind_cond_info->''39''->>''value'')::TEXT
    )                                                AS indCondInfo039

  FROM ord_main
  WHERE ord_no = @ordNo
),
device_set_default AS (
  SELECT tare_info, off_water_info
  FROM mst_device_set_info_default
  WHERE facility_cd = ''@facilityCd''
),
ind_cond_tmp_data AS (
  SELECT jsonb_set( 
    jsonb_set( 
      jsonb_set( 
        jsonb_set( 
          jsonb_set( 
            jsonb_set( 
              jsonb_set( 
                jsonb_set( 
                  jsonb_set( 
                    jsonb_set( 
                      jsonb_set( 
                        jsonb_set( 
                          jsonb_set( 
                            jsonb_set( 
                              jsonb_set( 
                                jsonb_set( 
                                  jsonb_set( 
                                    jsonb_set( 
                                      jsonb_set( 
                                        jsonb_set( 
                                          jsonb_set( 
                                            jsonb_set( 
                                              jsonb_set( 
                                                jsonb_set( 
                                                  jsonb_set( 
                                                    jsonb_set( 
                                                      jsonb_set( 
                                                        jsonb_set( 
                                                          ind_cond_info ::JSONB
                                                          , ''{39, value}''
                                                          , CASE
                                                              WHEN (SELECT check_type_39 FROM ssi_check_type_infos) THEN
                                                                (CASE WHEN input_data.indCondInfo039 IS NULL THEN ''null'' ELSE (''"''|| input_data.indCondInfo039 ||''"'') END)::JSONB
                                                              ELSE
                                                                COALESCE((ord_main.ind_cond_info->''39''->>''value''),''null'')::JSONB
                                                            END
                                                        ) ::JSONB
                                                        , ''{38, value}''
                                                        , CASE
                                                            WHEN ((SELECT check_type_38 FROM ssi_check_type_infos) AND (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''IPPWROK'')=''1'') THEN
                                                              (CASE WHEN input_data.indCondInfo038 IS NULL THEN ''null'' ELSE (''"''|| input_data.indCondInfo038 ||''"'') END)::JSONB
                                                            ELSE
                                                              COALESCE((ord_main.ind_cond_info->''38''->>''value''),''null'')::JSONB
                                                          END
                                                      ) ::JSONB
                                                      , ''{32, value}''
                                                      , CASE
                                                          WHEN ((SELECT check_type_32 FROM ssi_check_type_infos) AND (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''IPSPEED'')=''1'') THEN
                                                            (CASE WHEN input_data.indCondInfo032 IS NULL THEN ''null'' ELSE (''"''|| input_data.indCondInfo032 ||''"'') END)::JSONB
                                                          ELSE
                                                            COALESCE((ord_main.ind_cond_info->''32''->>''value''),''null'')::JSONB
                                                        END
                                                    ) ::JSONB
                                                    , ''{31, value}''
                                                    , CASE
                                                        WHEN ((SELECT check_type_31 FROM ssi_check_type_infos) AND (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''IPONESHOT'')=''1'') THEN
                                                          (CASE WHEN input_data.indCondInfo031 IS NULL THEN ''null'' ELSE (''"''|| input_data.indCondInfo031 ||''"'') END)::JSONB
                                                        ELSE
                                                          COALESCE((ord_main.ind_cond_info->''31''->>''value''),''null'')::JSONB
                                                      END
                                                  ) ::JSONB
                                                  , ''{28, value}''
                                                  , CASE
                                                      WHEN (SELECT check_type_28 FROM ssi_check_type_infos) THEN
                                                        (CASE WHEN input_data.indCondInfo028 IS NULL THEN ''null'' ELSE (''"''|| input_data.indCondInfo028 ||''"'') END)::JSONB
                                                      ELSE
                                                        COALESCE((ord_main.ind_cond_info->''28''->>''value''),''null'')::JSONB
                                                    END
                                                ) ::JSONB
                                                , ''{27, value}''
                                                , CASE
                                                    WHEN (SELECT check_type_27 FROM ssi_check_type_infos) THEN
                                                    (CASE WHEN input_data.indCondInfo027 IS NULL THEN ''null'' ELSE (''"''|| input_data.indCondInfo027 ||''"'') END)::JSONB
                                                    ELSE
                                                      COALESCE((ord_main.ind_cond_info->''27''->>''value''),''null'')::JSONB
                                                  END
                                              ) ::JSONB
                                              , ''{26, value}''
                                              , CASE
                                                  WHEN (SELECT check_type_26 FROM ssi_check_type_infos) THEN
                                                    (CASE WHEN input_data.indCondInfo026 IS NULL THEN ''null'' ELSE (''"''|| input_data.indCondInfo026 ||''"'') END)::JSONB
                                                  ELSE
                                                    COALESCE((ord_main.ind_cond_info->''26''->>''value''),''null'')::JSONB
                                                END
                                            ) ::JSONB
                                            , ''{25, value}''
                                            , CASE
                                                WHEN (SELECT check_type_25 FROM ssi_check_type_infos) THEN
                                                  (CASE WHEN input_data.indCondInfo025 IS NULL THEN ''null'' ELSE (''"''|| input_data.indCondInfo025 ||''"'') END)::JSONB
                                                ELSE
                                                  COALESCE((ord_main.ind_cond_info->''25''->>''value''),''null'')::JSONB
                                              END
                                          ) ::JSONB
                                          , ''{24, value}''
                                          , CASE
                                              WHEN (SELECT check_type_24 FROM ssi_check_type_infos) THEN
                                                (CASE WHEN input_data.indCondInfo024 IS NULL THEN ''null'' ELSE (''"''|| input_data.indCondInfo024 ||''"'') END)::JSONB
                                              ELSE
                                                COALESCE((ord_main.ind_cond_info->''24''->>''value''),''null'')::JSONB
                                            END
                                        ) ::JSONB
                                        , ''{22, value}''
                                        , CASE
                                            WHEN (SELECT check_type_22 FROM ssi_check_type_infos) THEN
                                              (CASE WHEN input_data.indCondInfo022 IS NULL THEN ''null'' ELSE (''"''|| input_data.indCondInfo022 ||''"'') END)::JSONB
                                            ELSE
                                              COALESCE((ord_main.ind_cond_info->''22''->>''value''),''null'')::JSONB
                                          END
                                      ) ::JSONB
                                      , ''{21, value}''
                                      , CASE
                                          WHEN ((SELECT check_type_21 FROM ssi_check_type_infos) AND (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''USE_SUPLIQUID'')=''1'') THEN
                                          (CASE WHEN input_data.indCondInfo021 IS NULL THEN ''null'' ELSE (''"''|| input_data.indCondInfo021 ||''"'') END)::JSONB
                                          ELSE
                                            COALESCE((ord_main.ind_cond_info->''21''->>''value''),''null'')::JSONB
                                        END
                                    ) ::JSONB
                                    , ''{20, value}''
                                    , CASE
                                        WHEN (SELECT check_type_20 FROM ssi_check_type_infos) THEN
                                          (CASE WHEN input_data.indCondInfo020 IS NULL THEN ''null'' ELSE (''"''|| input_data.indCondInfo020 ||''"'') END)::JSONB
                                        ELSE
                                          COALESCE((ord_main.ind_cond_info->''20''->>''value''),''null'')::JSONB
                                      END
                                  ) ::JSONB
                                  , ''{19, value}''
                                  , CASE
                                      WHEN (SELECT check_type_19 FROM ssi_check_type_infos) THEN
                                        (CASE WHEN input_data.indCondInfo019 IS NULL THEN ''null'' ELSE (''"''|| input_data.indCondInfo019 ||''"'') END)::JSONB
                                      ELSE
                                        COALESCE((ord_main.ind_cond_info->''19''->>''value''),''null'')::JSONB
                                    END
                                ) ::JSONB
                                , ''{18, value}''
                                , CASE
                                    WHEN (SELECT check_type_18 FROM ssi_check_type_infos) THEN
                                      (CASE WHEN input_data.indCondInfo018 IS NULL THEN ''null'' ELSE (''"''|| input_data.indCondInfo018 ||''"'') END)::JSONB
                                    ELSE
                                      COALESCE((ord_main.ind_cond_info->''18''->>''value''),''null'')::JSONB
                                  END
                              ) ::JSONB
                              , ''{17, value}''
                              , CASE
                                  WHEN (SELECT check_type_17 FROM ssi_check_type_infos) THEN
                                    (CASE WHEN input_data.indCondInfo017 IS NULL THEN ''null'' ELSE (''"''|| input_data.indCondInfo017 ||''"'') END)::JSONB
                                  ELSE
                                    COALESCE((ord_main.ind_cond_info->''17''->>''value''),''null'')::JSONB
                                END
                            ) ::JSONB
                            , ''{16, value}''
                            , CASE
                                WHEN ((SELECT check_type_16 FROM ssi_check_type_infos) AND (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''SOLUTION'')=''1'') THEN
                                  (CASE WHEN input_data.indCondInfo016 IS NULL THEN ''null'' ELSE (''"''|| input_data.indCondInfo016 ||''"'') END)::JSONB
                                ELSE
                                  COALESCE((ord_main.ind_cond_info->''16''->>''value''),''null'')::JSONB
                                END
                          ) ::JSONB
                          , ''{15, value}''
                          , CASE
                              WHEN (SELECT check_type_15 FROM ssi_check_type_infos) THEN
                                (CASE WHEN input_data.indCondInfo015 IS NULL THEN ''null'' ELSE (''"''|| input_data.indCondInfo015 ||''"'') END)::JSONB
                              ELSE
                                COALESCE((ord_main.ind_cond_info->''15''->>''value''),''null'')::JSONB
                            END
                        ) ::JSONB
                        , ''{14, value}''
                        , CASE
                            WHEN (SELECT check_type_14 FROM ssi_check_type_infos) THEN
                              (CASE WHEN input_data.indCondInfo014 IS NULL THEN ''null'' ELSE (''"''|| input_data.indCondInfo014 ||''"'') END)::JSONB
                            ELSE
                              COALESCE((ord_main.ind_cond_info->''14''->>''value''),''null'')::JSONB
                          END
                      ) ::JSONB
                      , ''{10, value}''
                      , CASE
                          WHEN (SELECT check_type_10 FROM ssi_check_type_infos) THEN
                            (CASE WHEN input_data.indCondInfo010 IS NULL THEN ''null'' ELSE (''"''|| input_data.indCondInfo010 ||''"'') END)::JSONB
                          ELSE
                            COALESCE((ord_main.ind_cond_info->''10''->>''value''),''null'')::JSONB
                        END
                    ) ::JSONB
                    , ''{9, value}''
                    , CASE
                        WHEN (SELECT check_type_09 FROM ssi_check_type_infos) THEN
                          (CASE WHEN input_data.indCondInfo009 IS NULL THEN ''null'' ELSE (''"''|| input_data.indCondInfo009 ||''"'') END)::JSONB
                        ELSE
                          COALESCE((ord_main.ind_cond_info->''9''->>''value''),''null'')::JSONB
                      END
                  ) ::JSONB
                  , ''{8, value}''
                  , CASE
                      WHEN (SELECT check_type_08 FROM ssi_check_type_infos) AND (SELECT is_membrane FROM is_membrane) = 1 THEN
                        (CASE WHEN input_data.indCondInfo008 IS NULL THEN ''null'' ELSE (''"''|| input_data.indCondInfo008 ||''"'') END)::JSONB
                      ELSE
                        COALESCE((ord_main.ind_cond_info->''8''->>''value''),''null'')::JSONB
                    END
                ) ::JSONB
                , ''{7, value}''
                , CASE
                    WHEN (SELECT check_type_07 FROM ssi_check_type_infos) AND (SELECT is_membrane FROM is_membrane) = 1 THEN
                      (CASE WHEN input_data.indCondInfo007 IS NULL THEN ''null'' ELSE (''"''|| input_data.indCondInfo007 ||''"'') END)::JSONB
                    ELSE
                      COALESCE((ord_main.ind_cond_info->''7''->>''value''),''null'')::JSONB
                  END
              ) ::JSONB
              , ''{6, value}''
              , CASE
                  WHEN (SELECT check_type_06 FROM ssi_check_type_infos) THEN
                    (CASE WHEN input_data.indCondInfo006 IS NULL THEN ''null'' ELSE (''"''|| input_data.indCondInfo006 ||''"'') END)::JSONB
                  ELSE
                    COALESCE((ord_main.ind_cond_info->''6''->>''value''),''null'')::JSONB
                END
            ) ::JSONB
            , ''{5, value}''
            , CASE
                WHEN (SELECT check_type_05 FROM ssi_check_type_infos) AND (SELECT is_membrane FROM is_membrane) = 0 THEN
                  (CASE WHEN input_data.indCondInfo005 IS NULL THEN ''null'' ELSE (''"''|| input_data.indCondInfo005 ||''"'') END)::JSONB
                ELSE
                  COALESCE((ord_main.ind_cond_info->''5''->>''value''),''null'')::JSONB
              END
          ) ::JSONB
          , ''{4, value}''
          , CASE
              WHEN (SELECT check_type_04 FROM ssi_check_type_infos) THEN
                (CASE WHEN input_data.indCondInfo004 IS NULL THEN ''null'' ELSE (''"''|| input_data.indCondInfo004 ||''"'') END)::JSONB
              ELSE
                COALESCE((ord_main.ind_cond_info->''4''->>''value''),''null'')::JSONB
            END
        ) ::JSONB
        , ''{3, value}''
        , CASE
            WHEN (SELECT check_type_03 FROM ssi_check_type_infos) THEN
              (CASE WHEN input_data.indCondInfo003 IS NULL THEN ''null'' ELSE (''"''|| input_data.indCondInfo003 ||''"'') END)::JSONB
            ELSE
              COALESCE((ord_main.ind_cond_info->''3''->>''value''),''null'')::JSONB
          END
      ) ::JSONB
      , ''{2, value}''
      , CASE
          WHEN (SELECT check_type_02 FROM ssi_check_type_infos) THEN
            (CASE WHEN input_data.indCondInfo002 IS NULL THEN ''null'' ELSE (''"''|| input_data.indCondInfo002 ||''"'') END)::JSONB
          ELSE
            COALESCE((ord_main.ind_cond_info->''2''->>''value''),''null'')::JSONB
        END
    ) ::JSONB
    , ''{1, value}''
    , CASE
        WHEN (SELECT check_type_01 FROM ssi_check_type_infos) THEN
          (CASE WHEN input_data.indCondInfo001 IS NULL THEN ''null'' ELSE (''"''|| input_data.indCondInfo001 ||''"'') END)::JSONB
        ELSE
          COALESCE((ord_main.ind_cond_info->''1''->>''value''),''null'')::JSONB
      END
  ) AS cond_json
  FROM ord_main,
       input_data
  WHERE
  ord_no = @ordNo
),
ind_cond_info_data AS (
  SELECT jsonb_object_agg(b.key, b.value) AS ind_cond_info_data
FROM
  (
    SELECT key, value
    FROM jsonb_each((SELECT cond_json FROM ind_cond_tmp_data))
    WHERE
      CASE
        WHEN (SELECT key FROM is_use_no LIMIT 1) IS NOT NULL THEN key IN (SELECT key FROM is_use_no)
        ELSE key NOT IN (SELECT is_not_use_no FROM is_not_use_no)
      END
  ) AS b
)
UPDATE ord_main 
SET
  ind_cond_info = (SELECT ind_cond_info_data FROM ind_cond_info_data),
  ind_off_water_info = jsonb_build_object(
    ''name_1'', CASE 
                WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''OFFWATER1'') = ''1'' 
                THEN ''@ind_off_water_info.ind_off_water_info.name_1''
                WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''OFFWATER1'') = ''0''
                THEN device_set_default.off_water_info->>''name_1''
                ELSE (ind_off_water_info->>''name_1'') 
              END,
    ''name_2'', CASE 
                WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''OFFWATER2'') = ''1'' 
                THEN ''@ind_off_water_info.ind_off_water_info.name_2''
                WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''OFFWATER1'') = ''0''
                THEN device_set_default.off_water_info->>''name_2''
                ELSE (ind_off_water_info->>''name_2'') 
              END,
    ''name_3'', CASE 
                WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''OFFWATER3'') = ''1'' 
                THEN ''@ind_off_water_info.ind_off_water_info.name_3''
                WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''OFFWATER1'') = ''0''
                THEN device_set_default.off_water_info->>''name_3''
                ELSE (ind_off_water_info->>''name_3'') 
              END,
    ''name_4'', CASE 
                WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''OFFWATER4'') = ''1'' AND (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''SOLUTION'') = ''0''
                THEN ''@ind_off_water_info.ind_off_water_info.name_4''
                WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''OFFWATER1'') = ''0''
                THEN device_set_default.off_water_info->>''name_4''
                ELSE (ind_off_water_info->>''name_4'') 
              END,
    ''name_5'', CASE 
                WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''OFFWATER5'') = ''1'' AND (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''IPPWROK'') = ''0''
                THEN ''@ind_off_water_info.ind_off_water_info.name_5''
                WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''OFFWATER1'') = ''0''
                THEN device_set_default.off_water_info->>''name_5''
                ELSE (ind_off_water_info->>''name_5'') 
              END,
    ''weight_1'', CASE 
                  WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''OFFWATER1'') = ''1'' 
                  THEN COALESCE(NULLIF(''@ind_off_water_info.ind_off_water_info.weight_1'', ''''), ''0'')::int
                  WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''OFFWATER1'') = ''0''
                  THEN (device_set_default.off_water_info->>''weight_1'')::int 
                  ELSE (ind_off_water_info->>''weight_1'')::int 
                END,
    ''weight_2'', CASE 
                  WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''OFFWATER2'') = ''1'' 
                  THEN COALESCE(NULLIF(''@ind_off_water_info.ind_off_water_info.weight_2'', ''''), ''0'')::int 
                  WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''OFFWATER1'') = ''0''
                  THEN (device_set_default.off_water_info->>''weight_2'')::int
                  ELSE (ind_off_water_info->>''weight_2'')::int 
                END,
    ''weight_3'', CASE 
                  WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''OFFWATER3'') = ''1'' 
                  THEN COALESCE(NULLIF(''@ind_off_water_info.ind_off_water_info.weight_3'', ''''), ''0'')::int 
                  WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''OFFWATER1'') = ''0''
                  THEN (device_set_default.off_water_info->>''weight_3'')::int
                  ELSE (ind_off_water_info->>''weight_3'')::int 
                END,
    ''weight_4'', CASE 
                  WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''OFFWATER4'') = ''1'' AND (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''USE_SUPLIQUID'') = ''0''
                  THEN COALESCE(NULLIF(''@ind_off_water_info.ind_off_water_info.weight_4'', ''''), ''0'')::int 
                  WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''OFFWATER1'') = ''0''
                  THEN (device_set_default.off_water_info->>''weight_4'')::int
                  ELSE (ind_off_water_info->>''weight_4'')::int 
                END,
    ''weight_5'', CASE 
                  WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''OFFWATER5'') = ''1'' AND (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''IPONESHOT'') = ''0''
                  THEN COALESCE(NULLIF(''@ind_off_water_info.ind_off_water_info.weight_5'', ''''), ''0'')::int 
                  WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''OFFWATER1'') = ''0''
                  THEN (device_set_default.off_water_info->>''weight_5'')::int
                  ELSE (ind_off_water_info->>''weight_5'')::int 
                END
  ),
  ind_tare_info = jsonb_build_object(
    ''name_1'', CASE 
                WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''TARE1'') = ''1'' 
                THEN ''@ind_tare_info.ind_tare_info.name_1''
                WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''TARE1'') = ''0''
                THEN device_set_default.tare_info->>''name_1''
                ELSE (ind_tare_info->>''name_1'') 
              END,
    ''name_2'', CASE 
                WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''TARE2'') = ''1'' 
                THEN ''@ind_tare_info.ind_tare_info.name_2''
                WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''TARE1'') = ''0''
                THEN device_set_default.tare_info->>''name_2''
                ELSE (ind_tare_info->>''name_2'') 
              END,
    ''name_3'', CASE 
                WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''TARE3'') = ''1'' 
                THEN ''@ind_tare_info.ind_tare_info.name_3''
                WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''TARE1'') = ''0''
                THEN device_set_default.tare_info->>''name_3''
                ELSE (ind_tare_info->>''name_3'') 
              END,
    ''name_4'', CASE 
                WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''TARE4'') = ''1'' AND (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''SOLUTION'') = ''0''
                THEN ''@ind_tare_info.ind_tare_info.name_4''
                WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''TARE1'') = ''0''
                THEN device_set_default.tare_info->>''name_4''
                ELSE (ind_tare_info->>''name_4'') 
              END,
    ''name_5'', CASE 
                WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''TARE5'') = ''1'' AND (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''IPPWROK'') = ''0''
                THEN ''@ind_tare_info.ind_tare_info.name_5''
                WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''TARE1'') = ''0''
                THEN device_set_default.tare_info->>''name_5''
                ELSE (ind_tare_info->>''name_5'') 
              END,
    ''weight_1'', CASE 
                  WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''TARE1'') = ''1'' 
                  THEN COALESCE(NULLIF(''@ind_tare_info.ind_tare_info.weight_1'', ''''), ''0'')::int 
                  WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''TARE1'') = ''0''
                  THEN (device_set_default.tare_info->>''weight_1'')::int
                  ELSE (ind_tare_info->>''weight_1'')::int 
                END,
    ''weight_2'', CASE 
                  WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''TARE2'') = ''1'' 
                  THEN COALESCE(NULLIF(''@ind_tare_info.ind_tare_info.weight_2'', ''''), ''0'')::int 
                  WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''TARE1'') = ''0''
                  THEN (device_set_default.tare_info->>''weight_2'')::int
                  ELSE (ind_tare_info->>''weight_2'')::int 
                END,
    ''weight_3'', CASE 
                  WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''TARE3'') = ''1'' 
                  THEN COALESCE(NULLIF(''@ind_tare_info.ind_tare_info.weight_3'', ''''), ''0'')::int 
                  WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''TARE1'') = ''0''
                  THEN (device_set_default.tare_info->>''weight_3'')::int
                  ELSE (ind_tare_info->>''weight_3'')::int 
                END,
    ''weight_4'', CASE 
                  WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''TARE4'') = ''1'' AND (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''SOLUTION'') = ''0''
                  THEN COALESCE(NULLIF(''@ind_tare_info.ind_tare_info.weight_4'', ''''), ''0'')::int 
                  WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''TARE1'') = ''0''
                  THEN (device_set_default.tare_info->>''weight_4'')::int
                  ELSE (ind_tare_info->>''weight_4'')::int 
                END,
    ''weight_5'', CASE 
                  WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''TARE5'') = ''1'' AND (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''IPPWROK'') = ''0''
                  THEN COALESCE(NULLIF(''@ind_tare_info.ind_tare_info.weight_5'', ''''), ''0'')::int 
                  WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''TARE1'') = ''0''
                  THEN (device_set_default.tare_info->>''weight_5'')::int
                  ELSE (ind_tare_info->>''weight_5'')::int 
                END
  )
FROM 
  device_set_default
WHERE
  ord_no = @ordNo', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのオーダ受け(指示：治療条件情報 の更新)', '2020-05-25 18:21:40.841', '2025-06-03 19:23:52.772', '[{"sql_cd": -500013, "field_name": "cd", "replace_var": "@indCondInfo.005.value"}, {"sql_cd": -500025, "field_name": "equipment_cd", "replace_var": "@indCondInfo.008.value"}, {"sql_cd": -500015, "field_name": "equipment_cd", "replace_var": "@indCondInfo.010.value"}, {"sql_cd": -500017, "field_name": "medicine_cd", "replace_var": "@indCondInfo.015.value"}, {"sql_cd": -500027, "field_name": "equipment_cd", "replace_var": "@indCondInfo.006.value"}, {"sql_cd": -500037, "field_name": "equipment_cd", "replace_var": "@indCondInfo.011.value"}, {"sql_cd": -500029, "field_name": "medicine_cd", "replace_var": "@indCondInfo.019.value"}, {"sql_cd": -500035, "field_name": "medicine_cd", "replace_var": "@indCondInfo.025.value"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500090, 'WITH
  -- 既存の physical_info 配列を取得（JSONB 配列として扱う）
  orig AS (
    SELECT
      COALESCE(physical_info, ''[]''::jsonb) AS arr
    FROM ntss.pat_unique
    WHERE
      pat_id       = @patId
      AND is_del     = ''0''
      AND facility_cd = ''@facilityCd''
  ),

  -- JSONB 配列を要素ごとに展開
  elems AS (
    SELECT
      arr,
      elem
    FROM orig
    CROSS JOIN LATERAL jsonb_array_elements(arr) AS elem
  ),

  -- 既存の最大 ctl_no を取得
  max_ctl AS (
    SELECT
      COALESCE(MAX((elem->>''ctl_no'')::int), 0) AS max_ctl
    FROM elems
  ),

  -- 処理日付を hyphen_date（YYYY-MM-DD）と ymd（YYYYMMDD）に整形
  params AS (
    SELECT
      substr(''@treatDate'',1,4) || ''-'' ||
      substr(''@treatDate'',5,2) || ''-'' ||
      substr(''@treatDate'',7,2) AS hyphen_date,
      ''@treatDate'' AS ymd
  ),

  -- DW → 下 2 桁を小数部とみなし ( / 100.0 )、範囲 [0.00–300.00] でクリップ
  -- CTR → 下 1 桁を小数部とみなし ( / 10.0 )、範囲 [0.0–100.0] でクリップ
  new_elem AS (
    SELECT jsonb_build_object(
      ''dw'',
        CASE
          WHEN (@dw::numeric / 100.0) < 0.00   THEN 0.00
          WHEN (@dw::numeric / 100.0) > 300.00 THEN 300.00
          ELSE (@dw::numeric / 100.0)
        END,
      ''ctr'',
        CASE
          WHEN (@ctr::numeric / 10.0) < 0.0    THEN 0.0
          WHEN (@ctr::numeric / 10.0) > 100.0  THEN 100.0
          ELSE (@ctr::numeric / 10.0)
        END,
      ''memo'',                  NULL,
      ''ctl_no'',                (SELECT max_ctl + 1 FROM max_ctl),
      ''height'',                NULL,
      ''chest_dia'',             NULL,
      ''exam_date'',             (SELECT hyphen_date FROM params),
      ''breast_dia'',            NULL,
      ''changer_cd'',            NULL,
      ''ctr_weight'',            NULL,
      ''facility_cd'',           ''@facilityCd'',
      ''order_class'',           NULL,
      ''indicator_cd'',          NULL,
      ''inspect_date'',          (SELECT ymd FROM params),
      ''target_weight'',         NULL,
      ''pre_scale_lower'',       NULL,
      ''pre_scale_upper'',       NULL,
      ''indicator_start_date'',  (SELECT ymd FROM params)
    ) AS elem
  ),

  -- 既存要素を同じ日付で上書きするか、新規配列に追加するか判定
  new_arr AS (
    SELECT
      CASE
        -- 同じ exam_date の要素があれば、その要素の dw, ctr を更新
        WHEN EXISTS (
          SELECT 1
          FROM elems
          JOIN params ON elems.elem->>''exam_date'' = params.hyphen_date
        )
        THEN (
          SELECT jsonb_agg(
            CASE
              WHEN e.elem->>''exam_date'' = p.hyphen_date
              THEN
                -- 既存要素に対して、dw と ctr を上書き。どちらもクリップ済みの値を使う。
                e.elem || jsonb_build_object(
                  ''dw'',
                    CASE
                      WHEN (@dw::numeric / 100.0) < 0.00   THEN 0.00
                      WHEN (@dw::numeric / 100.0) > 300.00 THEN 300.00
                      ELSE (@dw::numeric / 100.0)
                    END,
                  ''ctr'',
                    CASE
                      WHEN (@ctr::numeric / 10.0) < 0.0    THEN 0.0
                      WHEN (@ctr::numeric / 10.0) > 100.0  THEN 100.0
                      ELSE (@ctr::numeric / 10.0)
                    END
                )
              ELSE
                -- exam_date が異なる要素はそのまま
                e.elem
            END
          )
          FROM elems AS e
          CROSS JOIN params AS p
        )
        ELSE
          -- 同じ日付がなければ、新しい要素を配列末尾に追加
          ( SELECT orig.arr || jsonb_build_array(n.elem)
            FROM orig
            CROSS JOIN new_elem AS n
          )
      END AS arr
  )

-- 最終的に physical_info を更新
UPDATE ntss.pat_unique AS t
SET physical_info = na.arr
FROM new_arr AS na
WHERE
  t.pat_id       = @patId
  AND t.is_del     = ''0''
  AND t.facility_cd = ''@facilityCd'';
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのオーダ受け(DW,CRTの更新)', '2025-05-31 01:28:31.821', '2025-05-31 01:28:41.720', NULL);

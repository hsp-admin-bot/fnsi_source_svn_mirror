DELETE FROM sys_data_set WHERE sql_cd IN (-301, -500011, -500012, -500013, -500015, -500016, -500017, -500018, -500019, -500020, -500023, -500024, -500025, -500026, -500027, -500028, -500029, -500030, -500031, -500032, -500033, -500034, -500035, -500036, -500037, -500038, -500039, -500040, -500041, -500042, -500043, -500044, -500045, -500046, -500048, -500049, -500050, -500051, -500052, -500053, -500054, -500058, -500059, -500060, -500061, -500062, -500063, -500064, -500065, -500066, -500067, -500068, -500069, -500071, -500072, -500073, -500074, -500081, -500082, -500083, -500084, -500085, -500086, -500087, -501001, -501002, -501003, -501011, -501012, -501013, -501021, -501022, -501023, -501031, -501032, -501033, -501041, -501051, -501061, -501071, -501081, -501091, -501092, -501093, -501094, -501095, -501096, -501097, -501098, -501099, -501100, -501101, -501102, -501103, -501104, -501105, -501106, -502000, -502002, -502003, -503000, -503001, -503002, -504000, -504001, -504002, -505000, -505002, -65, -99987, 8101, 8102, 8103, 8104, 8105, 8107, 8109);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(8109, 'WITH ssi_in_hospital_cd AS ( 
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
procedure as (
  select procedure_cd
  from mst_procedure
  where is_del = ''0''
	and is_disp = ''1''
	and CASE (SELECT VALUE FROM ssi_in_hospital_cd)
			WHEN ''1'' THEN in_hospital_cd_a1 = ''@indMediInfo.procedureCd''
			WHEN ''2'' THEN in_hospital_cd_a2 = ''@indMediInfo.procedureCd''
		END
	and facility_cd = ''@facilityCd''
	and ''@indMediInfo.procedureCd''<>''''
  limit 1
),
medicine as (
  SELECT mst_medicine.medicine_cd
      ,  mst_medicine.class_cd
      ,  COALESCE(mst_medicine_class.class_name,'''') AS class_name
      ,  COALESCE(mst_medicine.medicine_short_name,'''') AS medicine_short_name
  FROM mst_medicine
  INNER JOIN mst_medicine_class ON mst_medicine.class_cd = mst_medicine_class.class_cd
  WHERE mst_medicine.is_del = ''0''
  and mst_medicine.is_disp = ''1''
  and CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN mst_medicine.in_hospital_cd_1 = ''@indMediInfo.cd''
        WHEN ''2'' THEN mst_medicine.in_hospital_cd_2 = ''@indMediInfo.cd''
        WHEN ''3'' THEN mst_medicine.in_hospital_cd_3 = ''@indMediInfo.cd''
        WHEN ''4'' THEN mst_medicine.in_hospital_cd_4 = ''@indMediInfo.cd''
      END
  and mst_medicine.facility_cd = ''@facilityCd''
  and ''@indMediInfo.cd''<>''''
  limit 1
),
filteredValue as (
  SELECT jsonb_agg(value) AS filtered_ind_medi_info
  FROM (
      SELECT value
      FROM ord_main, jsonb_array_elements(ind_medi_info) WITH ORDINALITY arr(value, index)
      where ord_no = @ordNo  
      ORDER BY index
  ) filtered
),
isExistsData as (
  SELECT jsonb_agg(value) AS filtered_rst_medi_info
  FROM (
      SELECT value
      FROM ord_main, jsonb_array_elements(rst_medi_info) WITH ORDINALITY arr(value, index)
      where value ->> ''cd'' = (SELECT medicine_cd FROM medicine)::text
      and value ->> ''effect_flg'' = ''1''
      and ord_no = @ordNo  
      ORDER BY index
  ) filtered
),
newNo as (
  SELECT COALESCE(max(medi_info_no),-1) AS no
  FROM medicine_latest_no
  WHERE facility_cd = ''@facilityCd''
  and pat_id = @patId
)
UPDATE ord_main 
SET
  ind_medi_info = CASE WHEN (SELECT (SELECT filtered_rst_medi_info FROM isExistsData) is not null and (ind_medi_info <> ''[]'')) THEN ''@indMediInfoValue'' 
    ELSE 
      CASE WHEN (SELECT (SELECT filtered_ind_medi_info FROM filteredValue) is null) THEN 
        concat(''[{"cd":'',COALESCE((SELECT medicine_cd FROM medicine)::text,''null''),'',
        "no":'',(SELECT no+1 FROM newNo)::text,'',
        "name":"@indMediInfo.name",
        "unit":"@indMediInfo.unit",
        "amount":"@indMediInfo.amount",
        "comment":null,
        "class_cd":'',COALESCE((SELECT class_cd FROM medicine)::text,''null''),'',
        "init_date":"@indMediInfo.initDate",
        "timing_cd":null,
        "class_name":"'',COALESCE((SELECT class_name FROM medicine)::text,''''),''",
        "class_type": 0,
        "short_name":"'',COALESCE((SELECT medicine_short_name FROM medicine)::text,''''),''",
        "ind_user_id":@indMediInfo.updUserId,
        "input_class":@indMediInfo.inputClass,
        "is_editable":"@indMediInfo.isEditable",
        "upd_user_id":@indMediInfo.updUserId,
        "cop_order_no":null,
        "procedure_cd":'',COALESCE((SELECT procedure_cd FROM procedure)::text,''null''),'',
        "procedure_name": "@indMediInfo.procedureName",
        "date_interval":0,
        "medicine_type":@indMediInfo.medicineType,
        "ind_user_last_name":"@indMediInfo.indUserLastName",
        "upd_user_last_name":"@indMediInfo.updUserLastName",
        "ind_user_first_name":"@indMediInfo.indUserFirstName",
        "upd_user_first_name":"@indMediInfo.updUserFirstName"}]'')::jsonb 
      ELSE 
        (SELECT filtered_ind_medi_info::text FROM filteredValue)::jsonb  || concat(''[{"cd":'',(SELECT medicine_cd FROM medicine)::text,'',
        "no":'',(SELECT no+1 FROM newNo)::text,'',
        "name":"@indMediInfo.name",
        "unit":"@indMediInfo.unit",
        "amount":"@indMediInfo.amount",
        "comment":null,
        "class_cd":'',COALESCE((SELECT class_cd FROM medicine)::text,''null''),'',
        "init_date":"@indMediInfo.initDate",
        "timing_cd":null,
        "class_name":"'',COALESCE((SELECT class_name FROM medicine)::text,''''),''",
        "class_type": 0,
        "short_name":"'',COALESCE((SELECT medicine_short_name FROM medicine)::text,''''),''",
        "ind_user_id":@indMediInfo.updUserId,
        "input_class":@indMediInfo.inputClass,
        "is_editable":"@indMediInfo.isEditable",
        "upd_user_id":@indMediInfo.updUserId,
        "cop_order_no":null,
        "procedure_cd":'',COALESCE((SELECT procedure_cd FROM procedure)::text,''null''),'',
        "procedure_name": "@indMediInfo.procedureName",
        "date_interval":0,
        "medicine_type":@indMediInfo.medicineType,
        "ind_user_last_name":"@indMediInfo.indUserLastName",
        "upd_user_last_name":"@indMediInfo.updUserLastName",
        "ind_user_first_name":"@indMediInfo.indUserFirstName",
        "upd_user_first_name":"@indMediInfo.updUserFirstName"}]'')::jsonb 
      END 
    END 
WHERE
  ord_no = @ordNo
AND
  (SELECT medicine_cd FROM medicine) is not null', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのオーダ受け(処方情報の更新)', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, '[{"sql_cd": -500067}, {"sql_cd": -500031, "field_name": "user_id", "replace_var": "@indMediInfo.updUserId"}, {"sql_cd": -500031, "field_name": "user_last_name", "replace_var": "@indMediInfo.indUserLastName"}, {"sql_cd": -500031, "field_name": "user_first_name", "replace_var": "@indMediInfo.indUserFirstName"}, {"sql_cd": -500031, "field_name": "user_last_name", "replace_var": "@indMediInfo.updUserLastName"}, {"sql_cd": -500031, "field_name": "user_first_name", "replace_var": "@indMediInfo.updUserFirstName"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(8107, 'WITH ssi_in_hospital_cd AS ( 
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
equipment_info AS(
    SELECT
        equipment_cd,
        equipment_name
    FROM
        mst_equipment
    WHERE
        facility_cd = ''@facilityCd''
    AND CASE (SELECT VALUE FROM ssi_in_hospital_cd)
          WHEN ''1'' THEN in_hospital_cd_1 = ''@indEquipInfo.cd''
          WHEN ''2'' THEN in_hospital_cd_2 = ''@indEquipInfo.cd''
          WHEN ''3'' THEN in_hospital_cd_3 = ''@indEquipInfo.cd''
          WHEN ''4'' THEN in_hospital_cd_4 = ''@indEquipInfo.cd''
        END
    AND is_del = ''0''
    AND is_disp = ''1''
    ORDER BY equipment_cd DESC
    LIMIT 1
)
UPDATE ord_main 
SET
  ind_equip_info = CASE ''@indEquipInfoFlg'' 
    WHEN '''' THEN ''@indEquipInfoValue'' 
    ELSE
      ind_equip_info || concat(''[{"cd":'',COALESCE((SELECT equipment_cd FROM equipment_info)::text,''''),'',
      "amount":"@indEquipInfo.amount",
      "equip_type":0,
      "ind_user_id":"@indEquipInfo.indUserId",
      "input_class":1,
      "is_editable":"@indEquipInfo.isEditable",
      "needle_type":null,
      "upd_user_id":"@indEquipInfo.updUserId",
      "cop_order_no":null,
      "ind_user_last_name":"@indEquipInfo.indUserLastName",
      "upd_user_last_name":"@indEquipInfo.updUserLastName",
      "ind_user_first_name":"@indEquipInfo.indUserFirstName",
      "upd_user_first_name":"@indEquipInfo.updUserFirstName"}]'')::jsonb 
    END 
WHERE
  ord_no = ''@ordNo''
AND
  (SELECT equipment_cd FROM equipment_info) is not null', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのオーダ受け(消耗品情報の更新)', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(8105, 'UPDATE ord_main 
SET
  is_del = ''1''
  , up_user_id = CASE ''@upUserId'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@upUserId'', ''999999999999999999'') 
    END
  , up_date = CURRENT_TIMESTAMP 
WHERE
  ord_no = @ordNo
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのオーダ受け(DELETE)', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, '[{"sql_cd": -500031, "field_name": "user_id", "replace_var": "@upUserId"}]'::jsonb);
INSERT INTO sys_data_set
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
  SELECT 
    COALESCE((
      select
        device_mode
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
    ),''-1'') AS device_mode
),
calc_value AS (
  SELECT
    CASE 
      WHEN LTRIM(''@indCondInfo.020.value'', ''0'') = '''' AND LTRIM(''@indCondInfo.024.value'', ''0'') = '''' THEN ''0''
      WHEN LTRIM(''@indCondInfo.020.value'', ''0'') = '''' AND LTRIM(''@indCondInfo.024.value'', ''0'') <> '''' THEN  TO_CHAR(TO_NUMBER(CASE WHEN ''@indCondInfo.024.value''<>'''' THEN ''@indCondInfo.024.value'' ELSE ''0'' END, ''FM999999999999999999'') / 100 * (TO_NUMBER(CASE WHEN ''@indCondInfo.024.value''<>'''' THEN ''@indCondInfo.024.value'' ELSE ''0'' END, ''FM999999999999999999'') / 60), ''FM999999999999999990.00'')
      ELSE TO_CHAR(CAST(TO_NUMBER(CASE WHEN ''@indCondInfo.020.value''<>'''' THEN ''@indCondInfo.020.value'' ELSE ''0'' END, ''FM999999999999999999'') / 10 AS FLOAT), ''FM999999999999999990.00'')
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
input_data AS(
  SELECT
    COALESCE(NULLIF(LTRIM(''@indCondInfo.001.value'', ''0''),''''),(ord_main.ind_cond_info->''1''->>''value'')::TEXT) AS indCondInfo001,
    CASE 
      WHEN (SELECT is_new FROM is_new) THEN COALESCE((SELECT va_cd FROM va_info)::text,(ord_main.ind_cond_info->''2''->>''value'')::TEXT)
      ELSE (SELECT va_cd FROM va_info)::text
    END AS indCondInfo002,
    ''-1'' AS indCondInfo003,
    COALESCE(TO_CHAR((NULLIF(''@indCondInfo.004.value'', '''')::numeric / 100),''FM999999990.00''), (ord_main.ind_cond_info->''4''->>''value'')::TEXT) AS indCondInfo004,
    CASE 
      WHEN (SELECT is_new FROM is_new) THEN COALESCE(NULLIF(''@indCondInfo.005.value'',''''),(ord_main.ind_cond_info->''5''->>''value'')::TEXT)
      ELSE NULLIF(''@indCondInfo.005.value'','''')
    END AS indCondInfo005,
    CASE 
      WHEN (SELECT is_new FROM is_new) THEN COALESCE(NULLIF(''@indCondInfo.006.value'',''''),(ord_main.ind_cond_info->''6''->>''value'')::TEXT)
      ELSE NULLIF(''@indCondInfo.006.value'','''')
    END AS indCondInfo006,
    CASE 
      WHEN (SELECT is_new FROM is_new) THEN COALESCE(NULLIF(''@indCondInfo.005.value'',''''),(ord_main.ind_cond_info->''5''->>''value'')::TEXT)
      ELSE NULLIF(''@indCondInfo.005.value'','''')
    END AS indCondInfo007,
    CASE 
      WHEN (SELECT is_new FROM is_new) THEN COALESCE(NULLIF(''@indCondInfo.008.value'',''''),(ord_main.ind_cond_info->''8''->>''value'')::TEXT)
      ELSE NULLIF(''@indCondInfo.008.value'','''')
    END AS indCondInfo008,
    COALESCE(NULLIF(''@indCondInfo.010.value'',''''),(ord_main.ind_cond_info->''9''->>''value'')::TEXT) indCondInfo009,
    COALESCE(NULLIF(''@indCondInfo.011.value'',''''),(ord_main.ind_cond_info->''10''->>''value'')::TEXT) AS indCondInfo010,
    COALESCE(NULLIF(LTRIM(''@indCondInfo.014.value'', ''0''),''''),(ord_main.ind_cond_info->''14''->>''value'')::TEXT) AS indCondInfo014,
    CASE 
      WHEN (SELECT is_new FROM is_new) THEN COALESCE(NULLIF(''@indCondInfo.015.value'',''''),(ord_main.ind_cond_info->''15''->>''value'')::TEXT)
      ELSE NULLIF(''@indCondInfo.015.value'','''')
    END AS indCondInfo015,
    COALESCE(NULLIF(LTRIM(''@ind_tare_info.ind_tare_info.weight_4'', ''0''),''''),''0'') AS indCondInfo016,
    TO_CHAR((CAST(TO_NUMBER(COALESCE(NULLIF(''@indCondInfo.017.value'', ''''), ''0''), ''FM999999999999999999'')/100 AS FLOAT)),''FM999999990.00'') AS indCondInfo017,
    TO_CHAR((CAST(TO_NUMBER(COALESCE(NULLIF(''@indCondInfo.018.value'', ''''), ''0''), ''FM999999999999999999'')/10 AS FLOAT)),''FM999999990.00'') AS indCondInfo018,
    CASE 
      WHEN (SELECT device_mode FROM device_mode) in (''1'',''2'') THEN 
        NULL
      ELSE
        CASE 
          WHEN (SELECT is_new FROM is_new) THEN COALESCE(NULLIF(''@indCondInfo.019.value'',''''),(ord_main.ind_cond_info->''19''->>''value'')::TEXT)
          ELSE NULLIF(''@indCondInfo.019.value'','''')
        END
    END AS indCondInfo019,
    CASE 
      WHEN (SELECT device_mode FROM device_mode) in (''1'',''2'',''10'') THEN 
        (''0.0'')
      ELSE
        (SELECT replenisher_amount FROM calc_value)::TEXT
    END AS indCondInfo020,
    CASE LTRIM(''@ind_off_water_info.ind_off_water_info.weight_4'', ''0'')
      WHEN LTRIM((SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''SUPLIQUID_BEFORE_CD''), ''0'') THEN ''1''
      WHEN LTRIM((SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''SUPLIQUID_AFTER_CD''), ''0'') THEN ''0''
      ELSE ((ord_main.ind_cond_info->''21''->>''value'')::TEXT)
    END AS indCondInfo021, 
    CASE 
      WHEN (SELECT device_mode FROM device_mode) in (''1'',''2'',''10'') THEN 
        (''0'')
      ELSE
        CASE ''@indCondInfo.format''
          WHEN ''Standard'' THEN TO_CHAR(COALESCE(NULLIF(''@indCondInfo.022.value'', ''''), ''0'')::numeric,''FM999999990.00'')
          ELSE TO_CHAR((CAST(TO_NUMBER(COALESCE(NULLIF(''@indCondInfo.022.value'', ''''), ''0''), ''FM999999999999999999'')/100 AS FLOAT)),''FM999999990.00'')
        END
    END AS indCondInfo022,
    CASE 
      WHEN (SELECT device_mode FROM device_mode) in (''1'',''2'',''10'') THEN 
        (''0'')
      ELSE
        (SELECT replenisher_speed::TEXT FROM calc_value)
    END AS indCondInfo024,
    CASE 
      WHEN (SELECT is_new FROM is_new) THEN COALESCE(NULLIF(''@indCondInfo.025.value'',''''),(ord_main.ind_cond_info->''25''->>''value'')::TEXT)
      ELSE NULLIF(''@indCondInfo.025.value'','''')
    END AS indCondInfo025,
    TO_CHAR((CAST(TO_NUMBER(COALESCE(NULLIF(''@indCondInfo.026.value'', ''''), ''0''), ''FM999999999999999999'')/100 AS FLOAT)),''FM999999990.00'') AS indCondInfo026,
    TO_CHAR((CAST(TO_NUMBER(COALESCE(NULLIF(''@indCondInfo.027.value'', ''''), ''0''), ''FM999999999999999999'')/100 AS FLOAT)),''FM999999990.00'') AS indCondInfo027,
    TO_CHAR((CAST(TO_NUMBER(COALESCE(NULLIF(''@indCondInfo.028.value'', ''''), ''0''), ''FM999999999999999999'')/100 AS FLOAT)),''FM999999990.00'') AS indCondInfo028,
    COALESCE(NULLIF(LTRIM(''@ind_off_water_info.ind_off_water_info.weight_5'', ''0''),''''),(ord_main.ind_cond_info->''31''->>''value'')::TEXT)AS indCondInfo031,
    COALESCE(TO_CHAR(NULLIF(''@indCondInfo.033.value'', '''')::numeric / 10, ''FM999999990.0''), (ord_main.ind_cond_info->''32''->>''value'')::TEXT) AS indCondInfo032,
    COALESCE(NULLIF(LTRIM(''@ind_tare_info.ind_tare_info.weight_5'', ''0''),''''),(ord_main.ind_cond_info->''38''->>''value'')::TEXT)AS indCondInfo038,
    COALESCE(NULLIF(''@indCondInfo.039.value'',''''),(ord_main.ind_cond_info->''39''->>''value'')::TEXT) AS indCondInfo039
FROM 
  ord_main
WHERE
  ord_no = @ordNo
)
UPDATE ord_main 
SET
  ind_cond_info = jsonb_set( 
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
  ),
  ind_off_water_info = jsonb_build_object(
    ''name_1'', CASE 
              WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''OFFWATER1'') = ''1'' 
              THEN ''@ind_off_water_info.ind_off_water_info.name_1''
              ELSE (ind_off_water_info->>''name_1'') 
            END,
    ''name_2'', CASE 
                WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''OFFWATER2'') = ''1'' 
                THEN ''@ind_off_water_info.ind_off_water_info.name_2''
                ELSE (ind_off_water_info->>''name_2'') 
              END,
    ''name_3'', CASE 
                WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''OFFWATER3'') = ''1'' 
                THEN ''@ind_off_water_info.ind_off_water_info.name_3''
                ELSE (ind_off_water_info->>''name_3'') 
              END,
    ''name_4'', CASE 
                WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''OFFWATER4'') = ''1'' AND (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''SOLUTION'') = ''0''
                THEN ''@ind_off_water_info.ind_off_water_info.name_4''
                ELSE (ind_off_water_info->>''name_4'') 
              END,
    ''name_5'', CASE 
                WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''OFFWATER5'') = ''1'' AND (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''IPPWROK'') = ''0''
                THEN ''@ind_off_water_info.ind_off_water_info.name_5''
                ELSE (ind_off_water_info->>''name_5'') 
              END,
    ''weight_1'', CASE 
                  WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''OFFWATER1'') = ''1'' 
                  THEN COALESCE(NULLIF(''@ind_off_water_info.ind_off_water_info.weight_1'', ''''), ''0'')::int 
                  ELSE (ind_off_water_info->>''weight_1'')::int 
                END,
    ''weight_2'', CASE 
                  WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''OFFWATER2'') = ''1'' 
                  THEN COALESCE(NULLIF(''@ind_off_water_info.ind_off_water_info.weight_2'', ''''), ''0'')::int 
                  ELSE (ind_off_water_info->>''weight_2'')::int 
                END,
    ''weight_3'', CASE 
                  WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''OFFWATER3'') = ''1'' 
                  THEN COALESCE(NULLIF(''@ind_off_water_info.ind_off_water_info.weight_3'', ''''), ''0'')::int 
                  ELSE (ind_off_water_info->>''weight_3'')::int 
                END,
    ''weight_4'', CASE 
                  WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''OFFWATER4'') = ''1'' AND (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''USE_SUPLIQUID'') = ''0''
                  THEN COALESCE(NULLIF(''@ind_off_water_info.ind_off_water_info.weight_4'', ''''), ''0'')::int 
                  ELSE (ind_off_water_info->>''weight_4'')::int 
                END,
    ''weight_5'', CASE 
                  WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''OFFWATER5'') = ''1'' AND (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''IPONESHOT'') = ''0''
                  THEN COALESCE(NULLIF(''@ind_off_water_info.ind_off_water_info.weight_5'', ''''), ''0'')::int 
                  ELSE (ind_off_water_info->>''weight_5'')::int 
                END
  ),
  ind_tare_info = jsonb_build_object(
    ''name_1'', CASE 
              WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''TARE1'') = ''1'' 
              THEN ''@ind_tare_info.ind_tare_info.name_1''
              ELSE (ind_tare_info->>''name_1'') 
            END,
    ''name_2'', CASE 
                WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''TARE2'') = ''1'' 
                THEN ''@ind_tare_info.ind_tare_info.name_2''
                ELSE (ind_tare_info->>''name_2'') 
              END,
    ''name_3'', CASE 
                WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''TARE3'') = ''1'' 
                THEN ''@ind_tare_info.ind_tare_info.name_3''
                ELSE (ind_tare_info->>''name_3'') 
              END,
    ''name_4'', CASE 
                WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''TARE4'') = ''1'' AND (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''SOLUTION'') = ''0''
                THEN ''@ind_tare_info.ind_tare_info.name_4''
                ELSE (ind_tare_info->>''name_4'') 
              END,
    ''name_5'', CASE 
                WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''TARE5'') = ''1'' AND (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''IPPWROK'') = ''0''
                THEN ''@ind_tare_info.ind_tare_info.name_5''
                ELSE (ind_tare_info->>''name_5'') 
              END,
    ''weight_1'', CASE 
                  WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''TARE1'') = ''1'' 
                  THEN COALESCE(NULLIF(''@ind_tare_info.ind_tare_info.weight_1'', ''''), ''0'')::int 
                  ELSE (ind_tare_info->>''weight_1'')::int 
                END,
    ''weight_2'', CASE 
                  WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''TARE2'') = ''1'' 
                  THEN COALESCE(NULLIF(''@ind_tare_info.ind_tare_info.weight_2'', ''''), ''0'')::int 
                  ELSE (ind_tare_info->>''weight_2'')::int 
                END,
    ''weight_3'', CASE 
                  WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''TARE3'') = ''1'' 
                  THEN COALESCE(NULLIF(''@ind_tare_info.ind_tare_info.weight_3'', ''''), ''0'')::int 
                  ELSE (ind_tare_info->>''weight_3'')::int 
                END,
    ''weight_4'', CASE 
                  WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''TARE4'') = ''1'' AND (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''SOLUTION'') = ''0''
                  THEN COALESCE(NULLIF(''@ind_tare_info.ind_tare_info.weight_4'', ''''), ''0'')::int 
                  ELSE (ind_tare_info->>''weight_4'')::int 
                END,
    ''weight_5'', CASE 
                  WHEN (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''TARE5'') = ''1'' AND (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''IPPWROK'') = ''0''
                  THEN COALESCE(NULLIF(''@ind_tare_info.ind_tare_info.weight_5'', ''''), ''0'')::int 
                  ELSE (ind_tare_info->>''weight_5'')::int 
                END
  )
FROM 
  input_data
WHERE
  ord_no = @ordNo', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのオーダ受け(指示：治療条件情報 の更新)', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, '[{"sql_cd": -500013, "field_name": "cd", "replace_var": "@indCondInfo.005.value"}, {"sql_cd": -500025, "field_name": "equipment_cd", "replace_var": "@indCondInfo.008.value"}, {"sql_cd": -500015, "field_name": "equipment_cd", "replace_var": "@indCondInfo.010.value"}, {"sql_cd": -500017, "field_name": "medicine_cd", "replace_var": "@indCondInfo.015.value"}, {"sql_cd": -500027, "field_name": "equipment_cd", "replace_var": "@indCondInfo.006.value"}, {"sql_cd": -500037, "field_name": "equipment_cd", "replace_var": "@indCondInfo.011.value"}, {"sql_cd": -500029, "field_name": "medicine_cd", "replace_var": "@indCondInfo.019.value"}, {"sql_cd": -500035, "field_name": "medicine_cd", "replace_var": "@indCondInfo.025.value"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(8103, 'WITH device_set_info_default AS ( 
  SELECT
    (device_set_info ->> ''ord'')::jsonb as device_set_info_ord
  FROM
    mst_device_set_info_default
  WHERE
    facility_cd = ''@facilityCd''
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
dialyzer_info AS(
  select
    dialyzer_cd
  from
    mst_dialyzer
  where
    is_del = ''0''
    and is_disp = ''1''
    and CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN in_hospital_cd_1 = ''@indEquipInfo.cd'' AND COALESCE(in_hospital_cd_1,'''') <> ''''
        WHEN ''2'' THEN in_hospital_cd_2 = ''@indEquipInfo.cd'' AND COALESCE(in_hospital_cd_2,'''') <> ''''
        WHEN ''3'' THEN in_hospital_cd_3 = ''@indEquipInfo.cd'' AND COALESCE(in_hospital_cd_3,'''') <> ''''
        WHEN ''4'' THEN in_hospital_cd_4 = ''@indEquipInfo.cd'' AND COALESCE(in_hospital_cd_4,'''') <> ''''
      END
    and facility_cd = ''@facilityCd''
    ORDER BY dialyzer_cd DESC
    LIMIT 1
),
bed_used_check AS (
SELECT CASE WHEN EXISTS (
  SELECT
    1
  FROM
    ord_main
  WHERE
    facility_cd = ''@facilityCd''
    AND treat_date = ''@treatDate''
    AND ind_kur_cd::text = ''@indKurCd''
    AND ind_kur_cd <> 0
    AND ind_bed_cd::text = ''@indBedCd''
    AND ord_no <> @ordNo
    AND is_del = ''0''
    )
    THEN ''0''
    ELSE ''@indBedCd''
    END AS bed_cd
  )
UPDATE ord_main 
SET
    ind_va_cd = CASE ''@indVaCd'' 
      WHEN '''' THEN NULL 
      ELSE TO_NUMBER(''@indVaCd'', ''999999999'') 
    END
  , ind_treatment_cd = CASE ''@indTreatmentCd'' 
      WHEN '''' THEN NULL 
      ELSE TO_NUMBER(''@indTreatmentCd'', ''999999999'') 
    END
  , ind_kur_cd = CASE ''@indKurCd'' 
      WHEN '''' THEN 0 
      ELSE TO_NUMBER(''@indKurCd'', ''999999999999999999'') 
    END
  , ind_treat_start_time = NULLIF(''@indTreatStartTime'', '''')
  , ind_bed_cd = TO_NUMBER((SELECT bed_cd FROM bed_used_check), ''999999999999999999'') 
  , ind_schedule_user_info = CASE
      WHEN ''@indKurCd'' = ind_kur_cd::text AND ''@indTreatStartTime'' = ind_treat_start_time THEN ''@indScheduleUserInfoValue'' 
      ELSE json_build_object( 
        ''ind_user_id''
        , CASE ''@userId'' 
          WHEN '''' THEN NULL 
          ELSE TO_NUMBER(''@userId'', ''999999999'') 
          END
        , ''ind_user_last_name''
        , NULLIF(''@userLastName'', '''')
        , ''ind_user_first_name''
        , NULLIF(''@userFirstName'', '''')
        , ''upd_user_id''
        , CASE ''@userId'' 
          WHEN '''' THEN NULL 
          ELSE TO_NUMBER(''@userId'', ''999999999'') 
          END
        , ''upd_user_last_name''
        , NULLIF(''@userLastName'', '''') 
        , ''upd_user_first_name''
        , NULLIF(''@userFirstName'', '''')
        , ''ind_kur_cd_before''
        , ind_kur_cd
        , ''ind_treat_start_time_before''
        , ind_treat_start_time
      ) 
    END
  , ind_medi_info = ''@indMediInfoValue''
  , ind_equip_info = CASE COALESCE((SELECT dialyzer_cd FROM dialyzer_info)::text,'''')
      WHEN '''' THEN ''@indEquipInfoValue'' 
      ELSE (''[{"cd":"''||(SELECT dialyzer_cd FROM dialyzer_info)::text||''", "name":"@indEquipInfo.name","unit":null,"amount":null,"class_cd":null,"class_name":null,"class_type":null,"equip_type":null,"short_name":null,"ind_user_id":null,"input_class":null,"is_editable":null,"needle_type":null,"upd_user_id":null,"cop_order_no":null,"ind_user_last_name":null,"upd_user_last_name":null,"ind_user_first_name":null,"upd_user_first_name":null}]'')::jsonb 
      END
  , ind_ind_comment_info = ''@indIndCommentInfoValue''
  , ind_device_set_info = NULLIF((SELECT device_set_info_ord FROM device_set_info_default), ''[]'')::JSONB
  , up_date = CURRENT_TIMESTAMP 
  , up_user_id = CASE ''@upUserId'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@upUserId'', ''999999999999999999'') 
    END
WHERE
  ord_no = @ordNo', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのオーダ受け(UPDATE)', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, '[{"sql_cd": -500011, "field_name": "ind_treatment_cd", "replace_var": "@indTreatmentCd"}, {"sql_cd": -500012, "field_name": "ind_bed_cd", "replace_var": "@indBedCd"}, {"sql_cd": -500031, "field_name": "user_id", "replace_var": "@userId"}, {"sql_cd": -500031, "field_name": "user_last_name", "replace_var": "@userLastName"}, {"sql_cd": -500031, "field_name": "user_first_name", "replace_var": "@userFirstName"}, {"sql_cd": -500039, "field_name": "ind_va_cd", "replace_var": "@indVaCd"}, {"sql_cd": -500082, "field_name": "kur_cd", "replace_var": "@indKurCd"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(8102, 'WITH device_set_info_default AS ( 
  SELECT
    (device_set_info ->> ''ord'')::jsonb as device_set_info_ord
  FROM
    mst_device_set_info_default
  WHERE
    facility_cd = ''@facilityCd''
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
dialyzer_info AS(
  select
    dialyzer_cd
  from
    mst_dialyzer
  where
    is_del = ''0''
    and is_disp = ''1''
    and CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN in_hospital_cd_1 = ''@indEquipInfo.cd'' AND COALESCE(in_hospital_cd_1,'''') <> ''''
        WHEN ''2'' THEN in_hospital_cd_2 = ''@indEquipInfo.cd'' AND COALESCE(in_hospital_cd_2,'''') <> ''''
        WHEN ''3'' THEN in_hospital_cd_3 = ''@indEquipInfo.cd'' AND COALESCE(in_hospital_cd_3,'''') <> ''''
        WHEN ''4'' THEN in_hospital_cd_4 = ''@indEquipInfo.cd'' AND COALESCE(in_hospital_cd_4,'''') <> ''''
      END
    and facility_cd = ''@facilityCd''
    ORDER BY dialyzer_cd DESC
    LIMIT 1
),
bed_used_check AS (
SELECT CASE WHEN EXISTS (
  SELECT
    1
  FROM
    ord_main
  WHERE
    facility_cd = ''@facilityCd''
    AND treat_date = ''@treatDate''
    AND ind_kur_cd::text = ''@indKurCd''
    AND ind_kur_cd <> 0
    AND ind_bed_cd::text = ''@indBedCd''
    AND is_del = ''0''
    )
    THEN ''0''
    ELSE ''@indBedCd''
    END AS bed_cd
  )
INSERT INTO ord_main( 
  pat_id
  , fn_pat_id
  , treat_date
  , treat_week
  , facility_cd
  , facility_name
  , ind_va_cd
  , ind_treatment_cd
  , ind_treatment_name
  , ind_kur_cd
  , ind_kur_name
  , ind_treat_start_time
  , ind_bed_cd
  , ind_bed_name
  , ind_schedule_user_info
  , ind_cond_info
  , ind_medi_info
  , ind_equip_info
  , ind_ind_comment_info
  , ind_tare_info
  , ind_off_water_info
  , ind_device_set_info
  , rst_fn_dialysis_no
  , rst_relation_dialysis_no
  , rst_edition
  , rst_is_update_edition
  , rst_input_class
  , rst_dialysis_state
  , rst_treatment_cd
  , rst_treatment_name
  , rst_kur_cd
  , rst_kur_name
  , rst_bed_cd
  , rst_bed_name
  , rst_machine_no
  , rst_machine_name
  , rst_cond_send_date
  , rst_accept_date
  , rst_start_date
  , rst_end_date
  , rst_return_home_date
  , rst_in_out_class
  , rst_dialysis_cnt
  , rst_ward_cd
  , rst_ward_name
  , rst_course_cd
  , rst_course_name
  , rst_puncture_user_info
  , rst_return_user_info
  , rst_charge_user_info
  , rst_blood_circulate_total
  , rst_running_time
  , rst_kt_v
  , rec_set_date
  , send_ctl_no
  , blood_purifier_name
  , pull_leave_amount
  , rst_cond_info
  , rst_medi_info
  , rst_equip_info
  , rst_ind_comment_info
  , rst_tare_info
  , rst_off_water_info
  , rst_weight_info
  , rst_complaint_info
  , rst_treatment_info
  , rst_treat_staff_info
  , rst_rounds_info
  , is_del
  , up_date
  , reg_date
  , rst_dw
  , weight_scale_no
  , treat_type
  , is_confirm
  , ind_dw
  , rst_purification_cnt
  , addition_info
  , up_ind_user_id
  , up_user_id
  , rst_edition_date
  , cur_edition_date
  , fn_plural
) 
VALUES ( 
  @patId
  , NULLIF(''@fnPatId'', '''')
  , ''@treatDate''
  , CASE 
    WHEN EXTRACT(DOW FROM ''@treatDate'' ::TIMESTAMP) = ''0'' 
      THEN 7 
    ELSE EXTRACT(DOW FROM ''@treatDate'' ::TIMESTAMP) 
    END
  , ''@facilityCd''
  , NULLIF(''@facilityName'', '''')
  , CASE ''@indVaCd'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@indVaCd'', ''999999999'') 
    END
  , CASE ''@indTreatmentCd'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@indTreatmentCd'', ''999999999'') 
    END
  , NULL
  , CASE ''@indKurCd'' 
    WHEN '''' THEN 0 
    ELSE TO_NUMBER(''@indKurCd'', ''999999999999999999'') 
    END
  , NULL
  , NULLIF(''@indTreatStartTime'', '''')
  , TO_NUMBER((SELECT bed_cd FROM bed_used_check), ''999999999999999999'') 
  , NULL
  , CASE ''@indScheduleUserInfoFlg'' 
    WHEN '''' THEN json_build_object( 
      ''ind_user_id''
      , NULL
      , ''ind_user_last_name''
      , NULL
      , ''ind_user_first_name''
      , NULL
      , ''upd_user_id''
      , NULL
      , ''upd_user_last_name''
      , NULL
      , ''upd_user_first_name''
      , NULL
    ) 
    ELSE json_build_object( 
      ''ind_user_id''
      , CASE ''@userId'' 
        WHEN '''' THEN NULL 
        ELSE TO_NUMBER(''@userId'', ''999999999'') 
        END
      , ''ind_user_last_name''
      , NULLIF(''@userLastName'', '''')
      , ''ind_user_first_name''
      , NULLIF(''@userFirstName'', '''')
      , ''upd_user_id''
      , CASE ''@userId'' 
        WHEN '''' THEN NULL 
        ELSE TO_NUMBER(''@userId'', ''999999999'') 
        END
      , ''upd_user_last_name''
      , NULLIF(''@userLastName'', '''') 
      , ''upd_user_first_name''
      , NULLIF(''@userFirstName'', '''')
      , ''ind_kur_cd_before''
      , null
      , ''ind_treat_start_time_before''
      , null
    ) 
    END
  , ''@indCondInfoValue''
  , ''@indMediInfoValue''
  , CASE COALESCE((SELECT dialyzer_cd FROM dialyzer_info)::text,'''')
    WHEN '''' THEN ''@indEquipInfoValue'' 
    ELSE (''[{"cd":"''||(SELECT dialyzer_cd FROM dialyzer_info)::text||''", "name":"@indEquipInfo.name","unit":null,"amount":null,"class_cd":null,"class_name":null,"class_type":null,"equip_type":null,"short_name":null,"ind_user_id":null,"input_class":null,"is_editable":null,"needle_type":null,"upd_user_id":null,"cop_order_no":null,"ind_user_last_name":null,"upd_user_last_name":null,"ind_user_first_name":null,"upd_user_first_name":null}]'')::jsonb 
    END
  , ''@indIndCommentInfoValue''
  , CASE ''@indTareInfoFlg'' 
    WHEN '''' THEN json_build_object( 
      ''name_1''
      , NULL
      , ''name_2''
      , NULL
      , ''name_3''
      , NULL
      , ''name_4''
      , NULL
      , ''name_5''
      , NULL
      , ''weight_1''
      , NULL
      , ''weight_2''
      , NULL
      , ''weight_3''
      , NULL
      , ''weight_4''
      , NULL
      , ''weight_5''
      , NULL
    ) 
    ELSE json_build_object( 
      ''name_1''
      , NULLIF(''@indTareInfo.name1'', '''')
      , ''name_2''
      , NULLIF(''@indTareInfo.name2'', '''')
      , ''name_3''
      , NULLIF(''@indTareInfo.name3'', '''')
      , ''name_4''
      , NULLIF(''@indTareInfo.name4'', '''')
      , ''name_5''
      , NULLIF(''@indTareInfo.name5'', '''')
      , ''weight_1''
      , CASE ''@indTareInfo.weight1'' 
        WHEN '''' THEN 0 
        ELSE TO_NUMBER(''@indTareInfo.weight1'', ''999999999'') 
        END
      , ''weight_2''
      , CASE ''@indTareInfo.weight2'' 
        WHEN '''' THEN 0 
        ELSE TO_NUMBER(''@indTareInfo.weight2'', ''999999999'') 
        END
      , ''weight_3''
      , CASE ''@indTareInfo.weight2'' 
        WHEN '''' THEN 0 
        ELSE TO_NUMBER(''@indTareInfo.weight2'', ''999999999'') 
        END
      , ''weight_4''
      , CASE ''@indTareInfo.weight4'' 
        WHEN '''' THEN 0 
        ELSE TO_NUMBER(''@indTareInfo.weight4'', ''999999999'') 
        END
      , ''weight_5''
      , CASE ''@indTareInfo.weight5'' 
        WHEN '''' THEN 0 
        ELSE TO_NUMBER(''@indTareInfo.weight5'', ''999999999'') 
        END
    ) 
    END
  , CASE ''@indOffWaterInfoFlg'' 
    WHEN '''' THEN json_build_object( 
      ''name_1''
      , NULL
      , ''name_2''
      , NULL
      , ''name_3''
      , NULL
      , ''name_4''
      , NULL
      , ''name_5''
      , NULL
      , ''weight_1''
      , NULL
      , ''weight_2''
      , NULL
      , ''weight_3''
      , NULL
      , ''weight_4''
      , NULL
      , ''weight_5''
      , NULL
    ) 
    ELSE json_build_object( 
      ''name_1''
      , NULLIF(''@indOffWaterInfo.name1'', '''')
      , ''name_2''
      , NULLIF(''@indOffWaterInfo.name2'', '''')
      , ''name_3''
      , NULLIF(''@indOffWaterInfo.name3'', '''')
      , ''name_4''
      , NULLIF(''@indOffWaterInfo.name4'', '''')
      , ''name_5''
      , NULLIF(''@indOffWaterInfo.name5'', '''')
      , ''weight_1''
      , CASE ''@indOffWaterInfo.weight1'' 
        WHEN '''' THEN 0 
        ELSE TO_NUMBER(''@indOffWaterInfo.weight1'', ''999999999'') 
        END
      , ''weight_2''
      , CASE ''@indOffWaterInfo.weight2'' 
        WHEN '''' THEN 0 
        ELSE TO_NUMBER(''@indOffWaterInfo.weight2'', ''999999999'') 
        END
      , ''weight_3''
      , CASE ''@indOffWaterInfo.weight2'' 
        WHEN '''' THEN 0 
        ELSE TO_NUMBER(''@indOffWaterInfo.weight2'', ''999999999'') 
        END
      , ''weight_4''
      , CASE ''@indOffWaterInfo.weight4'' 
        WHEN '''' THEN 0 
        ELSE TO_NUMBER(''@indOffWaterInfo.weight4'', ''999999999'') 
        END
      , ''weight_5''
      , CASE ''@indOffWaterInfo.weight5'' 
        WHEN '''' THEN 0 
        ELSE TO_NUMBER(''@indOffWaterInfo.weight5'', ''999999999'') 
        END
    ) 
    END
  , NULLIF((SELECT device_set_info_ord FROM device_set_info_default), ''[]'') ::JSONB
  , NULL
  , NULL
  , 0
  , NULL
  , NULL
  , ''0''
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , ''0''
  , CURRENT_TIMESTAMP
  , CURRENT_TIMESTAMP
  , NULL
  , NULL
  , 1
  , 0
  , NULL
  , NULL
  , NULL
  , NULL
  , CASE ''@userId'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@userId'', ''999999999999999999'') 
    END
  , NULL
  , NULL
  , NULL
)', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのオーダ受け(INSERT)', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, '[{"sql_cd": -500011, "field_name": "ind_treatment_cd", "replace_var": "@indTreatmentCd"}, {"sql_cd": -500012, "field_name": "ind_bed_cd", "replace_var": "@indBedCd"}, {"sql_cd": -500031, "field_name": "user_id", "replace_var": "@userId"}, {"sql_cd": -500031, "field_name": "user_last_name", "replace_var": "@userLastName"}, {"sql_cd": -500031, "field_name": "user_first_name", "replace_var": "@userFirstName"}, {"sql_cd": -500039, "field_name": "ind_va_cd", "replace_var": "@indVaCd"}, {"sql_cd": -500082, "field_name": "kur_cd", "replace_var": "@indKurCd"}, {"sql_cd": -500083, "field_name": "ind_cond_info", "replace_var": "@indCondInfoValue"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(8101, 'SELECT
  ord_no,
  pat_id,
  fn_pat_id,
  treat_date,
  treat_week,
  facility_cd,
  facility_name,
  ind_va_cd,
  ind_treatment_cd,
  ind_treatment_name,
  ind_kur_cd,
  ind_kur_name,
  ind_treat_start_time,
  ind_bed_cd,
  ind_bed_name,
  ind_schedule_user_info,
  ind_cond_info,
  ind_medi_info,
  ind_equip_info,
  ind_ind_comment_info,
  ind_tare_info,
  ind_off_water_info,
  ind_device_set_info,
  rst_fn_dialysis_no,
  rst_relation_dialysis_no,
  rst_edition,
  rst_is_update_edition,
  rst_input_class,
  rst_dialysis_state,
  rst_treatment_cd,
  rst_treatment_name,
  rst_kur_cd,
  rst_kur_name,
  rst_bed_cd,
  rst_bed_name,
  rst_machine_no,
  rst_machine_name,
  rst_cond_send_date,
  rst_accept_date,
  rst_start_date,
  rst_end_date,
  rst_return_home_date,
  rst_in_out_class,
  rst_dialysis_cnt,
  rst_ward_cd,
  rst_ward_name,
  rst_course_cd,
  rst_course_name,
  rst_puncture_user_info,
  rst_return_user_info,
  rst_charge_user_info,
  rst_blood_circulate_total,
  rst_running_time,
  rst_kt_v,
  rec_set_date,
  send_ctl_no,
  blood_purifier_name,
  pull_leave_amount,
  rst_cond_info,
  rst_medi_info,
  rst_equip_info,
  rst_ind_comment_info,
  rst_tare_info,
  rst_off_water_info,
  rst_weight_info,
  rst_complaint_info,
  rst_treatment_info,
  rst_treat_staff_info,
  rst_rounds_info,
  is_del,
  up_date,
  reg_date,
  rst_dw,
  weight_scale_no,
  treat_type,
  is_confirm,
  ind_dw,
  rst_purification_cnt,
  addition_info,
  up_ind_user_id,
  up_user_id,
  rst_edition_date,
  cur_edition_date,
  fn_plural 
FROM
  ord_main 
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = @facilityCd 
  AND treat_date = @treatDate
LIMIT 1', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのオーダ受け(SELECT)', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-65, 'WITH staff_cd_info AS(
  --指示者
  --条件指示
  SELECT
    1 AS order_no
    , COALESCE(info ->> ''ind_user_id'', '''') AS staff_cd 
  FROM
    (SELECT
      ord.rst_cond_info -> jsonb_object_keys(ord.rst_cond_info) AS info 
    FROM
      ord_main AS ord 
    WHERE
      ord.ord_no = @ordNo AND 
      ord.facility_cd = @facilityCd AND 
      ord.is_del = ''0'' 
    LIMIT 1 ) AS T
  UNION 
  --投薬指示
  SELECT
    2 AS order_no
    , COALESCE(info ->> ''ind_user_id'', '''') AS staff_cd 
  FROM
    ord_main AS ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) info 
  WHERE
    ord.ord_no = @ordNo AND 
    ord.facility_cd = @facilityCd AND 
    ord.is_del = ''0'' 
  UNION 
  --医材指示
  SELECT
    3 AS order_no
    , COALESCE(info ->> ''ind_user_id'', '''') AS staff_cd
  FROM
    ord_main AS ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_equip_info ::json) info 
  WHERE
    ord.ord_no = @ordNo AND 
    ord.facility_cd = @facilityCd AND 
    ord.is_del = ''0'' 
  UNION 
  --指示簿指示
  SELECT
    4 AS order_no
    , COALESCE(info ->> ''ind_user_id'', '''') AS staff_cd
  FROM
    ord_main AS ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_ind_comment_info ::json) info 
  WHERE
    ord.ord_no = @ordNo AND 
    ord.facility_cd = @facilityCd AND 
    ord.is_del = ''0'' 
  ORDER BY order_no ASC LIMIT 1 
)
, rst_vital_info_before AS(
  --前血圧
  SELECT
    mni_m.monitor_data ->> ''90'' AS bp_max, 
    mni_m.monitor_data ->> ''91'' AS bp_min, 
    mni_m.monitor_data ->> ''92'' AS bp_ave, 
    mni_m.monitor_data ->> ''93'' AS pulse, 
    mni_m.occur_date AS occur_date
  FROM 
    ord_main ord
  INNER JOIN
    mni_monitor as mni_m
  ON
    ord.ord_no = mni_m.ord_no
  WHERE 
    ord.ord_no = @ordNo AND
    ord.facility_cd = @facilityCd AND 
    ord.is_del = ''0'' AND
    mni_m.data_type = 5 
)
, rst_vital_info_after AS(
  --後血圧
  SELECT
    mni_m.monitor_data ->> ''90'' AS bp_max, 
    mni_m.monitor_data ->> ''91'' AS bp_min, 
    mni_m.monitor_data ->> ''92'' AS bp_ave, 
    mni_m.monitor_data ->> ''93'' AS pulse, 
    mni_m.occur_date AS occur_date,
    mni_m.monitor_data ->> ''94'' AS temperature 
  FROM 
    ord_main ord
  INNER JOIN
    mni_monitor as mni_m
  ON
    ord.ord_no = mni_m.ord_no
  WHERE 
    ord.ord_no = @ordNo AND
    ord.facility_cd = @facilityCd AND 
    ord.is_del = ''0'' AND
    mni_m.data_type = 6
)
, ord_main_info AS (
  SELECT 
    ord.pat_id AS pat_id, 
    ord.treat_date AS treat_date, 
    ord.ind_treat_start_time AS ind_treat_start_time
  FROM 
    ord_main ord
  WHERE
    ord.ord_no = @ordNo AND 
    ord.facility_cd = @facilityCd AND 
    ord.is_del = ''0'' 
)
--前回後体重
, pre_weight_after_info AS (
  SELECT
    rst_weight_info ->> ''weight_after'' AS weight_after 
  FROM 
    ord_main
  WHERE 
    pat_id = (SELECT pat_id FROM ord_main_info) AND 
    rst_dialysis_state >= ''5'' AND 
    (cast(treat_date as date) ||'' ''|| cast(ind_treat_start_time as time))::TIMESTAMP < (cast((SELECT treat_date FROM ord_main_info) as date) ||'' ''|| cast((SELECT ind_treat_start_time FROM ord_main_info) as time))::TIMESTAMP AND 
    facility_cd = @facilityCd AND 
    is_del = ''0'' 
    ORDER BY (cast(treat_date as date) ||'' ''|| cast(ind_treat_start_time as time))::TIMESTAMP 
    LIMIT 1
)
, equipment_info AS (
  --医療材料
  SELECT
    COALESCE(meq.equipment_name, '''') || ''　'' || COALESCE((info ->> ''amount''), ''0'') || COALESCE((info ->> ''unit''), '''') AS equipment
  FROM 
    ord_main ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_equip_info ::json) info
  LEFT OUTER JOIN
    mst_equipment meq
  ON
    meq.equipment_cd = TO_NUMBER(info->>''cd'',''999999999999'')
  WHERE 
    ord.ord_no = @ordNo AND 
    ord.facility_cd = @facilityCd AND 
    ord.is_del = ''0'' 
)
, comment_info AS (
  --指示簿指示
  SELECT
    REPLACE(COALESCE((info ->> ''content''), ''''), E''\\\\n'', ''　'') AS comment
  FROM 
    ord_main ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_ind_comment_info ::json) info
  WHERE 
    ord.ord_no = @ordNo AND 
    ord.facility_cd = @facilityCd AND 
    ord.is_del = ''0''
  ORDER BY (info->>''no'')::int ASC 
)
, medi_info AS (
  --投与薬剤
  SELECT
    CASE info ->> ''effect_flg'' WHEN ''0'' THEN ''          '' WHEN ''1'' THEN TO_CHAR((info ->> ''effect_date'')::timestamptz, ''YYYY/MM/DD'') END || ''　'' || 
    COALESCE((CASE info ->> ''medicine_type'' WHEN ''2'' THEN mmx.medicine_mix_name ELSE mmd.medicine_name END), '''') || ''　'' || 
    COALESCE(info ->> ''amount'', ''0'') || COALESCE(info ->> ''unit'', '''') || ''　'' || COALESCE(mp.pricedure_name, '''') || ''　'' || 
    COALESCE(info ->> ''effect_user_first_name'', '''') || '' '' || COALESCE(info ->> ''effect_user_last_name'', '''') medi
  FROM 
    ord_main ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) info
  LEFT OUTER JOIN
    mst_medicine_mix mmx
  ON
    mmx.medicine_mix_cd = TO_NUMBER(info ->> ''cd'',''999999999999'')
  LEFT OUTER JOIN
    mst_medicine mmd
  ON
    mmd.medicine_cd = TO_NUMBER(info ->> ''cd'',''999999999999'')
  LEFT OUTER JOIN
    mst_procedure mp
  ON
    mp.procedure_cd = TO_NUMBER(info ->> ''procedure_cd'',''999999999999'')
  WHERE 
    ord.ord_no = @ordNo AND 
    ord.facility_cd = @facilityCd AND 
    ord.is_del = ''0''
  ORDER BY
	info ->> ''effect_flg'' ASC,
  	info ->> ''effect_date'' ASC,
  	info ->> ''cd'' ASC 
)
, complaint_info AS (
  --愁訴情報
  SELECT
    ROW_NUMBER () OVER () AS row,
    TO_CHAR((info ->> ''occur_date'') :: TIMESTAMP, ''YYYY/MM/DD HH24:MI'') || ''　'' || COALESCE((info ->> ''complaint''), '''') AS complaint
  FROM 
    ord_main ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_complaint_info ::json) info
  WHERE 
    ord.ord_no = @ordNo AND 
    ord.facility_cd = @facilityCd AND 
    ord.is_del = ''0''
  ORDER BY 
   	(info ->> ''occur_date'') :: TIMESTAMP ASC,
   	info ->> ''ctl_no'' ASC
)
, treatment_info AS (
  --愁訴処置情報
  SELECT
    ROW_NUMBER () OVER () AS row,
    COALESCE((info ->> ''treat_name''), '''') || ''　'' || COALESCE((info ->> ''treat_medicine_name''), '''') || ''　'' || 
    COALESCE((info ->> ''amount''), '''') || COALESCE((info ->> ''unit''), '''') || ''　'' || 
    COALESCE((info ->> ''procedure_name''), '''') AS treatment 
  FROM 
    ord_main ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) info
  WHERE 
    ord.ord_no = @ordNo AND 
    ord.facility_cd = @facilityCd AND 
    ord.is_del = ''0''
  ORDER BY 
   	(info ->> ''occur_date'') :: TIMESTAMP ASC,
   	info ->> ''ctl_no'' ASC 
)
, treat_staff_info AS (
  --愁訴処置者情報
  SELECT
    ROW_NUMBER () OVER () AS row,
    COALESCE((info ->> ''treat_staff_name''), '''') AS treat_staff_name
  FROM 
    ord_main ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_treat_staff_info ::json) info
  WHERE 
    ord.ord_no = @ordNo AND 
    ord.facility_cd = @facilityCd AND 
    ord.is_del = ''0'' 
)
, rounds_info AS (
  --観察記録
  SELECT
    TO_TIMESTAMP(
      pat_e.event_start_date :: text || pat_e.event_start_time :: text,
      ''YYYYMMDDHH24MI''
    ) AS datetime,
    pat_e.sub_category_name,
    STRING_AGG(
      CASE pat_e.sub_category_name
        WHEN ''SOAP'' THEN  
          COALESCE((input.params ->> ''field_name''), '''') || '':'' || REPLACE(COALESCE((result.params ->> ''result_value''), ''''), E''\\\\n'', ''　'')
        ELSE
          REPLACE(COALESCE((result.params ->> ''result_value''), ''''), E''\\\\n'', ''　'')
      END,
      E''　''
    ) AS content,
    pat_e.up_staff_info ->> ''up_staff_name'' AS name
  FROM
    ord_main ord
    INNER JOIN pat_event pat_e
    CROSS JOIN LATERAL json_array_elements(pat_e.result_params :: json) WITH ORDINALITY AS result(params, ord)
    CROSS JOIN LATERAL json_array_elements(pat_e.input_params :: json) WITH ORDINALITY AS input(params, ord)
      ON ord.ord_no = pat_e.ord_no
    	AND pat_e.is_del = ''0''
        AND result.ord = input.ord
  WHERE
    ord.ord_no = @ordNo AND 
    ord.facility_cd = @facilityCd AND 
    ord.is_del = ''0''
  GROUP BY
    pat_e.pat_event_cd
  ORDER BY
    datetime
)
SELECT
  Tmp.values AS values
FROM
(
SELECT 
  split_part(cond_arr.cond_row,''-@-'',1) :: INTEGER AS order_no, 
  split_part(cond_arr.cond_row,''-@-'',2) || 
  split_part(cond_arr.cond_row,''-@-'',3) || 
  CASE WHEN split_part(cond_arr.cond_row,''-@-'',3) IS NULL OR split_part(cond_arr.cond_row,''-@-'',3) = ''''
    THEN ''''
    ELSE  split_part(cond_arr.cond_row,''-@-'',4)
  END || E''\\\\n'' AS values
FROM 
  (SELECT
    regexp_split_to_table(array_to_string(array[
    concat(''1-@-表示用患者ID:-@-'', (@hospPatId) :: TEXT), 
    concat(''2-@-患者名:-@-'', (@patName) :: TEXT), 
    concat(''3-@-指示者:-@-'', (SELECT staff_cd FROM staff_cd_info)),
    concat(''4-@-透析日:-@-'', 
    COALESCE(SUBSTRING(ord.treat_date, 1, 4) || ''年'' ||
       SUBSTRING(ord.treat_date, 5, 2) || ''月'' || 
       SUBSTRING(ord.treat_date, 7, 2) || ''日'', '''') || 
      ''('' ||
      CASE extract(DOW FROM cast(ord.treat_date as TIMESTAMP))
        WHEN 0 THEN ''日曜日''
        WHEN 1 THEN ''月曜日''
        WHEN 2 THEN ''火曜日''
        WHEN 3 THEN ''水曜日''
        WHEN 4 THEN ''木曜日''
        WHEN 5 THEN ''金曜日''
        WHEN 6 THEN ''土曜日''
        ELSE '''' 
      END || '')''
    ),
    concat(''5-@-予定透析時間:-@-'', ord.rst_cond_info -> ''1'' ->> ''value'', ''-@-分''),
    concat(''6-@-予定透析時間:-@-'', RIGHT(''00'' || TRUNC(TO_NUMBER(ord.rst_cond_info -> ''1'' ->> ''value'', ''9999'')/60, 0), 2) || '':'' ||
          RIGHT(''00'' || MOD(TO_NUMBER(ord.rst_cond_info -> ''1'' ->> ''value'', ''9999''), 60), 2)),
    concat(''7-@-入外区分:-@-'', CASE ord.rst_in_out_class WHEN ''0'' THEN ''1'' WHEN ''1'' THEN ''3'' ELSE ''1'' END),
    concat(''8-@-透析回数:-@-'', ord.rst_dialysis_cnt, ''-@-回''),
    concat(''9-@-透析時間:-@-'', RIGHT(''00'' || TRUNC(COALESCE(ord.rst_running_time, ''0'')/60, 0), 2) || '':'' ||
          RIGHT(''00'' || MOD(COALESCE(ord.rst_running_time, ''0''), 60), 2)),
    concat(''10-@-透析開始時刻:-@-'', TO_CHAR(ord.rst_start_date, ''YYYY/MM/DD HH24:MI'')),
    concat(''11-@-透析終了時刻:-@-'', TO_CHAR(ord.rst_end_date, ''YYYY/MM/DD HH24:MI'')),
    concat(''12-@-クール:-@-'', COALESCE(ord.rst_kur_name, '''')),
    concat(''13-@-ベッド:-@-'', COALESCE(ord.rst_bed_name, '''')),
    concat(''14-@-病棟名:-@-'', COALESCE(ord.rst_ward_name, '''')),
    concat(''15-@-診療科:-@-'', COALESCE(ord.rst_course_name, '''')),
    concat(''16-@-担当者１:-@-'', COALESCE(ord.rst_charge_user_info ->> ''user_last_name_1'', '''') || ''　'' || COALESCE(ord.rst_charge_user_info ->> ''user_first_name_1'', '''')),
    concat(''17-@-担当者２:-@-'', COALESCE(ord.rst_charge_user_info ->> ''user_last_name_2'', '''') || ''　'' || COALESCE(ord.rst_charge_user_info ->> ''user_first_name_2'', '''')),
    concat(''18-@-穿刺者１:-@-'', COALESCE(ord.rst_puncture_user_info ->> ''user_last_name_1'', '''') || ''　'' || COALESCE(ord.rst_puncture_user_info ->> ''user_first_name_1'', '''')),
    concat(''19-@-穿刺時刻１:-@-'', TO_CHAR((ord.rst_puncture_user_info ->> ''date'') :: TIMESTAMP, ''YYYY/MM/DD HH24:MI'')),
    concat(''20-@-穿刺者２:-@-'', COALESCE(ord.rst_puncture_user_info ->> ''user_last_name_2'', '''') || ''　'' || COALESCE(ord.rst_puncture_user_info ->> ''user_first_name_2'', '''')),
    concat(''21-@-穿刺時刻２:-@-'', TO_CHAR((ord.rst_puncture_user_info ->> ''date_2'') :: TIMESTAMP, ''YYYY/MM/DD HH24:MI'')),
    concat(''22-@-回収者１:-@-'', COALESCE(ord.rst_return_user_info ->> ''user_last_name_1'', '''') || ''　'' || COALESCE(ord.rst_return_user_info ->> ''user_first_name_1'', '''')),
    concat(''23-@-回収時刻１:-@-'', TO_CHAR((ord.rst_return_user_info ->> ''date_1'') :: TIMESTAMP, ''YYYY/MM/DD HH24:MI'')),
    concat(''24-@-回収者２:-@-'', COALESCE(ord.rst_return_user_info ->> ''user_last_name_2'', '''') || ''　'' || COALESCE(ord.rst_return_user_info ->> ''user_first_name_2'', '''')),
    concat(''25-@-回収時刻２:-@-'', TO_CHAR((ord.rst_return_user_info ->> ''date_2'') :: TIMESTAMP, ''YYYY/MM/DD HH24:MI'')),
    concat(''26-@-前回後体重:-@-'', (SELECT weight_after FROM pre_weight_after_info), ''-@-kg''),
    concat(''27-@-透析前体重:-@-'', ord.rst_weight_info ->> ''weight_before'', ''-@-kg''),
    concat(''28-@-透析前体重測定日時:-@-'', TO_CHAR((ord.rst_weight_info ->> ''weight_before_date'') :: TIMESTAMP, ''YYYY/MM/DD HH24:MI'')),
    concat(''29-@-ＣＴＲ:-@-'', ord.rst_weight_info ->> ''ctr'', ''-@-%''),
    concat(''30-@-ＣＴＲ測定時体重:-@-'', ord.rst_weight_info ->> ''ctr_weight'', ''-@-kg''),
    concat(''31-@-ＣＴＲ測定日:-@-'', TO_CHAR((ord.rst_weight_info ->> ''ctr_measure_date'') :: DATE, ''YYYY/MM/DD'')),
    concat(''32-@-目標体重:-@-'', ord.rst_cond_info -> ''3'' ->> ''value'', ''-@-kg''),
    concat(''33-@-目標除水量:-@-'', ord.rst_weight_info ->> ''water_removal_target'', ''-@-L''),
    concat(''34-@-除水実績:-@-'', ord.rst_weight_info ->> ''water_removal_rst'', ''-@-L''),
    concat(''35-@-Ｋｔ／Ｖ測定値:-@-'', COALESCE(ord.rst_weight_info ->> ''kt_v_measure'', '''')),
    concat(''36-@-ＵＲＲ:-@-'', ord.rst_weight_info ->> ''urr'', ''-@-%''),
    concat(''37-@-再循環率:-@-'', ord.rst_weight_info ->> ''recrcl_rt'', ''-@-%''),
    concat(''38-@-透析後体重:-@-'', ord.rst_weight_info ->> ''weight_after'', ''-@-kg''),
    concat(''39-@-透析後体重測定日時:-@-'', TO_CHAR((ord.rst_weight_info ->> ''weight_after_date'') :: DATE, ''YYYY/MM/DD'')),
    concat(''40-@-減少量:-@-'', TO_NUMBER(ord.rst_weight_info ->> ''weight_before'', ''999999999D9'') - TO_NUMBER(ord.rst_weight_info ->> ''weight_after'', ''999999999D9''), ''-@-kg''),
    concat(''41-@-前血圧(最高):-@-'', COALESCE((SELECT bp_max FROM rst_vital_info_before), '''')),
    concat(''42-@-前血圧(最低):-@-'', COALESCE((SELECT bp_min FROM rst_vital_info_before), '''')),
    concat(''43-@-前血圧(平均):-@-'', COALESCE((SELECT bp_ave FROM rst_vital_info_before), '''')),
    concat(''44-@-前脈拍:-@-'', COALESCE((SELECT pulse FROM rst_vital_info_before), '''')),
    concat(''45-@-前血圧測定日時:-@-'', TO_CHAR((SELECT occur_date FROM rst_vital_info_before) :: TIMESTAMP, ''YYYY/MM/DD HH24:MI'')),
    concat(''46-@-後血圧(最高):-@-'', COALESCE((SELECT bp_max FROM rst_vital_info_after), '''')),
    concat(''47-@-後血圧(最低):-@-'', COALESCE((SELECT bp_min FROM rst_vital_info_after), '''')),
    concat(''48-@-後血圧(平均):-@-'', COALESCE((SELECT bp_ave FROM rst_vital_info_after), '''')),
    concat(''49-@-後脈拍:-@-'', COALESCE((SELECT pulse FROM rst_vital_info_after), '''')),
    concat(''50-@-後血圧測定日時:-@-'', TO_CHAR((SELECT occur_date FROM rst_vital_info_after) :: TIMESTAMP, ''YYYY/MM/DD HH24:MI'')),
    concat(''51-@-体温:-@-'', (SELECT temperature FROM rst_vital_info_after), ''-@-℃''),
    concat(''52-@-透析条件：-@-'', (SELECT temperature FROM rst_vital_info_after), ''-@-℃''),
    concat(''53-@-透析開始時刻:-@-'', SUBSTRING(ord.ind_treat_start_time,1,2) || '':'' || SUBSTRING(ord.ind_treat_start_time,3,2)), 
    concat(''54-@-透析予定時間:-@-'', ord.rst_cond_info -> ''1'' ->> ''value'', ''-@-分''), 
    concat(''55-@-透析予定時間:-@-'', RIGHT(''00'' || TRUNC(TO_NUMBER(ord.rst_cond_info -> ''1'' ->> ''value'', ''9999'')/60, 0), 2) || '':'' ||
           RIGHT(''00'' || MOD(TO_NUMBER(ord.rst_cond_info -> ''1'' ->> ''value'', ''9999''), 60), 2), ''-@-mL/min''),
    concat(''56-@-VA:-@-'', COALESCE(mva.va_name, '''')),
    concat(''57-@-目標体重:-@-'', ord.rst_cond_info -> ''3'' ->> ''value'', ''-@-kg''),
    concat(''58-@-治療方法:-@-'', COALESCE(mtt.treatment_name , '''')),
    concat(''59-@-除水量制限:-@-'', ord.rst_cond_info -> ''4'' ->> ''value'', ''-@-L''),
    concat(''60-@-ダイアライザ:-@-'', COALESCE(mdz.model_number, '''')),
    concat(''61-@-吸着カラム:-@-'', COALESCE(meq.equipment_name, '''')),
    concat(''62-@-血流量:-@-'', ord.rst_cond_info -> ''14'' ->> ''value'', ''-@-mL/min''),
    concat(''63-@-抗凝固剤:-@-'', COALESCE(mmd25.medicine_name, '''')),
    concat(''64-@-抗凝固剤ワンショット量:-@-'', ord.rst_cond_info -> ''26'' ->> ''value'' || COALESCE((CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx25.unit ELSE mmd25.unit END), '''')),
    concat(''65-@-抗凝固剤持続速度:-@-'', ord.rst_cond_info -> ''27'' ->> ''value'' || COALESCE((CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx25.unit ELSE mmd25.unit END), ''''), ''-@-/h''),
    concat(''66-@-抗凝固剤持続総量:-@-'', ord.rst_cond_info -> ''28'' ->> ''value'' || COALESCE((CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx25.unit ELSE mmd25.unit END), '''')),
    concat(''67-@-IP使用選択:-@-'', CASE ord.rst_cond_info -> ''29'' ->> ''value'' WHEN ''0'' THEN ''使用しない'' WHEN ''1'' THEN ''使用する'' ELSE '''' END),
    concat(''68-@-IPワンショット量:-@-'', ord.rst_cond_info -> ''31'' ->> ''value'', ''-@-mL''),
    concat(''69-@-IP速度:-@-'', ord.rst_cond_info -> ''32'' ->> ''value'', ''-@-mL/h''),
    concat(''70-@-透析液:-@-'', COALESCE(mmd15.medicine_name, '''')),
    concat(''71-@-透析液流量:-@-'', ord.rst_cond_info -> ''16'' ->> ''value'', ''-@-mL/min''),
    concat(''72-@-透析液量:-@-'', COALESCE((ord.rst_cond_info -> ''17'' ->> ''value'') || (ord.rst_cond_info -> ''17'' ->> ''unit''), '''')),
    concat(''73-@-透析液温度:-@-'', ord.rst_cond_info -> ''18'' ->> ''value'', ''-@-℃''),
    concat(''74-@-補液:-@-'', COALESCE(mmd19.medicine_name, '''')),
    concat(''75-@-補液量:-@-'', ord.rst_cond_info -> ''20'' ->> ''value'', ''-@-L''),
    concat(''76-@-補液選択:-@-'', CASE ord.rst_cond_info -> ''21'' ->> ''value'' WHEN ''0'' THEN ''後補液'' WHEN ''1'' THEN ''前補液'' ELSE '''' END),
    concat(''77-@-補液温度:-@-'', ord.rst_cond_info -> ''23'' ->> ''value'', ''-@-℃''),
    concat(''78-@-シングルニードル使用:-@-'', CASE ord.rst_cond_info -> ''12'' ->> ''value'' WHEN ''0'' THEN ''無し'' WHEN ''1'' THEN ''有り'' ELSE '''' END),
    concat(''79-@-補液使用数:-@-'', COALESCE((ord.rst_cond_info -> ''22'' ->> ''value'') || (ord.rst_cond_info -> ''22'' ->> ''unit''), '''')),
    concat(''80-@-IPスタート:-@-'', CASE ord.rst_cond_info -> ''30'' ->> ''value'' WHEN ''0'' THEN ''手動'' WHEN ''1'' THEN ''自動'' ELSE '''' END),
    concat(''81-@-自動ワンショット:-@-'', CASE ord.rst_cond_info -> ''34'' ->> ''value'' WHEN ''0'' THEN ''使用しない'' WHEN ''1'' THEN ''使用する'' ELSE '''' END),
    concat(''82-@-IP電源自動切り:-@-'', CASE ord.rst_cond_info -> ''35'' ->> ''value'' WHEN ''0'' THEN ''切'' WHEN ''1'' THEN ''入'' ELSE '''' END),
    concat(''83-@-IP電源自動切り時間:-@-'', COALESCE(ord.rst_cond_info -> ''36'' ->> ''value'', '''')),
    concat(''84-@-IP電源OKモニタ切り:-@-'', CASE ord.rst_cond_info -> ''37'' ->> ''value'' WHEN ''0'' THEN ''切'' WHEN ''1'' THEN ''入'' ELSE '''' END),
    concat(''85-@-IP電源OKモニタ切り時間:-@-'', COALESCE(ord.rst_cond_info -> ''38'' ->> ''value'', '''')),
    concat(''86-@-IP速度最大値:-@-'', ord.rst_cond_info -> ''33'' ->> ''value'', ''-@-mL/h''),
    concat(''87-@-IP補液速度:-@-'', ord.rst_cond_info -> ''24'' ->> ''value'', ''-@-L/h''),
    concat(''88-@-1次膜:-@-'', COALESCE(meq1.equipment_name, '''')),
    concat(''89-@-2次膜:-@-'', COALESCE(meq2.equipment_name, ''''))
    ],''-@@-''),''-@@-'') AS cond_row
  FROM
    ord_main ord 
  LEFT OUTER JOIN
    mst_va mva
  ON
    mva.va_cd = TO_NUMBER(ord.rst_cond_info -> ''2'' ->> ''value'', ''999999999999'')
  LEFT OUTER JOIN
    mst_dialyzer mdz
  ON
    mdz.dialyzer_cd = TO_NUMBER(ord.rst_cond_info -> ''5'' ->> ''value'', ''999999999999'')
  LEFT OUTER JOIN
    mst_equipment meq
  ON
    meq.equipment_cd = TO_NUMBER(ord.rst_cond_info -> ''6'' ->> ''value'', ''999999999999'')
  LEFT OUTER JOIN
    mst_equipment meq1
  ON
    meq1.equipment_cd = TO_NUMBER(ord.rst_cond_info -> ''7'' ->> ''value'', ''999999999999'')
  LEFT OUTER JOIN
    mst_equipment meq2
  ON
    meq2.equipment_cd = TO_NUMBER(ord.rst_cond_info -> ''8'' ->> ''value'', ''999999999999'')
  LEFT OUTER JOIN
    mst_medicine mmd15
  ON
    mmd15.medicine_cd = TO_NUMBER(ord.rst_cond_info -> ''15'' ->> ''value'', ''999999999999'')
  LEFT OUTER JOIN
    mst_medicine mmd19
  ON
    mmd19.medicine_cd = TO_NUMBER(ord.rst_cond_info -> ''19'' ->> ''value'', ''999999999999'')
  LEFT OUTER JOIN
    mst_medicine mmd17
  ON
    mmd17.medicine_cd = TO_NUMBER(ord.rst_cond_info -> ''17'' ->> ''value'', ''999999999999'')
  LEFT OUTER JOIN
    mst_medicine_mix mmx17
  ON
    mmx17.medicine_mix_cd = TO_NUMBER(ord.rst_cond_info -> ''17'' ->> ''value'', ''999999999999'')
  LEFT OUTER JOIN
    mst_medicine mmd22
  ON
    mmd22.medicine_cd = TO_NUMBER(ord.rst_cond_info -> ''22'' ->> ''value'', ''999999999999'')
  LEFT OUTER JOIN
    mst_medicine_mix mmx22
  ON
    mmx22.medicine_mix_cd = TO_NUMBER(ord.rst_cond_info -> ''22'' ->> ''value'', ''999999999999'')
  LEFT OUTER JOIN
    mst_medicine mmd25
  ON
    mmd25.medicine_cd = TO_NUMBER(ord.rst_cond_info -> ''25'' ->> ''value'', ''999999999999'')
  LEFT OUTER JOIN
    mst_medicine mmd26
  ON
    mmd26.medicine_cd = TO_NUMBER(ord.rst_cond_info -> ''26'' ->> ''value'', ''999999999999'')
  LEFT OUTER JOIN
    mst_medicine_mix mmx25
  ON
    mmx25.medicine_mix_cd = TO_NUMBER(ord.rst_cond_info -> ''25'' ->> ''value'', ''999999999999'')
  LEFT OUTER JOIN
    mst_medicine mmd27
  ON
    mmd27.medicine_cd = TO_NUMBER(ord.rst_cond_info -> ''27'' ->> ''value'', ''999999999999'')
  LEFT OUTER JOIN
    mst_medicine_mix mmx27
  ON
    mmx27.medicine_mix_cd = TO_NUMBER(ord.rst_cond_info -> ''27'' ->> ''value'', ''999999999999'')
  LEFT OUTER JOIN
    mst_medicine mmd28
  ON
    mmd28.medicine_cd = TO_NUMBER(ord.rst_cond_info -> ''28'' ->> ''value'', ''999999999999'')
  LEFT OUTER JOIN
    mst_medicine_mix mmx28
  ON
    mmx28.medicine_mix_cd = TO_NUMBER(ord.rst_cond_info -> ''28'' ->> ''value'', ''999999999999'')
  LEFT OUTER JOIN
    mst_treatment mtt
  ON
    mtt.treatment_cd = ord.ind_treatment_cd
  WHERE
    ord.ord_no = @ordNo AND 
    ord.facility_cd = @facilityCd AND 
    ord.is_del = ''0'' 
) cond_arr
--医療材料
UNION 
(SELECT 
  99 AS order_no, 
  ''医療材料：'' || E''\\\\n'' AS values)
UNION
(SELECT 
  100 AS order_no, 
  equipment || E''\\\\n'' AS values
FROM 
  equipment_info)
--指示簿指示
UNION
(SELECT 
  101 AS order_no, 
  ''指示簿指示：'' || E''\\\\n'' AS values)
UNION
(SELECT 
  102 AS order_no, 
  STRING_AGG(comment_info.comment, E''\\\\n'')|| E''\\\\n'' AS values
FROM 
  comment_info)
--投与薬剤
UNION
(SELECT 
  103 AS order_no, 
  ''投与薬剤：'' || E''\\\\n'' AS values)
UNION
(SELECT 
  104 AS order_no, 
  STRING_AGG(medi, E''\\\\n'')|| E''\\\\n'' AS values
FROM 
  medi_info)
--愁訴処置
UNION
(SELECT 
  105 AS order_no, 
  ''愁訴処置：'' || E''\\\\n'' AS values) 
UNION
(SELECT
  106 AS order_no,
  STRING_AGG(
    complaint_info.complaint || ''　'' || treatment_info.treatment || ''　'' || treat_staff_info.treat_staff_name,
    E''\\\\n''
  ) || E''\\\\n'' AS
values
FROM
  complaint_info
  LEFT JOIN treatment_info ON complaint_info.row = treatment_info.row
  LEFT JOIN treat_staff_info ON complaint_info.row = treat_staff_info.row)
--観察記録
UNION
(SELECT 
  107 AS order_no,
  ''観察記録：'' || E''\\\\n'' AS values)
UNION
(SELECT
  108 AS order_no, 
  STRING_AGG(
    TO_CHAR(rounds_info.datetime :: TIMESTAMP, ''YYYY/MM/DD HH24:MI'') || ''　'' || 
      COALESCE(rounds_info.sub_category_name, '''') || ''　'' || 
      rounds_info.content || ''　'' || 
      rounds_info.name,
    E''\\\\n''
  ) || E''\\\\n'' AS values
FROM rounds_info)
ORDER BY order_no ASC
) Tmp', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'SSI）カルテ記載連携：内容取得', '2023-05-18 19:22:02.414', CURRENT_TIMESTAMP, '[{"sql_cd": -1, "field_name": "hosp_pat_id", "replace_var": "@hospPatId"}, {"sql_cd": -1, "field_name": "pat_name", "replace_var": "@patName"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-301, 'WITH ord_main_max AS (
  (
    SELECT
      ord.ord_no,
      ord.del_date AS up_date,
      ord.rst_medi_info,
      ord.rst_treatment_info
    FROM
      ord_main_restore AS ord,
      sys_coop_journal AS journal
    WHERE
      ord.ord_no = @ordNo
      AND journal.ctl_no = @ctlNo
      AND ord.ord_no = journal.ord_no
      AND journal.reg_date >= ord.del_date
    ORDER BY
      del_date DESC
    LIMIT
      1
  )
  UNION
    (
      SELECT
        ord.ord_no,
        ord.rst_edition_date AS up_date,
        ord.rst_medi_info,
        ord.rst_treatment_info
      FROM
        ord_main AS ord
      WHERE
        ord.ord_no = @ordNo
    )
  ORDER BY
    up_date DESC NULLS LAST
  LIMIT
    1
), oxygen_inhalation AS (
  SELECT
    COALESCE(
      NULLIF(info ->> ''value'', ''''),
      info ->> ''default_v''
    ) AS value,
    info ->> ''key2'' AS key2
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = @key0
    AND info ->> ''key1'' = ''SSI_DIALYSIS_SEND''
    AND (
      info ->> ''key2'' = ''OXYGEN_ACTION_CD''
      OR info ->> ''key2'' = ''OXYGEN_INHALATION''
    )
),
grouping_dispose_activity AS (
  SELECT
    COALESCE(
      NULLIF(info ->> ''value'', ''''),
      info ->> ''default_v''
    ) AS value
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = @key0
    AND info ->> ''key1'' = ''SSI_DIALYSIS_SEND''
    AND info ->> ''key2'' = ''GROUPING_DISPOSE_ACTIVITY''
),
action_medi_information_normal AS (
  --投与薬剤情報(通常)
  SELECT
    ''処置行為'' AS detail_id,
    mmd.in_hospital_cd_2 AS e01,
    mmd.medicine_name AS e02,
    ''1'' AS e03,
    NULL AS e04,
    1 AS table_no,
    medi.idx AS row_no
  FROM
    ord_main_max AS ord
    CROSS JOIN lateral json_array_elements (ord.rst_medi_info :: json) WITH ORDINALITY AS medi(val, idx)
    LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER (medi.val ->> ''cd'', ''999999999999'')
  WHERE
    medi.val ->> ''effect_flg'' = ''1''
    AND medi.val ->> ''medicine_type'' = ''1''
    AND COALESCE(mmd.in_hospital_cd_2, ''ZERO'') <> ''ZERO''
    AND ord.ord_no = @ordNo
),
material_medi_information_normal AS (
  --投与薬剤情報(通常)
  SELECT
    ''処置材料'' AS detail_id,
    mmd.in_hospital_cd_1 AS e01,
    mmd.medicine_name AS e02,
    TRIM(
      to_char(
        to_number(medi.val ->> ''amount'', ''99999.99''),
        ''99990.99''
      )
    ) AS e03,
    COALESCE(mmd.unit_second, mmd.unit) AS e04,
    2 AS table_no,
    medi.idx AS row_no
  FROM
    ord_main_max AS ord
    CROSS JOIN lateral json_array_elements (ord.rst_medi_info :: json) WITH ORDINALITY AS medi(val, idx)
    LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER (medi.val ->> ''cd'', ''999999999999'')
  WHERE
    medi.val ->> ''effect_flg'' = ''1''
    AND medi.val ->> ''medicine_type'' = ''1''
    AND COALESCE(mmd.in_hospital_cd_1, ''ZERO'') <> ''ZERO''
    AND COALESCE(mmd.in_hospital_cd_2, ''ZERO'') <> ''ZERO''
    AND ord.ord_no = @ordNo
),
action_medi_information_adjusted AS (
  --投与薬剤情報(調製)
  SELECT
    ''処置行為'' AS detail_id,
    mmx.in_hospital_cd_2 AS e01,
    mmx.medicine_mix_name AS e02,
    ''1'' AS e03,
    NULL AS e04,
    4 AS table_no,
    medi.idx AS row_no
  FROM
    ord_main_max AS ord
    CROSS JOIN lateral json_array_elements (ord.rst_medi_info :: json) WITH ORDINALITY AS medi(val, idx)
    LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER (medi.val ->> ''cd'', ''999999999999'')
  WHERE
    medi.val ->> ''effect_flg'' = ''1''
    AND medi.val ->> ''medicine_type'' = ''2''
    AND COALESCE(mmx.in_hospital_cd_2, ''ZERO'') <> ''ZERO''
    AND ord.ord_no = @ordNo
),
material_medi_information_adjusted AS (
  SELECT
    --投与薬剤情報(調製)
    ''処置材料'' AS detail_id,
    mmd.in_hospital_cd_1 AS e01,
    mmd.medicine_name AS e02,
    TRIM(
      to_char(
        sum(
          to_number(
            (
              case
                mmxd.val ->> ''solvent''
                WHEN ''1'' THEN to_char(
                  to_number(mmxd.val ->> ''amount'', ''99999.99''),
                  ''99999.99''
                )
                ELSE to_char(
                  to_number(medi.val ->> ''amount'', ''99999.99'') * to_number(COALESCE(mmxd.val ->> ''amount'', ''0''), ''99999.99''),
                  ''99999.99''
                )
              end
            ),
            ''99999.99''
          )
        ),
        ''9990.99''
      )
    ) AS e03,
    COALESCE(mmd.unit_second, mmd.unit) AS e04,
    5 AS table_no,
    medi.idx AS row_no
  FROM
    ord_main_max AS ord
    CROSS JOIN lateral json_array_elements (ord.rst_medi_info :: json) WITH ORDINALITY AS medi(val, idx)
    LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER (medi.val ->> ''cd'', ''999999999999'')
    CROSS JOIN lateral json_array_elements (mmx.mix_info :: json) WITH ORDINALITY AS mmxd(val, idx)
    LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER (mmxd.val ->> ''cd'', ''999999999999'')
  WHERE
    medi.val ->> ''effect_flg'' = ''1''
    AND medi.val ->> ''medicine_type'' = ''2''
    AND COALESCE(mmd.in_hospital_cd_1, ''ZERO'') <> ''ZERO''
    AND COALESCE(mmx.in_hospital_cd_2, ''ZERO'') <> ''ZERO''
    AND ord.ord_no = @ordNo
  GROUP BY
    detail_id,
    e01,
    e02,
    e04,
    table_no,
    mmxd.idx,
    medi.idx
  ORDER BY
    row_no,
    mmxd.idx
),
action_treatment_medi_info AS (
  --処置薬剤情報
  SELECT
    ''処置行為'' AS detail_id,
    mmd.in_hospital_cd_2 AS e01,
    mmd.medicine_name AS e02,
    ''1'' AS e03,
    NULL AS e04,
    7 AS table_no,
    tmedi.idx AS row_no
  FROM
    ord_main_max AS ord
    CROSS JOIN lateral json_array_elements (ord.rst_treatment_info :: json) WITH ORDINALITY AS tmedi(val, idx)
    LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER (
      tmedi.val ->> ''treat_medicine_cd'',
      ''999999999999''
    )
  WHERE
    ord.ord_no = @ordNo
    AND COALESCE(mmd.in_hospital_cd_2, ''ZERO'') <> ''ZERO''
),
material_treatment_medi_info AS (
  --処置薬剤情報
  SELECT
    ''処置材料'' AS detail_id,
    mmd.in_hospital_cd_1 AS e01,
    mmd.medicine_name AS e02,
    TRIM(
      to_char(
        to_number(tmedi.val ->> ''amount'', ''99990.99''),
        ''99990.99''
      )
    ) AS e03,
    COALESCE(mmd.unit_second, mmd.unit) AS e04,
    8 AS table_no,
    tmedi.idx AS row_no
  FROM
    ord_main_max AS ord
    CROSS JOIN lateral json_array_elements (ord.rst_treatment_info :: json) WITH ORDINALITY AS tmedi(val, idx)
    LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER (
      tmedi.val ->> ''treat_medicine_cd'',
      ''999999999999''
    )
  WHERE
    ord.ord_no = @ordNo
    AND COALESCE(mmd.in_hospital_cd_2, ''ZERO'') <> ''ZERO''
    AND COALESCE(mmd.in_hospital_cd_1, ''ZERO'') <> ''ZERO''
),
action_treatment_medi_mix_info AS (
  --愁訴処置情報
  SELECT
    ''処置行為'' AS detail_id,
    mmx.in_hospital_cd_2 AS e01,
    mmx.medicine_mix_name AS e02,
    ''1'' AS e03,
    NULL AS e04,
    10 AS table_no,
    tmedi.idx AS row_no
  FROM
    ord_main_max AS ord
    CROSS JOIN lateral json_array_elements (ord.rst_treatment_info :: json) WITH ORDINALITY AS tmedi(val, idx)
    LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER (
      tmedi.val ->> ''treat_medicine_cd'',
      ''999999999999''
    )
  WHERE
    ord.ord_no = @ordNo
    AND COALESCE(mmx.in_hospital_cd_2, ''ZERO'') <> ''ZERO''
),
material_treatment_medi_mix_info AS (
  --愁訴処置情報
  SELECT
    ''処置材料'' AS detail_id,
    mmd.in_hospital_cd_1 AS e01,
    mmd.medicine_name AS e02,
    TRIM(
      to_char(
        sum(
          to_number(
            (
              case
                mmxd.val ->> ''solvent''
                WHEN ''1'' THEN to_char(
                  to_number(mmxd.val ->> ''amount'', ''99999.99''),
                  ''99999.99''
                )
                ELSE to_char(
                  to_number(tmedi.val ->> ''amount'', ''99999.99'') * to_number(COALESCE(mmxd.val ->> ''amount'', ''0''), ''99999.99''),
                  ''99999.99''
                )
              end
            ),
            ''99999.99''
          )
        ),
        ''9990.99''
      )
    ) AS e03,
    COALESCE(mmd.unit_second, mmd.unit) AS e04,
    11 AS table_no,
    tmedi.idx AS row_no
  FROM
    ord_main_max AS ord
    CROSS JOIN lateral json_array_elements (ord.rst_treatment_info :: json) WITH ORDINALITY AS tmedi(val, idx)
    LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER (
      tmedi.val ->> ''treat_medicine_cd'',
      ''999999999999''
    )
    CROSS JOIN lateral json_array_elements (mmx.mix_info :: json) WITH ORDINALITY AS mmxd(val, idx)
    LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER (mmxd.val ->> ''cd'', ''999999999999'')
  WHERE
    tmedi.val ->> ''medicine_type'' = ''2''
    AND COALESCE(mmd.in_hospital_cd_1, ''ZERO'') <> ''ZERO''
    AND COALESCE(mmx.in_hospital_cd_2, ''ZERO'') <> ''ZERO''
    AND ord.ord_no = @ordNo
  GROUP BY
    detail_id,
    e01,
    e02,
    e04,
    table_no,
    mmxd.idx,
    tmedi.idx
  ORDER BY
    row_no,
    mmxd.idx
),
agg_actions_materuals_all AS (
  SELECT
    a_detail_id,
    a_e01,
    MODE() WITHIN GROUP (
      ORDER BY
        a_e02
    ) AS a_e02,
    a_e03,
    a_e04,
    min(a_table_no) AS a_table_no,
    min(a_row_no) AS a_row_no,
    m_detail_id,
    m_e01,
    m_e02,
    SUM(m_e03) AS m_e03,
    m_e04,
    min(m_table_no) AS m_table_no,
    min(m_row_no) AS m_row_no
  FROM
    (
      (
        SELECT
          a.detail_id AS a_detail_id,
          a.e01 AS a_e01,
          a.e02 AS a_e02,
          a.e03 AS a_e03,
          a.e04 AS a_e04,
          a.table_no AS a_table_no,
          a.row_no AS a_row_no,
          m.detail_id AS m_detail_id,
          m.e01 AS m_e01,
          m.e02 AS m_e02,
          to_number(m.e03, ''99999.99'') AS m_e03,
          m.e04 AS m_e04,
          m.table_no AS m_table_no,
          m.row_no AS m_row_no
        FROM
          action_medi_information_normal a
          LEFT JOIN material_medi_information_normal m ON a.row_no = m.row_no
        ORDER BY
          a.row_no,
          m.row_no
      )
      UNION ALL
        (
          SELECT
            a.detail_id AS a_detail_id,
            a.e01 AS a_e01,
            a.e02 AS a_e02,
            a.e03 AS a_e03,
            a.e04 AS a_e04,
            a.table_no AS a_table_no,
            a.row_no AS a_row_no,
            m.detail_id AS m_detail_id,
            m.e01 AS m_e01,
            m.e02 AS m_e02,
            to_number(m.e03, ''99999.99'') AS m_e03,
            m.e04 AS m_e04,
            m.table_no AS m_table_no,
            m.row_no AS m_row_no
          FROM
            action_medi_information_adjusted a
            LEFT JOIN material_medi_information_adjusted m ON a.row_no = m.row_no
          ORDER BY
            a.row_no,
            m.row_no
        )
      UNION ALL
        (
          SELECT
            a.detail_id AS a_detail_id,
            a.e01 AS a_e01,
            a.e02 AS a_e02,
            a.e03 AS a_e03,
            a.e04 AS a_e04,
            a.table_no AS a_table_no,
            a.row_no AS a_row_no,
            m.detail_id AS m_detail_id,
            m.e01 AS m_e01,
            m.e02 AS m_e02,
            to_number(m.e03, ''99999.99'') AS m_e03,
            m.e04 AS m_e04,
            m.table_no AS m_table_no,
            m.row_no AS m_row_no
          FROM
            action_treatment_medi_info a
            LEFT JOIN material_treatment_medi_info m ON a.row_no = m.row_no
          ORDER BY
            a.row_no,
            m.row_no
        )
      UNION ALL
        (
          SELECT
            a.detail_id AS a_detail_id,
            a.e01 AS a_e01,
            a.e02 AS a_e02,
            a.e03 AS a_e03,
            a.e04 AS a_e04,
            a.table_no AS a_table_no,
            a.row_no AS a_row_no,
            m.detail_id AS m_detail_id,
            m.e01 AS m_e01,
            m.e02 AS m_e02,
            to_number(m.e03, ''99999.99'') AS m_e03,
            m.e04 AS m_e04,
            m.table_no AS m_table_no,
            m.row_no AS m_row_no
          FROM
            action_treatment_medi_mix_info a
            LEFT JOIN material_treatment_medi_mix_info m ON a.row_no = m.row_no
          ORDER BY
            a.row_no,
            m.row_no
        )
    ) AS action_material
  GROUP BY
    a_detail_id,
    a_e01,
    a_e03,
    a_e04,
    m_detail_id,
    m_e01,
    m_e02,
    m_e04
  ORDER BY
    a_row_no,
    m_row_no
),
actions_all_min_row_no AS (
  SELECT
    a_e01 AS e01,
    MIN(a_row_no) AS min_row_no
  FROM
    agg_actions_materuals_all
  GROUP BY
    a_e01
),
actions_all AS (
  SELECT
    detail_id,
    e01,
    e02,
    e03,
    e04,
    table_no,
    table_no * 100 + row_no AS row_no
  FROM(
      SELECT
        *
      FROM
        action_medi_information_normal
      UNION ALL
      SELECT
        *
      FROM
        action_medi_information_adjusted
      UNION ALL
      SELECT
        *
      FROM
        action_treatment_medi_info
      UNION ALL
      SELECT
        *
      FROM
        action_treatment_medi_mix_info
    ) AS actions
  ORDER BY
    table_no,
    row_no
),
agg_actions_all AS (
  SELECT
    t.a_detail_id AS detail_id,
    t.a_e01 AS e01,
    t.a_e02 AS e02,
    t.a_e03 AS e03,
    t.a_e04 AS e04,
    t.a_table_no AS table_no,
    t.a_row_no AS row_no
  FROM
    (
      SELECT
        a_detail_id,
        a_e01,
        a_e02,
        a_e03,
        a_e04,
        a_table_no,
        a_row_no
      FROM
        agg_actions_materuals_all
      GROUP BY
        a_detail_id,
        a_e01,
        a_e02,
        a_e03,
        a_e04,
        a_table_no,
        a_row_no
    ) t
    JOIN actions_all_min_row_no m ON t.a_e01 = m.e01
    AND t.a_row_no = m.min_row_no
  ORDER BY
    t.a_row_no
),
materials_all AS (
  SELECT
    detail_id,
    e01,
    e02,
    e03,
    e04,
    table_no,
    (table_no - 1) * 100 + row_no AS row_no
  FROM(
      SELECT
        *
      FROM
        material_medi_information_normal
      UNION ALL
      SELECT
        *
      FROM
        material_medi_information_adjusted
      UNION ALL
      SELECT
        *
      FROM
        material_treatment_medi_info
      UNION ALL
      SELECT
        *
      FROM
        material_treatment_medi_mix_info
    ) AS materials
  ORDER BY
    table_no,
    row_no
),
agg_materials_all AS (
  SELECT
    agg_a_m.m_detail_id AS detail_id,
    agg_a_m.m_e01 AS e01,
    agg_a_m.m_e02 AS e02,
    TRIM(to_char(agg_a_m.m_e03, ''99990.99'')) AS e03,
    agg_a_m.m_e04 AS e04,
    agg_a_m.m_table_no AS table_no,
    agg_a.row_no AS row_no
  FROM
    agg_actions_all agg_a
    RIGHT JOIN agg_actions_materuals_all agg_a_m ON agg_a.e01 = agg_a_m.a_e01
  WHERE
    agg_a_m.m_detail_id IS NOT NULL
  ORDER BY
    agg_a.row_no,
    agg_a_m.m_row_no
),
delimiter_actions AS (
  SELECT
    ''区切り'' AS detail_id,
    ''000000'' AS e01,
    ''区切り'' AS e02,
    ''1'' AS e03,
    NULL AS e04,
    12 AS table_no,
    row_no -1 AS row_no
  FROM
    (
      SELECT
        *,
        ''0'' AS grouping_type
      FROM
        actions_all
      UNION ALL
      SELECT
        *,
        ''1'' AS grouping_type
      FROM
        agg_actions_all
    ) AS act
  WHERE
    act.grouping_type = (
      SELECT
        value
      FROM
        grouping_dispose_activity
      LIMIT
        1
    )
  ORDER BY
    row_no OFFSET 1
),
actions_materials_all AS (
  SELECT
    detail_id,
    e01,
    e02,
    e03,
    e04,
    ''01'' || to_char(row_no, ''-0000'') || to_char(table_no, ''-0000'') AS row_id
  FROM
    (
      SELECT
        detail_id,
        e01,
        e02,
        e03,
        e04,
        table_no,
        row_no
      FROM
        (
          SELECT
            *,
            ''0'' AS grouping_type
          FROM
            actions_all
          UNION ALL
          SELECT
            *,
            ''1'' AS grouping_type
          FROM
            agg_actions_all
        ) AS act
      WHERE
        act.grouping_type = (
          SELECT
            value
          FROM
            grouping_dispose_activity
          LIMIT
            1
        )
      UNION ALL
      SELECT
        detail_id,
        e01,
        e02,
        e03,
        e04,
        table_no,
        row_no
      FROM
        (
          SELECT
            *,
            ''0'' AS grouping_type
          FROM
            materials_all
          UNION ALL
          SELECT
            *,
            ''1'' AS grouping_type
          FROM
            agg_materials_all
        ) AS mat
      WHERE
        mat.grouping_type = (
          SELECT
            value
          FROM
            grouping_dispose_activity
          LIMIT
            1
        )
      UNION ALL
      SELECT
        *
      FROM
        delimiter_actions
    ) AS medi_information_normal_all
  ORDER BY
    row_no,
    table_no
),
oxygen_technique AS (
  --　酸素手技
  SELECT
    ''酸素手技'' AS detail_id,
    (
      SELECT
        value
      FROM
        oxygen_inhalation
      WHERE
        key2 = ''OXYGEN_ACTION_CD''
      LIMIT
        1
    ) AS e01,
    ''酸素吸入'' AS e02,
    ''1'' AS e03,
    NULL AS e04,
    13 AS table_no,
    oxy.idx AS row_no
  FROM
    ord_main_max AS ord
    CROSS JOIN lateral json_array_elements (ord.rst_treatment_info :: json) WITH ORDINALITY AS oxy(val, idx)
  WHERE
    COALESCE(oxy.val ->> ''oxygen_amount'', ''end'') = ''end''
    AND oxy.val ->> ''treat_class'' = ''3''
    AND ord.ord_no = @ordNo
    AND EXISTS (
      SELECT
        value
      FROM
        oxygen_inhalation
      WHERE
        key2 = ''OXYGEN_INHALATION''
        AND value IS NOT NULL
        AND value != ''''
      LIMIT
        1
    )
), oxygen_volume AS (
  --　酸素吸入量
  SELECT
    ''酸素吸入量'' AS detail_id,
    (
      SELECT
        value
      FROM
        oxygen_inhalation
      WHERE
        key2 = ''OXYGEN_INHALATION''
      LIMIT
        1
    ) AS e01,
    ''酸素吸入'' AS e02,
    TRIM(
      to_char(
        to_number(oxy.val ->> ''oxygen_amount'', ''999999.99''),
        ''999990.99''
      )
    ) AS e03,
    ''L'' AS e04,
    14 AS table_no,
    oxy.idx AS row_no
  FROM
    ord_main_max AS ord
    CROSS JOIN lateral json_array_elements (ord.rst_treatment_info :: json) WITH ORDINALITY AS oxy(val, idx)
  WHERE
    COALESCE(oxy.val ->> ''oxygen_amount'', ''end'') <> ''end''
    AND oxy.val ->> ''treat_class'' = ''3''
    AND ord.ord_no = @ordNo
    AND EXISTS (
      SELECT
        value
      FROM
        oxygen_inhalation
      WHERE
        key2 = ''OXYGEN_INHALATION''
        AND value IS NOT NULL
        AND value != ''''
      LIMIT
        1
    )
), delimiter_oxygen AS (
  -- 酸素情報_区切り
  SELECT
    ''区切り'' AS detail_id,
    ''000000'' AS e01,
    ''区切り'' AS e02,
    ''1'' AS e03,
    NULL AS e04,
    15 AS table_no,
    row_no -1 AS row_no
  FROM
    oxygen_technique
  ORDER BY
    row_no OFFSET 1
),
oxygen_info AS (
  -- 酸素手技、酸素吸入量、区切りを連結
  SELECT
    detail_id,
    e01,
    e02,
    e03,
    e04,
    ''05'' || to_char(row_no, ''-0000'') || to_char(table_no, ''-0000'') AS row_id
  FROM
    (
      SELECT
        *
      FROM
        oxygen_technique
      UNION ALL
      SELECT
        *
      FROM
        oxygen_volume
      UNION ALL
      SELECT
        *
      FROM
        delimiter_oxygen
    ) AS oxygen_all
  ORDER BY
    row_no,
    table_no
),
delimiter_all AS (
  SELECT
    ''区切り'' AS detail_id,
    ''000000'' AS e01,
    ''区切り'' AS e02,
    ''1'' AS e03,
    NULL AS e04
),
union_all_tables AS (
  SELECT
    *
  FROM
    actions_materials_all
  UNION ALL
  SELECT
    *,
    ''04'' || to_char(
      (
        SELECT
          count(row_id) + 1
        FROM
          actions_materials_all
      ),
      ''-0000''
    ) AS row_id
  FROM
    delimiter_all
  WHERE
    EXISTS (
      SELECT
        1
      FROM
        actions_materials_all
    )
  UNION ALL
    -- 酸素情報
  SELECT
    *
  FROM
    oxygen_info
),
with_cost_no AS (
  SELECT
    *,
    ROW_NUMBER() OVER(
      ORDER BY
        row_id
    ) AS cost_no
  FROM
    union_all_tables
  ORDER BY
    row_id
),
total AS (
  SELECT
    COUNT(*) AS total_rows
  FROM
    with_cost_no
),
last_divider AS (
  SELECT
    MAX(cost_no) AS max_row
  FROM
    with_cost_no
  WHERE
    e02 = ''区切り''
) -- 最後の行が区切りの場合は除外する
SELECT
  *
FROM
  with_cost_no
WHERE
  cost_no != (
    CASE
      WHEN (
        SELECT
          total_rows
        FROM
          total
      ) = (
        SELECT
          max_row
        FROM
          last_divider
      ) THEN (
        SELECT
          max_row
        FROM
          last_divider
      )
      ELSE 0
    end
  )', 2, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'SSI)実績処置繰り返し部', '2020-05-20 19:57:15.246', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-99987, 'SELECT
  ''Karte_'' || 
  TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDDHH24MISS_'') ||
  CASE WHEN LENGTH(TO_CHAR(journal.ord_no, ''FM9999999999999999999'')) >= 12 THEN TO_CHAR(journal.ord_no, ''FM9999999999999999999'') ELSE LPAD(TO_CHAR(journal.ord_no, ''FM9999999999999999999''), 12, ''0'') END ||
  ''.xml'' AS filename
FROM
  sys_coop_journal AS journal 
WHERE
  journal.ctl_no = @ctlNo', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'SSI カルテ記載連携[送信]ファイル名取得', '2021-04-20 09:19:08.001', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500011, 'WITH ssi_order_treat_info AS ( 
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
) 
select
	treatment_cd as ind_treatment_cd
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
  ))', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの治療方法(SELECT)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500012, 'WITH 
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
) 
select
	bed_cd as ind_bed_cd
from
	mst_bed
where
	is_del = ''0''
	and is_disp = ''1''
	and facility_cd = @facilityCd
	and bed_name = @indBedName
	and CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN in_hospital_cd_1 = @indBedCd AND COALESCE(in_hospital_cd_1,'''') <> ''''
        WHEN ''2'' THEN in_hospital_cd_2 = @indBedCd AND COALESCE(in_hospital_cd_2,'''') <> ''''
      END
union all
select
    0 as ind_bed_cd
where not exists (
    select 1
    from mst_bed
    where
is_del = ''0''
and is_disp = ''1''
and facility_cd = @facilityCd
and bed_name = @indBedName
and CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN in_hospital_cd_1 = @indBedCd AND COALESCE(in_hospital_cd_1,'''') <> ''''
        WHEN ''2'' THEN in_hospital_cd_2 = @indBedCd AND COALESCE(in_hospital_cd_2,'''') <> ''''
      END
  
  limit 1
)', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのベッド(SELECT)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500013, 'WITH ssi_in_hospital_cd AS ( 
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

select
  dialyzer_cd AS cd
from
  mst_dialyzer
where
  is_del = ''0''
  and is_disp = ''1''
  and CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN in_hospital_cd_1 = @indCondInfo.005.value AND COALESCE(in_hospital_cd_1,'''') <> ''''
        WHEN ''2'' THEN in_hospital_cd_2 = @indCondInfo.005.value AND COALESCE(in_hospital_cd_2,'''') <> ''''
        WHEN ''3'' THEN in_hospital_cd_3 = @indCondInfo.005.value AND COALESCE(in_hospital_cd_3,'''') <> ''''
        WHEN ''4'' THEN in_hospital_cd_4 = @indCondInfo.005.value AND COALESCE(in_hospital_cd_4,'''') <> ''''
      END
  and facility_cd = @facilityCd
  AND (SELECT is_membrane FROM is_membrane) = 0
  UNION
select
  equipment_cd AS cd
from
  mst_equipment
where
  is_del = ''0''
  and is_disp = ''1''
  and CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN in_hospital_cd_1 = @indCondInfo.005.value AND COALESCE(in_hospital_cd_1,'''') <> ''''
        WHEN ''2'' THEN in_hospital_cd_2 = @indCondInfo.005.value AND COALESCE(in_hospital_cd_2,'''') <> ''''
        WHEN ''3'' THEN in_hospital_cd_3 = @indCondInfo.005.value AND COALESCE(in_hospital_cd_3,'''') <> ''''
        WHEN ''4'' THEN in_hospital_cd_4 = @indCondInfo.005.value AND COALESCE(in_hospital_cd_4,'''') <> ''''
      END
  and facility_cd = @facilityCd
  AND (SELECT is_membrane FROM is_membrane) = 1', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのダイアライザ(SELECT)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500015, 'WITH ssi_in_hospital_cd AS ( 
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
select
	equipment_cd
from
	mst_equipment
where
	is_del = ''0''
	and is_disp = ''1''
	and CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN in_hospital_cd_1 = @indCondInfo.010.value AND COALESCE(in_hospital_cd_1,'''') <> ''''
        WHEN ''2'' THEN in_hospital_cd_2 = @indCondInfo.010.value AND COALESCE(in_hospital_cd_2,'''') <> ''''
        WHEN ''3'' THEN in_hospital_cd_3 = @indCondInfo.010.value AND COALESCE(in_hospital_cd_3,'''') <> ''''
        WHEN ''4'' THEN in_hospital_cd_4 = @indCondInfo.010.value AND COALESCE(in_hospital_cd_4,'''') <> ''''
      END
	and facility_cd = @facilityCd', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの治療材料(SELECT)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500016, 'WITH ssi_in_hospital_cd AS ( 
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
    AND info->>''key2'' = ''A_NEEDLE'' -- A針''
) 
, class_cd_info AS (
  SELECT
    class_cd AS class_cd
  FROM mst_equipment_class
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
        WHEN (@indCondInfo.010.value='''') 
        THEN 0 
        ELSE 1 
    END AS is_new
)
INSERT INTO mst_equipment( 
      facility_cd
  ,   fn_equipment_cd
  ,   standard_equipment_cd
  ,   is_trial
  ,   equipment_name
  ,   equipment_short_name
  ,   class_cd
  ,   unit
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
  ,   NULL
  ,   @indCondInfo.010.name
  ,   NULL
  ,   (SELECT class_cd FROM class_cd_info)
  ,   NULL
  ,   NULL
  ,   NULL
  ,   CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN @indCondInfo.010.value
        WHEN ''2'' THEN NULL
        WHEN ''3'' THEN NULL
      END
  ,   CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN NULL
        WHEN ''2'' THEN @indCondInfo.010.value
        WHEN ''3'' THEN NULL
      END
  ,   CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN NULL
        WHEN ''2'' THEN NULL
        WHEN ''3'' THEN @indCondInfo.010.value
      END
  ,   ''1''
  ,   ''0''
  ,   CURRENT_TIMESTAMP
  ,   CURRENT_TIMESTAMP
  ,   NULL
FROM is_new
WHERE is_new = 1', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの医療材料(INSERT)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500017, 'WITH ssi_in_hospital_cd AS ( 
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
select
	medicine_cd
from
	mst_medicine
where
	is_del = ''0''
	and is_disp = ''1''
	and CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN in_hospital_cd_1 = @indCondInfo.015.value AND COALESCE(in_hospital_cd_1,'''') <> ''''
        WHEN ''2'' THEN in_hospital_cd_2 = @indCondInfo.015.value AND COALESCE(in_hospital_cd_2,'''') <> ''''
        WHEN ''3'' THEN in_hospital_cd_3 = @indCondInfo.015.value AND COALESCE(in_hospital_cd_3,'''') <> ''''
        WHEN ''4'' THEN in_hospital_cd_4 = @indCondInfo.015.value AND COALESCE(in_hospital_cd_4,'''') <> ''''
      END
	and facility_cd = @facilityCd', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの薬剤(SELECT)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
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
  ,   @indCondInfo.015.unit
  ,   NULL
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
WHERE is_new = 1', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの薬剤(INSERT)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500019, 'WITH  ssi_in_hospital_cd AS ( 
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
select
	equipment_cd
from
	mst_equipment
where
	is_del = ''0''
	and is_disp = ''1''
	and CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN in_hospital_cd_1 = @indEquipInfo.cd AND COALESCE(in_hospital_cd_1,'''') <> ''''
        WHEN ''2'' THEN in_hospital_cd_2 = @indEquipInfo.cd AND COALESCE(in_hospital_cd_2,'''') <> ''''
        WHEN ''3'' THEN in_hospital_cd_3 = @indEquipInfo.cd AND COALESCE(in_hospital_cd_3,'''') <> ''''
        WHEN ''4'' THEN in_hospital_cd_4 = @indEquipInfo.cd AND COALESCE(in_hospital_cd_4,'''') <> ''''
      END
	and facility_cd = @facilityCd', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの治療材料(SELECT)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500020, 'WITH ssi_in_hospital_cd AS ( 
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
    AND info->>''key2'' = (''EQUIPMENT_'' || @indEquipInfo.no)  -- 医療材料''
) 
, class_cd_info AS (
  SELECT
    class_cd AS class_cd
  FROM mst_equipment_class
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
        WHEN (@indEquipInfo.cd='''') 
        THEN 0 
        ELSE 1 
    END AS is_new
)
INSERT INTO mst_equipment( 
      facility_cd
  ,   fn_equipment_cd
  ,   standard_equipment_cd
  ,   is_trial
  ,   equipment_name
  ,   equipment_short_name
  ,   class_cd
  ,   unit
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
  ,   NULL
  ,   @indEquipInfo.name
  ,   NULL
  ,   (SELECT class_cd FROM class_cd_info)
  ,   NULL
  ,   NULL
  ,   NULL
  ,   CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN @indEquipInfo.cd
        WHEN ''2'' THEN NULL
        WHEN ''3'' THEN NULL
        WHEN ''4'' THEN NULL
      END
  ,   CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN NULL
        WHEN ''2'' THEN @indEquipInfo.cd
        WHEN ''3'' THEN NULL
        WHEN ''4'' THEN NULL
      END
  ,   CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN NULL
        WHEN ''2'' THEN NULL
        WHEN ''3'' THEN @indEquipInfo.cd
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
        WHEN ''4'' THEN @indEquipInfo.cd
      END
FROM is_new
WHERE is_new = 1', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの医療材料(INSERT)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500023, 'WITH ssi_in_hospital_cd AS ( 
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
select
	procedure_cd
from
	mst_procedure
where
	is_del = ''0''
	and is_disp = ''1''
	and CASE (SELECT VALUE FROM ssi_in_hospital_cd)
			WHEN ''1'' THEN in_hospital_cd_a1 = @indMediInfo.procedureCd AND COALESCE(in_hospital_cd_a1,'''') <> ''''
			WHEN ''2'' THEN in_hospital_cd_a2 = @indMediInfo.procedureCd AND COALESCE(in_hospital_cd_a2,'''') <> ''''
		END
	and facility_cd = @facilityCd', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの手技(SELECT)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500024, 'WITH ssi_in_hospital_cd AS ( 
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
, is_new AS (
  SELECT 
    CASE 
        WHEN (@indMediInfo.procedureCd='''') 
        THEN 0 
        ELSE 1 
    END AS is_new
)
INSERT INTO mst_procedure( 
      facility_cd
  ,   fn_procedure_cd
  ,   pricedure_name
  ,   is_disp
  ,   is_del
  ,   reg_date
  ,   up_date
  ,   in_hosp_a_startdate
  ,   in_hospital_cd_a1
  ,   in_hospital_cd_a2
  ,   in_hosp_b_startdate
  ,   in_hospital_cd_b1
  ,   in_hospital_cd_b2
) 
SELECT
      @facilityCd
  ,   NULL
  ,   @indMediInfo.procedureName
  ,   ''1''
  ,   ''0''
  ,   CURRENT_TIMESTAMP
  ,   CURRENT_TIMESTAMP
  ,   CURRENT_TIMESTAMP
  ,   CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN @indMediInfo.procedureCd
        WHEN ''2'' THEN NULL
      END
  ,   CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN NULL
        WHEN ''2'' THEN @indMediInfo.procedureCd
      END
  ,   NULL
  ,   NULL
  ,   NULL
FROM is_new
WHERE is_new = 1', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの手技(INSERT)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500025, 'WITH ssi_in_hospital_cd AS ( 
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
select
  equipment_cd
from
  mst_equipment
where
  is_del = ''0''
  and is_disp = ''1''
  and CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN in_hospital_cd_1 = @indEquipInfo.cd AND COALESCE(in_hospital_cd_1,'''') <> ''''
        WHEN ''2'' THEN in_hospital_cd_2 = @indEquipInfo.cd AND COALESCE(in_hospital_cd_2,'''') <> ''''
        WHEN ''3'' THEN in_hospital_cd_3 = @indEquipInfo.cd AND COALESCE(in_hospital_cd_3,'''') <> ''''
        WHEN ''4'' THEN in_hospital_cd_4 = @indEquipInfo.cd AND COALESCE(in_hospital_cd_4,'''') <> ''''
      END
  and facility_cd = @facilityCd', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの2次膜', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
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
  ;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのダイアライザ(INSERT)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -500060}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500027, 'WITH ssi_in_hospital_cd AS ( 
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
select
	equipment_cd
from
	mst_equipment
where
	is_del = ''0''
	and is_disp = ''1''
	and CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN in_hospital_cd_1 = @indCondInfo.006.value AND COALESCE(in_hospital_cd_1,'''') <> ''''
        WHEN ''2'' THEN in_hospital_cd_2 = @indCondInfo.006.value AND COALESCE(in_hospital_cd_2,'''') <> ''''
        WHEN ''3'' THEN in_hospital_cd_3 = @indCondInfo.006.value AND COALESCE(in_hospital_cd_3,'''') <> ''''
        WHEN ''4'' THEN in_hospital_cd_4 = @indCondInfo.006.value AND COALESCE(in_hospital_cd_4,'''') <> ''''
      END
	and facility_cd = @facilityCd', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの治療材料(SELECT)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500028, 'WITH ssi_in_hospital_cd AS ( 
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
    AND info->>''key2'' = ''ADHESION'' -- 吸着器''
) 
, class_cd_info AS (
  SELECT
    class_cd AS class_cd
  FROM mst_equipment_class
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
        WHEN (@indCondInfo.006.value='''') 
        THEN 0 
        ELSE 1 
    END AS is_new
)
INSERT INTO mst_equipment( 
      facility_cd
  ,   fn_equipment_cd
  ,   standard_equipment_cd
  ,   is_trial
  ,   equipment_name
  ,   equipment_short_name
  ,   class_cd
  ,   unit
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
  ,   NULL
  ,   @indCondInfo.006.name
  ,   NULL
  ,   (SELECT class_cd FROM class_cd_info)
  ,   NULL
  ,   NULL
  ,   NULL
  ,   CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN @indCondInfo.006.value
        WHEN ''2'' THEN NULL
        WHEN ''3'' THEN NULL
        WHEN ''4'' THEN NULL
      END
  ,   CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN NULL
        WHEN ''2'' THEN @indCondInfo.006.value
        WHEN ''3'' THEN NULL
        WHEN ''4'' THEN NULL
      END
  ,   CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN NULL
        WHEN ''2'' THEN NULL
        WHEN ''3'' THEN @indCondInfo.006.value
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
        WHEN ''4'' THEN @indCondInfo.006.value
      END
FROM is_new
WHERE is_new = 1', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの医療材料(INSERT)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500029, 'WITH ssi_in_hospital_cd AS ( 
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
select
	medicine_cd
from
	mst_medicine
where
	is_del = ''0''
	and is_disp = ''1''
	and CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN in_hospital_cd_1 = @indCondInfo.019.value AND COALESCE(in_hospital_cd_1,'''') <> ''''
        WHEN ''2'' THEN in_hospital_cd_2 = @indCondInfo.019.value AND COALESCE(in_hospital_cd_2,'''') <> ''''
        WHEN ''3'' THEN in_hospital_cd_3 = @indCondInfo.019.value AND COALESCE(in_hospital_cd_3,'''') <> ''''
        WHEN ''4'' THEN in_hospital_cd_4 = @indCondInfo.019.value AND COALESCE(in_hospital_cd_4,'''') <> ''''
      END
	and facility_cd = @facilityCd', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの薬剤(SELECT)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500030, 'WITH ssi_in_hospital_cd AS ( 
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
    AND info->>''key2'' = ''LIQUID'' -- 補液''
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
        WHEN (@indCondInfo.019.value='''') 
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
  ,   @indCondInfo.019.name
  ,   NULL
  ,   NULL
  ,   NULL
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
        WHEN ''1'' THEN @indCondInfo.019.value
        WHEN ''2'' THEN NULL
        WHEN ''3'' THEN NULL
        WHEN ''4'' THEN NULL
      END
  ,   CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN NULL
        WHEN ''2'' THEN @indCondInfo.019.value
        WHEN ''3'' THEN NULL
        WHEN ''4'' THEN NULL
      END
  ,   CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN NULL
        WHEN ''2'' THEN NULL
        WHEN ''3'' THEN @indCondInfo.019.value
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
        WHEN ''4'' THEN @indCondInfo.019.value
      END
FROM is_new
WHERE is_new = 1', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの薬剤(INSERT)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500031, 'select 
  coalesce ( 
    (select
      user_id
    from
      mst_personal_user
    WHERE
        facility_cd = @facilityCd
        AND user_id = @userId
        and is_del = ''0''
        and is_disp = ''1'')
  ,-1) AS user_id,
  coalesce ( 
    (select
      COALESCE(personal_info_decrypt(user_last_name), '''') AS user_last_name
    from
      mst_personal_user
    WHERE
        facility_cd = @facilityCd
        AND user_id = @userId
        and is_del = ''0''
        and is_disp = ''1'')
  ,'''') AS user_last_name,
  coalesce ( 
    (select
      COALESCE(personal_info_decrypt(user_first_name), '''') AS user_first_name
    from
      mst_personal_user
    WHERE
        facility_cd = @facilityCd
        AND user_id = @userId
        and is_del = ''0''
        and is_disp = ''1'')
  ,'''') AS user_first_name', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのスタッフマスタ(SELECT)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -500086, "field_name": "user_id", "replace_var": "@userId"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500032, 'SELECT
  ord_no
FROM
  ord_schedule 
WHERE
  ord_no = @ordNo
  AND facility_cd = @facilityCd ', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのオーダ受け(SELECT)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500033, 'WITH bed_used_check AS (
SELECT CASE WHEN EXISTS (
  SELECT
    1
  FROM
    ord_main
  WHERE
    facility_cd = ''@facilityCd''
    AND treat_date = ''@treatDate''
    AND ind_kur_cd::text = ''@indKurCd''
    AND ind_kur_cd <> 0
    AND ind_bed_cd::text = ''@indBedCd''
    AND ord_no <> @ordNo
    AND is_del = ''0''
    )
    THEN ''0''
    ELSE ''@indBedCd''
    END AS bed_cd
  )
INSERT INTO ord_schedule( 
    facility_cd
    , ord_no
    , treat_date
    , kur_cd
    , bed_cd
    , pat_id
    , is_dummy
    , up_date
    , treat_week
    , reg_date
) 
VALUES (
      ''@facilityCd''
    , ''@ordNo''
    , ''@treatDate''
    , TO_NUMBER(''@indKurCd'', ''999999999999999999'')
    , TO_NUMBER((SELECT bed_cd FROM bed_used_check), ''999999999999999999'')
    ,   @patId
    , ''0''
    , CURRENT_TIMESTAMP
    , CASE 
        WHEN EXTRACT(DOW FROM ''@treatDate'' ::TIMESTAMP) = ''0'' 
        THEN 7 
        ELSE EXTRACT(DOW FROM ''@treatDate'' ::TIMESTAMP) 
      END
    , CURRENT_TIMESTAMP
)', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのオーダ受けord_schedule(INSERT)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -500012, "field_name": "ind_bed_cd", "replace_var": "@indBedCd"}, {"sql_cd": -500082, "field_name": "kur_cd", "replace_var": "@indKurCd"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500034, 'WITH bed_used_check AS (
SELECT CASE WHEN EXISTS (
  SELECT
    1
  FROM
    ord_main
  WHERE
    facility_cd = ''@facilityCd''
    AND treat_date = ''@treatDate''
    AND ind_kur_cd::text = ''@indKurCd''
    AND ind_kur_cd <> 0
    AND ind_bed_cd::text = ''@indBedCd''
    AND ord_no <> @ordNo
    AND is_del = ''0''
    )
    THEN ''0''
    ELSE ''@indBedCd''
    END AS bed_cd
  )
UPDATE ord_schedule 
SET
    kur_cd = TO_NUMBER(''@indKurCd'', ''999999999999999999'')
  ,  bed_cd = TO_NUMBER((SELECT bed_cd FROM bed_used_check), ''999999999999999999'')
  , up_date = CURRENT_TIMESTAMP 
WHERE
  ord_no = @ordNo
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのオーダ受けord_schedule(UPDATE)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -500012, "field_name": "ind_bed_cd", "replace_var": "@indBedCd"}, {"sql_cd": -500082, "field_name": "kur_cd", "replace_var": "@indKurCd"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500035, 'WITH ssi_in_hospital_cd AS ( 
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
select
	medicine_cd
from
	mst_medicine
where
	is_del = ''0''
	and is_disp = ''1''
	and CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN in_hospital_cd_1 = @indCondInfo.025.value AND COALESCE(in_hospital_cd_1,'''') <> ''''
        WHEN ''2'' THEN in_hospital_cd_2 = @indCondInfo.025.value AND COALESCE(in_hospital_cd_2,'''') <> ''''
        WHEN ''3'' THEN in_hospital_cd_3 = @indCondInfo.025.value AND COALESCE(in_hospital_cd_3,'''') <> ''''
        WHEN ''4'' THEN in_hospital_cd_4 = @indCondInfo.025.value AND COALESCE(in_hospital_cd_4,'''') <> ''''
      END
	and facility_cd = @facilityCd', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの薬剤(SELECT)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500036, 'WITH ssi_in_hospital_cd AS ( 
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
    AND info->>''key2'' = ''ANTICOAGULANT'' -- 抗凝固剤''
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
        WHEN (@indCondInfo.025.value='''') 
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
  ,   @indCondInfo.025.name
  ,   NULL
  ,   @indCondInfo.025.unit
  ,   NULL
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
        WHEN ''1'' THEN @indCondInfo.025.value
        WHEN ''2'' THEN NULL
        WHEN ''3'' THEN NULL
        WHEN ''4'' THEN NULL
      END
  ,   CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN NULL
        WHEN ''2'' THEN @indCondInfo.025.value
        WHEN ''3'' THEN NULL
        WHEN ''4'' THEN NULL
      END
  ,   CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN NULL
        WHEN ''2'' THEN NULL
        WHEN ''3'' THEN @indCondInfo.025.value
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
        WHEN ''4'' THEN @indCondInfo.025.value
      END
FROM is_new
WHERE is_new = 1', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの薬剤(INSERT)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500037, 'WITH ssi_in_hospital_cd AS ( 
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
select
	equipment_cd
from
	mst_equipment
where
	is_del = ''0''
	and is_disp = ''1''
	and CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN in_hospital_cd_1 = @indCondInfo.011.value AND COALESCE(in_hospital_cd_1,'''') <> ''''
        WHEN ''2'' THEN in_hospital_cd_2 = @indCondInfo.011.value AND COALESCE(in_hospital_cd_2,'''') <> ''''
        WHEN ''3'' THEN in_hospital_cd_3 = @indCondInfo.011.value AND COALESCE(in_hospital_cd_3,'''') <> ''''
        WHEN ''4'' THEN in_hospital_cd_4 = @indCondInfo.011.value AND COALESCE(in_hospital_cd_4,'''') <> ''''
      END
	and facility_cd = @facilityCd', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの治療材料(SELECT)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500038, 'WITH ssi_in_hospital_cd AS ( 
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
    AND info->>''key2'' = ''V_NEEDLE'' -- V針''
) 
, class_cd_info AS (
  SELECT
    class_cd AS class_cd
  FROM mst_equipment_class
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
        WHEN (@indCondInfo.011.value='''') 
        THEN 0 
        ELSE 1 
    END AS is_new
)
INSERT INTO mst_equipment( 
      facility_cd
  ,   fn_equipment_cd
  ,   standard_equipment_cd
  ,   is_trial
  ,   equipment_name
  ,   equipment_short_name
  ,   class_cd
  ,   unit
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
  ,   NULL
  ,   @indCondInfo.011.name
  ,   NULL
  ,   (SELECT class_cd FROM class_cd_info)
  ,   NULL
  ,   NULL
  ,   NULL
  ,   CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN @indCondInfo.011.value
        WHEN ''2'' THEN NULL
        WHEN ''3'' THEN NULL
        WHEN ''4'' THEN NULL
      END
  ,   CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN NULL
        WHEN ''2'' THEN @indCondInfo.011.value
        WHEN ''3'' THEN NULL
        WHEN ''4'' THEN NULL
      END
  ,   CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN NULL
        WHEN ''2'' THEN NULL
        WHEN ''3'' THEN @indCondInfo.011.value
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
        WHEN ''4'' THEN @indCondInfo.011.value
      END
FROM is_new
WHERE is_new = 1', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの医療材料(INSERT)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500039, 'WITH ssi_in_hospital_cd AS ( 
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
select
	va_cd as ind_va_cd
from
	mst_va
where
	is_del = ''0''
	and is_disp = ''1''
	and CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN in_hospital_cd_1 = @indVaCd AND COALESCE(in_hospital_cd_1,'''') <> ''''
        WHEN ''2'' THEN in_hospital_cd_2 = @indVaCd AND COALESCE(in_hospital_cd_2,'''') <> ''''
      END
;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのVA(SELECT)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
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
, is_new AS (
  SELECT 
    CASE 
        WHEN (@indVaCd='''') 
        THEN 0 
        ELSE 1 
    END AS is_new
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
  ,   @indVaPart
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
FROM is_new
WHERE is_new = 1', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのVA(INSERT)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500041, 'WITH pat_in_out_visit_history_tbl AS (
SELECT
  info ->> ''ctl_no'' AS ctl_no,
  info ->> ''move_in_out'' AS move_in_out,
  info ->> ''period_start'' AS period_start 
FROM
  pat_unique
  CROSS JOIN lateral json_array_elements ( pat_unique.in_out_visit_history_info :: json ) info 
WHERE
  pat_id = @patId 
  AND facility_cd = @facilityCd
  AND is_del = ''0'' 
  )
  , a AS(
  SELECT
    move_in_out
  FROM pat_in_out_visit_history_tbl
  WHERE period_start <= @treatDate
  ORDER BY period_start DESC, ctl_no DESC
  LIMIT 1
  )
SELECT
  1
FROM a 
WHERE move_in_out IN (''3'', ''7'', ''8'', ''11'') -- 透析日より前の最新の転入出状態が「3:転出」「7:離脱」「8:移植」「11:死亡」の場合は対象外
UNION
SELECT
  1
WHERE @diePatId <> ''-1''  
  ;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの患者入外状態チェック(SELECT)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -500081, "field_name": "pat_id", "replace_var": "@diePatId"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500042, 'WITH ssi_change_ctrl_info AS ( 
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
    AND info->>''key1'' = ''SSI_CHANGE_CTRL''
) 
SELECT
  ord_no,
  pat_id,
  fn_pat_id,
  treat_date,
  treat_week,
  facility_cd,
  facility_name,
  ind_va_cd,
  ind_treatment_cd,
  ind_treatment_name,
  ind_kur_cd,
  ind_kur_name,
  ind_treat_start_time,
  ind_bed_cd,
  ind_bed_name,
  ind_schedule_user_info,
  ind_cond_info,
  ind_medi_info,
  ind_equip_info,
  ind_ind_comment_info,
  ind_tare_info,
  ind_off_water_info,
  ind_device_set_info,
  rst_fn_dialysis_no,
  rst_relation_dialysis_no,
  rst_edition,
  rst_is_update_edition,
  rst_input_class,
  rst_dialysis_state,
  rst_treatment_cd,
  rst_treatment_name,
  rst_kur_cd,
  rst_kur_name,
  rst_bed_cd,
  rst_bed_name,
  rst_machine_no,
  rst_machine_name,
  rst_cond_send_date,
  rst_accept_date,
  rst_start_date,
  rst_end_date,
  rst_return_home_date,
  rst_in_out_class,
  rst_dialysis_cnt,
  rst_ward_cd,
  rst_ward_name,
  rst_course_cd,
  rst_course_name,
  rst_puncture_user_info,
  rst_return_user_info,
  rst_charge_user_info,
  rst_blood_circulate_total,
  rst_running_time,
  rst_kt_v,
  rec_set_date,
  send_ctl_no,
  blood_purifier_name,
  pull_leave_amount,
  rst_cond_info,
  rst_medi_info,
  rst_equip_info,
  rst_ind_comment_info,
  rst_tare_info,
  rst_off_water_info,
  rst_weight_info,
  rst_complaint_info,
  rst_treatment_info,
  rst_treat_staff_info,
  rst_rounds_info,
  is_del,
  up_date,
  reg_date,
  rst_dw,
  weight_scale_no,
  treat_type,
  is_confirm,
  ind_dw,
  rst_purification_cnt,
  addition_info,
  up_ind_user_id,
  up_user_id,
  rst_edition_date,
  cur_edition_date,
  fn_plural 
FROM
  ord_main 
WHERE
  is_del = ''0'' 
  AND facility_cd = @facilityCd 
  AND ord_no = @ordNo 
  AND (SELECT VALUE FROM ssi_change_ctrl_info WHERE key2 = ''EQUIPMENT'')=''1''', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのオーダ受け(SELECT)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500043, 'WITH ssi_change_ctrl_info AS ( 
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
    AND info->>''key1'' = ''SSI_CHANGE_CTRL''
) 
SELECT
  ord_no,
  pat_id,
  fn_pat_id,
  treat_date,
  treat_week,
  facility_cd,
  facility_name,
  ind_va_cd,
  ind_treatment_cd,
  ind_treatment_name,
  ind_kur_cd,
  ind_kur_name,
  ind_treat_start_time,
  ind_bed_cd,
  ind_bed_name,
  ind_schedule_user_info,
  ind_cond_info,
  ind_medi_info,
  ind_equip_info,
  ind_ind_comment_info,
  ind_tare_info,
  ind_off_water_info,
  ind_device_set_info,
  rst_fn_dialysis_no,
  rst_relation_dialysis_no,
  rst_edition,
  rst_is_update_edition,
  rst_input_class,
  rst_dialysis_state,
  rst_treatment_cd,
  rst_treatment_name,
  rst_kur_cd,
  rst_kur_name,
  rst_bed_cd,
  rst_bed_name,
  rst_machine_no,
  rst_machine_name,
  rst_cond_send_date,
  rst_accept_date,
  rst_start_date,
  rst_end_date,
  rst_return_home_date,
  rst_in_out_class,
  rst_dialysis_cnt,
  rst_ward_cd,
  rst_ward_name,
  rst_course_cd,
  rst_course_name,
  rst_puncture_user_info,
  rst_return_user_info,
  rst_charge_user_info,
  rst_blood_circulate_total,
  rst_running_time,
  rst_kt_v,
  rec_set_date,
  send_ctl_no,
  blood_purifier_name,
  pull_leave_amount,
  rst_cond_info,
  rst_medi_info,
  rst_equip_info,
  rst_ind_comment_info,
  rst_tare_info,
  rst_off_water_info,
  rst_weight_info,
  rst_complaint_info,
  rst_treatment_info,
  rst_treat_staff_info,
  rst_rounds_info,
  is_del,
  up_date,
  reg_date,
  rst_dw,
  weight_scale_no,
  treat_type,
  is_confirm,
  ind_dw,
  rst_purification_cnt,
  addition_info,
  up_ind_user_id,
  up_user_id,
  rst_edition_date,
  cur_edition_date,
  fn_plural 
FROM
  ord_main 
WHERE
  is_del = ''0'' 
  AND facility_cd = @facilityCd 
  AND ord_no = @ordNo 
  AND (SELECT VALUE FROM ssi_change_ctrl_info WHERE key2 = ''MEDICATION'')=''1''', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのオーダ受け(SELECT)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500044, '-- マスタに登録した内容をmst_selectorにも追加
WITH ssi_in_hospital_cd AS ( 
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
equipment_info AS(
    SELECT
        equipment_cd,
        equipment_name
    FROM
        mst_equipment
    WHERE
        facility_cd = ''@facilityCd''
    AND CASE (SELECT VALUE FROM ssi_in_hospital_cd)
          WHEN ''1'' THEN in_hospital_cd_1 = ''@indCondInfo.010.value'' AND COALESCE(in_hospital_cd_1,'''') <> ''''
          WHEN ''2'' THEN in_hospital_cd_2 = ''@indCondInfo.010.value'' AND COALESCE(in_hospital_cd_2,'''') <> ''''
          WHEN ''3'' THEN in_hospital_cd_3 = ''@indCondInfo.010.value'' AND COALESCE(in_hospital_cd_3,'''') <> ''''
          WHEN ''4'' THEN in_hospital_cd_4 = ''@indCondInfo.010.value'' AND COALESCE(in_hospital_cd_4,'''') <> ''''
        END
    AND is_del = ''0''
    AND is_disp = ''1''
    ORDER BY equipment_cd DESC
    LIMIT 1
)
UPDATE
  mst_selector
SET 
 order_settings = json_build_object
 (''items'',order_settings::jsonb->''items'' || json_build_array(
   json_build_object(
   ''code'', equipment_cd, 
   ''name'', CAST(equipment_name AS TEXT),
   ''isDel'', CAST(0 AS TEXT),
   ''isDisp'', CAST(1 AS TEXT),
   ''jlac10Cd'', CAST(NULL AS TEXT)
   ))::jsonb
 )::jsonb
 FROM equipment_info
WHERE 
  mst_selector.facility_cd = ''@facilityCd''
AND
  master_physical_name = ''mst_equipment''
;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのオーダ受け_医療材料マスタ登録(mst_selector)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -500016}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500045, '-- マスタに登録した内容をmst_selectorにも追加
WITH ssi_in_hospital_cd AS ( 
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
medicine_info AS(
    SELECT
        medicine_cd,
        medicine_name
    FROM
        mst_medicine
    WHERE
        facility_cd = ''@facilityCd''
    AND CASE (SELECT VALUE FROM ssi_in_hospital_cd)
          WHEN ''1'' THEN in_hospital_cd_1 = ''@indCondInfo.015.value'' AND COALESCE(in_hospital_cd_1,'''') <> ''''
          WHEN ''2'' THEN in_hospital_cd_2 = ''@indCondInfo.015.value'' AND COALESCE(in_hospital_cd_2,'''') <> ''''
          WHEN ''3'' THEN in_hospital_cd_3 = ''@indCondInfo.015.value'' AND COALESCE(in_hospital_cd_3,'''') <> ''''
          WHEN ''4'' THEN in_hospital_cd_4 = ''@indCondInfo.015.value'' AND COALESCE(in_hospital_cd_4,'''') <> ''''
        END
    AND is_del = ''0''
    AND is_disp = ''1''
    ORDER BY medicine_cd DESC
    LIMIT 1
)
UPDATE
  mst_selector
SET 
 order_settings = json_build_object
 (''items'',order_settings::jsonb->''items'' || json_build_array(
   json_build_object(
   ''code'', medicine_cd, 
   ''name'', CAST(medicine_name AS TEXT),
   ''isDel'', CAST(0 AS TEXT),
   ''isDisp'', CAST(1 AS TEXT),
   ''jlac10Cd'', CAST(NULL AS TEXT)
   ))::jsonb
 )::jsonb
 FROM medicine_info
WHERE 
  mst_selector.facility_cd = ''@facilityCd''
AND
  master_physical_name = ''mst_medicine''
;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのオーダ受け_薬剤マスタ登録(mst_selector)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -500018}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500046, '-- マスタに登録した内容をmst_selectorにも追加
WITH  ssi_in_hospital_cd AS ( 
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
equipment_info AS(
    SELECT
        equipment_cd,
        equipment_name
    FROM
        mst_equipment
    WHERE
        facility_cd = ''@facilityCd''
    and CASE (SELECT VALUE FROM ssi_in_hospital_cd)
          WHEN ''1'' THEN in_hospital_cd_1 = ''@indEquipInfo.cd'' AND COALESCE(in_hospital_cd_1,'''') <> ''''
          WHEN ''2'' THEN in_hospital_cd_2 = ''@indEquipInfo.cd'' AND COALESCE(in_hospital_cd_2,'''') <> ''''
          WHEN ''3'' THEN in_hospital_cd_3 = ''@indEquipInfo.cd'' AND COALESCE(in_hospital_cd_3,'''') <> ''''
          WHEN ''4'' THEN in_hospital_cd_4 = ''@indEquipInfo.cd'' AND COALESCE(in_hospital_cd_4,'''') <> ''''
        END
    AND is_del = ''0''
    AND is_disp = ''1''
    ORDER BY equipment_cd DESC
    LIMIT 1
)
UPDATE
  mst_selector
SET 
 order_settings = json_build_object
 (''items'',order_settings::jsonb->''items'' || json_build_array(
   json_build_object(
   ''code'', equipment_cd, 
   ''name'', CAST(equipment_name AS TEXT),
   ''isDel'', CAST(0 AS TEXT),
   ''isDisp'', CAST(1 AS TEXT),
   ''jlac10Cd'', CAST(NULL AS TEXT)
   ))::jsonb
 )::jsonb
 FROM equipment_info
WHERE 
  mst_selector.facility_cd = ''@facilityCd''
AND
  master_physical_name = ''mst_equipment''
;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのオーダ受け_医療材料マスタ登録(mst_selector)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -500020}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500048, '-- マスタに登録した内容をmst_selectorにも追加
WITH ssi_in_hospital_cd AS ( 
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
procedure_info AS(
    SELECT
        procedure_cd,
        pricedure_name
    FROM
        mst_procedure
    WHERE
        facility_cd = ''@facilityCd''
    AND CASE (SELECT VALUE FROM ssi_in_hospital_cd)
          WHEN ''1'' THEN in_hospital_cd_a1 = ''@indMediInfo.procedureCd'' AND COALESCE(in_hospital_cd_a1,'''') <> ''''
          WHEN ''2'' THEN in_hospital_cd_a2 = ''@indMediInfo.procedureCd'' AND COALESCE(in_hospital_cd_a2,'''') <> ''''
        END
    AND is_del = ''0''
    AND is_disp = ''1''
    ORDER BY procedure_cd DESC
    LIMIT 1
)
UPDATE
  mst_selector
SET 
 order_settings = json_build_object
 (''items'',order_settings::jsonb->''items'' || json_build_array(
   json_build_object(
   ''code'', procedure_cd, 
   ''name'', CAST(pricedure_name AS TEXT),
   ''isDel'', CAST(0 AS TEXT),
   ''isDisp'', CAST(1 AS TEXT),
   ''jlac10Cd'', CAST(NULL AS TEXT)
   ))::jsonb
 )::jsonb
 FROM procedure_info
WHERE 
  mst_selector.facility_cd = ''@facilityCd''
AND
  master_physical_name = ''mst_procedure''
;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのオーダ受け_手技マスタ登録(mst_selector)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -500024}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500049, '-- マスタに登録した内容をmst_selectorにも追加
WITH ssi_in_hospital_cd AS ( 
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
equipment_info AS(
    SELECT
        equipment_cd,
        equipment_name
    FROM
        mst_equipment
    WHERE
        facility_cd = ''@facilityCd''
    AND CASE (SELECT VALUE FROM ssi_in_hospital_cd)
          WHEN ''1'' THEN in_hospital_cd_1 = ''@indCondInfo.006.value'' AND COALESCE(in_hospital_cd_1,'''') <> ''''
          WHEN ''2'' THEN in_hospital_cd_2 = ''@indCondInfo.006.value'' AND COALESCE(in_hospital_cd_2,'''') <> ''''
          WHEN ''3'' THEN in_hospital_cd_3 = ''@indCondInfo.006.value'' AND COALESCE(in_hospital_cd_3,'''') <> ''''
          WHEN ''4'' THEN in_hospital_cd_4 = ''@indCondInfo.006.value'' AND COALESCE(in_hospital_cd_4,'''') <> ''''
        END
    AND is_del = ''0''
    AND is_disp = ''1''
    ORDER BY equipment_cd DESC
    LIMIT 1
)
UPDATE
  mst_selector
SET 
 order_settings = json_build_object
 (''items'',order_settings::jsonb->''items'' || json_build_array(
   json_build_object(
   ''code'', equipment_cd, 
   ''name'', CAST(equipment_name AS TEXT),
   ''isDel'', CAST(0 AS TEXT),
   ''isDisp'', CAST(1 AS TEXT),
   ''jlac10Cd'', CAST(NULL AS TEXT)
   ))::jsonb
 )::jsonb
 FROM equipment_info
WHERE 
  mst_selector.facility_cd = ''@facilityCd''
AND
  master_physical_name = ''mst_equipment''
;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのオーダ受け_医療材料マスタ登録(mst_selector)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -500028}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500050, '-- マスタに登録した内容をmst_selectorにも追加
WITH ssi_in_hospital_cd AS ( 
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
medicine_info AS(
    SELECT
        medicine_cd,
        medicine_name
    FROM
        mst_medicine
    WHERE
        facility_cd = ''@facilityCd''
    AND CASE (SELECT VALUE FROM ssi_in_hospital_cd)
          WHEN ''1'' THEN in_hospital_cd_1 = ''@indCondInfo.019.value'' AND COALESCE(in_hospital_cd_1,'''') <> ''''
          WHEN ''2'' THEN in_hospital_cd_2 = ''@indCondInfo.019.value'' AND COALESCE(in_hospital_cd_2,'''') <> ''''
          WHEN ''3'' THEN in_hospital_cd_3 = ''@indCondInfo.019.value'' AND COALESCE(in_hospital_cd_3,'''') <> ''''
          WHEN ''4'' THEN in_hospital_cd_4 = ''@indCondInfo.019.value'' AND COALESCE(in_hospital_cd_4,'''') <> ''''
        END
    AND is_del = ''0''
    AND is_disp = ''1''
    ORDER BY medicine_cd DESC
    LIMIT 1
)
UPDATE
  mst_selector
SET 
 order_settings = json_build_object
 (''items'',order_settings::jsonb->''items'' || json_build_array(
   json_build_object(
   ''code'', medicine_cd, 
   ''name'', CAST(medicine_name AS TEXT),
   ''isDel'', CAST(0 AS TEXT),
   ''isDisp'', CAST(1 AS TEXT),
   ''jlac10Cd'', CAST(NULL AS TEXT)
   ))::jsonb
 )::jsonb
 FROM medicine_info
WHERE 
  mst_selector.facility_cd = ''@facilityCd''
AND
  master_physical_name = ''mst_medicine''
;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのオーダ受け_薬剤マスタ登録(mst_selector)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -500030}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500051, '-- マスタに登録した内容をmst_selectorにも追加
WITH ssi_in_hospital_cd AS ( 
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
medicine_info AS(
    SELECT
        medicine_cd,
        medicine_name
    FROM
        mst_medicine
    WHERE
        facility_cd = ''@facilityCd''
    AND CASE (SELECT VALUE FROM ssi_in_hospital_cd)
          WHEN ''1'' THEN in_hospital_cd_1 = ''@indCondInfo.025.value'' AND COALESCE(in_hospital_cd_1,'''') <> ''''
          WHEN ''2'' THEN in_hospital_cd_2 = ''@indCondInfo.025.value'' AND COALESCE(in_hospital_cd_2,'''') <> ''''
          WHEN ''3'' THEN in_hospital_cd_3 = ''@indCondInfo.025.value'' AND COALESCE(in_hospital_cd_3,'''') <> ''''
          WHEN ''4'' THEN in_hospital_cd_4 = ''@indCondInfo.025.value'' AND COALESCE(in_hospital_cd_4,'''') <> ''''
        END
    AND is_del = ''0''
    AND is_disp = ''1''
    ORDER BY medicine_cd DESC
    LIMIT 1
)
UPDATE
  mst_selector
SET 
 order_settings = json_build_object
 (''items'',order_settings::jsonb->''items'' || json_build_array(
   json_build_object(
   ''code'', medicine_cd, 
   ''name'', CAST(medicine_name AS TEXT),
   ''isDel'', CAST(0 AS TEXT),
   ''isDisp'', CAST(1 AS TEXT),
   ''jlac10Cd'', CAST(NULL AS TEXT)
   ))::jsonb
 )::jsonb
 FROM medicine_info
WHERE 
  mst_selector.facility_cd = ''@facilityCd''
AND
  master_physical_name = ''mst_medicine''
;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのオーダ受け_薬剤マスタ登録(mst_selector)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -500036}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500052, '-- マスタに登録した内容をmst_selectorにも追加
WITH ssi_in_hospital_cd AS ( 
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
equipment_info AS(
    SELECT
        equipment_cd,
        equipment_name
    FROM
        mst_equipment
    WHERE
        facility_cd = ''@facilityCd''
    AND CASE (SELECT VALUE FROM ssi_in_hospital_cd)
          WHEN ''1'' THEN in_hospital_cd_1 = ''@indCondInfo.011.value'' AND COALESCE(in_hospital_cd_1,'''') <> ''''
          WHEN ''2'' THEN in_hospital_cd_2 = ''@indCondInfo.011.value'' AND COALESCE(in_hospital_cd_2,'''') <> ''''
          WHEN ''3'' THEN in_hospital_cd_3 = ''@indCondInfo.011.value'' AND COALESCE(in_hospital_cd_3,'''') <> ''''
          WHEN ''4'' THEN in_hospital_cd_4 = ''@indCondInfo.011.value'' AND COALESCE(in_hospital_cd_4,'''') <> ''''
        END
    AND is_del = ''0''
    AND is_disp = ''1''
    ORDER BY equipment_cd DESC
    LIMIT 1
)
UPDATE
  mst_selector
SET 
 order_settings = json_build_object
 (''items'',order_settings::jsonb->''items'' || json_build_array(
   json_build_object(
   ''code'', equipment_cd, 
   ''name'', CAST(equipment_name AS TEXT),
   ''isDel'', CAST(0 AS TEXT),
   ''isDisp'', CAST(1 AS TEXT),
   ''jlac10Cd'', CAST(NULL AS TEXT)
   ))::jsonb
 )::jsonb
 FROM equipment_info
WHERE 
  mst_selector.facility_cd = ''@facilityCd''
AND
  master_physical_name = ''mst_equipment''
;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのオーダ受け_医療材料マスタ登録(mst_selector)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -500038}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500053, '-- マスタに登録した内容をmst_selectorにも追加
WITH  ssi_in_hospital_cd AS ( 
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
va_info AS(
    SELECT
        va_cd,
        va_name
    FROM
        mst_va
    WHERE
        facility_cd = ''@facilityCd''
    and CASE (SELECT VALUE FROM ssi_in_hospital_cd)
          WHEN ''1'' THEN in_hospital_cd_1 = ''@indVaCd'' AND COALESCE(in_hospital_cd_1,'''') <> ''''
          WHEN ''2'' THEN in_hospital_cd_2 = ''@indVaCd'' AND COALESCE(in_hospital_cd_2,'''') <> ''''
        END
    AND is_del = ''0''
    AND is_disp = ''1''
    ORDER BY va_cd DESC
    LIMIT 1
)
UPDATE
  mst_selector
SET 
 order_settings = json_build_object
 (''items'',order_settings::jsonb->''items'' || json_build_array(
   json_build_object(
   ''code'', va_cd, 
   ''name'', CAST(va_name AS TEXT),
   ''isDel'', CAST(0 AS TEXT),
   ''isDisp'', CAST(1 AS TEXT),
   ''jlac10Cd'', CAST(NULL AS TEXT)
   ))::jsonb
 )::jsonb
 FROM va_info
WHERE 
  mst_selector.facility_cd = ''@facilityCd''
AND
  master_physical_name = ''mst_va''
;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのオーダ受け_VAマスタ登録(mst_selector)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -500040}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500054, '-- マスタに登録した内容をmst_selectorにも追加
WITH ssi_in_hospital_cd AS ( 
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
)
, dialyzer_info AS(
    SELECT
        dialyzer_cd,
        model_number
    FROM
        mst_dialyzer
    WHERE
        facility_cd = ''@facilityCd''
    AND CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN in_hospital_cd_1 = ''@indCondInfo.005.value'' AND COALESCE(in_hospital_cd_1,'''') <> ''''
        WHEN ''2'' THEN in_hospital_cd_2 = ''@indCondInfo.005.value'' AND COALESCE(in_hospital_cd_2,'''') <> ''''
        WHEN ''3'' THEN in_hospital_cd_3 = ''@indCondInfo.005.value'' AND COALESCE(in_hospital_cd_3,'''') <> ''''
        WHEN ''4'' THEN in_hospital_cd_4 = ''@indCondInfo.005.value'' AND COALESCE(in_hospital_cd_4,'''') <> ''''
      END
    AND is_del = ''0''
    AND is_disp = ''1''
    ORDER BY dialyzer_cd DESC
    LIMIT 1
)
, ssi_order_treat_info AS ( 
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
    AND info->>''key1'' = ''SSI_ORDER_TREAT''
    AND info->>''key2'' = ''@indTreatmentName''
)
, is_membrane AS (
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
)

UPDATE
  mst_selector
SET 
 order_settings = json_build_object
 (''items'',order_settings::jsonb->''items'' || json_build_array(
   json_build_object(
   ''code'', dialyzer_cd, 
   ''name'', CAST(model_number AS TEXT),
   ''isDel'', CAST(0 AS TEXT),
   ''isDisp'', CAST(1 AS TEXT),
   ''jlac10Cd'', CAST(NULL AS TEXT)
   ))::jsonb
 )::jsonb
 FROM dialyzer_info
WHERE 
  mst_selector.facility_cd = ''@facilityCd''
AND
  master_physical_name = ''mst_dialyzer''
AND
  (SELECT is_membrane FROM is_membrane) = 0 -- 膜使用する治療方法以外の場合のみ登録
;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのオーダ受け_ダイアライザマスタ登録(mst_selector)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -500026}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500058, 'WITH ssi_order_recv_info AS ( 
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
ssi_order_treat_info AS ( 
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
device_mode_info AS ( 
  select
    device_mode
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
  (@dialysisTime)::int > (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''DIALYSIS_TIME_LIMIT'')::int
  AND ''9'' not in (SELECT device_mode FROM device_mode_info)
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの治療方法(SELECT)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500059, 'WITH ssi_order_recv_info AS ( 
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
ssi_order_treat_info AS ( 
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
device_mode_info AS ( 
  select
    device_mode
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
  (@dialysisTime)::int > (SELECT VALUE FROM ssi_order_recv_info WHERE key2 = ''PURIFICATION_TIME_LIMIT'')::int
  AND ''9'' in (SELECT device_mode FROM device_mode_info)
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの治療方法(SELECT)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500060, '-- マスタに登録した内容をmst_selectorにも追加
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
, equipment_info AS(
    SELECT
        equipment_cd,
        equipment_name
    FROM
        mst_equipment
    WHERE
        facility_cd = @facilityCd
    AND CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN in_hospital_cd_1 = @indEquipInfo.cd AND COALESCE(in_hospital_cd_1,'''') <> ''''
        WHEN ''2'' THEN in_hospital_cd_2 = @indEquipInfo.cd AND COALESCE(in_hospital_cd_2,'''') <> ''''
        WHEN ''3'' THEN in_hospital_cd_3 = @indEquipInfo.cd AND COALESCE(in_hospital_cd_3,'''') <> ''''
        WHEN ''4'' THEN in_hospital_cd_4 = @indEquipInfo.cd AND COALESCE(in_hospital_cd_4,'''') <> ''''
      END
    AND is_del = ''0''
    AND is_disp = ''1''
    ORDER BY equipment_cd DESC
    LIMIT 1
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

UPDATE
  mst_selector
SET 
 order_settings = json_build_object
 (''items'',order_settings::jsonb->''items'' || json_build_array(
   json_build_object(
   ''code'', equipment_cd, 
   ''name'', CAST(equipment_name AS TEXT),
   ''isDel'', CAST(0 AS TEXT),
   ''isDisp'', CAST(1 AS TEXT),
   ''jlac10Cd'', CAST(NULL AS TEXT)
   ))::jsonb
 )::jsonb
 FROM equipment_info
WHERE 
  mst_selector.facility_cd = @facilityCd
AND
  master_physical_name = ''mst_equipment''
AND
  (SELECT is_membrane FROM is_membrane) = 1 -- 膜使用する治療方法の場合のみ登録
;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのオーダ受け_医療材料マスタ登録(mst_selector)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -500061}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500061, 'WITH class_cd_ini AS (
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
    AND info->>''key2'' = ''MEMBRANE1'' -- 1次膜''
)
, class_cd_info AS (
  SELECT
  class_cd AS class_cd
  FROM mst_equipment_class
  WHERE 
    facility_cd = @facilityCd
    AND is_del = ''0'' 
    AND is_disp = ''1'' 
    AND class_name = (SELECT VALUE FROM class_cd_ini)
  LIMIT 1
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

INSERT INTO mst_equipment( 
      facility_cd
  ,   fn_equipment_cd
  ,   standard_equipment_cd
  ,   is_trial
  ,   equipment_name
  ,   equipment_short_name
  ,   class_cd
  ,   unit
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
  ,   NULL
  ,   @indEquipInfo.name
  ,   NULL
  ,   (SELECT class_cd FROM class_cd_info)
  ,   NULL
  ,   NULL
  ,   NULL
  ,   @indEquipInfo.cd
  ,   NULL
  ,   NULL
  ,   ''1''
  ,   ''0''
  ,   CURRENT_TIMESTAMP
  ,   CURRENT_TIMESTAMP
  ,   NULL
FROM is_membrane
WHERE is_membrane = 1 -- 膜使用する治療方法の場合のみ登録', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのオーダ受け_医療材料マスタ登録(mst_selector)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500062, '-- マスタに登録した内容をmst_selectorにも追加
WITH ssi_in_hospital_cd AS ( 
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
)
, equipment_info AS(
    SELECT
        equipment_cd,
        equipment_name
    FROM
        mst_equipment
    WHERE
        facility_cd = ''@facilityCd''
    AND CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN in_hospital_cd_1 = ''@indEquipInfo.cd'' AND COALESCE(in_hospital_cd_1,'''') <> ''''
        WHEN ''2'' THEN in_hospital_cd_2 = ''@indEquipInfo.cd'' AND COALESCE(in_hospital_cd_2,'''') <> ''''
        WHEN ''3'' THEN in_hospital_cd_3 = ''@indEquipInfo.cd'' AND COALESCE(in_hospital_cd_3,'''') <> ''''
        WHEN ''4'' THEN in_hospital_cd_4 = ''@indEquipInfo.cd'' AND COALESCE(in_hospital_cd_4,'''') <> ''''
      END
    AND is_del = ''0''
    AND is_disp = ''1''
    ORDER BY equipment_cd DESC
    LIMIT 1
)
, ssi_order_treat_info AS ( 
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
    AND info->>''key1'' = ''SSI_ORDER_TREAT''
    AND info->>''key2'' = ''@indTreatmentName''
)
, is_membrane AS (
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
)

UPDATE
  mst_selector
SET 
 order_settings = json_build_object
 (''items'',order_settings::jsonb->''items'' || json_build_array(
   json_build_object(
   ''code'', equipment_cd, 
   ''name'', CAST(equipment_name AS TEXT),
   ''isDel'', CAST(0 AS TEXT),
   ''isDisp'', CAST(1 AS TEXT),
   ''jlac10Cd'', CAST(NULL AS TEXT)
   ))::jsonb
 )::jsonb
 FROM equipment_info
WHERE 
  mst_selector.facility_cd = ''@facilityCd''
AND
  master_physical_name = ''mst_equipment''
AND
  (SELECT is_membrane FROM is_membrane) = 1 -- 膜使用する治療方法の場合のみ登録
;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのオーダ受け_医療材料マスタ登録(mst_selector)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -500063}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500063, 'WITH class_cd_ini AS (
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
    AND info->>''key2'' = ''MEMBRANE2'' -- 2次膜''
)
, class_cd_info AS (
  SELECT
  class_cd AS class_cd
  FROM mst_equipment_class
  WHERE 
    facility_cd = @facilityCd
    AND is_del = ''0'' 
    AND is_disp = ''1'' 
    AND class_name = (SELECT VALUE FROM class_cd_ini)
  LIMIT 1
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

INSERT INTO mst_equipment( 
      facility_cd
  ,   fn_equipment_cd
  ,   standard_equipment_cd
  ,   is_trial
  ,   equipment_name
  ,   equipment_short_name
  ,   class_cd
  ,   unit
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
  ,   NULL
  ,   @indEquipInfo.name
  ,   NULL
  ,   (SELECT class_cd FROM class_cd_info)
  ,   NULL
  ,   NULL
  ,   NULL
  ,   @indEquipInfo.cd
  ,   NULL
  ,   NULL
  ,   ''1''
  ,   ''0''
  ,   CURRENT_TIMESTAMP
  ,   CURRENT_TIMESTAMP
  ,   NULL
FROM is_membrane
WHERE is_membrane = 1 -- 膜使用する治療方法の場合のみ登録', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのオーダ受け_医療材料マスタ登録(mst_selector)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500064, 'WITH ssi_order_recv_info AS ( 
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
    AND info->>''key2'' = ''BEDNO''
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
) 
select
	bed_cd as ind_bed_cd
from
	mst_bed
where
	is_del = ''0''
	and is_disp = ''1''
	and facility_cd = @facilityCd
	and bed_name = @indBedName
  and CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN in_hospital_cd_1 = @indBedCd AND COALESCE(in_hospital_cd_1,'''') <> ''''
        WHEN ''2'' THEN in_hospital_cd_2 = @indBedCd AND COALESCE(in_hospital_cd_2,'''') <> ''''
      END
  and bed_cd::text in (SELECT  regexp_split_to_table(VALUE,'','') FROM ssi_order_recv_info)', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのベッド(SELECT)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500065, '  SELECT medi_info_no
  FROM medicine_latest_no
  WHERE facility_cd = @facilityCd
  and pat_id = @patId', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのオーダ受け(処方情報の更新)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500066, 'INSERT INTO medicine_latest_no
(
  facility_cd, 
  pat_id, 
  medi_info_no, 
  reg_date, 
  up_date, 
  is_disp, 
  is_del
)VALUES(
  ''@facilityCd'', 
  @patId, 
  0, 
  CURRENT_TIMESTAMP, 
  CURRENT_TIMESTAMP, 
  ''1'', 
  ''0''
);
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのオーダ受け(処方情報の更新)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500067, 'UPDATE medicine_latest_no 
SET medi_info_no = medi_info_no +1
WHERE facility_cd = @facilityCd
and pat_id = @patId', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのオーダ受け(処方情報の更新)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500068, 'WITH ssi_in_hospital_cd AS ( 
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
select
	medicine_cd
from
	mst_medicine
where
	is_del = ''0''
	and is_disp = ''1''
	and CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN in_hospital_cd_1 = @indMediInfo.cd AND COALESCE(in_hospital_cd_1,'''') <> ''''
        WHEN ''2'' THEN in_hospital_cd_2 = @indMediInfo.cd AND COALESCE(in_hospital_cd_2,'''') <> ''''
        WHEN ''3'' THEN in_hospital_cd_3 = @indMediInfo.cd AND COALESCE(in_hospital_cd_3,'''') <> ''''
        WHEN ''4'' THEN in_hospital_cd_4 = @indMediInfo.cd AND COALESCE(in_hospital_cd_4,'''') <> ''''
      END
	and facility_cd = @facilityCd', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの薬剤(SELECT)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500069, 'WITH ssi_in_hospital_cd AS ( 
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
    AND info->>''key2'' = (''MEDICATION_''|| @indMediInfo.no) -- 薬剤''
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
        WHEN (@indMediInfo.cd='''') 
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
  ,   @indMediInfo.name
  ,   NULL
  ,   @indMediInfo.unit
  ,   NULL
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
        WHEN ''1'' THEN @indMediInfo.cd
        WHEN ''2'' THEN NULL
        WHEN ''3'' THEN NULL
        WHEN ''4'' THEN NULL
      END
  ,   CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN NULL
        WHEN ''2'' THEN @indMediInfo.cd
        WHEN ''3'' THEN NULL
        WHEN ''4'' THEN NULL
      END
  ,   CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN NULL
        WHEN ''2'' THEN NULL
        WHEN ''3'' THEN @indMediInfo.cd
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
        WHEN ''4'' THEN @indMediInfo.cd
      END
FROM is_new
WHERE is_new = 1', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの薬剤(INSERT)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500071, 'WITH filteredRstValue as (
  SELECT jsonb_agg(value) AS filtered_rst_medi_info
  FROM (
      SELECT value
      FROM ord_main, jsonb_array_elements(rst_medi_info) WITH ORDINALITY arr(value, index)
      where value ->> ''effect_flg'' = ''1''
      and ord_no = ''@ordNo''  
      ORDER BY index
  ) filtered
),
filteredIndValue as (
  SELECT jsonb_agg(value) AS filtered_ind_medi_info
  FROM (
      SELECT value
      FROM ord_main, jsonb_array_elements(rst_medi_info) WITH ORDINALITY arr(value, index)
      where value ->> ''no'' in (
        SELECT value ->> ''no''
        FROM ord_main, jsonb_array_elements(rst_medi_info) WITH ORDINALITY arr(value, index)
        where value ->> ''effect_flg'' = ''1''
        and ord_no = ''@ordNo'' 
      )
      and ord_no = ''@ordNo'' 
      ORDER BY index
  ) filtered
)
UPDATE ord_main 
SET
  ind_medi_info = COALESCE((SELECT filtered_ind_medi_info::text FROM filteredIndValue),''[]'' )::jsonb
, rst_medi_info = COALESCE((SELECT filtered_rst_medi_info::text FROM filteredRstValue),''[]'' )::jsonb
WHERE
  ord_no = ''@ordNo''
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのオーダ受け(処方情報の更新)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500072, 'WITH ssi_in_hospital_cd AS ( 
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
procedure as (
  select procedure_cd
  from mst_procedure
  where is_del = ''0''
	and is_disp = ''1''
	and CASE (SELECT VALUE FROM ssi_in_hospital_cd)
			WHEN ''1'' THEN in_hospital_cd_a1 = ''@indMediInfo.procedureCd''
			WHEN ''2'' THEN in_hospital_cd_a2 = ''@indMediInfo.procedureCd''
		END
	and facility_cd = ''@facilityCd''
	and ''@indMediInfo.procedureCd''<>''''
  limit 1
),
medicine as (
  SELECT mst_medicine.medicine_cd
      ,  mst_medicine.class_cd
      ,  COALESCE(mst_medicine_class.class_name,'''') AS class_name
      ,  COALESCE(mst_medicine.medicine_short_name,'''') AS medicine_short_name
  FROM mst_medicine
  INNER JOIN mst_medicine_class ON mst_medicine.class_cd = mst_medicine_class.class_cd
  WHERE mst_medicine.is_del = ''0''
  and mst_medicine.is_disp = ''1''
  and CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN mst_medicine.in_hospital_cd_1 = ''@indMediInfo.cd''
        WHEN ''2'' THEN mst_medicine.in_hospital_cd_2 = ''@indMediInfo.cd''
        WHEN ''3'' THEN mst_medicine.in_hospital_cd_3 = ''@indMediInfo.cd''
        WHEN ''4'' THEN mst_medicine.in_hospital_cd_4 = ''@indMediInfo.cd''
      END
  and mst_medicine.facility_cd = ''@facilityCd''
  and ''@indMediInfo.cd''<>''''
  limit 1
),
filteredIndValue as (
  SELECT jsonb_agg(value) AS filtered_ind_medi_info
  FROM (
      SELECT value
      FROM ord_main, jsonb_array_elements(ind_medi_info) WITH ORDINALITY arr(value, index)
      where ord_no = @ordNo  
      ORDER BY index
  ) filtered
),
filteredRstValue as (
  SELECT jsonb_agg(value) AS filtered_rst_medi_info
  FROM (
      SELECT value
      FROM ord_main, jsonb_array_elements(rst_medi_info) WITH ORDINALITY arr(value, index)
      where ord_no = @ordNo  
      ORDER BY index
  ) filtered
),
isExistsRstData as (
  SELECT jsonb_agg(value) AS filtered_rst_medi_info
  FROM (
      SELECT value
      FROM ord_main, jsonb_array_elements(rst_medi_info) WITH ORDINALITY arr(value, index)
      where value ->> ''cd'' = (SELECT medicine_cd FROM medicine)::text
      and value ->> ''effect_flg'' = ''1''
      and ord_no = @ordNo  
      ORDER BY index
  ) filtered
),
newNo as (
  SELECT COALESCE(max(medi_info_no),-1) AS no
  FROM medicine_latest_no
  WHERE facility_cd = ''@facilityCd''
  and pat_id = @patId
)
UPDATE ord_main 
SET
  ind_medi_info = CASE WHEN (SELECT (SELECT filtered_rst_medi_info FROM isExistsRstData) is not null and (ind_medi_info <> ''[]'')) THEN ''@indMediInfoValue'' 
    ELSE 
      CASE WHEN (SELECT(SELECT filtered_ind_medi_info FROM filteredIndValue) is null) THEN 
        concat(''[{"cd":'',COALESCE((SELECT medicine_cd FROM medicine)::text,''null''),'',
        "no":'',(SELECT no+1 FROM newNo)::text,'',
        "name":"@indMediInfo.name",
        "unit":"@indMediInfo.unit",
        "amount":"@indMediInfo.amount",
        "comment":null,
        "class_cd":'',COALESCE((SELECT class_cd FROM medicine)::text,''null''),'',
        "init_date":"@indMediInfo.initDate",
        "timing_cd":null,
        "class_name":"'',COALESCE((SELECT class_name FROM medicine)::text,''''),''",
        "class_type": 0,
        "short_name":"'',COALESCE((SELECT medicine_short_name FROM medicine)::text,''''),''",
        "ind_user_id":@indMediInfo.updUserId,
        "input_class":@indMediInfo.inputClass,
        "is_editable":"@indMediInfo.isEditable",
        "upd_user_id":@indMediInfo.updUserId,
        "cop_order_no":null,
        "procedure_cd":'',COALESCE((SELECT procedure_cd FROM procedure)::text,''null''),'',
        "procedure_name": "@indMediInfo.procedureName",
        "date_interval":0,
        "medicine_type":@indMediInfo.medicineType,
        "ind_user_last_name":"@indMediInfo.indUserLastName",
        "upd_user_last_name":"@indMediInfo.updUserLastName",
        "ind_user_first_name":"@indMediInfo.indUserFirstName",
        "upd_user_first_name":"@indMediInfo.updUserFirstName"}]'')::jsonb 
      ELSE 
        (SELECT filtered_ind_medi_info::text FROM filteredIndValue)::jsonb  || concat(''[{"cd":'',COALESCE((SELECT medicine_cd FROM medicine)::text,''''),'',
        "no":'',(SELECT no+1 FROM newNo)::text,'',
        "name":"@indMediInfo.name",
        "unit":"@indMediInfo.unit",
        "amount":"@indMediInfo.amount",
        "comment":null,
        "class_cd":'',COALESCE((SELECT class_cd FROM medicine)::text,''null''),'',
        "init_date":"@indMediInfo.initDate",
        "timing_cd":null,
        "class_name":"'',COALESCE((SELECT class_name FROM medicine)::text,''''),''",
        "class_type": 0,
        "short_name":"'',COALESCE((SELECT medicine_short_name FROM medicine)::text,''''),''",
        "ind_user_id":@indMediInfo.updUserId,
        "input_class":@indMediInfo.inputClass,
        "is_editable":"@indMediInfo.isEditable",
        "upd_user_id":@indMediInfo.updUserId,
        "cop_order_no":null,
        "procedure_cd":'',COALESCE((SELECT procedure_cd FROM procedure)::text,''null''),'',
        "procedure_name": "@indMediInfo.procedureName",
        "date_interval":0,
        "medicine_type":@indMediInfo.medicineType,
        "ind_user_last_name":"@indMediInfo.indUserLastName",
        "upd_user_last_name":"@indMediInfo.updUserLastName",
        "ind_user_first_name":"@indMediInfo.indUserFirstName",
        "upd_user_first_name":"@indMediInfo.updUserFirstName"}]'')::jsonb 
      END 
    END 
,  rst_medi_info = CASE WHEN (SELECT (SELECT filtered_rst_medi_info FROM isExistsRstData) is not null and (rst_medi_info <> ''[]'')) THEN ''@rstMediInfoValue'' 
    ELSE 
      CASE WHEN (SELECT(SELECT filtered_rst_medi_info FROM filteredRstValue) is null) THEN 
        concat(''[{"cd":'',COALESCE((SELECT medicine_cd FROM medicine)::text,''''),'',
        "no":'',(SELECT no+1 FROM newNo)::text,'',
        "name":"@indMediInfo.name",
        "unit":"@indMediInfo.unit",
        "amount":"@indMediInfo.amount",
        "comment":null,
        "class_cd":'',COALESCE((SELECT class_cd FROM medicine)::text,''null''),'',
        "init_date":"@indMediInfo.initDate",
        "timing_cd":null,
        "class_name":"'',COALESCE((SELECT class_name FROM medicine)::text,''''),''",
        "class_type": 0,
        "effect_flg": 0,
        "short_name":"'',COALESCE((SELECT medicine_short_name FROM medicine)::text,''''),''",
        "effect_date":null,
        "input_class":@indMediInfo.inputClass,
        "is_editable":"@indMediInfo.isEditable",
        "cop_order_no":null,
        "procedure_cd":'',COALESCE((SELECT procedure_cd FROM procedure)::text,''null''),'',
        "procedure_name": "@indMediInfo.procedureName",
        "date_interval":0,
        "medicine_type":@indMediInfo.medicineType,
        "effect_user_id": @indMediInfo.updUserId,
        "upd_user_last_name":"@indMediInfo.updUserLastName",
        "upd_user_first_name":"@indMediInfo.updUserFirstName"}]'')::jsonb 
      ELSE 
        (SELECT filtered_rst_medi_info::text FROM filteredRstValue)::jsonb  || concat(''[{"cd":'',COALESCE((SELECT medicine_cd FROM medicine)::text,''''),'',
        "no":'',(SELECT no+1 FROM newNo)::text,'',
        "name":"@indMediInfo.name",
        "unit":"@indMediInfo.unit",
        "amount":"@indMediInfo.amount",
        "comment":null,
        "class_cd":'',COALESCE((SELECT class_cd FROM medicine)::text,''null''),'',
        "init_date":"@indMediInfo.initDate",
        "timing_cd":null,
        "class_name":"'',COALESCE((SELECT class_name FROM medicine)::text,''''),''",
        "class_type": 0,
        "effect_flg": 0,
        "short_name":"'',COALESCE((SELECT medicine_short_name FROM medicine)::text,''''),''",
        "effect_date":null,
        "input_class":@indMediInfo.inputClass,
        "is_editable":"@indMediInfo.isEditable",
        "cop_order_no":null,
        "procedure_cd":'',COALESCE((SELECT procedure_cd FROM procedure)::text,''null''),'',
        "procedure_name": "@indMediInfo.procedureName",
        "date_interval":0,
        "medicine_type":@indMediInfo.medicineType,
        "effect_user_id": @indMediInfo.updUserId,
        "upd_user_last_name":"@indMediInfo.updUserLastName",
        "upd_user_first_name":"@indMediInfo.updUserFirstName"}]'')::jsonb 
      END 
  END 
WHERE
  ord_no = @ordNo
AND
  (SELECT medicine_cd FROM medicine) is not null', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのオーダ受け(処方情報の更新)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -500067}, {"sql_cd": -500031, "field_name": "user_id", "replace_var": "@indMediInfo.updUserId"}, {"sql_cd": -500031, "field_name": "user_last_name", "replace_var": "@indMediInfo.indUserLastName"}, {"sql_cd": -500031, "field_name": "user_first_name", "replace_var": "@indMediInfo.indUserFirstName"}, {"sql_cd": -500031, "field_name": "user_last_name", "replace_var": "@indMediInfo.updUserLastName"}, {"sql_cd": -500031, "field_name": "user_first_name", "replace_var": "@indMediInfo.updUserFirstName"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500073, '-- マスタに登録した内容をmst_selectorにも追加
WITH ssi_in_hospital_cd AS ( 
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
medicine_info AS(
    SELECT
        medicine_cd,
        medicine_name
    FROM
        mst_medicine
    WHERE
        facility_cd = ''@facilityCd''
    AND CASE (SELECT VALUE FROM ssi_in_hospital_cd)
          WHEN ''1'' THEN in_hospital_cd_1 = ''@indMediInfo.cd'' AND COALESCE(in_hospital_cd_1,'''') <> ''''
          WHEN ''2'' THEN in_hospital_cd_2 = ''@indMediInfo.cd'' AND COALESCE(in_hospital_cd_2,'''') <> ''''
          WHEN ''3'' THEN in_hospital_cd_3 = ''@indMediInfo.cd'' AND COALESCE(in_hospital_cd_3,'''') <> ''''
          WHEN ''4'' THEN in_hospital_cd_4 = ''@indMediInfo.cd'' AND COALESCE(in_hospital_cd_4,'''') <> ''''
        END
    AND is_del = ''0''
    AND is_disp = ''1''
    ORDER BY medicine_cd DESC
    LIMIT 1
)
UPDATE
  mst_selector
SET 
 order_settings = json_build_object
 (''items'',order_settings::jsonb->''items'' || json_build_array(
   json_build_object(
   ''code'', medicine_cd, 
   ''name'', CAST(medicine_name AS TEXT),
   ''isDel'', CAST(0 AS TEXT),
   ''isDisp'', CAST(1 AS TEXT),
   ''jlac10Cd'', CAST(NULL AS TEXT)
   ))::jsonb
 )::jsonb
 FROM medicine_info
WHERE 
  mst_selector.facility_cd = ''@facilityCd''
AND
  master_physical_name = ''mst_medicine''
;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのオーダ受け_薬剤マスタ登録(mst_selector)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -500069}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500074, 'WITH ssi_order_treat_info AS ( 
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
pat_max_upper_limit AS (
  SELECT (device_set_info#>>''{"ope","dev","A","383"}'')::numeric AS pat_max_upper_limit
  FROM pat_main 
  WHERE pat_id = @patId
),
max_upper_limit_info AS ( 
  select
    CASE 
      WHEN device_mode in (-1,9) THEN 
        999.0
      WHEN device_mode in (2,3,6) THEN 
        30.0
      WHEN device_mode in (4) THEN 
        99.9
      WHEN device_mode in (7,8) THEN 
        COALESCE((SELECT pat_max_upper_limit FROM pat_max_upper_limit), 192.0)
      ELSE
        999.0
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
  (SELECT replenisher_amount FROM calc_value) > (SELECT max_upper_limit FROM max_upper_limit_info)
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの治療方法(SELECT)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500081, 'SELECT
  pat_id,
  0 AS ord
FROM
  pat_personal_main
WHERE
  pat_id = @patId 
  AND facility_cd = @facilityCd
  AND is_del = ''0''
  AND is_die  = ''1''
  AND die_date IS NOT NULL
UNION 
SELECT
  -1 AS pat_id,
  1 AS ord
ORDER BY ord ASC
LIMIT 1
;', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの患者死亡状態チェック(SELECT)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500082, 'SELECT
  COALESCE(
    (
      SELECT
        kur_cd
      FROM
        mst_kur
      WHERE
        facility_cd = @facilityCd
        AND is_del = ''0''
        AND @indTreatStartTime || ''00'' BETWEEN kur_start_time AND kur_end_time
    )
    , 0
  ) AS kur_cd
;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのオーダ受け(kur_cd判定)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500083, 'WITH ssi_order_treat_set_name AS ( 
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
    AND info->>''key1'' = ''SSI_ORDER_TREAT_SET''
    AND info->>''key2'' = @indTreatmentName
),
treatment_set_order AS ( 
  SELECT 
    (item->>''code'')::INTEGER AS treatment_set_cd, row_number() OVER () AS sort_order
  FROM 
    mst_selector ms 
  CROSS JOIN LATERAL jsonb_array_elements(order_settings::jsonb->''items'') as item
    WHERE 
    facility_cd = @facilityCd
      AND master_physical_name = ''mst_treatment_set''
),
treatment_set_info AS ( 
  SELECT
    treatment_set_cd,
    0 AS is_ssi_order_treat_set_name,
    0 AS sort_order
  FROM
    mst_treatment_set
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0'' 
    AND is_disp = ''1'' 
    AND treatment_cd = @indTreatmentCd
    AND treatment_set_name IN (SELECT VALUE FROM ssi_order_treat_set_name)
  UNION ALL
  SELECT
    mst_treatment_set.treatment_set_cd,
    1 AS is_ssi_order_treat_set_name,
    treatment_set_order.sort_order
  FROM
    mst_treatment_set
    JOIN treatment_set_order ON mst_treatment_set.treatment_set_cd = treatment_set_order.treatment_set_cd
  WHERE
    mst_treatment_set.facility_cd = @facilityCd
    AND mst_treatment_set.is_del = ''0'' 
    AND mst_treatment_set.is_disp = ''1'' 
    AND mst_treatment_set.treatment_cd = @indTreatmentCd
  UNION ALL
  SELECT
    mst_treatment_set.treatment_set_cd,
    2 AS is_ssi_order_treat_set_name,
    treatment_set_order.sort_order
  FROM
    mst_treatment_set
    JOIN treatment_set_order ON mst_treatment_set.treatment_set_cd = treatment_set_order.treatment_set_cd
  WHERE
    mst_treatment_set.facility_cd = @facilityCd
    AND mst_treatment_set.is_del = ''0'' 
    AND mst_treatment_set.is_disp = ''1'' 
    AND mst_treatment_set.treatment_cd <> @indTreatmentCd
),
base_json AS (
  SELECT jsonb_object_agg(n, 
    jsonb_build_object(
      ''value'', null,
      ''ind_user_id'', @userId,
      ''input_class'', 2,
      ''is_editable'', ''1'',
      ''upd_user_id'', @userId,
      ''cop_order_no'', null,
      ''ind_user_last_name'', '''' || @userLastName || '''',
      ''upd_user_last_name'', '''' || @userLastName || '''',
      ''ind_user_first_name'', '''' || @userFirstName || '''',
      ''upd_user_first_name'', '''' || @userFirstName || ''''
    )
  ) AS ind_cond_info
  FROM generate_series(1, 38) AS n -- 必要に応じて増やす
),
default_set_json AS (
  SELECT jsonb_object_agg(update_data.key, update_data.value) AS ind_cond_info
  FROM jsonb_each((SELECT ind_cond_info FROM mst_treatment_set WHERE treatment_set_cd in (SELECT treatment_set_cd FROM treatment_set_info ORDER BY is_ssi_order_treat_set_name, sort_order LIMIT 1))) AS update_data(key, value)
  -- WHERE update_data.key IN (''1'')
),
ind_cond_infos AS (
  SELECT jsonb_object_agg(
    base.key,
    CASE 
      WHEN update.value IS NOT NULL THEN jsonb_set(base.value, ''{value}'', update.value->''value'', true)
      ELSE base.value
    END
  ) as ind_cond_info
  FROM jsonb_each((SELECT ind_cond_info FROM base_json)) AS base(key, value)
  LEFT JOIN jsonb_each((SELECT ind_cond_info FROM default_set_json)) AS update(key, value) 
  ON base.key = update.key
)
SELECT
  ind_cond_infos.ind_cond_info
FROM
  ind_cond_infos', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのオーダ受け(INSERT)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -500011, "field_name": "ind_treatment_cd", "replace_var": "@indTreatmentCd"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500084, 'WITH ssi_order_treat_info AS ( 
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
treat_info AS ( 
SELECT
  device_mode AS device_mode
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
FROM treat_info
WHERE
  device_mode IN (7, 8)
  AND @indCondInfo.015.value <> @indCondInfo.019.value
  ;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのオンライン透析時、補液チェック(SELECT)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500085, '  SELECT
    COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS value
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
    AND is_disp = ''1'' 
    AND COALESCE(info->>''key0'','''') = @key0
    AND info->>''key1'' = ''SSI_ORDER_RECV''
    AND info->>''key2'' = ''DEFAULT_DOCTOR''', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのスタッフマスタ(SELECT)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500086, 'SELECT user_id
FROM ntss.mst_user_authentication
WHERE  disp_user_id = CASE 
    WHEN @chargeStaffInfo.staffCd = '''' THEN @defaultUpUserId 
    ELSE @chargeStaffInfo.staffCd 
    END
AND facility_cd = @facilityCd
', 1, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのスタッフマスタ(SELECT)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -500085, "field_name": "value", "replace_var": "@defaultUpUserId"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500087, 'SELECT
  mst_treatment_set.treatment_set_cd
FROM
  mst_treatment_set
WHERE
  facility_cd = @facilityCd
  AND is_del = ''0'' 
  AND is_disp = ''1'' ', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのオーダ受け(INSERT)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-501001, 'SELECT
    infection_cd AS infection_cd
FROM
    mst_infection
WHERE
    facility_cd = @facilityCd
    AND in_hospital_cd_1 = @infectInfo.Cd
    and is_del = ''0''
    and is_disp = ''1''', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの患者プロファイル_感染症マスタ取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-501002, 'INSERT INTO mst_infection( 
      facility_cd
  ,   fn_infection_cd
  ,   infection_name
  ,   standard_infection_cd
  ,   in_hospital_cd_1
  ,   is_disp
  ,   is_del
  ,   reg_date
  ,   up_date
) 
SELECT
      @facilityCd
  ,   NULL
  ,   @infectInfo.infectionName
  ,   NULL
  ,   @infectInfo.Cd
  ,   ''1''
  ,   ''0''
  ,   CURRENT_TIMESTAMP
  ,   CURRENT_TIMESTAMP
WHERE
@infectInfo.Cd <> ''''
;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの患者プロファイル_感染症マスタ登録', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-501003, '-- マスタに登録した内容をmst_selectorにも追加
WITH infect_info AS(
    SELECT
        infection_cd,
        infection_name
    FROM
        mst_infection
    WHERE
        facility_cd = ''@facilityCd''
    AND in_hospital_cd_1 = ''@infectInfo.Cd''
    AND is_del = ''0''
    AND is_disp = ''1''
    AND ''@infectInfo.Cd'' <> ''''
    ORDER BY infection_cd DESC
    LIMIT 1
)
UPDATE
  mst_selector
SET 
 order_settings = json_build_object
 (''items'',order_settings::jsonb->''items'' || json_build_array(
   json_build_object(
   ''code'', infection_cd, 
   ''name'', CAST(infection_name AS TEXT),
   ''isDel'', CAST(0 AS TEXT),
   ''isDisp'', CAST(1 AS TEXT),
   ''jlac10Cd'', CAST(NULL AS TEXT)
   ))::jsonb
 )::jsonb
 FROM infect_info
WHERE 
  mst_selector.facility_cd = ''@facilityCd''
AND
  master_physical_name = ''mst_infection''
;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの患者プロファイル_感染症マスタ登録(mst_selector)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -501002}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-501011, 'SELECT
    disease_cd AS disease_cd
FROM
    mst_disease
WHERE
    facility_cd = @facilityCd
    AND in_hospital_cd_1 = @medicalHstInfo.diseaseCd
    AND disease_name = @medicalHstInfo.diseaseName
    and is_del = ''0''
    and is_disp = ''1''', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの患者プロファイル_病名マスタ取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-501012, 'INSERT INTO mst_disease( 
      facility_cd
  ,   fn_disease_cd
  ,   disease_name
  ,   disease_short_name
  ,   standard_disease_cd
  ,   p_disease_biopsy_none_cd
  ,   p_disease_biopsy_exist_cd
  ,   die_confirmed_diagnosis_none_cd
  ,   die_confirmed_diagnosis_exist_cd
  ,   in_hospital_cd_1
  ,   is_disp
  ,   is_del
  ,   reg_date
  ,   up_date
  ,   fn_class_cd
) 
SELECT
      @facilityCd
  ,   NULL
  ,   @medicalHstInfo.diseaseName
  ,   NULL
  ,   NULL
  ,   NULL
  ,   NULL
  ,   NULL
  ,   NULL
  ,   @medicalHstInfo.diseaseCd
  ,   ''1''
  ,   ''0''
  ,   CURRENT_TIMESTAMP
  ,   CURRENT_TIMESTAMP
  ,   NULL
WHERE
@medicalHstInfo.diseaseCd <> ''''
;
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの患者プロファイル_病名マスタ登録', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-501013, '-- マスタに登録した内容をmst_selectorにも追加
WITH disease_info AS(
    SELECT
        disease_cd,
        disease_name
    FROM
        mst_disease
    WHERE
        facility_cd = ''@facilityCd''
    AND in_hospital_cd_1 = ''@medicalHstInfo.diseaseCd''
    AND is_del = ''0''
    AND is_disp = ''1''
    AND ''@medicalHstInfo.diseaseCd'' <> ''''
    ORDER BY disease_cd DESC
    LIMIT 1
)
UPDATE
  mst_selector
SET 
 order_settings = json_build_object
 (''items'',order_settings::jsonb->''items'' || json_build_array(
   json_build_object(
   ''code'', disease_cd, 
   ''name'', CAST(disease_name AS TEXT),
   ''isDel'', CAST(0 AS TEXT),
   ''isDisp'', CAST(1 AS TEXT),
   ''jlac10Cd'', CAST(NULL AS TEXT)
   ))::jsonb
 )::jsonb
 FROM disease_info
WHERE 
  mst_selector.facility_cd = ''@facilityCd''
AND
  master_physical_name = ''mst_disease''
;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの患者プロファイル_病名マスタ登録(mst_selector)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -501012}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-501021, 'SELECT
    ward_cd AS ward_cd
FROM
    mst_ward
WHERE
    facility_cd = @facilityCd
    AND in_hospital_cd_1 = @medicalCareInfo.wardCd
    and is_del = ''0''
    and is_disp = ''1''', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの患者プロファイル_病棟マスタ取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-501022, 'INSERT INTO mst_ward( 
      facility_cd
  ,   fn_ward_cd
  ,   ward_name
  ,   in_hospital_cd_1
  ,   is_disp
  ,   is_del
  ,   reg_date
  ,   up_date
) 
SELECT
     @facilityCd
  ,   NULL
  ,   @medicalCareInfo.wardName
  ,   @medicalCareInfo.wardCd
  ,   ''1''
  ,   ''0''
  ,   CURRENT_TIMESTAMP
  ,   CURRENT_TIMESTAMP
WHERE
@medicalCareInfo.wardCd NOT IN (''99'','''',''NoXmlTag'') -- 病棟コードが99の場合は登録しない
;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの患者プロファイル_病棟マスタ登録', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-501023, '-- マスタに登録した内容をmst_selectorにも追加
WITH ward_info AS(
    SELECT
        ward_cd,
        ward_name
    FROM
        mst_ward
    WHERE
        facility_cd = ''@facilityCd''
    AND in_hospital_cd_1 = ''@medicalCareInfo.wardCd''
    AND is_del = ''0''
    AND is_disp = ''1''
    AND ''@medicalCareInfo.wardCd'' NOT IN (''99'', '''') -- 病棟コードが99の場合は登録しない
    ORDER BY ward_cd DESC
    LIMIT 1
)
UPDATE
  mst_selector
SET 
 order_settings = json_build_object
 (''items'',order_settings::jsonb->''items'' || json_build_array(
   json_build_object(
   ''code'', ward_cd, 
   ''name'', CAST(ward_name AS TEXT),
   ''isDel'', CAST(0 AS TEXT),
   ''isDisp'', CAST(1 AS TEXT),
   ''jlac10Cd'', CAST(NULL AS TEXT)
   ))::jsonb
 )::jsonb
 FROM ward_info
WHERE 
  mst_selector.facility_cd = ''@facilityCd''
AND
  master_physical_name = ''mst_ward''
;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの患者プロファイル_病棟マスタ登録(mst_selector)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -501022}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-501031, 'SELECT
    course_cd AS course_cd
FROM
    mst_course
WHERE
    facility_cd = @facilityCd
    AND in_hospital_cd_1 = @medicalCareInfo.mainCourseCd
    and is_del = ''0''
    and is_disp = ''1''', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの患者プロファイル_診療科マスタ取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-501032, 'INSERT INTO mst_course( 
      facility_cd
  ,   fn_course_cd
  ,   course_name
  ,   standard_course_cd
  ,   in_hospital_cd_1
  ,   is_disp
  ,   is_del
  ,   reg_date
  ,   up_date
) 
SELECT
      ''@facilityCd''
  ,   NULL
  ,   ''@medicalCareInfo.CourseName''
  ,   NULL
  ,   ''@medicalCareInfo.mainCourseCd''
  ,   ''1''
  ,   ''0''
  ,   CURRENT_TIMESTAMP
  ,   CURRENT_TIMESTAMP
WHERE
@medicalCareInfo.mainCourseCd <> ''''
;
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの患者プロファイル_診療科マスタ登録', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-501033, '-- マスタに登録した内容をmst_selectorにも追加
WITH course_info AS(
    SELECT
        course_cd,
        course_name
    FROM
        mst_course
    WHERE
        facility_cd = ''@facilityCd''
    AND in_hospital_cd_1 = ''@medicalCareInfo.mainCourseCd''
    AND is_del = ''0''
    AND is_disp = ''1''
    AND ''@medicalCareInfo.mainCourseCd'' <> ''''
    ORDER BY course_cd DESC
    LIMIT 1
)
UPDATE
  mst_selector
SET 
 order_settings = json_build_object
 (''items'',order_settings::jsonb->''items'' || json_build_array(
   json_build_object(
   ''code'', course_cd, 
   ''name'', CAST(course_name AS TEXT),
   ''isDel'', CAST(0 AS TEXT),
   ''isDisp'', CAST(1 AS TEXT),
   ''jlac10Cd'', CAST(NULL AS TEXT)
   ))::jsonb
 )::jsonb
 FROM course_info
WHERE 
  mst_selector.facility_cd = ''@facilityCd''
AND
  master_physical_name = ''mst_course''
;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの患者プロファイル_診療科マスタ登録(mst_selector)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -501032}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-501041, 'SELECT 
  CASE WHEN @chargeStaffInfo.doctorCd = '''' THEN -2
    ELSE COALESCE((SELECT user_id FROM mst_user_authentication WHERE facility_cd = @facilityCd AND disp_user_id = @chargeStaffInfo.doctorCd), -1)
    END AS doctor_id,
  CASE WHEN @chargeStaffInfo.dialysisDoctorCd = '''' THEN -2
    ELSE COALESCE((SELECT user_id FROM mst_user_authentication WHERE facility_cd = @facilityCd AND disp_user_id = @chargeStaffInfo.dialysisDoctorCd), -1)
    END AS dialysis_doctor_id,
  CASE WHEN @chargeStaffInfo.dialysisNurseCd = '''' THEN -2
    ELSE COALESCE((SELECT user_id FROM mst_user_authentication WHERE facility_cd = @facilityCd AND disp_user_id = @chargeStaffInfo.dialysisNurseCd), -1)
    END AS dialysis_nurse_id,
  CASE WHEN @chargeStaffInfo.admissionDoctorCd = '''' THEN -2
    ELSE COALESCE((SELECT user_id FROM mst_user_authentication WHERE facility_cd = @facilityCd AND disp_user_id = @chargeStaffInfo.admissionDoctorCd), -1)
    END AS admission_doctor_id', 1, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの患者プロファイル_スタッフマスタ取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-501051, 'SELECT
  1 AS flg
WHERE
  NULLIF(@patLastName, '''') IS NULL
  AND NULLIF(@patFirstName, '''') IS NULL
  AND NULLIF(@patLastNmKana, '''') IS NULL
  AND NULLIF(@patFirstNmKana, '''') IS NULL', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの患者プロファイル_診療科マスタ登録', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-501061, 'SELECT
    disease_cd AS disease_cd
FROM
    mst_disease
WHERE
    facility_cd = @facilityCd
    AND in_hospital_cd_1 = @diseaseCode
    AND is_del = ''0''
    AND is_disp = ''1''
ORDER BY disease_cd DESC LIMIT 1', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの患者プロファイル_診療科マスタ登録', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-501071, 'SELECT
  info ->> ''value'' AS die_code
FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
WHERE
  facility_cd = @facilityCd
  AND is_del = ''0''
  AND info ->> ''key0'' = ''SSI''
  AND info ->> ''key1'' = ''SSI_PATIENT_RECV''
  AND info ->> ''key2'' = ''DIE_CODE''', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの患者プロファイル_診療科マスタ登録', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-501081, 'UPDATE pat_personal_main
SET
  is_die =
    CASE ''@tenki''
      WHEN ''@dieCode'' THEN ''1''
      WHEN ''NoXmlTag'' THEN is_die
      ELSE ''0'' END
  , die_cd =
    CASE ''@tenki''
      WHEN ''@dieCode'' THEN die_cd
      WHEN ''NoXmlTag'' THEN die_cd
      ELSE NULL END
  , die_date =
    CASE
      WHEN ''@tenki'' = ''@dieCode'' THEN
        CASE
          WHEN LENGTH(''@dieDate'') = 8 AND ''@dieDate'' ~ ''^[0-9]+$'' THEN TO_TIMESTAMP(''@dieDate'',''YYYYMMDD'')
          WHEN ''@dieDate'' = ''NoXmlTag'' THEN die_date
          ELSE NULL
        END
      WHEN ''@tenki'' = ''NoXmlTag'' AND is_die = ''1'' THEN
        CASE
          WHEN LENGTH(''@dieDate'') = 8 AND ''@dieDate'' ~ ''^[0-9]+$'' THEN TO_TIMESTAMP(''@dieDate'',''YYYYMMDD'')
          WHEN ''@dieDate'' = ''NoXmlTag'' THEN die_date
          ELSE NULL
        END
    END
  , up_date = CURRENT_TIMESTAMP
WHERE
  pat_id = @patId 
  AND facility_cd = ''@facilityCd'' 
  AND is_del = ''0''
', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの患者プロファイル_診療科マスタ登録', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -501071, "field_name": "die_code", "replace_var": "@dieCode"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-501091, 'WITH new_name_info AS ( 
  SELECT
    COALESCE(substring(''@patLastName'' ::TEXT from ''^(.*?)[\\\\u3000\\\\s]''), ''@patLastName'') AS patLastName
    , substring(''@patLastName'' ::TEXT from ''[\\\\u3000\\\\s](.*)'') AS patFirstName
    , COALESCE(substring(''@patLastNmKana'' ::TEXT from ''^(.*?)[\\\\u3000\\\\s]''), ''@patLastNmKana'') AS patLastNmKana
    , substring(''@patLastNmKana'' ::TEXT from ''[\\\\u3000\\\\s](.*)'') AS patFirstNmKana
) 
INSERT 
INTO pat_personal_main( 
  fn_pat_id
  , hosp_pat_id
  , nkk_pat_id
  , facility_cd
  , pat_last_name
  , pat_first_name
  , pat_last_name_kana
  , pat_first_name_kana
  , pat_last_name_alpha
  , pat_first_name_alpha
  , pat_birth_name
  , pat_birth_name_kana
  , pat_birth_name_alpha
  , pat_birthday
  , pat_sex
  , nationality
  , pat_blood_type_abo
  , pat_blood_type_rh
  , pat_blood_type_serovar
  , in_out_class
  , is_die
  , die_cd
  , die_date
  , dial_diff_com_info
  , severity_cd
  , transport_cd
  , pat_contact_info
  , other_contact_info
  , vendor_contact_info
  , insurance_info
  , is_del
  , up_date
  , reg_date
  , primary_disease_cd
  , remote_monitor_service
  , remote_monitor_user_id
  , remote_monitor_user_pw
) 
VALUES ( 
  NULLIF(''@fnPatId'', '''')
  , NULLIF(''@hospPatId'', '''')
  , NULLIF(''@nkkPatId'', '''')
  , NULLIF(''@facilityCd'', '''')
  , personal_info_encrypt((SELECT CASE WHEN NULLIF(''@patLastName'', '''') IS NULL THEN patLastNmKana ELSE patLastName END FROM new_name_info)) 
  , personal_info_encrypt((SELECT CASE WHEN NULLIF(''@patLastName'', '''') IS NULL THEN patFirstNmKana ELSE patFirstName END FROM new_name_info))
  , personal_info_encrypt((SELECT patLastNmKana FROM new_name_info))
  , personal_info_encrypt((SELECT patFirstNmKana FROM new_name_info))
  , NULLIF(''@patLastNmAlpha'', '''')
  , NULLIF(''@patFirstNmAlpha'', '''')
  , NULLIF(''@patBirthName'', '''')
  , NULLIF(''@patBirthNmKana'', '''')
  , NULLIF(''@patBirthNmAlpha'', '''')
  , CASE
    WHEN LENGTH(''@patBirthday'') = 8 AND ''@patBirthday'' ~ ''^[0-9]+$'' THEN ''@patBirthday''
    ELSE NULL
    END
  , CASE 
    WHEN ''@patSex'' IN (''1'',''2'') THEN TO_NUMBER(''@patSex'', ''FM9999999999999999'') 
    ELSE 0 
    END
  , NULLIF(''@nationality'', '''')
  , CASE ''@patBloodTypeAbo'' 
    WHEN '''' THEN 0 
    WHEN ''NoXmlTag'' THEN 0
    ELSE TO_NUMBER(''@patBloodTypeAbo'', ''FM9999999999999999'') 
    END
  , CASE ''@patBloodTypeRh'' 
    WHEN '''' THEN 0
    WHEN ''NoXmlTag'' THEN 0
    ELSE TO_NUMBER(''@patBloodTypeRh'', ''FM9999999999999999'') 
    END
  , CASE ''@patBloodTypeSerovar'' 
    WHEN '''' THEN 0 
    ELSE TO_NUMBER(''@patBloodTypeSerovar'', ''FM9999999999999999'') 
    END
  , CASE WHEN @inOut = 3 THEN 0
    ELSE @inOut
    END
  , NULLIF(''@isDie'', '''')
  ,  CASE ''@dieCd'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@dieCd'', ''FM99999999999999999999999999999999'') 
    END
  , CASE ''@dieDate_Date'' 
    WHEN '''' THEN NULL 
    ELSE TO_TIMESTAMP(''@dieDate_Date'', ''YYYY-MM-DD HH24:MI:SS'') 
    END
  , COALESCE(NULLIF(''@dialDiffComInfo'', ''''), ''[]'') ::JSONB
  , CASE ''@severityCd'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@severityCd'', ''FM99999999999999999999999999999999'') 
    END
  , CASE ''@transportCd'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@transportCd'', ''FM99999999999999999999999999999999'') 
    END
  , NULL
  , ''@otherContactInfoValue''
  , ''@vendorContactInfoValue''
  , ''@insuranceInfoValue''
  , ''0''
  , CURRENT_TIMESTAMP
  , CURRENT_TIMESTAMP
  , CASE ''@primaryDiseaseCd'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@primaryDiseaseCd'', ''FM99999999999999999999999999999999'') 
    END
  , CASE ''@remoteMonitorService'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@remoteMonitorService'', ''FM99999999999999999999999999999999'') 
    END
  , NULLIF(''@remoteMonitorUserId'', '''')
  , NULLIF(''@remoteMonitorUserPw'', '''')
)', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの患者個人情報の取得の新規', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": 1001, "field_name": "dial_diff_com_info", "replace_var": "@dialDiffComInfo"}, {"sql_cd": -501061, "field_name": "disease_cd", "replace_var": "@dieCd"}, {"sql_cd": -502000, "field_name": "in_out", "replace_var": "@inOut"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-501092, 'WITH new_name_info AS ( 
  SELECT
    COALESCE(substring(''@patLastName'' ::TEXT from ''^(.*?)[\\\\u3000\\\\s]''), ''@patLastName'') AS patLastName
    , substring(''@patLastName'' ::TEXT from ''[\\\\u3000\\\\s](.*)'') AS patFirstName
    , COALESCE(substring(''@patLastNmKana'' ::TEXT from ''^(.*?)[\\\\u3000\\\\s]''), ''@patLastNmKana'') AS patLastNmKana
    , substring(''@patLastNmKana'' ::TEXT from ''[\\\\u3000\\\\s](.*)'') AS patFirstNmKana
)
UPDATE pat_personal_main 
SET
  fn_pat_id = NULLIF(''@fnPatId'', '''')
  , hosp_pat_id = NULLIF(''@hospPatId'', '''')
  , nkk_pat_id = NULLIF(''@nkkPatId'', '''')
  , facility_cd = NULLIF(''@facilityCd'', '''')
  , pat_last_name = personal_info_encrypt((SELECT CASE WHEN NULLIF(''@patLastName'', '''') IS NULL THEN patLastNmKana ELSE patLastName END FROM new_name_info)) 
  , pat_first_name = personal_info_encrypt((SELECT CASE WHEN NULLIF(''@patLastName'', '''') IS NULL THEN patFirstNmKana ELSE patFirstName END FROM new_name_info))
  , pat_last_name_kana = personal_info_encrypt((SELECT patLastNmKana FROM new_name_info))
  , pat_first_name_kana = personal_info_encrypt((SELECT patFirstNmKana FROM new_name_info))
  , pat_birth_name = NULLIF(''@patBirthName'', '''')
  , pat_birth_name_kana = NULLIF(''@patBirthNmKana'', '''')
  , pat_birth_name_alpha = NULLIF(''@patBirthNmAlpha'', '''')
  , pat_birthday = CASE
    WHEN LENGTH(''@patBirthday'') = 8 AND ''@patBirthday'' ~ ''^[0-9]+$'' THEN ''@patBirthday''
    ELSE NULL
    END
  , pat_sex = CASE 
    WHEN ''@patSex'' IN (''1'',''2'') THEN TO_NUMBER(''@patSex'', ''FM9999999999999999'') 
    ELSE 0 
    END
  , nationality = NULLIF(''@nationality'', '''')
  , pat_blood_type_abo = CASE ''@patBloodTypeAbo'' 
    WHEN '''' THEN 0 
    WHEN ''NoXmlTag'' THEN pat_blood_type_abo
    ELSE TO_NUMBER(''@patBloodTypeAbo'', ''FM9999999999999999'') 
    END
  , pat_blood_type_rh = CASE ''@patBloodTypeRh'' 
    WHEN '''' THEN 0 
    WHEN ''NoXmlTag'' THEN pat_blood_type_rh
    ELSE TO_NUMBER(''@patBloodTypeRh'', ''FM9999999999999999'') 
    END
  , pat_blood_type_serovar = CASE ''@patBloodTypeSerovar'' 
    WHEN '''' THEN 0 
    ELSE TO_NUMBER(''@patBloodTypeSerovar'', ''FM9999999999999999'') 
    END
  , in_out_class = CASE WHEN @inOut = 3 THEN in_out_class
    ELSE @inOut
    END
  , is_die = NULLIF(''@isDie'', '''')
  , die_cd = CASE ''@dieCd''
    WHEN '''' THEN NULL
    WHEN ''NoXmlTag'' THEN die_cd
    ELSE TO_NUMBER(''@dieCd'', ''FM99999999999999999999999999999999'') 
    END
  , die_date = CASE ''@dieDate_Date'' 
    WHEN '''' THEN NULL 
    ELSE TO_TIMESTAMP(''@dieDate_Date'', ''YYYY-MM-DD HH24:MI:SS'') 
    END
  , dial_diff_com_info = ''@dialDiffComInfoValue''
  , severity_cd = CASE ''@severityCd'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER( ''@severityCd'', ''FM99999999999999999999999999999999'') 
    END
  , transport_cd = CASE ''@transportCd'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@transportCd'', ''FM99999999999999999999999999999999'') 
    END
  , pat_contact_info = personal_info_encrypt_jsonb(jsonb_build_object(
      ''zip_cd'',
      CASE
        WHEN ''@patContactInfo.zipCd'' = ''NoXmlTag'' THEN personal_info_decrypt_jsonb(pat_contact_info) ->> ''zip_cd''
        ELSE NULLIF(''@patContactInfo.zipCd'', '''')
        END,
      ''address'',
      CASE
        WHEN ''@patContactInfo.address'' = ''NoXmlTag'' THEN personal_info_decrypt_jsonb(pat_contact_info) ->> ''address''
        ELSE NULLIF((TRIM(TRIM(TRIM(''@patContactInfo.address'', ''　''), '' ''), ''　'')), '''')
        END,
      ''tel1'', 
      CASE
        WHEN ''@patContactInfo.tel1'' = ''NoXmlTag'' THEN personal_info_decrypt_jsonb(pat_contact_info) ->> ''tel1''
        ELSE NULLIF(''@patContactInfo.tel1'', '''')
        END,
      ''tel2'',         NULLIF(''@patContactInfo.tel2'', ''''),
      ''fax'',          NULLIF(''@patContactInfo.fax'', ''''),
      ''e_mail'',       NULLIF(''@patContactInfo.eMail'', ''''),
      ''work_name'',    NULLIF(''@patContactInfo.workName'', ''''),
      ''work_address'', NULLIF(''@patContactInfo.workAddress'', ''''),
      ''work_tel'',     NULLIF(''@patContactInfo.workTel'', ''''),
      ''memo1'',
      CASE
        WHEN ''@patContactInfo.memo1'' = ''NoXmlTag''
        THEN CONCAT(regexp_replace(personal_info_decrypt_jsonb(pat_contact_info) ->> ''memo1'', ''【転帰】.*'', ''''),
            CASE
              WHEN ''@isDie'' = ''0''  AND NULLIF(NULLIF(''@tenki'', ''''), ''NoXmlTag'') IS NOT NULL THEN ''【転帰】'' || ''@tenki''
              ELSE NULL
            END
          )
        ELSE CONCAT(regexp_replace(personal_info_decrypt_jsonb(pat_contact_info) ->> ''memo1'', ''【コメント】.*|【転帰】.*'', ''''),
          CASE
            WHEN NULLIF(''@patContactInfo.memo1'', '''') IS NULL THEN
              CASE
                WHEN ''@isDie'' = ''0''  AND NULLIF(NULLIF(''@tenki'', ''''), ''NoXmlTag'') IS NOT NULL THEN ''【転帰】'' || ''@tenki''
                ELSE NULL
              END
            ELSE ''【コメント】'' || ''@patContactInfo.memo1'' || 
              CASE
                WHEN ''@isDie'' = ''0'' AND NULLIF(NULLIF(''@tenki'', ''''), ''NoXmlTag'') IS NOT NULL THEN E''\\\\n''  || ''【転帰】'' || ''@tenki''
                ELSE ''''
              END
            END
            )
        END,
      ''memo2'',       NULLIF(''@patContactInfo.memo2'', '''')
    ) )
  , vendor_contact_info = ''@vendorContactInfoValue''
  , insurance_info = ''@insuranceInfoValue''
  , reg_date = ''@regDate''
  , up_date = CURRENT_TIMESTAMP
  , primary_disease_cd = CASE ''@primaryDiseaseCd'' 
    WHEN '''' THEN NULL 
    ELSE (CASE WHEN ''@upBaseDiseaseFlg'' = ''0'' THEN NULL ELSE TO_NUMBER(''@primaryDiseaseCd'', ''FM99999999999999999999999999999999'') END) 
    END
  , remote_monitor_service = CASE ''@remoteMonitorService'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@remoteMonitorService'', ''FM99999999999999999999999999999999'') 
    END
  , remote_monitor_user_id = NULLIF(''@remoteMonitorUserId'', '''')
  , remote_monitor_user_pw = NULLIF(''@remoteMonitorUserPw'', '''') 
WHERE
  is_del = ''0'' 
  AND hosp_pat_id = ''@hospPatId''  
  AND facility_cd = ''@facilityCd''', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの患者個人情報の取得の修正', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": 1009, "field_name": "up_base_disease_flg", "replace_var": "@upBaseDiseaseFlg"}, {"sql_cd": -501061, "field_name": "disease_cd", "replace_var": "@dieCd"}, {"sql_cd": -502000, "field_name": "in_out", "replace_var": "@inOut"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-501093, 'WITH take_cource_info AS ( 
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''1'') 
      ELSE TRIM(ini_info ->> ''value'') 
      END AS take_cource_flg 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.is_disp = ''1''
    AND ini.facility_cd = ''@facilityCd'' 
    AND COALESCE(ini_info ->> ''key0'','''') = ''@key0''
    AND TRIM(ini_info ->> ''key1'') = ''PATIENT_SEND'' 
    AND TRIM(ini_info ->> ''key2'') = ''IS_TAKE_COURCE_FLG'' 
  UNION 
  SELECT
    2 AS order_no
    , ''1'' AS take_cource_flg 
  ORDER BY order_no ASC LIMIT 1
)
, mst_ward_cd AS (
  SELECT
    ward_cd
  FROM
    mst_ward
  WHERE
    in_hospital_cd_1 = ''@medicalCareInfo.wardCd'' :: TEXT
    AND facility_cd = ''@facilityCd''
    AND is_disp = ''1''
    AND is_del = ''0''
    AND ''@medicalCareInfo.wardCd'' :: TEXT != ''99''
    AND ''@medicalCareInfo.wardCd'' :: TEXT != ''''
)
, mst_course_cd AS (
  SELECT 
    course_cd
  FROM
    mst_course
  WHERE
    in_hospital_cd_1 = ''@medicalCareInfo.mainCourseCd''
    AND facility_cd = ''@facilityCd''
    AND is_disp = ''1''
    AND is_del = ''0''
)
, cource_ward_info AS (
  SELECT 
    CASE WHEN (SELECT take_cource_flg FROM take_cource_info) = ''1'' AND (''@inOutClass'') = ''1'' -- ''1''：入院
      THEN (SELECT course_cd FROM mst_course_cd)
      ELSE null
    END AS main_course_cd
    , CASE WHEN (SELECT take_cource_flg FROM take_cource_info) = ''1'' AND (''@inOutClass'') = ''1'' -- ''1''：入院
      THEN (SELECT ward_cd FROM mst_ward_cd)
      ELSE null
    END  AS ward_cd
)
INSERT 
INTO pat_main( 
  pat_id
  , facility_cd
  , is_same
  , is_implant
  , is_infect
  , is_diabetes
  , is_blood_suger_exam
  , in_out_current_state
  , in_out_plan_state
  , in_out_plan_date
  , pat_memo_info
  , addition_info
  , charge_staff_info
  , pat_group_info
  , taboo_allergy_info
  , infect_info
  , implant_info
  , tare_info
  , off_water_info
  , device_set_info
  , acceptance_status_info
  , is_del
  , up_date
  , reg_date
  , is_wheel_chair
  , medical_care_info
  , sch_ext_end_date
  , sch_ext_status
  , card_idm
  , old_up_date
  , host_notification_info
) 
VALUES ( 
  @patId
  , ''@facilityCd''
  , NULLIF(''@isSame'', '''')
  , NULLIF(''@isImplant'', '''')
  , NULLIF(''@isInfect'', '''')
  , NULLIF(''@isDiabetes'', '''')
  , NULLIF(''@isBloodSugerExam'', '''')
  , NULLIF(''@inOutCurrentState'', '''')
  , NULLIF(''@inOutPlanState'', '''')
  , CASE ''@inOutPlanDate_Date'' 
    WHEN '''' THEN NULL 
    ELSE to_timestamp(''@inOutPlanDate_Date'', ''yyyy-MM-dd hh24:mi:ss'') 
    END
  , COALESCE(NULLIF(''@patMemoInfo'', ''''), ''[]'') ::JSONB
  , COALESCE(NULLIF(''@additioninfo'', ''''), ''[]'') ::JSONB
  , ''@chargeStaffInfoValue''
  , ''@patGroupInfoValue''
  , ''@tabooAllergyInfoValue''
  , ''[]'' ::JSONB
  , ''@implantInfoValue''
  , ''@tareInfoValue''
  , ''@offWaterInfoValue''
  , ''@deviceSetInfoValue''
  , ''@acceptanceStatusInfoValue''
  , ''0''
  , CURRENT_TIMESTAMP
  , CURRENT_TIMESTAMP
  , NULLIF(''@isWheelChair'', '''')
  , json_build_object( 
      ''main_course_cd''
      , (SELECT main_course_cd FROM cource_ward_info)
      , ''dialysis_course_cd''
      , TO_NUMBER(NULLIF(''@medicalCareInfo.dialysisCourseCd'', ''''), ''FM999999999'')
      , ''ward_cd''
      , (SELECT ward_cd FROM cource_ward_info)
      , ''dialysis_count''
      , TO_NUMBER(NULLIF(''@medicalCareInfo.dialysisCount'', ''''), ''FM999999999'')
      , ''purification_count''
      , TO_NUMBER(NULLIF(''@medicalCareInfo.purificationCount'', ''''), ''FM999999999'')
      , ''other_dialysis_count''
      , TO_NUMBER(NULLIF(''@medicalCareInfo.otherDialysisCount'', ''''), ''FM999999999'')
      , ''pat_dialysis_count''
      , TO_NUMBER(NULLIF(''@medicalCareInfo.patDialysisCount'', ''''), ''FM999999999'')
      , ''facility_cd''
      , NULLIF(''@medicalCareInfo.facilityCd'', '''')
      , ''dialysis_start_date''
      , CASE
          WHEN LENGTH(''@medicalCareInfo.dialysisStartDate'') = 8 AND ''@medicalCareInfo.dialysisStartDate'' ~ ''^[0-9]+$'' THEN (''@medicalCareInfo.dialysisStartDate'')
          ELSE NULL
        END
      , ''hospital_start_date''
      , NULLIF(''@medicalCareInfo.hospitalStartDate'', '''')
    )
  , NULLIF(''@schExtEndDate'', '''')
  , NULLIF(''@schExtStatus'', '''')
  , NULLIF(''@cardIdm'', '''')
  , CASE ''@oldUpDate_Date'' 
    WHEN '''' THEN NULL 
    ELSE to_timestamp(''@oldUpDate_Date'', ''yyyy-MM-dd hh24:mi:ss'') 
    END
  , NULL
)', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの患者プロファイル_患者基本情報の新規', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": 1002, "field_name": "pat_memo_info", "replace_var": "@patMemoInfo"}, {"sql_cd": 1004, "field_name": "addition_info", "replace_var": "@additioninfo"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-501094, 'WITH take_cource_info AS ( 
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''1'') 
      ELSE TRIM(ini_info ->> ''value'') 
      END AS take_cource_flg 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.is_disp = ''1''
    AND ini.facility_cd = ''@facilityCd'' 
    AND COALESCE(ini_info ->> ''key0'','''') = ''@key0''
    AND TRIM(ini_info ->> ''key1'') = ''PATIENT_SEND'' 
    AND TRIM(ini_info ->> ''key2'') = ''IS_TAKE_COURCE_FLG'' 
  UNION 
  SELECT
    2 AS order_no
    , ''1'' AS take_cource_flg 
  ORDER BY order_no ASC LIMIT 1
)
, mst_ward_cd AS (
  SELECT
    ward_cd
  FROM
    mst_ward
  WHERE
    in_hospital_cd_1 = ''@medicalCareInfo.wardCd'' :: TEXT
    AND facility_cd = ''@facilityCd''
    AND is_disp = ''1''
    AND is_del = ''0''
)
, mst_course_cd AS (
  SELECT
    course_cd
  FROM
    mst_course
  WHERE
    in_hospital_cd_1 = ''@medicalCareInfo.mainCourseCd''
    AND facility_cd = ''@facilityCd''
    AND is_disp = ''1''
    AND is_del = ''0''
)
, before_medical_care_info AS (
  SELECT
  (medical_care_info ->> ''main_course_cd'') ::int AS main_course_cd
  , (medical_care_info ->> ''ward_cd'') ::int AS ward_cd
  FROM pat_main
  WHERE
    is_del = ''0''
    AND pat_id = @patId
)
, cource_ward_info AS (
  SELECT
    CASE WHEN (SELECT take_cource_flg FROM take_cource_info) = ''1''
      AND ''1'' =
        CASE WHEN ''@inOutClass'' = ''1'' THEN ''1''
          WHEN ''@inOutClass'' = ''NoXmlTag'' THEN ''@ppmInOutClass''
          ELSE ''0''
        END -- ''1''：入院
      THEN
        CASE WHEN ''@medicalCareInfo.mainCourseCd'' = ''NoXmlTag'' THEN (SELECT main_course_cd FROM before_medical_care_info)
        ELSE (SELECT course_cd FROM mst_course_cd)
        END
      ELSE NULL
    END AS main_course_cd
    , CASE WHEN (SELECT take_cource_flg FROM take_cource_info) = ''1''
      AND ''1'' =
        CASE WHEN ''@inOutClass'' = ''1'' THEN ''1''
          WHEN ''@inOutClass'' = ''NoXmlTag'' THEN ''@ppmInOutClass''
          ELSE ''0''
        END -- ''1''：入院
      THEN
        CASE WHEN ''@medicalCareInfo.wardCd'' = ''NoXmlTag'' THEN (SELECT ward_cd FROM before_medical_care_info)
        ELSE (SELECT ward_cd FROM mst_ward_cd)
        END
      ELSE NULL
    END  AS ward_cd
)
UPDATE pat_main
SET up_date              = CURRENT_TIMESTAMP
  , in_out_current_state = (case ''@isDie'' when ''1'' then ''11'' else in_out_current_state end)
  , medical_care_info    = json_build_object(
        ''main_course_cd''
    , (SELECT main_course_cd FROM cource_ward_info)
    , ''dialysis_course_cd''
    , medical_care_info -> ''dialysis_course_cd''
    , ''ward_cd''
    , (SELECT ward_cd FROM cource_ward_info)
    , ''dialysis_count''
    , medical_care_info -> ''dialysis_count''
    , ''purification_count''
    , medical_care_info -> ''purification_count''
    , ''other_dialysis_count''
    , medical_care_info -> ''other_dialysis_count''
    , ''pat_dialysis_count''
    , medical_care_info -> ''pat_dialysis_count''
    , ''facility_cd''
    , medical_care_info ->> ''facility_cd''
    , ''dialysis_start_date''
    , CASE
          WHEN LENGTH(''@medicalCareInfo.dialysisStartDate'') = 8 AND ''@medicalCareInfo.dialysisStartDate'' ~ ''^[0-9]+$'' THEN (''@medicalCareInfo.dialysisStartDate'')
          WHEN ''@medicalCareInfo.dialysisStartDate'' = ''NoXmlTag'' THEN medical_care_info ->> ''dialysis_start_date''
          ELSE NULL
      END
    , ''hospital_start_date''
    , medical_care_info ->> ''hospital_start_date''
    )
WHERE is_del = ''0''
  AND pat_id = @patId', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの患者プロファイル_患者基本情報の修正', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -100001, "field_name": "in_out_class", "replace_var": "@ppmInOutClass"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-501095, 'insert into pat_insurance (
  pat_id,
  facility_cd,
  ctl_no,
  fn_pat_id,
  insu_class,
  insu_name,
  insu_name_short,
  insu_info,
  insu_pub_info,
  insu_set_info,
  insu_self_info,
  is_selected,
  is_disp,
  is_del,
  coop_code,
  is_coop,
  reg_date,
  up_date,
  start_date,
  end_date,
  check_date,
  old_up_date
  )
VALUES
(
  @patId,
  ''@facilityCd'',
  case ''@ctlNo''
    when '''' then null
    else to_number(''@ctlNo'',''99999999999999999999999999999999'')
  end,
  NULL,
  0,
  ''外部連携登録'',
  NULL,
  json_build_object(
    ''insu_pat_name'',
    NULL,
    ''insu_no'',
    personal_info_encrypt(
        NULLIF(NULLIF(''@insuInfo.insuNo'', ''''), ''NoXmlTag'')
    ),
    ''insu_kbn'',
    CASE 
        WHEN ''@insuInfo.insuKbn'' = ''0'' THEN ''0''
        ELSE ''1''
    END,
    ''insu_pat_mark'',
    personal_info_encrypt(
        NULLIF(NULLIF(''@insuInfo.insuPatMark'', ''''), ''NoXmlTag'')
    ),
    ''insu_pat_no'',
    personal_info_encrypt(
        NULLIF(NULLIF(''@insuInfo.insuPatNo'', ''''), ''NoXmlTag'')
    ),
    ''cki_class'',
    ''0'',
    ''kki_class'',
    ''0'',
    ''und_six'',
    ''0'',
    ''futan-g'',
    NULL,
    ''futan-n'',
    NULL
),
  NULL,
  NULL,
  null,
  ''0'',
  ''1'',
  ''0'',
  NULLIF(''@coopCode'',''''),
  ''1'',
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP,
  NULLIF(''@startDate'',''''),
  NULLIF(''@endDate'',''''),
  NULL,
  NULL
)', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの患者プロファイル', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-501096, 'update pat_insurance set
insu_info = jsonb_set(jsonb_set(jsonb_set(jsonb_set(
    insu_info,
    ''{insu_kbn}'',
        CASE
            WHEN ''@insuInfo.insuKbn'' = ''0'' THEN ''"0"''
            WHEN ''@insuInfo.insuKbn'' = ''NoXmlTag'' THEN insu_info->''insu_kbn''
            ELSE ''"1"'' END::jsonb
    ),
    ''{insu_no}'',
            CASE
                WHEN ''@insuInfo.insuNo'' = '''' THEN ''null''
                WHEN ''@insuInfo.insuNo'' = ''NoXmlTag'' THEN insu_info->''insu_no''
                ELSE (''"'' || personal_info_encrypt(''@insuInfo.insuNo'') || ''"'')::jsonb
            END
    ),
    ''{insu_pat_mark}'',
            CASE
                WHEN ''@insuInfo.insuPatMark'' = '''' THEN insu_info->''insu_pat_mark''
                WHEN ''@insuInfo.insuPatMark'' = ''NoXmlTag'' THEN insu_info->''insu_pat_mark''
                ELSE to_jsonb(personal_info_encrypt(''@insuInfo.insuPatMark''))
            END
    ),
    ''{insu_pat_no}'',
            CASE
            WHEN ''@insuInfo.insuPatNo'' = '''' THEN insu_info->''insu_pat_no''
            WHEN ''@insuInfo.insuPatNo'' = ''NoXmlTag'' THEN insu_info->''insu_pat_no''
            ELSE to_jsonb(personal_info_encrypt(''@insuInfo.insuPatNo''))
        END
),
    up_date = CURRENT_TIMESTAMP
where
  pat_id = @patId
and
  facility_cd = ''@facilityCd''
and
  is_del = ''0''
and
  ctl_no = @ctlNo', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの患者プロファイル', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-501097, 'WITH doctor_cd1_mode AS (
  SELECT
    COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS VALUE
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
  WHERE
    facility_cd = ''@facilityCd''
    AND is_del = ''0''
    AND is_disp = ''1''
    AND COALESCE(info->>''key0'', '''') = ''@key0''
    AND info->>''key1'' = ''SSI_PATIENT_RECV''
    AND info->>''key2'' = ''DOCTOR_CD1_MODE''
),
doctor_cd2_mode AS (
  SELECT
    COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS VALUE
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
  WHERE
    facility_cd = ''@facilityCd''
    AND is_del = ''0''
    AND is_disp = ''1''
    AND COALESCE(info->>''key0'', '''') = ''@key0''
    AND info->>''key1'' = ''SSI_PATIENT_RECV''
    AND info->>''key2'' = ''DOCTOR_CD2_MODE''
),
before_staff AS (
  SELECT 
    (info -> ''ctl_no'')::int AS ctl_no
    , (info ->> ''staff_cd'')::int AS staff_cd
  FROM pat_main
  CROSS JOIN LATERAL jsonb_array_elements(charge_staff_info) info
  WHERE
    is_del =''0''
    AND facility_cd = ''@facilityCd''
    AND pat_id = @patId
),
computed_ctl_no AS (
  SELECT
    ctl_no,
    staff_cd,
    is_main,
    is_charge
  FROM 
    (
      (
        SELECT
        1 AS ctl_no,
        CASE (SELECT value FROM doctor_cd1_mode)
        WHEN ''0'' THEN
          COALESCE(NULLIF(@chargeStaffInfo.doctorId, -1)
            , NULLIF(@chargeStaffInfo.admissionDoctorId, -1)
            , (SELECT staff_cd FROM before_staff WHERE ctl_no = 1))
        WHEN ''1'' THEN
          COALESCE(NULLIF(@chargeStaffInfo.dialysisDoctorId, -1)
            , (SELECT staff_cd FROM before_staff WHERE ctl_no = 1))
        ELSE (SELECT staff_cd FROM before_staff WHERE ctl_no = 1)
        END AS staff_cd,
        ''1'' AS is_main,
        ''0'' AS is_charge
      )
      UNION
      (
        SELECT
        2 AS ctl_no,
        CASE (SELECT value FROM doctor_cd2_mode)
        WHEN ''0'' THEN
          COALESCE(NULLIF(@chargeStaffInfo.doctorId, -1)
            , NULLIF(@chargeStaffInfo.admissionDoctorId, -1)
            , (SELECT staff_cd FROM before_staff WHERE ctl_no = 2))
        WHEN ''1'' THEN
          COALESCE(NULLIF(@chargeStaffInfo.dialysisDoctorId, -1)
            , (SELECT staff_cd FROM before_staff WHERE ctl_no = 2))
        ELSE (SELECT staff_cd FROM before_staff WHERE ctl_no = 2)
        END AS staff_cd,
        ''1'' AS is_main,
        ''0'' AS is_charge
      )
      UNION
      (
        SELECT
        3 AS ctl_no,
        COALESCE(NULLIF(@chargeStaffInfo.dialysisNurseId, -1)
          , (SELECT staff_cd FROM before_staff WHERE ctl_no = 3)) AS staff_cd,
        ''0'' AS is_main,
        ''1'' AS is_charge
      )
    ) AS T1
  WHERE staff_cd <> -2
    AND staff_cd IS NOT NULL
  ORDER BY ctl_no ASC
)
UPDATE pat_main
SET charge_staff_info = (
  SELECT COALESCE(jsonb_agg(jsonb_build_object(
            ''ctl_no'', ctl_no,
            ''is_main'', is_main,
            ''staff_cd'', staff_cd,
            ''is_charge'', is_charge,
            ''disp_order'', ctl_no,
            ''is_puncture'', ''0''
            )
          ), ''[]''::jsonb)
  FROM computed_ctl_no
)
WHERE
  is_del = ''0''
  AND pat_id = @patId
  AND facility_cd = ''@facilityCd''
;
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの患者プロファイル(担当スタッフ情報)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -501041, "field_name": "doctor_id", "replace_var": "@chargeStaffInfo.doctorId"}, {"sql_cd": -501041, "field_name": "dialysis_doctor_id", "replace_var": "@chargeStaffInfo.dialysisDoctorId"}, {"sql_cd": -501041, "field_name": "dialysis_nurse_id", "replace_var": "@chargeStaffInfo.dialysisNurseId"}, {"sql_cd": -501041, "field_name": "admission_doctor_id", "replace_var": "@chargeStaffInfo.admissionDoctorId"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-501098, 'WITH allergyInfo AS (
    SELECT 
        a.taboo_allergy_info,
        (idx - 1) AS idx,
        CASE 
            WHEN ms->>''content'' = ''@tabooAllergyInfo.content'' AND ''@tabooAllergyInfo.memo'' <> ''''
            THEN ms->>''memo'' || E''\\\\n'' || ''@tabooAllergyInfo.memo''
            ELSE ms->>''memo''
        END as memo,
        ms->>''ctl_no'' as ctl_no,
        ms->>''content'' as content,
        ms->>''disp_order'' as disp_order,
        ms->>''category_class'' as category_class,
        ms->>''taboo_allergy_cd'' as taboo_allergy_cd,
        ms->>''taboo_allergy_class'' as taboo_allergy_class
    FROM pat_main AS a
    CROSS JOIN LATERAL jsonb_array_elements(a.taboo_allergy_info::jsonb) 
    WITH ORDINALITY AS info(ms, idx)
    WHERE a.is_del = ''0''
    AND a.pat_id = @patId
    AND a.facility_cd = ''@facilityCd''
)
UPDATE pat_main 
SET taboo_allergy_info = 
    CASE 
        WHEN ''@tabooAllergyInfoFlg'' = '''' THEN ''@tabooAllergyInfoValue''::jsonb
        WHEN EXISTS (
            SELECT 1 
            FROM allergyInfo 
            WHERE content = ''@tabooAllergyInfo.content''
        ) THEN (
            SELECT jsonb_agg(
                jsonb_build_object(
                        ''memo'', memo,
                        ''ctl_no'', ctl_no :: int,
                        ''content'', content,
                        ''disp_order'', disp_order :: int,
                        ''category_class'', category_class,
                        ''taboo_allergy_cd'', taboo_allergy_cd,
                        ''taboo_allergy_class'', taboo_allergy_class
                    )
            )
            FROM allergyInfo
        )
        ELSE 
            COALESCE(taboo_allergy_info, ''[]''::jsonb) || jsonb_build_object(
                ''ctl_no'', @nextCtlNo3 :: int,
                ''disp_order'', @nextCtlNo3 :: int,
                ''taboo_allergy_cd'', NULL,
                ''content'', ''@tabooAllergyInfo.content'',
                ''memo'', ''@tabooAllergyInfo.memo'',
                ''category_class'', ''5'',
                ''taboo_allergy_class'', ''1''
            )::jsonb
    END
WHERE is_del = ''0''
AND pat_id = @patId
AND facility_cd = ''@facilityCd''
AND ''@tabooAllergyInfo.status'' IN (''2'', '''');', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの患者プロファイル(禁忌・アレルギー情報)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -502002, "field_name": "taboo_allergy_cd", "replace_var": "@tabooAllergyInfo.tabooAllergyCd"}, {"sql_cd": -502002, "field_name": "content", "replace_var": "@tabooAllergyInfo.content"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-501099, 'UPDATE pat_main
  SET
    infect_info = COALESCE(infect_info, ''[]'')::jsonb ||
      jsonb_build_object(
        ''infect''
          , CASE ''@infectInfo.infect''
              WHEN ''''     THEN ''0''
              WHEN ''不明'' THEN ''0''
              ELSE ''@infectInfo.infect''
            END
        ,''up_date''
          , TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDD'')
        ,''exam_date''
          , CASE
              WHEN LENGTH(''@infectInfo.examDate'') = 8
                   AND ''@infectInfo.examDate'' ~ ''^[0-9]+$''
              THEN ''@infectInfo.examDate''
              ELSE NULL
            END
        ,''infection_cd''
          , CASE WHEN ''@infectInfo.infectionCd'' <> '''' THEN TO_NUMBER(''@infectInfo.infectionCd'',''FM999999'') END
      )
    , up_date = CURRENT_TIMESTAMP
WHERE
      pat_main.is_del      = ''0''
  AND pat_main.facility_cd = ''@facilityCd''
  AND pat_main.pat_id      = @patId
  AND ''@infectInfo.infectionCd'' <> '''' 
  AND ''@infectInfo.infectionCd'' <> ''NoXmlTag'' 
  AND ''@infectInfo.infect'' <> ''NoXmlTag'';', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの患者プロファイル(感染症情報)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -501001, "field_name": "infection_cd", "replace_var": "@infectInfo.infectionCd"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-501100, 'WITH diseaseInfo AS(
SELECT
    disease_cd AS diseaseCd
FROM
    mst_disease
WHERE
    facility_cd = ''@facilityCd''
    AND in_hospital_cd_1 = ''@diseaseCode''
    AND is_del = ''0''
    AND is_disp = ''1''
ORDER BY disease_cd DESC LIMIT 1
),
dieInfo AS(
SELECT
    disease_cd AS dieCd
FROM
    mst_disease
WHERE
    facility_cd = ''@facilityCd''
    AND in_hospital_cd_1 = ''@dieCode''
    AND is_del = ''0''
    AND is_disp = ''1''
ORDER BY disease_cd DESC LIMIT 1
),
isDie AS (SELECT
  CASE 
    WHEN info ->> ''value'' = ''@tenki'' THEN ''1''
    WHEN ''@tenki'' = ''NoXmlTag'' THEN ''@isDie''
    ELSE ''''
  END AS is_die
FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
WHERE
  facility_cd = ''@facilityCd''
  AND is_del = ''0''
  AND info ->> ''key0'' = ''@key0''
  AND info ->> ''key1'' = ''SSI_PATIENT_RECV''
  AND info ->> ''key2'' = ''DIE_CODE''),
outComeInfo AS(
  SELECT
    CASE
      WHEN (SELECT is_die FROM isDie) = ''1'' THEN ''10''
      ELSE ''0''
    END AS outCome
),
validDate AS(
  SELECT
    CASE 
       WHEN NULLIF(''@medicalHstInfo.outComeDate'','''') IS NULL THEN NULL
       WHEN ''@medicalHstInfo.outComeDate'' ~ ''^(19|20)\\\\d{2}(0[1-9]|1[0-2])(0[1-9]|[12]\\\\d|3[01])$'' 
            AND (
                 (''@medicalHstInfo.outComeDate'' ~ ''^(19|20)\\\\d{2}02(29)$'' AND SUBSTRING(''@medicalHstInfo.outComeDate'', 1, 4)::int % 4 = 0 AND (SUBSTRING(''@medicalHstInfo.outComeDate'', 1, 4)::int % 100 != 0 OR SUBSTRING(''@medicalHstInfo.outComeDate'', 1, 4)::int % 400 = 0))
                 OR (''@medicalHstInfo.outComeDate'' ~ ''^(19|20)\\\\d{2}(0[13578]|1[02])(0[1-9]|[12]\\\\d|3[01])$'')
                 OR (''@medicalHstInfo.outComeDate'' ~ ''^(19|20)\\\\d{2}(0[469]|11)(0[1-9]|[12]\\\\d|30)$'')
                 OR (''@medicalHstInfo.outComeDate'' ~ ''^(19|20)\\\\d{2}02(0[1-9]|1\\\\d|2[0-8])$'')
            )
       THEN ''@medicalHstInfo.outComeDate''
       ELSE NULL
     END AS outComeDate,
     CASE 
        WHEN NULLIF(''@medicalHstInfo.diseaseDate'','''') IS NULL THEN NULL
        WHEN ''@medicalHstInfo.diseaseDate'' ~ ''^(19|20)\\\\d{2}(0[1-9]|1[0-2])(0[1-9]|[12]\\\\d|3[01])$'' 
            AND (
                 (''@medicalHstInfo.diseaseDate'' ~ ''^(19|20)\\\\d{2}02(29)$'' AND SUBSTRING(''@medicalHstInfo.diseaseDate'', 1, 4)::int % 4 = 0 AND (SUBSTRING(''@medicalHstInfo.diseaseDate'', 1, 4)::int % 100 != 0 OR SUBSTRING(''@medicalHstInfo.diseaseDate'', 1, 4)::int % 400 = 0))
                 OR (''@medicalHstInfo.diseaseDate'' ~ ''^(19|20)\\\\d{2}(0[13578]|1[02])(0[1-9]|[12]\\\\d|3[01])$'')
                 OR (''@medicalHstInfo.diseaseDate'' ~ ''^(19|20)\\\\d{2}(0[469]|11)(0[1-9]|[12]\\\\d|30)$'')
                 OR (''@medicalHstInfo.diseaseDate'' ~ ''^(19|20)\\\\d{2}02(0[1-9]|1\\\\d|2[0-8])$'')
            )
        THEN ''@medicalHstInfo.diseaseDate''
        ELSE NULL
     END AS diseaseDate
),
dateInfo AS(
  SELECT
    CASE
      WHEN (SELECT is_die FROM isDie) = ''1'' THEN (SELECT outComeDate FROM validDate)
      ELSE ''''
    END AS dieDate,
    CASE
      WHEN (SELECT is_die FROM isDie) = ''1'' THEN (SELECT outComeDate FROM validDate)
      ELSE to_char(CURRENT_TIMESTAMP, ''YYYYMMDD'')
    END AS inOutDate
),
medi_data_exists_info AS(
SELECT CASE WHEN EXISTS (
      SELECT 1
      FROM jsonb_array_elements(medical_hst_info) AS elem
      WHERE COALESCE((elem->>''disease_cd'')::int, -1) = CASE
        WHEN (SELECT is_die FROM isDie) = ''1'' THEN COALESCE((SELECT dieCd FROM dieInfo), -1)
        ELSE (SELECT diseaseCd FROM diseaseInfo)
      END
      AND CASE WHEN (SELECT diseaseDate FROM validDate) IS NULL THEN true
        ELSE elem->>''disease_date'' = (SELECT diseaseDate FROM validDate)
        END
      AND elem->>''out_come'' = (SELECT outCome FROM outComeInfo)
    )
    THEN ''1''
    ELSE ''0''
    END exists_flag
FROM pat_unique
WHERE
  pat_id = @patId
AND facility_cd = ''@facilityCd''
AND is_del = ''0''
),
in_out_class AS(
  SELECT
    (
      CASE
        WHEN  (SELECT is_die FROM isDie) = ''1'' THEN ''2''
        WHEN info ->> ''value'' = ''@inOutClass'' THEN ''1''
        WHEN ''@inOutClass'' = ''NoXmlTag'' THEN ''@ppmInOutClass''
        ELSE ''0''
      END
    ) AS in_out
FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
WHERE
  facility_cd = ''@facilityCd''
  AND is_del = ''0''
  AND info ->> ''key0'' = ''@key0''
  AND info ->> ''key1'' = ''SSI_PATIENT_RECV''
  AND info ->> ''key2'' = ''CONV_INOUT_1''
),
in_out_ctl_no_calc AS(
  SELECT
    COUNT(1) + 1 AS ctl_no
  FROM
    pat_unique
    CROSS JOIN
      jsonb_array_elements(pat_unique.in_out_visit_history_info) AS data_calc
  WHERE
    pat_unique.pat_id = @patId
  AND facility_cd = ''@facilityCd''
  AND is_del = ''0''
  GROUP BY
    pat_unique.pat_id
),
data_new_info AS(
  SELECT
    COALESCE(ctl_no, 1) AS ctl_no,
    in_out AS in_out,
    NULL AS reason,
    NULL AS to_course,
    NULL AS to_doctor,
    0 AS disp_order,
    NULL AS period_end,
    ''@facilityCd'' AS facility_cd,
    NULL AS from_course,
    NULL AS from_doctor,
    (CASE in_out WHEN ''0'' THEN ''6'' WHEN ''1'' THEN ''4'' WHEN ''2'' THEN ''11'' ELSE ''6'' END)::TEXT AS move_in_out,
    NULL AS to_facility,
    (SELECT inOutDate FROM dateInfo) AS period_start,
    NULL AS from_facility,
    ''0'' AS course_is_free,
    ''0'' AS doctor_is_free,
    NULL AS period_end_day,
    NULL AS period_end_year,
    ''0'' AS facility_is_free,
    NULL AS period_end_month,
    CASE WHEN (SELECT inOutDate FROM dateInfo) IS NULL
THEN NULL
ELSE SUBSTR((SELECT inOutDate FROM dateInfo), 7, 2) END AS period_start_day,
    (SELECT inOutDate FROM dateInfo) AS period_start_date,
    CASE WHEN (SELECT inOutDate FROM dateInfo) IS NULL
THEN NULL
ELSE SUBSTR((SELECT inOutDate FROM dateInfo), 1, 4) END AS period_start_year,
    CASE WHEN (SELECT inOutDate FROM dateInfo) IS NULL
THEN NULL
ELSE SUBSTR((SELECT inOutDate FROM dateInfo), 5, 2) END AS period_start_month,
    ''0'' AS period_end_input_free,
    ''0'' AS period_start_input_free,
    NULL AS to_medicalInstitutionCd,
    NULL AS from_medicalInstitutionCd
  FROM
    in_out_class
    LEFT JOIN
      in_out_ctl_no_calc
    ON  true
),
in_out_data_exists_info AS(
  SELECT
    1 AS order_no,
    ''1'' AS exists_flag
  FROM
    in_out_class ioc
  WHERE
    ''@ppmInOutClass'' = ioc.in_out
  UNION
  SELECT
    2 AS order_no,
    ''0'' AS exists_flag
  ORDER BY
    order_no
  LIMIT 1
),
json_data AS(
  SELECT
    jsonb_build_object(
      ''ctl_no'',
      ctl_no,
      ''in_out'',
      in_out::integer,
      ''reason'',
      reason,
      ''to_course'',
      to_course,
      ''to_doctor'',
      to_doctor,
      ''disp_order'',
      disp_order,
      ''period_end'',
      period_end,
      ''facility_cd'',
      facility_cd,
      ''from_course'',
      from_course,
      ''from_doctor'',
      from_doctor,
      ''move_in_out'',
      move_in_out,
      ''to_facility'',
      to_facility,
      ''period_start'',
      period_start,
      ''from_facility'',
      from_facility,
      ''course_is_free'',
      course_is_free,
      ''doctor_is_free'',
      doctor_is_free,
      ''period_end_day'',
      period_end_day,
      ''period_end_year'',
      period_end_year,
      ''facility_is_free'',
      facility_is_free,
      ''period_end_month'',
      period_end_month,
      ''period_start_day'',
      period_start_day,
      ''period_start_date'',
      period_start_date,
      ''period_start_year'',
      period_start_year,
      ''period_start_month'',
      period_start_month,
      ''period_end_input_free'',
      period_end_input_free,
      ''period_start_input_free'',
      period_start_input_free,
      ''to_medicalInstitutionCd'',
      to_medicalInstitutionCd,
      ''from_medicalInstitutionCd'',
      from_medicalInstitutionCd
    ) AS new_data
  FROM
    data_new_info
)
UPDATE
  pat_unique
SET
  up_date = CURRENT_TIMESTAMP,
  medical_hst_info =  CASE
    WHEN (SELECT exists_flag FROM medi_data_exists_info) = ''0''
     THEN medical_hst_info || (
    CASE
        WHEN
          COALESCE((SELECT diseaseCd::text FROM diseaseInfo),'''') <> ''''
        OR (SELECT is_die FROM isDie) = ''1''
         THEN jsonb_build_object(
          ''memo'',
          ''@medicalHstInfo.memo'',
          ''ctl_no'',
          @nextCtlNo2,
          ''die_date'',
          (SELECT dieDate FROM dateInfo),
          ''out_come'',
          (SELECT outCome FROM outComeInfo),
          ''course_cd'',
          ''@medicalHstInfo.courseCd'',
          ''is_notice'',
          ''0'',
          ''disease_cd'',
          CASE
          WHEN (SELECT is_die FROM isDie) = ''1''  THEN (SELECT dieCd FROM dieInfo)
          ELSE (SELECT diseaseCd FROM diseaseInfo)
          END,
          ''disp_order'',
          @nextCtlNo2 -1,
          ''disease_day'',
          CASE WHEN (SELECT diseaseDate FROM validDate) IS NULL
            THEN NULL
            ELSE substr((SELECT diseaseDate FROM validDate), 7, 2) END,
          ''facility_cd'',
          ''@facilityCd'',
          ''disease_date'',
          (SELECT diseaseDate FROM validDate),
          ''disease_year'',
          CASE WHEN (SELECT diseaseDate FROM validDate) IS NULL
            THEN NULL
            ELSE substr((SELECT diseaseDate FROM validDate), 1, 4) END,
          ''is_diagnosed'',
          ''0'',
          ''diagnosis_day'',
          ''@medicalHstInfo.diagnosisDay'',
          ''disease_month'',
          CASE WHEN (SELECT diseaseDate FROM validDate) IS NULL
            THEN NULL
            ELSE substr((SELECT diseaseDate FROM validDate), 5, 2) END,
          ''out_come_date'',
          (SELECT dieDate FROM dateInfo),
          ''course_is_free'',
          ''0'',
          ''diagnosis_date'',
          ''@medicalHstInfo.diagnosisDate'',
          ''diagnosis_year'',
          ''@medicalHstInfo.diagnosisYear'',
          ''diagnosis_month'',
          ''@medicalHstInfo.diagnosisMonth'',
          ''is_main_disease'',
          ''0'',
          ''diagnostician_cd'',
          ''@medicalHstInfo.diagnosticianCd'',
          ''diagnosis_facility_cd'',
          ''@medicalHstInfo.diagnosisFacilityCd'',
          ''diagnostician_is_free'',
          ''0'',
          ''is_confirmation_biopsy'',
          ''0'',
          ''diagnosis_facility_is_free'',
          ''0'',
          ''disease_end_input_free'',
          ''0'',
          ''diagnosis_end_input_free'',
          ''0'',
          ''disease_start_input_free'',
          ''0'',
          ''diagnosis_start_input_free'',
          ''0'',
          ''is_dialysis_underlying_disease'',
          CASE
            WHEN (SELECT is_die FROM isDie) = '''' THEN ''1''
            ELSE ''0''
          END
        )
        ELSE ''[]''::jsonb
      END
  )
    ELSE medical_hst_info
  END
  ,
  in_out_visit_history_info = CASE
    WHEN((SELECT exists_flag FROM in_out_data_exists_info) = ''0''
    OR  in_out_visit_history_info IS NULL
    OR  in_out_visit_history_info = ''[]''
    ) THEN in_out_visit_history_info || (SELECT new_data FROM json_data)
    ELSE in_out_visit_history_info
  END
WHERE
  pat_id = @patId
AND facility_cd = ''@facilityCd''
AND is_del = ''0''', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの患者プロファイル(既往歴情報情報)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -100001, "field_name": "in_out_class", "replace_var": "@ppmInOutClass"}, {"sql_cd": -100001, "field_name": "is_die", "replace_var": "@isDie"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-501101, 'WITH exam_date_tmp AS ( 
  SELECT
  CASE
    WHEN LENGTH(''@physicalInfo.examDate'') = 8 AND ''@physicalInfo.examDate'' ~ ''^[0-9]+$'' THEN (''@physicalInfo.examDate'')
    ELSE ''''
    END AS exam_date
) 
, exam_date_info AS ( 
  SELECT
    CASE WHEN NULLIF(exam_date, '''') IS NULL THEN TO_CHAR(CURRENT_TIMESTAMP, ''YYYY-MM-DD'') ELSE TO_DATE(exam_date, ''YYYYMMDD'')::TEXT END AS exam_date
    , CASE WHEN NULLIF(exam_date, '''') IS NULL THEN TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDD'') ELSE REPLACE(SUBSTR(exam_date, 1, 10), ''-'', '''') END AS inspect_date
    , CASE WHEN NULLIF(exam_date, '''') IS NULL THEN TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDD'') ELSE REPLACE(SUBSTR(exam_date, 1, 10), ''-'', '''') END AS indicator_start_date
  FROM
    exam_date_tmp
) 
, order_class_info AS ( 
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''1'') 
      ELSE TRIM(ini_info ->> ''value'') 
      END AS order_class 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = ''@facilityCd'' 
    AND COALESCE(ini_info->>''key0'','''')= ''@key0''
    AND TRIM(ini_info ->> ''key1'') = ''SSI_PATIENT_RECV'' 
    AND TRIM(ini_info ->> ''key2'') = ''CTR_ORDER_CLASS'' 
  UNION 
  SELECT
    2 AS order_no
    , ''2'' AS order_class 
  ORDER BY
    order_no ASC LIMIT 1
) 
, ctr_imp_flag_info AS ( 
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''1'') 
      ELSE TRIM(ini_info ->> ''value'') 
      END AS ctr_imp_flag 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = ''@facilityCd'' 
    AND COALESCE(ini_info->>''key0'','''')= ''@key0''
    AND TRIM(ini_info ->> ''key1'') = ''SSI_PATIENT_RECV'' 
    AND TRIM(ini_info ->> ''key2'') = ''IS_CTR'' 
  UNION 
  SELECT
    2 AS order_no
    , ''1'' AS ctr_imp_flag 
  ORDER BY
    order_no ASC LIMIT 1
) 
, data_new_info AS (
  SELECT 
    NULL AS dw,
    COALESCE(NULLIF(''@physicalInfo.ctr'', ''''),NULLIF(''@physicalInfo.ctr2'', '''')) AS ctr,
    NULL AS memo,
    NULL AS ctl_no,
    NULL AS height,
    NULL AS chest_dia,
    (SELECT exam_date FROM exam_date_info) AS exam_date,
    NULL AS breast_dia,
    NULL AS ctr_weight,
    NULL AS changer_cd,
    NULLIF(''@facilityCd'', '''') AS facility_cd,
    COALESCE(NULLIF((SELECT order_class FROM order_class_info), ''2''), ''2'') AS order_class,
    NULL AS indicator_cd,
    (SELECT inspect_date FROM exam_date_info) AS inspect_date,
    NULL AS pre_scale_lower,
    NULL AS pre_scale_upper,
    (SELECT indicator_start_date FROM exam_date_info) AS indicator_start_date,
    null AS target_weight
) 
, data_exists_info AS (
  SELECT
    1 AS order_no
    , ''1'' AS exists_flag 
  FROM
    pat_unique patu 
    CROSS JOIN LATERAL json_array_elements(patu.physical_info ::json) AS OLD 
    , data_new_info AS NEW 
  WHERE
    patu.pat_id = @patId 
    AND patu.facility_cd = ''@facilityCd'' 
    AND patu.is_del = ''0'' 
    AND TO_NUMBER(OLD->>''ctr''::TEXT, ''FM9999.99'') = TO_NUMBER(NEW.ctr ::TEXT, ''FM9999.99'') 
    AND SUBSTR(OLD->>''exam_date''::TEXT, 1, 10) = SUBSTR(NEW.exam_date ::TEXT, 1, 10) 
  UNION 
  SELECT
    2 AS order_no
    , ''0'' AS exists_flag 
  ORDER BY
    order_no ASC LIMIT 1
)
, data_info AS ( 
  SELECT
    0 AS order_no
    , dw ::TEXT AS dw
    , ctr ::TEXT AS ctr
    , memo ::TEXT AS memo
    , ctl_no  AS ctl_no
    , height ::TEXT AS height
    , chest_dia ::TEXT AS chest_dia
    , exam_date ::TEXT AS exam_date
    , breast_dia ::TEXT AS breast_dia
    , ctr_weight ::TEXT AS ctr_weight
    , changer_cd  AS changer_cd
    , facility_cd ::TEXT AS facility_cd
    , (TO_NUMBER(order_class, ''FM9'')) ::TEXT AS order_class
    , indicator_cd ::TEXT AS indicator_cd
    , inspect_date ::TEXT AS inspect_date
    , pre_scale_lower ::TEXT AS pre_scale_lower
    , pre_scale_upper ::TEXT AS pre_scale_upper
    , indicator_start_date ::TEXT AS indicator_start_date 
    , target_weight ::TEXT AS target_weight 
  FROM
    data_new_info 
  WHERE
    (SELECT exists_flag FROM data_exists_info) = ''0'' 
  UNION 
  SELECT
    1 AS order_no
    , info ->> ''dw'' AS dw
    , info ->> ''ctr'' AS ctr
    , info ->> ''memo'' AS memo
    , info ->> ''ctl_no'' AS ctl_no
    , info ->> ''height'' AS height
    , info ->> ''chest_dia'' AS chest_dia
    , info ->> ''exam_date'' AS exam_date
    , info ->> ''breast_dia'' AS breast_dia
    , info ->> ''ctr_weight'' AS ctr_weight
    , info ->> ''changer_cd'' AS changer_cd
    , info ->> ''facility_cd'' AS facility_cd
    , info ->> ''order_class'' AS order_class
    , info ->> ''indicator_cd'' AS indicator_cd
    , info ->> ''inspect_date'' AS inspect_date
    , info ->> ''pre_scale_lower'' AS pre_scale_lower
    , info ->> ''pre_scale_upper'' AS pre_scale_upper
    , info ->> ''indicator_start_date'' AS indicator_start_date 
    , info ->> ''target_weight'' AS target_weight 
  FROM
    pat_unique patu 
    CROSS JOIN LATERAL json_array_elements(patu.physical_info ::json) AS info 
  WHERE
    pat_id = @patId  
    AND facility_cd = ''@facilityCd'' 
    AND is_del = ''0''
  ORDER BY order_no DESC, ctl_no ASC)
, json_data AS (
  SELECT json_build_object(''dw'', TO_NUMBER(dw , ''FM9999.99''),
    ''ctr'', ctr,
    ''memo'', memo,
    ''ctl_no'', row_number() over(order by order_no DESC, ctl_no ASC),
    ''height'', TO_NUMBER(height, ''FM9999.99''),
    ''chest_dia'', TO_NUMBER(chest_dia, ''FM9999.99''),
    ''exam_date'', exam_date,
    ''breast_dia'', TO_NUMBER(breast_dia, ''FM9999.99''),
    ''ctr_weight'', TO_NUMBER(ctr_weight, ''FM9999.99''),
    ''changer_cd'', changer_cd,
    ''facility_cd'', facility_cd,
    ''order_class'', (order_class :: INTEGER),
    ''indicator_cd'', (NULLIF(indicator_cd, '''') :: bigint),
    ''inspect_date'', inspect_date,
    ''target_weight'', TO_NUMBER(target_weight, ''FM9999.99''),
    ''pre_scale_lower'', TO_NUMBER(pre_scale_lower, ''FM9999.99''),
    ''pre_scale_upper'', TO_NUMBER(pre_scale_upper, ''FM9999.99''),
    ''indicator_start_date'', indicator_start_date) AS new_data
  FROM data_info
)
UPDATE pat_unique 
SET
  physical_info = (SELECT array_to_json(ARRAY_AGG(new_data)) FROM json_data)
  , up_date = CURRENT_TIMESTAMP
WHERE
  pat_id = @patId 
  AND facility_cd = ''@facilityCd'' 
  AND is_del = ''0''
  AND (SELECT exists_flag FROM data_exists_info) = ''0'' 
  AND (SELECT ctr_imp_flag FROM ctr_imp_flag_info) = ''1''
  AND (SELECT ctr FROM data_new_info) IS NOT NULL', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの患者プロファイル_固有情報_身体情報', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-501102, 'WITH  ord_main_max AS (
    (
      SELECT
        ord.ord_no,
        ord.del_date as up_date,
        ord.rst_equip_info,
        ord.rst_cond_info
      FROM
        ord_main_restore AS ord,
        sys_coop_journal as journal
      WHERE
        ord.ord_no = @ordNo
        AND journal.ctl_no = @ctlNo
        AND ord.ord_no = journal.ord_no
        AND journal.reg_date >= ord.del_date
      ORDER BY
        del_date DESC
      LIMIT
        1
    )
    UNION
    (
      SELECT
        ord.ord_no,
        ord.rst_edition_date as up_date,
        ord.rst_equip_info,
        ord.rst_cond_info
      FROM
        ord_main AS ord
      WHERE
        ord.ord_no = @ordNo
    )
    ORDER BY
      up_date DESC NULLS LAST
    LIMIT
      1
  )
,equip_order_data AS (
  SELECT
    ROW_NUMBER () OVER () AS no2
    , TO_NUMBER(datt.a1  :: text, ''999999999999'') AS ora
  FROM (
    SELECT TO_NUMBER((unnest(string_to_array((
      SELECT mst_f.value AS rtt
      FROM mst_facility_setting AS mst_f
      WHERE mst_f.facility_setting_no = ''3006'' AND mst_f.facility_cd = @facilityCd
    ),'',''))), ''999999999999'') AS a1) AS datt
)
select
  cost_fin.detail_id as detail_id,
  to_char(row_number() over(
    ORDER BY
    CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 0 THEN cost_fin.meq_reg_order
        WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 1 THEN cost_fin.meq_class_code_order
        WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 2 THEN cost_fin.meq_code_order END,
    CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 0 THEN cost_fin.meq_reg_order
        WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 1 THEN cost_fin.meq_class_code_order
        WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 2 THEN cost_fin.meq_code_order END,
    CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 0 THEN cost_fin.meq_reg_order
        WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 1 THEN cost_fin.meq_class_code_order
        WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 2 THEN cost_fin.meq_code_order END, cost_fin.meq_code_order
  ),''FM9999'') as cost_no,
  trim(cost_fin.e01) as e01,
  cost_fin.e02 as e02,
  cost_fin.e03 as e03,
  cost_fin.e04 as e04,
  cost_fin.e05 as e05,
  cost_fin.e06 as e06
from
(
select
  all_cost.*
    , ROW_NUMBER() OVER() AS meq_reg_order
from
(
WITH equip_order AS (
  SELECT
    index_no ::int AS meq_code_order
    , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS meq_code
  FROM mst_selector
  CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
  WHERE facility_cd = @facilityCd
    AND master_physical_name = ''mst_equipment''
)
, equip_class_order as (
  SELECT
    index_no ::int AS meq_class_code_order
    , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS meq_class_code
  FROM mst_selector
  CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
  WHERE facility_cd = @facilityCd
    AND master_physical_name = ''mst_equipment_class''
)
, mst_equip AS (
  SELECT
    equipment_cd
    , equipment_name
    , meq.class_cd as class_cd
    , unit
    , meq.in_hospital_cd_1 as in_hospital_cd_1
    , equip_order.meq_code_order
    , equip_class_order.meq_class_code_order
    , mst_equipment_class.class_name as class_name
  FROM mst_equipment meq
  LEFT JOIN equip_order ON meq.equipment_cd = equip_order.meq_code
  LEFT JOIN equip_class_order ON meq.class_cd = equip_class_order.meq_class_code
  LEFT JOIN mst_equipment_class ON meq.class_cd = mst_equipment_class.class_cd
  WHERE meq.facility_cd = @facilityCd
)
select --血液回路情報
  ''血液回路'' as detail_id,
  meq.in_hospital_cd_1 as e01,
  meq.equipment_name as e02,
  ''血液回路'' as e03,
  ''0''as e04,
  ''1'' as e05,
  meq.unit as e06,
    ''1'' AS meq_reg_order_text,
    meq.meq_class_code_order AS meq_class_code_order,
    meq.meq_code_order AS meq_code_order
 from
  ord_main_max ord
   left outer join
   mst_equip as meq
  on
   meq.equipment_cd = TO_NUMBER (ord.rst_cond_info->''13''->>''value'',''999999999999'')
   where
  ord.ord_no = @ordNo

union

select --A針情報
  ''穿刺針'' as detail_id,
  meq.in_hospital_cd_1 as e01,
  meq.equipment_name as e02,
  ''A針'' as e03,
  ''1''as e04,
  ''1'' as e05,
  meq.unit as e06,
    ''2'' AS meq_reg_order_text,
    meq.meq_class_code_order AS meq_class_code_order,
    meq.meq_code_order AS meq_code_order
 from
  ord_main_max ord
   left outer join
   mst_equip as meq
  on
   meq.equipment_cd = TO_NUMBER (ord.rst_cond_info->''9''->>''value'',''999999999999'')
   where
  ord.ord_no = @ordNo

union

select --V針情報
  ''穿刺針'' as detail_id,
  meq.in_hospital_cd_1 as e01,
  meq.equipment_name as e02,
  ''V針'' as e03,
  ''2''as e04,
  ''1'' as e05,
  meq.unit as e06,
    ''3'' AS meq_reg_order_text,
    meq.meq_class_code_order AS meq_class_code_order,
    meq.meq_code_order AS meq_code_order
 from
  ord_main_max ord
   left outer join
   mst_equip as meq
  on
   meq.equipment_cd = TO_NUMBER (ord.rst_cond_info->''10''->>''value'',''999999999999'')
   where
  ord.ord_no = @ordNo

union

select --SN針情報
  ''穿刺針'' as detail_id,
  meq.in_hospital_cd_1 as e01,
  meq.equipment_name as e02,
  ''SN針'' as e03,
  ''3''as e04,
  ''1'' as e05,
  meq.unit as e06,
    ''4'' AS meq_reg_order_text,
    meq.meq_class_code_order AS meq_class_code_order,
    meq.meq_code_order AS meq_code_order
 from
  ord_main_max ord
   left outer join
   mst_equip as meq
  on
   meq.equipment_cd = TO_NUMBER (ord.rst_cond_info->''11''->>''value'',''999999999999'')
   where
  ord.ord_no = @ordNo

union

select --医材内穿刺針情報
  ''穿刺針'' as detail_id,
  meq.in_hospital_cd_1 as e01,
  meq.equipment_name as e02,
  ''穿刺針'' as e03,
  ''0''as e04,
  t.equip ->> ''amount'' as e05,
  t.equip ->> ''unit'' as e06,
    ''6'' || TO_CHAR(t.idx,''FM0000'') AS meq_reg_order_text,
    meq.meq_class_code_order AS meq_class_code_order,
    meq.meq_code_order AS meq_code_order
 from
  ord_main_max ord
   cross join lateral
      json_array_elements (ord.rst_equip_info :: json) WITH ORDINALITY AS t(equip, idx)
  left outer join
    mst_equip as meq
  on
    meq.equipment_cd = TO_NUMBER (equip ->> ''cd'',''999999999999'')
   where
  t.equip->>''class_type'' in (''2'',''3'') and
  ord.ord_no = @ordNo

union

select --医材情報
  ''医材'' as detail_id,
  meq.in_hospital_cd_1 as e01,
  meq.equipment_name as e02,
  meq.class_name as e03,
  ''0'' as e04,
  t.equip ->> ''amount'' as e05,
  t.equip ->> ''unit'' as e06,
    ''6'' || TO_CHAR(t.idx,''FM0000'') AS meq_reg_order_text,
    meq.meq_class_code_order AS meq_class_code_order,
    meq.meq_code_order AS meq_code_order
 from
  ord_main_max ord
   cross join lateral
      json_array_elements (ord.rst_equip_info :: json) WITH ORDINALITY AS t(equip, idx)
  left outer join
    mst_equip as meq
  on
    meq.equipment_cd = TO_NUMBER (t.equip ->> ''cd'',''999999999999'')
   where
  t.equip->>''equip_type'' = ''0'' and
  t.equip->>''class_type'' not in (''2'',''3'') and
  ord.ord_no = @ordNo

union

select --1次膜情報
  ''医材'' as detail_id,
  meq.in_hospital_cd_1 as e01,
  meq.equipment_name as e02,
  ''1次膜'' as e03,
  ''0''as e04,
  ''1'' as e05,
  meq.unit as e06,
    ''7'' AS meq_reg_order_text,
    meq.meq_class_code_order AS meq_class_code_order,
    meq.meq_code_order AS meq_code_order
from
  ord_main_max ord
  left outer join
   mst_equip as meq
  on
   meq.equipment_cd = TO_NUMBER (ord.rst_cond_info->''7''->>''value'',''999999999999'')
where
  ord.ord_no = @ordNo

union

select --2次膜情報
  ''医材'' as detail_id,
  meq.in_hospital_cd_1 as e01,
  meq.equipment_name as e02,
  ''2次膜'' as e03,
  ''0''as e04,
  ''1'' as e05,
  meq.unit as e06,
    ''8'' AS meq_reg_order_text,
    meq.meq_class_code_order AS meq_class_code_order,
    meq.meq_code_order AS meq_code_order
from
  ord_main_max ord
  left outer join
   mst_equip as meq
  on
   meq.equipment_cd = TO_NUMBER (ord.rst_cond_info->''8''->>''value'',''999999999999'')
where
  ord.ord_no = @ordNo

union

select --吸着カラム情報
  ''医材'' as detail_id,
  meq.in_hospital_cd_1 as e01,
  meq.equipment_name as e02,
  ''吸着カラム'' as e03,
  ''0''as e04,
  ''1'' as e05,
  meq.unit as e06,
    ''9'' AS meq_reg_order_text,
    meq.meq_class_code_order AS meq_class_code_order,
    meq.meq_code_order AS meq_code_order
from
  ord_main_max ord
  left outer join
   mst_equip as meq
  on
   meq.equipment_cd = TO_NUMBER (ord.rst_cond_info->''6''->>''value'',''999999999999'')
where
  ord.ord_no = @ordNo
) all_cost

where
 all_cost.e01 is not null
--order by all_cost.e07,all_cost.e01
) cost_fin
ORDER BY
CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 0 THEN cost_fin.meq_reg_order
    WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 1 THEN cost_fin.meq_class_code_order
    WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 2 THEN cost_fin.meq_code_order END,
CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 0 THEN cost_fin.meq_reg_order
    WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 1 THEN cost_fin.meq_class_code_order
    WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 2 THEN cost_fin.meq_code_order END,
CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 0 THEN cost_fin.meq_reg_order
    WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 1 THEN cost_fin.meq_class_code_order
    WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 2 THEN cost_fin.meq_code_order END, cost_fin.meq_code_order', 2, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'SSI)実績）医材繰り返し部', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-501103, 'WITH  ord_main_max AS (
    (
      SELECT
        ord.ord_no,
        ord.del_date as up_date,
        ord.rst_medi_info,
        ord.rst_treatment_info
      FROM
        ord_main_restore AS ord,
        sys_coop_journal as journal
      WHERE
        ord.ord_no = @ordNo
        AND journal.ctl_no = @ctlNo
        AND ord.ord_no = journal.ord_no
        AND journal.reg_date >= ord.del_date
      ORDER BY
        del_date DESC
      LIMIT
        1
    )
    UNION
    (
      SELECT
        ord.ord_no,
        ord.rst_edition_date as up_date,
        ord.rst_medi_info,
        ord.rst_treatment_info
        
      FROM
        ord_main AS ord
      WHERE
        ord.ord_no = @ordNo
    )
    ORDER BY
      up_date DESC NULLS LAST
    LIMIT
      1
  )
,coop_ini as (
  SELECT COALESCE
      ( NULLIF( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS value
  FROM
      mst_coop_ini AS ini
      CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info
  WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND COALESCE(info->>''key0'','''') = @key0
    AND info ->> ''key1'' = ''SSI_DIALYSIS_SEND''
    AND info ->> ''key2'' = ''MEDICINE_RESOLVE_MODE''
),medi_order_data AS (
  SELECT
    ROW_NUMBER () OVER () AS no2
    , TO_NUMBER(datt.a1  :: text, ''999999999999'') AS ora
  FROM (
    SELECT TO_NUMBER((unnest(string_to_array((
      SELECT mst_f.value AS rtt
      FROM mst_facility_setting AS mst_f
      WHERE mst_f.facility_setting_no = ''3007'' AND mst_f.facility_cd = @facilityCd
    ),'',''))), ''999999999999'') AS a1) AS datt
)
select
	cost_fin.*,
	to_char(row_number() over( ORDER BY
    CASE WHEN (SELECT ora FROM medi_order_data WHERE no2 = 1) = 0 THEN cost_fin.medi_reg_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 1) = 1 THEN cost_fin.medi_class_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 1) = 2 THEN cost_fin.medicine_type
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 1) = 3 THEN cost_fin.medi_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 1) = 4 THEN cost_fin.timing_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 1) = 5 THEN cost_fin.procedure_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 1) = 6 THEN cost_fin.interval_no END,
    CASE WHEN (SELECT ora FROM medi_order_data WHERE no2 = 2) = 0 THEN cost_fin.medi_reg_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 2) = 1 THEN cost_fin.medi_class_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 2) = 2 THEN cost_fin.medicine_type
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 2) = 3 THEN cost_fin.medi_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 2) = 4 THEN cost_fin.timing_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 2) = 5 THEN cost_fin.procedure_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 2) = 6 THEN cost_fin.interval_no END,
    CASE WHEN (SELECT ora FROM medi_order_data WHERE no2 = 3) = 0 THEN cost_fin.medi_reg_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 3) = 1 THEN cost_fin.medi_class_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 3) = 2 THEN cost_fin.medicine_type
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 3) = 3 THEN cost_fin.medi_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 3) = 4 THEN cost_fin.timing_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 3) = 5 THEN cost_fin.procedure_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 3) = 6 THEN cost_fin.interval_no END,
    CASE WHEN (SELECT ora FROM medi_order_data WHERE no2 = 4) = 0 THEN cost_fin.medi_reg_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 4) = 1 THEN cost_fin.medi_class_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 4) = 2 THEN cost_fin.medicine_type
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 4) = 3 THEN cost_fin.medi_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 4) = 4 THEN cost_fin.timing_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 4) = 5 THEN cost_fin.procedure_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 4) = 6 THEN cost_fin.interval_no END,
    CASE WHEN (SELECT ora FROM medi_order_data WHERE no2 = 5) = 0 THEN cost_fin.medi_reg_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 5) = 1 THEN cost_fin.medi_class_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 5) = 2 THEN cost_fin.medicine_type
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 5) = 3 THEN cost_fin.medi_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 5) = 4 THEN cost_fin.timing_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 5) = 5 THEN cost_fin.procedure_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 5) = 6 THEN cost_fin.interval_no END,
    CASE WHEN (SELECT ora FROM medi_order_data WHERE no2 = 6) = 0 THEN cost_fin.medi_reg_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 6) = 1 THEN cost_fin.medi_class_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 6) = 2 THEN cost_fin.medicine_type
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 6) = 3 THEN cost_fin.medi_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 6) = 4 THEN cost_fin.timing_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 6) = 5 THEN cost_fin.procedure_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 6) = 6 THEN cost_fin.interval_no END,
    CASE WHEN (SELECT ora FROM medi_order_data WHERE no2 = 7) = 0 THEN cost_fin.medi_reg_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 7) = 1 THEN cost_fin.medi_class_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 7) = 2 THEN cost_fin.medicine_type
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 7) = 3 THEN cost_fin.medi_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 7) = 4 THEN cost_fin.timing_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 7) = 5 THEN cost_fin.procedure_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 7) = 6 THEN cost_fin.interval_no END, cost_fin.medi_code_order
  ),''FM9999'') as cost_no
from
(
select
	all_cost.*,
    ROW_NUMBER() OVER(ORDER BY all_cost.medi_reg_order_text) AS medi_reg_order
from
(
WITH medi_order AS (
  SELECT
    index_no AS medi_code_order
    , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_code
  FROM mst_selector
  CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
  WHERE facility_cd = @facilityCd
    AND master_physical_name = ''mst_medicine''
)
, medi_mix_order AS (
  SELECT
    index_no AS medi_code_order
    , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_code
  FROM mst_selector
  CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
  WHERE facility_cd = @facilityCd
    AND master_physical_name = ''mst_medicine_mix''
)
, medi_class_order AS (
  SELECT
    index_no AS medi_class_code_order
    , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_class_code
  FROM mst_selector
  CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
  WHERE facility_cd = @facilityCd
    AND master_physical_name = ''mst_medicine_class''
)
, timing_order AS (
  SELECT
    index_no AS timing_code_order
    , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS timing_code
  FROM mst_selector
  CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
  WHERE facility_cd = @facilityCd
    AND master_physical_name = ''mst_medicate_timing''
)
, procedure_order AS (
  SELECT
    index_no AS procedure_code_order
    , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS procedure_code
  FROM mst_selector
  CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
  WHERE facility_cd = @facilityCd
    AND master_physical_name = ''mst_procedure''
)
, mst_medi AS (
  SELECT
    medicine_cd
    , medicine_name
    , class_cd
    , unit
    , unit_second
    , in_hospital_cd_1
    , in_hospital_cd_2
    , medi_order.medi_code_order
    , medi_class_order.medi_class_code_order
  FROM mst_medicine mmd
  LEFT JOIN medi_order ON mmd.medicine_cd = medi_order.medi_code
  LEFT JOIN medi_class_order ON mmd.class_cd = medi_class_order.medi_class_code
  WHERE facility_cd = @facilityCd
)
select --投与薬剤情報(通常)
	''投与薬剤'' as detail_id,
	mmd.in_hospital_cd_1 as e01,
	t.medi ->> ''name'' as e02,
	t.medi ->> ''class_name'' as e03,
	to_char(to_number(t.medi ->>''amount'',''99999.99'') ,''FM99990.00'')  as e04,
	t.medi ->> ''unit''as e05,
	mp.in_hospital_cd_a1 as e06,
    mp.pricedure_name as e07,
    ''1'' || TO_CHAR(t.idx,''FM0000'') AS medi_reg_order_text,
    mmd.medi_code_order AS medi_code_order,
    mmd.medi_class_code_order AS medi_class_code_order,
    1 AS medicine_type,
    tio.timing_code_order AS timing_code_order,
    pro.procedure_code_order AS procedure_code_order,
    (t.medi ->> ''date_interval'') ::int AS interval_no
    from
      ord_main_max as ord
    cross join lateral
      json_array_elements (ord.rst_medi_info :: json) WITH ORDINALITY AS t(medi, idx)
	left outer join
	  mst_medi as mmd
	on
	  mmd.medicine_cd = TO_NUMBER (t.medi ->> ''cd'',''999999999999'')
	left outer join
	  mst_procedure as mp
	on
	  mp.procedure_cd = TO_NUMBER (t.medi ->> ''procedure_cd'',''999999999999'')
  and
	  COALESCE(mp.in_hospital_cd_a1, ''ZERO'') <> ''ZERO''
	left outer join
      timing_order as tio
    on
      tio.timing_code = TO_NUMBER(t.medi ->> ''timing_cd'', ''FM999999999999'') 
    left outer join
      procedure_order as pro 
    on
      pro.procedure_code = TO_NUMBER(t.medi ->> ''procedure_cd'', ''FM999999999999'') 
    where
	  t.medi ->> ''effect_flg'' = ''1'' and
	  t.medi ->> ''medicine_type'' = ''1'' and
	  COALESCE(mmd.in_hospital_cd_1, ''ZERO'') <> ''ZERO'' and
	  COALESCE(mmd.in_hospital_cd_2, ''ZERO'') = ''ZERO'' and
      ord.ord_no = @ordNo
	--order by medi ->> ''effect_date'',medi ->> ''cd''

union

select --投与薬剤情報(調製)分解
	 ''投与薬剤'' as detail_id,
	mmd.in_hospital_cd_1 as e01,
	mmd.medicine_name as e02,
	mmdc.class_name as e03 ,
	COALESCE((case mmxd->>''solvent'' when ''1'' then to_char(to_number(mmxd->>''amount'',''99999.99''),''FM99990.00'') else to_char(TRUNC(to_number(t.medi ->> ''amount'',''99999.99'') * to_number(mmxd->>''amount'',''99999.99''),2),''FM99990.00'') end),''0.00'') as e04,
	COALESCE(mmd.unit_second, mmd.unit) as e05,
	mp.in_hospital_cd_a1 as e06,
    mp.pricedure_name as e07,
  ''1'' || TO_CHAR(t.idx,''FM0000'') AS medi_reg_order_text,
  mmd.medi_code_order AS medi_code_order,
  mmd.medi_class_code_order AS medi_class_code_order,
  2 AS medicine_type,
  tio.timing_code_order AS timing_code_order,
  pro.procedure_code_order AS procedure_code_order,
  (t.medi ->> ''date_interval'') ::int AS interval_no
  from
    ord_main_max as ord
  cross join lateral
    json_array_elements (ord.rst_medi_info :: json) WITH ORDINALITY AS t(medi, idx)
	left outer join
	  mst_procedure as mp
	on
	  mp.procedure_cd = TO_NUMBER (t.medi ->> ''procedure_cd'',''999999999999'')
  and
	  COALESCE(mp.in_hospital_cd_a1, ''ZERO'') <> ''ZERO''
	left outer join
	  mst_medicine_mix as mmx
 	on
	  mmx.medicine_mix_cd = TO_NUMBER (t.medi ->> ''cd'',''999999999999'')
	left outer join
    timing_order as tio
  on
    tio.timing_code = TO_NUMBER(t.medi ->> ''timing_cd'', ''FM999999999999'') 
  left outer join
    procedure_order as pro 
  on
    pro.procedure_code = TO_NUMBER(t.medi ->> ''procedure_cd'', ''FM999999999999'')

	cross join lateral
      json_array_elements (mmx.mix_info :: json) mmxd
	left outer join
	  mst_medi as mmd
	on
	  mmd.medicine_cd = TO_NUMBER (mmxd ->> ''cd'',''999999999999'')
	left outer join
	  mst_medicine_class as mmdc
	on
	  mmdc.class_cd = mmd.class_cd
    where
	  medi ->> ''effect_flg'' = ''1'' and
	  medi ->> ''medicine_type'' = ''2'' and
	  COALESCE(mmd.in_hospital_cd_1, ''ZERO'') <> ''ZERO'' and
    ord.ord_no = @ordNo and
    (select value from coop_ini) = ''1''

union

select --投与薬剤情報(調製)セット
	 ''投与薬剤'' as detail_id,
	mmx.in_hospital_cd_1 as e01,
	mmx.medicine_mix_name as e02,
	mmdc.class_name as e03 ,
	COALESCE((to_char(to_number(t.medi ->> ''amount'',''99999.99''),''FM99990.00'')),''0.00'') as e04,
	mmx.unit as e05,
	mp.in_hospital_cd_a1 as e06,
	mp.pricedure_name as e07,
  ''1'' || TO_CHAR(t.idx,''FM0000'') AS medi_reg_order_text,
  medi_order.medi_code_order AS medi_code_order,
  medi_class_order.medi_class_code_order AS medi_class_code_order,
  2 AS medicine_type,
  tio.timing_code_order AS timing_code_order,
  pro.procedure_code_order AS procedure_code_order,
  (t.medi ->> ''date_interval'') ::int AS interval_no
  from
    ord_main_max as ord
  cross join lateral
    json_array_elements (ord.rst_medi_info :: json) WITH ORDINALITY AS t(medi, idx)
	left outer join
	  mst_procedure as mp
	on
	  mp.procedure_cd = TO_NUMBER (t.medi ->> ''procedure_cd'',''999999999999'')
  and
	  COALESCE(mp.in_hospital_cd_a1, ''ZERO'') <> ''ZERO''
	left outer join
	  mst_medicine_mix as mmx
 	on
	  mmx.medicine_mix_cd = TO_NUMBER (t.medi ->> ''cd'',''999999999999'')
	left outer join
      timing_order as tio
  on
    tio.timing_code = TO_NUMBER(t.medi ->> ''timing_cd'', ''FM999999999999'') 
  left outer join
    procedure_order as pro 
  on
    pro.procedure_code = TO_NUMBER(t.medi ->> ''procedure_cd'', ''FM999999999999'')
  left outer join
    mst_medicine_class as mmdc
  on
    mmdc.class_cd = mmx.class_cd
  LEFT JOIN medi_order ON mmx.medicine_mix_cd = medi_order.medi_code
  LEFT JOIN medi_class_order ON mmx.class_cd = medi_class_order.medi_class_code
  where
    medi ->> ''effect_flg'' = ''1'' and
    medi ->> ''medicine_type'' = ''2'' and
    COALESCE(mmx.in_hospital_cd_2, ''ZERO'') = ''ZERO'' and
    ord.ord_no = @ordNo and
    (select value from coop_ini) = ''0''

union

select --処置薬剤情報
	''処置薬剤'' as detail_id,
	mmd.in_hospital_cd_1 as e01,
	t.tmedi ->> ''treat_medicine_name'' as e02,
	mmdc.class_name as e03 ,
	to_char(to_number(t.tmedi ->> ''amount'',''99999.99'') ,''FM99990.00'') as e04,
	t.tmedi ->> ''unit'' as e05,
	mp.in_hospital_cd_a1 as e06,
  t.tmedi ->> ''procedure_name'' as e07,
    ''2'' || TO_CHAR(t.idx,''FM0000'') AS medi_reg_order_text,
    mmd.medi_code_order AS medi_code_order,
    mmd.medi_class_code_order AS medi_class_code_order,
    TO_NUMBER(t.tmedi ->> ''medicine_type'' , ''FM9999'') AS medicine_type,
    tio.timing_code_order AS timing_code_order,
    pro.procedure_code_order AS procedure_code_order,
    (t.tmedi ->> ''date_interval'') ::int AS interval_no
    from
      ord_main_max as ord
    cross join lateral
      json_array_elements (ord.rst_treatment_info :: json) WITH ORDINALITY AS t(tmedi, idx)
	left outer join
	  mst_medi as mmd
	on
	  mmd.medicine_cd = TO_NUMBER (t.tmedi ->> ''treat_medicine_cd'',''999999999999'')
	left outer join
	  mst_medicine_class as mmdc
	on
	  mmdc.class_cd = mmd.class_cd
	left outer join
	  mst_procedure as mp
	on
	  mp.procedure_cd = TO_NUMBER (t.tmedi ->> ''procedure_cd'',''999999999999'')
  and
	  COALESCE(mp.in_hospital_cd_a1, ''ZERO'') <> ''ZERO''
	left outer join
      timing_order as tio
    on
      tio.timing_code = TO_NUMBER(t.tmedi ->> ''timing_cd'', ''FM999999999999'') 
    left outer join
      procedure_order as pro 
    on
      pro.procedure_code = TO_NUMBER(t.tmedi ->> ''procedure_cd'', ''FM999999999999'')
    where
	  COALESCE(mmd.in_hospital_cd_2, ''ZERO'') <> ''ZERO'' and
      ord.ord_no = @ordNo
) all_cost

where
 all_cost.e01 is not null
) cost_fin
ORDER BY
CASE WHEN (SELECT ora FROM medi_order_data WHERE no2 = 1) = 0 THEN cost_fin.medi_reg_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 1) = 1 THEN cost_fin.medi_class_code_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 1) = 2 THEN cost_fin.medicine_type
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 1) = 3 THEN cost_fin.medi_code_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 1) = 4 THEN cost_fin.timing_code_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 1) = 5 THEN cost_fin.procedure_code_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 1) = 6 THEN cost_fin.interval_no END,
CASE WHEN (SELECT ora FROM medi_order_data WHERE no2 = 2) = 0 THEN cost_fin.medi_reg_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 2) = 1 THEN cost_fin.medi_class_code_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 2) = 2 THEN cost_fin.medicine_type
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 2) = 3 THEN cost_fin.medi_code_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 2) = 4 THEN cost_fin.timing_code_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 2) = 5 THEN cost_fin.procedure_code_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 2) = 6 THEN cost_fin.interval_no END,
CASE WHEN (SELECT ora FROM medi_order_data WHERE no2 = 3) = 0 THEN cost_fin.medi_reg_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 3) = 1 THEN cost_fin.medi_class_code_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 3) = 2 THEN cost_fin.medicine_type
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 3) = 3 THEN cost_fin.medi_code_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 3) = 4 THEN cost_fin.timing_code_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 3) = 5 THEN cost_fin.procedure_code_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 3) = 6 THEN cost_fin.interval_no END,
CASE WHEN (SELECT ora FROM medi_order_data WHERE no2 = 4) = 0 THEN cost_fin.medi_reg_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 4) = 1 THEN cost_fin.medi_class_code_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 4) = 2 THEN cost_fin.medicine_type
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 4) = 3 THEN cost_fin.medi_code_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 4) = 4 THEN cost_fin.timing_code_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 4) = 5 THEN cost_fin.procedure_code_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 4) = 6 THEN cost_fin.interval_no END,
CASE WHEN (SELECT ora FROM medi_order_data WHERE no2 = 5) = 0 THEN cost_fin.medi_reg_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 5) = 1 THEN cost_fin.medi_class_code_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 5) = 2 THEN cost_fin.medicine_type
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 5) = 3 THEN cost_fin.medi_code_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 5) = 4 THEN cost_fin.timing_code_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 5) = 5 THEN cost_fin.procedure_code_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 5) = 6 THEN cost_fin.interval_no END,
CASE WHEN (SELECT ora FROM medi_order_data WHERE no2 = 6) = 0 THEN cost_fin.medi_reg_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 6) = 1 THEN cost_fin.medi_class_code_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 6) = 2 THEN cost_fin.medicine_type
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 6) = 3 THEN cost_fin.medi_code_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 6) = 4 THEN cost_fin.timing_code_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 6) = 5 THEN cost_fin.procedure_code_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 6) = 6 THEN cost_fin.interval_no END,
CASE WHEN (SELECT ora FROM medi_order_data WHERE no2 = 7) = 0 THEN cost_fin.medi_reg_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 7) = 1 THEN cost_fin.medi_class_code_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 7) = 2 THEN cost_fin.medicine_type
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 7) = 3 THEN cost_fin.medi_code_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 7) = 4 THEN cost_fin.timing_code_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 7) = 5 THEN cost_fin.procedure_code_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 7) = 6 THEN cost_fin.interval_no END, cost_fin.medi_code_order', 2, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'SSI)実績）薬剤繰り返し部', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-501104, 'WITH  ord_main_max AS (
    (
      SELECT
        ord.ord_no,
        ord.del_date as up_date,
        ord.ind_cond_info,
        ord.ind_equip_info
      FROM
        ord_main_restore AS ord,
        sys_coop_journal as journal
      WHERE
        ord.ord_no = @ordNo
        AND journal.ctl_no = @ctlNo
        AND ord.ord_no = journal.ord_no
        AND journal.reg_date >= ord.del_date
      ORDER BY
        del_date DESC
      LIMIT
        1
    )
    UNION
    (
      SELECT
        ord.ord_no,
        ord.rst_edition_date as up_date,
        ord.ind_cond_info,
        ord.ind_equip_info
      FROM
        ord_main AS ord
      WHERE
        ord.ord_no = @ordNo
    )
    ORDER BY
      up_date DESC NULLS LAST
    LIMIT
      1
  )
SELECT
  ord_cost.*
  , TO_CHAR(ROW_NUMBER() OVER (), ''FM9999'') AS cost_no 
FROM
  (
    WITH equip_order_data AS (
      SELECT
        ROW_NUMBER () OVER () AS no2
        , TO_NUMBER(datt.a1  :: text, ''999999999999'') AS ora
      FROM (
        SELECT TO_NUMBER((unnest(string_to_array((
          SELECT mst_f.value AS rtt
          FROM mst_facility_setting AS mst_f
          WHERE mst_f.facility_setting_no = ''3006'' AND mst_f.facility_cd = @facilityCd
        ),'',''))), ''999999999999'') AS a1) AS datt
    )
    SELECT
      cost_fin.*
    FROM
      ( 
        SELECT
          all_cost.* 
          , ROW_NUMBER() OVER(ORDER BY all_cost.meq_reg_order_text) AS meq_reg_order
        FROM
          ( WITH equip_order AS (
              SELECT
                index_no ::int AS meq_code_order
                , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS meq_code
              FROM mst_selector
              CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
              WHERE facility_cd = @facilityCd
                AND master_physical_name = ''mst_equipment''
            )
            , equip_class_order as (
              SELECT
                index_no ::int AS meq_class_code_order
                , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS meq_class_code
              FROM mst_selector
              CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
              WHERE facility_cd = @facilityCd
                AND master_physical_name = ''mst_equipment_class''
            )
            , mst_equip AS (
              SELECT
                equipment_cd
                , equipment_name
                , class_cd
                , unit
                , in_hospital_cd_1
                , equip_order.meq_code_order
                , equip_class_order.meq_class_code_order
              FROM mst_equipment meq
              LEFT JOIN equip_order ON meq.equipment_cd = equip_order.meq_code
              LEFT JOIN equip_class_order ON meq.class_cd = equip_class_order.meq_class_code
              WHERE facility_cd = @facilityCd
            )
            SELECT
              --血液回路情報
              ''血液回路'' AS detail_id
              , meq.in_hospital_cd_1 AS e01
              , meq.equipment_name AS e02
              , ''血液回路'' AS e03
              , ''0'' AS e04
              , ''1'' AS e05
              , meq.unit AS e06 
              , ''1'' AS meq_reg_order_text
              , meq.meq_class_code_order AS meq_class_code_order
              , meq.meq_code_order AS meq_code_order
            FROM
              ord_main_max ord 
              LEFT OUTER JOIN mst_equip AS meq 
                ON meq.equipment_cd = TO_NUMBER(ord.ind_cond_info -> ''13'' ->> ''value'', ''FM999999999999'') 
            WHERE
              ord.ord_no = @ordNo 
            UNION 
            SELECT
              --A針情報
              ''穿刺針'' AS detail_id
              , meq.in_hospital_cd_1 AS e01
              , meq.equipment_name AS e02
              , ''A針'' AS e03
              , ''1'' AS e04
              , ''1'' AS e05
              , meq.unit AS e06 
              , ''2'' AS meq_reg_order_text
              , meq.meq_class_code_order AS meq_class_code_order
              , meq.meq_code_order AS meq_code_order
            FROM
              ord_main_max ord 
              LEFT OUTER JOIN mst_equip AS meq 
                ON meq.equipment_cd = TO_NUMBER(ord.ind_cond_info -> ''9'' ->> ''value'', ''FM999999999999'') 
            WHERE
              ord.ord_no = @ordNo 
            UNION 
            SELECT
              --V針情報
              ''穿刺針'' AS detail_id
              , meq.in_hospital_cd_1 AS e01
              , meq.equipment_name AS e02
              , ''V針'' AS e03
              , ''2'' AS e04
              , ''1'' AS e05
              , meq.unit AS e06 
              , ''3'' AS meq_reg_order_text
              , meq.meq_class_code_order AS meq_class_code_order
              , meq.meq_code_order AS meq_code_order
            FROM
              ord_main_max ord 
              LEFT OUTER JOIN mst_equip AS meq 
                ON meq.equipment_cd = TO_NUMBER(ord.ind_cond_info -> ''10'' ->> ''value'', ''FM999999999999'') 
            WHERE
              ord.ord_no = @ordNo 
            UNION 
            SELECT
              --SN針情報
              ''穿刺針'' AS detail_id
              , meq.in_hospital_cd_1 AS e01
              , meq.equipment_name AS e02
              , ''SN針'' AS e03
              , ''3'' AS e04
              , ''1'' AS e05
              , meq.unit AS e06 
              , ''4'' AS meq_reg_order_text
              , meq.meq_class_code_order AS meq_class_code_order
              , meq.meq_code_order AS meq_code_order
            FROM
              ord_main_max ord 
              LEFT OUTER JOIN mst_equip AS meq 
                ON meq.equipment_cd = TO_NUMBER(ord.ind_cond_info -> ''11'' ->> ''value'', ''FM999999999999'') 
            WHERE
              ord.ord_no = @ordNo 
            UNION 
            SELECT
              --医材内穿刺針情報
              ''穿刺針'' AS detail_id
              , meq.in_hospital_cd_1 AS e01
              , '''' AS e02
              , '''' AS e03
              , CASE WHEN
                  meqc.class_type = 3 THEN ''3''
                  WHEN meq.equipment_name LIKE ''%A%'' THEN ''1''
                  WHEN meq.equipment_name LIKE ''%V%'' THEN ''2''
                  ELSE ''0''
                END AS e04
              , '''' AS e05
              , '''' AS e06 
              , ''5'' || t.idx AS meq_reg_order_text
              , meq.meq_class_code_order AS meq_class_code_order
              , meq.meq_code_order AS meq_code_order
            FROM
              ord_main_max ord 
              CROSS JOIN LATERAL json_array_elements(ord.ind_equip_info ::json) WITH ORDINALITY AS t(equip, idx)
              LEFT OUTER JOIN mst_equip AS meq 
                ON meq.equipment_cd = TO_NUMBER(t.equip ->> ''cd'', ''FM999999999999'') 
              LEFT OUTER JOIN mst_equipment_class AS meqc 
                ON meqc.class_cd = meq.class_cd 
            WHERE
              meqc.class_type IN (2, 3) 
              AND ord.ord_no = @ordNo 
            UNION 
            SELECT
              --医材情報
              ''医材'' AS detail_id
              , meq.in_hospital_cd_1 AS e01
              , meq.equipment_name AS e02
              , meqc.class_name AS e03
              , ''0'' AS e04
              , equip ->> ''amount'' AS e05
              , meq.unit AS e06 
              , ''6'' || t.idx AS meq_reg_order_text
              , meq.meq_class_code_order AS meq_class_code_order
              , meq.meq_code_order AS meq_code_order
            FROM
              ord_main_max ord 
              CROSS JOIN LATERAL json_array_elements(ord.ind_equip_info ::json) WITH ORDINALITY AS t(equip, idx)
              LEFT OUTER JOIN mst_equip AS meq 
                ON meq.equipment_cd = TO_NUMBER(equip ->> ''cd'', ''FM999999999999'') 
              LEFT OUTER JOIN mst_equipment_class AS meqc 
                ON meqc.class_cd = meq.class_cd 
            WHERE
              t.equip ->> ''equip_type'' = ''0'' 
            AND (meqc.class_type NOT IN (2, 3)  OR meqc.class_type IS NULL)
              AND ord.ord_no = @ordNo 
            UNION 
            SELECT
              --吸着カラム情報
              ''医材'' AS detail_id
              , meq.in_hospital_cd_1 AS e01
              , meq.equipment_name AS e02
              , ''吸着カラム'' AS e03
              , ''0'' AS e04
              , ''1'' AS e05
              , meq.unit AS e06 
              , ''7'' AS meq_reg_order_text
              , meq.meq_class_code_order AS meq_class_code_order
              , meq.meq_code_order AS meq_code_order
            FROM
              ord_main_max ord 
              LEFT OUTER JOIN mst_equip AS meq 
                ON meq.equipment_cd = TO_NUMBER(ord.ind_cond_info -> ''6'' ->> ''value'', ''FM999999999999'') 
            WHERE
              ord.ord_no = @ordNo
          ) all_cost 
        WHERE
          all_cost.e01 IS NOT NULL
      ) cost_fin 
    ORDER BY
    CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 0 THEN cost_fin.meq_reg_order
        WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 1 THEN cost_fin.meq_class_code_order
        WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 2 THEN cost_fin.meq_code_order END,
    CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 0 THEN cost_fin.meq_reg_order
        WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 1 THEN cost_fin.meq_class_code_order
        WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 2 THEN cost_fin.meq_code_order END,
    CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 0 THEN cost_fin.meq_reg_order
        WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 1 THEN cost_fin.meq_class_code_order
        WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 2 THEN cost_fin.meq_code_order END, cost_fin.meq_code_order
  ) ord_cost', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'SSI予約）医材繰り返し部', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-501105, 'WITH coop_ini as (
    SELECT COALESCE
        ( NULLIF( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS value
    FROM
        mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info
    WHERE
            facility_cd = @facilityCd
        AND is_del = ''0''
        AND COALESCE(info->>''key0'','''') = @key0
        AND info ->> ''key1'' = ''SSI_DIALYSIS_SEND''
        AND info ->> ''key2'' = ''MEDICINE_RESOLVE_MODE''
  ),
  ord_main_max AS (
    (
      SELECT
        ord.ord_no,
        ord.del_date as up_date,
        ord.ind_medi_info
      FROM
        ord_main_restore AS ord,
        sys_coop_journal as journal
      WHERE
        ord.ord_no = @ordNo
        AND journal.ctl_no = @ctlNo
        AND ord.ord_no = journal.ord_no
        AND journal.reg_date >= ord.del_date
      ORDER BY
        del_date DESC
      LIMIT
        1
    )
    UNION
    (
      SELECT
        ord.ord_no,
        ord.rst_edition_date as up_date,
        ord.ind_medi_info
      FROM
        ord_main AS ord
      WHERE
        ord.ord_no = @ordNo
    )
    ORDER BY
      up_date DESC NULLS LAST
    LIMIT
      1
  )
SELECT
  ord_cost.*
  , TO_CHAR(ROW_NUMBER() OVER (), ''FM9999'') AS cost_no 
FROM
  (
    WITH medi_order_data AS (
      SELECT
        ROW_NUMBER () OVER () AS no2
        , TO_NUMBER(datt.a1  :: text, ''999999999999'') AS ora
      FROM (
        SELECT TO_NUMBER((unnest(string_to_array((
          SELECT mst_f.value AS rtt
          FROM mst_facility_setting AS mst_f
          WHERE mst_f.facility_setting_no = ''3007'' AND mst_f.facility_cd = @facilityCd
        ),'',''))), ''999999999999'') AS a1) AS datt
    )
    SELECT
      cost_fin.*
    FROM
      ( 
        SELECT
          all_cost.detail_id
          , all_cost.e01
          , all_cost.e02
          , all_cost.e03
          , CASE WHEN RIGHT(all_cost.e04,1)=''.'' THEN TO_CHAR( TO_NUMBER(all_cost.e04, ''FM99999''), ''FM99990'')
            ELSE all_cost.e04 END
          , all_cost.e05
          , all_cost.e06
          , all_cost.e07 
          , all_cost.medi_reg_order
          , all_cost.medi_code_order
          , all_cost.medi_class_code_order
          , all_cost.medicine_type
          , all_cost.timing_code_order
          , all_cost.procedure_code_order
          , all_cost.interval_no
        FROM
          ( 
            WITH medi_order AS (
              SELECT
                index_no AS medi_code_order
                , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_code
              FROM mst_selector
              CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
              WHERE facility_cd = @facilityCd
                AND master_physical_name = ''mst_medicine''
            )
            , medi_class_order AS (
              SELECT
                index_no AS medi_class_code_order
                , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_class_code
              FROM mst_selector
              CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
              WHERE facility_cd = @facilityCd
                AND master_physical_name = ''mst_medicine_class''
            )
            , timing_order AS (
              SELECT
                index_no AS timing_code_order
                , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS timing_code
              FROM mst_selector
              CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
              WHERE facility_cd = @facilityCd
                AND master_physical_name = ''mst_medicate_timing''
            )
            , procedure_order AS (
              SELECT
                index_no AS procedure_code_order
                , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS procedure_code
              FROM mst_selector
              CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
              WHERE facility_cd = @facilityCd
                AND master_physical_name = ''mst_procedure''
            )
            , mst_medi AS (
              SELECT
                medicine_cd
                , medicine_name
                , class_cd
                , unit
                , unit_second
                , in_hospital_cd_1
                , in_hospital_cd_2
                , medi_order.medi_code_order
                , medi_class_order.medi_class_code_order
              FROM mst_medicine mmd
              LEFT JOIN medi_order ON mmd.medicine_cd = medi_order.medi_code
              LEFT JOIN medi_class_order ON mmd.class_cd = medi_class_order.medi_class_code
              WHERE facility_cd = @facilityCd
            )
            SELECT
              --投与薬剤情報(通常)
              ''投与薬剤'' AS detail_id
              , mmd.in_hospital_cd_1 AS e01
              , mmd.medicine_name AS e02
              , mclass.class_name AS e03
              , TO_CHAR( TO_NUMBER(t.medi ->> ''amount'', ''FM99999.99''), ''FM99990.99'') AS e04
              , mmd.unit AS e05
              , mp.in_hospital_cd_a1 AS e06
              , CASE WHEN COALESCE(mp.in_hospital_cd_a1,'''') <>'''' THEN mp.pricedure_name ELSE NULL END AS e07 
              , t.idx AS medi_reg_order
              , mmd.medi_code_order AS medi_code_order
              , mmd.medi_class_code_order AS medi_class_code_order
              , 1 AS medicine_type
              , tio.timing_code_order AS timing_code_order
              , pro.procedure_code_order AS procedure_code_order
              , (t.medi ->> ''date_interval'') ::int AS interval_no
            FROM
              ord_main_max AS ord 
              CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info ::json) WITH ORDINALITY AS t(medi, idx)
              LEFT OUTER JOIN mst_medi AS mmd 
                ON mmd.medicine_cd = TO_NUMBER(t.medi ->> ''cd'', ''FM999999999999'') 
              LEFT OUTER JOIN mst_procedure AS mp 
                ON mp.procedure_cd = TO_NUMBER(t.medi ->> ''procedure_cd'', ''FM999999999999'') 
              LEFT OUTER JOIN mst_medicine_class AS mclass 
                ON mclass.class_cd = mmd.class_cd
              LEFT OUTER JOIN timing_order AS tio
                ON tio.timing_code = TO_NUMBER(t.medi ->> ''timing_cd'', ''FM999999999999'') 
              LEFT OUTER JOIN procedure_order AS pro 
                ON pro.procedure_code = TO_NUMBER(t.medi ->> ''procedure_cd'', ''FM999999999999'') 
            WHERE
              medi ->> ''medicine_type'' = ''1'' 
              AND COALESCE(mmd.in_hospital_cd_1, ''ZERO'') <> ''ZERO'' 
              AND COALESCE(mmd.in_hospital_cd_2, ''ZERO'') = ''ZERO''
              AND ord.ord_no = @ordNo 
            UNION 
            SELECT
              --投与薬剤情報(調製)分解
              ''投与薬剤'' AS detail_id
              , mmd.in_hospital_cd_1 AS e1
              , mmd.medicine_name AS e2
              , mmdc.class_name AS e03
              , COALESCE( 
                ( 
                  CASE mmxd ->> ''solvent'' 
                    WHEN ''1'' THEN TO_CHAR( TO_NUMBER(mmxd ->> ''amount'', ''FM99999.99''), ''99990.99'') 
                    ELSE ( CASE WHEN (mmx.amount_unit * TO_NUMBER(mmxd ->> ''amount'', ''FM99999.99'')) = 0 THEN ''0.00''
                                WHEN mmx.amount_unit IS NULL THEN 
                                    TO_CHAR( TRUNC(TO_NUMBER(t.medi ->> ''amount'', ''FM99999.99'') * TO_NUMBER(mmxd ->> ''amount'', ''FM99999.99''),2), ''FM99990.99'')
                           ELSE TO_CHAR( TO_NUMBER(t.medi ->> ''amount'', ''FM99999.99'') / mmx.amount_unit * TO_NUMBER(mmxd ->> ''amount'', ''FM99999.99''), ''FM99990.99'') 
                           END
                         )
                    END
                ) 
                , ''0.00''
              ) AS e04
              , COALESCE(mmd.unit_second, mmd.unit) AS e05
              , mp.in_hospital_cd_a1 AS e06
              , mp.pricedure_name AS e07 
              , t.idx AS medi_reg_order
              , mmd.medi_code_order AS medi_code_order
              , mmd.medi_class_code_order AS medi_class_code_order
              , 2 AS medicine_type
              , tio.timing_code_order AS timing_code_order
              , pro.procedure_code_order AS procedure_code_order
              , (t.medi ->> ''date_interval'') ::int AS interval_no
            FROM
              ord_main_max AS ord 
              CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info ::json) WITH ORDINALITY AS t(medi, idx)
              LEFT OUTER JOIN mst_procedure AS mp 
                ON mp.procedure_cd = TO_NUMBER(t.medi ->> ''procedure_cd'', ''FM999999999999'') 
              LEFT OUTER JOIN mst_medicine_mix AS mmx 
                ON mmx.medicine_mix_cd = TO_NUMBER(t.medi ->> ''cd'', ''FM999999999999'')
              CROSS JOIN LATERAL json_array_elements(mmx.mix_info ::json) mmxd 
              LEFT OUTER JOIN timing_order AS tio
                ON tio.timing_code = TO_NUMBER(t.medi ->> ''timing_cd'', ''FM999999999999'') 
              LEFT OUTER JOIN procedure_order AS pro 
                ON pro.procedure_code = TO_NUMBER(t.medi ->> ''procedure_cd'', ''FM999999999999'') 
              LEFT OUTER JOIN mst_medi AS mmd 
                ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''FM999999999999'') 
              LEFT OUTER JOIN mst_medicine_class AS mmdc 
                ON mmdc.class_cd = mmd.class_cd 
            WHERE
              t.medi ->> ''medicine_type'' = ''2'' 
              AND ord.ord_no = @ordNo
              AND (select value from coop_ini) = ''1''
            UNION 
            SELECT
              --投与薬剤情報(調製)セット
              ''投与薬剤'' AS detail_id
              , mmx.in_hospital_cd_1 AS e1
              , mmx.medicine_mix_name AS e2
              , mmdc.class_name AS e03
              , COALESCE( TO_CHAR( TO_NUMBER(t.medi ->> ''amount'', ''FM99999.99''), ''99990.99'') , ''0.00'') AS e04
              , mmx.unit AS e05
              , mp.in_hospital_cd_a1 AS e06
              , mp.pricedure_name AS e07 
              , t.idx AS medi_reg_order
              , medi_order.medi_code_order AS medi_code_order
              , medi_class_order.medi_class_code_order AS medi_class_code_order
              , 2 AS medicine_type
              , tio.timing_code_order AS timing_code_order
              , pro.procedure_code_order AS procedure_code_order
              , (t.medi ->> ''date_interval'') ::int AS interval_no
            FROM
              ord_main_max AS ord 
              CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info ::json) WITH ORDINALITY AS t(medi, idx)
              LEFT OUTER JOIN mst_procedure AS mp 
                ON mp.procedure_cd = TO_NUMBER(t.medi ->> ''procedure_cd'', ''FM999999999999'') 
              LEFT OUTER JOIN mst_medicine_mix AS mmx 
                ON mmx.medicine_mix_cd = TO_NUMBER(t.medi ->> ''cd'', ''FM999999999999'')
              LEFT OUTER JOIN timing_order AS tio
                ON tio.timing_code = TO_NUMBER(t.medi ->> ''timing_cd'', ''FM999999999999'') 
              LEFT OUTER JOIN procedure_order AS pro 
                ON pro.procedure_code = TO_NUMBER(t.medi ->> ''procedure_cd'', ''FM999999999999'') 
              LEFT OUTER JOIN mst_medicine_class AS mmdc 
                ON mmdc.class_cd = mmx.class_cd 
              LEFT JOIN medi_order 
                ON mmx.medicine_mix_cd = medi_order.medi_code
              LEFT JOIN medi_class_order 
                ON mmx.class_cd = medi_class_order.medi_class_code
            WHERE
              t.medi ->> ''medicine_type'' = ''2'' 
              AND ord.ord_no = @ordNo
              AND (select value from coop_ini) = ''0''
          ) all_cost 
        WHERE
          all_cost.e01 IS NOT NULL
      ) cost_fin 
    ORDER BY
    CASE WHEN (SELECT ora FROM medi_order_data WHERE no2 = 1) = 0 THEN cost_fin.medi_reg_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 1) = 1 THEN cost_fin.medi_class_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 1) = 2 THEN cost_fin.medicine_type
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 1) = 3 THEN cost_fin.medi_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 1) = 4 THEN cost_fin.timing_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 1) = 5 THEN cost_fin.procedure_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 1) = 6 THEN cost_fin.interval_no END,
    CASE WHEN (SELECT ora FROM medi_order_data WHERE no2 = 2) = 0 THEN cost_fin.medi_reg_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 2) = 1 THEN cost_fin.medi_class_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 2) = 2 THEN cost_fin.medicine_type
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 2) = 3 THEN cost_fin.medi_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 2) = 4 THEN cost_fin.timing_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 2) = 5 THEN cost_fin.procedure_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 2) = 6 THEN cost_fin.interval_no END,
    CASE WHEN (SELECT ora FROM medi_order_data WHERE no2 = 3) = 0 THEN cost_fin.medi_reg_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 3) = 1 THEN cost_fin.medi_class_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 3) = 2 THEN cost_fin.medicine_type
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 3) = 3 THEN cost_fin.medi_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 3) = 4 THEN cost_fin.timing_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 3) = 5 THEN cost_fin.procedure_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 3) = 6 THEN cost_fin.interval_no END,
    CASE WHEN (SELECT ora FROM medi_order_data WHERE no2 = 4) = 0 THEN cost_fin.medi_reg_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 4) = 1 THEN cost_fin.medi_class_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 4) = 2 THEN cost_fin.medicine_type
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 4) = 3 THEN cost_fin.medi_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 4) = 4 THEN cost_fin.timing_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 4) = 5 THEN cost_fin.procedure_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 4) = 6 THEN cost_fin.interval_no END,
    CASE WHEN (SELECT ora FROM medi_order_data WHERE no2 = 5) = 0 THEN cost_fin.medi_reg_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 5) = 1 THEN cost_fin.medi_class_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 5) = 2 THEN cost_fin.medicine_type
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 5) = 3 THEN cost_fin.medi_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 5) = 4 THEN cost_fin.timing_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 5) = 5 THEN cost_fin.procedure_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 5) = 6 THEN cost_fin.interval_no END,
    CASE WHEN (SELECT ora FROM medi_order_data WHERE no2 = 6) = 0 THEN cost_fin.medi_reg_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 6) = 1 THEN cost_fin.medi_class_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 6) = 2 THEN cost_fin.medicine_type
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 6) = 3 THEN cost_fin.medi_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 6) = 4 THEN cost_fin.timing_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 6) = 5 THEN cost_fin.procedure_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 6) = 6 THEN cost_fin.interval_no END,
    CASE WHEN (SELECT ora FROM medi_order_data WHERE no2 = 7) = 0 THEN cost_fin.medi_reg_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 7) = 1 THEN cost_fin.medi_class_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 7) = 2 THEN cost_fin.medicine_type
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 7) = 3 THEN cost_fin.medi_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 7) = 4 THEN cost_fin.timing_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 7) = 5 THEN cost_fin.procedure_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 7) = 6 THEN cost_fin.interval_no END, cost_fin.medi_code_order
  ) ord_cost', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'SSI予約）薬剤繰り返し部', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-501106, 'WITH  ord_main_max AS (
    (
      SELECT
        ord.ord_no,
        ord.del_date as up_date,
        ord.ind_bed_cd,
        ord.ind_cond_info,
        ord.ind_device_set_info,
        ord.ind_treat_start_time,
        ord.ind_treatment_cd,
        ord.treat_date,
        ord.pat_id,
        ord.ind_kur_cd
      FROM
        ord_main_restore AS ord,
        sys_coop_journal as journal
      WHERE
        ord.ord_no = @ordNo
        AND journal.ctl_no = @ctlNo
        AND ord.ord_no = journal.ord_no
        AND journal.reg_date >= ord.del_date
      ORDER BY
        del_date DESC
      LIMIT
        1
    )
    UNION
    (
      SELECT
        ord.ord_no,
        ord.rst_edition_date as up_date,
        ord.ind_bed_cd,
        ord.ind_cond_info,
        ord.ind_device_set_info,
        ord.ind_treat_start_time,
        ord.ind_treatment_cd,
        ord.treat_date,
        ord.pat_id,
        ord.ind_kur_cd
      FROM
        ord_main AS ord
      WHERE
        ord.ord_no = @ordNo
    )
    ORDER BY
      up_date DESC NULLS LAST
    LIMIT
      1
  )
  ,sch_start_time AS (
       SELECT COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
       FROM mst_coop_ini AS ini
       CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
       WHERE facility_cd = @facilityCd
              AND is_del = ''0''
              AND COALESCE(info ->> ''key0'', '''') = @key0
              AND info ->> ''key1'' = ''COOP_CONFIG''
              AND info ->> ''key2'' = ''SCH_START_TIME''
)
select
  ''透析条件'' as detail_id
  , split_part(cond_arr.cond_row, ''-@-'', 1) as e01
  , split_part(cond_arr.cond_row, ''-@-'', 2) as e02
  , split_part(cond_arr.cond_row, ''-@-'', 3) as e03
  , split_part(cond_arr.cond_row, ''-@-'', 4) as e04
  , split_part(cond_arr.cond_row, ''-@-'', 5) as e05 
from
  ( 
    select
      regexp_split_to_table( 
        array_to_string( 
          array [
            concat(''001-@-透析開始時刻-@-'',
            CASE (SELECT value FROM sch_start_time)
              WHEN ''0'' THEN overlay(substring(mkr.kur_standard_start_time, 1, 4) PLACING '':'' FROM 3 FOR 0)
              WHEN ''1'' THEN CASE WHEN coalesce(ord.ind_treat_start_time,'''') <> '''' THEN overlay(ord.ind_treat_start_time PLACING '':'' FROM 3 FOR 0) END
            END,''-@--@-'') ,
            concat(''002-@-透析時間-@-'',ord.ind_cond_info->''1''->>''value'' ,''-@--@-分'') ,
            concat(''003-@-VA-@-'',trim(mva.in_hospital_cd_1),''-@-'',trim(mva.va_name),''-@-'') ,
            concat(''004-@-DW-@-'',physical->>''dw'',''-@-'',''-@-'',''kg'') ,
            concat(''005-@-目標体重-@-'',case ord.ind_cond_info->''3''->>''value'' when ''-1'' then physical->>''dw'' else ord.ind_cond_info->''3''->>''value'' end,''-@-'',''-@-'',''kg'') ,
            concat(''006-@-治療方法-@-'',mtt.in_hospital_cd_a1,''-@-'',mtt.treatment_name,''-@-'') ,
            concat(''007-@-除水量制限-@-'',to_char(to_number(ord.ind_cond_info->''4''->>''value'',''FM99.99''),''FM90.00''),''-@-'',''-@-'',''L''),
            concat(''008-@-ダイアライザー-@-'',trim(mdr.in_hospital_cd_1),''-@-'',trim(mdr.model_number),''-@-''),
            concat(''009-@-吸着カラム-@-'',trim(meqad.in_hospital_cd_1),''-@-'',trim(meqad.equipment_name),''-@-''),
            concat(''010-@-血流量-@-'',ord.ind_cond_info->''14''->>''value'',''-@-'',''-@-'',''mL/min''),
            concat(''011-@-抗凝固剤-@-'',(case ord.ind_cond_info->''25''->>''medicine_type'' when ''1'' then med25.in_hospital_cd_1 when ''2'' then mmx.in_hospital_cd_1 end) ,
                ''-@-'',(case ord.ind_cond_info->''25''->>''medicine_type'' when ''1'' then med25.medicine_name when ''2'' then mmx.medicine_mix_name end),''-@-'') ,
            concat(''012-@-抗凝固剤ワンショット量-@-'',(case when ord.ind_cond_info->''25''->>''value'' is null then null else to_char(to_number(ord.ind_cond_info->''26''->>''value'',''FM99.99''),''FM90.00'') end),''-@-'',''-@-'',
                (case ord.ind_cond_info->''25''->>''medicine_type'' when ''1'' then med25.unit when ''2'' then mmx.unit end)),
            concat(''013-@-抗凝固剤持続速度-@-'',(case when ord.ind_cond_info->''25''->>''value'' is null then null else to_char(to_number(ord.ind_cond_info->''27''->>''value'',''FM99.99''),''FM90.00'') end),''-@-'',''-@-'',
                (case ord.ind_cond_info->''25''->>''medicine_type'' when ''1'' then med25.unit when ''2'' then mmx.unit end),''/h''),
            concat(''014-@-抗凝固剤持続総量-@-'',(case when ord.ind_cond_info->''25''->>''value'' is null then null else to_char(to_number(ord.ind_cond_info->''28''->>''value'',''FM99.99''),''FM90.00'') end),''-@-'',''-@-'',
                (case ord.ind_cond_info->''25''->>''medicine_type'' when ''1'' then med25.unit when ''2'' then mmx.unit end)),
            concat(''015-@-IP使用選択-@-'',(case when ord.ind_cond_info->''25''->>''value'' is null then null else ord.ind_cond_info->''29''->>''value'' end),''-@-'',(case ord.ind_cond_info->''29''->>''value'' when ''1'' then ''使用する'' when ''0'' then ''使用しない'' else null end) ,''-@-''),
            concat(''016-@-IPワンショット量-@-'',(case when ord.ind_cond_info->''29''->>''value'' = ''1'' and ord.ind_cond_info->''25''->>''value'' is not null then ord.ind_cond_info->''31''->>''value'' else null end),''-@-'',''-@-'',''mL'') ,
            concat(''017-@-IP速度-@-'',(case when ord.ind_cond_info->''29''->>''value'' = ''1'' and ord.ind_cond_info->''25''->>''value'' is not null then ord.ind_cond_info->''32''->>''value'' else null end),''-@-'',''-@-'',''mL/h''),
            concat(''018-@-透析液-@-'',(case ord.ind_cond_info->''15''->>''medicine_type'' when ''1'' then trim(med15.in_hospital_cd_1) when ''2'' then trim(mmmx.in_hospital_cd_1) end) ,
                ''-@-'',(case ord.ind_cond_info->''15''->>''medicine_type'' when ''1'' then trim(med15.medicine_name) when ''2'' then trim(mmmx.medicine_mix_name) end),''-@-'') ,
            concat(''019-@-透析液流量-@-'',(case when ord.ind_cond_info->''15''->>''value'' is null then null else ord.ind_cond_info->''16''->>''value'' end),''-@-'',''-@-'',''mL/min'') ,
            concat(''020-@-透析液量-@-'',(case when ord.ind_cond_info->''15''->>''value'' is null then null else to_char(to_number(ord.ind_cond_info->''17''->>''value'',''FM99.99''),''FM90.00'') end),''-@-'',''-@-'',
                (case ord.ind_cond_info->''15''->>''medicine_type'' when ''1'' then trim(med15.unit) when ''2'' then trim(mmmx.unit) end)) ,
            concat(''021-@-透析液温度-@-'',(case when ord.ind_cond_info->''15''->>''value'' is null then null else ord.ind_cond_info->''18''->>''value'' end),''-@-'',''-@-'',''℃'') ,
            concat(''022-@-補液-@-'', (case ord.ind_cond_info->''19''->>''medicine_type'' when ''1'' then med19.in_hospital_cd_1 when ''2'' then mmmmx.in_hospital_cd_1 end),
                ''-@-'',(case ord.ind_cond_info->''19''->>''medicine_type'' when ''1'' then med19.medicine_name when ''2'' then mmmmx.medicine_mix_name end),''-@-'') ,
            concat(''023-@-補液量-@-'',(case when ord.ind_cond_info->''19''->>''value'' is null then null else
                (case ord.ind_cond_info->''20''->>''value'' when ''-1'' then 
                    TO_CHAR(TRUNC((TO_NUMBER(ord.ind_cond_info->''24''->>''value'', ''FM99.99'') * (TO_NUMBER(ord.ind_cond_info->''1''->>''value'', ''FM999999'') / 60)) + 0.09, 1), ''FM999999999990.0'')
                else ord.ind_cond_info->''20''->>''value'' end) end),''-@-'',''-@-'',''L'') ,
            concat(''024-@-補液選択-@-'',(case when ord.ind_cond_info->''19''->>''value'' is null then null else ord.ind_cond_info->''21''->>''value'' end),''-@-'',(case ord.ind_cond_info->''21''->>''value'' when ''1'' then ''前補液'' when ''0'' then ''後補液'' else null end),''-@-'') ,
            concat(''025-@-補液温度-@-'',(case when ord.ind_cond_info->''19''->>''value'' is null then null else ord.ind_cond_info->''23''->>''value'' end),''-@-'',''-@-'',''℃'') ,
            concat(''029-@-シングルニードル電源-@-'',ord.ind_cond_info->''12''->>''value'',''-@-'',(case ord.ind_cond_info->''12''->>''value'' when ''1'' then ''使用する'' when ''0'' then ''使用しない'' else null end),''-@-'') ,
            concat(''030-@-補液使用数-@-'',(case when ord.ind_cond_info->''19''->>''value'' is null then null else to_char(to_number(ord.ind_cond_info->''22''->>''value'',''FM99.99''),''FM90.00'') end),''-@-'',''-@-'',
                (case ord.ind_cond_info->''19''->>''medicine_type'' when ''1'' then med19.unit when ''2'' then mmmmx.unit end)) ,
            concat(''031-@-IPスタート-@-'',(case when ord.ind_cond_info->''29''->>''value'' = ''1'' and ord.ind_cond_info->''25''->>''value'' is not null then ord.ind_cond_info->''30''->>''value'' else null end),''-@-'',(case ord.ind_cond_info->''30''->>''value'' when ''0'' then ''手動'' when ''1'' then ''自動'' else null end),''-@-''),
            concat(''032-@-自動ワンショット-@-'',(case when ord.ind_cond_info->''29''->>''value'' = ''1'' and ord.ind_cond_info->''25''->>''value'' is not null then ord.ind_cond_info->''34''->>''value'' else null end),''-@-'',(case ord.ind_cond_info->''34''->>''value'' when ''1'' then ''使用する'' when ''0'' then ''使用しない'' else null end),''-@-''),
            concat(''033-@-IP電源自動切り-@-'',(case when ord.ind_cond_info->''29''->>''value'' = ''1'' and ord.ind_cond_info->''25''->>''value'' is not null then ord.ind_cond_info->''35''->>''value'' else null end),''-@-'',(case ord.ind_cond_info->''35''->>''value'' when ''1'' then ''入り'' when ''0'' then ''切り'' else null end),''-@-''),
            concat(''034-@-IP電源自動切り時間-@-'',(case when 
                ord.ind_cond_info->''35''->>''value'' = ''1'' and ord.ind_cond_info->''29''->>''value'' = ''1'' and ord.ind_cond_info->''25''->>''value'' is not null then ord.ind_cond_info->''36''->>''value'' else null end),''-@-'',''-@-'',''分'') ,
            concat(''035-@-IP電源OKモニタ切り-@-'',(case when ord.ind_cond_info->''29''->>''value'' = ''1'' and ord.ind_cond_info->''25''->>''value'' is not null then ord.ind_cond_info->''37''->>''value'' else null end),''-@-'',(case ord.ind_cond_info->''37''->>''value'' when ''1'' then ''入り'' when ''0'' then ''切り'' else null end),''-@-''),
            concat(''036-@-IP電源OKモニタ切り時間-@-'',(case when 
                ord.ind_cond_info->''37''->>''value'' = ''1'' and ord.ind_cond_info->''29''->>''value'' = ''1'' and ord.ind_cond_info->''25''->>''value'' is not null then ord.ind_cond_info->''38''->>''value'' else null end),''-@-'',''-@-'',''分''),
            concat(''037-@-IP速度最大値-@-'',(case when ord.ind_cond_info->''29''->>''value'' = ''1'' and ord.ind_cond_info->''25''->>''value'' is not null then ord.ind_cond_info->''33''->>''value'' else null end),''-@-'',''-@-'',''mL/h''),
            concat(''038-@-補液速度-@-'',(case when ord.ind_cond_info->''19''->>''value'' is null then null else
                (case ord.ind_cond_info->''24''->>''value'' when ''-1'' then 
                    TO_CHAR(TRUNC((TO_NUMBER(ord.ind_cond_info->''20''->>''value'', ''FM99.9'') / (TO_NUMBER(ord.ind_cond_info->''1''->>''value'', ''FM999999'') / 60)) + 0.009, 2), ''FM999999999990.00'')
                else ord.ind_cond_info->''24''->>''value'' end) end),''-@-'',''-@-'',''L/h''),
            concat(''039-@-1次膜-@-'',meqpr.in_hospital_cd_1,''-@-'',trim(meqpr.equipment_name),''-@-'') ,
            concat(''040-@-2次膜-@-'',meqse.in_hospital_cd_1,''-@-'',trim(meqse.equipment_name),''-@-'')
          ]
          , ''-@@-''
        ) 
        , ''-@@-''
      ) as cond_row 
    from
      ord_main_max as ord 
      left outer join mst_equipment as meqa 
        on meqa.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''9'' ->> ''value'', ''FM999999999999'') 
      left outer join mst_equipment as meqv 
        on meqv.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''10'' ->> ''value'', ''FM999999999999'') 
      left outer join mst_equipment as meqsn 
        on meqsn.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''11'' ->> ''value'', ''FM999999999999'') 
      left outer join mst_equipment as meqad 
        on meqad.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''6'' ->> ''value'', ''FM999999999999'') 
      left outer join mst_equipment as meqpr 
        on meqpr.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''7'' ->> ''value'', ''FM999999999999'') 
      left outer join mst_equipment as meqbc 
        on meqbc.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''13'' ->> ''value'', ''FM999999999999'') 
      left outer join mst_equipment as meqse 
        on meqse.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''8'' ->> ''value'', ''FM999999999999'') 
      left outer join mst_medicine as med15 
        on med15.medicine_cd = TO_NUMBER( ord.ind_cond_info -> ''15'' ->> ''value'', ''FM999999999999'') 
      left outer join mst_medicine as med19 
        on med19.medicine_cd = TO_NUMBER( ord.ind_cond_info -> ''19'' ->> ''value'', ''FM999999999999'') 
      left outer join mst_medicine as med25 
        on med25.medicine_cd = TO_NUMBER( ord.ind_cond_info -> ''25'' ->> ''value'', ''FM999999999999'') 
      left outer join mst_treatment as mtt 
        on mtt.treatment_cd = ord.ind_treatment_cd 
      left outer join mst_dialyzer as mdr 
        on mdr.dialyzer_cd = TO_NUMBER( ord.ind_cond_info -> ''5'' ->> ''value'', ''FM999999999999'') 
      left outer join mst_va as mva 
        on mva.va_cd = TO_NUMBER( ord.ind_cond_info -> ''2'' ->> ''value'', ''FM999999999999'') 
      left outer join mst_bed as mbd 
        on mbd.bed_cd = ord.ind_bed_cd
      left outer join mst_medicine_mix as mmx 
        on mmx.medicine_mix_cd = TO_NUMBER( ord.ind_cond_info -> ''25'' ->> ''value'', ''FM999999999999'') 
      left outer join mst_medicine_mix as mmmx 
        on mmmx.medicine_mix_cd = TO_NUMBER( ord.ind_cond_info -> ''15'' ->> ''value'', ''FM999999999999'') 
      left outer join mst_medicine_mix as mmmmx 
        on mmmmx.medicine_mix_cd = TO_NUMBER( ord.ind_cond_info -> ''19'' ->> ''value'', ''FM999999999999'') 
      left outer join pat_unique as puq 
        on puq.pat_id = ord.pat_id 
      LEFT OUTER JOIN mst_kur AS mkr
        ON mkr.kur_cd = ord.ind_kur_cd
      LEFT JOIN lateral json_array_elements(puq.physical_info ::json) physical 
        ON physical ->> ''exam_date'' = ( 
        select
          max(physical2 ->> ''exam_date'') 
        from
          ord_main_max ord2
          , pat_unique puq2 
          cross join lateral json_array_elements(puq2.physical_info ::json) physical2 
        where
          TO_CHAR(CAST(physical2 ->> ''exam_date'' AS TIMESTAMP), ''YYYYMMDD'') <= ord.treat_date
          and COALESCE(physical2 ->> ''dw'', ''ZERO'') <> ''ZERO'' 
          and ord.pat_id = puq2.pat_id
      ) 
    where
      ord.ord_no = @ordNo
  ) cond_arr 
where
   length(split_part(cond_arr.cond_row, ''-@-'', 3)) > 0
OR (split_part(cond_arr.cond_row, ''-@-'', 1) IN (''003'', ''006'', ''008'', ''009'', ''011'', ''018'', ''022'', ''039'', ''040'') AND length(split_part(cond_arr.cond_row, ''-@-'', 4)) > 0) -- 連携コードを出力するものは連携コードが設定されてなくても、登録(名称)があれば出力する
;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'SSI予約）条件繰り返し部', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-502000, '  SELECT
    (
      CASE
        WHEN NULLIF(@isDie, '''') = ''1'' THEN 2
        WHEN info ->> ''value'' = @inOutClass THEN 1
        WHEN @inOutClass = ''NoXmlTag'' THEN 3
        ELSE 0
      END
    ) AS in_out
FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
WHERE
  facility_cd = @facilityCd
  AND is_del = ''0''
  AND info ->> ''key0'' = @key0
  AND info ->> ''key1'' = ''SSI_PATIENT_RECV''
  AND info ->> ''key2'' = ''CONV_INOUT_1''
  ;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの患者個人情報の取得の新規', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-502002, 'SELECT
    taboo_allergy_cd AS taboo_allergy_cd,
    content AS content
FROM
    mst_taboo_allergy
WHERE
    facility_cd = @facilityCd
    AND in_hospital_cd_1 = @tabooAllergyInfo.tabooAllergyCd
    and is_del = ''0''
    and is_disp = ''1''', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの患者プロファイル_禁忌アレルギーマスタ取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-502003, 'SELECT
  1
FROM
  pat_personal_main
WHERE
  is_del = ''0''
  AND hosp_pat_id = @hospPatId
  AND facility_cd = @facilityCd
  AND is_die = ''1''', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの患者プロファイル_既存死亡患者存在判定', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-503000, 'WITH  ord_main_max AS (
    (
      SELECT
        ord.ord_no,
        ord.del_date as up_date,
        ord.treat_date,
        ord.ind_kur_cd,
        ord.ind_bed_cd, 
        ord.ind_cond_info -> ''1'' ->> ''value'' AS dialysis_time_m
      FROM
        ord_main_restore AS ord,
        sys_coop_journal as journal
      WHERE
        ord.ord_no = @ordNo
        AND journal.ctl_no = @ctlNo
        AND ord.ord_no = journal.ord_no
        AND journal.reg_date >= ord.del_date
      ORDER BY
        del_date DESC
      LIMIT
        1
    )
    UNION
    (
      SELECT
        ord.ord_no,
        ord.rst_edition_date as up_date,
        ord.treat_date,
        ord.ind_kur_cd,
        ord.ind_bed_cd,
        ord.ind_cond_info -> ''1'' ->> ''value'' AS dialysis_time_m
      FROM
        ord_main AS ord
      WHERE
        ord.ord_no = @ordNo
    )
    ORDER BY
      up_date DESC NULLS LAST
    LIMIT
      1
  )
, get_bed_code_conv AS (
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value,
        0 AS ord
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE
        ini.facility_cd = @facilityCd
        AND ini.is_del = ''0''
        AND ini.is_disp = ''1''
        AND COALESCE(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' = ''SSI''
        AND info ->> ''key2'' = ''BED_CODE_CONV''
)
SELECT ord.treat_date                                               AS dialysis_date,
       COALESCE(mkr.in_hospital_cd_1, '''')                           AS kur_cd1,
       COALESCE(mkr.kur_name, '''')                                   AS kur_name,
       CASE (SELECT value FROM get_bed_code_conv)
       WHEN ''2'' THEN COALESCE(mbd.in_hospital_cd_2, '''')
       ELSE COALESCE(mbd.in_hospital_cd_1, '''')
       END                                                          AS bed_cd1,
       COALESCE(mbd.bed_name, '''')                                      AS bed_name,
       ord.dialysis_time_m                                          AS dialysis_time_m
FROM ord_main_max AS ord
         LEFT OUTER JOIN mst_bed AS mbd ON mbd.bed_cd = ord.ind_bed_cd
         LEFT OUTER JOIN mst_kur AS mkr ON mkr.kur_cd = ord.ind_kur_cd', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'SSI）指示）透析条件', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-503001, 'select 
	rst_dialysis_state 
from 
	ord_main
where 
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = @facilityCd 
  AND treat_date = @treatDate
  AND rst_dialysis_state >= ''1''', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのオーダ受け（透析オーダー削除条件チェック）', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-503002, 'select 
	rst_dialysis_state 
from 
	ord_main
where 
  is_del = ''0'' 
  AND facility_cd = @facilityCd 
  AND pat_id = @patId 
  AND treat_date = @treatDate
  AND rst_dialysis_state = ''3''', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのオーダ受け投薬オーダー条件チェック）', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-504000, 'WITH  ord_main_max AS (
    (
      SELECT
        ord.ord_no,
        ord.del_date as up_date2,
        ord.ind_schedule_user_info,
        ord.pull_leave_amount,
        ord.rst_accept_date,
        ord.rst_bed_cd,
        ord.rst_charge_user_info,
        ord.rst_cond_info,
        ord.rst_course_cd,
        ord.rst_course_name,
        ord.rst_dialysis_cnt,
        ord.rst_dw,
        ord.rst_end_date,
        ord.rst_in_out_class,
        ord.rst_kur_cd,
        ord.rst_kur_name,
        ord.rst_machine_name,
        ord.rst_machine_no,
        ord.rst_puncture_user_info,
        ord.rst_return_home_date,
        ord.rst_return_user_info,
        ord.rst_running_time,
        ord.rst_start_date,
        ord.rst_treatment_cd,
        ord.rst_treatment_name,
        ord.rst_ward_cd,
        ord.rst_ward_name,
        ord.rst_weight_info,
        ord.treat_date,
        ord.up_date
      FROM
        ord_main_restore AS ord,
        sys_coop_journal as journal
      WHERE
        ord.ord_no = @ordNo
        AND journal.ctl_no = @ctlNo
        AND ord.ord_no = journal.ord_no
        AND journal.reg_date >= ord.del_date
      ORDER BY
        del_date DESC
      LIMIT
        1
    )
    UNION
    (
      SELECT
        ord.ord_no,
        ord.rst_edition_date as up_date2,
        ord.ind_schedule_user_info,
        ord.pull_leave_amount,
        ord.rst_accept_date,
        ord.rst_bed_cd,
        ord.rst_charge_user_info,
        ord.rst_cond_info,
        ord.rst_course_cd,
        ord.rst_course_name,
        ord.rst_dialysis_cnt,
        ord.rst_dw,
        ord.rst_end_date,
        ord.rst_in_out_class,
        ord.rst_kur_cd,
        ord.rst_kur_name,
        ord.rst_machine_name,
        ord.rst_machine_no,
        ord.rst_puncture_user_info,
        ord.rst_return_home_date,
        ord.rst_return_user_info,
        ord.rst_running_time,
        ord.rst_start_date,
        ord.rst_treatment_cd,
        ord.rst_treatment_name,
        ord.rst_ward_cd,
        ord.rst_ward_name,
        ord.rst_weight_info,
        ord.treat_date,
        ord.up_date
      FROM
        ord_main AS ord
      WHERE
        ord.ord_no = @ordNo
    )
    ORDER BY
      up_date DESC NULLS LAST
    LIMIT
      1
  )
  ,KOU_COAG_RESOLVE_MODE_cd AS(
SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL jsON_array_elements(ini.coop_ini_info ::jsON) info
  WHERE
    facility_cd = @facilityCd

    AND is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = @key0
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''KOU_COAG_RESOLVE_MODE''
)
, get_bed_code_conv AS (
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value,
        0 AS ord
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE
        ini.facility_cd = @facilityCd
        AND ini.is_del = ''0''
        AND ini.is_disp = ''1''
        AND COALESCE(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' = ''SSI''
        AND info ->> ''key2'' = ''BED_CODE_CONV''
)
SELECT
  ord.ord_no AS ord_no,
  ord.treat_date AS treat_date,--透析日
  COALESCE(mkr.in_hospital_cd_1, '''') AS kur_cd1,--クール
  COALESCE(ord.rst_kur_name, '''') AS kur_name,--クール名
  COALESCE(ord.rst_dialysis_cnt, 0) AS dialysis_cnt,--透析回数
  COALESCE(ord.rst_machine_no, 0) AS machine_no,--装置番号
  COALESCE(ord.rst_machine_name, '''') AS machine_name,--装置名
  COALESCE(ord.rst_course_name, '''') AS course_name,--診療科名
  COALESCE(mcs.in_hospital_cd_1, '''') AS course_cd,--診療科コード１
  COALESCE(ord.rst_ward_name, '''') AS ward_name,--病棟名
  COALESCE(mwd.in_hospital_cd_1, '''') AS ward_cd,--病棟コード１
  COALESCE(ord.rst_treatment_name, '''') AS treatment_name,--治療項目
  COALESCE(mtt.in_hospital_cd_a1, '''') AS treatment_cd,--治療項目コード１
  (CASE  mtt.device_mode 
    WHEN ''0'' THEN
      ''HD'' 
    WHEN ''1'' THEN
      ''ECUM'' 
    WHEN ''2'' THEN
      ''HDF'' 
    WHEN ''3'' THEN
      ''HF'' 
    WHEN ''4'' THEN
      ''HD+補液'' 
    WHEN ''5'' THEN
      ''ECUM+補液'' 
    WHEN ''6'' THEN
      ''AFBF'' 
    WHEN ''7'' THEN
      ''OHDF'' 
    WHEN ''8'' THEN
      ''OHF'' 
    WHEN ''9'' THEN
      ''特殊浄化'' 
    WHEN ''10'' THEN
      ''i-HDF'' ELSE''不明'' 
    END) AS device_mode,--装置モード
  COALESCE(ord.rst_dw, 0) AS dw,--dw
CASE (SELECT value FROM get_bed_code_conv)
       WHEN ''2'' THEN COALESCE(mbd.in_hospital_cd_2, '''')
       ELSE COALESCE(mbd.in_hospital_cd_1, '''')
       END AS bed_cd1,
  COALESCE(mbd.bed_name, '''') AS bed_name,--ベッド名
  COALESCE(( CASE mbd.shunt_position WHEN ''0'' THEN ''両方'' WHEN ''1'' THEN ''左'' WHEN ''2'' THEN ''右'' WHEN ''3'' THEN ''なし'' ELSE''不明'' END ), '''') AS shunt_position,--シャント位置名称
  COALESCE(( CASE mbd.is_infection WHEN ''0'' THEN ''感染症無'' WHEN ''1'' THEN ''感染症対応'' ELSE''不明'' END ), '''') AS is_infection,--感染症フラグ
  COALESCE(( CASE mbd.emergency_class WHEN ''0'' THEN ''通常ベッド'' WHEN ''1'' THEN ''救急ベッド'' ELSE''不明'' END ), '''') AS emergency_class,--救急対応
  ord.rst_accept_date AS accept_date,--受付日時
  ord.rst_start_date AS start_date,--透析開始日時
  COALESCE(TO_CHAR( ord.rst_start_date, ''YYYYMMDDHH24MISS'' ), '''') AS start_date14,
  ord.rst_end_date AS end_date,--透析終了日時
  COALESCE(TO_CHAR( ord.rst_end_date, ''YYYYMMDDHH24MISS'' ), '''') AS end_date14,
  ord.rst_return_home_date AS return_home_date,--帰宅時刻
  ord.rst_in_out_class AS in_out_class,--入外コード
  COALESCE(( CASE ord.rst_in_out_class WHEN ''0'' THEN ''外来'' WHEN ''1'' THEN ''入院'' ELSE NULL END ), '''') AS in_out_name,--入外区分
  COALESCE(( CASE ord.rst_in_out_class WHEN ''0'' THEN ''1'' WHEN ''1'' THEN ''2'' ELSE NULL END ), '''') AS in_out_f,--入外区分（F)
  COALESCE(( CASE ord.rst_in_out_class WHEN ''0'' THEN ''1'' WHEN ''1'' THEN ''3'' ELSE NULL END ), '''') AS in_out_s,--入外区分（S)
  COALESCE(RIGHT ( ''00'' || TRUNC( TO_NUMBER( ord.rst_cond_info -> ''1'' ->> ''value'', ''FM999999'' ) / 60, 0 ), 2 ) || '':'' || RIGHT ( ''00'' || MOD ( TO_NUMBER( ord.rst_cond_info -> ''1'' ->> ''value'', ''FM999999'' ), 60 ), 2 ), '''') AS treatment_time,
  COALESCE(ord.rst_cond_info -> ''1'' ->> ''value'', '''') AS treatment_time_m,
  COALESCE(ord.rst_cond_info -> ''2'' ->> ''value_name_1'', '''') AS va,--シャント
  COALESCE(mva.in_hospital_cd_1, '''') AS va_cd1,--シャントコード１
  COALESCE(( CASE mva.va_direct WHEN ''0'' THEN ''両方'' WHEN ''1'' THEN ''左'' WHEN ''2'' THEN ''右'' WHEN ''3'' THEN ''なし'' ELSE''不明'' END ), '''') AS va_direct,--シャント方向
  COALESCE(ord.rst_cond_info -> ''3'' ->> ''value'', '''') AS target_weight,
  COALESCE(( CASE WHEN ord.rst_cond_info -> ''3'' ->> ''value'' = ''-1'' THEN ''DWと同じ'' ELSE''目標体重指定'' END ), '''') AS target_mode,--目標体重指定設定
  COALESCE(TO_CHAR( TO_NUMBER( ord.rst_cond_info -> ''4'' ->> ''value'', ''FM99.99'' ), ''FM90.99'' ), '''') AS water_removal_amount_limit,
  COALESCE(ord.rst_cond_info -> ''5'' ->> ''value_name_1'', '''') AS dialyzer,
  COALESCE(TRIM ( mdr.in_hospital_cd_1 ), '''') AS dialyzer_cd1,--ダイアライザコード１
  COALESCE(mdr.maker, '''') AS dialyzer_maker,--ダイアライザメーカ
  COALESCE(mdr.function_class, '''') AS function_class,--ダイアライザ機能分類
  COALESCE(mdr.area, 0) AS dialyzer_area,--ダイアライザ面積
  COALESCE(mdr.ufr, 0) AS dialyzer_ufr,--ダイアライザUFR
  COALESCE(mdr.koa, 0) AS dialyzer_KoA,--ダイアライザKoA
  COALESCE(mdr.material, '''') AS dialyzer_material,--ダイアライザ材質
  COALESCE(( CASE mdr.membrane_wash WHEN ''0'' THEN ''使用しない'' WHEN ''1'' THEN ''使用する'' ELSE''不明'' END ), '''') AS membrane_wash,--膜洗浄（中空糸）
  COALESCE(( CASE mdr.wetdry WHEN ''0'' THEN ''不明'' WHEN ''1'' THEN ''WET'' WHEN ''2'' THEN ''DRY'' ELSE''不明'' END ), '''') AS dialyzer_wetdry,--WET/DRY
  COALESCE(mdr.substituent_wash_amt, 0) AS substituent_wash_amt,--置換洗浄量（透析液）
  COALESCE(mdr.gas_purge_time, 0) AS gas_purge_time,--ガスパージ時間
  COALESCE(mdr.urea_clearance, 0) AS urea_clearance,--尿素クリアランス
  COALESCE(mdr.alqd_flood_vol, 0) AS alqd_flood_vol,--透析液流量
  COALESCE(mdr.bloodamt, 0) AS dialyzer_bloodamt,--血流量
  COALESCE(mdr.sterilization, '''') AS sterilization,--滅菌
  COALESCE(ord.rst_cond_info -> ''6'' ->> ''value_name_1'', '''') AS adsorption_column,
  COALESCE(meqad.in_hospital_cd_1, '''') AS ad_cd1,--吸着器コード１
  COALESCE(ord.rst_cond_info -> ''7'' ->> ''value_name_1'', '''') AS primary_film,
  COALESCE(meqpr.in_hospital_cd_1, '''') AS pr_cd1,--1次膜コード１
  COALESCE(ord.rst_cond_info -> ''8'' ->> ''value_name_1'', '''') AS secondary_film,
  COALESCE(meqse.in_hospital_cd_1, '''') AS se_cd1,--2次膜コード１
  COALESCE(ord.rst_cond_info -> ''9'' ->> ''value_name_1'', '''') AS puncture_needle_a,
  COALESCE(meqa.in_hospital_cd_1, '''') AS a_cd1,--穿刺針Aコード１
  COALESCE(ord.rst_cond_info -> ''10'' ->> ''value_name_1'', '''') AS puncture_needle_v,
  COALESCE(meqv.in_hospital_cd_1, '''') AS v_cd1,--穿刺針Vコード１
  COALESCE(ord.rst_cond_info -> ''11'' ->> ''value_name_1'', '''') AS puncture_needle_sn,
  COALESCE(meqsn.in_hospital_cd_1, '''') AS sn_cd1,--穿刺針SNコード１
  COALESCE(( CASE ord.rst_cond_info -> ''12'' ->> ''value'' WHEN ''1'' THEN ''有り'' WHEN ''0'' THEN ''無し'' ELSE NULL END ), '''') AS single_needle,
  COALESCE(ord.rst_cond_info -> ''13'' ->> ''value'', '''') AS blood_circuit,
  COALESCE(meqbc.in_hospital_cd_1, '''') AS bc_cd1,--血液回路コード１
  COALESCE(ord.rst_cond_info -> ''14'' ->> ''value'', '''') AS blood_flow,--血流量
  COALESCE(ord.rst_cond_info -> ''15'' ->> ''value_name_1'', '''') AS dialysate,
  COALESCE(( CASE ord.rst_cond_info -> ''15'' ->> ''medicine_type'' WHEN ''1'' THEN med15.in_hospital_cd_1 WHEN ''2'' THEN mmmx.in_hospital_cd_1 END ), '''') AS ds_cd,
  COALESCE(ord.rst_cond_info -> ''16'' ->> ''value'', '''') AS dialysate_flow_rate,
  COALESCE(ord.rst_cond_info -> ''17'' ->> ''value'', '''') AS dialysate_amount,
  COALESCE(ord.rst_cond_info -> ''17'' ->> ''unit'', '''') AS dialysate_amount_unit,
  COALESCE(ord.rst_cond_info -> ''18'' ->> ''value'', '''') AS dialysate_temperature,
  COALESCE(ord.rst_cond_info -> ''19'' ->> ''value_name_1'', '''') AS fluid_replacement,
--  ds_cd1抗凝固剤コード１繰り返すので取り除きます
   COALESCE(( CASE ord.rst_cond_info -> ''19'' ->> ''medicine_type'' WHEN ''1'' THEN med19.in_hospital_cd_1 WHEN ''2'' THEN mmmmx.in_hospital_cd_1 END ), '''') AS ds_cd1,--補液コード１
  COALESCE(ord.rst_cond_info -> ''20'' ->> ''value'', '''') AS fluid_replacement_amount,
  COALESCE(( CASE ord.rst_cond_info -> ''21'' ->> ''value'' WHEN ''1'' THEN ''前補液'' WHEN ''0'' THEN ''後補液'' ELSE NULL END ), '''') AS fluid_replacement_timing,
  COALESCE(ord.rst_cond_info -> ''21'' ->> ''value'', '''') AS fluid_replacement_timing_ssi,
  COALESCE(ord.rst_cond_info -> ''22'' ->> ''value'', '''') AS fluid_replacement_use_count,
  COALESCE(ord.rst_cond_info -> ''22'' ->> ''unit'', '''') AS fluid_replacement_use_count_unit,
  COALESCE(ord.rst_cond_info -> ''23'' ->> ''value'', '''') AS fluid_replacement_temperature,
  COALESCE(ord.rst_cond_info -> ''24'' ->> ''value'', '''') AS fluid_replacement_speed,
  COALESCE(ord.rst_cond_info -> ''25'' ->> ''value_name_1'', '''') AS anti_coagulant,
--   COALESCE(( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''1'' THEN med25.in_hospital_cd_1 WHEN ''2'' THEN mmx.in_hospital_cd_1 END ), '''') AS ds_cd1,--抗凝固剤コード１
  COALESCE(( CASE WHEN ord.rst_cond_info -> ''25'' ->> ''medicine_type'' =''1'' THEN med25.in_hospital_cd_1 WHEN
  ord.rst_cond_info -> ''25'' ->> ''medicine_type'' = ''2'' 
  and (select (SELECT staff_cd FROM KOU_COAG_RESOLVE_MODE_cd) in (''0'',''1''))
  THEN mmx.in_hospital_cd_1 END ), '''') AS ds_cd2,--抗凝固剤コード１
  COALESCE(ord.rst_cond_info -> ''26'' ->> ''value'', '''') AS anti_coagulant_one_shot_amount,
--   COALESCE(ord.rst_cond_info -> ''26'' ->> ''unit'', '''') AS anti_coagulant_one_shot_amount_unit,
 case when (select (SELECT staff_cd FROM KOU_COAG_RESOLVE_MODE_cd)) in (''0'',''1'') or 
ord.rst_cond_info -> ''25'' ->> ''medicine_type'' = ''1''
then 
 COALESCE(ord.rst_cond_info -> ''26'' ->> ''unit'', '''') else '''' end AS anti_coagulant_one_shot_amount_unit,
  COALESCE(ord.rst_cond_info -> ''27'' ->> ''value'', '''') AS anti_coagulant_sustained_speed,
  COALESCE(ord.rst_cond_info -> ''27'' ->> ''unit'', '''') AS anti_coagulant_sustained_speed_unit,
  COALESCE(ord.rst_cond_info -> ''28'' ->> ''value'', '''') AS anti_coagulant_sustained_amount,
  COALESCE(ord.rst_cond_info -> ''28'' ->> ''unit'', '''') AS anti_coagulant_sustained_amount_unit,
  COALESCE(TO_NUMBER( ord.rst_cond_info -> ''26'' ->> ''value'', ''FM999999999999'' ) + TO_NUMBER( ord.rst_cond_info -> ''28'' ->> ''value'', ''FM999999999999'' ), 0) AS anti_coagulant_total_amount,--抗凝固剤総量
  COALESCE(( CASE ord.rst_cond_info -> ''29'' ->> ''value'' WHEN ''1'' THEN ''使用する'' WHEN ''0'' THEN ''使用しない'' ELSE NULL END ), '''') AS ip,
  COALESCE(( CASE ord.rst_cond_info -> ''30'' ->> ''value'' WHEN ''0'' THEN ''手動'' WHEN ''1'' THEN ''自動'' ELSE NULL END ), '''') AS ip_start,
  COALESCE(ord.rst_cond_info -> ''30'' ->> ''value'', '''') AS ip_start_ssi,
  COALESCE(ord.rst_cond_info -> ''31'' ->> ''value'', '''') AS ip_one_short_amount,
  COALESCE(ord.rst_cond_info -> ''32'' ->> ''value'', '''') AS ip_speed,
  COALESCE(ord.rst_cond_info -> ''33'' ->> ''value'', '''') AS ip_speed_max,
  COALESCE(( CASE ord.rst_cond_info -> ''34'' ->> ''value'' WHEN ''1'' THEN ''使用する'' WHEN ''0'' THEN ''使用しない'' ELSE NULL END ), '''') AS auto_one_shot,
  COALESCE(ord.rst_cond_info -> ''34'' ->> ''value'', '''') AS auto_one_shot_ssi,
  COALESCE(( CASE ord.rst_cond_info -> ''35'' ->> ''value'' WHEN ''1'' THEN ''入'' WHEN ''0'' THEN ''切'' ELSE NULL END ), '''') AS ip_auto_off,
  COALESCE(ord.rst_cond_info -> ''35'' ->> ''value'', '''') AS ip_auto_off_ssi,
  COALESCE(ord.rst_cond_info -> ''36'' ->> ''value'', '''') AS ip_auto_off_time,
  COALESCE(( CASE ord.rst_cond_info -> ''37'' ->> ''value'' WHEN ''1'' THEN ''入'' WHEN ''0'' THEN ''切'' ELSE NULL END ), '''') AS ip_monitor_auto_off,
  COALESCE(ord.rst_cond_info -> ''37'' ->> ''value'', '''') AS ip_monitor_auto_off_ssi,
  COALESCE(ord.rst_cond_info -> ''38'' ->> ''value'', '''') AS ip_monitor_auto_off_time,
  ord.rst_puncture_user_info -> ''date'' AS puncture_date,--穿刺時刻
  COALESCE(ord.rst_puncture_user_info ->> ''user_id_1'', '''') AS puncture1_id,--穿刺者１ID
  COALESCE(concat ( ord.rst_puncture_user_info ->> ''user_last_name_1'', ord.rst_puncture_user_info ->> ''user_first_name_1'' ), '''') AS puncture1_name,--穿刺者1
  ord.rst_puncture_user_info -> ''date_1''AS puncture1_date,--穿刺時刻1
  COALESCE(ord.rst_puncture_user_info ->> ''user_id_2'', '''') AS puncture2_id,--穿刺者２ID
  COALESCE(concat ( ord.rst_puncture_user_info ->> ''user_last_name_2'', ord.rst_puncture_user_info ->> ''user_first_name_2'' ), '''') AS puncture2_name,--穿刺者2
  ord.rst_puncture_user_info -> ''date_2'' AS puncture2_date,--穿刺時刻2
  ord.rst_return_user_info -> ''date'' AS return_date,--回収時刻
  COALESCE(ord.rst_return_user_info ->> ''user_id_1'', '''') AS return1_id,--回収者１ID
  COALESCE(concat ( ord.rst_return_user_info ->> ''user_last_name_1'', ord.rst_return_user_info ->> ''user_first_name_1'' ), '''') AS return1_name,--回収者1
  ord.rst_return_user_info -> ''date_1'' AS return1_date,--回収時刻1
  COALESCE(ord.rst_return_user_info ->> ''user_id_2'', '''') AS return2_id,--回収者２ID
  COALESCE(concat ( ord.rst_return_user_info ->> ''user_last_name_2'', ord.rst_return_user_info ->> ''user_first_name_2'' ), '''') AS return2_name,--回収者2
  ord.rst_return_user_info -> ''date_2'' AS return2_date,--回収時刻2
  COALESCE(ord.rst_charge_user_info ->> ''user_id_1'', '''') AS charge1_id,--担当者１ID
  COALESCE(concat ( ord.rst_charge_user_info ->> ''user_last_name_1'', ord.rst_charge_user_info ->> ''user_first_name_1'' ), '''') AS charge1_name,--担当者1
  ord.rst_charge_user_info -> ''date_1'' AS charge1_date,--担当時刻1
  COALESCE(ord.rst_charge_user_info ->> ''user_id_2'', '''') AS charge2_id,--担当者２ID
  COALESCE(concat ( ord.rst_charge_user_info ->> ''user_last_name_2'', ord.rst_charge_user_info ->> ''user_first_name_2'' ), '''') AS charge2_name,--担当者2
  ord.rst_charge_user_info -> ''date_2'' AS charge2_date,--担当時刻2
  ord.rst_running_time AS running_time,--透析運転時間
  TRIM((to_char((to_number(substring(to_char(ord.rst_end_date-ord.rst_start_date,''HH24MI''),1,2),''99'') * 60 + to_number(substring(to_char(ord.rst_end_date-ord.rst_start_date,''HH24MI''),3,2),''99'')),''999999999''))) AS running_time_cal,--透析運転時間_計算
  COALESCE(ord.pull_leave_amount, 0) AS pull_leave_amount,--引き残し量
  COALESCE(TO_CHAR( TO_NUMBER( ord.rst_weight_info ->> ''weight_before'', ''FM999.99'' ), ''FM990.99'' ), '''') AS weight_before,
  COALESCE(TO_CHAR( TO_NUMBER( ord.rst_weight_info ->> ''weight_after'', ''FM999.99'' ), ''FM990.99'' ), '''') AS weight_after,
  CASE WHEN LENGTH(TO_CHAR(ord.ord_no, ''FM9999999999999999999'')) >= 12 THEN TO_CHAR(ord.ord_no, ''FM9999999999999999999'') ELSE LPAD(TO_CHAR(ord.ord_no, ''FM9999999999999999999''), 12, ''0'') END AS ord_no12,
  COALESCE(TO_CHAR( ord.up_date, ''YYYYMMDDHH24MISS'' ), '''') AS up_date14,
  COALESCE(ord.ind_schedule_user_info ->> ''ind_user_id'', '''') AS ind_user_id,
  COALESCE(TO_CHAR( ord.up_date, ''YYYYMMDD'' ), '''') AS up_date8,
  COALESCE(TO_CHAR( ord.up_date, ''HH24MISS'' ), '''') AS up_date6 
  FROM
    ord_main_max AS ord
    LEFT OUTER JOIN mst_equipment AS meqa ON meqa.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''9'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_equipment AS meqv ON meqv.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''10'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_equipment AS meqsn ON meqsn.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''11'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_equipment AS meqad ON meqad.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''6'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_equipment AS meqpr ON meqpr.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''7'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_equipment AS meqbc ON meqbc.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''13'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_equipment AS meqse ON meqse.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''8'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_medicine AS med15 ON med15.medicine_cd = TO_NUMBER( ord.rst_cond_info -> ''15'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_medicine AS med19 ON med19.medicine_cd = TO_NUMBER( ord.rst_cond_info -> ''19'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_medicine AS med25 ON med25.medicine_cd = TO_NUMBER( ord.rst_cond_info -> ''25'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_treatment AS mtt ON mtt.treatment_cd = ord.rst_treatment_cd
    LEFT OUTER JOIN mst_dialyzer AS mdr ON mdr.dialyzer_cd = TO_NUMBER( ord.rst_cond_info -> ''5'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_va AS mva ON mva.va_cd = TO_NUMBER( ord.rst_cond_info -> ''2'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_bed AS mbd ON mbd.bed_cd = ord.rst_bed_cd
    LEFT OUTER JOIN mst_course AS mcs ON mcs.course_cd = ord.rst_course_cd
    LEFT OUTER JOIN mst_ward AS mwd ON mwd.ward_cd = ord.rst_ward_cd
    LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( ord.rst_cond_info -> ''25'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_medicine_mix AS mmmx ON mmmx.medicine_mix_cd = TO_NUMBER( ord.rst_cond_info -> ''15'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_medicine_mix AS mmmmx ON mmmmx.medicine_mix_cd = TO_NUMBER( ord.rst_cond_info -> ''19'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_kur AS mkr ON mkr.kur_cd = ord.rst_kur_cd 
WHERE
  ord.ord_no =  @ordNo', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'SSI連携）実績）透析条件', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-504001, 'WITH  ord_main_max AS (
    (
      SELECT
        ord.ord_no,
        ord.del_date as up_date,
        ord.rst_bed_cd,
        ord.rst_cond_info,
        ord.rst_treatment_cd,
        ord.rst_course_cd,
        ord.rst_ward_cd,
        ord.rst_dw,
        ord.rst_treatment_name
      FROM
        ord_main_restore AS ord,
        sys_coop_journal as journal
      WHERE
        ord.ord_no = @ordNo
        AND journal.ctl_no = @ctlNo
        AND ord.ord_no = journal.ord_no
        AND journal.reg_date >= ord.del_date
      ORDER BY
        del_date DESC
      LIMIT
        1
    )
    UNION
    (
      SELECT
        ord.ord_no,
        ord.rst_edition_date as up_date,
        ord.rst_bed_cd,
        ord.rst_cond_info,
        ord.rst_treatment_cd,
        ord.rst_course_cd,
        ord.rst_ward_cd,
        ord.rst_dw,
        ord.rst_treatment_name
      FROM
        ord_main AS ord
      WHERE
        ord.ord_no = @ordNo
    )
    ORDER BY
      up_date DESC NULLS LAST
    LIMIT
      1
  )
select
 ''透析条件'' as detail_id,
 split_part(cond_arr.cond_row,''-@-'',1) as e01,
 split_part(cond_arr.cond_row,''-@-'',2) as e02,
 COALESCE(nullif(split_part(cond_arr.cond_row,''-@-'',3),''''),'''') as e03,
 COALESCE(nullif(split_part(cond_arr.cond_row,''-@-'',4),''''),'''') as e04,
 COALESCE(nullif(split_part(cond_arr.cond_row,''-@-'',5),''''),'''') as e05
from
(
 select
 regexp_split_to_table(array_to_string(array[
  concat(''002-@-透析時間-@-'',ord.rst_cond_info->''1''->>''value'' ,''-@--@-分'') ,
  concat(''003-@-VA-@-'',trim(mva.in_hospital_cd_1),''-@-'',ord.rst_cond_info->''2''->>''value_name_1'',''-@-'') ,
  concat(''004-@-DW-@-'',ord.rst_dw,''-@-'',''-@-'',''kg'') ,
  concat(''005-@-目標体重-@-'',ord.rst_cond_info->''3''->>''value'',''-@-'',''-@-'',''kg'') ,
  concat(''006-@-治療方法-@-'',mtt.in_hospital_cd_a1,''-@-'',ord.rst_treatment_name,''-@-'') ,
  concat(''007-@-除水量制限-@-'',to_char(to_number(ord.rst_cond_info->''4''->>''value'',''99.99''),''FM90.00''),''-@-'',''-@-'',''L''),
  concat(''008-@-ダイアライザー-@-'',trim(mdr.in_hospital_cd_1),''-@-'',ord.rst_cond_info->''5''->>''value_name_1'',''-@-''),
  concat(''009-@-吸着カラム-@-'',trim(meqad.in_hospital_cd_1),''-@-'',ord.rst_cond_info->''6''->>''value_name_1'',''-@-''),
  concat(''010-@-血流量-@-'',ord.rst_cond_info->''14''->>''value'',''-@-'',''-@-'',''mL/min''),
  concat(''011-@-抗凝固剤-@-'',(case ord.rst_cond_info->''25''->>''medicine_type'' when ''1'' then med25.in_hospital_cd_1 when ''2'' then mmx.in_hospital_cd_1 end) ,''-@-'',ord.rst_cond_info->''25''->>''value_name_1'',''-@-'') ,
  concat(''012-@-抗凝固剤ワンショット量-@-'',(case when ord.rst_cond_info->''25''->>''value'' is null then null else ord.rst_cond_info->''26''->>''value'' end),''-@-'',''-@-'',ord.rst_cond_info->''26''->>''unit''),
  concat(''013-@-抗凝固剤持続速度-@-'',(case when ord.rst_cond_info->''25''->>''value'' is null then null else ord.rst_cond_info->''27''->>''value'' end),''-@-'',''-@-'',ord.rst_cond_info->''27''->>''unit''),
  concat(''014-@-抗凝固剤持続総量-@-'',(case when ord.rst_cond_info->''25''->>''value'' is null then null else ord.rst_cond_info->''28''->>''value'' end),''-@-'',''-@-'',ord.rst_cond_info->''28''->>''unit''),
  concat(''015-@-IP使用選択-@-'',(case when ord.rst_cond_info->''25''->>''value'' is null then null else ord.rst_cond_info->''29''->>''value'' end),''-@-'',(case ord.rst_cond_info->''29''->>''value'' when ''1'' then ''使用する'' when ''0'' then ''使用しない'' else null end) ,''-@-''),
  concat(''016-@-IPワンショット量-@-'',(case when ord.rst_cond_info->''29''->>''value'' = ''1'' and ord.rst_cond_info->''25''->>''value'' is not null then ord.rst_cond_info->''31''->>''value'' else null end),''-@-'',''-@-'',''mL'') ,
  concat(''017-@-IP速度-@-'',(case when ord.rst_cond_info->''29''->>''value'' = ''1'' and ord.rst_cond_info->''25''->>''value'' is not null then ord.rst_cond_info->''32''->>''value'' else null end),''-@-'',''-@-'',''mL/h''),
  concat(''018-@-透析液-@-'',(case ord.rst_cond_info->''15''->>''medicine_type'' when ''1'' then trim(med15.in_hospital_cd_1) when ''2'' then trim(mmmx.in_hospital_cd_1) end) ,''-@-'',ord.rst_cond_info->''15''->>''value_name_1'',''-@-'') ,
  concat(''019-@-透析液流量-@-'',(case when ord.rst_cond_info->''15''->>''value'' is null then null else ord.rst_cond_info->''16''->>''value'' end),''-@-'',''-@-'',''mL/min'') ,
  concat(''020-@-透析液量-@-'',(case when ord.rst_cond_info->''15''->>''value'' is null then null else ord.rst_cond_info->''17''->>''value'' end),''-@-'',''-@-'',ord.rst_cond_info->''17''->>''unit'') ,
  concat(''021-@-透析液温度-@-'',(case when ord.rst_cond_info->''15''->>''value'' is null then null else ord.rst_cond_info->''18''->>''value'' end),''-@-'',''-@-'',''℃'') ,
  concat(''022-@-補液-@-'', (case ord.rst_cond_info->''19''->>''medicine_type'' when ''1'' then med19.in_hospital_cd_1 when ''2'' then mmmmx.in_hospital_cd_1 end),''-@-'',ord.rst_cond_info->''19''->>''value_name_1'',''-@-'') ,
  concat(''023-@-補液量-@-'',(case when ord.rst_cond_info->''19''->>''value'' is null then null else ord.rst_cond_info->''20''->>''value'' end),''-@-'',''-@-'',''L'') ,
  concat(''024-@-補液選択-@-'',(case when ord.rst_cond_info->''19''->>''value'' is null then null else ord.rst_cond_info->''21''->>''value'' end),''-@-'',(case ord.rst_cond_info->''21''->>''value'' when ''1'' then ''前補液'' when ''0'' then ''後補液'' else null end),''-@-'') ,
  concat(''025-@-補液温度-@-'',(case when ord.rst_cond_info->''19''->>''value'' is null then null else ord.rst_cond_info->''23''->>''value'' end),''-@-'',''-@-'',''℃'') ,
  concat(''029-@-シングルニードル電源-@-'',ord.rst_cond_info->''12''->>''value'',''-@-'',(case ord.rst_cond_info->''12''->>''value'' when ''1'' then ''使用する'' when ''0'' then ''使用しない'' else null end),''-@-'') ,
  concat(''030-@-補液使用数-@-'',(case when ord.rst_cond_info->''19''->>''value'' is null then null else ord.rst_cond_info->''22''->>''value'' end),''-@-'',''-@-'',ord.rst_cond_info->''22''->>''unit'') ,
  concat(''031-@-IPスタート-@-'',(case when ord.rst_cond_info->''29''->>''value'' = ''1'' and ord.rst_cond_info->''25''->>''value'' is not null then ord.rst_cond_info->''30''->>''value'' else null end),''-@-'',(case ord.rst_cond_info->''30''->>''value'' when ''0'' then ''手動'' when ''1'' then ''自動'' else null end),''-@-''),
  concat(''032-@-自動ワンショット-@-'',(case when ord.rst_cond_info->''29''->>''value'' = ''1'' and ord.rst_cond_info->''25''->>''value'' is not null then ord.rst_cond_info->''34''->>''value'' else null end),''-@-'',(case ord.rst_cond_info->''34''->>''value'' when ''1'' then ''使用する'' when ''0'' then ''使用しない'' else null end),''-@-''),
  concat(''033-@-IP電源自動切り-@-'',(case when ord.rst_cond_info->''29''->>''value'' = ''1'' and ord.rst_cond_info->''25''->>''value'' is not null then ord.rst_cond_info->''35''->>''value'' else null end),''-@-'',(case ord.rst_cond_info->''35''->>''value'' when ''1'' then ''入り'' when ''0'' then ''切り'' else null end),''-@-''),
  concat(''034-@-IP電源自動切り時間-@-'',(case when 
      ord.rst_cond_info->''35''->>''value'' = ''1'' and ord.rst_cond_info->''29''->>''value'' = ''1'' and ord.rst_cond_info->''25''->>''value'' is not null then ord.rst_cond_info->''36''->>''value'' else null end),''-@-'',''-@-'',''分'') ,
  concat(''035-@-IP電源OKモニタ切り-@-'',(case when ord.rst_cond_info->''29''->>''value'' = ''1'' and ord.rst_cond_info->''25''->>''value'' is not null then ord.rst_cond_info->''37''->>''value'' else null end),''-@-'',(case ord.rst_cond_info->''37''->>''value'' when ''1'' then ''入り'' when ''0'' then ''切り'' else null end),''-@-''),
  concat(''036-@-IP電源OKモニタ切り時間-@-'',(case when 
      ord.rst_cond_info->''37''->>''value'' = ''1'' and ord.rst_cond_info->''29''->>''value'' = ''1'' and ord.rst_cond_info->''25''->>''value'' is not null then ord.rst_cond_info->''38''->>''value'' else null end),''-@-'',''-@-'',''分''),
  concat(''037-@-IP速度最大値-@-'',(case when ord.rst_cond_info->''29''->>''value'' = ''1'' and ord.rst_cond_info->''25''->>''value'' is not null then ord.rst_cond_info->''33''->>''value'' else null end),''-@-'',''-@-'',''mL/h''),
  concat(''038-@-補液速度-@-'',(case when ord.rst_cond_info->''19''->>''value'' is null then null else ord.rst_cond_info->''24''->>''value'' end),''-@-'',''-@-'',''L/h''),
  concat(''039-@-1次膜-@-'',meqpr.in_hospital_cd_1,''-@-'',ord.rst_cond_info->''7''->>''value_name_1'',''-@-'') ,
  concat(''040-@-2次膜-@-'',meqse.in_hospital_cd_1,''-@-'',ord.rst_cond_info->''8''->>''value_name_1'',''-@-'')
  ],''-@@-''),''-@@-'') as cond_row
from
  ord_main_max as ord
left outer join
   mst_equipment as meqa
  on
   meqa.equipment_cd = TO_NUMBER (ord.rst_cond_info->''9''->>''value'',''999999999999'')
  left outer join
   mst_equipment as meqv
  on
   meqv.equipment_cd = TO_NUMBER (ord.rst_cond_info->''10''->>''value'',''999999999999'')
  left outer join
   mst_equipment as meqsn
  on
   meqsn.equipment_cd = TO_NUMBER (ord.rst_cond_info->''11''->>''value'',''999999999999'')
 left outer join
  mst_equipment as meqad
 on
  meqad.equipment_cd = TO_NUMBER (ord.rst_cond_info->''6''->>''value'',''999999999999'')
 left outer join
  mst_equipment as meqpr
 on
  meqpr.equipment_cd = TO_NUMBER (ord.rst_cond_info->''7''->>''value'',''999999999999'')
 left outer join
  mst_equipment as meqbc
 on
  meqbc.equipment_cd = TO_NUMBER (ord.rst_cond_info->''13''->>''value'',''999999999999'')
 left outer join
  mst_equipment as meqse
 on
  meqse.equipment_cd = TO_NUMBER (ord.rst_cond_info->''8''->>''value'',''999999999999'')
 left outer join
  mst_medicine as med15
 on
  med15.medicine_cd = TO_NUMBER (ord.rst_cond_info->''15''->>''value'',''999999999999'')
 left outer join
  mst_medicine as med19
 on
  med19.medicine_cd = TO_NUMBER (ord.rst_cond_info->''19''->>''value'',''999999999999'')
 left outer join
  mst_medicine as med25
 on
  med25.medicine_cd = TO_NUMBER (ord.rst_cond_info->''25''->>''value'',''999999999999'')
 left outer join
  mst_treatment as mtt
 on
  mtt.treatment_cd = ord.rst_treatment_cd
 left outer join
  mst_dialyzer as mdr
 on
  mdr.dialyzer_cd =TO_NUMBER (ord.rst_cond_info->''5''->>''value'',''999999999999'')
 left outer join
  mst_va as mva
 on
  mva.va_cd =TO_NUMBER (ord.rst_cond_info->''2''->>''value'',''999999999999'')
 left outer join
  mst_bed as mbd
 on
  mbd.bed_cd =ord.rst_bed_cd
 left outer join
  mst_course as mcs
 on
  mcs.course_cd = ord.rst_course_cd
 left outer join
  mst_ward as mwd
 on
  mwd.ward_cd = ord.rst_ward_cd
  left outer join
  mst_medicine_mix as mmx
 on
  mmx.medicine_mix_cd = TO_NUMBER (ord.rst_cond_info->''25''->>''value'',''999999999999'')
  left outer join
  mst_medicine_mix as mmmx
 on
  mmmx.medicine_mix_cd = TO_NUMBER (ord.rst_cond_info->''15''->>''value'',''999999999999'')
  left outer join
  mst_medicine_mix as mmmmx
 on
  mmmmx.medicine_mix_cd = TO_NUMBER (ord.rst_cond_info->''19''->>''value'',''999999999999'')
 where
  ord.ord_no = @ordNo
  ) cond_arr
where
  length(split_part(cond_arr.cond_row,''-@-'',3)) > 0
OR (split_part(cond_arr.cond_row, ''-@-'', 1) IN (''003'', ''006'', ''008'', ''009'', ''011'', ''018'', ''022'', ''039'', ''040'') AND length(split_part(cond_arr.cond_row, ''-@-'', 4)) > 0) -- 連携コードを出力するものは連携コードが設定されてなくても、登録(名称)があれば出力する
;', 2, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'SSI)実績）透析条件繰り返し部', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-504002, 'SELECT case when cnt = 0 then 1 else null end
FROM
	(
		SELECT count(*) AS cnt
		FROM sys_coop_journal
		WHERE ctl_no =
			(
				SELECT MAX(past.ctl_no) 
				FROM sys_coop_journal present
				INNER JOIN sys_coop_journal past
				ON present.facility_cd = past.facility_cd
				AND present.coop_cd = past.coop_cd
				AND present.direction = past.direction
				AND present.pat_id = past.pat_id
				AND present.base_date = past.base_date
				AND present.ord_no <> past.ord_no
				AND present.ctl_no <> past.ctl_no
				WHERE present.facility_cd = @facilityCd
				AND present.ctl_no = @ctlNo
				AND past.coop_result = ''9''
			)
		AND crud <> ''D''
	) tag
', 2, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'SSI)実績）透析条件繰り返し部', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-505000, 'with detault_course_cd AS (
  SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS cource_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
    AND COALESCE(info ->> ''key0'', '''') = @key0
    AND info ->> ''key1'' = ''SSI_MEDI_REC_SEND''
    AND info ->> ''key2'' = ''DEFAULT_COURSE_CD''
),
karte_class AS (
  SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS karte_class
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
    AND COALESCE(info ->> ''key0'', '''') = @key0
    AND info ->> ''key1'' = ''SSI_MEDI_REC_SEND''
    AND info ->> ''key2'' = ''CLASS''
)
SELECT
  ord.ord_no AS ord_no,
  CASE WHEN LENGTH(TO_CHAR(ord.ord_no, ''FM9999999999999999999'')) >= 12 THEN TO_CHAR(ord.ord_no, ''FM9999999999999999999'') ELSE LPAD(TO_CHAR(ord.ord_no, ''FM9999999999999999999''), 12, ''0'') END AS ord_no12,
  (SELECT karte_class FROM karte_class) AS karte_class,
  LPAD(COALESCE(mcs.in_hospital_cd_1,(SELECT cource_cd FROM detault_course_cd), ''''), 2, ''0'') AS course_cd,--診療科コード１
  COALESCE(( CASE ord.rst_in_out_class WHEN ''1'' THEN ''3'' ELSE ''1'' END ), '''') AS in_out_s,--入外区分（SSI) 
  to_char(ord.rst_start_date,''YYYYMMDD'') as start_date8,--透析開始年月日
  to_char(ord.rst_start_date,''HH24MISS'') as start_date6,--透析開始時刻
    CASE journal.crud 
    WHEN ''C'' THEN to_char(ord.rst_start_date, ''YYYYMMDD'') --透析開始日時
    ELSE to_char(ord.up_date, ''YYYYMMDD'') --更新日時
    END AS inp_date --入力日
  , CASE journal.crud 
    WHEN ''C'' THEN to_char(ord.rst_start_date, ''HH24MISS'') --透析終了時刻
    ELSE to_char(ord.up_date, ''HH24MISS'') --更新時刻
    END AS inp_time --入力時間
  , journal.user_id AS user_id
  FROM
    ord_main AS ord
  LEFT OUTER JOIN mst_course AS mcs ON mcs.course_cd = ord.rst_course_cd
  INNER JOIN sys_coop_journal AS journal 
    ON journal.ctl_no = @ctlNo 
    AND journal.ord_no = ord.ord_no 
WHERE
  ord.ord_no =  @ordNo;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'SSI カルテ記載連携', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-505002, 'with detault_course_cd AS (
  SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS cource_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
    AND COALESCE(info ->> ''key0'', '''') = @key0
    AND info ->> ''key1'' = ''SSI_MEDI_REC_SEND''
    AND info ->> ''key2'' = ''DEFAULT_COURSE_CD''
),
karte_class AS (
  SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS karte_class
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
    AND COALESCE(info ->> ''key0'', '''') = @key0
    AND info ->> ''key1'' = ''SSI_MEDI_REC_SEND''
    AND info ->> ''key2'' = ''CLASS''
),
ord AS (
SELECT
        ord.ord_no,
        ord.rst_in_out_class,
        ord.rst_start_date,
        ord.up_date,
        ord.rst_course_cd,
        journal.crud,
        journal.user_id
      FROM
        ord_main_restore AS ord,
        sys_coop_journal as journal
      WHERE
        ord.ord_no = @ordNo
        AND journal.ctl_no = @ctlNo
        AND ord.ord_no = journal.ord_no
        AND journal.reg_date >= ord.del_date
      ORDER BY
        del_date DESC
      LIMIT
        1
)
SELECT
  ord.ord_no AS ord_no,
  CASE WHEN LENGTH(TO_CHAR(ord.ord_no, ''FM9999999999999999999'')) >= 12 THEN TO_CHAR(ord.ord_no, ''FM9999999999999999999'') ELSE LPAD(TO_CHAR(ord.ord_no, ''FM9999999999999999999''), 12, ''0'') END AS ord_no12,
  (SELECT karte_class FROM karte_class) AS karte_class,
  LPAD(COALESCE(mcs.in_hospital_cd_1,(SELECT cource_cd FROM detault_course_cd), ''''), 2, ''0'') AS course_cd,--診療科コード１
  COALESCE(( CASE ord.rst_in_out_class WHEN ''1'' THEN ''3'' ELSE ''1'' END ), '''') AS in_out_s,--入外区分（SSI) 
  to_char(ord.rst_start_date,''YYYYMMDD'') as start_date8,--透析開始年月日
  to_char(ord.rst_start_date,''HH24MISS'') as start_date6,--透析開始時刻
    CASE journal.crud 
    WHEN ''C'' THEN to_char(ord.rst_start_date, ''YYYYMMDD'') --透析開始日時
    ELSE to_char(ord.up_date, ''YYYYMMDD'') --更新日時
    END AS inp_date --入力日
  , CASE journal.crud 
    WHEN ''C'' THEN to_char(ord.rst_start_date, ''HH24MISS'') --透析終了時刻
    ELSE to_char(ord.up_date, ''HH24MISS'') --更新時刻
    END AS inp_time --入力時間
  , journal.user_id AS user_id
  FROM
    ord
  LEFT OUTER JOIN mst_course AS mcs ON mcs.course_cd = ord.rst_course_cd
  INNER JOIN sys_coop_journal AS journal 
    ON journal.ctl_no = @ctlNo 
    AND journal.ord_no = ord.ord_no;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'SSI カルテ記載連携 削除用', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
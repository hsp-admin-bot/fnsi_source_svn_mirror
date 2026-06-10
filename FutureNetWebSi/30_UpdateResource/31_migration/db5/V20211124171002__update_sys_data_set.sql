delete from "sys_data_set" where "sql_cd" in (1102, 1202,1001,1002,1003,1004);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1202, 'insert into pat_main (
  pat_id,
  facility_cd,
  is_same,
  is_implant,
  is_infect,
  is_diabetes,
  is_blood_suger_exam,
  in_out_current_state,
  in_out_plan_state,
  in_out_plan_date,
  pat_memo_info,
  addition_info,
  charge_staff_info,
  pat_group_info,
  taboo_allergy_info,
  infect_info,
  implant_info,
  tare_info,
  off_water_info,
  device_set_info,
  acceptance_status_info,
  is_del,
  up_date,
  reg_date,
  is_wheel_chair,
  medical_care_info,
  sch_ext_end_date,
  sch_ext_status,
  card_idm,
  old_up_date,
  host_notification_info
) values (
  @patId,
  ''@facilityCd'',
  NULLIF(''@isSame'',''''),
  NULLIF(''@isImplant'',''''),
  NULLIF(''@isInfect'',''''),
  NULLIF(''@isDiabetes'',''''),
  NULLIF(''@isBloodSugerExam'',''''),
  NULLIF(''@inOutCurrentState'',''''),
  NULLIF(''@inOutPlanState'',''''),
  case ''@inOutPlanDate_Date''
    when '''' then null
    else to_timestamp(''@inOutPlanDate_Date'',''yyyy-MM-dd hh24:mi:ss'')
  end,
  COALESCE(NULLIF(''@patMemoInfo'', ''''), ''[]'') :: JSONB,
  COALESCE(NULLIF(''@additioninfo'', ''''), ''[]'') :: JSONB,
  ''@chargeStaffInfoValue'',
  ''@patGroupInfoValue'',
  ''@tabooAllergyInfoValue'',
  COALESCE(NULLIF(''@infectInfo'', ''''), ''[]'') :: JSONB,
  ''@implantInfoValue'',
  ''@tareInfoValue'',
  ''@offWaterInfoValue'',
  ''@deviceSetInfoValue'',
  ''@acceptanceStatusInfoValue'',
  ''0'',
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP,
  NULLIF(''@isWheelChair'',''''),
  case ''@medicalCareInfoFlg''
    when '''' then json_build_object(''main_course_cd'',null,''dialysis_course_cd'',null,''ward_cd'',null,''dialysis_count'',null,''purification_count'',null,''other_dialysis_count'',null,''facility_cd'',null,''dialysis_start_date'',null,''hospital_start_date'',null)
    else json_build_object(''main_course_cd'',NULLIF(''@medicalCareInfo.mainCourseCd'',''''),''dialysis_course_cd'',NULLIF(''@medicalCareInfo.dialysisCourseCd'',''''),''ward_cd'',NULLIF(''@medicalCareInfo.wardCd'',''''),''dialysis_count'',NULLIF(''@medicalCareInfo.dialysisCount'',''''),''purification_count'',NULLIF(''@medicalCareInfo.purificationCount'',''''),''other_dialysis_count'',NULLIF(''@medicalCareInfo.otherDialysisCount'',''''),''facility_cd'',NULLIF(''@medicalCareInfo.facilityCd'',''''),''dialysis_start_date'',NULLIF(''@medicalCareInfo.dialysisStartDate'',''''),''hospital_start_date'',NULLIF(''@medicalCareInfo.hospitalStartDate'',''''))
  end,
  NULLIF(''@schExtEndDate'',''''),
  NULLIF(''@schExtStatus'',''''),
  NULLIF(''@cardIdm'',''''),
  case ''@oldUpDate_Date''
    when '''' then null
    else to_timestamp(''@oldUpDate_Date'',''yyyy-MM-dd hh24:mi:ss'')
  end,
  null
)', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, '[{"sql_cd": 1002, "field_name": "pat_memo_info", "replace_var": "@patMemoInfo"}, {"sql_cd": 1003, "field_name": "infect_info", "replace_var": "@infectInfo"}, {"sql_cd": 1004, "field_name": "addition_info", "replace_var": "@additioninfo"}]');
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1102, 'insert into pat_personal_main (
  fn_pat_id,
  hosp_pat_id,
  nkk_pat_id,
  facility_cd,
  pat_last_name,
  pat_first_name,
  pat_last_name_kana,
  pat_first_name_kana,
  pat_last_name_alpha,
  pat_first_name_alpha,
  pat_birth_name,
  pat_birth_name_kana,
  pat_birth_name_alpha,
  pat_birthday,
  pat_sex,
  nationality,
  pat_blood_type_abo,
  pat_blood_type_rh,
  pat_blood_type_serovar,
  in_out_class,
  is_die,
  die_cd,
  die_date,
  dial_diff_com_info,
  severity_cd,
  transport_cd,
  pat_contact_info,
  other_contact_info,
  vendor_contact_info,
  insurance_info,
  is_del,
  up_date,
  reg_date,
  primary_disease_cd,
  remote_monitor_service,
  remote_monitor_user_id,
  remote_monitor_user_pw
) values (
  NULLIF(''@fnPatId'',''''),
  LTRIM(NULLIF(''@hospPatId'',''''), ''0''),
  NULLIF(''@nkkPatId'',''''),
  NULLIF(''@facilityCd'',''''),
  personal_info_encrypt(split_part( ''@patLastName'', ''　'', 1 )),
  personal_info_encrypt(split_part( ''@patFirstName'', ''　'', 2 )),
  case when split_part( ''@patLastNmKana'', ''　'', 2 ) is null or split_part( ''@patLastNmKana'', ''　'', 2 ) = '''' then 
    personal_info_encrypt(split_part( ''@patLastNmKana'', '' '', 1 ))
  else 
    personal_info_encrypt(split_part( ''@patLastNmKana'', ''　'', 1 ))
  end,
  case when split_part( ''@patFirstNmKana'', ''　'', 2 ) is null or split_part( ''@patFirstNmKana'', ''　'', 2 ) = '''' then 
    personal_info_encrypt(split_part( ''@patFirstNmKana'', '' '', 2 ))
  else 
    personal_info_encrypt(split_part( ''@patFirstNmKana'', ''　'', 2 ))
  end,
  NULLIF(''@patLastNmAlpha'',''''),
  NULLIF(''@patFirstNmAlpha'',''''),
  NULLIF(''@patBirthName'',''''),
  NULLIF(''@patBirthNmKana'',''''),
  NULLIF(''@patBirthNmAlpha'',''''),
  NULLIF(''@patBirthday'',''''),
  case ''@patSex''
    when '''' then null
    else to_number(''@patSex'',''9999999999999999'')
  end,
  NULLIF(''@nationality'',''''),
  case ''@patBloodTypeAbo''
    when '''' then null
    else to_number(''@patBloodTypeAbo'',''9999999999999999'')
  end,
  case ''@patBloodTypeRh''
    when '''' then null
    else to_number(''@patBloodTypeRh'',''9999999999999999'')
  end,
  case ''@patBloodTypeSerovar''
    when '''' then null
    else to_number(''@patBloodTypeSerovar'',''9999999999999999'')
  end,
  case ''@inOutClass''
    when '''' then null
    else to_number(''@inOutClass'',''9999999999999999'')
  end,
  NULLIF(''@isDie'',''''),
  case ''@dieCd''
    when '''' then null
    else to_number(''@dieCd'',''99999999999999999999999999999999'')
  end,
  case ''@dieDate_Date''
    when '''' then null
    else to_timestamp(''@dieDate_Date'',''yyyy-MM-dd hh24:mi:ss'')
  end,
  COALESCE(NULLIF(''@dialDiffComInfo'', ''''), ''[]'') :: JSONB,
  case ''@severityCd''
    when '''' then null
    else to_number(''@severityCd'',''99999999999999999999999999999999'')
  end,
  case ''@transportCd''
    when '''' then null
    else to_number(''@transportCd'',''99999999999999999999999999999999'')
  end,
  case ''@patContactInfoFlg''
    when '''' then json_build_object(''zip_cd'',null,''address'',null,''tel1'',null,''tel2'',null,''fax'',null,''e_mail'',null,''work_name'',null,''work_address'',null,''work_tel'',null,''memo1'',null,''memo2'',null)
    else json_build_object(''zip_cd'',NULLIF(''@patContactInfo.zipCd'',''''),''address'',NULLIF(TRIM(TRIM(TRIM(''@patContactInfo.address'', ''　''), '' ''), ''　''),''''),''tel1'',NULLIF(''@patContactInfo.tel1'',''''),''tel2'',NULLIF(''@patContactInfo.tel2'',''''),''fax'',NULLIF(''@patContactInfo.fax'',''''),''e_mail'',NULLIF(''@patContactInfo.eMail'',''''),''work_name'',NULLIF(''@patContactInfo.workName'',''''),''work_address'',NULLIF(''@patContactInfo.workAddress'',''''),''work_tel'',NULLIF(''@patContactInfo.workTel'',''''),''memo1'',NULLIF(''@patContactInfo.memo1'',''''),''memo2'',NULLIF(''@patContactInfo.memo2'',''''))
  end,
  ''@otherContactInfoValue'',
  ''@vendorContactInfoValue'',
  ''@insuranceInfoValue'',
  ''0'',
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP,
  case ''@primaryDiseaseCd''
    when '''' then null
    else to_number(''@primaryDiseaseCd'',''99999999999999999999999999999999'')
  end,
  case ''@remoteMonitorService''
    when '''' then null
    else to_number(''@remoteMonitorService'',''99999999999999999999999999999999'')
  end,
  NULLIF(''@remoteMonitorUserId'',''''),
  NULLIF(''@remoteMonitorUserPw'','''')
)', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, '[{"sql_cd": 1001, "field_name": "dial_diff_com_info", "replace_var": "@dialDiffComInfo"}]');
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1004, 'SELECT
  array_to_json(ARRAY_AGG(T.col)) AS addition_info
FROM
  ( 
    SELECT
       json_build_object(''is_enable'', ''0'', ''reg_date'', CURRENT_TIMESTAMP, ''cd'', A.addition_cd) AS col
    FROM
      mst_addition A 
      , ( 
        SELECT
          mss.facility_cd
          , ms.*
          , ROW_NUMBER() OVER () AS INDEX 
        FROM
          mst_selector mss 
          CROSS JOIN LATERAL jsonb_to_recordset(mss.order_settings -> ''items'') AS ms(code BIGINT, NAME TEXT) 
        WHERE
          facility_cd = @facilityCd 
          AND master_physical_name = ''mst_addition'' 
      ) ms 
    WHERE
      A.facility_cd = ms.facility_cd 
      AND A.addition_cd = ms.code 
      AND A.is_del = ''0'' 
      AND A.is_disp = ''1'' 
    ORDER BY
      ms.INDEX
  ) AS T', 2, '[{}]', '0', '{"applications": [4]}', NULL, '外部連携用の[患者基本情報→加算情報]デフォルト値の取得', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1003, 'SELECT
  array_to_json(ARRAY_AGG(T.col)) AS infect_info
FROM
  ( 
    SELECT
       json_build_object(''infect'', ''0'', ''up_date'', null, ''exam_date'', null, ''infection_cd'', A.infection_cd) AS col
    FROM
      mst_infection A 
      , ( 
        SELECT
          mss.facility_cd
          , ms.*
          , ROW_NUMBER() OVER () AS INDEX 
        FROM
          mst_selector mss 
          CROSS JOIN LATERAL jsonb_to_recordset(mss.order_settings -> ''items'') AS ms(code BIGINT, NAME TEXT) 
        WHERE
          facility_cd = @facilityCd 
          AND master_physical_name = ''mst_infection'' 
      ) ms 
    WHERE
      A.facility_cd = ms.facility_cd 
      AND A.infection_cd = ms.code 
      AND A.is_del = ''0'' 
      AND A.is_disp = ''1'' 
    ORDER BY
      ms.INDEX
  ) AS T', 2, '[{}]', '0', '{"applications": [4]}', NULL, '外部連携用の[患者基本情報→感染症情報]デフォルト値の取得', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1002, 'SELECT
  array_to_json(ARRAY_AGG(T.col)) AS pat_memo_info
FROM
  ( 
    SELECT
       json_build_object(''title'', A.title, ''ctl_no'', A.pat_memo_no, ''content'', A.content) AS col
    FROM
      mst_pat_memo A 
      , ( 
        SELECT
          mss.facility_cd
          , ms.*
          , ROW_NUMBER() OVER () AS INDEX 
        FROM
          mst_selector mss 
          CROSS JOIN LATERAL jsonb_to_recordset(mss.order_settings -> ''items'') AS ms(code BIGINT, NAME TEXT) 
        WHERE
          facility_cd = @facilityCd 
          AND master_physical_name = ''mst_pat_memo'' 
      ) ms 
    WHERE
      A.facility_cd = ms.facility_cd 
      AND A.pat_memo_no = ms.code 
      AND A.is_del = ''0'' 
      AND A.is_disp = ''1'' 
    ORDER BY
      ms.INDEX
  ) AS T', 2, '[{}]', '0', '{"applications": [4]}', NULL, '外部連携用の[患者基本情報→患者メモ情報]デフォルト値の取得', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1001, 'SELECT
  array_to_json(ARRAY_AGG(T.col)) AS dial_diff_com_info
FROM
  ( 
    SELECT
      json_build_object(''is_main'', ''0'', ''reg_date'', null, ''is_dial_diff'', ''0'', ''dial_diff_cd'', A.dialysis_difficulty_cd) AS col
    FROM
      mst_dialysis_difficulty A 
      , ( 
        SELECT
          mss.facility_cd
          , ms.*
          , ROW_NUMBER() OVER () AS INDEX 
        FROM
          mst_selector mss 
          CROSS JOIN LATERAL jsonb_to_recordset(mss.order_settings -> ''items'') AS ms(code BIGINT, NAME TEXT) 
        WHERE
          facility_cd = @facilityCd
          AND master_physical_name = ''mst_dialysis_difficulty'' 
      ) ms 
    WHERE
      A.facility_cd = ms.facility_cd 
      AND A.dialysis_difficulty_cd = ms.code 
      AND A.is_del = ''0'' 
      AND A.is_disp = ''1'' 
    ORDER BY
      ms.INDEX
  ) AS T', 2, '[{}]', '0', '{"applications": [4]}', NULL, '外部連携用の[患者個人情報→透析困難情報]デフォルト値の取得', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, NULL);

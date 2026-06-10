delete from "sys_data_set" where "sql_cd" in (1103,1102);
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
  NULLIF(''@hospPatId'',''''),
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
  ''[{"is_main": "0", "reg_date": null, "dial_diff_cd": 1, "is_dial_diff": "0"}, {"is_main": "0", "reg_date": null, "dial_diff_cd": 2, "is_dial_diff": "0"}, {"is_main": "0", "reg_date": null, "dial_diff_cd": 3, "is_dial_diff": "0"}, {"is_main": "0", "reg_date": null, "dial_diff_cd": 4, "is_dial_diff": "0"}, {"is_main": "0", "reg_date": null, "dial_diff_cd": 5, "is_dial_diff": "0"}, {"is_main": "0", "reg_date": null, "dial_diff_cd": 6, "is_dial_diff": "0"}, {"is_main": "0", "reg_date": null, "dial_diff_cd": 7, "is_dial_diff": "0"}, {"is_main": "0", "reg_date": null, "dial_diff_cd": 8, "is_dial_diff": "0"}, {"is_main": "0", "reg_date": null, "dial_diff_cd": 9, "is_dial_diff": "0"}, {"is_main": "0", "reg_date": null, "dial_diff_cd": 10, "is_dial_diff": "0"}, {"is_main": "0", "reg_date": null, "dial_diff_cd": 11, "is_dial_diff": "0"}, {"is_main": "0", "reg_date": null, "dial_diff_cd": 12, "is_dial_diff": "0"}]'',
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
)', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1103, 'UPDATE pat_personal_main 
SET fn_pat_id = NULLIF ( ''@fnPatId'', '''' ),
hosp_pat_id = NULLIF ( ''@hospPatId'', '''' ),
nkk_pat_id = NULLIF ( ''@nkkPatId'', '''' ),
facility_cd = NULLIF ( ''@facilityCd'', '''' ),
pat_last_name = personal_info_encrypt(split_part( ''@patLastName'', ''　'', 1 )),
pat_first_name = personal_info_encrypt(split_part( ''@patFirstName'', ''　'', 2 )),
pat_last_name_kana =  case when split_part( ''@patLastNmKana'', ''　'', 2 ) is null or split_part( ''@patLastNmKana'', ''　'', 2 ) = '''' then 
    personal_info_encrypt(split_part( ''@patLastNmKana'', '' '', 1 ))
  else 
    personal_info_encrypt(split_part( ''@patLastNmKana'', ''　'', 1 ))
  end,
pat_first_name_kana = case when split_part( ''@patFirstNmKana'', ''　'', 2 ) is null or split_part( ''@patFirstNmKana'', ''　'', 2 ) = '''' then 
    personal_info_encrypt(split_part( ''@patFirstNmKana'', '' '', 2 ))
  else 
    personal_info_encrypt(split_part( ''@patFirstNmKana'', ''　'', 2 ))
  end,
pat_last_name_alpha = NULLIF ( ''@patLastNmAlpha'', '''' ),
pat_first_name_alpha = NULLIF ( ''@patFirstNmAlpha'', '''' ),
pat_birth_name = NULLIF ( ''@patBirthName'', '''' ),
pat_birth_name_kana = NULLIF ( ''@patBirthNmKana'', '''' ),
pat_birth_name_alpha = NULLIF ( ''@patBirthNmAlpha'', '''' ),
pat_birthday = NULLIF ( ''@patBirthday'', '''' ),
pat_sex =
CASE
        ''@patSex'' 
        WHEN '''' THEN
        NULL ELSE to_number( ''@patSex'', ''9999999999999999'' ) 
    END,
    nationality = NULLIF ( ''@nationality'', '''' ),
    pat_blood_type_abo =
CASE
        ''@patBloodTypeAbo'' 
        WHEN '''' THEN
        NULL ELSE to_number( ''@patBloodTypeAbo'', ''9999999999999999'' ) 
    END,
    pat_blood_type_rh =
CASE
    ''@patBloodTypeRh'' 
    WHEN '''' THEN
    NULL ELSE to_number( ''@patBloodTypeRh'', ''9999999999999999'' ) 
    END,
    pat_blood_type_serovar =
CASE
    ''@patBloodTypeSerovar'' 
    WHEN '''' THEN
    NULL ELSE to_number( ''@patBloodTypeSerovar'', ''9999999999999999'' ) 
    END,
    in_out_class =
CASE
    ''@inOutClass'' 
    WHEN '''' THEN
    NULL ELSE to_number( ''@inOutClass'', ''9999999999999999'' ) 
    END,
    is_die = NULLIF ( ''@isDie'', '''' ),
    die_cd =
CASE
        ''@dieCd'' 
        WHEN '''' THEN
        NULL ELSE to_number( ''@dieCd'', ''99999999999999999999999999999999'' ) 
    END,
    die_date =
CASE
    ''@dieDate_Date'' 
    WHEN '''' THEN
    NULL ELSE to_timestamp( ''@dieDate_Date'', ''yyyy-MM-dd hh24:mi:ss'' ) 
    END,
    dial_diff_com_info = ''@dialDiffComInfoValue'',
    severity_cd =
CASE
    ''@severityCd'' 
    WHEN '''' THEN
    NULL ELSE to_number( ''@severityCd'', ''99999999999999999999999999999999'' ) 
    END,
    transport_cd =
CASE
    ''@transportCd'' 
    WHEN '''' THEN
    NULL ELSE to_number( ''@transportCd'', ''99999999999999999999999999999999'' ) 
    END,
    pat_contact_info =
CASE
    ''@patContactInfoFlg'' 
    WHEN '''' THEN
    ''@patContactInfoValue'' ELSE json_build_object (
        ''zip_cd'',
        NULLIF ( ''@patContactInfo.zipCd'', '''' ),
        ''address'',
        NULLIF ( TRIM(TRIM(TRIM(''@patContactInfo.address'', ''　''), '' ''), ''　''), '''' ),
        ''tel1'',
        NULLIF ( ''@patContactInfo.tel1'', '''' ),
        ''tel2'',
        NULLIF ( ''@patContactInfo.tel2'', '''' ),
        ''fax'',
        NULLIF ( ''@patContactInfo.fax'', '''' ),
        ''e_mail'',
        NULLIF ( ''@patContactInfo.eMail'', '''' ),
        ''work_name'',
        NULLIF ( ''@patContactInfo.workName'', '''' ),
        ''work_address'',
        NULLIF ( ''@patContactInfo.workAddress'', '''' ),
        ''work_tel'',
        NULLIF ( ''@patContactInfo.workTel'', '''' ),
        ''memo1'',
        NULLIF ( ''@patContactInfo.memo1'', '''' ),
        ''memo2'',
        NULLIF ( ''@patContactInfo.memo2'', '''' ) 
    ) 
    END,
    other_contact_info = ''@otherContactInfoValue'',
    vendor_contact_info = ''@vendorContactInfoValue'',
    insurance_info = ''@insuranceInfoValue'',
    reg_date = ''@regDate'',
    up_date = CURRENT_TIMESTAMP,
    primary_disease_cd =
CASE
        ''@primaryDiseaseCd'' 
        WHEN '''' THEN
        NULL ELSE to_number( ''@primaryDiseaseCd'', ''99999999999999999999999999999999'' ) 
    END,
    remote_monitor_service =
CASE
    ''@remoteMonitorService'' 
    WHEN '''' THEN
    NULL ELSE to_number( ''@remoteMonitorService'', ''99999999999999999999999999999999'' ) 
    END,
    remote_monitor_user_id = NULLIF ( ''@remoteMonitorUserId'', '''' ),
    remote_monitor_user_pw = NULLIF ( ''@remoteMonitorUserPw'', '''' ) 
WHERE
    is_del = ''0'' 
    AND hosp_pat_id = ''@hospPatId'' 
    AND facility_cd = ''@facilityCd''', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);

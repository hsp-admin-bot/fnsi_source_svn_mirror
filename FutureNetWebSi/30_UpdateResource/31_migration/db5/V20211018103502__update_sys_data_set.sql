delete from "sys_data_set" where  "sql_cd" in (1102,1103,1302,1303);
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
  ''@dialDiffComInfoValue'',
  case ''@severityCd''
    when '''' then null
    else to_number(''@severityCd'',''99999999999999999999999999999999'')
  end,
  case ''@transportCd''
    when '''' then null
    else to_number(''@transportCd'',''99999999999999999999999999999999'')
  end,
  case ''@patContactInfoFlg''
    when '''' then json_build_object(''zip_cd'',null,''address'',null,''tel'',null,''fax'',null,''e_mail'',null,''work_name'',null,''work_address'',null,''work_tel'',null,''memo1'',null,''memo2'',null)
    else json_build_object(''zip_cd'',NULLIF(''@patContactInfo.zipCd'',''''),''address'',NULLIF(TRIM(TRIM(TRIM(''@patContactInfo.address'', ''　''), '' ''), ''　''),''''),''tel'',NULLIF(''@patContactInfo.tel'',''''),''fax'',NULLIF(''@patContactInfo.fax'',''''),''e_mail'',NULLIF(''@patContactInfo.eMail'',''''),''work_name'',NULLIF(''@patContactInfo.workName'',''''),''work_address'',NULLIF(''@patContactInfo.workAddress'',''''),''work_tel'',NULLIF(''@patContactInfo.workTel'',''''),''memo1'',NULLIF(''@patContactInfo.memo1'',''''),''memo2'',NULLIF(''@patContactInfo.memo2'',''''))
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
        NULLIF ( ''@patContactInfo.tel'', '''' ),
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
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1302, 'insert into pat_insurance (
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
  NULLIF(''@fnPatId'',''''),
  case ''@insuClass''
    when '''' then null
    else to_number(''@insuClass'',''99999999999999999999999999999999'')
  end,
  NULLIF(TRIM(''@insuName'', ''　''),''''),
  NULLIF(''@insuNmShort'',''''),
  case ''@insuInfoFlg''
    when '''' then json_build_object(''insu_pat_name'',null,''insu_no'',null,''insu_kbn'',null,''insu_pat_mark'',null,''insu_pat_no'',null,''cki_class'',null,''kki_class'',null,''und_six'',null,''futan-g'',null,''futan-n'',null)
    else json_build_object(''insu_pat_name'',NULLIF(''@insuInfo.insuPatName'',''''),''insu_no'',NULLIF(''@insuInfo.insuNo'',''''),''insu_kbn'',NULLIF(''@insuInfo.insuKbn'',''''),''insu_pat_mark'',NULLIF(''@insuInfo.insuPatMark'',''''),''insu_pat_no'',NULLIF(''@insuInfo.insuPatNo'',''''),''cki_class'',NULLIF(''@insuInfo.ckiClass'',''''),''kki_class'',NULLIF(''@insuInfo.kkiClass'',''''),''und_six'',NULLIF(''@insuInfo.undSix'',''''),''futan-g'',NULLIF(''@insuInfo.futan-g'',''''),''futan-n'',NULLIF(''@insuInfo.futan-n'',''''))
  end,
  case ''@insuPubInfoFlg''
    when '''' then json_build_object(''insu_pub_name'',null,''insu_pub_no'',null,''insu_pub_pat_no'',null)
    else json_build_object(''insu_pub_name'',NULLIF(''@insuPubInfo.insuPubName'',''''),''insu_pub_no'',NULLIF(''@insuPubInfo.insuPubNo'',''''),''insu_pub_pat_no'',NULLIF(''@insuPubInfo.insuPubPatNo'',''''))
  end,
  case ''@insuSetInfoFlg''
    when '''' then json_build_object(''insu_cd'',null,''insu_pub1_cd'',null,''insu_pub2_cd'',null,''insu_pub3_cd'',null,''insu_pub4_cd'',null)
    else json_build_object(''insu_cd'',NULLIF(''@insuSetInfo.insuCd'',''''),''insu_pub1_cd'',NULLIF(''@insuSetInfo.insuPub1Cd'',''''),''insu_pub2_cd'',NULLIF(''@insuSetInfo.insuPub2Cd'',''''),''insu_pub3_cd'',NULLIF(''@insuSetInfo.insuPub3Cd'',''''),''insu_pub4_cd'',NULLIF(''@insuSetInfo.insuPub4Cd'',''''))
  end,
  null,
  NULLIF(''@isSelected'',''''),
  NULLIF(''@isDisp'',''''),
  ''0'',
  NULLIF(''@coopCode'',''''),
  NULLIF(''@isCoop'',''''),
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP,
  NULLIF(''@startDate'',''''),
  NULLIF(''@endDate'',''''),
  NULLIF(''@checkDate'',''''),
  case ''@oldUpDate_Date''
    when '''' then null
    else to_timestamp(''@oldUpDate_Date'',''yyyy-MM-dd hh24:mi:ss'')
  end
)', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1303, 'update pat_insurance set
  pat_id = @patId,
  facility_cd = ''@facilityCd'',
  ctl_no = case ''@ctlNo''
             when '''' then null
             else to_number(''@ctlNo'',''99999999999999999999999999999999'')
           end,
  fn_pat_id = NULLIF(''@fnPatId'',''''),
  insu_class = case ''@insuClass''
                 when '''' then null
                 else to_number(''@insuClass'',''99999999999999999999999999999999'')
               end,
  insu_name = NULLIF(TRIM(''@insuName'', ''　''),''''),
  insu_name_short = NULLIF(''@insuNmShort'',''''),
  insu_info = case ''@insuInfoFlg''
                when '''' then ''@insuInfoValue''
                else json_build_object(''insu_pat_name'',NULLIF(''@insuInfo.insuPatName'',''''),''insu_no'',NULLIF(''@insuInfo.insuNo'',''''),''insu_kbn'',NULLIF(''@insuInfo.insuKbn'',''''),''insu_pat_mark'',NULLIF(''@insuInfo.insuPatMark'',''''),''insu_pat_no'',NULLIF(''@insuInfo.insuPatNo'',''''),''cki_class'',NULLIF(''@insuInfo.ckiClass'',''''),''kki_class'',NULLIF(''@insuInfo.kkiClass'',''''),''und_six'',NULLIF(''@insuInfo.undSix'',''''),''futan-g'',NULLIF(''@insuInfo.futan-g'',''''),''futan-n'',NULLIF(''@insuInfo.futan-n'',''''))
              end,
  insu_pub_info = case ''@insuPubInfoFlg''
                    when '''' then ''@insuPubInfoValue''
                    else json_build_object(''insu_pub_name'',NULLIF(''@insuPubInfo.insuPubName'',''''),''insu_pub_no'',NULLIF(''@insuPubInfo.insuPubNo'',''''),''insu_pub_pat_no'',NULLIF(''@insuPubInfo.insuPubPatNo'',''''))
                  end,
  insu_set_info = case ''@insuSetInfoFlg''
                    when '''' then ''@insuSetInfoValue''
                    else json_build_object(''insu_cd'',NULLIF(''@insuSetInfo.insuCd'',''''),''insu_pub1_cd'',NULLIF(''@insuSetInfo.insuPub1Cd'',''''),''insu_pub2_cd'',NULLIF(''@insuSetInfo.insuPub2Cd'',''''),''insu_pub3_cd'',NULLIF(''@insuSetInfo.insuPub3Cd'',''''),''insu_pub4_cd'',NULLIF(''@insuSetInfo.insuPub4Cd'',''''))
                  end,
  insu_self_info = null,
  is_selected = NULLIF(''@isSelected'',''''),
  is_disp = NULLIF(''@isDisp'',''''),
  coop_code = NULLIF(''@coopCode'',''''),
  is_coop = NULLIF(''@isCoop'',''''),
  up_date = CURRENT_TIMESTAMP,
  start_date = NULLIF(''@startDate'',''''),
  end_date = NULLIF(''@endDate'',''''),
  check_date = NULLIF(''@checkDate'',''''),
  old_up_date = case ''@oldUpDate_Date''
                  when '''' then null
                  else to_timestamp(''@oldUpDate_Date'',''yyyy-MM-dd hh24:mi:ss'')
                end
where
  pat_id = @patId
and
  facility_cd = ''@facilityCd''
and
  is_del = ''0''
and
  ctl_no = @ctlNo', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);

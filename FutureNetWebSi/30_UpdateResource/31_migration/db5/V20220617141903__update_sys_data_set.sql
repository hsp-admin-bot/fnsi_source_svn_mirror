DELETE FROM "ntss"."sys_data_set" where "sql_cd" IN (1012, 1013);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1012, 'WITH name_info AS ( 
  SELECT
    ''@patLastName'' ::TEXT AS patLastName
    , ''@patFirstName'' ::TEXT AS patFirstName
    , ''@patLastNmKana'' ::TEXT AS patLastNmKana
    , ''@patFirstNmKana'' ::TEXT AS patFirstNmKana
) 
, tmp_index_info AS ( 
  SELECT
    COALESCE(NULLIF(POSITION(''　'' IN patLastName), 0), LENGTH(patLastName) + 1) AS indexLast1
    , COALESCE(NULLIF(POSITION('' '' IN patLastName), 0), LENGTH(patLastName) + 1) AS indexLast2
    , COALESCE(NULLIF(POSITION(''　'' IN patFirstName), 0), LENGTH(patFirstName) + 1) AS indexFirst1
    , COALESCE(NULLIF(POSITION('' '' IN patFirstName), 0), LENGTH(patFirstName) + 1) AS indexFirst2
    , COALESCE(NULLIF(POSITION(''　'' IN patLastNmKana), 0), LENGTH(patLastNmKana) + 1) AS indexLastK1
    , COALESCE(NULLIF(POSITION('' '' IN patLastNmKana), 0), LENGTH(patLastNmKana) + 1) AS indexLastK2
    , COALESCE(NULLIF(POSITION(''　'' IN patFirstNmKana), 0), LENGTH(patFirstNmKana) + 1) AS indexFirstK1
    , COALESCE(NULLIF(POSITION('' '' IN patFirstNmKana), 0), LENGTH(patFirstNmKana) + 1) AS indexFirstK2 
  FROM
    name_info
) 
, index_info AS ( 
  SELECT
    CASE 
      WHEN indexLast1 > indexLast2 
        THEN indexLast2 
      ELSE indexLast1 
      END AS indexLast
    , CASE 
      WHEN indexFirst1 > indexFirst2 
        THEN indexFirst2 
      ELSE indexFirst1 
      END AS indexFirst
    , CASE 
      WHEN indexLastK1 > indexLastK2 
        THEN indexLastK2 
      ELSE indexLastK1 
      END AS indexLastK
    , CASE 
      WHEN indexFirstK1 > indexFirstK2 
        THEN indexFirstK2 
      ELSE indexFirstK1 
      END AS indexFirstK 
  FROM
    tmp_index_info
)
, new_name_info AS (
  SELECT
    TRIM(TRIM(TRIM(SUBSTRING(patLastName, 1, indexLast-1)), ''　'')) AS patLastName
    , TRIM(TRIM(TRIM(SUBSTRING(patFirstName, indexFirst + 1)), ''　'')) AS patFirstName
    , TRIM(TRIM(TRIM(SUBSTRING(patLastNmKana, 1, indexLastK-1)), ''　'')) AS patLastNmKana
    , TRIM(TRIM(TRIM(SUBSTRING(patFirstNmKana, indexFirstK + 1)), ''　'')) AS patFirstNmKana
  FROM 
    name_info,
    index_info
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
  , LTRIM(NULLIF(''@hospPatId'', ''''), ''0'')
  , NULLIF(''@nkkPatId'', '''')
  , NULLIF(''@facilityCd'', '''')
  , personal_info_encrypt((SELECT patLastName FROM new_name_info)) 
  , personal_info_encrypt((SELECT patFirstName FROM new_name_info))
  , personal_info_encrypt((SELECT patLastNmKana FROM new_name_info))
  , personal_info_encrypt((SELECT patFirstNmKana FROM new_name_info))
  , NULLIF(''@patLastNmAlpha'', '''')
  , NULLIF(''@patFirstNmAlpha'', '''')
  , NULLIF(''@patBirthName'', '''')
  , NULLIF(''@patBirthNmKana'', '''')
  , NULLIF(''@patBirthNmAlpha'', '''')
  , NULLIF(TRIM(REPLACE(''@patBirthday'',''/'','''' )), '''')
  , TO_NUMBER(''@patSexOut'', ''FM9999999999999999'') 
  , NULLIF(''@nationality'', '''')
  , TO_NUMBER(''@patBloodAboType'', ''FM9999999999999999'') 
  , TO_NUMBER(''@patBloodRhType'', ''FM9999999999999999'') 
  , CASE ''@patBloodTypeSerovar'' 
    WHEN '''' THEN 0 
    ELSE TO_NUMBER(''@patBloodTypeSerovar'', ''FM9999999999999999'') 
    END
  , TO_NUMBER(''@inOutClassOut'', ''FM9999999999999999'') 
  , NULLIF(''@isDie'', '''')
  , CASE ''@dieCd'' 
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
  , CASE ''@patContactInfoFlg'' 
    WHEN '''' THEN json_build_object( 
      ''zip_cd''
      , NULL
      , ''address''
      , NULL
      , ''tel1''
      , NULL
      , ''tel2''
      , NULL
      , ''fax''
      , NULL
      , ''e_mail''
      , NULL
      , ''work_name''
      , NULL
      , ''work_address''
      , NULL
      , ''work_tel''
      , NULL
      , ''memo1''
      , NULL
      , ''memo2''
      , NULL
    ) 
    ELSE json_build_object( 
      ''zip_cd''
      , NULLIF(''@patContactInfo.zipCd'', '''')
      , ''address''
      , NULLIF((TRIM(TRIM(TRIM(''@patContactInfo.address'', ''　''), '' ''), ''　'') || TRIM(TRIM(TRIM(''@patContactInfo.detailsAddress'', ''　''), '' ''), ''　'')), '''') 
      , ''tel1''
      , NULLIF(''@patContactInfo.tel1'', '''')
      , ''tel2''
      , NULLIF(''@patContactInfo.tel2'', '''')
      , ''fax''
      , NULLIF(''@patContactInfo.fax'', '''')
      , ''e_mail''
      , NULLIF(''@patContactInfo.eMail'', '''')
      , ''work_name''
      , NULLIF(''@patContactInfo.workName'', '''')
      , ''work_address''
      , NULLIF(''@patContactInfo.workAddress'', '''')
      , ''work_tel''
      , NULLIF(''@patContactInfo.workTel'', '''')
      , ''memo1''
      , NULLIF(''@patContactInfo.memo1'', '''')
      , ''memo2''
      , NULLIF(''@patContactInfo.memo2'', '''')
    ) 
    END
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
)', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装)患者プロファイル(profile)(XML):患者個人情報の取得の新規', '2022-06-13 08:34:44.813', CURRENT_TIMESTAMP, '[{"sql_cd": 1001, "field_name": "dial_diff_com_info", "replace_var": "@dialDiffComInfo"}, {"sql_cd": 1010, "field_name": "check_value", "replace_var": "@patBloodRhType"}, {"sql_cd": 1011, "field_name": "check_value", "replace_var": "@patBloodAboType"}, {"sql_cd": 1014, "field_name": "check_value", "replace_var": "@patSexOut"}, {"sql_cd": 1015, "field_name": "check_value", "replace_var": "@inOutClassOut"}]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1013, 'WITH name_info AS ( 
  SELECT
    ''@patLastName'' ::TEXT AS patLastName
    , ''@patFirstName'' ::TEXT AS patFirstName
    , ''@patLastNmKana'' ::TEXT AS patLastNmKana
    , ''@patFirstNmKana'' ::TEXT AS patFirstNmKana
) 
, Blood_info AS ( 
  SELECT
    ''@patBloodTypeRh'' ::TEXT AS patBloodTypeRh
) 
, tmp_index_info AS ( 
  SELECT
    COALESCE(NULLIF(POSITION(''　'' IN patLastName), 0), LENGTH(patLastName) + 1) AS indexLast1
    , COALESCE(NULLIF(POSITION('' '' IN patLastName), 0), LENGTH(patLastName) + 1) AS indexLast2
    , COALESCE(NULLIF(POSITION(''　'' IN patFirstName), 0), LENGTH(patFirstName) + 1) AS indexFirst1
    , COALESCE(NULLIF(POSITION('' '' IN patFirstName), 0), LENGTH(patFirstName) + 1) AS indexFirst2
    , COALESCE(NULLIF(POSITION(''　'' IN patLastNmKana), 0), LENGTH(patLastNmKana) + 1) AS indexLastK1
    , COALESCE(NULLIF(POSITION('' '' IN patLastNmKana), 0), LENGTH(patLastNmKana) + 1) AS indexLastK2
    , COALESCE(NULLIF(POSITION(''　'' IN patFirstNmKana), 0), LENGTH(patFirstNmKana) + 1) AS indexFirstK1
    , COALESCE(NULLIF(POSITION('' '' IN patFirstNmKana), 0), LENGTH(patFirstNmKana) + 1) AS indexFirstK2 
  FROM
    name_info
) 
, index_info AS ( 
  SELECT
    CASE 
      WHEN indexLast1 > indexLast2 
        THEN indexLast2 
      ELSE indexLast1 
      END AS indexLast
    , CASE 
      WHEN indexFirst1 > indexFirst2 
        THEN indexFirst2 
      ELSE indexFirst1 
      END AS indexFirst
    , CASE 
      WHEN indexLastK1 > indexLastK2 
        THEN indexLastK2 
      ELSE indexLastK1 
      END AS indexLastK
    , CASE 
      WHEN indexFirstK1 > indexFirstK2 
        THEN indexFirstK2 
      ELSE indexFirstK1 
      END AS indexFirstK 
  FROM
    tmp_index_info
)
, new_name_info AS (
  SELECT
    TRIM(TRIM(TRIM(SUBSTRING(patLastName, 1, indexLast-1)), ''　'')) AS patLastName
    , TRIM(TRIM(TRIM(SUBSTRING(patFirstName, indexFirst + 1)), ''　'')) AS patFirstName
    , TRIM(TRIM(TRIM(SUBSTRING(patLastNmKana, 1, indexLastK-1)), ''　'')) AS patLastNmKana
    , TRIM(TRIM(TRIM(SUBSTRING(patFirstNmKana, indexFirstK + 1)), ''　'')) AS patFirstNmKana
  FROM 
    name_info,
    index_info
) 
UPDATE pat_personal_main 
SET
  fn_pat_id = NULLIF(''@fnPatId'', '''')
  , hosp_pat_id = LTRIM(NULLIF(''@hospPatId'', ''''), ''0'')
  , nkk_pat_id = NULLIF(''@nkkPatId'', '''')
  , facility_cd = NULLIF(''@facilityCd'', '''')
  , pat_last_name = personal_info_encrypt((SELECT patLastName FROM new_name_info))
  , pat_first_name = COALESCE(personal_info_encrypt(NULLIF((SELECT patFirstName FROM new_name_info), '''')) , pat_first_name) 
  , pat_last_name_kana = personal_info_encrypt((SELECT patLastNmKana FROM new_name_info))
  , pat_first_name_kana = COALESCE(personal_info_encrypt(NULLIF((SELECT patFirstNmKana FROM new_name_info), '''')) , pat_first_name_kana) 
  , pat_last_name_alpha = NULLIF(''@patLastNmAlpha'', '''')
  , pat_first_name_alpha = NULLIF(''@patFirstNmAlpha'', '''')
  , pat_birth_name = NULLIF(''@patBirthName'', '''')
  , pat_birth_name_kana = NULLIF(''@patBirthNmKana'', '''')
  , pat_birth_name_alpha = NULLIF(''@patBirthNmAlpha'', '''')
  , pat_birthday = NULLIF(TRIM(REPLACE(''@patBirthday'',''/'','''' )), '''')
  , pat_sex = TO_NUMBER(''@patSexOut'', ''FM9999999999999999'') 
  , nationality = NULLIF(''@nationality'', '''')
  , pat_blood_type_abo = TO_NUMBER(''@patBloodAboType'', ''FM9999999999999999'') 
  , pat_blood_type_rh = TO_NUMBER(''@patBloodRhType'', ''FM9999999999999999'') 
  , pat_blood_type_serovar = CASE ''@patBloodTypeSerovar'' 
    WHEN '''' THEN 0 
    ELSE TO_NUMBER(''@patBloodTypeSerovar'', ''FM9999999999999999'') 
    END
  , in_out_class = TO_NUMBER(''@inOutClassOut'', ''FM9999999999999999'') 
  , is_die = NULLIF(''@isDie'', '''')
  , die_cd = CASE ''@dieCd'' 
    WHEN '''' THEN NULL 
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
  , pat_contact_info = CASE ''@patContactInfoFlg'' 
    WHEN '''' THEN ''@patContactInfoValue'' 
    ELSE json_build_object( 
      ''zip_cd''
      , NULLIF(''@patContactInfo.zipCd'', '''')
      , ''address''
      , NULLIF((TRIM(TRIM(TRIM(''@patContactInfo.address'', ''　''), '' ''), ''　'') || TRIM(TRIM(TRIM(''@patContactInfo.detailsAddress'', ''　''), '' ''), ''　'')), '''') 
      , ''tel1''
      , NULLIF(''@patContactInfo.tel1'', '''')
      , ''tel2''
      , NULLIF(''@patContactInfo.tel2'', '''')
      , ''fax''
      , NULLIF(''@patContactInfo.fax'', '''')
      , ''e_mail''
      , NULLIF(''@patContactInfo.eMail'', '''')
      , ''work_name''
      , NULLIF(''@patContactInfo.workName'', '''')
      , ''work_address''
      , NULLIF(''@patContactInfo.workAddress'', '''')
      , ''work_tel''
      , NULLIF(''@patContactInfo.workTel'', '''')
      , ''memo1''
      , NULLIF(''@patContactInfo.memo1'', '''')
      , ''memo2''
      , NULLIF(''@patContactInfo.memo2'', '''')
    ) 
    END
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
  AND facility_cd = ''@facilityCd''', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装)患者プロファイル(profile)(XML):患者個人情報の取得の修正', '2022-06-13 08:34:44.813', CURRENT_TIMESTAMP, '[{"sql_cd": 1009, "field_name": "up_base_disease_flg", "replace_var": "@upBaseDiseaseFlg"}, {"sql_cd": 1010, "field_name": "check_value", "replace_var": "@patBloodRhType"}, {"sql_cd": 1011, "field_name": "check_value", "replace_var": "@patBloodAboType"}, {"sql_cd": 1014, "field_name": "check_value", "replace_var": "@patSexOut"}, {"sql_cd": 1015, "field_name": "check_value", "replace_var": "@inOutClassOut"}]');

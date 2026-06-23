UPDATE "ntss"."sys_data_set" SET "sql" = 'WITH name_info AS ( 
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
  , TRIM(REPLACE(''@patBirthday'',''/'','''' ))
  , CASE ''@patSex'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@patSex'', ''FM9999999999999999'') 
    END
  , NULLIF(''@nationality'', '''')
  , TO_NUMBER(''@patBloodAboType'', ''FM9999999999999999'') 
  , TO_NUMBER(''@patBloodRhType'', ''FM9999999999999999'') 
  , CASE ''@patBloodTypeSerovar'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@patBloodTypeSerovar'', ''FM9999999999999999'') 
    END
  , CASE ''@inOutClass'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@inOutClass'', ''FM9999999999999999'') 
    END
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
)', "db_class" = 3, "detail" = '[{}]', "can_repeat" = '0', "use_application" = '{"applications": [4]}', "report_class" = NULL, "memo" = '(受信用)患者個人情報の取得の新規', "reg_date" = '2020-05-25 18:21:40.841', "up_date" =current_timestamp, "pre_sql_info" = '[{"sql_cd": 1001, "field_name": "dial_diff_com_info", "replace_var": "@dialDiffComInfo"}, {"sql_cd": 1010, "field_name": "check_value", "replace_var": "@patBloodRhType"}, {"sql_cd": 1011, "field_name": "check_value", "replace_var": "@patBloodAboType"}]' WHERE "sql_cd" = 1102;

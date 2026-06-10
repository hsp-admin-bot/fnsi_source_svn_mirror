DELETE FROM sys_data_set
WHERE sql_cd IN (-603101, -603201);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-603101, 'WITH new_name_info AS (
  SELECT
    substring(''@patLastName'' ::TEXT from ''^(.*?)[\u3000\s]'') AS patLastName
    , substring(''@patLastName'' ::TEXT from ''[\u3000\s](.*)'') AS patFirstName
    , substring(''@patLastNmKana'' ::TEXT from ''^(.*?)[\u3000\s]'') AS patLastNmKana
    , substring(''@patLastNmKana'' ::TEXT from ''[\u3000\s](.*)'') AS patFirstNmKana
)
, pat_contract_info_json AS (
SELECT
    CASE
        WHEN ''@patContactInfo.ctlNo'' = ''1''
  THEN json_build_object(
      ''zip_cd''
        , NULLIF(''@patContactInfo.zipCd'', '''')
        , ''address''
        , NULLIF(TRIM(TRIM(TRIM(''@patContactInfo.address'', ''　''), '' ''), ''　''), '''')
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
        ,''work_address''
        , NULLIF(''@patContactInfo.workAddress'', '''')
        ,''work_tel''
        , NULLIF(''@patContactInfo.workTel'', '''')
        , ''memo1''
        , NULLIF(''@patContactInfo.memo1'', '''')
        , ''memo2''
        , NULLIF(''@patContactInfo.memo2'', '''')
    )
  ELSE json_build_object(
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
    END
)
INSERT
INTO ntss.pat_personal_main(
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
  , personal_info_encrypt((SELECT patLastName FROM new_name_info))
  , personal_info_encrypt((SELECT patFirstName FROM new_name_info))
  , personal_info_encrypt((SELECT patLastNmKana FROM new_name_info))
  , personal_info_encrypt((SELECT patFirstNmKana FROM new_name_info))
  , NULLIF(''@patLastNmAlpha'', '''')
  , NULLIF(''@patFirstNmAlpha'', '''')
  , NULLIF(''@patBirthName'', '''')
  , NULLIF(''@patBirthNmKana'', '''')
  , NULLIF(''@patBirthNmAlpha'', '''')
  , NULLIF(''@patBirthday'', '''')
  , CASE ''@patSex''
    WHEN ''1'' THEN 1
    WHEN ''2'' THEN 2
    ELSE 0
    END
  , NULLIF(''@nationality'', '''')
  , CASE ''@patBloodTypeAbo''
    WHEN ''1'' THEN 1
    WHEN ''2'' THEN 2
    WHEN ''3'' THEN 3
    WHEN ''4'' THEN 4
    ELSE 0
    END
  , CASE ''@patBloodTypeRh''
    WHEN ''1'' THEN 1
    WHEN ''2'' THEN 2
    ELSE 0
    END
  , CASE ''@patBloodTypeSerovar''
    WHEN '''' THEN 0
    ELSE TO_NUMBER(''@patBloodTypeSerovar'', ''FM9999999999999999'')
    END
  , CASE ''@inOutClass''
    WHEN '''' THEN 3
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
    ELSE (SELECT * FROM pat_contract_info_json)
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
)', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)患者個人情報の取得の新規', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": 1001, "field_name": "dial_diff_com_info", "replace_var": "@dialDiffComInfo"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-603201, 'WITH new_name_info AS (
  SELECT
    COALESCE(substring(''@patLastName'' ::TEXT from ''^(.*?)[\u3000\s]''), nullif(''@patLastName'','''')) AS patLastName
    , substring(''@patLastName'' ::TEXT from ''[\u3000\s](.*)'') AS patFirstName
    , COALESCE(substring(''@patLastNmKana'' ::TEXT from ''^(.*?)[\u3000\s]''), nullif(''@patLastNmKana'','''')) AS patLastNmKana
    , substring(''@patLastNmKana'' ::TEXT from ''[\u3000\s](.*)'') AS patFirstNmKana
)
, new_name_check_info AS (
    SELECT CASE WHEN (pat_last_name = personal_info_encrypt(''ini_dial'') AND pat_first_name = personal_info_encrypt(''only'')) OR (pat_last_name IS NULL AND pat_first_name IS NULL) THEN ''new''
            WHEN (''ini_dial'' <> (SELECT patLastName FROM new_name_info)
                AND ''only'' <> (SELECT patFirstName FROM new_name_info)) THEN ''new''
            ELSE ''old'' END AS name_falg
    FROM pat_personal_main
    WHERE
        is_del = ''0''
        AND hosp_pat_id = @hospPatId :: text
        AND facility_cd = ''@facilityCd''
)
, check_name_update AS (
  SELECT
    CASE
      WHEN POSITION('' '' IN ''@patLastName'') = 0
        AND POSITION(''　'' IN ''@patLastName'') = 0
        AND ''@patLastName'' = CONCAT(personal_info_decrypt(pat_last_name), personal_info_decrypt(pat_first_name))
      THEN ''0''
      ELSE ''1''
      END AS name_update_flg
    , CASE
      WHEN POSITION('' '' IN ''@patLastNmKana'') = 0
        AND POSITION(''　'' IN ''@patLastNmKana'') = 0
        AND ''@patLastNmKana'' = CONCAT(personal_info_decrypt(pat_last_name_kana), personal_info_decrypt(pat_first_name_kana))
      THEN ''0''
      ELSE ''1''
      END AS name_kana_update_flg
  FROM
    pat_personal_main
  WHERE
    is_del = ''0''
    AND hosp_pat_id = ''@hospPatId''
    AND facility_cd = ''@facilityCd''
    AND is_die = ''0''
)
, pat_contact_info_json AS (
SELECT
    CASE
        WHEN ''@patContactInfo.ctlNo'' = ''1''
  THEN jsonb_build_object(
      ''zip_cd''
        , NULLIF(''@patContactInfo.zipCd'', '''')
        , ''address''
        , NULLIF(TRIM(TRIM(TRIM(''@patContactInfo.address'', ''　''), '' ''), ''　''), '''')
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
        ,''work_address''
        , NULLIF(''@patContactInfo.workAddress'', '''')
        ,''work_tel''
        , NULLIF(''@patContactInfo.workTel'', '''')
        , ''memo1''
        , NULLIF(''@patContactInfo.memo1'', '''')
        , ''memo2''
        , NULLIF(''@patContactInfo.memo2'', '''')
    )
  ELSE jsonb_build_object(
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
    END
)
UPDATE pat_personal_main
SET
  pat_last_name = CASE
    WHEN ''new'' = (SELECT name_falg FROM new_name_check_info)
      AND (''1'' = (SELECT name_update_flg FROM check_name_update))
    THEN personal_info_encrypt((SELECT patLastName FROM new_name_info))
    ELSE pat_last_name
    END
  , pat_first_name = CASE
    WHEN ''new'' = (SELECT name_falg FROM new_name_check_info)
      AND (''1'' = (SELECT name_update_flg FROM check_name_update))
    THEN personal_info_encrypt(NULLIF((SELECT patFirstName FROM new_name_info), ''''))
    ELSE pat_first_name
    END
  , pat_last_name_kana = CASE
    WHEN ''1'' = (SELECT name_kana_update_flg FROM check_name_update)
    THEN personal_info_encrypt((SELECT patLastNmKana FROM new_name_info))
    ELSE pat_last_name_kana
    END
  , pat_first_name_kana = CASE
    WHEN ''1'' = (SELECT name_kana_update_flg FROM check_name_update)
    THEN personal_info_encrypt(NULLIF((SELECT patFirstNmKana FROM new_name_info), ''''))
    ELSE pat_first_name_kana
    END
  , pat_last_name_alpha = NULLIF(''@patLastNmAlpha'', '''')
  , pat_first_name_alpha = NULLIF(''@patFirstNmAlpha'', '''')
  , pat_birth_name = NULLIF(''@patBirthName'', '''')
  , pat_birth_name_kana = NULLIF(''@patBirthNmKana'', '''')
  , pat_birth_name_alpha = NULLIF(''@patBirthNmAlpha'', '''')
  , pat_birthday = NULLIF(''@patBirthday'', '''')
  , pat_sex = CASE ''@patSex''
    WHEN ''1'' THEN 1
    WHEN ''2'' THEN 2
    ELSE 0
    END
  , pat_blood_type_abo = CASE ''@patBloodTypeAbo''
    WHEN ''1'' THEN 1
    WHEN ''2'' THEN 2
    WHEN ''3'' THEN 3
    WHEN ''4'' THEN 4
    ELSE 0
    END
  , pat_blood_type_rh = CASE ''@patBloodTypeRh''
    WHEN ''1'' THEN 1
    WHEN ''2'' THEN 2
    ELSE 0
    END
  , in_out_class = CASE
    WHEN ''@inOutClass'' = ''0'' or ''@inOutClass'' = ''1'' THEN TO_NUMBER(''@inOutClass'', ''FM9999999999999999'')
    ELSE 3
    END
  , is_die = NULLIF(''@isDie'', '''')
  , die_date = CASE ''@dieDate_Date''
    WHEN '''' THEN NULL
    ELSE TO_TIMESTAMP(''@dieDate_Date'', ''YYYY-MM-DD HH24:MI:SS'')
    END
  , pat_contact_info = CASE
    WHEN ''@patContactInfoFlg''  = '''' THEN ''@patContactInfoValue''
    WHEN ''@patContactInfo.ctlNo'' = ''1'' THEN (SELECT * FROM pat_contact_info_json)
    ELSE pat_contact_info
    END
  , up_date = CURRENT_TIMESTAMP
WHERE
  is_del = ''0''
  AND hosp_pat_id = ''@hospPatId''
  AND facility_cd = ''@facilityCd''', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)患者個人情報の取得の修正', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
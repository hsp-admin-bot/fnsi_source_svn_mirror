delete from ntss.sys_data_set where sql_cd = '-403201';

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-403201, 'WITH name_info AS (
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
, new_name_check_info AS (
    SELECT CASE WHEN (pat_last_name = personal_info_encrypt(''ini_dial'') AND pat_first_name = personal_info_encrypt(''only'')) OR (pat_last_name IS NULL AND pat_first_name IS NULL) THEN ''new''
            WHEN (''ini_dial'' <> (SELECT patLastName FROM new_name_info) 
                AND ''only'' <> (SELECT patFirstName FROM new_name_info)) THEN ''new''
            ELSE ''old'' END AS name_falg
    FROM pat_personal_main
    WHERE
        is_del = ''0'' 
        AND hosp_pat_id = ''@hospPatId''
        AND facility_cd = ''@facilityCd''   
) 
UPDATE pat_personal_main 
SET
  fn_pat_id = NULLIF(''@fnPatId'', '''')
  , hosp_pat_id = NULLIF(''@hospPatId'', '''')
  , nkk_pat_id = NULLIF(''@nkkPatId'', '''')
  , facility_cd = NULLIF(''@facilityCd'', '''')
  , pat_last_name = CASE 
                        WHEN 
                            ''new'' = (SELECT name_falg FROM new_name_check_info)
                        THEN (SELECT  personal_info_encrypt(patLastName) FROM new_name_info) 
                        ELSE pat_last_name 
                    END 
  , pat_first_name = CASE 
                        WHEN 
                            ''new'' = (SELECT name_falg FROM new_name_check_info)
                        THEN (SELECT  personal_info_encrypt(patfirstName) FROM new_name_info) 
                        ELSE pat_first_name 
                     END 
 , pat_last_name_kana = 
	case when (''@patLastNmKana'' like ''% %'') then (SELECT  personal_info_encrypt(patLastNmKana) FROM new_name_info)
	when (((SELECT concat(patLastNmKana,patFirstNmKana) FROM new_name_info) = concat(personal_info_decrypt(pat_last_name_kana),personal_info_decrypt(pat_first_name_kana))) and (''@patLastNmKana'' not like ''% %'') ) then pat_last_name_kana
	when ((SELECT concat(patLastNmKana,patFirstNmKana) FROM new_name_info) != concat(personal_info_decrypt(pat_last_name_kana),personal_info_decrypt(pat_first_name_kana)) and (''@patLastNmKana'' not like ''% %'') )
	then (SELECT personal_info_encrypt(concat(patLastNmKana,patFirstNmKana))  FROM new_name_info) end
  ,pat_first_name_kana = case when (''@patFirstNmKana''  like ''% %'') then (SELECT  personal_info_encrypt(patFirstNmKana) FROM new_name_info)
  when ((SELECT concat(patLastNmKana,patFirstNmKana) FROM new_name_info) = concat(personal_info_decrypt(pat_last_name_kana),personal_info_decrypt(pat_first_name_kana)) and (''@patFirstNmKana'' not like ''% %'')  )then pat_first_name_kana 
	when ((SELECT concat(patLastNmKana,patFirstNmKana) FROM new_name_info) != concat(personal_info_decrypt(pat_last_name_kana),personal_info_decrypt(pat_first_name_kana)) and (''@patFirstNmKana'' not like ''% %'')  ) then NULL end
  , pat_last_name_alpha = NULLIF(personal_info_encrypt(''@patLastNmAlpha''), '''')
  , pat_first_name_alpha = NULLIF(personal_info_encrypt(''@patFirstNmAlpha''), '''')
  , pat_birth_name = NULLIF(''@patBirthName'', '''')
  , pat_birth_name_kana = NULLIF(''@patBirthNmKana'', '''')
  , pat_birth_name_alpha = NULLIF(''@patBirthNmAlpha'', '''')
  , pat_birthday = NULLIF(''@patBirthday'', '''')
  , pat_sex = CASE ''@patSex'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@patSex'', ''FM9999999999999999'') 
    END
  , nationality = NULLIF(''@nationality'', '''')
  , pat_blood_type_abo = CASE ''@patBloodTypeAbo'' 
    WHEN '''' THEN 0 
    ELSE TO_NUMBER(''@patBloodTypeAbo'', ''FM9999999999999999'') 
    END
  , pat_blood_type_rh = CASE ''@patBloodTypeRh'' 
    WHEN '''' THEN 0 
    ELSE TO_NUMBER(''@patBloodTypeRh'', ''FM9999999999999999'') 
    END
  , pat_blood_type_serovar = CASE ''@patBloodTypeSerovar'' 
    WHEN '''' THEN 0 
    ELSE TO_NUMBER(''@patBloodTypeSerovar'', ''FM9999999999999999'') 
    END
  , in_out_class = CASE  
    WHEN ''@inOutClass'' = ''0'' or ''@inOutClass'' = ''1'' THEN TO_NUMBER(''@inOutClass'', ''FM9999999999999999'')  
    ELSE 3
    END
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
      , NULLIF(replace(''@patContactInfo.zipCd'', ''-'', ''''), '''')
      , ''address''
      , NULLIF(TRIM(TRIM(TRIM(''@patContactInfo.address'', ''　''), '' ''), ''　''), '''')
      , ''tel1''
      , NULLIF(''@patContactInfo.tel1'', '''')
      , ''tel2''
      , CASE
      		WHEN ''@patContactInfo.tel2'' = '''' THEN trim(both ''"'' from personal_info_decrypt(pat_contact_info ->> ''tel2''))
      		ELSE NULLIF(''@patContactInfo.tel2'', '''')
      	END
      , ''fax''
      , CASE
      		WHEN ''@patContactInfo.fax'' = '''' THEN trim(both ''"'' from personal_info_decrypt(pat_contact_info ->> ''fax''))
      		ELSE NULLIF(''@patContactInfo.fax'', '''')
      	END
      , ''e_mail''
      , NULLIF(trim(both ''"'' from personal_info_decrypt(pat_contact_info ->> ''e_mail'')), '''')
      , ''work_name''
      , NULLIF(trim(both ''"'' from personal_info_decrypt(pat_contact_info ->> ''work_name'')), '''')
      , ''work_address''
      , NULLIF(trim(both ''"'' from personal_info_decrypt(pat_contact_info ->> ''work_address'')), '''')
      , ''work_tel''
      , NULLIF(trim(both ''"'' from personal_info_decrypt(pat_contact_info ->> ''work_tel'')), '''')
      , ''memo1''
      , NULLIF(trim(both ''"'' from personal_info_decrypt(pat_contact_info ->> ''memo1'')), '''')
      , ''memo2''
      , NULLIF(trim(both ''"'' from personal_info_decrypt(pat_contact_info ->> ''memo2'')), '''')
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
  AND facility_cd = ''@facilityCd''', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)患者個人情報の取得の修正', '2023-12-22 13:44:58.338', CURRENT_TIMESTAMP, '[{"sql_cd": 1009, "field_name": "up_base_disease_flg", "replace_var": "@upBaseDiseaseFlg"}]'::jsonb);
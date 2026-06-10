DELETE FROM "ntss"."sys_data_set" where sql_cd in (1103, 1502);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(1103, 'WITH name_info AS (
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
        AND hosp_pat_id = @hospPatId :: text
        AND facility_cd = ''@facilityCd''   
) 
UPDATE pat_personal_main 
SET
  fn_pat_id = NULLIF(''@fnPatId'', '''')
  , hosp_pat_id = NULLIF(''@hospPatId'', '''')
  , nkk_pat_id = NULLIF(''@nkkPatId'', '''')
  , facility_cd = NULLIF(''@facilityCd'', '''')
 , pat_last_name = CASE WHEN ''new'' = (SELECT name_falg FROM new_name_check_info) THEN 
 (case when (REPLACE(''@patLastName'', ''　'', '' '') like ''% %'') then (SELECT  personal_info_encrypt(patLastName) FROM new_name_info)
	when (((SELECT concat(patLastName,patFirstName) FROM new_name_info) = concat(personal_info_decrypt(pat_last_name),personal_info_decrypt(pat_first_name))) and (''@patLastName'' not like ''% %'') ) then pat_last_name
	when ((SELECT concat(patLastName,patFirstName) FROM new_name_info) != concat(personal_info_decrypt(pat_last_name),personal_info_decrypt(pat_first_name)) and (''@patLastName'' not like ''% %'') )
	then (SELECT personal_info_encrypt(concat(patLastName,patFirstName))  FROM new_name_info) end)
	ELSE pat_last_name END 
    , pat_first_name = CASE WHEN ''new'' = (SELECT name_falg FROM new_name_check_info) THEN	
	(case when (REPLACE(''@patFirstName'', ''　'', '' '')  like ''% %'') then (SELECT  personal_info_encrypt(patFirstName) FROM new_name_info)
  when ((SELECT concat(patLastName,patFirstName) FROM new_name_info) = concat(personal_info_decrypt(pat_last_name),personal_info_decrypt(pat_first_name)) and (''@patFirstName'' not like ''% %'')  )then pat_first_name 
	when ((SELECT concat(patLastName,patFirstName) FROM new_name_info) != concat(personal_info_decrypt(pat_last_name),personal_info_decrypt(pat_first_name)) and (''@patFirstName'' not like ''% %'')  ) then NULL end)	
		ELSE pat_first_name END
--   , pat_last_name_kana = personal_info_encrypt((SELECT patLastNmKana FROM new_name_info))
--   , pat_first_name_kana = COALESCE(personal_info_encrypt(NULLIF((SELECT patFirstNmKana FROM new_name_info), '''')) , pat_first_name_kana) 
 , pat_last_name_kana = 
	case when (''@patLastNmKana'' like ''% %'') then (SELECT  personal_info_encrypt(patLastNmKana) FROM new_name_info)
	when (((SELECT concat(patLastNmKana,patFirstNmKana) FROM new_name_info) = concat(personal_info_decrypt(pat_last_name_kana),personal_info_decrypt(pat_first_name_kana))) and (''@patLastNmKana'' not like ''% %'') ) then pat_last_name_kana
	when ((SELECT concat(patLastNmKana,patFirstNmKana) FROM new_name_info) != concat(personal_info_decrypt(pat_last_name_kana),personal_info_decrypt(pat_first_name_kana)) and (''@patLastNmKana'' not like ''% %'') )
	then (SELECT personal_info_encrypt(concat(patLastNmKana,patFirstNmKana))  FROM new_name_info) end
  ,pat_first_name_kana = case when (''@patFirstNmKana''  like ''% %'') then (SELECT  personal_info_encrypt(patFirstNmKana) FROM new_name_info)
  when ((SELECT concat(patLastNmKana,patFirstNmKana) FROM new_name_info) = concat(personal_info_decrypt(pat_last_name_kana),personal_info_decrypt(pat_first_name_kana)) and (''@patFirstNmKana'' not like ''% %'')  )then pat_first_name_kana 
	when ((SELECT concat(patLastNmKana,patFirstNmKana) FROM new_name_info) != concat(personal_info_decrypt(pat_last_name_kana),personal_info_decrypt(pat_first_name_kana)) and (''@patFirstNmKana'' not like ''% %'')  ) then NULL end
  , pat_last_name_alpha = NULLIF(''@patLastNmAlpha'', '''')
  , pat_first_name_alpha = NULLIF(''@patFirstNmAlpha'', '''')
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
  AND facility_cd = ''@facilityCd''', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)患者個人情報の取得の修正', '2022-01-07 18:21:46.000', CURRENT_TIMESTAMP, '[{"sql_cd": 1009, "field_name": "up_base_disease_flg", "replace_var": "@upBaseDiseaseFlg"}]'::jsonb);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(1502, 'WITH die_info AS (
  SELECT 
    CASE 
    WHEN ''@isDie'' LIKE ''_isDie'' THEN ''0''
    ELSE COALESCE(NULLIF(''@isDie'', ''''), ''0'')
    END AS is_die
    , CASE 
    WHEN ''@dieDate_Date'' LIKE ''_dieDate_Date'' THEN NULL
    ELSE TO_TIMESTAMP(NULLIF(''@dieDate_Date'', ''''), ''YYYY-MM-DD HH24:MI:SS'')
    END AS die_date
)
UPDATE pat_personal_main 
SET
  in_out_class =  CASE (SELECT is_die FROM die_info)
    WHEN ''0'' THEN in_out_class 
    ELSE ''2''
    END 
  , is_die = (SELECT is_die FROM die_info)
  , die_date = CASE (SELECT is_die FROM die_info)
    WHEN ''0'' THEN NULL 
    ELSE (SELECT die_date FROM die_info)
    END ,
    up_date = CURRENT_TIMESTAMP
WHERE
  facility_cd = ''@facilityCd'' 
  AND hosp_pat_id = ''@hospPatId'' 
  AND pat_id = @patId;', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)富士通の患者プロファイル_生存の有無登録', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, NULL);

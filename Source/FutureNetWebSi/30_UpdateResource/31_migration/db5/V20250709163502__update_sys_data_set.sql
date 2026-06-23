DELETE FROM sys_data_set
WHERE sql_cd IN (-303101);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-303101, 'WITH new_name_info AS ( 
  SELECT
    substring(''@patLastName'' ::TEXT from ''^(.*?)[\u3000\s]'') AS patLastName
    , substring(''@patLastName'' ::TEXT from ''[\u3000\s](.*)'') AS patFirstName
    , substring(''@patLastNmKana'' ::TEXT from ''^(.*?)[\u3000\s]'') AS patLastNmKana
    , substring(''@patLastNmKana'' ::TEXT from ''[\u3000\s](.*)'') AS patFirstNmKana
) 
, birthday_info AS ( 
SELECT
  CASE WHEN left(wareki, 1) = ''M'' THEN (18670000 + to_number(right(wareki, 6), ''999999'')) :: text
       WHEN left(wareki, 1) = ''T'' THEN (19110000 + to_number(right(wareki, 6), ''999999'')) :: text
       WHEN left(wareki, 1) = ''S'' THEN (19250000 + to_number(right(wareki, 6), ''999999'')) :: text
       WHEN left(wareki, 1) = ''H'' THEN (19880000 + to_number(right(wareki, 6), ''999999'')) :: text
       WHEN left(wareki, 1) = ''R'' THEN (20180000 + to_number(right(wareki, 6), ''999999'')) :: text
       else wareki
  END AS seireki
FROM
  (
    SELECT ''@patBirthday'' AS wareki
  ) AS tmp
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
  NULL
  , LEFT(NULLIF(''@hospPatId'', ''''),12)
  , NULL
  , NULLIF(''@facilityCd'', '''')
  , personal_info_encrypt((SELECT patLastName FROM new_name_info)) 
  , personal_info_encrypt((SELECT patFirstName FROM new_name_info))
  , personal_info_encrypt((SELECT patLastNmKana FROM new_name_info))
  , personal_info_encrypt((SELECT patFirstNmKana FROM new_name_info))
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , (SELECT seireki FROM birthday_info)
  , CASE  
    WHEN ''@patSex'' NOT IN (''1'',''2'') THEN 0
    ELSE TO_NUMBER(''@patSex'', ''FM9999999999999999'') 
    END
  , ''JPN''
  , 0
  , 0
  , 0
  , 0
  , NULL
  , NULL
  , NULL
  , COALESCE(NULLIF(''@dialDiffComInfo'', ''''), ''[]'') ::JSONB
  , NULL
  , NULL
  , json_build_object( 
      ''zip_cd''
      , NULLIF(''@patContactInfo.zipCd'', '''')
      , ''address''
      , NULLIF(''@patContactInfo.address1'' || ''@patContactInfo.address2'', '''')
      , ''tel1''
      , NULLIF(''@patContactInfo.tel1'', '''')
      , ''tel2''
      , NULLIF(''@patContactInfo.tel2'', '''')
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
  ,  ''[]'' ::JSONB
  ,  ''[]'' ::JSONB
  , ''[]'' ::JSONB
  , ''0''
  , CURRENT_TIMESTAMP
  , CURRENT_TIMESTAMP
  , NULL
  , NULL
  , NULL
  , NULL
)', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)患者個人情報の新規登録', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, '[{"sql_cd": -303001, "field_name": "dial_diff_com_info", "replace_var": "@dialDiffComInfo"}]'::jsonb);
DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-603001,-603002,-603201,-603205);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-603001, 'WITH name_info AS ( 
SELECT
  REPLACE(REPLACE(COALESCE(substring(@lastName ::TEXT from ''^(.*?)[\u3000\s]''), nullif(@lastName ::TEXT,'''')), ''　'', ''''), '' '', '''') AS patLastName,
  REPLACE(REPLACE(substring(@lastName ::TEXT from ''[\u3000\s](.*)''), ''　'', ''''), '' '', '''') AS patFirstName
),
check_info AS (
  SELECT
    CASE
      WHEN NULLIF(REPLACE(REPLACE(concat((elem ->> ''last_name'')::TEXT, (elem ->> ''first_name'')::TEXT), ''　'', ''''), '' '', ''''), '''') = NULLIF(REPLACE(REPLACE(@lastName ::TEXT, ''　'', ''''), '' '', ''''), '''')
        AND (elem ->> ''relation_name'')::TEXT =
          CASE
            WHEN @relationCd = ''0'' THEN ''その他(本人)''::TEXT
            WHEN @relationCd = ''99'' THEN ''その他''::TEXT
            ELSE NULL
          END
      THEN ''1''
      ELSE ''0''
    END AS update_flg
  FROM pat_personal_main
  CROSS join lateral jsonb_array_elements(personal_info_decrypt_jsonb(other_contact_info)) AS elem
WHERE
  is_del = ''0''
  AND hosp_pat_id = @hospPatId
  AND facility_cd = @facilityCd
)
select
  pat_id,
  fn_pat_id,
  hosp_pat_id,
  nkk_pat_id,
  facility_cd,
  personal_info_decrypt(pat_last_name) as pat_last_name,
  personal_info_decrypt(pat_first_name) as pat_first_name,
  personal_info_decrypt(pat_last_name_kana) as pat_last_name_kana,
  personal_info_decrypt(pat_first_name_kana) as pat_first_name_kana,
  personal_info_decrypt(pat_last_name_alpha) as pat_last_name_alpha,
  personal_info_decrypt(pat_first_name_alpha) as pat_first_name_alpha,
  personal_info_decrypt(pat_birth_name) as pat_birth_name,
  personal_info_decrypt(pat_birth_name_kana) as pat_birth_name_kana,
  personal_info_decrypt(pat_birth_name_alpha) as pat_birth_name_alpha,
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
  personal_info_decrypt_jsonb(pat_contact_info) as pat_contact_info,
  personal_info_decrypt_jsonb(other_contact_info) as other_contact_info,
  personal_info_decrypt_jsonb(vendor_contact_info) as vendor_contact_info,
  insurance_info,
  is_del,
  up_date,
  reg_date,
  primary_disease_cd,
  remote_monitor_service,
  personal_info_decrypt(remote_monitor_user_id) as remote_monitor_user_id,
  personal_info_decrypt(remote_monitor_user_pw) as remote_monitor_user_pw
from
  pat_personal_main
where
  is_del = ''0''
and
  hosp_pat_id = @hospPatId
and
  facility_cd = @facilityCd
and
  @contactCtlNo in (''2'', ''3'')
and
  exists (SELECT update_flg FROM check_info where update_flg = ''1'');', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)MIRAIsの患者プロファイル', '2024-03-26 16:11:32.036', CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-603002, 'WITH name_info AS ( 
SELECT
  REPLACE(REPLACE(COALESCE(substring(@lastName ::TEXT from ''^(.*?)[\u3000\s]''), nullif(@lastName ::TEXT,'''')), ''　'', ''''), '' '', '''') AS patLastName,
  REPLACE(REPLACE(substring(@lastName ::TEXT from ''[\u3000\s](.*)''), ''　'', ''''), '' '', '''') AS patFirstName
),
check_info AS (
  SELECT
    CASE
      WHEN NULLIF(REPLACE(REPLACE(concat((elem ->> ''last_name'')::TEXT, (elem ->> ''first_name'')::TEXT), ''　'', ''''), '' '', ''''), '''') = NULLIF(REPLACE(REPLACE(@lastName ::TEXT, ''　'', ''''), '' '', ''''), '''')
        AND (elem ->> ''relation_name'')::TEXT =
          CASE
            WHEN @relationCd = ''0'' THEN ''その他(本人)''::TEXT
            WHEN @relationCd = ''99'' THEN ''その他''::TEXT
            ELSE NULL
          END
      THEN ''1''
      ELSE ''0''
    END AS update_flg
  FROM pat_personal_main
  CROSS join lateral jsonb_array_elements(personal_info_decrypt_jsonb(other_contact_info)) AS elem
WHERE
  is_del = ''0''
  AND hosp_pat_id = @hospPatId
  AND facility_cd = @facilityCd
)
select
  pat_id,
  fn_pat_id,
  hosp_pat_id,
  nkk_pat_id,
  facility_cd,
  personal_info_decrypt(pat_last_name) as pat_last_name,
  personal_info_decrypt(pat_first_name) as pat_first_name,
  personal_info_decrypt(pat_last_name_kana) as pat_last_name_kana,
  personal_info_decrypt(pat_first_name_kana) as pat_first_name_kana,
  personal_info_decrypt(pat_last_name_alpha) as pat_last_name_alpha,
  personal_info_decrypt(pat_first_name_alpha) as pat_first_name_alpha,
  personal_info_decrypt(pat_birth_name) as pat_birth_name,
  personal_info_decrypt(pat_birth_name_kana) as pat_birth_name_kana,
  personal_info_decrypt(pat_birth_name_alpha) as pat_birth_name_alpha,
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
  personal_info_decrypt_jsonb(pat_contact_info) as pat_contact_info,
  personal_info_decrypt_jsonb(other_contact_info) as other_contact_info,
  personal_info_decrypt_jsonb(vendor_contact_info) as vendor_contact_info,
  insurance_info,
  is_del,
  up_date,
  reg_date,
  primary_disease_cd,
  remote_monitor_service,
  personal_info_decrypt(remote_monitor_user_id) as remote_monitor_user_id,
  personal_info_decrypt(remote_monitor_user_pw) as remote_monitor_user_pw
from
  pat_personal_main
where
  is_del = ''0''
and
  hosp_pat_id = @hospPatId
and
  facility_cd = @facilityCd
and
  @contactCtlNo in (''2'', ''3'')
and
  not exists (SELECT update_flg FROM check_info where update_flg = ''1'');', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)MIRAIsの患者プロファイル', '2024-03-26 16:11:32.036', CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
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
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@patSex'', ''FM9999999999999999'') 
    END
  , pat_blood_type_abo = CASE ''@patBloodTypeAbo'' 
    WHEN '''' THEN 0 
    ELSE TO_NUMBER(''@patBloodTypeAbo'', ''FM9999999999999999'') 
    END
  , pat_blood_type_rh = CASE ''@patBloodTypeRh'' 
    WHEN '''' THEN 0 
    ELSE TO_NUMBER(''@patBloodTypeRh'', ''FM9999999999999999'') 
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
  AND facility_cd = ''@facilityCd''', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)患者個人情報の取得の修正', '2024-03-26 16:11:32.036', CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-603205, 'WITH new_name_info AS (
  SELECT
    COALESCE(substring(''@lastName'' ::TEXT from ''^(.*?)[\u3000\s]''), nullif(''@lastName'','''')) AS patLastName
    , substring(''@lastName'' ::TEXT from ''[\u3000\s](.*)'') AS patFirstName
) 
UPDATE
  ntss.pat_personal_main
SET
  other_contact_info = other_contact_info 
    || json_build_object(''ctl_no'',null,''disp_order'',null,''is_key_person'',null,''pat_id'',null,
      ''last_name'', (SELECT patLastName FROM new_name_info) ,
      ''first_name'', (SELECT patFirstName FROM new_name_info) ,
      ''last_name_kana'',null,''first_name_kana'',null,''relation_cd'', NULL ,''relation_name'', CASE WHEN ''@relationCd'' = ''0'' THEN ''その他(本人)'' WHEN ''@relationCd'' = ''99'' THEN ''その他'' ELSE null END ,''zip_cd'',''@zipCd'',''address'',''@address'',''e_mail'',null,''work_name'',null,''work_tel'',null,''tel1'',''@tel1'',''tel2'',null,''fax'',null,''memo1'', null,''memo2'',null)::jsonb
WHERE
  is_del = ''0''
  AND hosp_pat_id = ''@hospPatId''
  AND facility_cd = ''@facilityCd''', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)患者個人情報の取得', '2024-03-26 16:11:32.036', CURRENT_TIMESTAMP, NULL);

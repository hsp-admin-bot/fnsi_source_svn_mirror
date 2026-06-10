DELETE FROM ntss.sys_data_set
WHERE sql_cd=-501092;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-501092, 'WITH new_name_info AS ( 
  SELECT
    COALESCE(substring(''@patLastName'' ::TEXT from ''^(.*?)[\u3000\s]''), ''@patLastName'') AS patLastName
    , substring(''@patLastName'' ::TEXT from ''[\u3000\s](.*)'') AS patFirstName
    , COALESCE(substring(''@patLastNmKana'' ::TEXT from ''^(.*?)[\u3000\s]''), ''@patLastNmKana'') AS patLastNmKana
    , substring(''@patLastNmKana'' ::TEXT from ''[\u3000\s](.*)'') AS patFirstNmKana
)
, check_name_update AS (
  SELECT
    CASE
    WHEN ''@patLastName'' != ''''
    THEN CASE
      WHEN POSITION('' '' IN ''@patLastName'') = 0
        AND POSITION(''　'' IN ''@patLastName'') = 0
        AND ''@patLastName'' = CONCAT(personal_info_decrypt(pat_last_name), personal_info_decrypt(pat_first_name))
      THEN ''0''
      ELSE ''1''
      END
    ELSE CASE
      WHEN POSITION('' '' IN ''@patLastNmKana'') = 0
        AND POSITION(''　'' IN ''@patLastNmKana'') = 0
        AND ''@patLastNmKana'' = CONCAT(personal_info_decrypt(pat_last_name), personal_info_decrypt(pat_first_name))
      THEN ''0''
      ELSE ''1''
      END
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
    AND pat_id = @patId
    AND facility_cd = ''@facilityCd''
    AND is_die = ''0''
)
UPDATE pat_personal_main 
SET
  pat_last_name =
    CASE WHEN (SELECT name_update_flg FROM check_name_update) = ''1''
    THEN personal_info_encrypt((SELECT CASE WHEN NULLIF(''@patLastName'', '''') IS NULL THEN patLastNmKana ELSE patLastName END FROM new_name_info))
    ELSE pat_last_name END
  , pat_first_name =
    CASE WHEN (SELECT name_update_flg FROM check_name_update) = ''1''
    THEN personal_info_encrypt((SELECT CASE WHEN NULLIF(''@patLastName'', '''') IS NULL THEN patFirstNmKana ELSE patFirstName END FROM new_name_info))
    ELSE pat_first_name END
  , pat_last_name_kana =
    CASE WHEN (SELECT name_kana_update_flg FROM check_name_update) = ''1''
    THEN personal_info_encrypt((SELECT patLastNmKana FROM new_name_info))
    ELSE pat_last_name_kana END
  , pat_first_name_kana =
    CASE WHEN (SELECT name_kana_update_flg FROM check_name_update) = ''1''
    THEN personal_info_encrypt((SELECT patFirstNmKana FROM new_name_info))
    ELSE pat_first_name_kana END
  , pat_birthday = CASE
    WHEN LENGTH(''@patBirthday'') = 8 AND ''@patBirthday'' ~ ''^[0-9]+$'' THEN ''@patBirthday''
    ELSE NULL
    END
  , pat_sex = CASE 
    WHEN ''@patSex'' IN (''1'',''2'') THEN TO_NUMBER(''@patSex'', ''FM9999999999999999'') 
    ELSE 0 
    END
  , pat_blood_type_abo = CASE ''@patBloodTypeAbo'' 
    WHEN '''' THEN 0 
    WHEN ''NoXmlTag'' THEN pat_blood_type_abo
    ELSE TO_NUMBER(''@patBloodTypeAbo'', ''FM9999999999999999'') 
    END
  , pat_blood_type_rh = CASE ''@patBloodTypeRh'' 
    WHEN '''' THEN 0 
    WHEN ''NoXmlTag'' THEN pat_blood_type_rh
    ELSE TO_NUMBER(''@patBloodTypeRh'', ''FM9999999999999999'') 
    END
  , in_out_class = CASE WHEN @inOut = 3 THEN in_out_class
    ELSE @inOut
    END
  , die_cd = CASE ''@dieCd''
    WHEN '''' THEN NULL
    WHEN ''NoXmlTag'' THEN die_cd
    ELSE TO_NUMBER(''@dieCd'', ''FM99999999999999999999999999999999'') 
    END
  , pat_contact_info = personal_info_encrypt_jsonb(jsonb_build_object(
      ''zip_cd'',
      CASE
        WHEN ''@patContactInfo.zipCd'' = ''NoXmlTag'' THEN personal_info_decrypt_jsonb(pat_contact_info) ->> ''zip_cd''
        ELSE NULLIF(''@patContactInfo.zipCd'', '''')
        END,
      ''address'',
      CASE
        WHEN ''@patContactInfo.address'' = ''NoXmlTag'' THEN personal_info_decrypt_jsonb(pat_contact_info) ->> ''address''
        ELSE NULLIF((TRIM(TRIM(TRIM(''@patContactInfo.address'', ''　''), '' ''), ''　'')), '''')
        END,
      ''tel1'', 
      CASE
        WHEN ''@patContactInfo.tel1'' = ''NoXmlTag'' THEN personal_info_decrypt_jsonb(pat_contact_info) ->> ''tel1''
        ELSE NULLIF(''@patContactInfo.tel1'', '''')
        END,
      ''tel2'',         NULLIF(''@patContactInfo.tel2'', ''''),
      ''fax'',          NULLIF(''@patContactInfo.fax'', ''''),
      ''e_mail'',       NULLIF(''@patContactInfo.eMail'', ''''),
      ''work_name'',    NULLIF(''@patContactInfo.workName'', ''''),
      ''work_address'', NULLIF(''@patContactInfo.workAddress'', ''''),
      ''work_tel'',     NULLIF(''@patContactInfo.workTel'', ''''),
      ''memo1'',
      CASE
        WHEN ''@patContactInfo.memo1'' = ''NoXmlTag''
        THEN CONCAT(regexp_replace(personal_info_decrypt_jsonb(pat_contact_info) ->> ''memo1'', ''【転帰】.*'', ''''),
            CASE
              WHEN ''@isDie'' = ''0''  AND NULLIF(NULLIF(''@tenki'', ''''), ''NoXmlTag'') IS NOT NULL THEN ''【転帰】'' || ''@tenki''
              ELSE NULL
            END
          )
        ELSE CONCAT(regexp_replace(personal_info_decrypt_jsonb(pat_contact_info) ->> ''memo1'', ''【コメント】.*|【転帰】.*'', ''''),
          CASE
            WHEN NULLIF(''@patContactInfo.memo1'', '''') IS NULL THEN
              CASE
                WHEN ''@isDie'' = ''0''  AND NULLIF(NULLIF(''@tenki'', ''''), ''NoXmlTag'') IS NOT NULL THEN ''【転帰】'' || ''@tenki''
                ELSE NULL
              END
            ELSE ''【コメント】'' || ''@patContactInfo.memo1'' || 
              CASE
                WHEN ''@isDie'' = ''0'' AND NULLIF(NULLIF(''@tenki'', ''''), ''NoXmlTag'') IS NOT NULL THEN E''\n''  || ''【転帰】'' || ''@tenki''
                ELSE ''''
              END
            END
            )
        END,
      ''memo2'',       NULLIF(''@patContactInfo.memo2'', '''')
    ) )
  , up_date = CURRENT_TIMESTAMP
  , primary_disease_cd = CASE ''@primaryDiseaseCd'' 
    WHEN '''' THEN NULL 
    ELSE (CASE WHEN ''@upBaseDiseaseFlg'' = ''0'' THEN NULL ELSE TO_NUMBER(''@primaryDiseaseCd'', ''FM99999999999999999999999999999999'') END) 
    END
WHERE
  is_del = ''0'' 
  AND pat_id = @patId
  AND facility_cd = ''@facilityCd''', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの患者個人情報の取得の修正', '2025-03-18 11:35:01.176', CURRENT_TIMESTAMP, '[{"sql_cd": 1009, "field_name": "up_base_disease_flg", "replace_var": "@upBaseDiseaseFlg"}, {"sql_cd": -501061, "field_name": "disease_cd", "replace_var": "@dieCd"}, {"sql_cd": -502000, "field_name": "in_out", "replace_var": "@inOut"}]'::jsonb);

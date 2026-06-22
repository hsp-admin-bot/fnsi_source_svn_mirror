DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-600015,9102,9103);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600015, 'WITH new_name_info AS (
  SELECT
    CASE
        WHEN POSITION('' '' IN ''@patLastName'') = 0 AND POSITION(''　'' IN ''@patLastName'') = 0 THEN ''@patLastName''
        WHEN POSITION('' '' IN ''@patLastName'') > 0 THEN TRIM(substring(''@patLastName'' FROM 1 FOR POSITION('' '' IN ''@patLastName'') - 1))
        ELSE TRIM(substring(''@patLastName'' FROM 1 FOR POSITION(''　'' IN ''@patLastName'') - 1))
    END AS patLastName,
    CASE
        WHEN POSITION('' '' IN ''@patLastName'') > 0 THEN TRIM(substring(''@patLastName'' FROM POSITION('' '' IN ''@patLastName'') + 1))
        WHEN POSITION(''　'' IN ''@patLastName'') > 0 THEN TRIM(substring(''@patLastName'' FROM POSITION(''　'' IN ''@patLastName'') + 1))
        ELSE ''''
    END AS patFirstName,
    CASE
        WHEN POSITION('' '' IN ''@patLastNmKana'') = 0 AND POSITION(''　'' IN ''@patLastNmKana'') = 0 THEN ''@patLastNmKana''
        WHEN POSITION('' '' IN ''@patLastNmKana'') > 0 THEN TRIM(substring(''@patLastNmKana'' FROM 1 FOR POSITION('' '' IN ''@patLastNmKana'') - 1))
        ELSE TRIM(substring(''@patLastNmKana'' FROM 1 FOR POSITION(''　'' IN ''@patLastNmKana'') - 1))
    END AS patLastNmKana,
    CASE
        WHEN POSITION('' '' IN ''@patLastNmKana'') > 0 THEN TRIM(substring(''@patLastNmKana'' FROM POSITION('' '' IN ''@patLastNmKana'') + 1))
        WHEN POSITION(''　'' IN ''@patLastNmKana'') > 0 THEN TRIM(substring(''@patLastNmKana'' FROM POSITION(''　'' IN ''@patLastNmKana'') + 1))
        ELSE ''''
    END AS patFirstNmKana
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
    AND pat_id = @patId
    AND facility_cd = ''@facilityCd''
    AND is_die = ''0''
)
UPDATE pat_personal_main
SET
  pat_last_name = CASE (SELECT name_update_flg FROM check_name_update)
    WHEN ''1'' THEN personal_info_encrypt((SELECT patLastName FROM new_name_info))
    ELSE pat_last_name
    END
  , pat_first_name = CASE (SELECT name_update_flg FROM check_name_update)
    WHEN ''1'' THEN personal_info_encrypt((SELECT patFirstName FROM new_name_info))
    ELSE pat_first_name
    END
  , pat_last_name_kana = CASE (SELECT name_kana_update_flg FROM check_name_update)
    WHEN ''1'' THEN personal_info_encrypt((SELECT patLastNmKana FROM new_name_info))
    ELSE pat_last_name_kana
    END
  , pat_first_name_kana = CASE (SELECT name_kana_update_flg FROM check_name_update)
    WHEN ''1'' THEN personal_info_encrypt((SELECT patFirstNmKana FROM new_name_info))
    ELSE pat_first_name_kana
    END
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
    WHEN ''@dieDate_Date'' != '''' THEN 2
    WHEN ''@medicalCareInfo.wardCd'' = '''' THEN 0
    ELSE 1
    END
  , severity_cd = CASE ''@mstSeverityCd''
    WHEN ''@'' || ''mstSeverityCd'' THEN NULL
    ELSE TO_NUMBER(''@mstSeverityCd'', ''FM99999999999999999999999999999999'')
    END
  , transport_cd = CASE ''@mstTransportCd''
    WHEN ''@'' || ''mstTransportCd'' THEN NULL
    ELSE TO_NUMBER(''@mstTransportCd'', ''FM99999999999999999999999999999999'')
    END
  , pat_contact_info = CASE ''@patContactInfoFlg''
    WHEN '''' THEN ''@patContactInfoValue''
    ELSE json_build_object(
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
  , up_date = CURRENT_TIMESTAMP
WHERE
  is_del = ''0''
  AND pat_id = @patId
  AND facility_cd = ''@facilityCd''
  AND is_die = ''0''', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)患者個人情報の取得の修正', '2025-03-18 11:34:58.308', CURRENT_TIMESTAMP, '[{"sql_cd": -600011, "field_name": "severity_cd", "replace_var": "@mstSeverityCd"}, {"sql_cd": -600012, "field_name": "transport_cd", "replace_var": "@mstTransportCd"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(9102, 'UPDATE pat_personal_main 
SET
  dial_diff_com_info = COALESCE(NULLIF(''@dialDiffComInfo'', ''''), ''[]'') :: JSONB
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND hosp_pat_id = ''@hospPatId'' 
  AND facility_cd = ''@facilityCd''
  AND is_die = ''0''', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECの「連絡先情報、透析困難情報」のクリア', '2021-11-23 12:12:12.000', CURRENT_TIMESTAMP, '[{"sql_cd": 1001, "field_name": "dial_diff_com_info", "replace_var": "@dialDiffComInfo"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(9103, 'WITH pat_name AS (
  SELECT
    CASE
        WHEN POSITION('' '' IN ''@otherContactInfo.patName'') = 0 AND POSITION(''　'' IN ''@otherContactInfo.patName'') = 0 THEN ''@otherContactInfo.patName''
        WHEN POSITION('' '' IN ''@otherContactInfo.patName'') > 0 THEN TRIM(substring(''@otherContactInfo.patName'' FROM 1 FOR POSITION('' '' IN ''@otherContactInfo.patName'') - 1))
        ELSE TRIM(substring(''@otherContactInfo.patName'' FROM 1 FOR POSITION(''　'' IN ''@otherContactInfo.patName'') - 1))
    END AS last_name,
    CASE
        WHEN POSITION('' '' IN ''@otherContactInfo.patName'') > 0 THEN TRIM(substring(''@otherContactInfo.patName'' FROM POSITION('' '' IN ''@otherContactInfo.patName'') + 1))
        WHEN POSITION(''　'' IN ''@otherContactInfo.patName'') > 0 THEN TRIM(substring(''@otherContactInfo.patName'' FROM POSITION(''　'' IN ''@otherContactInfo.patName'') + 1))
        ELSE ''''
    END AS first_name,
    CASE
        WHEN POSITION('' '' IN ''@otherContactInfo.patNameKana'') = 0 AND POSITION(''　'' IN ''@otherContactInfo.patNameKana'') = 0 THEN ''@otherContactInfo.patNameKana''
        WHEN POSITION('' '' IN ''@otherContactInfo.patNameKana'') > 0 THEN TRIM(substring(''@otherContactInfo.patNameKana'' FROM 1 FOR POSITION('' '' IN ''@otherContactInfo.patNameKana'') - 1))
        ELSE TRIM(substring(''@otherContactInfo.patNameKana'' FROM 1 FOR POSITION(''　'' IN ''@otherContactInfo.patNameKana'') - 1))
    END AS last_name_kana,
    CASE
        WHEN POSITION('' '' IN ''@otherContactInfo.patNameKana'') > 0 THEN TRIM(substring(''@otherContactInfo.patNameKana'' FROM POSITION('' '' IN ''@otherContactInfo.patNameKana'') + 1))
        WHEN POSITION(''　'' IN ''@otherContactInfo.patNameKana'') > 0 THEN TRIM(substring(''@otherContactInfo.patNameKana'' FROM POSITION(''　'' IN ''@otherContactInfo.patNameKana'') + 1))
        ELSE ''''
    END AS first_name_kana
)
, check_name_update AS (
  SELECT
    info ->> ''last_name'' AS last_name
    , info ->> ''first_name'' AS first_name
    , info ->> ''last_name_kana'' AS last_name_kana
    , info ->> ''first_name_kana'' AS first_name_kana
    , CASE
      WHEN POSITION('' '' IN ''@otherContactInfo.patName'') = 0
        AND POSITION(''　'' IN ''@otherContactInfo.patName'') = 0
        AND ''@otherContactInfo.patName'' = CONCAT((info ->> ''last_name''), (info ->> ''first_name''))
      THEN ''0''
      ELSE ''1''
      END AS name_update_flg
    , CASE
      WHEN POSITION('' '' IN ''@otherContactInfo.patNameKana'') = 0
        AND POSITION(''　'' IN ''@otherContactInfo.patNameKana'') = 0
        AND ''@otherContactInfo.patNameKana'' = CONCAT((info ->> ''last_name_kana''), (info ->> ''first_name_kana''))
      THEN ''0''
      ELSE ''1''
      END AS name_kana_update_flg
  FROM
    pat_personal_main
    CROSS JOIN LATERAL jsonb_array_elements(personal_info_decrypt_jsonb(other_contact_info)) WITH ORDINALITY t(info,idx)
  WHERE
    is_del = ''0''
    AND pat_id = @patId
    AND facility_cd = ''@facilityCd''
    AND is_die = ''0''
    AND idx = 1
)
, name_data AS (
  SELECT
    CASE COALESCE((SELECT name_update_flg FROM check_name_update), ''1'')
    WHEN ''1'' THEN (SELECT last_name FROM pat_name)
    ELSE (SELECT last_name FROM check_name_update)
    END AS last_name
    , CASE COALESCE((SELECT name_update_flg FROM check_name_update), ''1'')
    WHEN ''1'' THEN (SELECT first_name FROM pat_name)
    ELSE (SELECT first_name FROM check_name_update)
    END AS first_name
    , CASE COALESCE((SELECT name_kana_update_flg FROM check_name_update), ''1'')
    WHEN ''1'' THEN (SELECT last_name_kana FROM pat_name)
    ELSE (SELECT last_name_kana FROM check_name_update)
    END AS last_name_kana
    , CASE COALESCE((SELECT name_kana_update_flg FROM check_name_update), ''1'')
    WHEN ''1'' THEN (SELECT first_name_kana FROM pat_name)
    ELSE (SELECT first_name_kana FROM check_name_update)
    END AS first_name_kana
)
, json_data AS (
  SELECT
  ''[{"ctl_no":1,"disp_order":0,"is_key_person":null,"pat_id":null,"last_name":"''
  || (SELECT last_name FROM name_data)
  ||''","first_name":"''
  || (SELECT first_name FROM name_data)
  ||''","last_name_kana":"''
  || (SELECT last_name_kana FROM name_data)
  ||''","first_name_kana":"''
  || (SELECT first_name_kana FROM name_data)
  ||''","relation_cd":null,"relation_name":null,"zip_cd":"@otherContactInfo.zipCd","address":"@otherContactInfo.address","e_mail":null,"work_name":null,"work_address":null,"work_tel":null,"tel1":"@otherContactInfo.tel1","tel2":null,"fax":null,"memo1":null,"memo2":null}]'' AS otherContactInfo
)
UPDATE pat_personal_main 
SET
  other_contact_info = CASE WHEN ''@otherContactInfo.tel1''='''' AND ''@otherContactInfo.zipCd''='''' AND ''@otherContactInfo.address''='''' THEN other_contact_info ELSE (SELECT otherContactInfo FROM json_data) :: jsonb END 
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND hosp_pat_id = ''@hospPatId'' 
  AND facility_cd = ''@facilityCd''
  AND is_die = ''0''', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECの「死亡患者、連絡先情報、透析困難情報」の更新', '2021-11-23 12:12:12.000', CURRENT_TIMESTAMP, NULL);

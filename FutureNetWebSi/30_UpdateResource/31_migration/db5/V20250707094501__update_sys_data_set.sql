DELETE FROM sys_data_set
WHERE sql_cd IN (-501061, -501081, -501091, -501092, -501100);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-501061, 'SELECT
    disease_cd AS disease_cd
FROM
    mst_disease
WHERE
    facility_cd = @facilityCd
    AND in_hospital_cd_1 = @diseaseCode
    AND is_del = ''0''
    AND is_disp = ''1''
ORDER BY disease_cd DESC LIMIT 1', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの患者プロファイル_診療科マスタ登録', '2025-03-12 00:10:40.493', CURRENT_TIMESTAMP, '[]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-501081, 'UPDATE pat_personal_main
SET
  is_die =
    CASE ''@tenki''
      WHEN ''@dieCode'' THEN ''1''
      WHEN ''NoXmlTag'' THEN is_die
      ELSE ''0'' END
  , die_cd =
    CASE ''@tenki''
      WHEN ''@dieCode'' THEN CASE ''@dieCd'' 
    WHEN '''' THEN NULL 
    ELSE CASE WHEN ''@dieCd'' ~ ''[0-9]'' THEN TO_NUMBER(''@dieCd'', ''FM99999999999999999999999999999999'') END 
    END
      WHEN ''NoXmlTag'' THEN die_cd
      ELSE NULL END
  , die_date =
    CASE 
      WHEN ''@tenki'' = ''@dieCode'' THEN
        CASE
          WHEN LENGTH(''@dieDate'') = 8 AND ''@dieDate'' ~ ''^[0-9]+$'' THEN TO_TIMESTAMP(''@dieDate'',''YYYYMMDD'')
          WHEN ''@dieDate'' = ''NoXmlTag'' THEN die_date
          ELSE NULL
        END
      WHEN ''@tenki'' = ''NoXmlTag'' AND is_die = ''1'' THEN
        CASE
          WHEN LENGTH(''@dieDate'') = 8 AND ''@dieDate'' ~ ''^[0-9]+$'' THEN TO_TIMESTAMP(''@dieDate'',''YYYYMMDD'')
          WHEN ''@dieDate'' = ''NoXmlTag'' THEN die_date
          ELSE NULL
        END
    END
  , up_date = CURRENT_TIMESTAMP
WHERE
  pat_id = @patId 
  AND facility_cd = ''@facilityCd'' 
  AND is_del = ''0''
', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの患者プロファイル_診療科マスタ登録', '2025-06-19 10:46:04.398', CURRENT_TIMESTAMP, '[{"sql_cd": -501071, "field_name": "die_code", "replace_var": "@dieCode"}, {"sql_cd": -501061, "field_name": "disease_cd", "replace_var": "@dieCd"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-501091, 'WITH new_name_info AS ( 
  SELECT
    COALESCE(substring(''@patLastName'' ::TEXT from ''^(.*?)[\u3000\s]''), ''@patLastName'') AS patLastName
    , substring(''@patLastName'' ::TEXT from ''[\u3000\s](.*)'') AS patFirstName
    , COALESCE(substring(''@patLastNmKana'' ::TEXT from ''^(.*?)[\u3000\s]''), ''@patLastNmKana'') AS patLastNmKana
    , substring(''@patLastNmKana'' ::TEXT from ''[\u3000\s](.*)'') AS patFirstNmKana
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
  , NULLIF(''@hospPatId'', '''')
  , NULLIF(''@nkkPatId'', '''')
  , NULLIF(''@facilityCd'', '''')
  , personal_info_encrypt((SELECT CASE WHEN NULLIF(''@patLastName'', '''') IS NULL THEN patLastNmKana ELSE patLastName END FROM new_name_info)) 
  , personal_info_encrypt((SELECT CASE WHEN NULLIF(''@patLastName'', '''') IS NULL THEN patFirstNmKana ELSE patFirstName END FROM new_name_info))
  , personal_info_encrypt((SELECT patLastNmKana FROM new_name_info))
  , personal_info_encrypt((SELECT patFirstNmKana FROM new_name_info))
  , NULLIF(''@patLastNmAlpha'', '''')
  , NULLIF(''@patFirstNmAlpha'', '''')
  , NULLIF(''@patBirthName'', '''')
  , NULLIF(''@patBirthNmKana'', '''')
  , NULLIF(''@patBirthNmAlpha'', '''')
  , CASE
    WHEN LENGTH(''@patBirthday'') = 8 AND ''@patBirthday'' ~ ''^[0-9]+$'' THEN ''@patBirthday''
    ELSE NULL
    END
  , CASE 
    WHEN ''@patSex'' IN (''1'',''2'') THEN TO_NUMBER(''@patSex'', ''FM9999999999999999'') 
    ELSE 0 
    END
  , NULLIF(''@nationality'', '''')
  , CASE  
    WHEN ''@patBloodTypeAbo'' IN (''1'',''2'',''3'',''4'') THEN TO_NUMBER(''@patBloodTypeAbo'', ''FM9999999999999999'')
    ELSE 0
    END
  , CASE 
    WHEN ''@patBloodTypeRh'' IN (''1'',''2'') THEN TO_NUMBER(''@patBloodTypeRh'', ''FM9999999999999999'')
    ELSE 0
    END
  , CASE ''@patBloodTypeSerovar'' 
    WHEN '''' THEN 0 
    ELSE TO_NUMBER(''@patBloodTypeSerovar'', ''FM9999999999999999'') 
    END
  , CASE WHEN @inOut = 3 THEN 0
    ELSE @inOut
    END
  , NULL
  , NULL
  , NULL
  , COALESCE(NULLIF(''@dialDiffComInfo'', ''''), ''[]'') ::JSONB
  , CASE ''@severityCd'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@severityCd'', ''FM99999999999999999999999999999999'') 
    END
  , CASE ''@transportCd'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@transportCd'', ''FM99999999999999999999999999999999'') 
    END
  , NULL
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
)', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの患者個人情報の取得の新規', '2025-04-11 21:12:25.816', CURRENT_TIMESTAMP, '[{"sql_cd": 1001, "field_name": "dial_diff_com_info", "replace_var": "@dialDiffComInfo"}, {"sql_cd": -501061, "field_name": "disease_cd", "replace_var": "@primaryDiseaseCd"}, {"sql_cd": -502000, "field_name": "in_out", "replace_var": "@inOut"}]'::jsonb);
INSERT INTO sys_data_set
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
  , pat_blood_type_abo = CASE 
    WHEN ''@patBloodTypeAbo'' IN (''1'',''2'',''3'',''4'') THEN TO_NUMBER(''@patBloodTypeAbo'', ''FM9999999999999999'') 
    WHEN ''@patBloodTypeAbo'' = ''NoXmlTag'' THEN pat_blood_type_abo
    ELSE 0
    END
  , pat_blood_type_rh = CASE 
    WHEN ''@patBloodTypeRh'' IN (''1'',''2'') THEN TO_NUMBER(''@patBloodTypeRh'', ''FM9999999999999999'')
    WHEN ''@patBloodTypeAbo'' = ''NoXmlTag'' THEN pat_blood_type_rh
    ELSE 0
    END
  , in_out_class = CASE WHEN @inOut = 3 THEN in_out_class
    ELSE @inOut
    END
  , pat_contact_info = personal_info_encrypt_jsonb(jsonb_build_object(
      ''zip_cd'',
      CASE
        WHEN ''@patContactInfo.zipCd'' = ''NoXmlTag'' THEN personal_info_decrypt_jsonb(pat_contact_info) ->> ''zip_cd''
        ELSE NULLIF(REPLACE(''@patContactInfo.zipCd'', ''-'', ''''), '''')
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
    ELSE TO_NUMBER(''@primaryDiseaseCd'', ''FM99999999999999999999999999999999'')
    END
WHERE
  is_del = ''0'' 
  AND pat_id = @patId
  AND facility_cd = ''@facilityCd''', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの患者個人情報の取得の修正', '2025-03-18 11:35:01.176', CURRENT_TIMESTAMP, '[{"sql_cd": 1009, "field_name": "up_base_disease_flg", "replace_var": "@upBaseDiseaseFlg"}, {"sql_cd": -501061, "field_name": "disease_cd", "replace_var": "@primaryDiseaseCd"}, {"sql_cd": -502000, "field_name": "in_out", "replace_var": "@inOut"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-501100, 'WITH diseaseInfo AS(
SELECT
    disease_cd AS diseaseCd
FROM
    mst_disease
WHERE
    facility_cd = ''@facilityCd''
    AND in_hospital_cd_1 = ''@diseaseCode''
    AND is_del = ''0''
    AND is_disp = ''1''
ORDER BY disease_cd DESC LIMIT 1
),
dieInfo AS(
SELECT
    disease_cd AS dieCd
FROM
    mst_disease
WHERE
    facility_cd = ''@facilityCd''
    AND in_hospital_cd_1 = ''@dieCode''
    AND is_del = ''0''
    AND is_disp = ''1''
ORDER BY disease_cd DESC LIMIT 1
),
isDie AS (SELECT
  CASE 
    WHEN info ->> ''value'' = ''@tenki'' THEN ''1''
    WHEN ''@tenki'' = ''NoXmlTag'' THEN ''@isDie''
    ELSE ''''
  END AS is_die
FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
WHERE
  facility_cd = ''@facilityCd''
  AND is_del = ''0''
  AND info ->> ''key0'' = ''@key0''
  AND info ->> ''key1'' = ''SSI_PATIENT_RECV''
  AND info ->> ''key2'' = ''DIE_CODE''),
outComeInfo AS(
  SELECT
    CASE
      WHEN (SELECT is_die FROM isDie) = ''1'' THEN ''10''
      ELSE ''0''
    END AS outCome
),
validDate AS(
  SELECT
    CASE 
       WHEN NULLIF(''@medicalHstInfo.outComeDate'','''') IS NULL THEN NULL
       WHEN ''@medicalHstInfo.outComeDate'' ~ ''^(19|20)\d{2}(0[1-9]|1[0-2])(0[1-9]|[12]\d|3[01])$'' 
            AND (
                 (''@medicalHstInfo.outComeDate'' ~ ''^(19|20)\d{2}02(29)$'' AND SUBSTRING(''@medicalHstInfo.outComeDate'', 1, 4)::int % 4 = 0 AND (SUBSTRING(''@medicalHstInfo.outComeDate'', 1, 4)::int % 100 != 0 OR SUBSTRING(''@medicalHstInfo.outComeDate'', 1, 4)::int % 400 = 0))
                 OR (''@medicalHstInfo.outComeDate'' ~ ''^(19|20)\d{2}(0[13578]|1[02])(0[1-9]|[12]\d|3[01])$'')
                 OR (''@medicalHstInfo.outComeDate'' ~ ''^(19|20)\d{2}(0[469]|11)(0[1-9]|[12]\d|30)$'')
                 OR (''@medicalHstInfo.outComeDate'' ~ ''^(19|20)\d{2}02(0[1-9]|1\d|2[0-8])$'')
            )
       THEN ''@medicalHstInfo.outComeDate''
       ELSE NULL
     END AS outComeDate,
     CASE 
        WHEN NULLIF(''@medicalHstInfo.diseaseDate'','''') IS NULL THEN NULL
        WHEN ''@medicalHstInfo.diseaseDate'' ~ ''^(19|20)\d{2}(0[1-9]|1[0-2])(0[1-9]|[12]\d|3[01])$'' 
            AND (
                 (''@medicalHstInfo.diseaseDate'' ~ ''^(19|20)\d{2}02(29)$'' AND SUBSTRING(''@medicalHstInfo.diseaseDate'', 1, 4)::int % 4 = 0 AND (SUBSTRING(''@medicalHstInfo.diseaseDate'', 1, 4)::int % 100 != 0 OR SUBSTRING(''@medicalHstInfo.diseaseDate'', 1, 4)::int % 400 = 0))
                 OR (''@medicalHstInfo.diseaseDate'' ~ ''^(19|20)\d{2}(0[13578]|1[02])(0[1-9]|[12]\d|3[01])$'')
                 OR (''@medicalHstInfo.diseaseDate'' ~ ''^(19|20)\d{2}(0[469]|11)(0[1-9]|[12]\d|30)$'')
                 OR (''@medicalHstInfo.diseaseDate'' ~ ''^(19|20)\d{2}02(0[1-9]|1\d|2[0-8])$'')
            )
        THEN ''@medicalHstInfo.diseaseDate''
        ELSE NULL
     END AS diseaseDate
),
dateInfo AS(
  SELECT
    CASE
      WHEN (SELECT is_die FROM isDie) = ''1'' THEN (SELECT outComeDate FROM validDate)
      ELSE ''''
    END AS dieDate,
    CASE
      WHEN (SELECT is_die FROM isDie) = ''1'' THEN (SELECT outComeDate FROM validDate)
      ELSE to_char(CURRENT_TIMESTAMP, ''YYYYMMDD'')
    END AS inOutDate
),
medi_data_exists_info AS(
SELECT CASE WHEN EXISTS (
      SELECT 1
      FROM jsonb_array_elements(medical_hst_info) AS elem
      WHERE COALESCE((elem->>''disease_cd'')::int, -1) = CASE
        WHEN (SELECT is_die FROM isDie) = ''1'' THEN COALESCE((SELECT dieCd FROM dieInfo), -1)
        ELSE (SELECT diseaseCd FROM diseaseInfo)
      END
      AND CASE WHEN (SELECT diseaseDate FROM validDate) IS NULL THEN true
        ELSE elem->>''disease_date'' = (SELECT diseaseDate FROM validDate)
        END
      AND elem->>''out_come'' = (SELECT outCome FROM outComeInfo)
    )
    THEN ''1''
    ELSE ''0''
    END exists_flag
FROM pat_unique
WHERE
  pat_id = @patId
AND facility_cd = ''@facilityCd''
AND is_del = ''0''
),
in_out_class AS(
  SELECT
    (
      CASE
        WHEN  (SELECT is_die FROM isDie) = ''1'' THEN ''2''
        WHEN info ->> ''value'' = ''@inOutClass'' THEN ''1''
        WHEN ''@inOutClass'' = ''NoXmlTag'' THEN ''@ppmInOutClass''
        ELSE ''0''
      END
    ) AS in_out
FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
WHERE
  facility_cd = ''@facilityCd''
  AND is_del = ''0''
  AND info ->> ''key0'' = ''@key0''
  AND info ->> ''key1'' = ''SSI_PATIENT_RECV''
  AND info ->> ''key2'' = ''CONV_INOUT_1''
),
in_out_ctl_no_calc AS(
  SELECT
    COUNT(1) + 1 AS ctl_no
  FROM
    pat_unique
    CROSS JOIN
      jsonb_array_elements(pat_unique.in_out_visit_history_info) AS data_calc
  WHERE
    pat_unique.pat_id = @patId
  AND facility_cd = ''@facilityCd''
  AND is_del = ''0''
  GROUP BY
    pat_unique.pat_id
),
data_new_info AS(
  SELECT
    COALESCE(ctl_no, 1) AS ctl_no,
    in_out AS in_out,
    NULL AS reason,
    NULL AS to_course,
    NULL AS to_doctor,
    0 AS disp_order,
    NULL AS period_end,
    ''@facilityCd'' AS facility_cd,
    NULL AS from_course,
    NULL AS from_doctor,
    (CASE in_out WHEN ''0'' THEN ''6'' WHEN ''1'' THEN ''4'' WHEN ''2'' THEN ''11'' ELSE ''6'' END)::TEXT AS move_in_out,
    NULL AS to_facility,
    (SELECT inOutDate FROM dateInfo) AS period_start,
    NULL AS from_facility,
    ''0'' AS course_is_free,
    ''0'' AS doctor_is_free,
    NULL AS period_end_day,
    NULL AS period_end_year,
    ''0'' AS facility_is_free,
    NULL AS period_end_month,
    CASE WHEN (SELECT inOutDate FROM dateInfo) IS NULL
THEN NULL
ELSE SUBSTR((SELECT inOutDate FROM dateInfo), 7, 2) END AS period_start_day,
    (SELECT inOutDate FROM dateInfo) AS period_start_date,
    CASE WHEN (SELECT inOutDate FROM dateInfo) IS NULL
THEN NULL
ELSE SUBSTR((SELECT inOutDate FROM dateInfo), 1, 4) END AS period_start_year,
    CASE WHEN (SELECT inOutDate FROM dateInfo) IS NULL
THEN NULL
ELSE SUBSTR((SELECT inOutDate FROM dateInfo), 5, 2) END AS period_start_month,
    ''0'' AS period_end_input_free,
    ''0'' AS period_start_input_free,
    NULL AS to_medicalInstitutionCd,
    NULL AS from_medicalInstitutionCd
  FROM
    in_out_class
    LEFT JOIN
      in_out_ctl_no_calc
    ON  true
),
in_out_data_exists_info AS(
  SELECT
    1 AS order_no,
    ''1'' AS exists_flag
  FROM
    in_out_class ioc
  WHERE
    ''@ppmInOutClass'' = ioc.in_out
  UNION
  SELECT
    2 AS order_no,
    ''0'' AS exists_flag
  ORDER BY
    order_no
  LIMIT 1
),
json_data AS(
  SELECT
    jsonb_build_object(
      ''ctl_no'',
      ctl_no,
      ''in_out'',
      in_out::integer,
      ''reason'',
      reason,
      ''to_course'',
      to_course,
      ''to_doctor'',
      to_doctor,
      ''disp_order'',
      disp_order,
      ''period_end'',
      period_end,
      ''facility_cd'',
      facility_cd,
      ''from_course'',
      from_course,
      ''from_doctor'',
      from_doctor,
      ''move_in_out'',
      move_in_out,
      ''to_facility'',
      to_facility,
      ''period_start'',
      period_start,
      ''from_facility'',
      from_facility,
      ''course_is_free'',
      course_is_free,
      ''doctor_is_free'',
      doctor_is_free,
      ''period_end_day'',
      period_end_day,
      ''period_end_year'',
      period_end_year,
      ''facility_is_free'',
      facility_is_free,
      ''period_end_month'',
      period_end_month,
      ''period_start_day'',
      period_start_day,
      ''period_start_date'',
      period_start_date,
      ''period_start_year'',
      period_start_year,
      ''period_start_month'',
      period_start_month,
      ''period_end_input_free'',
      period_end_input_free,
      ''period_start_input_free'',
      period_start_input_free,
      ''to_medicalInstitutionCd'',
      to_medicalInstitutionCd,
      ''from_medicalInstitutionCd'',
      from_medicalInstitutionCd
    ) AS new_data
  FROM
    data_new_info
)
UPDATE pat_unique
SET
  up_date = CURRENT_TIMESTAMP,
  medical_hst_info = CASE
    WHEN (SELECT exists_flag FROM medi_data_exists_info) = ''0''
    THEN medical_hst_info || (
      CASE 
        WHEN (SELECT is_die FROM isDie) = '''' 
          AND COALESCE((SELECT diseaseCd::text FROM diseaseInfo), '''') <> ''''
        THEN jsonb_build_object(
          ''memo'',
          ''@medicalHstInfo.memo'',
          ''ctl_no'',
          @nextCtlNo2,
          ''die_date'',
          null,
          ''out_come'',
          (SELECT outCome FROM outComeInfo),
          ''course_cd'',
          ''@medicalHstInfo.courseCd'',
          ''is_notice'',
          ''0'',
          ''disease_cd'',
          (SELECT diseaseCd FROM diseaseInfo),
          ''disp_order'',
          @nextCtlNo2 -1,
          ''disease_day'',
          CASE WHEN (SELECT diseaseDate FROM validDate) IS NULL
            THEN NULL
            ELSE substr((SELECT diseaseDate FROM validDate), 7, 2) 
          END,
          ''facility_cd'',
          ''@facilityCd'',
          ''disease_date'',
          (SELECT diseaseDate FROM validDate),
          ''disease_year'',
          CASE WHEN (SELECT diseaseDate FROM validDate) IS NULL
            THEN NULL
            ELSE substr((SELECT diseaseDate FROM validDate), 1, 4) 
          END,
          ''is_diagnosed'',
          ''0'',
          ''diagnosis_day'',
          ''@medicalHstInfo.diagnosisDay'',
          ''disease_month'',
          CASE WHEN (SELECT diseaseDate FROM validDate) IS NULL
            THEN NULL
            ELSE substr((SELECT diseaseDate FROM validDate), 5, 2) 
          END,
          ''out_come_date'',
          null,
          ''course_is_free'',
          ''0'',
          ''diagnosis_date'',
          ''@medicalHstInfo.diagnosisDate'',
          ''diagnosis_year'',
          ''@medicalHstInfo.diagnosisYear'',
          ''diagnosis_month'',
          ''@medicalHstInfo.diagnosisMonth'',
          ''is_main_disease'',
          ''0'',
          ''diagnostician_cd'',
          ''@medicalHstInfo.diagnosticianCd'',
          ''diagnosis_facility_cd'',
          ''@medicalHstInfo.diagnosisFacilityCd'',
          ''diagnostician_is_free'',
          ''0'',
          ''is_confirmation_biopsy'',
          ''0'',
          ''diagnosis_facility_is_free'',
          ''0'',
          ''disease_end_input_free'',
          ''0'',
          ''diagnosis_end_input_free'',
          ''0'',
          ''disease_start_input_free'',
          ''0'',
          ''diagnosis_start_input_free'',
          ''0'',
          ''is_dialysis_underlying_disease'',
          ''1''
        )
        WHEN 
          ((SELECT is_die FROM isDie) = ''1''
           AND EXISTS (
             SELECT 1
             FROM jsonb_array_elements(medical_hst_info) AS elem
             WHERE 
               COALESCE((elem->>''disease_cd'')::int, -1) = COALESCE((SELECT diseaseCd FROM diseaseInfo), -1)
               AND CASE 
                     WHEN (SELECT diseaseDate FROM validDate) IS NULL THEN true
                     ELSE elem->>''disease_date'' = (SELECT diseaseDate FROM validDate)
                   END
           ))
          OR
          (
            (SELECT is_die FROM isDie) = ''1'' 
            AND COALESCE((SELECT dieCd::text FROM dieInfo), '''') <> '''' 
            AND COALESCE((SELECT diseaseCd::text FROM diseaseInfo), '''') = ''''
          )
        THEN jsonb_build_object(
          ''memo'',
          ''@medicalHstInfo.memo'',
          ''ctl_no'',
          @nextCtlNo2,
          ''die_date'',
          (SELECT dieDate FROM dateInfo),
          ''out_come'',
          (SELECT outCome FROM outComeInfo),
          ''course_cd'',
          ''@medicalHstInfo.courseCd'',
          ''is_notice'',
          ''0'',
          ''disease_cd'',
          (SELECT dieCd FROM dieInfo),
          ''disp_order'',
          @nextCtlNo2 -1,
          ''disease_day'',
          null,
          ''facility_cd'',
          ''@facilityCd'',
          ''disease_date'',
          null,
          ''disease_year'',
          null,
          ''is_diagnosed'',
          ''0'',
          ''diagnosis_day'',
          ''@medicalHstInfo.diagnosisDay'',
          ''disease_month'',
          null,
          ''out_come_date'',
          (SELECT dieDate FROM dateInfo),
          ''course_is_free'',
          ''0'',
          ''diagnosis_date'',
          ''@medicalHstInfo.diagnosisDate'',
          ''diagnosis_year'',
          ''@medicalHstInfo.diagnosisYear'',
          ''diagnosis_month'',
          ''@medicalHstInfo.diagnosisMonth'',
          ''is_main_disease'',
          ''0'',
          ''diagnostician_cd'',
          ''@medicalHstInfo.diagnosticianCd'',
          ''diagnosis_facility_cd'',
          ''@medicalHstInfo.diagnosisFacilityCd'',
          ''diagnostician_is_free'',
          ''0'',
          ''is_confirmation_biopsy'',
          ''0'',
          ''diagnosis_facility_is_free'',
          ''0'',
          ''disease_end_input_free'',
          ''0'',
          ''diagnosis_end_input_free'',
          ''0'',
          ''disease_start_input_free'',
          ''0'',
          ''diagnosis_start_input_free'',
          ''0'',
          ''is_dialysis_underlying_disease'',
          ''0''
        )
        WHEN (SELECT is_die FROM isDie) = ''1'' AND COALESCE((SELECT dieCd::text FROM dieInfo), '''') <> '''' AND COALESCE((SELECT diseaseCd::text FROM diseaseInfo), '''') <> ''''
        THEN
          -- dieInfoとdiseaseInfoを両方登録する場合は配列で登録
          jsonb_build_array(
            jsonb_build_object(
          ''memo'',
          ''@medicalHstInfo.memo'',
          ''ctl_no'',
          @nextCtlNo2,
          ''die_date'',
          NULL,
          ''out_come'',
          ''0'',
          ''course_cd'',
          ''@medicalHstInfo.courseCd'',
          ''is_notice'',
          ''0'',
          ''disease_cd'',
          (SELECT diseaseCd FROM diseaseInfo),
          ''disp_order'',
          @nextCtlNo2 -1,
          ''disease_day'',
          CASE WHEN (SELECT diseaseDate FROM validDate) IS NULL
            THEN NULL
            ELSE substr((SELECT diseaseDate FROM validDate), 7, 2) END,
          ''facility_cd'',
          ''@facilityCd'',
          ''disease_date'',
          (SELECT diseaseDate FROM validDate),
          ''disease_year'',
          CASE WHEN (SELECT diseaseDate FROM validDate) IS NULL
            THEN NULL
            ELSE substr((SELECT diseaseDate FROM validDate), 1, 4) END,
          ''is_diagnosed'',
          ''0'',
          ''diagnosis_day'',
          ''@medicalHstInfo.diagnosisDay'',
          ''disease_month'',
          CASE WHEN (SELECT diseaseDate FROM validDate) IS NULL
            THEN NULL
            ELSE substr((SELECT diseaseDate FROM validDate), 5, 2) END,
          ''out_come_date'',
          NULL,
          ''course_is_free'',
          ''0'',
          ''diagnosis_date'',
          ''@medicalHstInfo.diagnosisDate'',
          ''diagnosis_year'',
          ''@medicalHstInfo.diagnosisYear'',
          ''diagnosis_month'',
          ''@medicalHstInfo.diagnosisMonth'',
          ''is_main_disease'',
          ''0'',
          ''diagnostician_cd'',
          ''@medicalHstInfo.diagnosticianCd'',
          ''diagnosis_facility_cd'',
          ''@medicalHstInfo.diagnosisFacilityCd'',
          ''diagnostician_is_free'',
          ''0'',
          ''is_confirmation_biopsy'',
          ''0'',
          ''diagnosis_facility_is_free'',
          ''0'',
          ''disease_end_input_free'',
          ''0'',
          ''diagnosis_end_input_free'',
          ''0'',
          ''disease_start_input_free'',
          ''0'',
          ''diagnosis_start_input_free'',
          ''0'',
          ''is_dialysis_underlying_disease'',
          ''1''
            ),
            jsonb_build_object(
              ''memo'',
          ''@medicalHstInfo.memo'',
          ''ctl_no'',
          @nextCtlNo2 + 1,
          ''die_date'',
          (SELECT dieDate FROM dateInfo),
          ''out_come'',
          (SELECT outCome FROM outComeInfo),
          ''course_cd'',
          ''@medicalHstInfo.courseCd'',
          ''is_notice'',
          ''0'',
          ''disease_cd'',
          (SELECT dieCd FROM dieInfo),
          ''disp_order'',
          @nextCtlNo2,
          ''disease_day'',
          null,
          ''facility_cd'',
          ''@facilityCd'',
          ''disease_date'',
          null,
          ''disease_year'',
          null,
          ''is_diagnosed'',
          ''0'',
          ''diagnosis_day'',
          ''@medicalHstInfo.diagnosisDay'',
          ''disease_month'',
          null,
          ''out_come_date'',
          (SELECT dieDate FROM dateInfo),
          ''course_is_free'',
          ''0'',
          ''diagnosis_date'',
          ''@medicalHstInfo.diagnosisDate'',
          ''diagnosis_year'',
          ''@medicalHstInfo.diagnosisYear'',
          ''diagnosis_month'',
          ''@medicalHstInfo.diagnosisMonth'',
          ''is_main_disease'',
          ''0'',
          ''diagnostician_cd'',
          ''@medicalHstInfo.diagnosticianCd'',
          ''diagnosis_facility_cd'',
          ''@medicalHstInfo.diagnosisFacilityCd'',
          ''diagnostician_is_free'',
          ''0'',
          ''is_confirmation_biopsy'',
          ''0'',
          ''diagnosis_facility_is_free'',
          ''0'',
          ''disease_end_input_free'',
          ''0'',
          ''diagnosis_end_input_free'',
          ''0'',
          ''disease_start_input_free'',
          ''0'',
          ''diagnosis_start_input_free'',
          ''0'',
          ''is_dialysis_underlying_disease'',
          ''0''
            )
          )
        ELSE ''[]''::jsonb
      END
    )
    ELSE medical_hst_info
  END

  ,
  in_out_visit_history_info = CASE
    WHEN((SELECT exists_flag FROM in_out_data_exists_info) = ''0''
    OR  in_out_visit_history_info IS NULL
    OR  in_out_visit_history_info = ''[]''
    ) THEN in_out_visit_history_info || (SELECT new_data FROM json_data)
    ELSE in_out_visit_history_info
  END
WHERE
  pat_id = @patId
AND facility_cd = ''@facilityCd''
AND is_del = ''0''', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの患者プロファイル(既往歴情報情報)', '2025-06-19 10:54:32.853', CURRENT_TIMESTAMP, '[{"sql_cd": -100001, "field_name": "in_out_class", "replace_var": "@ppmInOutClass"}, {"sql_cd": -100001, "field_name": "is_die", "replace_var": "@isDie"}]'::jsonb);
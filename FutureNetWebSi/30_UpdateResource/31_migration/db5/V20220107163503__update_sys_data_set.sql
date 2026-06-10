delete from "sys_data_set" where "sql_cd" in (1005, 1103, 1105, 1205, 1305, 1405, 3101, 3102, 3103, 3104, 3201, 3202, 3203, 3204, 3301, 3302, 3303, 3304, 3401, 3402);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1005, 'SELECT
  json_build_object( 
    ''insu_name'', NAME
    , ''insu_name_short'', insu_name_short
    , ''futan_g'', futan_g
    , ''futan_n'', futan_n
    , ''insu_class'', insu_type
  ) ::TEXT AS insu_info 
FROM
  mst_insurance 
WHERE
  insu_cd = COALESCE(NULLIF(@insuCd, ''''), ''-1'') ::INTEGER
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の初回申し込み→MSTの保険情報', '2022-01-07 18:21:46', '2022-01-07 18:21:46', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1103, 'UPDATE pat_personal_main 
SET fn_pat_id = NULLIF ( ''@fnPatId'', '''' ),
hosp_pat_id = LTRIM(NULLIF (''@hospPatId'', ''''), ''0''),
nkk_pat_id = NULLIF ( ''@nkkPatId'', '''' ),
facility_cd = NULLIF ( ''@facilityCd'', '''' ),
pat_last_name = personal_info_encrypt(split_part( ''@patLastName'', ''　'', 1 )),
pat_first_name = COALESCE(NULLIF(personal_info_encrypt(split_part( ''@patFirstName'', ''　'', 2 )), ''''), pat_first_name),
pat_last_name_kana =  case when split_part( ''@patLastNmKana'', ''　'', 2 ) is null or split_part( ''@patLastNmKana'', ''　'', 2 ) = '''' then 
    personal_info_encrypt(split_part( ''@patLastNmKana'', '' '', 1 ))
  else 
    personal_info_encrypt(split_part( ''@patLastNmKana'', ''　'', 1 ))
  end,
pat_first_name_kana = COALESCE(NULLIF(case when split_part( ''@patFirstNmKana'', ''　'', 2 ) is null or split_part( ''@patFirstNmKana'', ''　'', 2 ) = '''' then 
    personal_info_encrypt(split_part( ''@patFirstNmKana'', '' '', 2 ))
  else 
    personal_info_encrypt(split_part( ''@patFirstNmKana'', ''　'', 2 ))
  end, ''''), pat_first_name_kana),
pat_last_name_alpha = NULLIF ( ''@patLastNmAlpha'', '''' ),
pat_first_name_alpha = NULLIF ( ''@patFirstNmAlpha'', '''' ),
pat_birth_name = NULLIF ( ''@patBirthName'', '''' ),
pat_birth_name_kana = NULLIF ( ''@patBirthNmKana'', '''' ),
pat_birth_name_alpha = NULLIF ( ''@patBirthNmAlpha'', '''' ),
pat_birthday = NULLIF ( ''@patBirthday'', '''' ),
pat_sex =
CASE
        ''@patSex'' 
        WHEN '''' THEN
        NULL ELSE to_number( ''@patSex'', ''9999999999999999'' ) 
    END,
    nationality = NULLIF ( ''@nationality'', '''' ),
    pat_blood_type_abo =
CASE
        ''@patBloodTypeAbo'' 
        WHEN '''' THEN
        NULL ELSE to_number( ''@patBloodTypeAbo'', ''9999999999999999'' ) 
    END,
    pat_blood_type_rh =
CASE
    ''@patBloodTypeRh'' 
    WHEN '''' THEN
    NULL ELSE to_number( ''@patBloodTypeRh'', ''9999999999999999'' ) 
    END,
    pat_blood_type_serovar =
CASE
    ''@patBloodTypeSerovar'' 
    WHEN '''' THEN
    NULL ELSE to_number( ''@patBloodTypeSerovar'', ''9999999999999999'' ) 
    END,
    in_out_class =
CASE
    ''@inOutClass'' 
    WHEN '''' THEN
    NULL ELSE to_number( ''@inOutClass'', ''9999999999999999'' ) 
    END,
    is_die = NULLIF ( ''@isDie'', '''' ),
    die_cd =
CASE
        ''@dieCd'' 
        WHEN '''' THEN
        NULL ELSE to_number( ''@dieCd'', ''99999999999999999999999999999999'' ) 
    END,
    die_date =
CASE
    ''@dieDate_Date'' 
    WHEN '''' THEN
    NULL ELSE to_timestamp( ''@dieDate_Date'', ''yyyy-MM-dd hh24:mi:ss'' ) 
    END,
    dial_diff_com_info = ''@dialDiffComInfoValue'',
    severity_cd =
CASE
    ''@severityCd'' 
    WHEN '''' THEN
    NULL ELSE to_number( ''@severityCd'', ''99999999999999999999999999999999'' ) 
    END,
    transport_cd =
CASE
    ''@transportCd'' 
    WHEN '''' THEN
    NULL ELSE to_number( ''@transportCd'', ''99999999999999999999999999999999'' ) 
    END,
    pat_contact_info =
CASE
    ''@patContactInfoFlg'' 
    WHEN '''' THEN
    ''@patContactInfoValue'' ELSE json_build_object (
        ''zip_cd'',
        NULLIF ( ''@patContactInfo.zipCd'', '''' ),
        ''address'',
        NULLIF ( TRIM(TRIM(TRIM(''@patContactInfo.address'', ''　''), '' ''), ''　''), '''' ),
        ''tel1'',
        NULLIF ( ''@patContactInfo.tel1'', '''' ),
        ''tel2'',
        NULLIF ( ''@patContactInfo.tel2'', '''' ),
        ''fax'',
        NULLIF ( ''@patContactInfo.fax'', '''' ),
        ''e_mail'',
        NULLIF ( ''@patContactInfo.eMail'', '''' ),
        ''work_name'',
        NULLIF ( ''@patContactInfo.workName'', '''' ),
        ''work_address'',
        NULLIF ( ''@patContactInfo.workAddress'', '''' ),
        ''work_tel'',
        NULLIF ( ''@patContactInfo.workTel'', '''' ),
        ''memo1'',
        NULLIF ( ''@patContactInfo.memo1'', '''' ),
        ''memo2'',
        NULLIF ( ''@patContactInfo.memo2'', '''' ) 
    ) 
    END,
    other_contact_info = ''@otherContactInfoValue'',
    vendor_contact_info = ''@vendorContactInfoValue'',
    insurance_info = ''@insuranceInfoValue'',
    reg_date = ''@regDate'',
    up_date = CURRENT_TIMESTAMP,
    primary_disease_cd =
CASE
        ''@primaryDiseaseCd'' 
        WHEN '''' THEN
        NULL ELSE to_number( ''@primaryDiseaseCd'', ''99999999999999999999999999999999'' ) 
    END,
    remote_monitor_service =
CASE
    ''@remoteMonitorService'' 
    WHEN '''' THEN
    NULL ELSE to_number( ''@remoteMonitorService'', ''99999999999999999999999999999999'' ) 
    END,
    remote_monitor_user_id = NULLIF ( ''@remoteMonitorUserId'', '''' ),
    remote_monitor_user_pw = NULLIF ( ''@remoteMonitorUserPw'', '''' ) 
WHERE
    is_del = ''0'' 
    AND hosp_pat_id = ''@hospPatId'' 
    AND facility_cd = ''@facilityCd''', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル', '2022-01-07 18:21:46', '2022-01-07 18:21:46', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1105, 'UPDATE pat_personal_main 
SET
  is_del = ''1'' 
WHERE
  facility_cd = ''@facilityCd'' 
  AND pat_id = @patId
  AND hosp_pat_id = ''@hospPatId'' 
  AND is_del = ''0''
', 3, '[{}]', '0', '{"applications": [4]}', NULL, '患者プロファイル→患者個人情報(論理削除:削除フラグ=''1'')', '2022-01-07 18:21:46', '2022-01-07 18:21:46', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1205, 'UPDATE pat_main 
SET
  is_del = ''1'' 
WHERE
  facility_cd = ''@facilityCd'' 
  AND pat_id = @patId
  AND is_del = ''0''
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '患者プロファイル→患者基本情報(論理削除:削除フラグ=''1'')', '2022-01-07 18:21:46', '2022-01-07 18:21:46', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1305, 'UPDATE pat_insurance 
SET
  is_del = ''1'' 
WHERE
  facility_cd = ''@facilityCd'' 
  AND pat_id = @patId
  AND is_del = ''0''
', 3, '[{}]', '0', '{"applications": [4]}', NULL, '患者プロファイル→保険情報(論理削除:削除フラグ=''1'')', '2022-01-07 18:21:46', '2022-01-07 18:21:46', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1405, 'UPDATE pat_unique 
SET
  is_del = ''1'' 
WHERE
  facility_cd = ''@facilityCd'' 
  AND pat_id = @patId
  AND is_del = ''0''
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '患者プロファイル→患者固有情報(論理削除:削除フラグ=''1'')', '2022-01-07 18:21:46', '2022-01-07 18:21:46', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (3101, 'UPDATE pat_main 
SET
  charge_staff_info = ''[]'' 
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の初回申し込み→担当スタッフ情報', '2020-05-25 18:21:40.841', '2022-01-07 18:21:46', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (3102, 'UPDATE pat_main 
SET
  charge_staff_info = CASE ''@chargeStaffInfoFlg'' 
    WHEN '''' THEN ''@chargeStaffInfoValue'' 
    ELSE charge_staff_info || (''[{"ctl_no":'' || COALESCE(NULLIF(''@nextCtlNo2'', ''''), ''1'') || '', "disp_order":'' || COALESCE(NULLIF(''@chargeStaffInfo.dispOrder'', ''''), ''0'') || '', "staff_cd":'' || COALESCE(NULLIF(''@chargeStaffInfo.staffCd'', ''''), ''null'') || '', "is_main":"@chargeStaffInfo.isMain", "is_charge":"@chargeStaffInfo.isCharge", "is_puncture":"@chargeStaffInfo.isPuncture"}]'') ::jsonb 
    END 
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の初回申し込み→担当スタッフ情報', '2020-05-25 18:21:40.841', '2022-01-07 18:21:46', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (3103, 'WITH mstInfo AS ( 
  SELECT
    (idx - 1) AS idx
    , ms ->> ''cd'' AS cd 
    , TO_CHAR(CURRENT_TIMESTAMP, ''YYYY-MM-DD HH24:MI:SS'') AS reg_date
  FROM
    pat_main AS A 
    CROSS JOIN LATERAL jsonb_array_elements(A.addition_info ::jsonb) WITH ORDINALITY AS info(ms, idx)
  WHERE
    A.is_del = ''0'' 
    AND A.facility_cd = ''@facilityCd'' 
    AND A.pat_id = @patId 
    AND ms ->> ''cd'' :: TEXT = ''@additionInfo.cd''
) 
UPDATE pat_main 
SET addition_info = jsonb_set (
  COALESCE ( addition_info, ''[]'' ) :: JSONB,
  CAST ( ( SELECT ''{'' ||  idx || ''}'' FROM mstInfo ) AS TEXT [] ),
  CAST ( ( SELECT ''{"cd":'' || cd || '', "reg_date":"'' || reg_date || ''", "is_enable":"1"}'' FROM mstInfo ) AS JSONB ) :: JSONB 
) 
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の初回申し込み→加算情報', '2020-05-25 18:21:40.841', '2022-01-07 18:21:46', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (3104, 'WITH mstInitInfo AS ( 
  SELECT
    1 AS order_no
    , (idx - 1) AS idx
    , ms ->> ''ctl_no'' AS ctl_no 
    , ms ->> ''title'' AS title 
    , ms ->> ''content'' AS content 
  FROM
    pat_main AS A 
    CROSS JOIN LATERAL jsonb_array_elements(A.pat_memo_info ::jsonb) WITH ORDINALITY AS info(ms, idx)
  WHERE
    A.is_del = ''0'' 
    AND A.facility_cd = ''@facilityCd'' 
    AND A.pat_id = @patId 
    AND ms ->> ''title'' = ''@patMemoInfo.title'' 
  UNION 
  (SELECT
    2 AS order_no
    , (idx - 1) AS idx
    , ms ->> ''ctl_no'' AS ctl_no 
    , ms ->> ''title'' AS title 
    , ms ->> ''content'' AS content 
  FROM
    pat_main AS A 
    CROSS JOIN LATERAL jsonb_array_elements(A.pat_memo_info ::jsonb) WITH ORDINALITY AS info(ms, idx)
  WHERE
    A.is_del = ''0'' 
    AND A.facility_cd = ''@facilityCd'' 
    AND A.pat_id = @patId 
    AND (ms ->> ''title'' IS NULL OR ms ->> ''title'' = '''')
  ORDER BY (ms ->> ''ctl_no'') :: INTEGER ASC LIMIT 1)
  UNION 
  (SELECT
    3 AS order_no
    , (idx - 1) AS idx
    , ms ->> ''ctl_no'' AS ctl_no 
    , ms ->> ''title'' AS title 
    , ms ->> ''content'' AS content 
  FROM
    pat_main AS A 
    CROSS JOIN LATERAL jsonb_array_elements(A.pat_memo_info ::jsonb) WITH ORDINALITY AS info(ms, idx)
  WHERE
    A.is_del = ''0'' 
    AND A.facility_cd = ''@facilityCd'' 
    AND A.pat_id = @patId 
    AND (ms ->> ''title'' IS NOT NULL AND ms ->> ''title'' <> '''')
    AND (ms ->> ''content'' IS NULL OR ms ->> ''content'' = '''')
  ORDER BY (ms ->> ''ctl_no'') :: INTEGER ASC LIMIT 1)
  UNION 
  (SELECT
    4 AS order_no
    , (idx - 1) AS idx
    , ms ->> ''ctl_no'' AS ctl_no 
    , ms ->> ''title'' AS title 
    , ms ->> ''content'' AS content 
  FROM
    pat_main AS A 
    CROSS JOIN LATERAL jsonb_array_elements(A.pat_memo_info ::jsonb) WITH ORDINALITY AS info(ms, idx)
  WHERE
    A.is_del = ''0'' 
    AND A.facility_cd = ''@facilityCd'' 
    AND A.pat_id = @patId 
    AND (ms ->> ''title'' IS NOT NULL AND ms ->> ''title'' <> '''')
    AND (ms ->> ''content'' IS NOT NULL AND ms ->> ''content'' <> '''')
  ORDER BY (ms ->> ''ctl_no'') :: INTEGER ASC LIMIT 1)
  ORDER BY order_no ASC LIMIT 1
) 
, mstInfo AS (
  SELECT
    idx
    , ctl_no 
    , REPLACE(COALESCE(NULLIF(title, ''''), ''@patMemoInfo.title''), CHR(10), ''\n'') AS title 
    , CASE WHEN NULLIF(content, '''') IS NULL THEN 
        COALESCE(NULLIF(''@patMemoInfo.content'', ''''), '''') 
      ELSE
        REPLACE(content, CHR(10), ''\n'') || ''\n'' || COALESCE(NULLIF(''@patMemoInfo.content'', ''''), '''') 
      END AS  content
  FROM
    mstInitInfo
)
UPDATE pat_main 
SET pat_memo_info = jsonb_set (
  COALESCE ( pat_memo_info, ''[]'' ) :: JSONB,
  CAST ( ( SELECT ''{'' ||  idx || ''}'' FROM mstInfo ) AS TEXT [] ),
  CAST ( ( SELECT ''{"ctl_no":'' || ctl_no || '', "title":"'' || title || ''", "content":"'' || content || ''"}'' FROM mstInfo ) AS JSONB ) :: JSONB 
) 
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の初回申し込み→患者メモ情報', '2020-05-25 18:21:40.841', '2022-01-07 18:21:46', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (3201, 'UPDATE pat_unique 
SET
  physical_info = ''[]'' 
WHERE
  pat_id = @patId 
  AND facility_cd = ''@facilityCd'' 
  AND is_del = ''0''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の初回申し込み→身体情報', '2020-05-25 18:21:40.841', '2022-01-07 18:21:46', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (3202, 'UPDATE pat_unique 
SET
  physical_info = CASE ''@physicalInfoFlg'' 
    WHEN '''' THEN ''@physicalInfoValue'' 
    ELSE physical_info || (''[{"ctl_no":'' || COALESCE(NULLIF(''@nextCtlNo1'', ''''), ''null'') || '', "exam_date":"'' || COALESCE(NULLIF(''@physicalInfo.examDate'', ''''), TO_CHAR(CURRENT_DATE, ''YYYY-MM-DD'')) || ''", "order_class":'' || COALESCE(NULLIF(''@physicalInfo.orderClass'', ''''), ''null'') || '', "height":'' || COALESCE(NULLIF(''@physicalInfo.height'', ''''), ''null'') || '', "ctr_weight":'' || COALESCE(NULLIF(''@physicalInfo.ctrWeight'', ''''), ''null'') || '', "breast_dia":'' || COALESCE(NULLIF(''@physicalInfo.breastDia'', ''''), ''null'') || '', "chest_dia":'' || COALESCE(NULLIF(''@physicalInfo.chestDia'', ''''), ''null'') || '', "ctr":'' || COALESCE(NULLIF(''@physicalInfo.ctr'', ''''), ''null'') || '', "dw":'' || LTRIM(COALESCE(NULLIF(''@physicalInfo.dw'', ''''), ''null''), ''0'') || '', "indicator_cd":'' || COALESCE(NULLIF(''@physicalInfo.indicatorCd'', ''''), ''null'') || '', "indicator_start_date":"'' || COALESCE(NULLIF(''@physicalInfo.indicatorStartDate'', ''''), TO_CHAR(CURRENT_DATE, ''YYYYMMDD'')) || ''", "memo":"'' || COALESCE(NULLIF(''@physicalInfo.memo'', ''''), '''') || ''", "pre_scale_upper":'' || COALESCE(NULLIF(''@physicalInfo.preScaleUpper'', ''''), ''null'') || '', "pre_scale_lower":'' || COALESCE(NULLIF(''@physicalInfo.preScaleLower'', ''''), ''null'') || '', "facility_cd": "'' || COALESCE(NULLIF(''@physicalInfo.facilityCd'', ''''), '''') || ''", "target_weight": '' || COALESCE(NULLIF(''@physicalInfo.targetWeight'', ''''), ''null'') || ''}]'') ::jsonb 
    END 
WHERE
  pat_id = @patId 
  AND facility_cd = ''@facilityCd'' 
  AND is_del = ''0''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の初回申し込み→身体情報', '2020-05-25 18:21:40.841', '2022-01-07 18:21:46', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (3203, 'UPDATE pat_unique 
SET
  medical_hst_info = ''[]'' 
WHERE
  pat_id = @patId 
  AND facility_cd = ''@facilityCd'' 
  AND is_del = ''0''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の初回申し込み→既往歴情報', '2020-05-25 18:21:40.841', '2022-01-07 18:21:46', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (3204, 'UPDATE pat_unique 
SET
  medical_hst_info = CASE ''@medicalHstInfoFlg'' 
    WHEN '''' THEN ''@medicalHstInfoValue'' 
    ELSE medical_hst_info || (''[{"memo":"'' || COALESCE(NULLIF(''@medicalHstInfo.memo'', ''''), '''') || ''", "ctl_no":'' || COALESCE(NULLIF(''@nextCtlNo2'', ''''), ''null'') || '', "die_date":"'' || COALESCE(NULLIF(''@medicalHstInfo.dieDate'', ''''), '''') || ''", "out_come":"'' || COALESCE(NULLIF(''@medicalHstInfo.outCome'', ''''), '''') || ''", "course_cd":'' || COALESCE(NULLIF(''@medicalHstInfo.courseCd'', ''''), ''null'') || '', "is_notice":"'' || COALESCE(NULLIF(''@medicalHstInfo.isNotice'', ''''), '''') || ''", "disease_cd":'' || COALESCE(NULLIF(''@medicalHstInfo.diseaseCd'', ''''), ''null'') || '', "disp_order":'' || COALESCE(NULLIF(''@medicalHstInfo.dispOrder'', ''''), ''null'') || '', "disease_day":"'' || COALESCE(NULLIF(''@medicalHstInfo.diseaseDay'', ''''), '''') || ''", "facility_cd":"'' || COALESCE(NULLIF(''@medicalHstInfo.facilityCd'', ''''), '''') || ''", "disease_date":"'' || COALESCE(NULLIF(''@medicalHstInfo.diseaseDate'', ''''), '''') || ''", "disease_year":"'' || COALESCE(NULLIF(''@medicalHstInfo.diseaseYear'', ''''), '''') || ''", "is_diagnosed":"'' || COALESCE(NULLIF(''@medicalHstInfo.isDiagnosed'', ''''), '''') || ''", "diagnosis_day":"'' || COALESCE(NULLIF(''@medicalHstInfo.diagnosisDay'', ''''), '''') || ''", "disease_month":"'' || COALESCE(NULLIF(''@medicalHstInfo.diseaseMonth'', ''''), '''') || ''", "out_come_date":"'' || COALESCE(NULLIF(''@medicalHstInfo.outComeDate'', ''''), '''') || ''", "course_is_free":"'' || COALESCE(NULLIF(''@medicalHstInfo.courseIsFree'', ''''), '''') || ''", "diagnosis_date":"'' || COALESCE(NULLIF(''@medicalHstInfo.diagnosisDate'', ''''), '''') || ''", "diagnosis_year":"'' || COALESCE(NULLIF(''@medicalHstInfo.diagnosisYear'', ''''), '''') || ''", "diagnosis_month":"'' || COALESCE(NULLIF(''@medicalHstInfo.diagnosisMonth'', ''''), '''') || ''", "is_main_disease":"'' || COALESCE(NULLIF(''@medicalHstInfo.isMainDisease'', ''''), '''') || ''", "diagnostician_cd":'' || COALESCE(NULLIF(''@medicalHstInfo.diagnosticianCd'', ''''), ''null'') || '', "diagnosis_facility_cd":"'' || COALESCE(NULLIF(''@medicalHstInfo.diagnosisFacilityCd'', ''''), '''') || ''", "diagnostician_is_free":"'' || COALESCE(NULLIF(''@medicalHstInfo.diagnosticianIsFree'', ''''), '''') || ''", "is_confirmation_biopsy":"'' || COALESCE(NULLIF(''@medicalHstInfo.isConfirmationBiopsy'', ''''), '''') || ''", "diagnosis_facility_is_free":"'' || COALESCE(NULLIF(''@medicalHstInfo.diagnosisFacilityIsFree'', ''''), '''') || ''", "is_dialysis_underlying_disease":"'' || COALESCE(NULLIF(''@medicalHstInfo.isDialysisUnderlyingDisease'', ''''), '''') || ''"}]'') ::jsonb 
    END 
WHERE
  pat_id = @patId 
  AND facility_cd = ''@facilityCd'' 
  AND is_del = ''0''
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の初回申し込み→既往歴情報', '2020-05-25 18:21:40.841', '2022-01-07 18:21:46', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (3301, 'SELECT
  ord_no,
  pat_id,
  fn_pat_id,
  treat_date,
  treat_week,
  facility_cd,
  facility_name,
  ind_va_cd,
  ind_treatment_cd,
  ind_treatment_name,
  ind_kur_cd,
  ind_kur_name,
  ind_treat_start_time,
  ind_bed_cd,
  ind_bed_name,
  ind_schedule_user_info,
  ind_cond_info,
  ind_medi_info,
  ind_equip_info,
  ind_ind_comment_info,
  ind_tare_info,
  ind_off_water_info,
  ind_device_set_info,
  rst_fn_dialysis_no,
  rst_relation_dialysis_no,
  rst_edition,
  rst_is_update_edition,
  rst_input_class,
  rst_dialysis_state,
  rst_treatment_cd,
  rst_treatment_name,
  rst_kur_cd,
  rst_kur_name,
  rst_bed_cd,
  rst_bed_name,
  rst_machine_no,
  rst_machine_name,
  rst_cond_send_date,
  rst_accept_date,
  rst_start_date,
  rst_end_date,
  rst_return_home_date,
  rst_in_out_class,
  rst_dialysis_cnt,
  rst_ward_cd,
  rst_ward_name,
  rst_course_cd,
  rst_course_name,
  rst_puncture_user_info,
  rst_return_user_info,
  rst_charge_user_info,
  rst_blood_circulate_total,
  rst_running_time,
  rst_kt_v,
  rec_set_date,
  send_ctl_no,
  blood_purifier_name,
  pull_leave_amount,
  rst_cond_info,
  rst_medi_info,
  rst_equip_info,
  rst_ind_comment_info,
  rst_tare_info,
  rst_off_water_info,
  rst_device_set_info,
  rst_weight_info,
  rst_vital_info,
  rst_complaint_info,
  rst_treatment_info,
  rst_treat_staff_info,
  rst_rounds_info,
  is_del,
  up_date,
  reg_date,
  rst_dw,
  weight_scale_no,
  treat_type,
  is_confirm,
  ind_dw,
  rst_purification_cnt,
  addition_info,
  up_ind_user_id,
  up_user_id,
  rst_edition_date,
  cur_edition_date,
  fn_plural 
FROM
  ord_main 
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = @facilityCd', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の初回申し込み→治療情報(取得)', '2022-01-07 18:21:46', '2022-01-07 18:21:46', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (3302, 'WITH date_tmp AS ( 
  SELECT
    generate_series( 
      COALESCE(TO_DATE(NULLIF(''@treatDateFrom'', ''''), ''YYYY/MM/DD''), CURRENT_DATE) 
      , COALESCE(TO_DATE(NULLIF(''@treatDateTo'', ''''), ''YYYY/MM/DD''), CURRENT_DATE + 7) 
      , ''1 day''
    ) AS treat_date
) 
, date_info AS ( 
  SELECT
    TO_CHAR(treat_date, ''YYYYMMDD'') AS treat_date
    , CASE EXTRACT(DOW FROM treat_date) 
      WHEN 0 THEN 7 
      ELSE EXTRACT(DOW FROM treat_date) 
      END AS treat_week 
  FROM
    date_tmp
) 
, week_tmp AS (SELECT ''@treatWeekList'' ::TEXT AS weeks)
, week_info AS ( 
  SELECT CASE WHEN weeks LIKE ''%月曜日%'' THEN 1 ELSE - 1 END AS week FROM week_tmp 
  UNION 
  SELECT CASE WHEN weeks LIKE ''%火曜日%'' THEN 2 ELSE - 1 END AS week FROM week_tmp 
  UNION 
  SELECT CASE WHEN weeks LIKE ''%水曜日%'' THEN 3 ELSE - 1 END AS week FROM week_tmp 
  UNION 
  SELECT CASE WHEN weeks LIKE ''%木曜日%'' THEN 4 ELSE - 1 END AS week FROM week_tmp 
  UNION 
  SELECT CASE WHEN weeks LIKE ''%金曜日%'' THEN 6 ELSE - 1 END AS week FROM week_tmp 
  UNION 
  SELECT CASE WHEN weeks LIKE ''%土曜日%'' THEN 7 ELSE - 1 END AS week FROM week_tmp 
  UNION 
  SELECT CASE WHEN weeks LIKE ''%日曜日%'' THEN 7 ELSE - 1 END AS week FROM week_tmp 
) 
, kur_info AS(
  (SELECT 
    1 AS order_no
    , kur_cd AS ind_kur_cd
    , kur_name AS ind_kur_name
    , REPLACE(''@indTreatStartTime'', '':'', '''') AS ind_treat_start_time
  FROM 
   mst_kur
  WHERE 
    is_del = ''0''
    AND COALESCE(NULLIF(REPLACE(''@indTreatStartTime'', '':'', ''''), ''''), ''9999'') <> ''9999''
    AND COALESCE(NULLIF(REPLACE(''@indTreatStartTime'', '':'', ''''), ''''), ''9999'') BETWEEN kur_start_time AND kur_end_time
  ORDER BY kur_cd ASC LIMIT 1)
  UNION
  SELECT 
    2 AS order_no
    , kur_cd AS ind_kur_cd
    , kur_name AS ind_kur_name
    , kur_standard_start_time AS ind_treat_start_time
  FROM 
   mst_kur
  WHERE 
    is_del = ''0''
    AND COALESCE(NULLIF(''@indKurCd'', ''''), ''-1'') <> ''-1''
    AND kur_cd :: TEXT = COALESCE(NULLIF(''@indKurCd'', ''''), ''-1'')
  UNION
  SELECT 
    3 AS order_no
    , null AS ind_kur_cd
    , null AS ind_kur_name
    , null AS ind_treat_start_time
  ORDER BY order_no ASC LIMIT 1
)
, cond_info AS(
 SELECT (TO_NUMBER(COALESCE(NULLIF(split_part(''@indCondInfo1value'', '':'', 1), ''''), ''0''), ''FM000'') * 60) + TO_NUMBER(COALESCE(NULLIF(split_part(''@indCondInfo1value'', '':'', 2), ''''), ''0''), ''FM000'') AS item1_value
) 
INSERT INTO ord_main( 
  pat_id
  , fn_pat_id
  , treat_date
  , treat_week
  , facility_cd
  , facility_name
  , ind_va_cd
  , ind_treatment_cd
  , ind_treatment_name
  , ind_kur_cd
  , ind_kur_name
  , ind_treat_start_time
  , ind_bed_cd
  , ind_bed_name
  , ind_schedule_user_info
  , ind_cond_info
  , ind_medi_info
  , ind_equip_info
  , ind_ind_comment_info
  , ind_tare_info
  , ind_off_water_info
  , ind_device_set_info
  , rst_fn_dialysis_no
  , rst_relation_dialysis_no
  , rst_edition
  , rst_is_update_edition
  , rst_input_class
  , rst_dialysis_state
  , rst_treatment_cd
  , rst_treatment_name
  , rst_kur_cd
  , rst_kur_name
  , rst_bed_cd
  , rst_bed_name
  , rst_machine_no
  , rst_machine_name
  , rst_cond_send_date
  , rst_accept_date
  , rst_start_date
  , rst_end_date
  , rst_return_home_date
  , rst_in_out_class
  , rst_dialysis_cnt
  , rst_ward_cd
  , rst_ward_name
  , rst_course_cd
  , rst_course_name
  , rst_puncture_user_info
  , rst_return_user_info
  , rst_charge_user_info
  , rst_blood_circulate_total
  , rst_running_time
  , rst_kt_v
  , rec_set_date
  , send_ctl_no
  , blood_purifier_name
  , pull_leave_amount
  , rst_cond_info
  , rst_medi_info
  , rst_equip_info
  , rst_ind_comment_info
  , rst_tare_info
  , rst_off_water_info
  , rst_device_set_info
  , rst_weight_info
  , rst_vital_info
  , rst_complaint_info
  , rst_treatment_info
  , rst_treat_staff_info
  , rst_rounds_info
  , is_del
  , up_date
  , reg_date
  , rst_dw
  , weight_scale_no
  , treat_type
  , is_confirm
  , ind_dw
  , rst_purification_cnt
  , addition_info
  , up_ind_user_id
  , up_user_id
  , rst_edition_date
  , cur_edition_date
  , fn_plural
) 
SELECT
  @patId
  , NULLIF(''@fnPatId'', '''')
  , date_info.treat_date 
  , date_info.treat_week
  , ''@facilityCd''
  , NULLIF(''@facilityName'', '''')
  , CASE ''@indVaCd'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@indVaCd'', ''999999999'') 
    END
  , CASE ''@indTreatmentCd'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@indTreatmentCd'', ''999999999'') 
    END
  , NULLIF(''@indTreatmentName'', '''')
  , (SELECT ind_kur_cd FROM kur_info)
  , (SELECT ind_kur_name FROM kur_info)
  , (SELECT ind_treat_start_time FROM kur_info)
  , CASE ''@indBedCd'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@indBedCd'', ''999999999999999999'') 
    END
  , NULLIF(''@indBedName'', '''')
  , CASE ''@indScheduleUserInfoFlg'' 
    WHEN '''' THEN json_build_object( 
      ''ind_user_id''
      , NULL
      , ''ind_user_last_name''
      , NULL
      , ''ind_user_first_name''
      , NULL
      , ''upd_user_id''
      , NULL
      , ''upd_user_last_name''
      , NULL
      , ''upd_user_first_name''
      , NULL
    ) 
    ELSE json_build_object( 
      ''ind_user_id''
      , CASE ''@indScheduleUserInfo.indUserId'' 
        WHEN '''' THEN NULL 
        ELSE TO_NUMBER(''@indScheduleUserInfo.indUserId'', ''999999999'') 
        END
      , ''ind_user_last_name''
      , NULLIF( 
        split_part( ''@indScheduleUserInfo.indUserLastName '', ''　'', 1 )
        , ''''
      ) 
      , ''ind_user_first_name''
      , NULLIF( 
        split_part( ''@indScheduleUserInfo.indUserFirstName '', ''　'', 2)
        , ''''
      ) 
      , ''upd_user_id''
      , CASE ''@indScheduleUserInfo.updUserId'' 
        WHEN '''' THEN NULL 
        ELSE TO_NUMBER(''@indScheduleUserInfo.updUserId'', ''999999999'') 
        END
      , ''upd_user_last_name''
      , NULLIF( 
        split_part( ''@indScheduleUserInfo.updUserLastName '', ''　'', 1 )
        , ''''
      ) 
      , ''upd_user_first_name''
      , NULLIF( 
        split_part( ''@indScheduleUserInfo.updUserFirstName '', ''　'', 2)
        , ''''
      )
    ) 
    END
  , (''{"1": {"unit": null, "value":''|| (SELECT item1_value FROM cond_Info) || '', "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "2": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "3": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "4": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "5": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "6": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "7": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "8": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "9": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "10": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "11": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "12": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "13": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "14": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "15": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "16": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "17": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "18": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "19": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "20": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "21": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "22": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "23": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "24": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "25": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "26": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "27": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "28": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "29": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "30": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "31": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "32": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "33": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "34": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "35": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "36": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "37": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "38": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}}'') :: jsonb
  , ''@indMediInfoValue''
  , CASE ''@indEquipInfo.cd'' 
    WHEN '''' THEN ''@indEquipInfoValue'' 
    ELSE ''[{"cd":"@indEquipInfo.cd", "name":"@indEquipInfo.name","unit":null,"amount":null,"class_cd":null,"class_name":null,"class_type":null,"equip_type":null,"short_name":null,"ind_user_id":null,"input_class":null,"is_editable":null,"needle_type":null,"upd_user_id":null,"cop_order_no":null,"ind_user_last_name":null,"upd_user_last_name":null,"ind_user_first_name":null,"upd_user_first_name":null}]''::jsonb 
    END
  , ''@indIndCommentInfoValue''
  , CASE ''@indTareInfoFlg'' 
    WHEN '''' THEN json_build_object( 
      ''name_1''
      , NULL
      , ''name_2''
      , NULL
      , ''name_3''
      , NULL
      , ''name_4''
      , NULL
      , ''name_5''
      , NULL
      , ''weight_1''
      , NULL
      , ''weight_2''
      , NULL
      , ''weight_3''
      , NULL
      , ''weight_4''
      , NULL
      , ''weight_5''
      , NULL
    ) 
    ELSE json_build_object( 
      ''name_1''
      , NULLIF(''@indTareInfo.name1'', '''')
      , ''name_2''
      , NULLIF(''@indTareInfo.name2'', '''')
      , ''name_3''
      , NULLIF(''@indTareInfo.name3'', '''')
      , ''name_4''
      , NULLIF(''@indTareInfo.name4'', '''')
      , ''name_5''
      , NULLIF(''@indTareInfo.name5'', '''')
      , ''weight_1''
      , CASE ''@indTareInfo.weight1'' 
        WHEN '''' THEN 0 
        ELSE TO_NUMBER(''@indTareInfo.weight1'', ''999999999'') 
        END
      , ''weight_2''
      , CASE ''@indTareInfo.weight2'' 
        WHEN '''' THEN 0 
        ELSE TO_NUMBER(''@indTareInfo.weight2'', ''999999999'') 
        END
      , ''weight_3''
      , CASE ''@indTareInfo.weight2'' 
        WHEN '''' THEN 0 
        ELSE TO_NUMBER(''@indTareInfo.weight2'', ''999999999'') 
        END
      , ''weight_4''
      , CASE ''@indTareInfo.weight4'' 
        WHEN '''' THEN 0 
        ELSE TO_NUMBER(''@indTareInfo.weight4'', ''999999999'') 
        END
      , ''weight_5''
      , CASE ''@indTareInfo.weight5'' 
        WHEN '''' THEN 0 
        ELSE TO_NUMBER(''@indTareInfo.weight5'', ''999999999'') 
        END
    ) 
    END
  , CASE ''@indOffWaterInfoFlg'' 
    WHEN '''' THEN json_build_object( 
      ''name_1''
      , NULL
      , ''name_2''
      , NULL
      , ''name_3''
      , NULL
      , ''name_4''
      , NULL
      , ''name_5''
      , NULL
      , ''weight_1''
      , NULL
      , ''weight_2''
      , NULL
      , ''weight_3''
      , NULL
      , ''weight_4''
      , NULL
      , ''weight_5''
      , NULL
    ) 
    ELSE json_build_object( 
      ''name_1''
      , NULLIF(''@indOffWaterInfo.name1'', '''')
      , ''name_2''
      , NULLIF(''@indOffWaterInfo.name2'', '''')
      , ''name_3''
      , NULLIF(''@indOffWaterInfo.name3'', '''')
      , ''name_4''
      , NULLIF(''@indOffWaterInfo.name4'', '''')
      , ''name_5''
      , NULLIF(''@indOffWaterInfo.name5'', '''')
      , ''weight_1''
      , CASE ''@indOffWaterInfo.weight1'' 
        WHEN '''' THEN 0 
        ELSE TO_NUMBER(''@indOffWaterInfo.weight1'', ''999999999'') 
        END
      , ''weight_2''
      , CASE ''@indOffWaterInfo.weight2'' 
        WHEN '''' THEN 0 
        ELSE TO_NUMBER(''@indOffWaterInfo.weight2'', ''999999999'') 
        END
      , ''weight_3''
      , CASE ''@indOffWaterInfo.weight2'' 
        WHEN '''' THEN 0 
        ELSE TO_NUMBER(''@indOffWaterInfo.weight2'', ''999999999'') 
        END
      , ''weight_4''
      , CASE ''@indOffWaterInfo.weight4'' 
        WHEN '''' THEN 0 
        ELSE TO_NUMBER(''@indOffWaterInfo.weight4'', ''999999999'') 
        END
      , ''weight_5''
      , CASE ''@indOffWaterInfo.weight5'' 
        WHEN '''' THEN 0 
        ELSE TO_NUMBER(''@indOffWaterInfo.weight5'', ''999999999'') 
        END
    ) 
    END
  , ''{"bp": {"dev": {"A": {"190": 27, "191": "1", "192": 134, "193": "0", "194": "1", "195": "2", "211": 111, "212": 82, "213": 80, "214": 46, "215": 70, "216": 64, "217": 60, "218": 48, "219": "1", "220": "1", "221": "1", "222": "1", "223": "1", "224": "1", "225": "1", "226": "1", "227": 104, "228": 104, "229": 0.15, "230": 0.06, "231": 12, "232": 5, "233": 5.93, "234": 0.08, "235": 10, "236": 19, "237": "1", "238": "1", "239": "0"}}}, "bv": {"dev": {"A": {"258": "0", "259": 3, "260": -18.8, "261": -39.5, "262": -9.6, "263": 63, "264": 66, "265": 68, "266": 81, "267": "0", "277": 0.05, "278": 7, "281": 23}}}, "iap": {"dev": {"A": {"468": 78, "469": 0.5, "470": "2", "471": "1"}}}, "ope": {"dev": {"A": {"21": "1", "22": "1", "24": 200, "25": 100, "38": "1", "39": 4, "90": 52, "91": 33, "92": 6.5, "168": 51, "169": -51, "171": 52, "172": -52, "174": 53, "175": -53, "177": 54, "178": -54, "179": 300, "181": 2.03, "182": 40, "183": 33, "185": 5.98, "186": 5.97, "241": "1", "268": "2", "269": 2, "336": 107, "337": 106, "369": "2", "379": 22, "383": 99.9, "384": "1", "385": 13, "386": 2.5, "387": 1, "389": "0", "391": 56, "392": -56, "394": 57, "395": -57, "396": 11.97, "397": 11.96, "398": 2, "472": 3, "473": 2, "474": 8, "475": 3, "476": "1", "477": 129}, "B": {"30": 11.98, "31": 5.99, "32": 5.96, "33": 5.95, "34": 5.93, "35": 5.92, "37": 55, "38": -55, "39": 20, "40": 42}, "C": {"91": "-", "92": "-"}}}, "pri": {"dev": {"A": {"370": 194, "371": 93, "372": "1"}}, "pat": {"A": {"219": 203, "220": 97, "221": 200, "222": 97, "223": 398, "224": 296, "225": "1", "226": "1", "227": "1", "228": 796, "229": 2.3, "230": 1.4, "231": 416, "232": 44, "233": 254, "234": 254, "235": 245, "236": 394, "237": 294, "238": 604}, "B": {"32": 90, "33": 3, "51": 2, "52": 60, "53": 8}}}, "war": {"dev": {"A": {"100": 51, "101": -31, "102": 301, "103": 10, "104": 296, "105": -50, "106": 71, "107": -70, "108": 375, "109": -182, "110": 379, "111": -50, "112": 53, "113": -53, "114": 303, "115": -302, "116": 297, "117": -297, "118": 74, "119": -73, "120": 90, "121": -72, "122": 303, "123": -292, "124": 289, "125": -306, "126": 20, "127": -20, "128": 54, "129": -54, "130": 494, "131": -28, "132": 494, "133": -28, "134": 48, "135": -50, "136": 77, "137": -72, "138": 55, "139": -45, "140": 86, "141": -67, "142": 474, "143": -25, "144": 493, "145": -35, "146": 25, "147": -24, "148": 78, "149": 2, "150": 59, "151": -52, "152": 52, "153": -52, "154": 302, "155": 0, "156": 298, "157": -49, "158": 73, "159": -71, "160": 479, "161": -184, "162": 497, "163": -53, "240": "0", "242": "0", "243": "0", "244": "0", "245": "0", "246": "0", "247": "0", "254": 5, "255": -5, "256": 173, "257": 134}}}, "cpro": {"dev": {"A": {"250": 5.6, "251": -4.6, "252": 6.1, "253": -4.7}}}, "dfas": {"dev": {"A": {"270": "0", "331": 146, "332": -203, "333": 103, "334": 155, "338": 46, "339": "1", "373": 104, "374": 255, "376": 34, "377": "1", "378": "1"}, "B": {"36": "0"}}, "pat": {"B": {"1": "0", "5": 293, "7": 29, "8": 214, "9": 0, "10": 150, "54": 57, "55": 200, "56": 0, "57": 142, "58": 0.2, "59": 154}}}, "ecum": {"dev": {"A": {"16": "1", "17": 0.03, "18": 31, "19": "0"}}}}''
  , NULL
  , NULL
  , 0
  , NULL
  , NULL
  , ''0''
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , ''0''
  , CURRENT_TIMESTAMP
  , CURRENT_TIMESTAMP
  , NULL
  , NULL
  , 1
  , 0
  , NULL
  , NULL
  , NULL
  , NULL
  , CASE ''@upUserId'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@upUserId'', ''999999999999999999'') 
    END
  , NULL
  , NULL
  , NULL
FROM
  date_info
  , week_info 
WHERE
  date_info.treat_week = week_info.week 
ORDER BY
  treat_date ASC', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の初回申し込み→治療情報(作成)', '2022-01-07 18:21:46', '2022-01-07 18:21:46', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (3303, 'INSERT 
INTO ord_main_restore( 
  del_date
  , ord_no
  , pat_id
  , fn_pat_id
  , treat_date
  , treat_week
  , facility_cd
  , facility_name
  , ind_va_cd
  , ind_treatment_cd
  , ind_treatment_name
  , ind_kur_cd
  , ind_kur_name
  , ind_treat_start_time
  , ind_bed_cd
  , ind_bed_name
  , ind_schedule_user_info
  , ind_cond_info
  , ind_medi_info
  , ind_equip_info
  , ind_ind_comment_info
  , ind_tare_info
  , ind_off_water_info
  , ind_device_set_info
  , rst_fn_dialysis_no
  , rst_relation_dialysis_no
  , rst_edition
  , rst_is_update_edition
  , rst_input_class
  , rst_dialysis_state
  , rst_treatment_cd
  , rst_treatment_name
  , rst_kur_cd
  , rst_kur_name
  , rst_bed_cd
  , rst_bed_name
  , rst_machine_no
  , rst_machine_name
  , rst_cond_send_date
  , rst_accept_date
  , rst_start_date
  , rst_end_date
  , rst_return_home_date
  , rst_in_out_class
  , rst_dialysis_cnt
  , rst_ward_cd
  , rst_ward_name
  , rst_course_cd
  , rst_course_name
  , rst_puncture_user_info
  , rst_return_user_info
  , rst_charge_user_info
  , rst_blood_circulate_total
  , rst_running_time
  , rst_kt_v
  , rec_set_date
  , send_ctl_no
  , blood_purifier_name
  , pull_leave_amount
  , rst_cond_info
  , rst_medi_info
  , rst_equip_info
  , rst_ind_comment_info
  , rst_tare_info
  , rst_off_water_info
  , rst_device_set_info
  , rst_weight_info
  , rst_vital_info
  , rst_complaint_info
  , rst_treatment_info
  , rst_treat_staff_info
  , rst_rounds_info
  , is_del
  , up_date
  , reg_date
  , rst_dw
  , weight_scale_no
  , treat_type
  , is_confirm
  , ind_dw
  , rst_purification_cnt
  , addition_info
  , up_ind_user_id
  , up_user_id
  , rst_edition_date
  , cur_edition_date
  , fn_plural
) 
SELECT
  CURRENT_TIMESTAMP AS del_date
  , ord_no
  , pat_id
  , fn_pat_id
  , treat_date
  , treat_week
  , facility_cd
  , facility_name
  , ind_va_cd
  , ind_treatment_cd
  , ind_treatment_name
  , ind_kur_cd
  , ind_kur_name
  , ind_treat_start_time
  , ind_bed_cd
  , ind_bed_name
  , ind_schedule_user_info
  , ind_cond_info
  , ind_medi_info
  , ind_equip_info
  , ind_ind_comment_info
  , ind_tare_info
  , ind_off_water_info
  , ind_device_set_info
  , rst_fn_dialysis_no
  , rst_relation_dialysis_no
  , rst_edition
  , rst_is_update_edition
  , rst_input_class
  , rst_dialysis_state
  , rst_treatment_cd
  , rst_treatment_name
  , rst_kur_cd
  , rst_kur_name
  , rst_bed_cd
  , rst_bed_name
  , rst_machine_no
  , rst_machine_name
  , rst_cond_send_date
  , rst_accept_date
  , rst_start_date
  , rst_end_date
  , rst_return_home_date
  , rst_in_out_class
  , rst_dialysis_cnt
  , rst_ward_cd
  , rst_ward_name
  , rst_course_cd
  , rst_course_name
  , rst_puncture_user_info
  , rst_return_user_info
  , rst_charge_user_info
  , rst_blood_circulate_total
  , rst_running_time
  , rst_kt_v
  , rec_set_date
  , send_ctl_no
  , blood_purifier_name
  , pull_leave_amount
  , rst_cond_info
  , rst_medi_info
  , rst_equip_info
  , rst_ind_comment_info
  , rst_tare_info
  , rst_off_water_info
  , rst_device_set_info
  , rst_weight_info
  , rst_vital_info
  , rst_complaint_info
  , rst_treatment_info
  , rst_treat_staff_info
  , rst_rounds_info
  , is_del
  , up_date
  , reg_date
  , rst_dw
  , weight_scale_no
  , treat_type
  , is_confirm
  , ind_dw
  , rst_purification_cnt
  , addition_info
  , up_ind_user_id
  , up_user_id
  , rst_edition_date
  , cur_edition_date
  , fn_plural 
FROM
  ord_main 
WHERE
  is_del = ''0'' 
  AND rst_edition = 0
  AND rst_treatment_cd is null
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd'' ', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の初回申し込み→治療情報(バックアップ)', '2022-01-07 18:21:46', '2022-01-07 18:21:46', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (3304, 'DELETE 
FROM
  ord_main 
WHERE
  is_del = ''0'' 
  AND rst_edition = 0
  AND rst_treatment_cd is null
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd'' ', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の初回申し込み→治療情報(削除)', '2022-01-07 18:21:46', '2022-01-07 18:21:46', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (3401, 'SELECT
  pat_id
  , facility_cd
  , ctl_no
  , fn_pat_id
  , insu_class
  , insu_name
  , insu_name_short
  , start_date
  , end_date
  , check_date
  , insu_info
  , insu_pub_info
  , insu_set_info
  , insu_self_info
  , is_selected
  , is_disp
  , is_del
  , coop_code
  , is_coop
  , reg_date
  , up_date
  , check_date
  , old_up_date 
FROM
  pat_insurance 
WHERE
  pat_id = @patId 
  AND facility_cd = @facilityCd 
  AND is_del = ''0'' 
  AND ctl_no is null
  AND ctl_no = -1', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の初回申し込み→保険情報(取得)', '2022-01-07 18:21:46', '2022-01-07 18:21:46', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (3402, 'WITH insu_info AS (
  SELECT
    insu_name
    , insu_name_short
    , futan_g
    , futan_n
    , insu_class 
  FROM
    json_to_record(''@insuInfo'') AS insu_info(insu_name TEXT, insu_name_short TEXT, futan_g INT, futan_n INT, insu_class INT)
)
INSERT 
INTO pat_insurance( 
  pat_id
  , facility_cd
  , ctl_no
  , fn_pat_id
  , insu_class
  , insu_name
  , insu_name_short
  , insu_info
  , insu_pub_info
  , insu_set_info
  , insu_self_info
  , is_selected
  , is_disp
  , is_del
  , coop_code
  , is_coop
  , reg_date
  , up_date
  , start_date
  , end_date
  , check_date
  , old_up_date
) 
SELECT
  @patId
  , ''@facilityCd''
  , TO_NUMBER(COALESCE(NULLIF((SELECT TO_CHAR(MAX(ctl_no) + 1, ''FM999999'') AS ctl_no FROM pat_insurance WHERE pat_id = @patId AND facility_cd = ''@facilityCd'' AND is_del = ''0''), ''''), ''0''), ''FM99999'')
  , NULLIF(''@fnPatId'', '''')
  , insu_class
  , insu_name
  , insu_name_short
  , json_build_object( 
      ''insu_pat_name''
      , personal_info_encrypt(insu_name)
      , ''insu_no''
      , personal_info_encrypt(NULLIF(''@insuInfo.insuNo'', ''''))
      , ''insu_kbn''
      , NULLIF(''@insuInfo.insuKbn'', '''')
      , ''insu_pat_mark''
      , personal_info_encrypt(NULLIF(''@insuInfo.insuPatMark'', ''''))
      , ''insu_pat_no''
      , personal_info_encrypt(NULLIF(''@insuInfo.insuPatNo'', ''''))
      , ''cki_class''
      , NULLIF(''@insuInfo.ckiClass'', '''')
      , ''kki_class''
      , NULLIF(''@insuInfo.kkiClass'', '''')
      , ''und_six''
      , NULLIF(''@insuInfo.undSix'', '''')
      , ''futan-g''
      , futan_g
      , ''futan-n''
      , futan_n
    ) 
  , CASE ''@insuPubInfoFlg'' 
    WHEN '''' THEN json_build_object( 
      ''insu_pub_name''
      , personal_info_encrypt(NULL)
      , ''insu_pub_no''
      , personal_info_encrypt(NULL)
      , ''insu_pub_pat_no''
      , personal_info_encrypt(NULL)
      , ''passbook_no''
      , personal_info_encrypt(NULL)
    ) 
    ELSE json_build_object( 
      ''insu_pub_name''
      , personal_info_encrypt(NULLIF(''@insuPubInfo.insuPubName'', ''''))
      , ''insu_pub_no''
      , personal_info_encrypt(NULLIF(''@insuPubInfo.insuPubNo'', ''''))
      , ''insu_pub_pat_no''
      , personal_info_encrypt(NULLIF(''@insuPubInfo.insuPubPatNo'', ''''))
      , ''passbook_no''
      , personal_info_encrypt(NULLIF(''@insuPubInfo.passbookNo'', ''''))
    ) 
    END
  , CASE ''@insuSetInfoFlg'' 
    WHEN '''' THEN json_build_object( 
      ''insu_cd''
      , NULL
      , ''insu_pub1_cd''
      , NULL
      , ''insu_pub2_cd''
      , NULL
      , ''insu_pub3_cd''
      , NULL
      , ''insu_pub4_cd''
      , NULL
    ) 
    ELSE json_build_object( 
      ''insu_cd''
      , NULLIF(''@insuSetInfo.insuCd'', '''')
      , ''insu_pub1_cd''
      , NULLIF(''@insuSetInfo.insuPub1Cd'', '''')
      , ''insu_pub2_cd''
      , NULLIF(''@insuSetInfo.insuPub2Cd'', '''')
      , ''insu_pub3_cd''
      , NULLIF(''@insuSetInfo.insuPub3Cd'', '''')
      , ''insu_pub4_cd''
      , NULLIF(''@insuSetInfo.insuPub4Cd'', '''')
    ) 
    END
  , json_build_object(''insu_self_name'', (null)::text)
  , NULLIF(''@isSelected'', '''')
  , NULLIF(''@isDisp'', '''')
  , ''0''
  , NULLIF(''@coopCode'', '''')
  , NULLIF(''@isCoop'', '''')
  , CURRENT_TIMESTAMP
  , CURRENT_TIMESTAMP
  , NULLIF(''@startDate'', '''')
  , NULLIF(''@endDate'', '''')
  , NULLIF(''@checkDate'', '''')
  , CASE ''@oldUpDate_Date'' 
    WHEN '''' THEN NULL 
    ELSE to_timestamp(''@oldUpDate_Date'', ''yyyy-MM-dd hh24:mi:ss'') 
    END
FROM
  insu_info', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の初回申し込み→保険情報(登録)', '2022-01-07 18:21:46', '2022-01-07 18:21:46', '[{"sql_cd": 1005, "field_name": "insu_info", "replace_var": "@insuInfo"}]');

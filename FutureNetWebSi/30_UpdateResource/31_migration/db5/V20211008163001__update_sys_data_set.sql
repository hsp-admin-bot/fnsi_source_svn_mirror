delete from "sys_data_set" where "sql_cd" in (-442,-436,1102,1103);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-442, ' WITH staff_info AS (
   SELECT ROW_NUMBER( ) OVER ( ORDER BY info ->> ''is_main'' DESC,  info ->> ''is_charge'' DESC,  info ->> ''is_puncture'' DESC, info ->> ''ctl_no'' ASC ) AS CNT,
     info ->> ''staff_cd'' AS staff_cd 
   FROM
     pat_main AS pat
     LEFT JOIN LATERAL json_array_elements ( pat.charge_staff_info :: json ) info ON info ->> ''ctl_no'' IS NOT NULL 
   WHERE
     pat.pat_id = @patId 
   )
 SELECT
   M1.reg_order_class,
   TO_CHAR( M1.reg_exam_date, ''YYYYMMDD'' ) AS reg_exam_date,
   M1.ind_user_id,
   M1.reg_staff,
   M1.up_staff,
   TO_CHAR( M1.up_date, ''YYYY-MM-DD HH24:MI'' ) AS up_date,
   -- 診療科マスタ
   pat.medical_care_info ->> ''main_course_cd'' AS course_cd,
   course.course_name AS course_name,
   COALESCE ( TRIM ( course.in_hospital_cd_1 ), CAST ( course.course_cd AS VARCHAR ) ) AS course_cd1,
   -- 透析前/透析後開始時刻
   '''' AS standard_start_time,
   -- 透析後予定透析時間
   '''' AS ind_dialysis_time,
   -- その他開始時刻
   '''' AS other_exam_time,
   -- 血液検査セットコード
   info ->> ''set_cd'' AS exam_set_cd,
   -- 医師1
   staff1.staff_cd AS staff_cd1,
   -- 医師2
    staff2.staff_cd AS staff_cd2 
 FROM
   pat_exam_main AS M1
   LEFT JOIN LATERAL json_array_elements ( M1.order_exam_set_info :: json ) info ON info ->> ''set_name'' LIKE''%血液%''
   INNER JOIN pat_main AS pat ON pat.pat_id = M1.pat_id
   LEFT JOIN staff_info AS staff1 ON staff1.CNT = 1
   LEFT JOIN staff_info AS staff2 ON staff2.CNT = 2
   LEFT JOIN mst_course AS course ON course.course_cd :: TEXT = pat.medical_care_info ->> ''main_course_cd'' 
 WHERE
   M1.is_del = ''0'' 
   AND M1.exam_status = ''0'' 
   AND M1.exam_main_cd = @ordNo
   LIMIT 1', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'CSI検査オーダ(連携電文の検査スケジュール)', '2020-07-31 18:29:49', '2020-07-31 18:29:49', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-436, ' WITH staff_info AS (
   SELECT ROW_NUMBER( ) OVER ( ORDER BY info ->> ''is_main'' DESC,  info ->> ''is_charge'' DESC,  info ->> ''is_puncture'' DESC, info ->> ''ctl_no'' ASC ) AS CNT,
     info ->> ''staff_cd'' AS staff_cd 
   FROM
     pat_main AS pat
     LEFT JOIN LATERAL json_array_elements ( pat.charge_staff_info :: json ) info ON info ->> ''ctl_no'' IS NOT NULL 
   WHERE
     pat.pat_id = @patId 
   )
 SELECT
    ord.treat_date AS treat_date,
    ord.ind_treat_start_time AS start_time,
    -- クールマスタ
    ord.ind_kur_cd AS kur_cd,
    mkr.kur_name AS kur_name,
    COALESCE(TRIM(mkr.in_hospital_cd_1), cast(mkr.kur_cd as VARCHAR)) AS kur_cd1,
    LEFT ( mkr.kur_standard_start_time, 4 ) AS kur_standard_start_time,
    -- ベッドマスタ
    ord.ind_bed_cd AS bed_cd,
    mbd.bed_name AS bed_name,
    COALESCE(TRIM(mbd.in_hospital_cd_1), cast(mbd.bed_cd as VARCHAR)) AS bed_cd1,
    -- 診療科マスタ
    pat.medical_care_info ->> ''main_course_cd'' AS course_cd,
    course.course_name AS course_name,
    COALESCE(TRIM(course.in_hospital_cd_1), cast(course.course_cd as VARCHAR)) AS course_cd1,
    -- 医師1
    staff1.staff_cd AS staff_cd1,
    -- 医師2
    staff2.staff_cd AS staff_cd2 
 FROM
    pat_main AS pat
    LEFT JOIN ord_main AS ord ON pat.pat_id = ord.pat_id AND ord.ord_no = @ordNo
    LEFT JOIN staff_info AS staff1 ON staff1.CNT = 1
    LEFT JOIN staff_info AS staff2 ON staff2.CNT = 2
    LEFT JOIN mst_kur AS mkr ON mkr.kur_cd = ord.ind_kur_cd 
    LEFT JOIN mst_bed AS mbd ON mbd.bed_cd = ord.ind_bed_cd
    LEFT JOIN mst_course AS course ON course.course_cd ::TEXT = pat.medical_care_info ->> ''main_course_cd''
  WHERE
    pat.pat_id = @patId ', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'CSI透析予約(連携電文の透析スケジュール)', '2020-07-31 18:29:49', '2020-07-31 18:29:49', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1102, 'insert into pat_personal_main (
  fn_pat_id,
  hosp_pat_id,
  nkk_pat_id,
  facility_cd,
  pat_last_name,
  pat_first_name,
  pat_last_name_kana,
  pat_first_name_kana,
  pat_last_name_alpha,
  pat_first_name_alpha,
  pat_birth_name,
  pat_birth_name_kana,
  pat_birth_name_alpha,
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
  pat_contact_info,
  other_contact_info,
  vendor_contact_info,
  insurance_info,
  is_del,
  up_date,
  reg_date,
  primary_disease_cd,
  remote_monitor_service,
  remote_monitor_user_id,
  remote_monitor_user_pw
) values (
  NULLIF(''@fnPatId'',''''),
  NULLIF(''@hospPatId'',''''),
  NULLIF(''@nkkPatId'',''''),
  NULLIF(''@facilityCd'',''''),
  personal_info_encrypt(split_part( ''@patLastName'', ''　'', 1 )),
  personal_info_encrypt(split_part( ''@patFirstName'', ''　'', 2 )),
  personal_info_encrypt(split_part( ''@patLastNmKana'', ''　'', 1 )),
  personal_info_encrypt(split_part( ''@patFirstNmKana'', ''　'', 2 )),
  NULLIF(''@patLastNmAlpha'',''''),
  NULLIF(''@patFirstNmAlpha'',''''),
  NULLIF(''@patBirthName'',''''),
  NULLIF(''@patBirthNmKana'',''''),
  NULLIF(''@patBirthNmAlpha'',''''),
  NULLIF(''@patBirthday'',''''),
  case ''@patSex''
    when '''' then null
    else to_number(''@patSex'',''9999999999999999'')
  end,
  NULLIF(''@nationality'',''''),
  case ''@patBloodTypeAbo''
    when '''' then null
    else to_number(''@patBloodTypeAbo'',''9999999999999999'')
  end,
  case ''@patBloodTypeRh''
    when '''' then null
    else to_number(''@patBloodTypeRh'',''9999999999999999'')
  end,
  case ''@patBloodTypeSerovar''
    when '''' then null
    else to_number(''@patBloodTypeSerovar'',''9999999999999999'')
  end,
  case ''@inOutClass''
    when '''' then null
    else to_number(''@inOutClass'',''9999999999999999'')
  end,
  NULLIF(''@isDie'',''''),
  case ''@dieCd''
    when '''' then null
    else to_number(''@dieCd'',''99999999999999999999999999999999'')
  end,
  case ''@dieDate_Date''
    when '''' then null
    else to_timestamp(''@dieDate_Date'',''yyyy-MM-dd hh24:mi:ss'')
  end,
  ''@dialDiffComInfoValue'',
  case ''@severityCd''
    when '''' then null
    else to_number(''@severityCd'',''99999999999999999999999999999999'')
  end,
  case ''@transportCd''
    when '''' then null
    else to_number(''@transportCd'',''99999999999999999999999999999999'')
  end,
  case ''@patContactInfoFlg''
    when '''' then json_build_object(''zip_cd'',null,''address'',null,''tel'',null,''fax'',null,''e_mail'',null,''work_name'',null,''work_address'',null,''work_tel'',null,''memo1'',null,''memo2'',null)
    else json_build_object(''zip_cd'',NULLIF(''@patContactInfo.zipCd'',''''),''address'',NULLIF(''@patContactInfo.address'',''''),''tel'',NULLIF(''@patContactInfo.tel'',''''),''fax'',NULLIF(''@patContactInfo.fax'',''''),''e_mail'',NULLIF(''@patContactInfo.eMail'',''''),''work_name'',NULLIF(''@patContactInfo.workName'',''''),''work_address'',NULLIF(''@patContactInfo.workAddress'',''''),''work_tel'',NULLIF(''@patContactInfo.workTel'',''''),''memo1'',NULLIF(''@patContactInfo.memo1'',''''),''memo2'',NULLIF(''@patContactInfo.memo2'',''''))
  end,
  ''@otherContactInfoValue'',
  ''@vendorContactInfoValue'',
  ''@insuranceInfoValue'',
  ''0'',
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP,
  case ''@primaryDiseaseCd''
    when '''' then null
    else to_number(''@primaryDiseaseCd'',''99999999999999999999999999999999'')
  end,
  case ''@remoteMonitorService''
    when '''' then null
    else to_number(''@remoteMonitorService'',''99999999999999999999999999999999'')
  end,
  NULLIF(''@remoteMonitorUserId'',''''),
  NULLIF(''@remoteMonitorUserPw'','''')
)', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1103, 'UPDATE pat_personal_main 
SET fn_pat_id = NULLIF ( ''@fnPatId'', '''' ),
hosp_pat_id = NULLIF ( ''@hospPatId'', '''' ),
nkk_pat_id = NULLIF ( ''@nkkPatId'', '''' ),
facility_cd = NULLIF ( ''@facilityCd'', '''' ),
pat_last_name = personal_info_encrypt ( split_part( ''@patLastName'', ''　'', 1 ) ),
pat_first_name = personal_info_encrypt ( split_part( ''@patFirstName'', ''　'', 2 ) ),
pat_last_name_kana = personal_info_encrypt ( split_part( ''@patLastNmKana'', ''　'', 1 ) ),
pat_first_name_kana = personal_info_encrypt ( split_part( ''@patFirstNmKana'', ''　'', 2 ) ),
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
        NULLIF ( ''@patContactInfo.address'', '''' ),
        ''tel1'',
        NULLIF ( ''@patContactInfo.tel'', '''' ),
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
    AND facility_cd = ''@facilityCd''', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);

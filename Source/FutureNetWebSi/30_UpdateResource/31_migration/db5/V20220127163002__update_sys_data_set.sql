delete from "sys_data_set" where "sql_cd" in (1006,1401,1402,1403,1703,1705,1706,1707);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1006, 'SELECT
  1 AS order_no
  , CASE TRIM(ini_info ->> ''value'') 
    WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''0'') 
    ELSE TRIM(ini_info ->> ''value'') 
    END AS relation_flg 
FROM
  mst_coop_ini AS ini 
  CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
WHERE
  ini.is_del = ''0'' 
  AND ini.facility_cd = @facilityCd 
  AND TRIM(ini_info ->> ''key1'') = ''PATIENT_SEND'' 
  AND TRIM(ini_info ->> ''key2'') = ''CONTACT_RELATION_FLG'' 
UNION
SELECT
  2 AS order_no
  , ''0'' AS relation_flg
ORDER BY order_no ASC LIMIT 1', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル_連絡先続柄登録有無切替フラグ', '2022-01-27 18:21:46', '2022-01-27 18:21:46', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1401, 'select
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
  ltrim(hosp_pat_id, ''0'') = ltrim(@hospPatId, ''0'')
and
  facility_cd = @facilityCd', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1402, 'UPDATE pat_personal_main 
SET
  other_contact_info = ''[]'' 
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル_緊急連絡先', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1403, 'WITH name_info AS ( 
  SELECT
    ''@otherContactInfo.lastName'' ::TEXT AS lastName
   , '''' ::TEXT AS lastNmKana
   -- , ''@otherContactInfo.lastNmKana'' ::TEXT AS lastNmKana
) 
, tmp_index_info AS ( 
  SELECT
    COALESCE(NULLIF(POSITION(''　'' IN lastName), 0), LENGTH(lastName) + 1) AS indexLast1
    , COALESCE(NULLIF(POSITION('' '' IN lastName), 0), LENGTH(lastName) + 1) AS indexLast2
    , COALESCE(NULLIF(POSITION(''　'' IN lastNmKana), 0), LENGTH(lastNmKana) + 1) AS indexLastK1
    , COALESCE(NULLIF(POSITION('' '' IN lastNmKana), 0), LENGTH(lastNmKana) + 1) AS indexLastK2
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
      WHEN indexLastK1 > indexLastK2 
        THEN indexLastK2 
      ELSE indexLastK1 
      END AS indexLastK
  FROM
    tmp_index_info
)
, new_name_info AS (
  SELECT
    TRIM(TRIM(TRIM(SUBSTRING(lastName, 1, indexLast-1)), ''　'')) AS lastName
    , TRIM(TRIM(TRIM(SUBSTRING(lastName, indexLast + 1)), ''　'')) AS firstName
    , TRIM(TRIM(TRIM(SUBSTRING(lastNmKana, 1, indexLastK-1)), ''　'')) AS lastNmKana
    , TRIM(TRIM(TRIM(SUBSTRING(lastNmKana, indexLastK + 1)), ''　'')) AS firstNmKana
  FROM 
    name_info,
    index_info
)  
, data_new_info AS (
  SELECT 
    null AS ctl_no,
    ''0'' AS disp_order,
    null AS pat_id,
    COALESCE(NULLIF(lastName, ''''), '' '') AS last_name,
    COALESCE(NULLIF(firstName, ''''), '' '') AS first_name,
    NULLIF(lastNmKana, '''') AS last_name_kana,
    NULLIF(firstNmKana, '''') AS first_name_kana,
    CASE WHEN COALESCE(NULLIF(''@relationFlg'', ''''), ''0'') = ''1'' THEN NULLIF(''@otherContactInfo.relationCd'', '''') ELSE null END AS relation_cd,
    null AS relation_name,
    null AS zip_cd,
    null AS address,
    NULLIF(''@otherContactInfo.tel1'', '''') AS tel1,
    NULLIF(''@otherContactInfo.tel2'', '''') AS tel2,
    null AS fax,
    null AS e_mail,
    null AS work_name,
    null AS work_tel,
    null AS work_address,
    NULLIF(''@otherContactInfo.memo1'', '''') AS memo1,
    null AS memo2,
    ''0'' AS is_key_person
  FROM new_name_info
) 
, data_exists_info AS (
  SELECT
    1 AS order_no
    , (info->>''ctl_no'') :: TEXT AS ctl_no 
  FROM
    pat_personal_main pm
    CROSS JOIN LATERAL json_array_elements (personal_info_decrypt_jsonb(pm.other_contact_info) :: json ) AS info 
    INNER JOIN data_new_info AS NEW ON (info->> ''last_name'')::TEXT = (NEW.last_name ::TEXT) AND (info->> ''first_name'')::TEXT = (NEW.first_name ::TEXT)
  WHERE
    pm.pat_id = @patId 
    AND pm.facility_cd = ''@facilityCd'' 
    AND pm.is_del = ''0'' 
  UNION 
  SELECT
    2 AS order_no
    , ''-1'' AS ctl_no 
  ORDER BY
    order_no ASC, ctl_no ASC LIMIT 1
)
, data_info AS ( 
  SELECT
    0 AS order_no,
    ctl_no::TEXT AS ctl_no,
    disp_order::TEXT AS disp_order,
    pat_id::TEXT AS pat_id,
    last_name::TEXT AS last_name,
    first_name::TEXT AS first_name,
    last_name_kana::TEXT AS last_name_kana,
    first_name_kana::TEXT AS first_name_kana,
    relation_cd::TEXT AS relation_cd,
    relation_name::TEXT AS relation_name,
    zip_cd::TEXT AS zip_cd,
    address::TEXT AS address,
    tel1::TEXT AS tel1,
    tel2::TEXT AS tel2,
    fax::TEXT AS fax,
    e_mail::TEXT AS e_mail,
    work_name::TEXT AS work_name,
    work_tel::TEXT AS work_tel,
    work_address::TEXT AS work_address,
    memo1::TEXT AS memo1,
    memo2::TEXT AS memo2,
    is_key_person::TEXT AS is_key_person
  FROM
    data_new_info AS new
  WHERE
    (SELECT ctl_no FROM data_exists_info) = ''-1'' 
  UNION 
  SELECT
    1 AS order_no,
    info ->> ''ctl_no'' AS ctl_no,
    info ->> ''disp_order'' AS disp_order,
    info ->> ''pat_id'' AS pat_id,
    info ->> ''last_name'' AS last_name,
    info ->> ''first_name'' AS first_name,
    info ->> ''last_name_kana'' AS last_name_kana,
    info ->> ''first_name_kana'' AS first_name_kana,
    (CASE WHEN NEW.ctl_no_old IS NULL THEN info ->> ''relation_cd'' ELSE new.relation_cd::TEXT END) AS relation_cd,
    (CASE WHEN NEW.ctl_no_old IS NULL THEN info ->> ''relation_name'' ELSE '''' END) AS relation_name,
    info ->> ''zip_cd'' AS zip_cd,
    info ->> ''address'' AS address,
    (CASE WHEN NEW.ctl_no_old IS NULL THEN info ->> ''tel1'' ELSE new.tel1::TEXT END) AS tel1,
    (CASE WHEN NEW.ctl_no_old IS NULL THEN info ->> ''tel2'' ELSE new.tel2::TEXT END) AS tel2,
    info ->> ''fax'' AS fax,
    info ->> ''e_mail'' AS e_mail,
    info ->> ''work_name'' AS work_name,
    info ->> ''work_tel'' AS work_tel,
    info ->> ''work_address'' AS work_address,
    (CASE WHEN NEW.ctl_no_old IS NULL THEN info ->> ''memo1'' ELSE new.memo1::TEXT END) AS memo1,
    info ->> ''memo2'' AS memo2,
    info ->> ''is_key_person'' AS is_key_person
  FROM
    pat_personal_main pm
    CROSS JOIN LATERAL json_array_elements (personal_info_decrypt_jsonb(pm.other_contact_info) :: json ) AS info 
    LEFT OUTER JOIN (SELECT data1.ctl_no AS ctl_no_old, new1.* FROM data_new_info AS new1, data_exists_info AS data1) AS NEW ON (info->> ''ctl_no'')::TEXT = (NEW.ctl_no_old::TEXT)
  WHERE
    pm.pat_id = @patId 
    AND pm.facility_cd = ''@facilityCd'' 
    AND pm.is_del = ''0'' 
  ORDER BY
    order_no DESC, ctl_no ASC
)
, json_data AS (
  SELECT json_build_object(
    ''ctl_no'', row_number() over(order by order_no DESC, ctl_no ASC),
    ''disp_order'', (disp_order :: INTEGER),
    ''pat_id'', pat_id,
    ''last_name'', last_name,
    ''first_name'', first_name,
    ''last_name_kana'', last_name_kana,
    ''first_name_kana'', first_name_kana,
    ''relation_cd'', (relation_cd :: INTEGER),
    ''relation_name'', relation_name,
    ''zip_cd'', zip_cd,
    ''address'', address,
    ''tel1'', tel1,
    ''tel2'', tel2,
    ''fax'', fax,
    ''e_mail'', e_mail,
    ''work_name'', work_name,
    ''work_tel'', work_tel,
    ''work_address'', work_address,
    ''memo1'', memo1,
    ''memo2'', memo2,
    ''is_key_person'', is_key_person) AS new_data
  FROM data_info
)
UPDATE pat_personal_main 
SET 
  other_contact_info = (SELECT array_to_json(ARRAY_AGG(new_data)) FROM json_data)
  , up_date = CURRENT_TIMESTAMP
WHERE
    is_del = ''0'' 
    AND pat_id = @patId 
    AND facility_cd = ''@facilityCd''', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル_緊急連絡先', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', '[{"sql_cd": 1006, "field_name": "relation_flg", "replace_var": "@relationFlg"}]');
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1703, 'WITH exam_date_tmp AS ( 
  SELECT
    COALESCE(NULLIF(''@physicalInfo.examDate1_Date'', ''''), COALESCE(NULLIF(''@physicalInfo.examDate2_Date'', ''''), TO_CHAR(CURRENT_TIMESTAMP, ''YYYY-MM-DD HH24:MI:SS''))) AS exam_date
) 
, exam_date_info AS ( 
  SELECT
    SUBSTR(exam_date, 1, 10) || ''T'' || SUBSTR(exam_date, 12, 8) AS exam_date
    , TO_CHAR(TO_DATE(exam_date, ''YYYY-MM-DD HH24:MI:SS''), ''YYYYMMDD'') AS inspect_date
    , TO_CHAR(TO_DATE(exam_date, ''YYYY-MM-DD HH24:MI:SS''), ''YYYYMMDD'') AS indicator_start_date 
  FROM
    exam_date_tmp
) 
, order_class_info AS ( 
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''1'') 
      ELSE TRIM(ini_info ->> ''value'') 
      END AS order_class 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = ''@facilityCd'' 
    AND TRIM(ini_info ->> ''key1'') = ''PATIENT_SEND'' 
    AND TRIM(ini_info ->> ''key2'') = ''ORDER_CLASS'' 
  UNION 
  SELECT
    2 AS order_no
    , ''1'' AS order_class 
  ORDER BY
    order_no ASC LIMIT 1
) 
, indicator_info AS ( 
  SELECT
    1 AS order_no
    , CASE 
      WHEN TRIM(ini_info ->> ''value'') = '''' OR TRIM(ini_info ->> ''value'') = ''0'' 
        THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''0''), '''') 
      ELSE TRIM(ini_info ->> ''value'') 
      END AS indicator_cd 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = ''@facilityCd'' 
    AND TRIM(ini_info ->> ''key1'') = ''ORDER_RECV'' 
    AND TRIM(ini_info ->> ''key2'') = ''DEFAULT_DOCTOR'' 
  UNION 
  SELECT
    2 AS order_no
    , '''' AS indicator_cd 
  ORDER BY
    order_no ASC LIMIT 1
) 
, data_new_info AS (
  SELECT 
    NULL AS dw,
    NULL AS ctr,
    NULL AS memo,
    NULL AS ctl_no,
    NULLIF(''@physicalInfo.height'', '''') AS height,
    NULL AS chest_dia,
    (SELECT exam_date FROM exam_date_info) AS exam_date,
    NULL AS breast_dia,
    NULLIF(''@physicalInfo.ctrWeight'', '''') AS ctr_weight,
    NULLIF(''@facilityCd'', '''') AS facility_cd,
    (SELECT order_class FROM order_class_info) AS order_class,
    (SELECT indicator_cd FROM indicator_info) AS indicator_cd,
    (SELECT inspect_date FROM exam_date_info) AS inspect_date,
    NULL AS pre_scale_lower,
    NULL AS pre_scale_upper,
    (SELECT indicator_start_date FROM exam_date_info) AS indicator_start_date,
    NULL AS target_weight
) 
, data_old_info AS (
  SELECT
    info ->> ''dw'' AS dw,
    info ->> ''ctr'' AS ctr,
    info ->> ''memo'' AS memo,
    info ->> ''ctl_no'' AS ctl_no,
    info ->> ''height'' AS height,
    info ->> ''chest_dia'' AS chest_dia,
    info ->> ''exam_date'' AS exam_date,
    info ->> ''breast_dia'' AS breast_dia,
    info ->> ''ctr_weight'' AS ctr_weight,
    info ->> ''facility_cd'' AS facility_cd,
    info ->> ''order_class'' AS order_class,
    info ->> ''indicator_cd'' AS indicator_cd,
    info ->> ''inspect_date'' AS inspect_date,
    info ->> ''pre_scale_lower'' AS pre_scale_lower,
    info ->> ''pre_scale_upper'' AS pre_scale_upper,
    info ->> ''indicator_start_date'' AS indicator_start_date, 
    info ->> ''target_weight'' AS target_weight 
  FROM
    pat_unique patu
    CROSS JOIN LATERAL json_array_elements ( patu.physical_info :: json ) AS info 
  WHERE
    pat_id = @patId 
    AND facility_cd = ''@facilityCd'' 
    AND is_del = ''0'' 
  ORDER BY
    exam_date DESC, ctl_no ASC LIMIT 1
) 
, data_exists_info AS (
  SELECT
    1 AS order_no
    , ''1'' AS exists_flag 
  FROM
    data_old_info AS OLD
    , data_new_info AS NEW 
  WHERE
    TO_NUMBER(OLD.height ::TEXT, ''FM9999.99'') = TO_NUMBER(NEW.height ::TEXT, ''FM9999.99'') 
    AND TO_NUMBER(OLD.ctr_weight ::TEXT, ''FM9999.99'') = TO_NUMBER(NEW.ctr_weight ::TEXT, ''FM9999.99'') 
    AND SUBSTR(OLD.exam_date ::TEXT, 1, 10) = SUBSTR(NEW.exam_date ::TEXT, 1, 10) 
  UNION 
  SELECT
    2 AS order_no
    , ''0'' AS exists_flag 
  ORDER BY
    order_no ASC LIMIT 1
)
, data_info AS ( 
  SELECT
    0 AS order_no
    , dw ::TEXT AS dw
    , ctr ::TEXT AS ctr
    , memo ::TEXT AS memo
    , ctl_no ::TEXT AS ctl_no
    , height ::TEXT AS height
    , chest_dia ::TEXT AS chest_dia
    , exam_date ::TEXT AS exam_date
    , breast_dia ::TEXT AS breast_dia
    , ctr_weight ::TEXT AS ctr_weight
    , facility_cd ::TEXT AS facility_cd
    , order_class ::TEXT AS order_class
    , indicator_cd ::TEXT AS indicator_cd
    , inspect_date ::TEXT AS inspect_date
    , pre_scale_lower ::TEXT AS pre_scale_lower
    , pre_scale_upper ::TEXT AS pre_scale_upper
    , indicator_start_date ::TEXT AS indicator_start_date 
    , target_weight ::TEXT AS target_weight 
  FROM
    data_new_info 
  WHERE
    (SELECT exists_flag FROM data_exists_info) = ''0'' 
  UNION 
  SELECT
    1 AS order_no
    , info ->> ''dw'' AS dw
    , info ->> ''ctr'' AS ctr
    , info ->> ''memo'' AS memo
    , info ->> ''ctl_no'' AS ctl_no
    , info ->> ''height'' AS height
    , info ->> ''chest_dia'' AS chest_dia
    , info ->> ''exam_date'' AS exam_date
    , info ->> ''breast_dia'' AS breast_dia
    , info ->> ''ctr_weight'' AS ctr_weight
    , info ->> ''facility_cd'' AS facility_cd
    , info ->> ''order_class'' AS order_class
    , info ->> ''indicator_cd'' AS indicator_cd
    , info ->> ''inspect_date'' AS inspect_date
    , info ->> ''pre_scale_lower'' AS pre_scale_lower
    , info ->> ''pre_scale_upper'' AS pre_scale_upper
    , info ->> ''indicator_start_date'' AS indicator_start_date 
    , info ->> ''target_weight'' AS target_weight 
  FROM
    pat_unique patu 
    CROSS JOIN LATERAL json_array_elements(patu.physical_info ::json) AS info 
  WHERE
    pat_id = @patId  
    AND facility_cd = ''@facilityCd'' 
    AND is_del = ''0''
  ORDER BY order_no ASC, exam_date DESC)
, json_data AS (
  SELECT json_build_object(''dw'', TO_NUMBER(dw , ''FM9999.99''),
    ''ctr'', TO_NUMBER(ctr, ''FM9999.99''),
    ''memo'', memo,
    ''ctl_no'', row_number() over(order by order_no ASC, exam_date DESC),
    ''height'', TO_NUMBER(height, ''FM9999.99''),
    ''chest_dia'', TO_NUMBER(chest_dia, ''FM9999.99''),
    ''exam_date'', exam_date,
    ''breast_dia'', TO_NUMBER(breast_dia, ''FM9999.99''),
    ''ctr_weight'', TO_NUMBER(ctr_weight, ''FM9999.99''),
    ''facility_cd'', facility_cd,
    ''order_class'', (order_class :: INTEGER),
    ''indicator_cd'', (NULLIF(indicator_cd, '''') :: INTEGER),
    ''inspect_date'', inspect_date,
    ''pre_scale_lower'', TO_NUMBER(pre_scale_lower, ''FM9999.99''),
    ''pre_scale_upper'', TO_NUMBER(pre_scale_upper, ''FM9999.99''),
    ''indicator_start_date '', indicator_start_date) AS new_data
  FROM data_info
)
UPDATE pat_unique 
SET
  physical_info = (SELECT array_to_json(ARRAY_AGG(new_data)) FROM json_data)
  , up_date = CURRENT_TIMESTAMP
WHERE
  pat_id = @patId 
  AND facility_cd = ''@facilityCd'' 
  AND is_del = ''0''
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル_固有情報_身体情報', '2020-05-25 18:21:40.841', '2021-12-24 17:59:06.44', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1705, 'WITH data_new_info AS (
  SELECT 
    null AS ctl_no,
    NULLIF(''@inOutClass'', '''') :: TEXT AS in_out, 
    null AS reason,
    null AS to_course,
    null AS to_doctor,
    0 AS disp_order,
    null AS period_end,
    NULLIF(''@facilityCd'', '''') AS facility_cd,
    null AS from_course,
    null AS from_doctor,
    (CASE ''@inOutClass'' WHEN ''0'' THEN  ''6'' WHEN ''1'' THEN ''4'' ELSE ''10'' END) :: TEXT AS move_in_out,
    null AS to_facility,
    TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDD'') AS period_start,
    null AS from_facility,
    ''0'' AS course_is_free,
    ''0'' AS doctor_is_free,
    null AS period_end_day,
    null AS period_end_year,
    ''0'' AS facility_is_free,
    null AS period_end_month,
    TO_CHAR(CURRENT_TIMESTAMP, ''DD'') AS period_start_day,
    TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDD'') AS period_start_date,
    TO_CHAR(CURRENT_TIMESTAMP, ''YYYY'') AS period_start_year,
    TO_CHAR(CURRENT_TIMESTAMP, ''MM'') AS period_start_month,
    ''0'' AS period_end_input_free,
    ''0'' AS period_start_input_free,
    null AS to_medicalInstitutionCd,
    null AS from_medicalInstitutionCd
) 
, data_old_info AS (
  SELECT
    info ->> ''ctl_no'' AS ctl_no,
    info ->> ''in_out'' AS in_out,
    info ->> ''reason'' AS reason,
    info ->> ''to_course'' AS to_course,
    info ->> ''to_doctor'' AS to_doctor,
    info ->> ''disp_order'' AS disp_order,
    info ->> ''period_end'' AS period_end,
    info ->> ''facility_cd'' AS facility_cd,
    info ->> ''from_course'' AS from_course,
    info ->> ''from_doctor'' AS from_doctor,
    info ->> ''move_in_out'' AS move_in_out,
    info ->> ''to_facility'' AS to_facility,
    info ->> ''period_start'' AS period_start,
    info ->> ''from_facility'' AS from_facility,
    info ->> ''course_is_free'' AS course_is_free,
    info ->> ''doctor_is_free'' AS doctor_is_free,
    info ->> ''period_end_day'' AS period_end_day,
    info ->> ''period_end_year'' AS period_end_year,
    info ->> ''facility_is_free'' AS facility_is_free,
    info ->> ''period_end_month'' AS period_end_month,
    info ->> ''period_start_day'' AS period_start_day,
    info ->> ''period_start_date'' AS period_start_date,
    info ->> ''period_start_year'' AS period_start_year,
    info ->> ''period_start_month'' AS period_start_month,
    info ->> ''period_end_input_free'' AS period_end_input_free,
    info ->> ''period_start_input_free'' AS period_start_input_free,
    info ->> ''to_medicalInstitutionCd'' AS to_medicalInstitutionCd,
    info ->> ''from_medicalInstitutionCd'' AS from_medicalInstitutionCd
  FROM
    pat_unique patu
    CROSS JOIN LATERAL json_array_elements ( patu.in_out_visit_history_info :: json ) AS info 
  WHERE
    pat_id = @patId 
    AND facility_cd = ''@facilityCd'' 
    AND is_del = ''0'' 
  ORDER BY
    period_start DESC, ctl_no ASC LIMIT 1
) 
, data_exists_info AS (
  SELECT
    1 AS order_no
    , ''1'' AS exists_flag 
  FROM
    data_old_info AS OLD
    , data_new_info AS NEW 
  WHERE
    (OLD.in_out ::TEXT) = (NEW.in_out ::TEXT) 
  UNION 
  SELECT
    2 AS order_no
    , ''0'' AS exists_flag 
  ORDER BY
    order_no ASC LIMIT 1
)
, data_info AS ( 
  SELECT
    0 AS order_no,
    ctl_no::TEXT AS ctl_no,
    in_out::TEXT AS in_out,
    reason::TEXT AS reason,
    to_course::TEXT AS to_course,
    to_doctor::TEXT AS to_doctor,
    disp_order::TEXT AS disp_order,
    period_end::TEXT AS period_end,
    facility_cd::TEXT AS facility_cd,
    from_course::TEXT AS from_course,
    from_doctor::TEXT AS from_doctor,
    move_in_out::TEXT AS move_in_out,
    to_facility::TEXT AS to_facility,
    period_start::TEXT AS period_start,
    from_facility::TEXT AS from_facility,
    course_is_free::TEXT AS course_is_free,
    doctor_is_free::TEXT AS doctor_is_free,
    period_end_day::TEXT AS period_end_day,
    period_end_year::TEXT AS period_end_year,
    facility_is_free::TEXT AS facility_is_free,
    period_end_month::TEXT AS period_end_month,
    period_start_day::TEXT AS period_start_day,
    period_start_date::TEXT AS period_start_date,
    period_start_year::TEXT AS period_start_year,
    period_start_month::TEXT AS period_start_month,
    period_end_input_free::TEXT AS period_end_input_free,
    period_start_input_free::TEXT AS period_start_input_free,
    to_medicalInstitutionCd::TEXT AS to_medicalInstitutionCd,
    from_medicalInstitutionCd::TEXT AS from_medicalInstitutionCd
  FROM
    data_new_info 
  WHERE
    (SELECT exists_flag FROM data_exists_info) = ''0'' 
  UNION 
  SELECT
    1 AS order_no,
    info ->> ''ctl_no'' AS ctl_no,
    info ->> ''in_out'' AS in_out,
    info ->> ''reason'' AS reason,
    info ->> ''to_course'' AS to_course,
    info ->> ''to_doctor'' AS to_doctor,
    info ->> ''disp_order'' AS disp_order,
    info ->> ''period_end'' AS period_end,
    info ->> ''facility_cd'' AS facility_cd,
    info ->> ''from_course'' AS from_course,
    info ->> ''from_doctor'' AS from_doctor,
    info ->> ''move_in_out'' AS move_in_out,
    info ->> ''to_facility'' AS to_facility,
    info ->> ''period_start'' AS period_start,
    info ->> ''from_facility'' AS from_facility,
    info ->> ''course_is_free'' AS course_is_free,
    info ->> ''doctor_is_free'' AS doctor_is_free,
    info ->> ''period_end_day'' AS period_end_day,
    info ->> ''period_end_year'' AS period_end_year,
    info ->> ''facility_is_free'' AS facility_is_free,
    info ->> ''period_end_month'' AS period_end_month,
    info ->> ''period_start_day'' AS period_start_day,
    info ->> ''period_start_date'' AS period_start_date,
    info ->> ''period_start_year'' AS period_start_year,
    info ->> ''period_start_month'' AS period_start_month,
    info ->> ''period_end_input_free'' AS period_end_input_free,
    info ->> ''period_start_input_free'' AS period_start_input_free,
    info ->> ''to_medicalInstitutionCd'' AS to_medicalInstitutionCd,
    info ->> ''from_medicalInstitutionCd'' AS from_medicalInstitutionCd
  FROM
    pat_unique patu
    CROSS JOIN LATERAL json_array_elements ( patu.in_out_visit_history_info :: json ) AS info 
  WHERE
    pat_id = @patId 
    AND facility_cd = ''@facilityCd'' 
    AND is_del = ''0'' 
  ORDER BY
    order_no DESC, period_start ASC)
, json_data AS (
  SELECT json_build_object(
    ''ctl_no'', row_number() over(order by order_no DESC, period_start ASC),
    ''in_out'' , (in_out :: INTEGER),
    ''reason'' , reason,
    ''to_course'' , (to_course :: INTEGER),
    ''to_doctor'' , (to_doctor :: INTEGER),
    ''disp_order'' , (disp_order :: INTEGER),
    ''period_end'' , period_end,
    ''facility_cd'' , facility_cd,
    ''from_course'' , (from_course :: INTEGER),
    ''from_doctor'' , (from_doctor :: INTEGER),
    ''move_in_out'' , move_in_out,
    ''to_facility'' , to_facility,
    ''period_start'' , period_start,
    ''from_facility'' , from_facility,
    ''course_is_free'' , course_is_free,
    ''doctor_is_free'' , doctor_is_free,
    ''period_end_day'' , period_end_day,
    ''period_end_year'' , period_end_year,
    ''facility_is_free'' , facility_is_free,
    ''period_end_month'' , period_end_month,
    ''period_start_day'' , period_start_day,
    ''period_start_date'' , period_start_date,
    ''period_start_year'' , period_start_year,
    ''period_start_month'' , period_start_month,
    ''period_end_input_free'' , period_end_input_free,
    ''period_start_input_free'' , period_start_input_free,
    ''to_medicalInstitutionCd'' , to_medicalInstitutionCd,
    ''from_medicalInstitutionCd'' , from_medicalInstitutionCd) AS new_data
  FROM data_info
)
UPDATE pat_unique 
SET
  in_out_visit_history_info = (SELECT array_to_json(ARRAY_AGG(new_data)) FROM json_data)
  , up_date = CURRENT_TIMESTAMP
WHERE
  pat_id = @patId 
  AND facility_cd = ''@facilityCd'' 
  AND is_del = ''0''
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル_固有情報_入外・転入出情報(死亡以外)', '2020-05-25 18:21:40.841', '2021-12-24 17:59:06.44', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1706, 'WITH data_new_info AS (
  SELECT 
    null AS ctl_no,
    ''2'' :: TEXT AS in_out, 
    null AS reason,
    null AS to_course,
    null AS to_doctor,
    0 AS disp_order,
    null AS period_end,
    NULLIF(''@facilityCd'', '''') AS facility_cd,
    null AS from_course,
    null AS from_doctor,
    ''11'' :: TEXT AS move_in_out,
    null AS to_facility,
    TO_CHAR(TO_DATE(''@dieDate_Date'', ''YYYY-MM-DD HH24:MI:SS''), ''YYYYMMDD'') AS period_start,
    null AS from_facility,
    ''0'' AS course_is_free,
    ''0'' AS doctor_is_free,
    null AS period_end_day,
    null AS period_end_year,
    ''0'' AS facility_is_free,
    null AS period_end_month,
    TO_CHAR(TO_DATE(''@dieDate_Date'', ''YYYY-MM-DD HH24:MI:SS''), ''DD'') AS period_start_day,
    null AS period_start_date,
    TO_CHAR(TO_DATE(''@dieDate_Date'', ''YYYY-MM-DD HH24:MI:SS''), ''YYYY'') AS period_start_year,
    TO_CHAR(TO_DATE(''@dieDate_Date'', ''YYYY-MM-DD HH24:MI:SS''), ''MM'') AS period_start_month,
    ''0'' AS period_end_input_free,
    ''0'' AS period_start_input_free,
    null AS to_medicalInstitutionCd,
    null AS from_medicalInstitutionCd
) 
, data_old_info AS (
  SELECT
    info ->> ''ctl_no'' AS ctl_no,
    info ->> ''in_out'' AS in_out,
    info ->> ''reason'' AS reason,
    info ->> ''to_course'' AS to_course,
    info ->> ''to_doctor'' AS to_doctor,
    info ->> ''disp_order'' AS disp_order,
    info ->> ''period_end'' AS period_end,
    info ->> ''facility_cd'' AS facility_cd,
    info ->> ''from_course'' AS from_course,
    info ->> ''from_doctor'' AS from_doctor,
    info ->> ''move_in_out'' AS move_in_out,
    info ->> ''to_facility'' AS to_facility,
    info ->> ''period_start'' AS period_start,
    info ->> ''from_facility'' AS from_facility,
    info ->> ''course_is_free'' AS course_is_free,
    info ->> ''doctor_is_free'' AS doctor_is_free,
    info ->> ''period_end_day'' AS period_end_day,
    info ->> ''period_end_year'' AS period_end_year,
    info ->> ''facility_is_free'' AS facility_is_free,
    info ->> ''period_end_month'' AS period_end_month,
    info ->> ''period_start_day'' AS period_start_day,
    info ->> ''period_start_date'' AS period_start_date,
    info ->> ''period_start_year'' AS period_start_year,
    info ->> ''period_start_month'' AS period_start_month,
    info ->> ''period_end_input_free'' AS period_end_input_free,
    info ->> ''period_start_input_free'' AS period_start_input_free,
    info ->> ''to_medicalInstitutionCd'' AS to_medicalInstitutionCd,
    info ->> ''from_medicalInstitutionCd'' AS from_medicalInstitutionCd
  FROM
    pat_unique patu
    CROSS JOIN LATERAL json_array_elements ( patu.in_out_visit_history_info :: json ) AS info 
  WHERE
    pat_id = @patId 
    AND facility_cd = ''@facilityCd'' 
    AND is_del = ''0'' 
  ORDER BY
    period_start DESC, ctl_no ASC LIMIT 1
) 
, data_exists_info AS (
  SELECT
    1 AS order_no
    , ''1'' AS exists_flag 
  FROM
    data_old_info AS OLD
    , data_new_info AS NEW 
  WHERE
    (OLD.in_out ::TEXT) = (NEW.in_out ::TEXT) 
  UNION 
  SELECT
    2 AS order_no
    , ''0'' AS exists_flag 
  ORDER BY
    order_no ASC LIMIT 1
)
, data_info AS ( 
  SELECT
    0 AS order_no,
    ctl_no::TEXT AS ctl_no,
    in_out::TEXT AS in_out,
    reason::TEXT AS reason,
    to_course::TEXT AS to_course,
    to_doctor::TEXT AS to_doctor,
    disp_order::TEXT AS disp_order,
    period_end::TEXT AS period_end,
    facility_cd::TEXT AS facility_cd,
    from_course::TEXT AS from_course,
    from_doctor::TEXT AS from_doctor,
    move_in_out::TEXT AS move_in_out,
    to_facility::TEXT AS to_facility,
    period_start::TEXT AS period_start,
    from_facility::TEXT AS from_facility,
    course_is_free::TEXT AS course_is_free,
    doctor_is_free::TEXT AS doctor_is_free,
    period_end_day::TEXT AS period_end_day,
    period_end_year::TEXT AS period_end_year,
    facility_is_free::TEXT AS facility_is_free,
    period_end_month::TEXT AS period_end_month,
    period_start_day::TEXT AS period_start_day,
    period_start_date::TEXT AS period_start_date,
    period_start_year::TEXT AS period_start_year,
    period_start_month::TEXT AS period_start_month,
    period_end_input_free::TEXT AS period_end_input_free,
    period_start_input_free::TEXT AS period_start_input_free,
    to_medicalInstitutionCd::TEXT AS to_medicalInstitutionCd,
    from_medicalInstitutionCd::TEXT AS from_medicalInstitutionCd
  FROM
    data_new_info 
  WHERE
    (SELECT exists_flag FROM data_exists_info) = ''0'' 
  UNION 
  SELECT
    1 AS order_no,
    info ->> ''ctl_no'' AS ctl_no,
    info ->> ''in_out'' AS in_out,
    info ->> ''reason'' AS reason,
    info ->> ''to_course'' AS to_course,
    info ->> ''to_doctor'' AS to_doctor,
    info ->> ''disp_order'' AS disp_order,
    info ->> ''period_end'' AS period_end,
    info ->> ''facility_cd'' AS facility_cd,
    info ->> ''from_course'' AS from_course,
    info ->> ''from_doctor'' AS from_doctor,
    info ->> ''move_in_out'' AS move_in_out,
    info ->> ''to_facility'' AS to_facility,
    info ->> ''period_start'' AS period_start,
    info ->> ''from_facility'' AS from_facility,
    info ->> ''course_is_free'' AS course_is_free,
    info ->> ''doctor_is_free'' AS doctor_is_free,
    info ->> ''period_end_day'' AS period_end_day,
    info ->> ''period_end_year'' AS period_end_year,
    info ->> ''facility_is_free'' AS facility_is_free,
    info ->> ''period_end_month'' AS period_end_month,
    info ->> ''period_start_day'' AS period_start_day,
    info ->> ''period_start_date'' AS period_start_date,
    info ->> ''period_start_year'' AS period_start_year,
    info ->> ''period_start_month'' AS period_start_month,
    info ->> ''period_end_input_free'' AS period_end_input_free,
    info ->> ''period_start_input_free'' AS period_start_input_free,
    info ->> ''to_medicalInstitutionCd'' AS to_medicalInstitutionCd,
    info ->> ''from_medicalInstitutionCd'' AS from_medicalInstitutionCd
  FROM
    pat_unique patu
    CROSS JOIN LATERAL json_array_elements ( patu.in_out_visit_history_info :: json ) AS info 
  WHERE
    pat_id = @patId 
    AND facility_cd = ''@facilityCd'' 
    AND is_del = ''0'' 
  ORDER BY
    order_no DESC, period_start ASC)
, json_data AS (
  SELECT json_build_object(
    ''ctl_no'', row_number() over(order by order_no DESC, period_start ASC),
    ''in_out'' , (in_out :: INTEGER),
    ''reason'' , reason,
    ''to_course'' , (to_course :: INTEGER),
    ''to_doctor'' , (to_doctor :: INTEGER),
    ''disp_order'' , (disp_order :: INTEGER),
    ''period_end'' , period_end,
    ''facility_cd'' , facility_cd,
    ''from_course'' , (from_course :: INTEGER),
    ''from_doctor'' , (from_doctor :: INTEGER),
    ''move_in_out'' , move_in_out,
    ''to_facility'' , to_facility,
    ''period_start'' , period_start,
    ''from_facility'' , from_facility,
    ''course_is_free'' , course_is_free,
    ''doctor_is_free'' , doctor_is_free,
    ''period_end_day'' , period_end_day,
    ''period_end_year'' , period_end_year,
    ''facility_is_free'' , facility_is_free,
    ''period_end_month'' , period_end_month,
    ''period_start_day'' , period_start_day,
    ''period_start_date'' , period_start_date,
    ''period_start_year'' , period_start_year,
    ''period_start_month'' , period_start_month,
    ''period_end_input_free'' , period_end_input_free,
    ''period_start_input_free'' , period_start_input_free,
    ''to_medicalInstitutionCd'' , to_medicalInstitutionCd,
    ''from_medicalInstitutionCd'' , from_medicalInstitutionCd) AS new_data
  FROM data_info
)
UPDATE pat_unique 
SET
  in_out_visit_history_info = (SELECT array_to_json(ARRAY_AGG(new_data)) FROM json_data)
  , up_date = CURRENT_TIMESTAMP
WHERE
  pat_id = @patId 
  AND facility_cd = ''@facilityCd'' 
  AND is_del = ''0''
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル_固有情報_入外・転入出情報(死亡)', '2020-05-25 18:21:40.841', '2021-12-24 17:59:06.44', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1707, 'WITH data_new_info AS (
  SELECT 
     null AS memo, 
     null AS ctl_no, 
     TO_CHAR(TO_DATE(''@dieDate_Date'', ''YYYY-MM-DD HH24:MI:SS''), ''YYYYMMDD'') AS die_date, 
     ''10'' AS out_come, 
     null AS course_cd, 
     ''0'' AS is_notice, 
     null AS disease_cd, 
     ''0'' AS disp_order, 
     null AS disease_day, 
     NULLIF(''@facilityCd'', '''') AS facility_cd, 
     null AS disease_date, 
     null AS disease_year, 
     ''0'' AS is_diagnosed, 
     null AS diagnosis_day, 
     null AS disease_month, 
     TO_CHAR(TO_DATE(''@dieDate_Date'', ''YYYY-MM-DD HH24:MI:SS''), ''YYYYMMDD'') AS out_come_date, 
     ''0'' AS course_is_free, 
     null AS diagnosis_date, 
     null AS diagnosis_year, 
     null AS diagnosis_month, 
     ''0'' AS is_main_disease, 
     null AS diagnostician_cd, 
     null AS diagnosis_facility_cd, 
     ''0'' AS diagnostician_is_free, 
     ''0'' AS is_confirmation_biopsy, 
     ''0'' AS diagnosis_facility_is_free, 
     ''0'' AS is_dialysis_underlying_disease
) 
, data_old_info AS (
  SELECT
    info ->> ''memo'' AS memo, 
    info ->> ''ctl_no'' AS ctl_no, 
    info ->> ''die_date'' AS die_date, 
    info ->> ''out_come'' AS out_come, 
    info ->> ''course_cd'' AS course_cd, 
    info ->> ''is_notice'' AS is_notice, 
    info ->> ''disease_cd'' AS disease_cd, 
    info ->> ''disp_order'' AS disp_order, 
    info ->> ''disease_day'' AS disease_day, 
    info ->> ''facility_cd'' AS facility_cd, 
    info ->> ''disease_date'' AS disease_date, 
    info ->> ''disease_year'' AS disease_year, 
    info ->> ''is_diagnosed'' AS is_diagnosed, 
    info ->> ''diagnosis_day'' AS diagnosis_day, 
    info ->> ''disease_month'' AS disease_month, 
    info ->> ''out_come_date'' AS out_come_date, 
    info ->> ''course_is_free'' AS course_is_free, 
    info ->> ''diagnosis_date'' AS diagnosis_date, 
    info ->> ''diagnosis_year'' AS diagnosis_year, 
    info ->> ''diagnosis_month'' AS diagnosis_month, 
    info ->> ''is_main_disease'' AS is_main_disease, 
    info ->> ''diagnostician_cd'' AS diagnostician_cd, 
    info ->> ''diagnosis_facility_cd'' AS diagnosis_facility_cd, 
    info ->> ''diagnostician_is_free'' AS diagnostician_is_free, 
    info ->> ''is_confirmation_biopsy'' AS is_confirmation_biopsy, 
    info ->> ''diagnosis_facility_is_free'' AS diagnosis_facility_is_free, 
    info ->> ''is_dialysis_underlying_disease'' AS is_dialysis_underlying_disease
  FROM
    pat_unique patu
    CROSS JOIN LATERAL json_array_elements ( patu.medical_hst_info :: json ) AS info 
  WHERE
    pat_id = @patId 
    AND facility_cd = ''@facilityCd'' 
    AND is_del = ''0'' 
  ORDER BY
    ctl_no DESC LIMIT 1
) 
, data_exists_info AS (
  SELECT
    1 AS order_no
    , ''1'' AS exists_flag 
  FROM
    data_old_info AS OLD
    , data_new_info AS NEW 
  WHERE
    (OLD.out_come ::TEXT) = (NEW.out_come ::TEXT) 
  UNION 
  SELECT
    2 AS order_no
    , ''0'' AS exists_flag 
  ORDER BY
    order_no ASC LIMIT 1
)
, data_info AS ( 
  SELECT
    0 AS order_no,
    memo::TEXT AS memo, 
    ctl_no::TEXT AS ctl_no, 
    die_date::TEXT AS die_date, 
    out_come::TEXT AS out_come, 
    course_cd::TEXT AS course_cd, 
    is_notice::TEXT AS is_notice, 
    disease_cd::TEXT AS disease_cd, 
    disp_order::TEXT AS disp_order, 
    disease_day::TEXT AS disease_day, 
    facility_cd::TEXT AS facility_cd, 
    disease_date::TEXT AS disease_date, 
    disease_year::TEXT AS disease_year, 
    is_diagnosed::TEXT AS is_diagnosed, 
    diagnosis_day::TEXT AS diagnosis_day, 
    disease_month::TEXT AS disease_month, 
    out_come_date::TEXT AS out_come_date, 
    course_is_free::TEXT AS course_is_free, 
    diagnosis_date::TEXT AS diagnosis_date, 
    diagnosis_year::TEXT AS diagnosis_year, 
    diagnosis_month::TEXT AS diagnosis_month, 
    is_main_disease::TEXT AS is_main_disease, 
    diagnostician_cd::TEXT AS diagnostician_cd, 
    diagnosis_facility_cd::TEXT AS diagnosis_facility_cd, 
    diagnostician_is_free::TEXT AS diagnostician_is_free, 
    is_confirmation_biopsy::TEXT AS is_confirmation_biopsy, 
    diagnosis_facility_is_free::TEXT AS diagnosis_facility_is_free, 
    is_dialysis_underlying_disease::TEXT AS is_dialysis_underlying_disease
  FROM
    data_new_info 
  WHERE
    (SELECT exists_flag FROM data_exists_info) = ''0'' 
  UNION 
  SELECT
    1 AS order_no,
    info ->> ''memo'' AS memo, 
    info ->> ''ctl_no'' AS ctl_no, 
    info ->> ''die_date'' AS die_date, 
    info ->> ''out_come'' AS out_come, 
    info ->> ''course_cd'' AS course_cd, 
    info ->> ''is_notice'' AS is_notice, 
    info ->> ''disease_cd'' AS disease_cd, 
    info ->> ''disp_order'' AS disp_order, 
    info ->> ''disease_day'' AS disease_day, 
    info ->> ''facility_cd'' AS facility_cd, 
    info ->> ''disease_date'' AS disease_date, 
    info ->> ''disease_year'' AS disease_year, 
    info ->> ''is_diagnosed'' AS is_diagnosed, 
    info ->> ''diagnosis_day'' AS diagnosis_day, 
    info ->> ''disease_month'' AS disease_month, 
    info ->> ''out_come_date'' AS out_come_date, 
    info ->> ''course_is_free'' AS course_is_free, 
    info ->> ''diagnosis_date'' AS diagnosis_date, 
    info ->> ''diagnosis_year'' AS diagnosis_year, 
    info ->> ''diagnosis_month'' AS diagnosis_month, 
    info ->> ''is_main_disease'' AS is_main_disease, 
    info ->> ''diagnostician_cd'' AS diagnostician_cd, 
    info ->> ''diagnosis_facility_cd'' AS diagnosis_facility_cd, 
    info ->> ''diagnostician_is_free'' AS diagnostician_is_free, 
    info ->> ''is_confirmation_biopsy'' AS is_confirmation_biopsy, 
    info ->> ''diagnosis_facility_is_free'' AS diagnosis_facility_is_free, 
    info ->> ''is_dialysis_underlying_disease'' AS is_dialysis_underlying_disease
  FROM
    pat_unique patu
    CROSS JOIN LATERAL json_array_elements ( patu.medical_hst_info :: json ) AS info 
  WHERE
    pat_id = @patId 
    AND facility_cd = ''@facilityCd'' 
    AND is_del = ''0'' 
  ORDER BY
    order_no DESC, ctl_no ASC)
, json_data AS (
  SELECT json_build_object(
    ''memo'', memo, 
    ''ctl_no'', row_number() over(order by order_no DESC, ctl_no ASC),
    ''die_date'', die_date, 
    ''out_come'', out_come, 
    ''course_cd'', (course_cd :: INTEGER), 
    ''is_notice'', is_notice, 
    ''disease_cd'', (disease_cd :: INTEGER), 
    ''disp_order'', (disp_order :: INTEGER), 
    ''disease_day'', disease_day, 
    ''facility_cd'', facility_cd, 
    ''disease_date'', disease_date, 
    ''disease_year'', disease_year, 
    ''is_diagnosed'', is_diagnosed, 
    ''diagnosis_day'', diagnosis_day, 
    ''disease_month'', disease_month, 
    ''out_come_date'', out_come_date, 
    ''course_is_free'', course_is_free, 
    ''diagnosis_date'', diagnosis_date, 
    ''diagnosis_year'', diagnosis_year, 
    ''diagnosis_month'', diagnosis_month, 
    ''is_main_disease'', is_main_disease, 
    ''diagnostician_cd'', (diagnostician_cd :: INTEGER), 
    ''diagnosis_facility_cd'', diagnosis_facility_cd, 
    ''diagnostician_is_free'', diagnostician_is_free, 
    ''is_confirmation_biopsy'', is_confirmation_biopsy, 
    ''diagnosis_facility_is_free'', diagnosis_facility_is_free, 
    ''is_dialysis_underlying_disease'', is_dialysis_underlying_disease) AS new_data
  FROM data_info
)
UPDATE pat_unique 
SET
  medical_hst_info = (SELECT array_to_json(ARRAY_AGG(new_data)) FROM json_data)
  , up_date = CURRENT_TIMESTAMP
WHERE
  pat_id = @patId 
  AND facility_cd = ''@facilityCd'' 
  AND is_del = ''0''
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル_固有情報_既往歴情報(死亡)', '2020-05-25 18:21:40.841', '2021-12-24 17:59:06.44', NULL);

DELETE FROM ntss.sys_data_set
WHERE sql_cd in (-1104001, -1104004);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1104001, '-- SQL: -1104001 begin
WITH expanded_candidates AS (
  SELECT value::text AS candidate_user_id, ordinality AS priority
  FROM jsonb_array_elements_text(@chargeUserIdJson::jsonb) WITH ORDINALITY
),
selected_user AS (
  SELECT candidate_user_id FROM expanded_candidates
  WHERE NULLIF(candidate_user_id,'''') IS NOT NULL
  ORDER BY priority ASC LIMIT 1
),
default_user AS (
  SELECT candidate_user_id AS default_user_id FROM expanded_candidates
  WHERE priority = 3 LIMIT 1
)
SELECT
  CASE
    WHEN COALESCE(
        NULLIF(CASE @hospCd12 WHEN ''1'' THEN mpu_sel.in_hospital_cd_1 WHEN ''2'' THEN mpu_sel.in_hospital_cd_2 END,''''),
        NULLIF(CASE @hospCd12 WHEN ''1'' THEN mpu_def.in_hospital_cd_1 WHEN ''2'' THEN mpu_def.in_hospital_cd_2 END,''''),
        NULLIF(@appointmentslotCd,'''')
      ) IS NULL THEN ''''
    ELSE
      CONCAT(
        CASE
          WHEN OCTET_LENGTH(
            COALESCE(
              NULLIF(CASE @hospCd12 WHEN ''1'' THEN mpu_sel.in_hospital_cd_1 WHEN ''2'' THEN mpu_sel.in_hospital_cd_2 END,''''),
              NULLIF(CASE @hospCd12 WHEN ''1'' THEN mpu_def.in_hospital_cd_1 WHEN ''2'' THEN mpu_def.in_hospital_cd_2 END,''''),
              NULLIF(@appointmentslotCd,'''')
            )
          ) <= 4 THEN
            COALESCE(
              NULLIF(CASE @hospCd12 WHEN ''1'' THEN mpu_sel.in_hospital_cd_1 WHEN ''2'' THEN mpu_sel.in_hospital_cd_2 END,''''),
              NULLIF(CASE @hospCd12 WHEN ''1'' THEN mpu_def.in_hospital_cd_1 WHEN ''2'' THEN mpu_def.in_hospital_cd_2 END,''''),
              NULLIF(@appointmentslotCd,'''')
            ) || repeat('' '', 4 - OCTET_LENGTH(
              COALESCE(
                NULLIF(CASE @hospCd12 WHEN ''1'' THEN mpu_sel.in_hospital_cd_1 WHEN ''2'' THEN mpu_sel.in_hospital_cd_2 END,''''),
                NULLIF(CASE @hospCd12 WHEN ''1'' THEN mpu_def.in_hospital_cd_1 WHEN ''2'' THEN mpu_def.in_hospital_cd_2 END,''''),
                NULLIF(@appointmentslotCd,'''')
              )
            ))
          ELSE convert_from(substring((
            COALESCE(
              NULLIF(CASE @hospCd12 WHEN ''1'' THEN mpu_sel.in_hospital_cd_1 WHEN ''2'' THEN mpu_sel.in_hospital_cd_2 END,''''),
              NULLIF(CASE @hospCd12 WHEN ''1'' THEN mpu_def.in_hospital_cd_1 WHEN ''2'' THEN mpu_def.in_hospital_cd_2 END,''''),
              NULLIF(@appointmentslotCd,'''')
            )
          )::bytea from 1 for 4),''UTF8'')
        END,
        CASE
          WHEN COALESCE(@bedName::text,'''') = '''' THEN repeat('' '',40)
          WHEN OCTET_LENGTH(@bedName::text) > 40 THEN convert_from(substring((@bedName::text)::bytea from 1 for 40),''UTF8'')
          ELSE @bedName::text
        END
      )
  END AS reservation_code_comment,
  @appointmentDate::text AS appointment_date,
  @sequenceNo::text AS sequence_no
FROM (SELECT 1) dummy
LEFT JOIN selected_user su ON TRUE
LEFT JOIN default_user du ON TRUE
LEFT JOIN mst_personal_user mpu_sel ON mpu_sel.user_id::text = su.candidate_user_id
LEFT JOIN mst_personal_user mpu_def ON mpu_def.user_id::text = du.default_user_id;
-- SQL: -1104001 end', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム　再来受付', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1104000, "field_name": "bed_name", "replace_var": "@bedName"}, {"sql_cd": -1104000, "field_name": "appointment_date", "replace_var": "@appointmentDate"}, {"sql_cd": -1104000, "field_name": "sequence_no", "replace_var": "@sequenceNo"}, {"sql_cd": -1104004, "field_name": "charge_user_id_json", "replace_var": "@chargeUserIdJson"}, {"sql_cd": -1104004, "field_name": "hosp_cd_1_2", "replace_var": "@hospCd12"}, {"sql_cd": -1104004, "field_name": "default_appointment_slot_code", "replace_var": "@appointmentslotCd"}]'::jsonb);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1104004, '-- SQL: -1104004 begin
WITH staff_candidates AS (
  SELECT (elem ->> ''staff_cd'')::int AS staff_cd,
         (elem ->> ''disp_order'')::int AS disp_order
  FROM pat_main
  CROSS JOIN LATERAL jsonb_array_elements(charge_staff_info) AS elem
  WHERE pat_id = @patId
    AND elem ->> ''is_main'' = ''1''
  ORDER BY (elem ->> ''disp_order'')::int ASC
  LIMIT 2
)
,ranked_staff AS (
  SELECT staff_cd FROM staff_candidates ORDER BY disp_order ASC LIMIT 1 OFFSET 0
)
,fallback_staff AS (
  SELECT staff_cd FROM staff_candidates ORDER BY disp_order ASC LIMIT 1 OFFSET 1
)
,ini AS (
  SELECT COALESCE(NULLIF(info ->> ''value'',''''), NULLIF(info ->> ''default_v'',''''), '''') AS default_staff_cd
  FROM MST_COOP_INI ini
  CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE ini.FACILITY_CD = @facilityCd
    AND ini.IS_DEL = ''0''
    AND info ->> ''key1'' = ''SCM_COMMON''
    AND info ->> ''key2'' = ''DEFAULT_DOCTOR''
)
,ini_appointment_slot_code AS (
  SELECT COALESCE(NULLIF(info ->> ''value'',''''), NULLIF(info ->> ''default_v'',''''), '''') AS default_appointment_slot_code
  FROM MST_COOP_INI ini
  CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE ini.FACILITY_CD = @facilityCd
    AND ini.IS_DEL = ''0''
    AND info ->> ''key1'' = ''SCM_COMMON''
    AND info ->> ''key2'' = ''DEFAULT_APPOINTMENT_SLOT_CODE''
)
,ini_hosp_cd AS (
  SELECT COALESCE(NULLIF(info ->> ''value'',''''), NULLIF(info ->> ''default_v'',''''), '''') AS hosp_cd_1_2
  FROM MST_COOP_INI ini
  CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE ini.FACILITY_CD = @facilityCd
    AND ini.IS_DEL = ''0''
    AND info ->> ''key1'' = ''SCM_COMMON''
    AND info ->> ''key2'' = ''IN_HOSP_CD''
)
,selected_staff AS (
  SELECT COALESCE(
           (SELECT staff_cd::text FROM ranked_staff),
           (SELECT staff_cd::text FROM fallback_staff),
           (SELECT default_staff_cd FROM ini)
         ) AS reserved_by_user_id
)
,user_auth_list AS (
  SELECT (auth_elem ->> ''user_id'')::int AS user_id,
         auth_elem ->> ''disp_user_id''      AS disp_user_id
  FROM jsonb_array_elements(@userList::jsonb) AS auth_elem
)
, ini_user AS (
  SELECT u.user_id::text AS ini_user_id
  FROM ini
  CROSS JOIN user_auth_list u
  WHERE u.disp_user_id = ini.default_staff_cd
  LIMIT 1
),
final AS (
  SELECT
    s.reserved_by_user_id::text AS reserved_by_user_id,
    -- 3つ目に「ini で指定された default_staff_cd を user_id に変換したもの」
    to_jsonb(ARRAY[
      r.staff_cd::text,
      f.staff_cd::text,
      (SELECT ini_user_id FROM ini_user)  -- 見つからなければ NULL
    ])::text AS charge_user_id_json,
    
    CASE
      WHEN LENGTH(COALESCE(u.disp_user_id, ini.default_staff_cd::text, ''      '')) >= 7
        THEN RIGHT(COALESCE(u.disp_user_id, ini.default_staff_cd::text, ''      ''), 6)
      ELSE LPAD(COALESCE(u.disp_user_id, ini.default_staff_cd::text, ''      ''), 6, '' '')
    END AS disp_user_id,
    u.disp_user_id AS raw_disp_user_id,
    hosp_cd_1_2,
    default_appointment_slot_code
  FROM selected_staff s
  LEFT JOIN user_auth_list u ON s.reserved_by_user_id::text = u.user_id::text
  LEFT JOIN ranked_staff r ON TRUE
  LEFT JOIN fallback_staff f ON TRUE
  LEFT JOIN ini ON TRUE
  LEFT JOIN ini_hosp_Cd ON TRUE
  LEFT join ini_appointment_slot_code ON TRUE
)
SELECT * FROM final;
-- SQL: -1104004 end', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'セコム連携 予約担当ユーザーID取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1100003, "field_name": "user_list", "replace_var": "@userList"}]'::jsonb);
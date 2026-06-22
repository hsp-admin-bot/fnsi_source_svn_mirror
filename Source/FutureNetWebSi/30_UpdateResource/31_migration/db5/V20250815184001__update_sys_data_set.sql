DELETE FROM sys_data_set WHERE sql_cd IN 
(-1104001);

INSERT INTO sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-1104001, '-- SQL: -1104001 begin
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
  CONCAT(
    CASE
      WHEN COALESCE(
        NULLIF(CASE @hospCd12 WHEN ''1'' THEN mpu_sel.in_hospital_cd_1 WHEN ''2'' THEN mpu_sel.in_hospital_cd_2 END,''''),
        NULLIF(CASE @hospCd12 WHEN ''1'' THEN mpu_def.in_hospital_cd_1 WHEN ''2'' THEN mpu_def.in_hospital_cd_2 END,'''')
      ) IS NULL THEN repeat('' '',4)
      WHEN OCTET_LENGTH(
        COALESCE(
          NULLIF(CASE @hospCd12 WHEN ''1'' THEN mpu_sel.in_hospital_cd_1 WHEN ''2'' THEN mpu_sel.in_hospital_cd_2 END,''''),
          NULLIF(CASE @hospCd12 WHEN ''1'' THEN mpu_def.in_hospital_cd_1 WHEN ''2'' THEN mpu_def.in_hospital_cd_2 END,'''')
        )
      ) <= 4 THEN
        COALESCE(
          NULLIF(CASE @hospCd12 WHEN ''1'' THEN mpu_sel.in_hospital_cd_1 WHEN ''2'' THEN mpu_sel.in_hospital_cd_2 END,''''),
          NULLIF(CASE @hospCd12 WHEN ''1'' THEN mpu_def.in_hospital_cd_1 WHEN ''2'' THEN mpu_def.in_hospital_cd_2 END,'''')
        ) || repeat('' '', 4 - OCTET_LENGTH(
          COALESCE(
            NULLIF(CASE @hospCd12 WHEN ''1'' THEN mpu_sel.in_hospital_cd_1 WHEN ''2'' THEN mpu_sel.in_hospital_cd_2 END,''''),
            NULLIF(CASE @hospCd12 WHEN ''1'' THEN mpu_def.in_hospital_cd_1 WHEN ''2'' THEN mpu_def.in_hospital_cd_2 END,'''')
          )
        ))
      ELSE convert_from(substring((
        COALESCE(
          NULLIF(CASE @hospCd12 WHEN ''1'' THEN mpu_sel.in_hospital_cd_1 WHEN ''2'' THEN mpu_sel.in_hospital_cd_2 END,''''),
          NULLIF(CASE @hospCd12 WHEN ''1'' THEN mpu_def.in_hospital_cd_1 WHEN ''2'' THEN mpu_def.in_hospital_cd_2 END,'''')
        )
      )::bytea from 1 for 4),''UTF8'')
    END,
    CASE
      WHEN COALESCE(@bedName::text,'''') = '''' THEN repeat('' '',40)
      WHEN OCTET_LENGTH(@bedName::text) > 40 THEN convert_from(substring((@bedName::text)::bytea from 1 for 40),''UTF8'')
      ELSE @bedName::text
    END
  ) AS reservation_code_comment,
  @appointmentDate::text AS appointment_date,
  @sequenceNo::text AS sequence_no
FROM (SELECT 1) dummy
LEFT JOIN selected_user su ON TRUE
LEFT JOIN default_user du ON TRUE
LEFT JOIN mst_personal_user mpu_sel ON mpu_sel.user_id::text = su.candidate_user_id
LEFT JOIN mst_personal_user mpu_def ON mpu_def.user_id::text = du.default_user_id;
-- SQL: -1104001 end', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム　再来受付', '2025-05-20 10:20:41.403', '2025-08-15 12:45:09.266', '[{"sql_cd": -1104000, "field_name": "bed_name", "replace_var": "@bedName"}, {"sql_cd": -1104000, "field_name": "appointment_date", "replace_var": "@appointmentDate"}, {"sql_cd": -1104000, "field_name": "sequence_no", "replace_var": "@sequenceNo"}, {"sql_cd": -1104004, "field_name": "charge_user_id_json", "replace_var": "@chargeUserIdJson"}, {"sql_cd": -1104004, "field_name": "hosp_cd_1_2", "replace_var": "@hospCd12"}]'::jsonb);
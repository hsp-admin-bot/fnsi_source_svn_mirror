DELETE FROM sys_data_set WHERE sql_cd IN 
(-1104001);

INSERT INTO sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-1104001, '-- SQL: -1104001 begin
WITH expanded_candidates AS (
  -- JSON配列を展開して優先順位付きスタッフIDリストを得る
  SELECT
    value::text AS candidate_user_id,
    ordinality AS priority
  FROM jsonb_array_elements_text(@chargeUserIdJson::jsonb) WITH ORDINALITY
)
,ranked_user_id AS (
  -- 最初ユーザーIDが取れた行を1件だけhosp_cdに変換する
  SELECT *
  FROM expanded_candidates
  WHERE candidate_user_id IS NOT NULL
  ORDER BY priority ASC
  LIMIT 1
)
,final AS (
	SELECT CONCAT(
	  CASE WHEN (CASE @hospCd12 WHEN ''1'' THEN mpu.in_hospital_cd_1 WHEN ''2'' THEN mpu.in_hospital_cd_2 END) IS NULL THEN repeat('' '', 4)
	       WHEN OCTET_LENGTH(CASE @hospCd12 WHEN ''1'' THEN mpu.in_hospital_cd_1 WHEN ''2'' THEN mpu.in_hospital_cd_2 END) <= 4
	         THEN (CASE @hospCd12 WHEN ''1'' THEN mpu.in_hospital_cd_1 WHEN ''2'' THEN mpu.in_hospital_cd_2 END) || repeat('' '', 4 - OCTET_LENGTH(CASE @hospCd12 WHEN ''1'' THEN mpu.in_hospital_cd_1 WHEN ''2'' THEN mpu.in_hospital_cd_2 END))
	       ELSE convert_from(substring((CASE @hospCd12 WHEN ''1'' THEN mpu.in_hospital_cd_1 WHEN ''2'' THEN mpu.in_hospital_cd_2 END)::bytea from 1 for 4), ''UTF8'')
	  END,
	  CASE WHEN COALESCE(@bedName::text, '''') = '''' THEN repeat('' '', 40)
	       WHEN OCTET_LENGTH(@bedName::text) <= 40 THEN @bedName::text || repeat('' '', 40 - OCTET_LENGTH(@bedName::text))
	       ELSE convert_from(substring((@bedName::text)::bytea from 1 for 40), ''UTF8'')
	  END
	) AS reservation_code_comment,
	@appointmentDate::text AS appointment_date,
	@sequenceNo::text AS sequence_no
	FROM ranked_user_id r
	LEFT JOIN mst_personal_user mpu ON mpu.user_id::text = r.candidate_user_id
	RIGHT JOIN (SELECT 1) dummy ON TRUE
)

SELECT * FROM final;
-- SQL: -1104001 end', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム　再来受付', '2025-05-20 10:20:41.403', CURRENT_TIMESTAMP, '[{"sql_cd": -1104000, "field_name": "bed_name", "replace_var": "@bedName"}, {"sql_cd": -1104000, "field_name": "appointment_date", "replace_var": "@appointmentDate"}, {"sql_cd": -1104000, "field_name": "sequence_no", "replace_var": "@sequenceNo"}, {"sql_cd": -1104004, "field_name": "charge_user_id_json", "replace_var": "@chargeUserIdJson"}]'::jsonb);
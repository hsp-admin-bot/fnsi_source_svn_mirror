DELETE FROM sys_data_set WHERE sql_cd IN 
(-1104001,-1104004);

INSERT INTO sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-1104004, '-- SQL: -1104004 begin
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
    hosp_cd_1_2
  FROM selected_staff s
  LEFT JOIN user_auth_list u ON s.reserved_by_user_id::text = u.user_id::text
  LEFT JOIN ranked_staff r ON TRUE
  LEFT JOIN fallback_staff f ON TRUE
  LEFT JOIN ini ON TRUE
  LEFT JOIN ini_hosp_Cd ON TRUE
)
SELECT * FROM final;
-- SQL: -1104004 end', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'セコム連携 予約担当ユーザーID取得', '2020-07-31 18:29:49.000', CURRENT_TIMESTAMP, '[{"sql_cd": -1100003, "field_name": "user_list", "replace_var": "@userList"}]'::jsonb);
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
-- SQL: -1104001 end', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム　再来受付', '2025-05-20 10:20:41.403', CURRENT_TIMESTAMP, '[{"sql_cd": -1104000, "field_name": "bed_name", "replace_var": "@bedName"}, {"sql_cd": -1104000, "field_name": "appointment_date", "replace_var": "@appointmentDate"}, {"sql_cd": -1104000, "field_name": "sequence_no", "replace_var": "@sequenceNo"}, {"sql_cd": -1104004, "field_name": "charge_user_id_json", "replace_var": "@chargeUserIdJson"}, {"sql_cd": -1104004, "field_name": "hosp_cd_1_2", "replace_var": "@hospCd12"}]'::jsonb);
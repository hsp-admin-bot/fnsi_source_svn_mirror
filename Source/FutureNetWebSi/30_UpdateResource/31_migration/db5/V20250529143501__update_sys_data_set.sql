DELETE FROM sys_data_set WHERE sql_cd IN (-1104004, -1104001);

INSERT INTO sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-1104004, 'WITH staff_candidates AS (
  SELECT 
    (elem ->> ''staff_cd'')::int AS staff_cd,
    (elem ->> ''disp_order'')::int AS disp_order
  FROM pat_main
  CROSS JOIN LATERAL jsonb_array_elements(charge_staff_info) AS elem
  WHERE pat_id = @patId
    AND elem ->> ''is_main'' = ''1''
  ORDER BY (elem ->> ''disp_order'')::int ASC
  LIMIT 2
),

ranked_staff AS (
  SELECT staff_cd FROM staff_candidates ORDER BY disp_order ASC LIMIT 1 OFFSET 0
),

fallback_staff AS (
  SELECT staff_cd FROM staff_candidates ORDER BY disp_order ASC LIMIT 1 OFFSET 1
),

ini AS (
  SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), NULLIF(info ->> ''default_v'', ''''), '''') AS default_staff_cd
  FROM
    MST_COOP_INI ini
  CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    ini.FACILITY_CD = @facilityCd
    AND ini.IS_DEL = ''0''
    AND info ->> ''key1'' = ''DIALYSISSCHESEND''
    AND info ->> ''key2'' = ''DEFAULT_DOCTOR''
),

selected_staff AS (
  SELECT
    COALESCE(
      (SELECT staff_cd::text FROM ranked_staff),
      (SELECT staff_cd::text FROM fallback_staff),
      (SELECT default_staff_cd FROM ini)
    ) AS reserved_by_user_id
),

user_auth_list AS (
  SELECT
    (auth_elem ->> ''user_id'')::int AS user_id,
    auth_elem ->> ''disp_user_id'' AS disp_user_id
  FROM jsonb_array_elements(@userList::jsonb) AS auth_elem
),

final AS (
  SELECT
    s.reserved_by_user_id::text AS reserved_by_user_id,

    -- JSON配列としてFAX用スタッフ候補をまとめる
    to_jsonb(ARRAY[
	  r.staff_cd::text,
	  f.staff_cd::text,
	  ini.default_staff_cd
	])::text AS fax_user_id_json,
    CASE 
      WHEN LENGTH(COALESCE(u.disp_user_id, ini.default_staff_cd::text, ''      '')) >= 7 
        THEN RIGHT(COALESCE(u.disp_user_id, ini.default_staff_cd::text, ''      ''), 6)
      ELSE LPAD(COALESCE(u.disp_user_id, ini.default_staff_cd::text, ''      ''), 6, '' '')
    END AS disp_user_id,

    u.disp_user_id AS raw_disp_user_id

  FROM selected_staff s
  LEFT JOIN user_auth_list u ON s.reserved_by_user_id::text = u.user_id::text
  LEFT JOIN ranked_staff r ON TRUE
  LEFT JOIN fallback_staff f ON TRUE
  CROSS JOIN ini
)

SELECT * FROM final;
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'セコム連携 予約担当ユーザーID取得', '2020-07-31 18:29:49.000', '2020-07-31 18:29:49.000', '[{"sql_cd": -1100003, "field_name": "user_list", "replace_var": "@userList"}]'::jsonb);

INSERT INTO sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-1104001, 'WITH expanded_candidates AS (
  -- JSON配列を展開して優先順位付きスタッフIDリストを得る
  SELECT
    value::text AS candidate_user_id,
    ordinality AS priority
  FROM jsonb_array_elements_text(@faxUserIdJson::jsonb) WITH ORDINALITY
),

decoded_fax_candidates AS (
  -- 候補スタッフごとにFAX番号をデコード
  SELECT 
    e.candidate_user_id,
    (
      SELECT string_agg(
               chr((''x'' || substr(mpu.fax_no, gs, 2))::bit(8)::int / 2),
               ''''
             )
      FROM generate_series(1, length(mpu.fax_no), 2) AS gs
      WHERE mpu.fax_no IS NOT NULL
    ) AS decoded_fax_no,
    mpu.in_hospital_cd_1,
    e.priority
  FROM expanded_candidates e
  LEFT JOIN mst_personal_user mpu
    ON mpu.user_id::text = e.candidate_user_id
),

ranked_fax AS (
  -- 最初にFAX番号が取れた行を1件だけ残す
  SELECT *
  FROM decoded_fax_candidates
  WHERE decoded_fax_no IS NOT NULL
  ORDER BY priority ASC
  LIMIT 1
),

final AS (
  SELECT
    -- FAXが取れていればそのまま、取れなければ空白4文字
    CONCAT(
      CASE 
        WHEN r.decoded_fax_no IS NULL OR OCTET_LENGTH(r.decoded_fax_no) < 4 THEN RPAD(COALESCE(r.decoded_fax_no, ''''), 4, '' '')
        ELSE r.decoded_fax_no
      END,
      CASE 
        WHEN @bedName::text = '''' THEN RPAD('''', 40, '' '')
        ELSE @bedName::text
      END
    ) AS reservation_code_comment,

    @appointmentDate::text AS appointment_date,
    @sequenceNo::text AS sequence_no,
    r.in_hospital_cd_1

  FROM ranked_fax r
  RIGHT JOIN (SELECT 1) dummy ON TRUE
)

SELECT * FROM final;
', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム　再来受付', '2025-05-20 10:20:41.403', '2025-05-27 13:22:21.116', '[{"sql_cd": -1104000, "field_name": "bed_name", "replace_var": "@bedName"}, {"sql_cd": -1104000, "field_name": "appointment_date", "replace_var": "@appointmentDate"}, {"sql_cd": -1104000, "field_name": "sequence_no", "replace_var": "@sequenceNo"}, {"sql_cd": -1104004, "field_name": "reserved_by_user_id", "replace_var": "@reservedByUserId"}, {"sql_cd": -1104004, "field_name": "fax_user_id_json", "replace_var": "@faxUserIdJson"}]'::jsonb);
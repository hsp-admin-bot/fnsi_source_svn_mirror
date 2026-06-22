DELETE FROM sys_data_set WHERE sql_cd IN 
(-1104001);

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
        WHEN r.decoded_fax_no IS NULL OR LENGTH(r.decoded_fax_no) < 4 THEN 
          RPAD(COALESCE(r.decoded_fax_no, ''''), 4, '' '')
        ELSE 
          SUBSTRING(r.decoded_fax_no FROM 1 FOR 4)
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
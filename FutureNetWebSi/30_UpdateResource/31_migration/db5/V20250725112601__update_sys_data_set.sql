delete from ntss.sys_data_set
where sql_cd in (-1102028);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1102028, 'WITH get_json AS (
  SELECT *
  FROM (
    SELECT save_2
    FROM pat_coop_detail
    WHERE pat_id = @patId
      AND save_2->>''coop_cd'' = ''ind_dial''
    ORDER BY up_date DESC
    LIMIT 1
  ) AS sub,
  LATERAL jsonb_to_record(save_2) AS j(
    memo text,
    treatment_user_id text,
    treatment_send_day text,
    treatment_seq_no text,
    injection_user_id text,
    injection_send_day text,
    injection_seq_no text,
    medical_send_day text,
    medical_seq_no text
  )
)
, split_memo AS (
  SELECT
    *,
    string_to_array(split_part(memo, ''#'', 1), ''|'') AS r_array,
    string_to_array(regexp_replace(substring(memo FROM ''#K.*''), ''^#K'', ''K''), ''|'') AS k_array
  FROM get_json
)
SELECT
  r_array[3]  AS reservation_user_id,
  TO_CHAR(TO_DATE(r_array[4], ''YYYYMMDD''), ''YYYY-MM-DD'') AS reservation_send_day,
  TO_CHAR(TO_TIMESTAMP(r_array[5], ''HH24MISS''), ''HH24:MI:SS'') AS reservation_seq_no,

  treatment_user_id,
  TO_CHAR(TO_DATE(treatment_send_day, ''YYYYMMDD''), ''YYYY-MM-DD'') AS treatment_send_day,
  TO_CHAR(TO_TIMESTAMP(treatment_seq_no, ''HH24MISS''), ''HH24:MI:SS'') AS treatment_seq_no,

  injection_user_id,
  TO_CHAR(TO_DATE(injection_send_day, ''YYYYMMDD''), ''YYYY-MM-DD'') AS injection_send_day,
  TO_CHAR(TO_TIMESTAMP(injection_seq_no, ''HH24MISS''), ''HH24:MI:SS'') AS injection_seq_no,

  k_array[3] AS medical_user_id,
  TO_CHAR(TO_DATE(medical_send_day, ''YYYYMMDD''), ''YYYY-MM-DD'') AS medical_send_day,
  TO_CHAR(TO_TIMESTAMP(medical_seq_no, ''HH24MISS''), ''HH24:MI:SS'') AS medical_seq_no

FROM split_memo;
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '透析指示連携', '2025-07-24 11:30:41.435', CURRENT_TIMESTAMP, NULL);
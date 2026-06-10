SELECT
  MIN(
    CASE
      WHEN i.period_start_date IS NOT NULL THEN
        i.period_start_date
      WHEN i.period_start_year IS NOT NULL AND i.period_start_month IS NOT NULL AND i.period_start_day IS NOT NULL THEN
        TO_CHAR(TO_DATE(i.period_start_year || LPAD(i.period_start_month, 2, '0') || LPAD(i.period_start_day, 2, '0'), 'YYYYMMDD'), 'YYYYMMDD')
      WHEN i.period_start_year IS NOT NULL AND i.period_start_month IS NOT NULL THEN
        TO_CHAR(TO_DATE(i.period_start_year || LPAD(i.period_start_month, 2, '0') || '01', 'YYYYMMDD'), 'YYYYMMDD')
      ELSE NULL
    END
  ) AS period_start_date
FROM
  pat_unique u
  CROSS JOIN LATERAL jsonb_to_recordset(u.in_out_visit_history_info) AS i
  (
    period_start_date varchar,
    move_in_out varchar,
    period_start_year varchar,
    period_start_month varchar,
    period_start_day varchar
  )
WHERE
  u.pat_id = /*patId*/0
  AND u.is_del = '0'
  AND i.move_in_out = '1'
;
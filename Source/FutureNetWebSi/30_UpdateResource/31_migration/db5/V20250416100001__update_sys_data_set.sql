DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-310016);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-310016, 'WITH exam_data AS (
  SELECT
    TO_CHAR(reg_exam_date, ''YYYYMMDD'') AS exam_date,
    reg_order_class
  FROM
    ntss.pat_exam_main
  WHERE
    exam_main_cd = @ordNo::numeric
    AND facility_cd = @facilityCd
),
ord_data AS (
  SELECT
    1 AS exist
  FROM
    ord_main
  WHERE
    treat_date = (SELECT exam_date FROM exam_data)
    AND facility_cd = @facilityCd
    AND pat_id = @patId::numeric
    AND ind_kur_cd > 0
    AND is_del = ''0''
  LIMIT 1
),
journal AS (
  SELECT
    base_date
  FROM
    sys_coop_journal
  WHERE
    ctl_no = @ctlNo
),
pat_uni AS (
  SELECT 
    COUNT(*) AS cnt
  FROM
    pat_unique AS patu
    CROSS JOIN LATERAL json_array_elements(patu.in_out_visit_history_info::json) info
  WHERE
    patu.facility_cd = @facilityCd
    AND patu.pat_id = @patId::numeric
    AND patu.is_del = ''0''
    AND (
      info->>''move_in_out'' IN (''3'', ''11'')
      AND info->>''period_start'' <= (SELECT base_date FROM journal)
    )
)
SELECT 1
WHERE (SELECT cnt FROM pat_uni) = 0
  AND (
    (SELECT reg_order_class FROM exam_data) = ''0''
    OR (SELECT exist FROM ord_data) IS NOT NULL
  );
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom検査オーダ 連携判定', '2025-04-09 15:03:52.869', CURRENT_TIMESTAMP, NULL);
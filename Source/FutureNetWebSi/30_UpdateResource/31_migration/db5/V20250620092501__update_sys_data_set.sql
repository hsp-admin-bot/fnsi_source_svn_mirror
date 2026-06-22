DELETE FROM ntss.sys_data_set
WHERE sql_cd in (-1101504);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1101504, 'WITH base AS (
  SELECT
    pat_id,
    COALESCE(physical_info, ''[]''::jsonb) AS physical_info
  FROM pat_unique
  WHERE
    pat_id = @patId
    AND facility_cd = ''@facilityCd''
    AND is_del = ''0''
),
latest_obj AS (
  SELECT
    b.pat_id,
    ord,
    (elem->>''height'')::numeric AS height,
    (elem->>''exam_date'')::timestamp AS exam_date,
    ROW_NUMBER() OVER (PARTITION BY b.pat_id ORDER BY (elem->>''exam_date'')::timestamp DESC) AS rn
  FROM base b,
       jsonb_array_elements(b.physical_info) WITH ORDINALITY AS elem(elem, ord)
),
max_ctl AS (
  SELECT
    pat_id,
    MAX((e->>''ctl_no'')::int) AS max_ctl
  FROM base,
       jsonb_array_elements(physical_info) AS e
  GROUP BY pat_id
),
target AS (
  SELECT
    b.pat_id,
    COALESCE(lo.ord, 1) - 1 AS idx,
    COALESCE(m.max_ctl, -1) + 1 AS next_ctl_no,
    CASE
      WHEN lo.exam_date::date >= CURRENT_DATE THEN ''update''
      ELSE ''append''
    END AS action
  FROM base b
  LEFT JOIN latest_obj lo ON b.pat_id = lo.pat_id AND lo.rn = 1
  LEFT JOIN max_ctl m ON b.pat_id = m.pat_id
  WHERE lo.height IS DISTINCT FROM ''@content''
     OR lo.height IS NULL
)
UPDATE pat_unique
SET physical_info = CASE
  WHEN action = ''update'' THEN
    jsonb_set(
      jsonb_set(physical_info, ARRAY[idx::text, ''height''], to_jsonb(''@content''::text), false),
      ARRAY[idx::text, ''order_class''], to_jsonb(3), false
    )
  ELSE
     jsonb_build_array(
      jsonb_build_object(
        ''dw'',                   NULL,
        ''ctr'',                  NULL,
        ''memo'',                 NULL,
        ''ctl_no'',               next_ctl_no,
        ''height'',               ''@content'',
        ''chest_dia'',            NULL,
        ''exam_date'',            TO_CHAR(CURRENT_TIMESTAMP, ''YYYY-MM-DD''),
        ''breast_dia'',           NULL,
        ''ctr_weight'',           NULL,
        ''facility_cd'',          ''@facilityCd'',
        ''order_class'',          3,
        ''indicator_cd'',         NULL,
        ''inspect_date'',         NULL,
        ''target_weight'',        NULL,
        ''pre_scale_lower'',      NULL,
        ''pre_scale_upper'',      NULL,
        ''indicator_start_date'', NULL
      )
    ) || COALESCE(physical_info, ''[]''::jsonb)
END,
  up_date = CURRENT_TIMESTAMP
FROM target
WHERE pat_unique.pat_id = target.pat_id;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)セコム)患者プロファイル　身長更新', '2025-05-18 22:33:06.096', CURRENT_TIMESTAMP, NULL);
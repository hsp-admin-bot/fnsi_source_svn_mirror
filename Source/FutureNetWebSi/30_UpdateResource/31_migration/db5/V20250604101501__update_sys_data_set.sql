DELETE FROM ntss.sys_data_set
WHERE sql_cd in (-1101504);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1101504, 'WITH
  physical_elems AS (
    SELECT
      pu.pat_id,
      pu.facility_cd,
      pu.is_del,
      elem,
      (elem->>''ctl_no'')::INT    AS ctl_no,
      (elem->>''exam_date'')::DATE AS exam_dt
    FROM
      pat_unique pu
      CROSS JOIN LATERAL
        jsonb_array_elements(
          COALESCE(pu.physical_info::jsonb, ''[]''::jsonb)
        ) AS elem
    WHERE
      pu.pat_id         = @patId
      AND pu.facility_cd = ''@facilityCd''
      AND pu.is_del      = ''0''
  ),
  latest_elem AS (
    SELECT
      elem
    FROM
      physical_elems
    ORDER BY
      exam_dt DESC,
      ctl_no DESC
    LIMIT 1
  ),
  max_ctl AS (
    SELECT
      COALESCE(MAX(ctl_no), 0) AS max_ctl
    FROM
      physical_elems
  ),
  new_elem AS (
    SELECT
      jsonb_build_object(
        ''dw'',                   NULL,
        ''ctr'',                  NULL,
        ''memo'',                 NULL,
        ''ctl_no'',               mc.max_ctl + 1,
        ''height'',               @content,
        ''chest_dia'',            NULL,
        ''exam_date'',            TO_CHAR(CURRENT_TIMESTAMP, ''YYYY-MM-DD''),
        ''breast_dia'',           NULL,
        ''ctr_weight'',           NULL,
        ''facility_cd'',          ''@facilityCd'',
        ''order_class'',          2,
        ''indicator_cd'',         NULL,
        ''inspect_date'',         NULL,
        ''target_weight'',        NULL,
        ''pre_scale_lower'',      NULL,
        ''pre_scale_upper'',      NULL,
        ''indicator_start_date'', NULL
      ) AS elem
    FROM
      max_ctl mc
  ),
  new_array AS (
    SELECT
      jsonb_build_array(ne.elem) AS arr
    FROM
      new_elem ne 
  )
UPDATE
  pat_unique pu
SET
  physical_info = (
    CASE
      WHEN pu.physical_info IS NULL
        OR jsonb_array_length(COALESCE(pu.physical_info::jsonb, ''[]''::jsonb)) = 0
      THEN
        na.arr
      ELSE
        COALESCE(pu.physical_info::jsonb, ''[]''::jsonb) || na.arr
    END
  )::json,
  up_date = CURRENT_TIMESTAMP
FROM
  new_array na
  LEFT JOIN latest_elem le ON 1=1
WHERE
  pu.pat_id         = @patId
  AND pu.facility_cd = ''@facilityCd''
  AND pu.is_del      = ''0''
  AND (
    pu.physical_info IS NULL
    OR jsonb_array_length(COALESCE(pu.physical_info::jsonb, ''[]''::jsonb)) = 0
    OR (le.elem IS NOT NULL AND (le.elem->>''height'')::NUMERIC <> @content::NUMERIC)
  )
;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)セコム)患者プロファイル　身長更新', '2025-05-18 22:33:06.096', '2025-05-18 22:33:06.096', NULL);
DELETE FROM ntss.sys_data_set
WHERE sql_cd in (-500090);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500090, 'WITH
orig AS (
  SELECT
    COALESCE(physical_info, ''[]''::jsonb) AS arr
  FROM ntss.pat_unique
  WHERE
    pat_id       = @patId
    AND is_del     = ''0''
    AND facility_cd = ''@facilityCd''
),
elems AS (
  SELECT
    arr,
    elem
  FROM orig
  CROSS JOIN LATERAL jsonb_array_elements(arr) AS elem
),
max_ctl AS (
  SELECT
    COALESCE(MAX((elem->>''ctl_no'')::int), 0) AS max_ctl
  FROM elems
),
params AS (
  SELECT
    substr(''@treatDate'',1,4) || ''-'' ||
    substr(''@treatDate'',5,2) || ''-'' ||
    substr(''@treatDate'',7,2) AS hyphen_date,
    ''@treatDate'' AS ymd
),
new_elem AS (
  SELECT jsonb_build_object(
    ''dw'',                    ''@dw'',
    ''ctr'',                   ''@ctr'',
    ''memo'',                  NULL,
    ''ctl_no'',                (SELECT max_ctl + 1 FROM max_ctl),
    ''height'',                NULL,
    ''chest_dia'',             NULL,
    ''exam_date'',             (SELECT hyphen_date FROM params),
    ''breast_dia'',            NULL,
    ''changer_cd'',            NULL,
    ''ctr_weight'',            NULL,
    ''facility_cd'',           ''@facilityCd'',
    ''order_class'',           NULL,
    ''indicator_cd'',          NULL,
    ''inspect_date'',          (SELECT ymd FROM params),
    ''target_weight'',         NULL,
    ''pre_scale_lower'',       NULL,
    ''pre_scale_upper'',       NULL,
    ''indicator_start_date'',  (SELECT ymd FROM params)
  ) AS elem
),
new_arr AS (
  SELECT
    CASE
      WHEN EXISTS (
        SELECT 1
        FROM elems
        JOIN params ON elems.elem->>''exam_date'' = params.hyphen_date
      )
      THEN (
        SELECT jsonb_agg(
          CASE
            WHEN e.elem->>''exam_date'' = p.hyphen_date
            THEN 
              e.elem || jsonb_build_object(
                ''dw'',  ''@dw'',
                ''ctr'', ''@ctr''
              )
            ELSE e.elem
          END
        )
        FROM elems AS e
        CROSS JOIN params  AS p
      )
      ELSE (
        SELECT arr || jsonb_build_array(n.elem)
        FROM orig
        CROSS JOIN new_elem AS n
      )
    END AS arr
)
UPDATE ntss.pat_unique AS t
SET physical_info = na.arr
FROM new_arr AS na
WHERE
  t.pat_id       = @patId
  AND t.is_del     = ''0''
  AND t.facility_cd = ''@facilityCd'';
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのオーダ受け(DW,CRTの更新)', '2025-05-31 01:28:31.821', '2025-05-31 01:28:41.720', NULL);
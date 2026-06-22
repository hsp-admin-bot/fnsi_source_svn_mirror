DELETE FROM ntss.sys_data_set
WHERE sql_cd in (-310006);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-310006, 'WITH exam_data AS(
  SELECT
    TO_CHAR(reg_exam_date, ''YYYYMMDD'') AS exam_date,
    CASE reg_order_class
      WHEN ''0'' THEN '' ''
      ELSE reg_order_class
    END AS exam_timing,
    exam_set_info ->> ''set_cd'' AS exam_set_cd,
    pat_id
  FROM
    ntss.pat_exam_main
    CROSS JOIN
      LATERAL json_array_elements(
        pat_exam_main.order_exam_set_info::json
      ) exam_set_info
  WHERE
    exam_main_cd = @ordNo
  limit 1
),
exam_set_data AS(
  SELECT
    other_exam_time
  FROM
    mst_exam_set
  WHERE
    exam_set_cd = (
      SELECT
        exam_set_cd
      FROM
        exam_data
    )::int
),
ord_data AS(
  SELECT
    ord_main.ind_treat_start_time,
    ord_main.ind_cond_info,
    ord_main.ind_bed_cd
  FROM
    ord_main
  WHERE
    pat_id = (
      SELECT
        pat_id
      FROM
        exam_data
    )
  AND treat_date = (
      SELECT
        exam_date
      FROM
        exam_data
    )
  AND ind_kur_cd > 0
  AND ord_main.is_del = ''0''
  ORDER BY
    ind_treat_start_time ASC
  LIMIT 1
),
before_margin AS(
  SELECT
    COALESCE(
      NULLIF(
        info ->> ''value'',
        ''''
      ),
      info ->> ''default_v''
    ) AS value
  FROM
    mst_coop_ini AS ini
    CROSS JOIN
      LATERAL json_array_elements(
        ini.coop_ini_info::json
      ) info
  WHERE
    facility_cd = @facilityCd
  AND is_del = ''0''
  AND info ->> ''key0'' = ''MED''
  AND info ->> ''key1'' = ''EXAM_ORD''
  AND info ->> ''key2'' = ''BEFORE_MARGIN''
),
after_margin AS(
  SELECT
    COALESCE(
      NULLIF(
        info ->> ''value'',
        ''''
      ),
      info ->> ''default_v''
    ) AS value
  FROM
    mst_coop_ini AS ini
    CROSS JOIN
      LATERAL json_array_elements(
        ini.coop_ini_info::json
      ) info
  WHERE
    facility_cd = @facilityCd
  AND is_del = ''0''
  AND info ->> ''key0'' = ''MED''
  AND info ->> ''key1'' = ''EXAM_ORD''
  AND info ->> ''key2'' = ''AFTER_MARGIN''
),
output_bed_no AS(
  SELECT
    COALESCE(
      NULLIF(
        info ->> ''value'',
        ''''
      ),
      info ->> ''default_v''
    ) AS value
  FROM
    mst_coop_ini AS ini
    CROSS JOIN
      LATERAL json_array_elements(
        ini.coop_ini_info::json
      ) info
  WHERE
    facility_cd = @facilityCd
  AND is_del = ''0''
  AND info ->> ''key0'' = ''MED''
  AND info ->> ''key1'' = ''EXAM_ORD''
  AND info ->> ''key2'' = ''OUTPUT_BED_NO''
)
SELECT
  exam_date,
  exam_timing,
  CASE exam_timing
    WHEN ''1'' THEN to_char((
        ind_treat_start_time::time - ((
            SELECT
              value
            FROM
              before_margin
          ) || '' minutes'')::interval
      ), ''HH24MI'')
    WHEN ''2'' THEN to_char((
        ind_treat_start_time::time + (
          ind_cond_info -> ''1'' ->> ''value'' || '' minutes''
        )::interval + ((
            SELECT
              value
            FROM
              after_margin
          ) || '' minutes'')::interval
      ), ''HH24MI'')
    ELSE(
      SELECT
        other_exam_time
      FROM
        exam_set_data
    )
  END AS exam_time,
  CASE(
      SELECT
        value
      FROM
        output_bed_no
    )
    WHEN ''1'' THEN
        ord_data.ind_bed_cd::text
    ELSE ''    ''
  END AS bed_cd
FROM
  exam_data,
  ord_data', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'Medicom', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
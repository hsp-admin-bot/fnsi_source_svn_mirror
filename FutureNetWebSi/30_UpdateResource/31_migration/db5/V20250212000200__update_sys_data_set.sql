DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (236, 237);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (236, 'WITH mst_treat AS (
  SELECT
    treatment_cd
  FROM
    mst_treatment mt
  WHERE
    mt.facility_cd = @facilityCd
    AND mt.is_del = ''0''
    AND mt.device_mode <> ''9''
),
rst_dial_cnt AS (
  SELECT 
    ord_no AS p_no,
    treatment_cd,
    treat_date,
    TO_CHAR(treat_date::DATE, ''YYYY-MM'') AS treat_month,
    COALESCE(
        SUM(CASE WHEN rst_dialysis_state = ''6'' AND treatment_cd is not null THEN COUNT(treat_date) ELSE 0 END) 
        OVER (PARTITION BY TO_CHAR(treat_date::DATE, ''YYYY-MM'') ORDER BY treat_date), 
        0
    ) AS rst_dialysis_cnt
  FROM
    ord_main m
  LEFT JOIN
    mst_treat mt ON mt.treatment_cd = m.rst_treatment_cd
  WHERE
    facility_cd = @facilityCd
    AND pat_id = @patId
    AND treat_date BETWEEN to_char(date_trunc(''month'', CAST(@fromDate AS TIMESTAMP)), ''YYYYMMDD'') 
    AND TO_CHAR((date_trunc(''month'', CAST(@toDate AS TIMESTAMP)) + INTERVAL ''1 month'' - INTERVAL ''1 day''), ''YYYYMMDD'')
    AND m.is_del = ''0''
  GROUP BY
    treat_month,
    p_no,
    treatment_cd
)

SELECT
  om.ord_no,
  om.treat_date,
  rdc.treat_month, 
  rdc.rst_dialysis_cnt
FROM
  ord_main om
  LEFT JOIN rst_dial_cnt rdc ON om.ord_no = rdc.p_no
WHERE
  om.ord_no = @ordNo
  AND om.pat_id = @patId
  AND om.facility_cd = @facilityCd
  AND om.is_del = ''0''
  AND om.rst_dialysis_state > ''0''
ORDER BY
  treat_date
', 2, '[{"preview": "3", "can_calc": "0", "data_code": "rst_dialysis_cnt", "data_name": "月内確定済透析回数", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_dialysis_cnt", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：実績情報 @ordNo 使用', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (237, 'WITH mst_treat AS (
  SELECT
    treatment_cd
  FROM
    mst_treatment mt
  WHERE
    mt.facility_cd = @facilityCd
    AND mt.is_del = ''0''
    AND mt.device_mode <> ''9''
),
rst_dial_cnt AS (
  SELECT 
    ord_no AS p_no,
    treatment_cd,
    treat_date,
    TO_CHAR(treat_date::DATE, ''YYYY-MM'') AS treat_month,
    COALESCE(
        SUM(CASE WHEN rst_dialysis_state = ''6'' AND treatment_cd is not null THEN COUNT(treat_date) ELSE 0 END) 
        OVER (PARTITION BY TO_CHAR(treat_date::DATE, ''YYYY-MM'') ORDER BY treat_date), 
        0
    ) AS rst_dialysis_cnt
  FROM
    ord_main m
  LEFT JOIN
    mst_treat mt ON mt.treatment_cd = m.rst_treatment_cd
  WHERE
    facility_cd = @facilityCd
    AND pat_id = @patId
    AND treat_date BETWEEN to_char(date_trunc(''month'', CAST(@fromDate AS TIMESTAMP)), ''YYYYMMDD'') 
    AND TO_CHAR((date_trunc(''month'', CAST(@toDate AS TIMESTAMP)) + INTERVAL ''1 month'' - INTERVAL ''1 day''), ''YYYYMMDD'')
    AND m.is_del = ''0''
  GROUP BY
    treat_month,
    p_no,
    treatment_cd
)

SELECT
  om.ord_no,
  om.treat_date,
  rdc.treat_month, 
  rdc.rst_dialysis_cnt
FROM
  ord_main om
  LEFT JOIN rst_dial_cnt rdc ON om.ord_no = rdc.p_no
WHERE
  om.ord_no = @ordNo
  AND om.pat_id = @patId
  AND om.facility_cd = @facilityCd
  AND om.is_del = ''0''
  AND om.rst_dialysis_state > ''0''
  AND om.rst_dialysis_state < ''6''
ORDER BY
  treat_date
', 2, '[{"preview": "3", "can_calc": "0", "data_code": "rst_dialysis_cnt", "data_name": "月内確定済透析回数", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_dialysis_cnt", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [3]}', '実績（治療中）：実績情報 @ordNo 使用', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

DELETE FROM sys_data_set WHERE sql_cd IN 
(-1107054,-1107055);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1107055, 'WITH log_info AS (
    SELECT 
        @logTreatmentStartDate AS treatment_start_date,
        @logTreatmentEndDate AS treatment_end_date,
        @logTreatmentWeekday AS treatment_weekday,
        string_to_array(@logTreatmentWeekday, '','') AS weekday_array
),
log_info_with_dow AS (
    SELECT
        treatment_start_date,
        treatment_end_date,
        treatment_weekday,
        ARRAY(
            SELECT 
                CASE TRIM(w)
                    WHEN ''日'' THEN 0
                    WHEN ''月'' THEN 1
                    WHEN ''火'' THEN 2
                    WHEN ''水'' THEN 3
                    WHEN ''木'' THEN 4
                    WHEN ''金'' THEN 5
                    WHEN ''土'' THEN 6
                END
            FROM unnest(weekday_array) AS w
        ) AS weekday_numbers
    FROM log_info
),
target_ord_no AS (
    SELECT 
        ord_main.ord_no,
      ROW_NUMBER() OVER (ORDER BY TO_DATE(LPAD(ord_main.treat_date::text, 8, ''0''), ''YYYYMMDD'') ASC) AS rn
    FROM 
        ord_main
    JOIN 
        log_info_with_dow ON TRUE
    WHERE 
        ord_main.facility_cd = @facilityCd
        AND ord_main.pat_id = @patId
        AND ord_main.treat_date >= log_info_with_dow.treatment_start_date
        AND ord_main.treat_date <= log_info_with_dow.treatment_end_date
        AND EXTRACT(DOW FROM TO_DATE(ord_main.treat_date, ''YYYYMMDD'')) = ANY (log_info_with_dow.weekday_numbers)
)
SELECT 
    ord_main.ord_no
FROM 
    ord_main
INNER JOIN 
    target_ord_no ON ord_main.ord_no = target_ord_no.ord_no
WHERE
	  ord_main.ord_no = @ordNo
    AND target_ord_no.rn = 1;', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{}'::jsonb, 'セコム　指示変更履歴 実施対象取得', '2025-03-26 21:13:57.360', '2025-05-27 13:22:16.287', '[{"sql_cd": -1107054, "field_name": "treatment_start_date", "replace_var": "@logTreatmentStartDate"}, {"sql_cd": -1107054, "field_name": "treatment_end_date", "replace_var": "@logTreatmentEndDate"}, {"sql_cd": -1107054, "field_name": "treatment_weekday", "replace_var": "@logTreatmentWeekday"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1107054, '{
  "collection": "ind_history",
  "eq": {
    "pat_id": "@patId",
    "facility_cd": "@facilityCd"
  },
  "sort": {
    "log_date": "desc"
  },
  "slice": {
    "log_date": 1
  }
}', 4, '[]'::jsonb, '0', '{"applications": [5]}'::jsonb, '{}'::jsonb, 'セコム　指示変更履歴 最新ログ取得', '2020-07-31 18:29:49.000', '2020-07-31 18:29:49.000', NULL);

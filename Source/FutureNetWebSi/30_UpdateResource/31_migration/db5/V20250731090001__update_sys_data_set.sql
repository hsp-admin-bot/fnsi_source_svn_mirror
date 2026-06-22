delete from ntss.sys_data_set
where sql_cd in (-1107056,-1107055);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1107056, 'WITH log_info AS (
    SELECT 
        @logTreatmentStartDate AS treatment_start_date,
        CASE 
            WHEN @logTreatmentEndDate = ''logTreatmentEndDate'' THEN ''''
            ELSE @logTreatmentEndDate
        END AS treatment_end_date,
        @logTreatmentWeekday AS treatment_weekday,
        string_to_array(@logTreatmentWeekday, '','') AS weekday_array,
        @logContent AS log_content
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
        ) AS weekday_numbers,
        log_content
    FROM log_info
),
target_del_date AS (
    SELECT 
        ord_main_restore.del_date
    FROM 
        ord_main_restore
    JOIN 
        log_info_with_dow ON TRUE
    WHERE 
        ord_main_restore.facility_cd = @facilityCd
        AND ord_main_restore.pat_id = @patId
        AND ord_main_restore.treat_date >= (CASE WHEN log_info_with_dow.treatment_start_date is null or log_info_with_dow.treatment_start_date = '''' THEN ord_main_restore.treat_date ELSE log_info_with_dow.treatment_start_date END)
        AND ord_main_restore.treat_date <= (CASE WHEN log_info_with_dow.treatment_end_date is null or log_info_with_dow.treatment_end_date = '''' THEN ord_main_restore.treat_date ELSE log_info_with_dow.treatment_end_date END)
        AND (
            log_info_with_dow.treatment_weekday = ''''
            OR EXTRACT(DOW FROM TO_DATE(ord_main_restore.treat_date, ''YYYYMMDD''))
               = ANY (log_info_with_dow.weekday_numbers)
        )
    ORDER BY ord_main_restore.del_date DESC
    LIMIT 1
),
target_ord_no_restore AS (
    SELECT 
        ord_main_restore.ord_no,
        ord_main_restore.del_date,
        ROW_NUMBER() OVER (ORDER BY TO_DATE(LPAD(ord_main_restore.treat_date::text, 8, ''0''), ''YYYYMMDD'') ASC) AS rn
    FROM 
        ord_main_restore
    JOIN 
        log_info_with_dow ON TRUE
    WHERE 
        ord_main_restore.facility_cd = @facilityCd
        AND ord_main_restore.pat_id = @patId
        AND ord_main_restore.del_date = (SELECT del_date FROM target_del_date)

)

SELECT 
    ord_main_restore.ord_no
FROM 
    ord_main_restore
INNER JOIN 
    target_ord_no_restore ON ord_main_restore.ord_no = target_ord_no_restore.ord_no
    AND ord_main_restore.del_date = target_ord_no_restore.del_date
JOIN 
    log_info_with_dow ON TRUE
WHERE
    target_ord_no_restore.ord_no = @ordNo
    AND target_ord_no_restore.rn = 1
    AND NOT EXISTS (
            SELECT 1
            FROM regexp_matches(
                log_info_with_dow.log_content,
                ''(月→火|月→水|月→木|月→金|月→土|月→日|火→月|火→水|火→木|火→金|火→土|火→日|水→月|水→火|水→木|水→金|水→土|水→日|木→月|木→火|木→水|木→金|木→土|木→日|金→月|金→火|金→水|金→木|金→土|金→日|土→月|土→火|土→水|土→木|土→金|土→日|日→月|日→火|日→水|日→木|日→金|日→土)'',
                ''g''
            )
        )
UNION ALL
SELECT 
    ord_main.ord_no
FROM 
    ord_main
JOIN 
    log_info_with_dow ON TRUE
WHERE
    ord_main.ord_no = @ordNo
    AND NOT EXISTS (
            SELECT 1
            FROM regexp_matches(
                log_info_with_dow.log_content,
                ''(月→火|月→水|月→木|月→金|月→土|月→日|火→月|火→水|火→木|火→金|火→土|火→日|水→月|水→火|水→木|水→金|水→土|水→日|木→月|木→火|木→水|木→金|木→土|木→日|金→月|金→火|金→水|金→木|金→土|金→日|土→月|土→火|土→水|土→木|土→金|土→日|日→月|日→火|日→水|日→木|日→金|日→土)'',
                ''g''
            )
        )', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{}'::jsonb, 'セコム　指示変更履歴 実施対象取得', '2025-03-26 21:13:57.360', '2025-05-27 13:22:16.287', '[{"sql_cd": -1107054, "field_name": "treatment_start_date", "replace_var": "@logTreatmentStartDate"}, {"sql_cd": -1107054, "field_name": "treatment_end_date", "replace_var": "logTreatmentEndDate"}, {"sql_cd": -1107054, "field_name": "treatment_weekday", "replace_var": "@logTreatmentWeekday"}, {"sql_cd": -1107054, "field_name": "log_content", "replace_var": "@logContent"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1107055, 'WITH log_info AS (
    SELECT 
        @logTreatmentStartDate AS treatment_start_date,
        CASE 
            WHEN @logTreatmentEndDate = ''logTreatmentEndDate'' THEN ''''
            ELSE @logTreatmentEndDate
        END AS treatment_end_date,
        @logTreatmentWeekday AS treatment_weekday,
        string_to_array(@logTreatmentWeekday, '','') AS weekday_array,
        @logContent AS log_content
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
        ) AS weekday_numbers,
        log_content
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
        AND ord_main.treat_date >= (CASE WHEN log_info_with_dow.treatment_start_date is null or log_info_with_dow.treatment_start_date = '''' THEN ord_main.treat_date ELSE log_info_with_dow.treatment_start_date END)
        AND ord_main.treat_date <= (CASE WHEN log_info_with_dow.treatment_end_date is null or log_info_with_dow.treatment_end_date = '''' THEN ord_main.treat_date ELSE log_info_with_dow.treatment_end_date END)
        AND (
            log_info_with_dow.log_content LIKE ''曜日パターン変更%'' 
            OR log_info_with_dow.treatment_weekday = ''''
            OR EXTRACT(DOW FROM TO_DATE(ord_main.treat_date, ''YYYYMMDD''))
               = ANY (log_info_with_dow.weekday_numbers)
        )
)
SELECT 
    ord_main.ord_no
FROM 
    ord_main
INNER JOIN 
    target_ord_no ON ord_main.ord_no = target_ord_no.ord_no
WHERE
	ord_main.ord_no = @ordNo
    AND target_ord_no.rn = 1', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{}'::jsonb, 'セコム　指示変更履歴 実施対象取得', '2025-03-26 21:13:57.360', '2025-05-27 13:22:16.287', '[{"sql_cd": -1107054, "field_name": "treatment_start_date", "replace_var": "@logTreatmentStartDate"}, {"sql_cd": -1107054, "field_name": "treatment_end_date", "replace_var": "logTreatmentEndDate"}, {"sql_cd": -1107054, "field_name": "treatment_weekday", "replace_var": "@logTreatmentWeekday"}, {"sql_cd": -1107054, "field_name": "log_content", "replace_var": "@logContent"}]'::jsonb);

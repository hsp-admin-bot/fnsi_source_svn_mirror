DELETE FROM ntss.sys_data_set
WHERE sql_cd in (-1107055,-1107056);

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
        @treatmentMethod AS treatment_method,
        @treatmentCourse AS treatment_course,
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
        treatment_method,
        treatment_course,
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
    LEFT JOIN
        mst_treatment ON ord_main_restore.ind_treatment_cd = mst_treatment.treatment_cd
        AND ord_main_restore.facility_cd = mst_treatment.facility_cd
        AND mst_treatment.is_del = ''0''
        AND mst_treatment.is_disp = ''1''
    LEFT JOIN
        mst_kur ON ord_main_restore.ind_kur_cd = mst_kur.kur_cd
        AND ord_main_restore.facility_cd = mst_treatment.facility_cd
        AND mst_treatment.is_del = ''0''
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
        AND COALESCE(mst_treatment.treatment_name,'''') = (CASE WHEN log_info_with_dow.treatment_method is null or log_info_with_dow.treatment_method = ''すべて'' THEN COALESCE(mst_treatment.treatment_name,'''') ELSE log_info_with_dow.treatment_method END)
        AND COALESCE(mst_kur.kur_name,''未登録'') = (CASE WHEN log_info_with_dow.treatment_course is null or log_info_with_dow.treatment_course = '''' THEN COALESCE(mst_kur.kur_name,''未登録'') ELSE COALESCE(NULLIF(log_info_with_dow.treatment_course, ''''), ''未登録'') END)
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
        )', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{}'::jsonb, 'セコム　指示変更履歴 実施対象取得', '2025-03-26 21:13:57.360', '2025-05-27 13:22:16.287', '[{"sql_cd": -1107054, "field_name": "treatment_start_date", "replace_var": "@logTreatmentStartDate"}, {"sql_cd": -1107054, "field_name": "treatment_end_date", "replace_var": "logTreatmentEndDate"}, {"sql_cd": -1107054, "field_name": "treatment_weekday", "replace_var": "@logTreatmentWeekday"}, {"sql_cd": -1107054, "field_name": "treatment_method", "replace_var": "@treatmentMethod"}, {"sql_cd": -1107054, "field_name": "treatment_course", "replace_var": "@treatmentCourse"}, {"sql_cd": -1107054, "field_name": "log_content", "replace_var": "@logContent"}]'::jsonb);
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
        @treatmentMethod AS treatment_method,
        @treatmentCourse AS treatment_course,
        @logClass AS log_class,
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
        treatment_method,
        treatment_course,
        log_class,
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
    LEFT JOIN
        mst_treatment ON ord_main.ind_treatment_cd = mst_treatment.treatment_cd
        AND ord_main.facility_cd = mst_treatment.facility_cd
        AND mst_treatment.is_del = ''0''
        AND mst_treatment.is_disp = ''1''
    LEFT JOIN
        mst_kur ON ord_main.ind_kur_cd = mst_kur.kur_cd
        AND ord_main.facility_cd = mst_treatment.facility_cd
        AND mst_treatment.is_del = ''0''
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
        AND COALESCE(mst_treatment.treatment_name,'''') = (CASE WHEN ((log_info_with_dow.treatment_method is null or log_info_with_dow.treatment_method = ''すべて'') and (log_info_with_dow.log_class <> ''新規'')) THEN COALESCE(mst_treatment.treatment_name,'''') ELSE log_info_with_dow.treatment_method END)
        AND COALESCE(mst_kur.kur_name,''未登録'') = (CASE WHEN ((log_info_with_dow.treatment_course is null or log_info_with_dow.treatment_course = '''') and (log_info_with_dow.log_class <> ''新規'')) THEN COALESCE(mst_kur.kur_name,''未登録'') ELSE COALESCE(NULLIF(log_info_with_dow.treatment_course, ''''), ''未登録'') END)
)
SELECT 
    ord_main.ord_no
FROM 
    ord_main
INNER JOIN 
    target_ord_no ON ord_main.ord_no = target_ord_no.ord_no
WHERE
	ord_main.ord_no = @ordNo
    AND target_ord_no.rn = 1', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{}'::jsonb, 'セコム　指示変更履歴 実施対象取得', '2025-03-26 21:13:57.360', '2025-05-27 13:22:16.287', '[{"sql_cd": -1107054, "field_name": "treatment_start_date", "replace_var": "@logTreatmentStartDate"}, {"sql_cd": -1107054, "field_name": "treatment_end_date", "replace_var": "logTreatmentEndDate"}, {"sql_cd": -1107054, "field_name": "treatment_weekday", "replace_var": "@logTreatmentWeekday"}, {"sql_cd": -1107054, "field_name": "treatment_method", "replace_var": "@treatmentMethod"}, {"sql_cd": -1107054, "field_name": "treatment_course", "replace_var": "@treatmentCourse"}, {"sql_cd": -1107054, "field_name": "log_class", "replace_var": "@logClass"}, {"sql_cd": -1107054, "field_name": "log_content", "replace_var": "@logContent"}]'::jsonb);

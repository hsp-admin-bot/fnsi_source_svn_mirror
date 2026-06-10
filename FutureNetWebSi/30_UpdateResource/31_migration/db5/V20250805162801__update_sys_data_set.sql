DELETE FROM ntss.sys_data_set
WHERE sql_cd=-1107055;
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1107055, 'WITH content_raw AS (
  SELECT  (e ->> ''sort_no'')::int        AS sort_no,
          e ->> ''log_target''            AS log_target,
          e ->> ''log_date''              AS log_date,
          e ->> ''treatment_weekday''     AS treatment_weekday,
          e ->> ''treatment_method''      AS treatment_method,
          e ->> ''treatment_course''      AS treatment_course,
          e ->> ''log_class''             AS log_class,
          e ->> ''log_content''           AS log_content,
          e ->> ''treatment_start_date''  AS treatment_start_date,
          e ->> ''treatment_end_date''    AS treatment_end_date
  FROM    jsonb_array_elements(@content::jsonb) e
),
log_info AS (
    SELECT 
        sort_no,
        treatment_start_date,
        CASE 
            WHEN treatment_end_date = ''logTreatmentEndDate'' THEN ''''
            ELSE treatment_end_date
        END AS treatment_end_date,
        treatment_weekday,
        string_to_array(treatment_weekday, '','') AS weekday_array,
        treatment_method,
        treatment_course,
        log_class,
        log_content
    FROM
        content_raw
    LIMIT
        1
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
        ROW_NUMBER() OVER (ORDER BY ord_main.up_date DESC, TO_DATE(LPAD(ord_main.treat_date::text, 8, ''0''), ''YYYYMMDD'') ASC) AS rn
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
        AND ord_main.facility_cd = mst_kur.facility_cd
        AND mst_kur.is_del = ''0''
    WHERE 
        ord_main.facility_cd = @facilityCd
        AND ord_main.pat_id = @patId
        AND ord_main.treat_date >= (CASE WHEN log_info_with_dow.treatment_start_date is null or log_info_with_dow.treatment_start_date = '''' THEN ord_main.treat_date ELSE log_info_with_dow.treatment_start_date END)
        AND ord_main.treat_date <= (CASE WHEN log_info_with_dow.treatment_end_date is null or log_info_with_dow.treatment_end_date = '''' THEN ord_main.treat_date ELSE log_info_with_dow.treatment_end_date END)
        AND (
            (log_info_with_dow.log_content NOT LIKE ''曜日パターン変更%'' 
            AND EXTRACT(DOW FROM TO_DATE(ord_main.treat_date, ''YYYYMMDD'')) = ANY (log_info_with_dow.weekday_numbers))
            OR (log_info_with_dow.log_content LIKE ''曜日パターン変更%'' 
            AND EXTRACT(DOW FROM TO_DATE(ord_main.treat_date, ''YYYYMMDD'')) <> ALL (log_info_with_dow.weekday_numbers))
            OR log_info_with_dow.treatment_weekday = ''''
        )
        AND COALESCE(mst_treatment.treatment_name,''未登録'') = (
            CASE 
                WHEN ((NULLIF(log_info_with_dow.treatment_method,'''') is null
                     or log_info_with_dow.treatment_method = ''すべて'') 
                      and (log_info_with_dow.log_class = ''変更'' and log_info_with_dow.log_content NOT LIKE ''曜日パターン変更%'')) 
                THEN COALESCE(mst_treatment.treatment_name,''未登録'') 
                ELSE 
                    CASE 
                        WHEN (log_info_with_dow.log_class = ''変更'' and ((SELECT COUNT(log_content) FROM content_raw WHERE sort_no = ''20'') > 0))
                        THEN split_part((SELECT log_content FROM content_raw WHERE sort_no = ''20'' LIMIT 1), ''→'', 2)
                        ELSE
                            CASE
                                WHEN log_info_with_dow.treatment_method = ''すべて''
                                THEN COALESCE(mst_treatment.treatment_name,''未登録'')
                                ELSE COALESCE(NULLIF(log_info_with_dow.treatment_method, ''''), COALESCE(mst_treatment.treatment_name,''未登録''))
                            END
                    END
            END
        )
        AND COALESCE(mst_kur.kur_name,''未登録'') = (
            CASE 
                WHEN ((log_info_with_dow.treatment_course is null or log_info_with_dow.treatment_course = '''') 
                      and (log_info_with_dow.log_class = ''変更'' and log_info_with_dow.log_content NOT LIKE ''曜日パターン変更%'')) 
                THEN COALESCE(mst_kur.kur_name,''未登録'') 
                ELSE 
                    CASE 
                        WHEN (log_info_with_dow.log_class = ''変更'' and ((SELECT COUNT(log_content) FROM content_raw WHERE sort_no = ''40'') > 0))
                        THEN split_part((SELECT log_content FROM content_raw WHERE sort_no = ''40'' LIMIT 1), ''→'', 2)
                        ELSE 
                            CASE
                                WHEN log_info_with_dow.treatment_course = ''すべて''
                                THEN COALESCE(mst_kur.kur_name,''未登録'')
                                ELSE COALESCE(NULLIF(log_info_with_dow.treatment_course, ''''), COALESCE(mst_kur.kur_name,''未登録''))
                            END
                    END
            END
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
    AND target_ord_no.rn = 1;
', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{}'::jsonb, 'セコム　指示変更履歴 実施対象取得', '2025-03-26 21:13:57.360', '2025-05-27 13:22:16.287', '[{"sql_cd": -1107003, "field_name": ["sort_no", "log_date", "treatment_start_date", "treatment_end_date", "log_content", "log_class", "treatment_weekday", "treatment_method", "treatment_course", "log_target"], "replace_var": "content"}]'::jsonb);
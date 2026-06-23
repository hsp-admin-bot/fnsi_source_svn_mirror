DELETE FROM sys_data_set WHERE sql_cd IN (-1107056,-1107055,-1107005,-1106009,-1106004,-1106003,-1106002,-1106001,-1105010,-1105009,-1105008,-1104003,-1104002,-1103021,-1103019,-1103018,-1103017,-1103014,-1103013,-1103012,-1103011,-1103010,-1103009,-1103008,-1103007,-1103006,-1103005,-1103004,-1103003,-1103002,-1102033,-1102032,-1102030,-1102025,-1102024,-1102023,-1102022,-1102021,-1102020,-1102019,-1102018,-1102017,-1102016,-1102011,-1102006,-1102003,-1100015,-1100013,-1100011,-1100010,-1100009,-1100008);

INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1107056, 'WITH content_raw AS (
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
        AND ord_main_restore.facility_cd = mst_kur.facility_cd
        AND mst_kur.is_del = ''0''
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
        )', '2', '[]', '1', '{"applications": [5]}', '{}', 'セコム　指示変更履歴 実施対象取得', '2025-03-26 21:13:57.36', CURRENT_TIMESTAMP, '[{"sql_cd": -1107003, "field_name": ["sort_no", "log_date", "treatment_start_date", "treatment_end_date", "log_content", "log_class", "treatment_weekday", "treatment_method", "treatment_course", "log_target"], "replace_var": "content"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1107055, 'WITH sys_coop_journal_info AS (
    SELECT
        ope_cd,
        CASE 
            WHEN ope_cd IN (''004001'', ''004072'', ''007020'', ''007021'') THEN true
            ELSE false
        END AS is_del,
        base_date
    FROM
        sys_coop_journal
    WHERE
        ctl_no = @ctlNo
),
content_raw AS (
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
        TO_CHAR(
            CASE
            WHEN LENGTH(treatment_start_date) = 8 THEN to_date(treatment_start_date, ''YYYYMMDD'')
            WHEN LENGTH(treatment_start_date) = 10 THEN to_date(treatment_start_date, ''YYYY-MM-DD'')
            WHEN LENGTH(treatment_start_date) >= 19 AND SUBSTR(treatment_start_date, 5, 1) = ''-''
                THEN to_date(SUBSTR(treatment_start_date, 1, 10), ''YYYY-MM-DD'')
            ELSE NULL
            END,
            ''YYYYMMDD''
        ) AS treatment_start_date,
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
        ROW_NUMBER() OVER (
            ORDER BY
                TO_DATE(LPAD(ord_main.treat_date::text, 8, ''0''), ''YYYYMMDD'') ASC, -- ①治療日が早いものを優先
                ord_main.up_date ASC NULLS FIRST,                                 -- ②同じ治療日の中で更新が古いものを優先（NULLを最古扱い）
                ord_main.ord_no ASC                                               -- ③完全同着時の安定化
        ) AS rn
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
        AND ord_main_restore.facility_cd = mst_kur.facility_cd
        AND mst_kur.is_del = ''0''
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
        AND COALESCE(mst_kur.kur_name,''未登録'') = (CASE WHEN log_info_with_dow.treatment_course is null or log_info_with_dow.treatment_course = '''' or log_info_with_dow.treatment_course = ''すべて'' THEN COALESCE(mst_kur.kur_name,''未登録'') ELSE COALESCE(NULLIF(log_info_with_dow.treatment_course, ''''), ''未登録'') END)
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
    ord_main.ord_no
FROM 
    ord_main
INNER JOIN 
    target_ord_no ON ord_main.ord_no = target_ord_no.ord_no
JOIN 
    sys_coop_journal_info ON TRUE
WHERE
    ord_main.ord_no = @ordNo
    AND target_ord_no.rn = 1
    AND sys_coop_journal_info.is_del = false
UNION ALL
SELECT 
    ord_main.ord_no
FROM 
    ord_main
JOIN 
    log_info_with_dow ON TRUE
JOIN 
    sys_coop_journal_info ON TRUE
WHERE
    ord_main.ord_no = @ordNo
    AND log_info_with_dow.log_class LIKE ''治療日変更%''
    AND (
            ord_main.treat_date = sys_coop_journal_info.base_date
            OR
                CASE 
                    WHEN ((SELECT COUNT(log_content) FROM content_raw WHERE sort_no = ''40'') > 0)
                    THEN split_part((SELECT log_content FROM content_raw WHERE sort_no = ''40'' LIMIT 1), ''→'', 1) <> ''未登録'' AND split_part((SELECT log_content FROM content_raw WHERE sort_no = ''40'' LIMIT 1), ''→'', 2) = ''未登録''
                    ELSE false
                END
        )
UNION ALL
SELECT 
    ord_main_restore.ord_no
FROM 
    ord_main_restore
INNER JOIN 
    target_ord_no_restore ON ord_main_restore.ord_no = target_ord_no_restore.ord_no
    AND ord_main_restore.del_date = target_ord_no_restore.del_date
JOIN 
    log_info_with_dow ON TRUE
JOIN 
    sys_coop_journal_info ON TRUE
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
    AND sys_coop_journal_info.is_del = true
UNION ALL
SELECT 
    ord_main.ord_no
FROM 
    ord_main
JOIN 
    log_info_with_dow ON TRUE
JOIN 
    sys_coop_journal_info ON TRUE
WHERE
    ord_main.ord_no = @ordNo
    AND NOT EXISTS (
            SELECT 1
            FROM regexp_matches(
                log_info_with_dow.log_content,
                ''(月→火|月→水|月→木|月→金|月→土|月→日|火→月|火→水|火→木|火→金|火→土|火→日|水→月|水→火|水→木|水→金|水→土|水→日|木→月|木→火|木→水|木→金|木→土|木→日|金→月|金→火|金→水|金→木|金→土|金→日|土→月|土→火|土→水|土→木|土→金|土→日|日→月|日→火|日→水|日→木|日→金|日→土)'',
                ''g''
            )
        )    
    AND sys_coop_journal_info.is_del = true
', '2', '[]', '1', '{"applications": [5]}', '{}', 'セコム　指示変更履歴 実施対象取得', '2025-03-26 21:13:57.36', CURRENT_TIMESTAMP, '[{"sql_cd": -1107003, "field_name": ["sort_no", "log_date", "treatment_start_date", "treatment_end_date", "log_content", "log_class", "treatment_weekday", "treatment_method", "treatment_course", "log_target"], "replace_var": "content"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1107005, 'select  
''01'' as detail_id,
@facilityCd AS facility_cd,
@ctlNo AS ctl_no,
@key0 AS key0,
@patId AS pat_id,
@ordNo AS ord_no,
@fileName AS file_name,
'''' AS folder_name', '2', '[{}]', '0', '{"applications": [4]}', NULL, '(送信用)セコムの指示変更履歴のdetail特定', '2025-06-16 02:18:28.215', CURRENT_TIMESTAMP, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1106009, 'SELECT
    1
FROM 
    pat_rad_main prm
CROSS JOIN LATERAL json_array_elements(prm.order_rad_set_info::json) info
JOIN mst_rad_set mrs ON
    (info ->> ''rad_set_cd'')::integer = mrs.rad_set_cd
CROSS JOIN LATERAL json_array_elements(mrs.rad_item_info::json) item_info
WHERE
    prm.rad_result_cd = @ordNo
    AND prm.facility_cd = @facilityCd
    AND prm.pat_id = @patId
    AND prm.is_del = ''0''
    AND COALESCE(item_info ->> ''item_cd'', '''') <> ''''
    AND item_info ->> ''item_class'' = ''部位''', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'Secom連携_放射線オーダー連携 is_zero_end', '2025-07-18 20:19:41.142', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1106004, 'select  
''01'' as detail_id,
@facilityCd AS facility_cd,
@ctlNo AS ctl_no,
@key0 AS key0,
@patId AS pat_id,
@ordNo AS ord_no,
@fileName AS file_name,
'''' AS folder_name', '2', '[{}]', '0', '{"applications": [4]}', NULL, '(送信用)セコムの放射線オーダー_ファイル作成終了のdetail特定', '2025-06-19 10:57:13.141', CURRENT_TIMESTAMP, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1106003, 'select  
''01'' as detail_id,
@facilityCd AS facility_cd,
@ctlNo AS ctl_no,
@key0 AS key0,
@patId AS pat_id,
@ordNo AS ord_no,
@fileName AS file_name,
'''' AS folder_name', '2', '[{}]', '0', '{"applications": [4]}', NULL, '(送信用)セコムの放射線オーダー_実施単位のdetail特定', '2025-06-25 16:30:15.736', CURRENT_TIMESTAMP, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1106002, 'select  
''01'' as detail_id,
@facilityCd AS facility_cd,
@ctlNo AS ctl_no,
@key0 AS key0,
@patId AS pat_id,
@ordNo AS ord_no,
@fileName AS file_name,
'''' AS folder_name', '2', '[{}]', '0', '{"applications": [4]}', NULL, '(送信用)セコムの放射線オーダー_処方ヘッダーのdetail特定', '2025-06-25 16:30:15.736', CURRENT_TIMESTAMP, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1106001, 'select  
''01'' as detail_id,
@facilityCd AS facility_cd,
@ctlNo AS ctl_no,
@key0 AS key0,
@patId AS pat_id,
@ordNo AS ord_no,
@fileName AS file_name,
'''' AS folder_name', '2', '[{}]', '0', '{"applications": [4]}', NULL, '(送信用)セコムの放射線オーダー_オーダーインデックスのdetail特定', '2025-06-25 16:30:15.736', CURRENT_TIMESTAMP, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1105010, 'select  
''01'' as detail_id,
@facilityCd AS facility_cd,
@ctlNo AS ctl_no,
@key0 AS key0,
@patId AS pat_id,
@ordNo AS ord_no,
@fileName AS file_name,
'''' AS folder_name', '2', '[{}]', '0', '{"applications": [4]}', NULL, '(送信用)セコムの検体検査_検体検査依頼ファイル作成終了出力', '2025-07-10 11:28:37.471', CURRENT_TIMESTAMP, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1105009, 'select  
''01'' as detail_id,
@facilityCd AS facility_cd,
@ctlNo AS ctl_no,
@key0 AS key0,
@patId AS pat_id,
@ordNo AS ord_no,
@fileName AS file_name,
'''' AS folder_name', '2', '[{}]', '0', '{"applications": [4]}', NULL, '(送信用)セコムの検体検査_検体検査出力', '2025-07-10 11:28:37.471', CURRENT_TIMESTAMP, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1105008, 'select  
''01'' as detail_id,
@facilityCd AS facility_cd,
@ctlNo AS ctl_no,
@key0 AS key0,
@patId AS pat_id,
@ordNo AS ord_no,
@fileName AS file_name,
'''' AS folder_name', '2', '[{}]', '0', '{"applications": [4]}', NULL, '(送信用)セコムの検体検査_オーダーインデックス出力', '2025-07-10 11:28:37.471', CURRENT_TIMESTAMP, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1104003, 'WITH receiptinfo_file_name AS (
SELECT
	COALESCE(NULLIF(info ->> ''value'',
	''''),
	info ->> ''default_v'') AS value
FROM
	MST_COOP_INI ini
CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
WHERE
	1 = 1
	AND ini.FACILITY_CD = @facilityCd
	AND ini.IS_DEL = ''0''
	AND info ->> ''key1'' = ''SCM_RECEIPTINFO_SEND''
	AND info ->> ''key2'' = ''RECEIPTINFO_FILE_NAME'' )
SELECT
	receiptinfo_file_name.value || TO_CHAR(scj.reg_date,
	''YYYYMMDDHH24MISS'') || ''.csv'' AS filename
FROM
	receiptinfo_file_name
JOIN sys_coop_journal scj ON
	scj.ORD_NO = @ordNo
	AND scj.FACILITY_CD = @facilityCd
	AND scj.COOP_CD = ''accept''', '2', '[]', '0', '{"applications": [4]}', '{"classes": []}', 'セコム連携 再来受付ファイル名', '2020-07-31 18:29:49', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1104002, 'WITH ind_memo AS (
  SELECT COALESCE(save_2 ->> ''sequence_no'', '''') AS sequence_no
  FROM pat_coop_detail
  WHERE
    save_2 ->> ''ord_no'' = @ordNo
    AND save_2 ->> ''coop_cd'' = ''ind_dial'' 
    AND facility_cd = @facilityCd
  ORDER BY up_date
  LIMIT 1
),
acc_memo AS (
  SELECT 1
  FROM pat_coop_detail p
  JOIN ind_memo i
    ON COALESCE(p.save_2 ->> ''sequence_no'', '''') = i.sequence_no
  WHERE
    p.save_2 ->> ''coop_cd'' = ''accept''
    AND p.facility_cd = @facilityCd
    AND p.save_2 ->> ''ord_no'' <> @ordNo
  LIMIT 1
)
SELECT 1 AS result
FROM ind_memo
WHERE NOT EXISTS (SELECT 1 FROM acc_memo);', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム　再来受付', '2025-05-27 13:22:20.305', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1103021, '-- SQL: -1103021 begin
WITH raw_data AS (
	SELECT @contentJson::jsonb AS data
),
rows AS (
	SELECT JSONB_ARRAY_ELEMENTS(data) AS row
	FROM raw_data
)

-- colの番号は設計書の「No.」を表しています。
-- col1は「No.1」、col2は「No.2」...と続きます。
SELECT 
    ''01'' AS detail_id,
    row->>0  AS col1,
    row->>1  AS col2,
    row->>2  AS col3,
    row->>3  AS col4,
    row->>4  AS col5,
    row->>5  AS col6,
    row->>6  AS col7,
    row->>7  AS col8,
    row->>8  AS col9,
    row->>9  AS col10,
    row->>10 AS col11,
    row->>11 AS col12,
    row->>12 AS col13,
    row->>13 AS col14,
    row->>14 AS col15,
    row->>15 AS col16,
    row->>16 AS col17,
    row->>17 AS col18,
    row->>18 AS col19,
    row->>19 AS col20,
    row->>20 AS col21,
    row->>21 AS col22,
    row->>22 AS col23,
    row->>23 AS col24,
    row->>24 AS col25,
    row->>25 AS col26,
    row->>26 AS col27,
    row->>27 AS col28,
    row->>28 AS col29,
    row->>29 AS col30,
    row->>30 AS col31,
    row->>31 AS col32,
    row->>32 AS col33,
    row->>33 AS col34,
    row->>34 AS col35,
    row->>35 AS col36,
    row->>36 AS col37,
    row->>37 AS col38,
    row->>38 AS col39,
    row->>39 AS col40
FROM rows
where row->>@conditionTargetColNo = @conditionValue::text;
-- SQL: -1103021 end
', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム連携 透析実績連携 注射実績 行取得用(削除電文用)', '2025-08-05 10:51:12.178', CURRENT_TIMESTAMP, '[{"sql_cd": -1103016, "field_name": "content_json", "replace_var": "@contentJson"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1103019, '-- SQL: -1103019 begin
-- このSQLは、透析実績連携の最新の新規処理によって生成されたファイルの内容を出力します。
-- recordタグのSqlCodeに指定する形で使用してください。
-- このSQLで取得したパラメータは子レイアウトのSQLで直接参照してください。

WITH raw_data AS (
	SELECT @contentJson::jsonb AS data
),
rows AS (
	SELECT JSONB_ARRAY_ELEMENTS(data) AS row
	FROM raw_data
)

-- colの番号は設計書の「No.」を表しています。
-- col1は「No.1」、col2は「No.2」...と続きます。
SELECT 
    ''01'' AS detail_id,
    row->>0  AS col1,
    row->>1  AS col2,
    row->>2  AS col3,
    row->>3  AS col4,
    row->>4  AS col5,
    row->>5  AS col6,
    row->>6  AS col7,
    row->>7  AS col8,
    row->>8  AS col9,
    row->>9  AS col10,
    row->>10 AS col11,
    row->>11 AS col12,
    row->>12 AS col13,
    row->>13 AS col14,
    row->>14 AS col15,
    row->>15 AS col16,
    row->>16 AS col17,
    row->>17 AS col18,
    row->>18 AS col19,
    row->>19 AS col20,
    row->>20 AS col21,
    row->>21 AS col22,
    row->>22 AS col23,
    row->>23 AS col24,
    row->>24 AS col25,
    row->>25 AS col26,
    row->>26 AS col27,
    row->>27 AS col28,
    row->>28 AS col29,
    row->>29 AS col30,
    row->>30 AS col31,
    row->>31 AS col32,
    row->>32 AS col33,
    row->>33 AS col34,
    row->>34 AS col35,
    row->>35 AS col36,
    row->>36 AS col37,
    row->>37 AS col38,
    row->>38 AS col39,
    row->>39 AS col40
FROM rows;
-- SQL: -1103019 end
', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム連携 透析実績連携 行取得用(削除電文用)', '2025-07-24 22:27:41.353', CURRENT_TIMESTAMP, '[{"sql_cd": -1103016, "field_name": "content_json", "replace_var": "@contentJson"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1103018, '-- SQL: -1103018 begin
WITH raw_data AS (
	SELECT @contentJson::jsonb AS data
)
,rows AS (
	SELECT JSONB_ARRAY_ELEMENTS(data) AS row
	FROM raw_data
)

-- このSQLでは注射実績ファイルのファイル出力有無を判断します。
-- ファイル出力を行う場合は1件以上のレコードを返却します。
-- ファイル出力を行わない場合はレコードを返却しません。
-- このSQLに指定できるfileSubKindには''inj_index''を指定してください。
-- 注射実績のオーダーインデックスの9番目の要素を参照し、RP番号を出力します。
SELECT 
    ''01'' AS detail_id,
    (row ->> 8)::numeric AS rp_no
FROM rows
WHERE EXISTS (
  SELECT 1 FROM rows
)
order by rp_no;
-- SQL: -1103018 end
', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム連携 透析実績連携 注射実績(削除電文用)', '2025-08-05 10:51:12.178', CURRENT_TIMESTAMP, '[{"sql_cd": -1103016, "field_name": "content_json", "replace_var": "@contentJson"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1103017, '-- SQL: -1103017 begin
WITH raw_data AS (
	SELECT @contentJson::jsonb AS data
)
,rows AS (
	SELECT JSONB_ARRAY_ELEMENTS(data) AS row
	FROM raw_data
)

-- このSQLでは処置実績ファイルのファイル出力有無を判断します。
-- ファイル出力を行う場合は1件のレコードを返却します。
-- ファイル出力を行わない場合はレコードを返却しません。
SELECT 
    ''01'' AS detail_id
WHERE EXISTS (
  SELECT 1 FROM rows
);
-- SQL: -1103017 end
', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム連携 透析実績連携 処置実績(削除電文用)', '2025-07-24 22:27:41.353', CURRENT_TIMESTAMP, '[{"sql_cd": -1103016, "field_name": "content_json", "replace_var": "@contentJson"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1103014, '-- SQL: -11030014 begin
WITH RECURSIVE coop_ini_info AS (
--連携設定より取得
SELECT
  COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value,
  info ->> ''key1'' AS key1,
  info ->> ''key2'' AS key2
FROM
  mst_coop_ini AS ini
CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
WHERE
  facility_cd = @facilityCd
  AND is_del = ''0''
  AND COALESCE(info ->> ''key0'', '''') = @key0
  AND info ->> ''key1'' IN (
        ''SCM_COMMON'',
        ''SCM_IN_HOSPITAL_CD'',
        ''SCM_DIALYSISSEND''
    )
)
, ini_value AS (
--連携設定からvalue値取得
SELECT
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''MEDICINE_SEND_TYPE'') AS medicine_send_type,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_TREATMENT'') AS hosp_get_mst_treatment,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_DIALYZER'') AS hosp_get_mst_dialyzer,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_EQUIPMENT'') AS hosp_get_mst_equipment,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_MEDICINE'') AS hosp_get_mst_medicine,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_PROCEDURE'') AS hosp_get_mst_procedure,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_DIALYSIS_DIFFICULTY'') AS hosp_get_mst_dia_diff,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_ADDITION'') AS hosp_get_mst_addition,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND'' AND key2 = ''OXGEN_PROCEDURE_CODE'') AS oxgen_procedure_code,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND'' AND key2 = ''OXGEN_MEDI_CODE'') AS oxgen_medi_code,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND'' AND key2 = ''TREAT_CONVERT'') AS treat_convert
)
, auth_info AS (
--患者個人情報取得(pre_sqlにて取得)
SELECT
  auth_info ->> ''dial_diff_cd'' AS dial_diff_cd,
  auth_info ->> ''is_dial_diff'' AS is_dial_diff
FROM
  json_array_elements(@patPersonalInfo::json) auth_info
)
, mst_medi_mix AS (
--調整薬剤マスタ
SELECT
  t1.idx AS idx,
  medicine_mix_cd AS mix_cd,
  t1.info ->> ''solvent'' AS solvent,
  t1.info ->> ''cd'' AS medi_cd,
  mst.is_shot AS is_shot,
  mst.in_hospital_cd_1 AS in_hospital_cd_1,
  mst.in_hospital_cd_2 AS in_hospital_cd_2,
  mst.in_hospital_cd_3 AS in_hospital_cd_3,
  mst.in_hospital_cd_4 AS in_hospital_cd_4
FROM
  mst_medicine_mix mix
CROSS JOIN LATERAL json_array_elements(mix.mix_info ::json) WITH ORDINALITY AS t1(info, idx)
INNER JOIN mst_medicine AS mst ON mst.medicine_cd::text = info ->> ''cd''
  AND mst.facility_cd = @facilityCd
  AND mst.is_shot = ''0''
  AND mst.is_del = ''0''
  AND mst.is_disp = ''1''
WHERE
  mix.is_del = ''0''
  AND mix.facility_cd = @facilityCd
)
, do_ord_main AS (
(SELECT
  res.del_date as up_date_switch,
  res.rst_treatment_cd as rst_treatment_cd,
  res.rst_cond_info as rst_cond_info,
  res.rst_medi_info AS rst_medi_info,
  res.rst_treatment_info as rst_treatment_info,
  res.rst_equip_info as rst_equip_info,
  res.addition_info as addition_info,
  res.treat_date::TIMESTAMP AS treat_date,
  res.rst_start_date AS rst_start_date,
  res.rst_end_date AS rst_end_date
FROM ord_main_restore as res
JOIN sys_coop_journal AS journal ON res.ord_no = journal.ord_no
WHERE res.ord_no = @ordNo
  AND res.facility_cd = @facilityCd
  AND res.pat_id = @patId
  AND res.is_del = ''0''
  AND res.ord_no = journal.ord_no
  AND journal.ctl_no = @ctlNo
  AND journal.reg_date >= res.del_date
ORDER BY res.del_date DESC LIMIT 1
)
UNION
(SELECT
  main.rst_edition_date as up_date_switch,
  main.rst_treatment_cd as rst_treatment_cd,
  main.rst_cond_info as rst_cond_info,
  main.rst_medi_info AS rst_medi_info,
  main.rst_treatment_info as rst_treatment_info,
  main.rst_equip_info as rst_equip_info,
  main.addition_info as addition_info,
  main.treat_date::TIMESTAMP AS treat_date,
  main.rst_start_date AS rst_start_date,
  main.rst_end_date AS rst_end_date
FROM ord_main AS main
  WHERE main.ord_no = @ordNo
  AND main.facility_cd = @facilityCd
  AND main.pat_id = @patId
  AND main.is_del = ''0''
)
ORDER BY
  up_date_switch DESC NULLS LAST
LIMIT 1
)
, rst_treatment AS (
-- 治療方法コード
SELECT
  1000 AS temp_no,
  om.rst_treatment_cd AS mst_cd,
  CASE
    -- 両方とも利用開始日以降の場合
    WHEN ((om.treat_date::TIMESTAMP >= mt.in_hosp_a_startdate)
      AND (om.treat_date::TIMESTAMP >= mt.in_hosp_b_startdate)) THEN
        CASE
          WHEN mt.in_hosp_a_startdate > mt.in_hosp_b_startdate THEN
            CASE ini_value.hosp_get_mst_treatment
              WHEN ''1'' THEN mt.in_hospital_cd_a1
              WHEN ''2'' THEN mt.in_hospital_cd_a2
              WHEN ''3'' THEN mt.in_hospital_cd_a3
              WHEN ''4'' THEN mt.in_hospital_cd_a4
            END
          WHEN mt.in_hosp_a_startdate < mt.in_hosp_b_startdate THEN
            CASE ini_value.hosp_get_mst_treatment
              WHEN ''1'' THEN mt.in_hospital_cd_b1
              WHEN ''2'' THEN mt.in_hospital_cd_b2
              WHEN ''3'' THEN mt.in_hospital_cd_b3
              WHEN ''4'' THEN mt.in_hospital_cd_b4
            END
        END
    -- 治療日よりAの利用日開始日以降の場合
    WHEN om.treat_date::TIMESTAMP >= mt.in_hosp_a_startdate THEN
      CASE ini_value.hosp_get_mst_treatment
        WHEN ''1'' THEN mt.in_hospital_cd_a1
        WHEN ''2'' THEN mt.in_hospital_cd_a2
        WHEN ''3'' THEN mt.in_hospital_cd_a3
        WHEN ''4'' THEN mt.in_hospital_cd_a4
      END
    -- 治療日よりBの利用日開始日以降の場合
    WHEN om.treat_date::TIMESTAMP >= mt.in_hosp_b_startdate THEN
      CASE ini_value.hosp_get_mst_treatment
        WHEN ''1'' THEN mt.in_hospital_cd_b1
        WHEN ''2'' THEN mt.in_hospital_cd_b2
        WHEN ''3'' THEN mt.in_hospital_cd_b3
        WHEN ''4'' THEN mt.in_hospital_cd_b4
      END
    ELSE NULL
  END AS hosp_cd
FROM
  do_ord_main om
INNER JOIN mst_treatment AS mt ON mt.treatment_cd = om.rst_treatment_cd
  AND mt.facility_cd = @facilityCd
CROSS JOIN ini_value
)
, rst_dialyzer AS (
-- ダイアライザ
SELECT
  2000 AS temp_no,
  om.rst_cond_info->''5''->>''value'' AS mst_cd,
  CASE ini_value.hosp_get_mst_dialyzer
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd
FROM
  do_ord_main om
INNER JOIN mst_dialyzer AS mst ON mst.dialyzer_cd::text = om.rst_cond_info ->''5''->>''value''
  AND mst.facility_cd = @facilityCd
CROSS JOIN ini_value
)
, rst_adsorption AS (
-- 吸着カラム
SELECT
  2100 AS temp_no,
  om.rst_cond_info->''6''->>''value'' AS mst_cd,
  CASE ini_value.hosp_get_mst_equipment
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd
FROM
  do_ord_main om
INNER JOIN mst_equipment AS mst ON mst.equipment_cd::text = om.rst_cond_info->''6''->>''value''
  AND mst.facility_cd = @facilityCd
CROSS JOIN ini_value
)
, rst_coagulant AS (
-- 抗凝固剤
SELECT
  3000 AS temp_no,
  om.rst_cond_info->''25''->>''value'' AS mst_cd,
  (om.rst_cond_info->''25''->>''medicine_type'')::integer AS medicine_type,
  NULL::integer AS procedure_cd,
  CASE
    WHEN COALESCE(om.rst_cond_info->''25''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE om.rst_cond_info->''25''->>''medicine_type''
        WHEN ''1'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_medi.in_hospital_cd_1
            WHEN ''2'' THEN mst_medi.in_hospital_cd_2
            WHEN ''3'' THEN mst_medi.in_hospital_cd_3
            WHEN ''4'' THEN mst_medi.in_hospital_cd_4
            ELSE NULL
          END
        WHEN ''2'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_mix.in_hospital_cd_1
            WHEN ''2'' THEN mst_mix.in_hospital_cd_2
            WHEN ''3'' THEN mst_mix.in_hospital_cd_3
            WHEN ''4'' THEN mst_mix.in_hospital_cd_4
            ELSE NULL
          END
      END
  END AS hosp_cd
FROM
  do_ord_main om
LEFT JOIN mst_medicine AS mst_medi ON mst_medi.medicine_cd::text = om.rst_cond_info->''25''->>''value''
  AND mst_medi.facility_cd = @facilityCd
  AND mst_medi.is_shot = ''0''
  AND mst_medi.is_del = ''0''
  AND mst_medi.is_disp = ''1''
  AND om.rst_cond_info->''25''->>''medicine_type''::text = ''1''
LEFT JOIN mst_medi_mix AS mst_mix ON mst_mix.mix_cd::text = om.rst_cond_info->''25''->>''value''
  AND om.rst_cond_info->''25''->>''medicine_type''::text = ''2''
CROSS JOIN ini_value
)
, rst_touseki AS (
-- 透析液
SELECT
  3100 AS temp_no,
  om.rst_cond_info->''15''->>''value'' AS mst_cd,
  (om.rst_cond_info->''15''->>''medicine_type'')::integer AS medicine_type,
  NULL::integer AS procedure_cd,
  CASE
    WHEN COALESCE(om.rst_cond_info->''15''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE om.rst_cond_info->''15''->>''medicine_type''
        WHEN ''1'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_medi.in_hospital_cd_1
            WHEN ''2'' THEN mst_medi.in_hospital_cd_2
            WHEN ''3'' THEN mst_medi.in_hospital_cd_3
            WHEN ''4'' THEN mst_medi.in_hospital_cd_4
            ELSE NULL
          END
        WHEN ''2'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_mix.in_hospital_cd_1
            WHEN ''2'' THEN mst_mix.in_hospital_cd_2
            WHEN ''3'' THEN mst_mix.in_hospital_cd_3
            WHEN ''4'' THEN mst_mix.in_hospital_cd_4
            ELSE NULL
          END
      END
  END AS hosp_cd
FROM
  do_ord_main om
LEFT JOIN mst_medicine AS mst_medi ON mst_medi.medicine_cd::text = om.rst_cond_info->''15''->>''value''
  AND mst_medi.facility_cd = @facilityCd
  AND mst_medi.is_shot = ''0''
  AND mst_medi.is_del = ''0''
  AND mst_medi.is_disp = ''1''
  AND om.rst_cond_info->''15''->>''medicine_type''::text = ''1''
LEFT JOIN mst_medi_mix AS mst_mix ON mst_mix.mix_cd::text = om.rst_cond_info->''15''->>''value''
  AND om.rst_cond_info->''15''->>''medicine_type''::text = ''2''
CROSS JOIN ini_value
)
, rst_hoeki AS (
-- 補液
SELECT
  3200 AS temp_no,
  om.rst_cond_info->''19''->>''value'' AS mst_cd,
  (om.rst_cond_info->''19''->>''medicine_type'')::integer AS medicine_type,
  NULL::integer AS procedure_cd,
  CASE
    WHEN COALESCE(om.rst_cond_info->''19''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE om.rst_cond_info->''19''->>''medicine_type''
        WHEN ''1'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_medi.in_hospital_cd_1
            WHEN ''2'' THEN mst_medi.in_hospital_cd_2
            WHEN ''3'' THEN mst_medi.in_hospital_cd_3
            WHEN ''4'' THEN mst_medi.in_hospital_cd_4
            ELSE NULL
          END
        WHEN ''2'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_mix.in_hospital_cd_1
            WHEN ''2'' THEN mst_mix.in_hospital_cd_2
            WHEN ''3'' THEN mst_mix.in_hospital_cd_3
            WHEN ''4'' THEN mst_mix.in_hospital_cd_4
            ELSE NULL
          END
      END
  END AS hosp_cd
FROM
  do_ord_main om
LEFT JOIN mst_medicine AS mst_medi ON mst_medi.medicine_cd::text = om.rst_cond_info->''19''->>''value''
  AND mst_medi.facility_cd = @facilityCd
  AND mst_medi.is_shot = ''0''
  AND mst_medi.is_del = ''0''
  AND mst_medi.is_disp = ''1''
  AND om.rst_cond_info->''19''->>''medicine_type''::text = ''1''
LEFT JOIN mst_medi_mix AS mst_mix ON mst_mix.mix_cd::text = om.rst_cond_info->''19''->>''value''
  AND om.rst_cond_info->''19''->>''medicine_type''::text = ''2''
CROSS JOIN ini_value
)
, rst_one_film AS (
-- 1次膜
SELECT
  2200 AS temp_no,
  om.rst_cond_info->''7''->>''value'' AS mst_cd,
  CASE ini_value.hosp_get_mst_equipment
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd
FROM
  do_ord_main om
INNER JOIN mst_equipment AS mst ON mst.equipment_cd::text = om.rst_cond_info->''7''->>''value''
  AND mst.facility_cd = @facilityCd
CROSS JOIN ini_value
)
, rst_two_film AS (
-- 2次膜
SELECT
  2300 AS temp_no,
  om.rst_cond_info->''8''->>''value'' AS mst_cd,
  CASE ini_value.hosp_get_mst_equipment
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd
FROM
  do_ord_main om
INNER JOIN mst_equipment AS mst ON mst.equipment_cd::text = om.rst_cond_info->''8''->>''value''
  AND mst.facility_cd = @facilityCd
CROSS JOIN ini_value
)
, medi_indo AS (
-- 投与薬剤情報
SELECT
  3300 + t1.idx AS temp_no,
  t1.medi_info ->> ''cd'' AS mst_cd,
  (t1.medi_info ->> ''medicine_type'')::integer AS medicine_type,
  (t1.medi_info ->> ''procedure_cd'')::integer AS procedure_cd,
  om.treat_date::TIMESTAMP AS treat_date,
  CASE
    WHEN json_array_length(om.rst_medi_info::json) = 0 THEN NULL
    ELSE
      CASE t1.medi_info ->> ''medicine_type''
        WHEN ''1'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_medi.in_hospital_cd_1
            WHEN ''2'' THEN mst_medi.in_hospital_cd_2
            WHEN ''3'' THEN mst_medi.in_hospital_cd_3
            WHEN ''4'' THEN mst_medi.in_hospital_cd_4
            ELSE NULL
          END
        WHEN ''2'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_mix.in_hospital_cd_1
            WHEN ''2'' THEN mst_mix.in_hospital_cd_2
            WHEN ''3'' THEN mst_mix.in_hospital_cd_3
            WHEN ''4'' THEN mst_mix.in_hospital_cd_4
            ELSE NULL
          END
      END
  END AS hosp_cd,
  CASE
    WHEN json_array_length(om.rst_medi_info::json) = 0 THEN NULL
    ELSE
      CASE t1.medi_info ->> ''medicine_type''
        WHEN ''1'' THEN mst_medi.is_shot
        WHEN ''2'' THEN mst_mix.is_shot
      END
  END AS is_shot
FROM
  do_ord_main om
CROSS JOIN LATERAL json_array_elements(om.rst_medi_info::json) WITH ORDINALITY AS t1(medi_info, idx)
LEFT JOIN mst_medicine AS mst_medi ON mst_medi.medicine_cd::text = medi_info ->> ''cd''
  AND medi_info ->> ''medicine_type''::text = ''1''
  AND mst_medi.facility_cd = @facilityCd
  AND mst_medi.is_del = ''0''
  AND mst_medi.is_disp = ''1''
LEFT JOIN mst_medi_mix AS mst_mix ON mst_mix.mix_cd::text = medi_info ->> ''cd''
  AND medi_info ->> ''medicine_type''::text = ''2''
CROSS JOIN ini_value
WHERE
  medi_info ->> ''effect_flg''::text = ''1''
)
, treatment_info AS (
-- 愁訴処置情報
SELECT
  3400 + t1.idx AS temp_no,
  CASE
    WHEN t1.tre_info ->> ''treat_class'' = ''3''
      AND t1.tre_info ->> ''oxygen_amount'' IS NOT NULL
      AND ini_value.oxgen_medi_code <> ''''
      AND ini_value.oxgen_procedure_code <> '''' THEN
      ''oxgen_medi_code''
    ELSE
      t1.tre_info ->> ''treat_medicine_cd''
  END AS mst_cd,
  (t1.tre_info ->> ''medicine_type'')::integer AS medicine_type,
  CASE
    WHEN t1.tre_info ->> ''treat_class'' = ''3''
      AND t1.tre_info ->> ''oxygen_amount'' IS NOT NULL
      AND ini_value.oxgen_medi_code <> ''''
      AND ini_value.oxgen_procedure_code <> '''' THEN
      -9999
    ELSE
      (t1.tre_info ->> ''procedure_cd'')::integer
  END AS procedure_cd,
  om.treat_date::TIMESTAMP AS treat_date,
  CASE
    WHEN json_array_length(om.rst_treatment_info::json) = 0 THEN NULL
    WHEN t1.tre_info ->> ''treat_class'' = ''3''
      AND t1.tre_info ->> ''oxygen_amount'' IS NOT NULL
      AND ini_value.oxgen_medi_code <> ''''
      AND ini_value.oxgen_procedure_code <> '''' THEN
      ini_value.oxgen_medi_code
    ELSE
      CASE t1.tre_info ->> ''medicine_type''
        WHEN ''1'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_medi.in_hospital_cd_1
            WHEN ''2'' THEN mst_medi.in_hospital_cd_2
            WHEN ''3'' THEN mst_medi.in_hospital_cd_3
            WHEN ''4'' THEN mst_medi.in_hospital_cd_4
            ELSE NULL
          END
        WHEN ''2'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_mix.in_hospital_cd_1
            WHEN ''2'' THEN mst_mix.in_hospital_cd_2
            WHEN ''3'' THEN mst_mix.in_hospital_cd_3
            WHEN ''4'' THEN mst_mix.in_hospital_cd_4
            ELSE NULL
          END
      END
  END AS hosp_cd,
  CASE
    WHEN json_array_length(om.rst_treatment_info::json) = 0 THEN NULL
    WHEN t1.tre_info ->> ''treat_class'' = ''3''
      AND t1.tre_info ->> ''oxygen_amount'' IS NOT NULL
      AND ini_value.oxgen_medi_code <> ''''
      AND ini_value.oxgen_procedure_code <> '''' THEN
      ''0''
    ELSE
      CASE t1.tre_info ->> ''medicine_type''
        WHEN ''1'' THEN mst_medi.is_shot
        WHEN ''2'' THEN mst_mix.is_shot
      END
  END AS is_shot
FROM
  do_ord_main om
CROSS JOIN LATERAL json_array_elements(om.rst_treatment_info::json) WITH ORDINALITY AS t1(tre_info, idx)
LEFT JOIN mst_medicine AS mst_medi ON mst_medi.medicine_cd::text = t1.tre_info ->> ''treat_medicine_cd''
  AND t1.tre_info ->> ''medicine_type''::text = ''1''
  AND mst_medi.facility_cd = @facilityCd
  AND mst_medi.is_shot = ''0''
  AND mst_medi.is_del = ''0''
  AND mst_medi.is_disp = ''1''
LEFT JOIN mst_medi_mix AS mst_mix ON mst_mix.mix_cd::text = t1.tre_info ->> ''treat_medicine_cd''
  AND t1.tre_info ->> ''medicine_type''::text = ''2''
CROSS JOIN ini_value
)
, rst_equip_info AS (
-- 医療材料コード
SELECT
  2400 + t1.idx AS temp_no,
  t1.equip_info ->> ''cd'' AS mst_cd,
  CASE ini_value.hosp_get_mst_equipment
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd
FROM
  do_ord_main om
CROSS JOIN LATERAL json_array_elements(om.rst_equip_info::json) WITH ORDINALITY AS t1(equip_info, idx)
INNER JOIN mst_equipment AS mst ON mst.equipment_cd::text = t1.equip_info ->> ''cd''
  AND mst.facility_cd = @facilityCd
CROSS JOIN ini_value
)
, dial_diff_info AS (
-- 透析困難コード
SELECT
  1300 AS temp_no,
  CASE ini_value.hosp_get_mst_dia_diff
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    ELSE NULL
  END AS hosp_cd
FROM
  auth_info ai
LEFT JOIN mst_dialysis_difficulty AS mst ON mst.dialysis_difficulty_cd::text = ai.dial_diff_cd
  AND mst.facility_cd = @facilityCd
  AND mst.is_del = ''0''
CROSS JOIN ini_value
WHERE
  ai.is_dial_diff = ''1''
)
, addition_info AS (
-- 加算情報
SELECT
  1300 + t1.idx AS temp_no,
  t1.addi_info ->> ''cd'' AS mst_cd,
  CASE ini_value.hosp_get_mst_addition
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    ELSE NULL
  END AS hosp_cd,
  mst.addition_class AS add_class,
  mst.in_hospital_cd_2 AS hosp_2_cd
FROM
  do_ord_main om
LEFT JOIN LATERAL (
  SELECT x.elem, x.ord FROM do_ord_main om
  CROSS JOIN LATERAL jsonb_array_elements(om.addition_info) WITH ORDINALITY AS x(elem, ord)
  WHERE
    jsonb_typeof(om.addition_info) = ''array''
) AS t1(addi_info, idx) ON TRUE
LEFT JOIN mst_addition AS mst ON mst.addition_cd ::text = t1.addi_info ->> ''cd''
  AND mst.facility_cd = @facilityCd
  AND mst.is_del = ''0''
CROSS JOIN ini_value
)
, medi_union_1 AS (
-- 薬剤情報（抗凝固剤、透析液、補液、投与薬剤情報(手技なし)、愁訴処置情報（手技なし））
SELECT
  title,
  hosp_cd
FROM
  (SELECT
    coa.temp_no AS temp_no,
    coa.medicine_type AS medicine_type,
    coa.procedure_cd AS procedure_cd,
    ''抗凝固剤'' AS title,
    coa.mst_cd AS mst_cd,
    coa.hosp_cd AS hosp_cd
  FROM
    rst_coagulant coa
  WHERE
    coa.mst_cd IS NOT NULL
UNION ALL
  SELECT
    tou.temp_no AS temp_no,
    tou.medicine_type AS medicine_type,
    tou.procedure_cd AS procedure_cd,
    ''透析液'' AS title,
    tou.mst_cd AS mst_cd,
    tou.hosp_cd AS hosp_cd
  FROM
    rst_touseki tou
  WHERE
    tou.mst_cd IS NOT NULL
UNION ALL
  SELECT
    hoe.temp_no AS temp_no,
    hoe.medicine_type AS medicine_type,
    hoe.procedure_cd AS procedure_cd,
    ''補液'' AS title,
    hoe.mst_cd AS mst_cd,
    hoe.hosp_cd AS hosp_cd
  FROM
    rst_hoeki hoe
  WHERE
    hoe.mst_cd IS NOT NULL
UNION ALL
  SELECT
    imi.temp_no AS temp_no,
    imi.medicine_type AS medicine_type,
    imi.procedure_cd AS procedure_cd,
    ''投与薬剤情報(手技なし）'' AS title,
    imi.mst_cd AS mst_cd,
    imi.hosp_cd AS hosp_cd
  FROM
    medi_indo imi
  WHERE
    imi.mst_cd IS NOT NULL
    AND imi.is_shot = ''0''
    AND imi.procedure_cd IS NULL
    AND (SELECT medicine_send_type::NUMERIC FROM ini_value) = 0
UNION ALL
  SELECT
    MIN(imi.temp_no) AS temp_no,
    MIN(imi.medicine_type) AS medicine_type,
    imi.procedure_cd AS procedure_cd,
    ''投与薬剤情報(手技なし）'' AS title,
    MIN(imi.mst_cd) AS mst_cd,
    imi.hosp_cd AS hosp_cd
  FROM
    medi_indo imi
  WHERE
    imi.mst_cd IS NOT NULL
    AND imi.is_shot = ''0''
    AND imi.procedure_cd IS NULL
    AND (SELECT medicine_send_type::NUMERIC FROM ini_value) = 1
  GROUP BY
    imi.procedure_cd,
    imi.hosp_cd
UNION ALL
  SELECT
    ti.temp_no AS temp_no,
    ti.medicine_type AS medicine_type,
    ti.procedure_cd AS procedure_cd,
    ''愁訴処置情報(手技なし）'' AS title,
    ti.mst_cd AS mst_cd,
    ti.hosp_cd AS hosp_cd
  FROM
    treatment_info ti
  WHERE
    ti.mst_cd IS NOT NULL
    AND ti.is_shot = ''0''
    AND ti.procedure_cd IS NULL
    AND (SELECT medicine_send_type::NUMERIC FROM ini_value) = 0
UNION ALL
  SELECT
    MIN(ti.temp_no) AS temp_no,
    MIN(ti.medicine_type) AS medicine_type,
    ti.procedure_cd AS procedure_cd,
    ''愁訴処置情報(手技なし）'' AS title,
    MIN(ti.mst_cd) AS mst_cd,
    ti.hosp_cd AS hosp_cd
  FROM
    treatment_info ti
  WHERE
    ti.mst_cd IS NOT NULL
    AND ti.is_shot = ''0''
    AND ti.procedure_cd IS NULL
    AND (SELECT medicine_send_type::NUMERIC FROM ini_value) = 1
  GROUP BY
    ti.procedure_cd,
    ti.hosp_cd
) AS rst_medi_table
ORDER BY
  temp_no
)
, medi_union_2 AS (
-- 投与薬剤情報(手技あり)、愁訴処置情報（手技あり）
SELECT
  ''投与薬剤/愁訴処置情報(薬剤）'' AS title,
  mst_cd,
  hosp_cd,
  MAX(mst.pricedure_name) AS pro_title,
  pro_medi_table.procedure_cd,
  CASE
    WHEN pro_medi_table.procedure_cd = -9999 THEN
      MAX(ini_value.oxgen_procedure_code)
    WHEN ((MAX(pro_medi_table.treat_date) >= MAX(mst.in_hosp_a_startdate))
      AND (MAX(pro_medi_table.treat_date) >= MAX(mst.in_hosp_b_startdate))) THEN
      CASE
        WHEN MAX(mst.in_hosp_a_startdate) > MAX(mst.in_hosp_b_startdate) THEN
          CASE MAX(ini_value.hosp_get_mst_procedure)
            WHEN ''1'' THEN MAX(mst.in_hospital_cd_a1)
            WHEN ''2'' THEN MAX(mst.in_hospital_cd_a2)
          END
        WHEN MAX(mst.in_hosp_a_startdate) < MAX(mst.in_hosp_b_startdate) THEN
          CASE MAX(ini_value.hosp_get_mst_procedure)
            WHEN ''1'' THEN MAX(mst.in_hospital_cd_b1)
            WHEN ''2'' THEN MAX(mst.in_hospital_cd_b2)
          END
      END
    WHEN MAX(pro_medi_table.treat_date) >= MAX(mst.in_hosp_a_startdate) THEN
      CASE MAX(ini_value.hosp_get_mst_procedure)
        WHEN ''1'' THEN MAX(mst.in_hospital_cd_a1)
        WHEN ''2'' THEN MAX(mst.in_hospital_cd_a2)
      END
    WHEN MAX(pro_medi_table.treat_date) >= MAX(mst.in_hosp_b_startdate) THEN
      CASE MAX(ini_value.hosp_get_mst_procedure)
        WHEN ''1'' THEN MAX(mst.in_hospital_cd_b1)
        WHEN ''2'' THEN MAX(mst.in_hospital_cd_b2)
      END
    ELSE NULL
  END AS pro_hosp_cd
FROM
  (SELECT
    imi2.mst_cd AS mst_cd,
    imi2.hosp_cd AS hosp_cd,
    imi2.procedure_cd AS procedure_cd,
    imi2.treat_date AS treat_date
  FROM
    medi_indo imi2
  WHERE
    imi2.mst_cd IS NOT NULL
    AND imi2.is_shot = ''0''
    AND imi2.procedure_cd IS NOT NULL
UNION ALL
  SELECT
    ti2.mst_cd AS mst_cd,
    ti2.hosp_cd AS hosp_cd,
    ti2.procedure_cd AS procedure_cd,
    ti2.treat_date AS treat_date
  FROM
    treatment_info ti2
  WHERE
    ti2.mst_cd IS NOT NULL
    AND ti2.is_shot = ''0''
    AND ti2.procedure_cd IS NOT NULL
) AS pro_medi_table
LEFT JOIN mst_procedure mst ON mst.procedure_cd = pro_medi_table.procedure_cd
  AND mst.facility_cd = @facilityCd
CROSS JOIN ini_value
WHERE
  (SELECT medicine_send_type::NUMERIC FROM ini_value) = 0
GROUP BY
  pro_medi_table.procedure_cd,
  pro_medi_table.mst_cd,
  pro_medi_table.hosp_cd
UNION ALL
SELECT
  ''投与薬剤情報(薬剤）'' AS title,
  MIN(pro_medi_table.mst_cd) AS mst_cd,
  pro_medi_table.hosp_cd AS hosp_cd,
  MAX(mst.pricedure_name) AS pro_title,
  pro_medi_table.procedure_cd AS procedure_cd,
  CASE
    WHEN pro_medi_table.procedure_cd = -9999 THEN
        MAX(ini_value.oxgen_procedure_code)
    WHEN ((MAX(pro_medi_table.treat_date) >= MAX(mst.in_hosp_a_startdate)) AND (MAX(pro_medi_table.treat_date) >= MAX(mst.in_hosp_b_startdate))) THEN
      CASE
        WHEN MAX(mst.in_hosp_a_startdate) > MAX(mst.in_hosp_b_startdate) THEN
          CASE MAX(ini_value.hosp_get_mst_procedure)
            WHEN ''1'' THEN MAX(mst.in_hospital_cd_a1)
            WHEN ''2'' THEN MAX(mst.in_hospital_cd_a2)
          END
        WHEN MAX(mst.in_hosp_a_startdate) < MAX(mst.in_hosp_b_startdate) THEN
          CASE MAX(ini_value.hosp_get_mst_procedure)
            WHEN ''1'' THEN MAX(mst.in_hospital_cd_b1)
            WHEN ''2'' THEN MAX(mst.in_hospital_cd_b2)
          END
      END
    WHEN MAX(pro_medi_table.treat_date) >= MAX(mst.in_hosp_a_startdate) THEN
      CASE MAX(ini_value.hosp_get_mst_procedure)
        WHEN ''1'' THEN MAX(mst.in_hospital_cd_a1)
        WHEN ''2'' THEN MAX(mst.in_hospital_cd_a2)
      END
    WHEN MAX(pro_medi_table.treat_date) >= MAX(mst.in_hosp_b_startdate) THEN
      CASE MAX(ini_value.hosp_get_mst_procedure)
        WHEN ''1'' THEN MAX(mst.in_hospital_cd_b1)
        WHEN ''2'' THEN MAX(mst.in_hospital_cd_b2)
      END
    ELSE NULL
  END AS pro_hosp_cd
FROM
  (SELECT
    imi2.mst_cd AS mst_cd,
    imi2.hosp_cd AS hosp_cd,
    imi2.procedure_cd AS procedure_cd,
    imi2.treat_date AS treat_date
  FROM
    medi_indo imi2
  WHERE
    imi2.mst_cd IS NOT NULL
    AND imi2.is_shot = ''0''
    AND imi2.procedure_cd IS NOT NULL
UNION ALL
  SELECT
    ti2.mst_cd AS mst_cd,
    ti2.hosp_cd AS hosp_cd,
    ti2.procedure_cd AS procedure_cd,
    ti2.treat_date AS treat_date
  FROM
    treatment_info ti2
  WHERE
    ti2.mst_cd IS NOT NULL
    AND ti2.is_shot = ''0''
    AND ti2.procedure_cd IS NOT NULL
) AS pro_medi_table
LEFT JOIN mst_procedure mst
  ON mst.procedure_cd = pro_medi_table.procedure_cd
  AND mst.facility_cd = @facilityCd
CROSS JOIN ini_value
WHERE
  (SELECT medicine_send_type::NUMERIC FROM ini_value) = 1
GROUP BY
  pro_medi_table.procedure_cd,
  pro_medi_table.hosp_cd
)
, equip_union AS (
-- 医療材料情報（吸着カラム,1次膜,2次膜,医療材料情報）
SELECT
  title,
  hosp_cd
FROM
  (SELECT
    ''吸着カラム'' AS title,
    ads.*
  FROM
    rst_adsorption ads
  WHERE
    ads.mst_cd IS NOT NULL
UNION ALL
  SELECT
    ''1次膜'' AS title,
    one.*
  FROM
    rst_one_film one
  WHERE
    one.mst_cd IS NOT NULL
UNION ALL
  SELECT
    ''2次膜'' AS title,
    two.*
  FROM
    rst_two_film two
  WHERE
    two.mst_cd IS NOT NULL
UNION ALL
  SELECT
    ''医療材料情報'' AS title,
    iei.*
  FROM
    rst_equip_info iei
  WHERE
    iei.mst_cd IS NOT NULL    
) AS rst_equip_table
ORDER BY
  rst_equip_table.temp_no
)
, equip_sort_num AS (
SELECT
  DISTINCT ON
  (un.hosp_cd) un.hosp_cd AS hosp_cd,
  un.r_num
FROM
  (SELECT
    ROW_NUMBER() OVER () AS r_num,
    ut.hosp_cd
  FROM
    equip_union ut
) AS un
ORDER BY
  un.hosp_cd,
  un.r_num
)
, equip_sort_union AS (
-- 医療材料情報の合算とソート
SELECT
  ams.title,
  ams.hosp_cd AS hosp_cd,
  NULL AS proc_cd
FROM
  (SELECT
    STRING_AGG(DISTINCT title, ''-'') AS title,
    hosp_cd
  FROM
    equip_union
  GROUP BY
    hosp_cd
) AS ams
INNER JOIN equip_sort_num AS un ON un.hosp_cd = ams.hosp_cd
ORDER BY
  un.r_num
)
, union_table AS (
-- 全項目をUNION ALL
SELECT
  ''治療方法'' AS title,
  tre.hosp_cd AS hosp_cd,
  NULL AS proc_cd,
  NULL AS add_class
FROM
  rst_treatment tre
WHERE
  tre.hosp_cd IS NOT NULL
UNION ALL
SELECT
  ''透析困難コード'' AS title,
  ddi.hosp_cd AS hosp_cd,
  NULL AS proc_cd,
  NULL AS add_class
FROM
  dial_diff_info ddi
WHERE
  ddi.hosp_cd IS NOT NULL
UNION ALL
SELECT
  ''加算情報(加算項目)'' AS title,
  ai.hosp_cd AS hosp_cd,
  NULL AS proc_cd,
  NULL AS add_class
FROM
  addition_info ai
WHERE
  (ai.add_class <> ''13''
    OR COALESCE(ai.hosp_2_cd, '''') <> '''')
    AND ai.hosp_cd IS NOT NULL
UNION ALL
  SELECT
    ''ダイアライザ'' AS title,
    dia.hosp_cd AS hosp_cd,
    NULL AS proc_cd,
    NULL AS add_class
  FROM
    rst_dialyzer dia
  WHERE
    dia.hosp_cd IS NOT NULL
UNION ALL
  SELECT
    eu.title AS title,
    eu.hosp_cd AS hosp_cd,
    NULL AS proc_cd,
    NULL AS add_class
  FROM
    equip_sort_union eu
  WHERE
    eu.hosp_cd IS NOT NULL
UNION ALL
  SELECT
    mu1.title AS title,
    mu1.hosp_cd AS hosp_cd,
    NULL AS proc_cd,
    NULL AS add_class
  FROM
    medi_union_1 mu1
  WHERE
    mu1.hosp_cd IS NOT NULL
UNION ALL
  SELECT
    ''加算情報(医学管理科)'' AS title,
    ai.hosp_cd AS hosp_cd,
    NULL AS proc_cd,
    ai.add_class AS add_class
  FROM
    addition_info ai
  WHERE
    (ai.add_class = ''13''
      AND COALESCE(ai.hosp_2_cd, '''') = '''')
    AND ai.hosp_cd IS NOT NULL
UNION ALL
  SELECT
    mu2.title AS title,
    mu2.hosp_cd AS hosp_cd,
    mu2.pro_hosp_cd AS proc_cd,
    NULL AS add_class
  FROM
    medi_union_2 mu2
  WHERE
    mu2.hosp_cd IS NOT NULL
    AND mu2.pro_hosp_cd IS NOT NULL
)
, numbered AS (
SELECT
  *,
  ROW_NUMBER() OVER () AS rn
FROM
  union_table
)
, recursive_rp AS (
-- 再帰で RP, RpItem を採番
SELECT
  n.rn,
  n.title,
  n.hosp_cd,
  n.proc_cd,
  n.add_class,
  1 AS RP,
  1 AS RpItem,
  NULL::text AS last_proc_cd,
  ARRAY[]::text[] AS proc_cd_list,
  FALSE AS need_procedure_insert,
  FALSE AS need_treatment_insert
FROM
  numbered n,
  ini_value m
WHERE
  n.rn = 1
UNION ALL
SELECT
  n.rn,
  n.title,
  n.hosp_cd,
  n.proc_cd,
  n.add_class,
  CASE
    WHEN n.proc_cd IS NOT NULL AND NOT (n.proc_cd = ANY(r.proc_cd_list)) THEN r.RP + 1
    WHEN r.RpItem >= 20 OR (m.medicine_send_type::NUMERIC = 0
      AND n.proc_cd IS NOT NULL) THEN r.RP + 1
    WHEN r.RpItem >= 20 OR n.proc_cd IS NULL
      AND n.add_class IS NOT NULL THEN r.RP + 1
    ELSE r.RP
  END AS RP,
  CASE
    WHEN ((n.proc_cd IS NOT NULL AND NOT (n.proc_cd = ANY(r.proc_cd_list)))
      OR (r.RpItem >= 20
      OR (m.medicine_send_type::NUMERIC = 0
      AND n.proc_cd IS NOT NULL))) THEN 2
    WHEN r.RpItem >= 20
      OR n.proc_cd IS NULL
      AND n.add_class IS NOT NULL THEN 1
    ELSE r.RpItem + 1
  END AS RpItem,
  CASE
    WHEN n.proc_cd IS NOT NULL THEN n.proc_cd
    ELSE r.last_proc_cd
  END AS last_proc_cd,
  CASE
    WHEN n.proc_cd IS NOT NULL
      AND NOT (n.proc_cd = ANY(r.proc_cd_list)) THEN r.proc_cd_list || n.proc_cd
    ELSE r.proc_cd_list
  END AS proc_cd_list,
  CASE
    WHEN ((n.proc_cd IS NOT NULL
      AND NOT (n.proc_cd = ANY(r.proc_cd_list)))
      OR (m.medicine_send_type::NUMERIC = 0
      AND n.proc_cd IS NOT NULL)
      OR r.RpItem >= 20
      AND n.proc_cd IS NOT NULL) THEN TRUE
    ELSE FALSE
  END AS need_procedure_insert,
  CASE
    WHEN r.RpItem >= 20
      AND n.proc_cd IS NULL THEN TRUE
    ELSE FALSE
  END AS need_treatment_insert
FROM
  recursive_rp r
JOIN numbered n ON n.rn = r.rn + 1
CROSS JOIN ini_value m
)
, procedure_inserts AS (
-- 手技コード差し込み
SELECT
  RP,
  1 AS RpItem,
  ''手技コード'' AS title,
  last_proc_cd AS hosp_cd,
  NULL::text AS proc_cd,
  (rn - 0.5)::NUMERIC AS sort_key
FROM
  recursive_rp
WHERE
  need_procedure_insert
)
, treatment_inserts AS (
-- 治療項目コード差し込み
SELECT
  RP,
  1 AS RpItem,
  ''治療方法'' AS title,
  tre.hosp_cd AS hosp_cd,
  NULL::text AS proc_cd,
  (rn - 0.5)::NUMERIC AS sort_key
FROM
  recursive_rp
CROSS JOIN rst_treatment tre
WHERE
  need_treatment_insert
)
, recursive_rp_with_sort AS (
SELECT
  RP,
  RpItem,
  title,
  hosp_cd,
  proc_cd,
  rn::NUMERIC AS sort_key
FROM
  recursive_rp
)
, final_data AS (
SELECT
  RP,
  RpItem,
  title,
  hosp_cd,
  proc_cd,
  sort_key
FROM
  recursive_rp_with_sort
UNION ALL
SELECT
  RP,
  RpItem,
  title,
  hosp_cd,
  proc_cd,
  sort_key
FROM
  procedure_inserts
UNION ALL
SELECT
  RP,
  RpItem,
  title,
  hosp_cd,
  proc_cd,
  sort_key
FROM
  treatment_inserts
)
SELECT
  ''01'' AS detail_id,
  @facilityCd AS facility_cd,
  @ctlNo AS ctl_no,
  @key0 AS key0,
  @patId AS pat_id,
  @ordNo AS ord_no
WHERE
EXISTS (
  SELECT 1 FROM final_data
)
-- SQL: -1103014 end', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム連携 透析実績連携 処置実績ファイル_ファイル出力有無', '2025-08-04 13:58:54.92', CURRENT_TIMESTAMP, '[{"sql_cd": -1102004, "field_name": "pat_personal_info", "replace_var": "@patPersonalInfo"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1103013, '-- SQL: -1103013 begin
WITH ord_main_switch AS(
    -- ord_mainまたはord_main_restoreから、当連携処理のord_noに該当するの最新のレコードを取得する
    (
        SELECT TRUE AS is_from_ord_main,
            ord.rst_dialysis_state AS rst_dialysis_state,
            ord.rst_edition_date AS up_date_switch
        FROM ord_main ord
        WHERE ord.ord_no = @ordNo
            and is_del = ''0''
    )
    UNION
    (
        select FALSE AS is_from_ord_main,
            ord.rst_dialysis_state AS rst_dialysis_state,
            ord.del_date AS up_date_switch
        FROM ord_main_restore AS ord
            JOIN sys_coop_journal AS journal ON ord.ord_no = journal.ord_no
        WHERE ord.ord_no = @ordNo
            AND journal.ctl_no = @ctlNo
            AND ord.ord_no = journal.ord_no
            AND journal.reg_date >= ord.del_date
        ORDER BY del_date DESC
        LIMIT 1
    )
    ORDER BY up_date_switch DESC NULLS LAST
    LIMIT 1
)
, inject_cancel_file_output_flg AS (
    -- 注射中止ファイル出力有無を判断するフラグを取得する
    SELECT CASE
            -- 処理対象ord_noに紐づく最新のオーダーがord_main_restoreから取得できた場合
            -- 注射中止ファイルを出力する
            WHEN oms.is_from_ord_main = FALSE THEN TRUE 
            -- それ以外の場合
            -- rst_dialysis_stateが存在して、ord_main_restore.del_dateよりも最新の場合（実績が更新されている）
            -- 注射中止ファイルを出力しない
            ELSE FALSE
        END AS value
    FROM ord_main_switch AS oms
)
, raw_data AS (
	SELECT @contentJson::jsonb AS data
)
, rows AS (
	SELECT JSONB_ARRAY_ELEMENTS(data) AS row
	FROM raw_data
)
, get_rp_no AS (
    SELECT row ->> 8 AS rp_no
    FROM rows
)
SELECT
    ''01'' AS detail_id,
    rp_no AS rp_no
FROM get_rp_no
WHERE (select value from inject_cancel_file_output_flg)
    AND EXISTS (
    SELECT 1 FROM rows
    )
ORDER BY rp_no::int
-- SQL: -1103013 end', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム連携 透析実績連携 注射中止ファイル', '2025-08-01 15:43:21.288', CURRENT_TIMESTAMP, '[{"sql_cd": -1103016, "field_name": "content_json", "replace_var": "@contentJson"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1103012, '-- SQL: -1103012 begin
select  
''01'' as detail_id,
@fileName AS file_name,
@folderName AS folder_name
-- SQL: -1103012 end', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム連携 透析実績連携 注射実績ファイル_ファイル作成終了', '2025-07-30 10:00:11.29', CURRENT_TIMESTAMP, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1103011, '-- SQL: -1103011 begin
select  
''01'' as detail_id,
@fileName AS file_name,
@folderName AS folder_name,
@rpNo AS rp_no
-- SQL: -1103011 end', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム連携 透析実績連携 注射実績ファイル_処置項目', '2025-07-30 10:00:11.29', CURRENT_TIMESTAMP, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1103010, '-- SQL: -1103010 begin
select  
''01'' as detail_id,
@fileName AS file_name,
@folderName AS folder_name,
@rpNo AS rp_no
-- SQL: -1103010 end', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム連携 透析実績連携 注射実績ファイル_オーダーインデックス', '2025-07-30 10:00:11.29', CURRENT_TIMESTAMP, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1103009, '-- SQL: -1103009 begin
select  
''01'' as detail_id,
@fileName AS file_name,
@folderName AS folder_name
-- SQL: -1103009 end', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム連携 透析実績連携 処置実績ファイル_ファイル作成終了', '2025-07-30 10:00:11.29', CURRENT_TIMESTAMP, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1103008, '-- SQL: -1103008 begin
select  
''01'' as detail_id,
@fileName AS file_name,
@folderName AS folder_name
-- SQL: -1103008 end', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム連携 透析実績連携 処置実績ファイル_処置項目', '2025-07-30 10:00:11.29', CURRENT_TIMESTAMP, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1103007, '-- SQL: -1103007 begin
select  
''01'' as detail_id,
@fileName AS file_name,
@folderName AS folder_name
-- SQL: -1103007 end', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム連携 透析実績連携 処置実績ファイル_処置単位', '2025-07-30 10:00:11.29', CURRENT_TIMESTAMP, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1103006, '-- SQL: -1103006 begin
select  
''01'' as detail_id,
@fileName AS file_name,
@folderName AS folder_name
-- SQL: -1103006 end', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム連携 透析実績連携 処置実績ファイル_処置ヘッダー', '2025-07-30 10:00:11.29', CURRENT_TIMESTAMP, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1103005, '-- SQL: -1103005 begin
select  
''01'' as detail_id,
@fileName AS file_name,
@folderName AS folder_name
-- SQL: -1103005 end', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム連携 透析実績連携 処置実績ファイル_オーダーインデックス', '2025-07-30 10:00:11.29', CURRENT_TIMESTAMP, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1103004, 'WITH RECURSIVE coop_ini_info AS (
--連携設定から取得
SELECT
  COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value,
  info ->> ''key1'' AS key1,
  info ->> ''key2'' AS key2
FROM
  mst_coop_ini AS ini
CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
WHERE
  ini.facility_cd = @facilityCd
  AND ini.is_del = ''0''
  AND COALESCE(info ->> ''key0'', '''') = @key0
  AND info ->> ''key1'' IN(
            ''SCM_CONV_UNIT_MEDI'',
            ''SCM_IN_HOSPITAL_CD'',
            ''SCM_COMMON''
        )
)
, ini_unit AS (
    SELECT
        key2,
        value
    FROM
        coop_ini_info
    WHERE
        key1 = ''SCM_CONV_UNIT_MEDI''
)

, ini_value AS(
--連携設定取得値
SELECT
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_MEDICINE'') AS hosp_get_mst_medicine,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_PROCEDURE'') AS hosp_get_mst_procedure
  )
, mst_medi_mix AS (
--調整薬剤マスタ
SELECT
  t1.idx AS idx,
  medicine_mix_cd AS mix_cd,
  t1.info ->> ''solvent'' AS solvent,
  t1.info ->> ''cd'' AS medi_cd,
  t1.info ->> ''amount'' AS amount,
  mst.unit AS unit,
  mst.is_shot AS is_shot,
  mst.in_hospital_cd_1 AS in_hospital_cd_1,
  mst.in_hospital_cd_2 AS in_hospital_cd_2,
  mst.in_hospital_cd_3 AS in_hospital_cd_3,
  mst.in_hospital_cd_4 AS in_hospital_cd_4,
  mst.is_disp as is_disp,
  mst.is_del as is_del  
FROM
  mst_medicine_mix mix
CROSS JOIN LATERAL json_array_elements(mix.mix_info ::json) WITH ORDINALITY AS t1(info, idx)
INNER JOIN mst_medicine AS mst ON mst.medicine_cd::text = info ->> ''cd''
  AND mst.is_shot = ''1''
  AND mst.is_del = ''0''
  AND mst.is_disp = ''1''
WHERE
  mix.is_del = ''0''
  AND mix.facility_cd = @facilityCd
  AND mst.facility_cd = @facilityCd
)
, do_ord_main AS (
(SELECT
  res.del_date as up_date_switch,
  res.rst_medi_info AS rst_medi_info,
  res.treat_date::TIMESTAMP AS treat_date
FROM ord_main_restore as res
JOIN sys_coop_journal AS journal ON res.ord_no = journal.ord_no
WHERE res.ord_no = @ordNo
  AND res.facility_cd = @facilityCd
  AND journal.facility_cd = @facilityCd
  AND journal.ctl_no = @ctlNo
  AND journal.reg_date >= res.del_date
ORDER BY res.del_date DESC LIMIT 1
)
UNION
(SELECT
  main.rst_edition_date as up_date_switch,
  main.rst_medi_info AS rst_medi_info,
  main.treat_date::TIMESTAMP AS treat_date
FROM ord_main AS main
  WHERE main.ord_no = @ordNo
  AND main.facility_cd = @facilityCd
)
ORDER BY
  up_date_switch DESC NULLS LAST
LIMIT 1
)
, medi_indo AS (
-- 投与薬剤情報
SELECT
  t1.idx as idx,
  t1.medi_info ->> ''cd'' AS mst_cd,
  CASE
    WHEN (om.treat_date >= mst_pro.in_hosp_a_startdate) 
      AND (om.treat_date >= mst_pro.in_hosp_b_startdate) THEN
      CASE
        WHEN mst_pro.in_hosp_a_startdate >= mst_pro.in_hosp_b_startdate THEN
          CASE ini_value.hosp_get_mst_procedure
            WHEN ''1'' THEN mst_pro.in_hospital_cd_a1
            WHEN ''2'' THEN mst_pro.in_hospital_cd_a2
          END
        WHEN mst_pro.in_hosp_a_startdate < mst_pro.in_hosp_b_startdate THEN
          CASE ini_value.hosp_get_mst_procedure
            WHEN ''1'' THEN mst_pro.in_hospital_cd_b1
            WHEN ''2'' THEN mst_pro.in_hospital_cd_b2
          END
      END
    WHEN om.treat_date >= mst_pro.in_hosp_a_startdate THEN
      CASE ini_value.hosp_get_mst_procedure
        WHEN ''1'' THEN mst_pro.in_hospital_cd_a1
        WHEN ''2'' THEN mst_pro.in_hospital_cd_a2
      END
    WHEN om.treat_date >= mst_pro.in_hosp_b_startdate THEN
      CASE ini_value.hosp_get_mst_procedure
        WHEN ''1'' THEN mst_pro.in_hospital_cd_b1
        WHEN ''2'' THEN mst_pro.in_hospital_cd_b2
      END
    ELSE NULL
  END AS pro_hosp_cd,
  CASE
    WHEN json_array_length(om.rst_medi_info::json) = 0 THEN NULL
    ELSE
      CASE t1.medi_info ->> ''medicine_type''
        WHEN ''1'' THEN
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_medi.in_hospital_cd_1
            WHEN ''2'' THEN mst_medi.in_hospital_cd_2
            WHEN ''3'' THEN mst_medi.in_hospital_cd_3
            WHEN ''4'' THEN mst_medi.in_hospital_cd_4
            ELSE NULL
          END
        WHEN ''2'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_mix.in_hospital_cd_1
            WHEN ''2'' THEN mst_mix.in_hospital_cd_2
            WHEN ''3'' THEN mst_mix.in_hospital_cd_3
            WHEN ''4'' THEN mst_mix.in_hospital_cd_4
            ELSE NULL
          END
      END
  END AS hosp_cd,
  CASE
    WHEN json_array_length(om.rst_medi_info::json) = 0 THEN NULL
    ELSE
      CASE t1.medi_info ->> ''medicine_type''
        WHEN ''1'' THEN (medi_info ->> ''amount'')::numeric
        WHEN ''2'' THEN
          CASE mst_mix.solvent
            WHEN ''0'' THEN
              (medi_info ->> ''amount'')::numeric * mst_mix.amount::numeric
            WHEN ''1'' THEN
              mst_mix.amount::numeric
          END
        ELSE 0
      END
  END AS amount,
  CASE
    WHEN json_array_length(om.rst_medi_info::json) = 0 THEN NULL
    ELSE
          CASE t1.medi_info ->> ''medicine_type''
            WHEN ''1'' THEN mst_medi.unit
            WHEN ''2'' THEN mst_mix.unit
          END
  END AS unit,
  CASE
    WHEN json_array_length(om.rst_medi_info::json) = 0 THEN NULL
    ELSE
      CASE t1.medi_info ->> ''medicine_type''
        WHEN ''1'' THEN mst_medi.is_shot
        WHEN ''2'' THEN mst_mix.is_shot
      END
  END AS is_shot,
  CASE t1.medi_info ->> ''medicine_type''
    WHEN ''1'' THEN mst_medi.is_disp 
    WHEN ''2'' THEN mst_mix.is_disp 
  END AS is_disp
FROM
  do_ord_main om
CROSS JOIN LATERAL json_array_elements(om.rst_medi_info::json) WITH ORDINALITY AS t1(medi_info, idx)
LEFT JOIN mst_medicine AS mst_medi ON mst_medi.medicine_cd::text = medi_info ->> ''cd''
  AND medi_info ->> ''medicine_type''::text = ''1'' AND mst_medi.facility_cd = @facilityCd
LEFT JOIN mst_medi_mix AS mst_mix ON mst_mix.mix_cd::text = medi_info ->> ''cd''
  AND medi_info ->> ''medicine_type''::text = ''2''
LEFT JOIN mst_procedure AS mst_pro ON mst_pro.procedure_cd::text = t1.medi_info ->> ''procedure_cd'' AND mst_pro.facility_cd = @facilityCd
CROSS JOIN ini_value
WHERE
  medi_info ->> ''effect_flg'' = ''1''

  AND (
    (medi_info ->> ''medicine_type''::text = ''1'' AND  mst_medi.is_del = ''0'')
    OR
    (medi_info ->> ''medicine_type''::text = ''2'' AND  mst_mix.is_del = ''0'')
  )
  
)
-- 送信履歴メモ.memoから取得
, memo_text AS (
SELECT
  save_2->>''memo'' AS memo
FROM
  pat_coop_detail
WHERE
  pat_id = @patId
  AND save_2->>''coop_cd'' = ''ind_dial''
  AND pat_coop_detail.facility_cd = @facilityCd
  AND save_2->>''ord_no'' = @ordNo::text
ORDER BY
  up_date DESC
LIMIT 1
)
, bounds AS (
SELECT
  memo,
  POSITION(''#I|'' IN memo) AS i_pos,
  POSITION(''#K'' IN memo) AS k_pos
FROM
  memo_text
)
, extracted AS (
SELECT
  substring(memo FROM i_pos + 3 FOR k_pos - (i_pos + 3)) AS i_segment
FROM
  bounds
)
, split_parts AS (
SELECT
  string_to_array(i_segment, ''|'') AS parts
FROM
  extracted
)
, item_info AS (
SELECT
  parts[i] AS item_value,
  i - 4 AS item_index
FROM
  split_parts,
  generate_series(5, CARDINALITY(parts)) AS i
)
, get_items AS (
SELECT
  item_index,
  item_value,
  substring(item_value FROM 1 FOR 2) AS rp_no,
  substring(item_value FROM 3 FOR 2) AS technique,
  substring(item_value FROM 5 FOR 2) AS med_no,
  substring(item_value FROM 7 FOR 6) AS med_code
FROM
  item_info
)
-- 同手技同薬剤コードは一つだけ出力
, get_items_total AS (
  SELECT DISTINCT ON (technique, med_code) *
    FROM get_items
    ORDER BY technique, med_code, item_index
)
-- コード桁数処理
, medi_indo_mi_cut AS (
  SELECT
    *,
    CASE
      WHEN octet_length(hosp_cd) <= 4 THEN hosp_cd
      ELSE (
        SELECT substring(hosp_cd FROM MIN(i))
        FROM generate_series(1, char_length(hosp_cd)) AS i
        WHERE octet_length(substring(hosp_cd FROM i)) <= 6
      )
    END AS hosp_cd_trimmed,
    RIGHT(pro_hosp_cd, 2) as pro_hosp_cd_trimmed
  FROM medi_indo
),
 unit_choice AS (
  SELECT DISTINCT ON (hosp_cd_trimmed, pro_hosp_cd_trimmed)
    hosp_cd_trimmed,
    pro_hosp_cd,
    unit
  FROM medi_indo_mi_cut
  WHERE is_shot = ''1'' AND is_disp = ''1''
  ORDER BY hosp_cd_trimmed, pro_hosp_cd_trimmed, idx
)

,select_seq AS (
select
  gi.rp_no::numeric AS rp_no,
  gi.med_no::numeric AS medi_no,
  mi.hosp_cd_trimmed AS medi_cd,
  LEAST(SUM(TRUNC(mi.amount, 2)::FLOAT8), 9999999.99)::text AS amount,
  MIN(ini_unit.value) AS unit
FROM
  get_items_total gi
INNER JOIN medi_indo_mi_cut AS mi ON gi.med_code = LPAD(mi.hosp_cd_trimmed, 6,'' '')
  AND gi.technique = LPAD(pro_hosp_cd_trimmed, 2,'' '')
LEFT JOIN unit_choice uc
  ON mi.hosp_cd_trimmed = uc.hosp_cd_trimmed
  AND mi.pro_hosp_cd = uc.pro_hosp_cd
LEFT JOIN ini_unit
  ON uc.unit = ini_unit.key2
WHERE
  mi.is_shot = ''1'' and 
  mi.is_disp = ''1''
  
GROUP BY gi.rp_no, gi.med_no, mi.hosp_cd_trimmed

ORDER BY rp_no, medi_no
)
SELECT DISTINCT
  ''01'' AS detail_id,
  rp_no
FROM
  select_seq
WHERE EXISTS (
  SELECT 1 FROM select_seq
)
ORDER BY
  rp_no', '2', '[{}]', '0', '{"applications": [4]}', NULL, '(送信用)セコムの透析実績連携', '2025-07-16 14:50:48.578', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1103003, E'-- SQL: -1103003 begin
WITH RECURSIVE coop_ini_info AS (
--連携設定より取得
SELECT
  COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value,
  info ->> ''key1'' AS key1,
  info ->> ''key2'' AS key2
FROM
  mst_coop_ini AS ini
CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
WHERE
  facility_cd = @facilityCd
  AND is_del = ''0''
  AND COALESCE(info ->> ''key0'', '''') = @key0
  AND info ->> ''key1'' IN (
        ''SCM_COMMON'',
        ''SCM_CONV_UNIT_MEDI'',
        ''SCM_CONV_UNIT_EQUIP'',
        ''SCM_IN_HOSPITAL_CD'',
        ''SCM_DIALYSISSEND''
    )
)
, ini_value AS (
--連携設定からvalue値取得
SELECT
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''MEDICINE_SEND_TYPE'') AS medicine_send_type,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_TREATMENT'') AS hosp_get_mst_treatment,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_DIALYZER'') AS hosp_get_mst_dialyzer,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_EQUIPMENT'') AS hosp_get_mst_equipment,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_MEDICINE'') AS hosp_get_mst_medicine,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_PROCEDURE'') AS hosp_get_mst_procedure,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_DIALYSIS_DIFFICULTY'') AS hosp_get_mst_dia_diff,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_ADDITION'') AS hosp_get_mst_addition,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND'' AND key2 = ''OXGEN_PROCEDURE_CODE'') AS oxgen_procedure_code,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND'' AND key2 = ''OXGEN_MEDI_CODE'') AS oxgen_medi_code,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND'' AND key2 = ''TREAT_CONVERT'') AS treat_convert,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND'' AND key2 = ''ADDITION_CD'') AS addition_cd
)
, addition_cd_list as (
SELECT
  UNNEST(string_to_array(addition_cd, '','')) AS set_value
FROM ini_value
)
, auth_info AS (
--患者個人情報取得(pre_sqlにて取得)
SELECT
  auth_info ->> ''dial_diff_cd'' AS dial_diff_cd,
  auth_info ->> ''is_dial_diff'' AS is_dial_diff
FROM
  json_array_elements(@patPersonalInfo::json) auth_info
)
, mst_medi_mix AS (
--調整薬剤マスタ
SELECT
  t1.idx AS idx,
  medicine_mix_cd AS mix_cd,
  t1.info ->> ''solvent'' AS solvent,
  t1.info ->> ''cd'' AS medi_cd,
  mst.is_shot AS is_shot,
  mst.in_hospital_cd_1 AS in_hospital_cd_1,
  mst.in_hospital_cd_2 AS in_hospital_cd_2,
  mst.in_hospital_cd_3 AS in_hospital_cd_3,
  mst.in_hospital_cd_4 AS in_hospital_cd_4
FROM
  mst_medicine_mix mix
CROSS JOIN LATERAL json_array_elements(mix.mix_info ::json) WITH ORDINALITY AS t1(info, idx)
INNER JOIN mst_medicine AS mst ON mst.medicine_cd::text = info ->> ''cd''
  AND mst.facility_cd = @facilityCd
  AND mst.is_shot = ''0''
  AND mst.is_del = ''0''
  AND mst.is_disp = ''1''
WHERE
  mix.is_del = ''0''
  AND mix.facility_cd = @facilityCd
)
, do_ord_main AS (
(SELECT
  res.del_date as up_date_switch,
  res.rst_treatment_cd as rst_treatment_cd,
  res.rst_cond_info as rst_cond_info,
  res.rst_medi_info AS rst_medi_info,
  res.rst_treatment_info as rst_treatment_info,
  res.rst_equip_info as rst_equip_info,
  res.addition_info as addition_info,
  res.treat_date::TIMESTAMP AS treat_date,
  res.rst_start_date AS rst_start_date,
  res.rst_end_date AS rst_end_date
FROM ord_main_restore as res
JOIN sys_coop_journal AS journal ON res.ord_no = journal.ord_no
WHERE res.ord_no = @ordNo
  AND res.facility_cd = @facilityCd
  AND res.pat_id = @patId
  AND res.is_del = ''0''
  AND res.ord_no = journal.ord_no
  AND journal.ctl_no = @ctlNo
  AND journal.reg_date >= res.del_date
ORDER BY res.del_date DESC LIMIT 1
)
UNION
(SELECT
  main.rst_edition_date as up_date_switch,
  main.rst_treatment_cd as rst_treatment_cd,
  main.rst_cond_info as rst_cond_info,
  main.rst_medi_info AS rst_medi_info,
  main.rst_treatment_info as rst_treatment_info,
  main.rst_equip_info as rst_equip_info,
  main.addition_info as addition_info,
  main.treat_date::TIMESTAMP AS treat_date,
  main.rst_start_date AS rst_start_date,
  main.rst_end_date AS rst_end_date
FROM ord_main AS main
  WHERE main.ord_no = @ordNo
  AND main.facility_cd = @facilityCd
  AND main.pat_id = @patId
  AND main.is_del = ''0''
)
ORDER BY
  up_date_switch DESC NULLS LAST
LIMIT 1
)
, treat_convert_part AS (
-- 連携設定.治療方法変換設定をテーブル化
SELECT
  key2 AS hosp_cd,
  split_part(t1.set_value, '','', 1) AS dialysis_time,
  split_part(t1.set_value, '','', 2) AS convert_cd,
  t1.no
FROM
  (SELECT
    key2
    , UNNEST(string_to_array(value, ''_'')) AS set_value
    ,generate_subscripts(string_to_array(value, ''_''), 1) as no
  FROM
    coop_ini_info ini
  WHERE key1 = ''SCM_DIALYSISSEND''
 ) t1
)
, parsed_ranges_check AS (
-- 治療方法変換設定チェック
SELECT distinct
  hosp_cd,
  ''NG'' AS check_result
FROM (
  SELECT
    CASE WHEN dialysis_time ~ ''^\\d+(\\.\\d+)?$''
    THEN NULLIF(dialysis_time, '''')
    ELSE NULL
    END AS lower_bound,
    NULLIF(convert_cd, '''') AS value,
    treat_convert_part.hosp_cd
  FROM treat_convert_part
) check_part
WHERE lower_bound IS NULL
  OR value IS NULL
)
, treat_convert AS (
    SELECT
        treat_convert_part.hosp_cd,
        convert_cd AS convert_cd,
        dialysis_time::numeric AS lower_bound,
        lead(dialysis_time::numeric, 1, 100000) OVER (PARTITION BY treat_convert_part.hosp_cd ORDER BY dialysis_time::numeric) -0.0001 AS upper_bound
    FROM treat_convert_part
    LEFT JOIN parsed_ranges_check on treat_convert_part.hosp_cd = parsed_ranges_check.hosp_cd
    WHERE parsed_ranges_check.check_result IS NULL
)
, ord_main_tre AS (
-- 治療方法コード
SELECT
  1000 AS temp_no,
  om.rst_treatment_cd AS mst_cd,
  CASE
    -- 両方とも利用開始日以降の場合
    WHEN ((om.treat_date::TIMESTAMP >= mt.in_hosp_a_startdate)
      AND (om.treat_date::TIMESTAMP >= mt.in_hosp_b_startdate)) THEN
        CASE
          WHEN mt.in_hosp_a_startdate > mt.in_hosp_b_startdate THEN
            CASE ini_value.hosp_get_mst_treatment
              WHEN ''1'' THEN mt.in_hospital_cd_a1
              WHEN ''2'' THEN mt.in_hospital_cd_a2
              WHEN ''3'' THEN mt.in_hospital_cd_a3
              WHEN ''4'' THEN mt.in_hospital_cd_a4
            END
          WHEN mt.in_hosp_a_startdate < mt.in_hosp_b_startdate THEN
            CASE ini_value.hosp_get_mst_treatment
              WHEN ''1'' THEN mt.in_hospital_cd_b1
              WHEN ''2'' THEN mt.in_hospital_cd_b2
              WHEN ''3'' THEN mt.in_hospital_cd_b3
              WHEN ''4'' THEN mt.in_hospital_cd_b4
            END
        END
    -- 治療日よりAの利用日開始日以降の場合
    WHEN om.treat_date::TIMESTAMP >= mt.in_hosp_a_startdate THEN
      CASE ini_value.hosp_get_mst_treatment
        WHEN ''1'' THEN mt.in_hospital_cd_a1
        WHEN ''2'' THEN mt.in_hospital_cd_a2
        WHEN ''3'' THEN mt.in_hospital_cd_a3
        WHEN ''4'' THEN mt.in_hospital_cd_a4
      END
    -- 治療日よりBの利用日開始日以降の場合
    WHEN om.treat_date::TIMESTAMP >= mt.in_hosp_b_startdate THEN
      CASE ini_value.hosp_get_mst_treatment
        WHEN ''1'' THEN mt.in_hospital_cd_b1
        WHEN ''2'' THEN mt.in_hospital_cd_b2
        WHEN ''3'' THEN mt.in_hospital_cd_b3
        WHEN ''4'' THEN mt.in_hospital_cd_b4
      END
    ELSE NULL
  END AS hosp_cd,
  FLOOR(EXTRACT(epoch FROM (date_trunc(''minute'', om.rst_end_date) - date_trunc(''minute'', om.rst_start_date))) / 60) AS dialysis_time
FROM
  do_ord_main om
INNER JOIN mst_treatment AS mt ON mt.treatment_cd = om.rst_treatment_cd
  AND mt.facility_cd = @facilityCd
CROSS JOIN ini_value
)
, ind_treatment AS (
SELECT
  CASE ini_value.treat_convert
    WHEN ''0'' THEN tre.hosp_cd
    WHEN ''1'' THEN tc.convert_cd
  END AS hosp_cd,
  NULL AS proc_cd
FROM
  ord_main_tre tre
LEFT JOIN treat_convert tc ON tc.hosp_cd = tre.hosp_cd
AND tre.dialysis_time BETWEEN tc.lower_bound AND tc.upper_bound
CROSS JOIN ini_value
)
, ind_dialyzer AS (
-- ダイアライザ
SELECT
  2000 AS temp_no,
  om.rst_cond_info->''5''->>''value'' AS mst_cd,
  CASE ini_value.hosp_get_mst_dialyzer
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd
FROM
  do_ord_main om
INNER JOIN mst_dialyzer AS mst ON mst.dialyzer_cd::text = om.rst_cond_info ->''5''->>''value''
  AND mst.facility_cd = @facilityCd
CROSS JOIN ini_value
)
, ind_adsorption AS (
-- 吸着カラム
SELECT
  2100 AS temp_no,
  om.rst_cond_info->''6''->>''value'' AS mst_cd,
  CASE ini_value.hosp_get_mst_equipment
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd
FROM
  do_ord_main om
INNER JOIN mst_equipment AS mst ON mst.equipment_cd::text = om.rst_cond_info->''6''->>''value''
  AND mst.facility_cd = @facilityCd
CROSS JOIN ini_value
)
, ind_coagulant AS (
-- 抗凝固剤
SELECT
  3000 AS temp_no,
  om.rst_cond_info->''25''->>''value'' AS mst_cd,
  (om.rst_cond_info->''25''->>''medicine_type'')::integer AS medicine_type,
  NULL::integer AS procedure_cd,
  CASE
    WHEN COALESCE(om.rst_cond_info->''25''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE om.rst_cond_info->''25''->>''medicine_type''
        WHEN ''1'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_medi.in_hospital_cd_1
            WHEN ''2'' THEN mst_medi.in_hospital_cd_2
            WHEN ''3'' THEN mst_medi.in_hospital_cd_3
            WHEN ''4'' THEN mst_medi.in_hospital_cd_4
            ELSE NULL
          END
        WHEN ''2'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_mix.in_hospital_cd_1
            WHEN ''2'' THEN mst_mix.in_hospital_cd_2
            WHEN ''3'' THEN mst_mix.in_hospital_cd_3
            WHEN ''4'' THEN mst_mix.in_hospital_cd_4
            ELSE NULL
          END
      END
  END AS hosp_cd
FROM
  do_ord_main om
LEFT JOIN mst_medicine AS mst_medi ON mst_medi.medicine_cd::text = om.rst_cond_info->''25''->>''value''
  AND mst_medi.facility_cd = @facilityCd
  AND mst_medi.is_shot = ''0''
  AND mst_medi.is_del = ''0''
  AND mst_medi.is_disp = ''1''
  AND om.rst_cond_info->''25''->>''medicine_type''::text = ''1''
LEFT JOIN mst_medi_mix AS mst_mix ON mst_mix.mix_cd::text = om.rst_cond_info->''25''->>''value''
  AND om.rst_cond_info->''25''->>''medicine_type''::text = ''2''
CROSS JOIN ini_value
)
, ind_touseki AS (
-- 透析液
SELECT
  3100 AS temp_no,
  om.rst_cond_info->''15''->>''value'' AS mst_cd,
  (om.rst_cond_info->''15''->>''medicine_type'')::integer AS medicine_type,
  NULL::integer AS procedure_cd,
  CASE
    WHEN COALESCE(om.rst_cond_info->''15''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE om.rst_cond_info->''15''->>''medicine_type''
        WHEN ''1'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_medi.in_hospital_cd_1
            WHEN ''2'' THEN mst_medi.in_hospital_cd_2
            WHEN ''3'' THEN mst_medi.in_hospital_cd_3
            WHEN ''4'' THEN mst_medi.in_hospital_cd_4
            ELSE NULL
          END
        WHEN ''2'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_mix.in_hospital_cd_1
            WHEN ''2'' THEN mst_mix.in_hospital_cd_2
            WHEN ''3'' THEN mst_mix.in_hospital_cd_3
            WHEN ''4'' THEN mst_mix.in_hospital_cd_4
            ELSE NULL
          END
      END
  END AS hosp_cd
FROM
  do_ord_main om
LEFT JOIN mst_medicine AS mst_medi ON mst_medi.medicine_cd::text = om.rst_cond_info->''15''->>''value''
  AND mst_medi.facility_cd = @facilityCd
  AND mst_medi.is_shot = ''0''
  AND mst_medi.is_del = ''0''
  AND mst_medi.is_disp = ''1''
  AND om.rst_cond_info->''15''->>''medicine_type''::text = ''1''
LEFT JOIN mst_medi_mix AS mst_mix ON mst_mix.mix_cd::text = om.rst_cond_info->''15''->>''value''
  AND om.rst_cond_info->''15''->>''medicine_type''::text = ''2''
CROSS JOIN ini_value
)
, ind_hoeki AS (
-- 補液
SELECT
  3200 AS temp_no,
  om.rst_cond_info->''19''->>''value'' AS mst_cd,
  (om.rst_cond_info->''19''->>''medicine_type'')::integer AS medicine_type,
  NULL::integer AS procedure_cd,
  CASE
    WHEN COALESCE(om.rst_cond_info->''19''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE om.rst_cond_info->''19''->>''medicine_type''
        WHEN ''1'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_medi.in_hospital_cd_1
            WHEN ''2'' THEN mst_medi.in_hospital_cd_2
            WHEN ''3'' THEN mst_medi.in_hospital_cd_3
            WHEN ''4'' THEN mst_medi.in_hospital_cd_4
            ELSE NULL
          END
        WHEN ''2'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_mix.in_hospital_cd_1
            WHEN ''2'' THEN mst_mix.in_hospital_cd_2
            WHEN ''3'' THEN mst_mix.in_hospital_cd_3
            WHEN ''4'' THEN mst_mix.in_hospital_cd_4
            ELSE NULL
          END
      END
  END AS hosp_cd
FROM
  do_ord_main om
LEFT JOIN mst_medicine AS mst_medi ON mst_medi.medicine_cd::text = om.rst_cond_info->''19''->>''value''
  AND mst_medi.facility_cd = @facilityCd
  AND mst_medi.is_shot = ''0''
  AND mst_medi.is_del = ''0''
  AND mst_medi.is_disp = ''1''
  AND om.rst_cond_info->''19''->>''medicine_type''::text = ''1''
LEFT JOIN mst_medi_mix AS mst_mix ON mst_mix.mix_cd::text = om.rst_cond_info->''19''->>''value''
  AND om.rst_cond_info->''19''->>''medicine_type''::text = ''2''
CROSS JOIN ini_value
)
, ind_one_film AS (
-- 1次膜
SELECT
  2200 AS temp_no,
  om.rst_cond_info->''7''->>''value'' AS mst_cd,
  CASE ini_value.hosp_get_mst_equipment
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd
FROM
  do_ord_main om
INNER JOIN mst_equipment AS mst ON mst.equipment_cd::text = om.rst_cond_info->''7''->>''value''
  AND mst.facility_cd = @facilityCd
CROSS JOIN ini_value
)
, ind_two_film AS (
-- 2次膜
SELECT
  2300 AS temp_no,
  om.rst_cond_info->''8''->>''value'' AS mst_cd,
  CASE ini_value.hosp_get_mst_equipment
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd
FROM
  do_ord_main om
INNER JOIN mst_equipment AS mst ON mst.equipment_cd::text = om.rst_cond_info->''8''->>''value''
  AND mst.facility_cd = @facilityCd
CROSS JOIN ini_value
)
, medi_indo AS (
-- 投与薬剤情報
SELECT
  3300 + t1.idx AS temp_no,
  t1.medi_info ->> ''cd'' AS mst_cd,
  (t1.medi_info ->> ''medicine_type'')::integer AS medicine_type,
  (t1.medi_info ->> ''procedure_cd'')::integer AS procedure_cd,
  om.treat_date::TIMESTAMP AS treat_date,
  CASE
    WHEN json_array_length(om.rst_medi_info::json) = 0 THEN NULL
    ELSE
      CASE t1.medi_info ->> ''medicine_type''
        WHEN ''1'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_medi.in_hospital_cd_1
            WHEN ''2'' THEN mst_medi.in_hospital_cd_2
            WHEN ''3'' THEN mst_medi.in_hospital_cd_3
            WHEN ''4'' THEN mst_medi.in_hospital_cd_4
            ELSE NULL
          END
        WHEN ''2'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_mix.in_hospital_cd_1
            WHEN ''2'' THEN mst_mix.in_hospital_cd_2
            WHEN ''3'' THEN mst_mix.in_hospital_cd_3
            WHEN ''4'' THEN mst_mix.in_hospital_cd_4
            ELSE NULL
          END
      END
  END AS hosp_cd,
  CASE
    WHEN json_array_length(om.rst_medi_info::json) = 0 THEN NULL
    ELSE
      CASE t1.medi_info ->> ''medicine_type''
        WHEN ''1'' THEN mst_medi.is_shot
        WHEN ''2'' THEN mst_mix.is_shot
      END
  END AS is_shot
FROM
  do_ord_main om
CROSS JOIN LATERAL json_array_elements(om.rst_medi_info::json) WITH ORDINALITY AS t1(medi_info, idx)
LEFT JOIN mst_medicine AS mst_medi ON mst_medi.medicine_cd::text = medi_info ->> ''cd''
  AND medi_info ->> ''medicine_type''::text = ''1''
  AND mst_medi.facility_cd = @facilityCd
  AND mst_medi.is_del = ''0''
  AND mst_medi.is_disp = ''1''
LEFT JOIN mst_medi_mix AS mst_mix ON mst_mix.mix_cd::text = medi_info ->> ''cd''
  AND medi_info ->> ''medicine_type''::text = ''2''
CROSS JOIN ini_value
WHERE
  medi_info ->> ''effect_flg''::text = ''1''
)
, treatment_info AS (
-- 愁訴処置情報
SELECT
  3400 + t1.idx AS temp_no,
  CASE
    WHEN t1.tre_info ->> ''treat_class'' = ''3''
      AND t1.tre_info ->> ''oxygen_amount'' IS NOT NULL
      AND ini_value.oxgen_medi_code <> ''''
      AND ini_value.oxgen_procedure_code <> '''' THEN
      ''oxgen_medi_code''
    ELSE
      t1.tre_info ->> ''treat_medicine_cd''
  END AS mst_cd,
  (t1.tre_info ->> ''medicine_type'')::integer AS medicine_type,
  CASE
    WHEN t1.tre_info ->> ''treat_class'' = ''3''
      AND t1.tre_info ->> ''oxygen_amount'' IS NOT NULL
      AND ini_value.oxgen_medi_code <> ''''
      AND ini_value.oxgen_procedure_code <> '''' THEN
      -9999
    ELSE
      (t1.tre_info ->> ''procedure_cd'')::integer
  END AS procedure_cd,
  om.treat_date::TIMESTAMP AS treat_date,
  CASE
    WHEN json_array_length(om.rst_treatment_info::json) = 0 THEN NULL
    WHEN t1.tre_info ->> ''treat_class'' = ''3''
      AND t1.tre_info ->> ''oxygen_amount'' IS NOT NULL
      AND ini_value.oxgen_medi_code <> ''''
      AND ini_value.oxgen_procedure_code <> '''' THEN
      ini_value.oxgen_medi_code
    ELSE
      CASE t1.tre_info ->> ''medicine_type''
        WHEN ''1'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_medi.in_hospital_cd_1
            WHEN ''2'' THEN mst_medi.in_hospital_cd_2
            WHEN ''3'' THEN mst_medi.in_hospital_cd_3
            WHEN ''4'' THEN mst_medi.in_hospital_cd_4
            ELSE NULL
          END
        WHEN ''2'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_mix.in_hospital_cd_1
            WHEN ''2'' THEN mst_mix.in_hospital_cd_2
            WHEN ''3'' THEN mst_mix.in_hospital_cd_3
            WHEN ''4'' THEN mst_mix.in_hospital_cd_4
            ELSE NULL
          END
      END
  END AS hosp_cd,
  CASE
    WHEN json_array_length(om.rst_treatment_info::json) = 0 THEN NULL
    WHEN t1.tre_info ->> ''treat_class'' = ''3''
      AND t1.tre_info ->> ''oxygen_amount'' IS NOT NULL
      AND ini_value.oxgen_medi_code <> ''''
      AND ini_value.oxgen_procedure_code <> '''' THEN
      ''0''
    ELSE
      CASE t1.tre_info ->> ''medicine_type''
        WHEN ''1'' THEN mst_medi.is_shot
        WHEN ''2'' THEN mst_mix.is_shot
      END
  END AS is_shot
FROM
  do_ord_main om
CROSS JOIN LATERAL json_array_elements(om.rst_treatment_info::json) WITH ORDINALITY AS t1(tre_info, idx)
LEFT JOIN mst_medicine AS mst_medi ON mst_medi.medicine_cd::text = t1.tre_info ->> ''treat_medicine_cd''
  AND t1.tre_info ->> ''medicine_type''::text = ''1''
  AND mst_medi.facility_cd = @facilityCd
  AND mst_medi.is_shot = ''0''
  AND mst_medi.is_del = ''0''
  AND mst_medi.is_disp = ''1''
LEFT JOIN mst_medi_mix AS mst_mix ON mst_mix.mix_cd::text = t1.tre_info ->> ''treat_medicine_cd''
  AND t1.tre_info ->> ''medicine_type''::text = ''2''
CROSS JOIN ini_value
)
, ind_equip_info AS (
-- 医療材料コード
SELECT
  2400 + t1.idx AS temp_no,
  t1.equip_info ->> ''cd'' AS mst_cd,
  CASE ini_value.hosp_get_mst_equipment
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd
FROM
  do_ord_main om
CROSS JOIN LATERAL json_array_elements(om.rst_equip_info::json) WITH ORDINALITY AS t1(equip_info, idx)
INNER JOIN mst_equipment AS mst ON mst.equipment_cd::text = t1.equip_info ->> ''cd''
  AND mst.facility_cd = @facilityCd
CROSS JOIN ini_value
)
, dial_diff_info AS (
-- 透析困難コード
SELECT
  1300 AS temp_no,
  CASE ini_value.hosp_get_mst_dia_diff
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    ELSE NULL
  END AS hosp_cd
FROM
  auth_info ai
LEFT JOIN mst_dialysis_difficulty AS mst ON mst.dialysis_difficulty_cd::text = ai.dial_diff_cd
  AND mst.is_del = ''0''
  AND mst.facility_cd = @facilityCd
CROSS JOIN ini_value
WHERE
  ai.is_dial_diff = ''1''
)
, addition_info AS (
-- 加算情報
SELECT
  1300 + t1.idx AS temp_no,
  t1.addi_info ->> ''cd'' AS mst_cd,
  CASE ini_value.hosp_get_mst_addition
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    ELSE NULL
  END AS hosp_cd,
  mst.addition_class AS add_class
FROM
  do_ord_main om
LEFT JOIN LATERAL (
  SELECT x.elem, x.ord FROM do_ord_main om
  CROSS JOIN LATERAL jsonb_array_elements(om.addition_info) WITH ORDINALITY AS x(elem, ord)
  WHERE
    jsonb_typeof(om.addition_info) = ''array''
) AS t1(addi_info, idx) ON TRUE
LEFT JOIN mst_addition AS mst ON mst.addition_cd ::text = t1.addi_info ->> ''cd''
  AND mst.is_del = ''0''
  AND mst.facility_cd = @facilityCd
CROSS JOIN ini_value
)
, medi_union_1 AS (
-- 薬剤情報（抗凝固剤、透析液、補液、投与薬剤情報(手技なし)、愁訴処置情報（手技なし））
SELECT
  title,
  hosp_cd
FROM
  (SELECT
    coa.temp_no AS temp_no,
    coa.medicine_type AS medicine_type,
    coa.procedure_cd AS procedure_cd,
    ''抗凝固剤'' AS title,
    coa.mst_cd AS mst_cd,
    coa.hosp_cd AS hosp_cd
  FROM
    ind_coagulant coa
  WHERE
    coa.mst_cd IS NOT NULL
UNION ALL
  SELECT
    tou.temp_no AS temp_no,
    tou.medicine_type AS medicine_type,
    tou.procedure_cd AS procedure_cd,
    ''透析液'' AS title,
    tou.mst_cd AS mst_cd,
    tou.hosp_cd AS hosp_cd
  FROM
    ind_touseki tou
  WHERE
    tou.mst_cd IS NOT NULL
UNION ALL
  SELECT
    hoe.temp_no AS temp_no,
    hoe.medicine_type AS medicine_type,
    hoe.procedure_cd AS procedure_cd,
    ''補液'' AS title,
    hoe.mst_cd AS mst_cd,
    hoe.hosp_cd AS hosp_cd
  FROM
    ind_hoeki hoe
  WHERE
    hoe.mst_cd IS NOT NULL
UNION ALL
  SELECT
    MIN(pro_medi_table.temp_no) AS temp_no,
    MIN(pro_medi_table.medicine_type) AS medicine_type,
    MIN(pro_medi_table.procedure_cd) AS procedure_cd,
    ''投与薬剤情報(手技なし）'' AS title,
    MIN(pro_medi_table.mst_cd) AS mst_cd,
    pro_medi_table.hosp_cd AS hosp_cd
  FROM
  (SELECT
    imi.temp_no,
    imi.medicine_type,
    imi.mst_cd AS mst_cd,
    imi.hosp_cd AS hosp_cd,
    imi.procedure_cd AS procedure_cd,
    imi.treat_date AS treat_date
  FROM
    medi_indo imi
  WHERE
    imi.mst_cd IS NOT NULL
    AND imi.is_shot = ''0''
  UNION ALL
  SELECT
    ti.temp_no,
    ti.medicine_type,
    ti.mst_cd AS mst_cd,
    ti.hosp_cd AS hosp_cd,
    ti.procedure_cd AS procedure_cd,
    ti.treat_date AS treat_date
  FROM
    treatment_info ti
  WHERE
    ti.mst_cd IS NOT NULL
    AND ti.is_shot = ''0''
  ) AS pro_medi_table
  LEFT JOIN mst_procedure mst ON mst.procedure_cd = pro_medi_table.procedure_cd AND mst.facility_cd = @facilityCd
  CROSS JOIN ini_value
  WHERE
    pro_medi_table.procedure_cd IS NULL
    OR (
      pro_medi_table.procedure_cd <> -9999
      AND NULLIF(
        CASE
          -- ▼治療日が A/B の両開始日を満たしている場合（より新しい方を優先）
          WHEN pro_medi_table.treat_date >= mst.in_hosp_a_startdate
            AND pro_medi_table.treat_date >= mst.in_hosp_b_startdate THEN
            CASE
              -- Aの方が新しければA系の施設CDを参照
              WHEN mst.in_hosp_a_startdate > mst.in_hosp_b_startdate THEN
                CASE ini_value.hosp_get_mst_procedure
                  WHEN ''1'' THEN mst.in_hospital_cd_a1
                  WHEN ''2'' THEN mst.in_hospital_cd_a2
                END
              -- Bの方が新しければB系の施設CDを参照
              WHEN mst.in_hosp_a_startdate < mst.in_hosp_b_startdate THEN
                CASE ini_value.hosp_get_mst_procedure
                  WHEN ''1'' THEN mst.in_hospital_cd_b1
                  WHEN ''2'' THEN mst.in_hospital_cd_b2
                END
            END
          -- ▼治療日がAの開始日だけを満たしている場合
          WHEN pro_medi_table.treat_date >= mst.in_hosp_a_startdate THEN
            CASE ini_value.hosp_get_mst_procedure
              WHEN ''1'' THEN mst.in_hospital_cd_a1
              WHEN ''2'' THEN mst.in_hospital_cd_a2
            END
          -- ▼治療日がBの開始日だけを満たしている場合
          WHEN pro_medi_table.treat_date >= mst.in_hosp_b_startdate THEN
            CASE ini_value.hosp_get_mst_procedure
              WHEN ''1'' THEN mst.in_hospital_cd_b1
              WHEN ''2'' THEN mst.in_hospital_cd_b2
            END
          -- ▼どちらの開始日も満たしていない、またはNULL含む場合
          ELSE NULL
        END
        , '''') IS NULL
    )
  GROUP BY
    pro_medi_table.hosp_cd
) AS ind_medi_table
LEFT JOIN mst_procedure mp ON ind_medi_table.procedure_cd = mp.procedure_cd
CROSS JOIN do_ord_main om
CROSS JOIN ini_value
ORDER BY
  temp_no
)
, medi_union_2 AS (
-- 投与薬剤情報(手技あり)、愁訴処置情報（手技あり）
SELECT
  ''投与薬剤/愁訴処置情報(薬剤）'' AS title,
  mst_cd,
  hosp_cd,
  mst.pricedure_name AS pro_title,
  pro_medi_table.procedure_cd,
  CASE
    WHEN pro_medi_table.procedure_cd = -9999 THEN
      ini_value.oxgen_procedure_code
    WHEN ((pro_medi_table.treat_date >= mst.in_hosp_a_startdate)
      AND (pro_medi_table.treat_date >= mst.in_hosp_b_startdate)) THEN
      CASE
        WHEN mst.in_hosp_a_startdate > mst.in_hosp_b_startdate THEN
          CASE ini_value.hosp_get_mst_procedure
            WHEN ''1'' THEN mst.in_hospital_cd_a1
            WHEN ''2'' THEN mst.in_hospital_cd_a2
          END
        WHEN mst.in_hosp_a_startdate < mst.in_hosp_b_startdate THEN
          CASE ini_value.hosp_get_mst_procedure
            WHEN ''1'' THEN mst.in_hospital_cd_b1
            WHEN ''2'' THEN mst.in_hospital_cd_b2
          END
      END
    WHEN pro_medi_table.treat_date >= mst.in_hosp_a_startdate THEN
      CASE ini_value.hosp_get_mst_procedure
        WHEN ''1'' THEN mst.in_hospital_cd_a1
        WHEN ''2'' THEN mst.in_hospital_cd_a2
      END
    WHEN pro_medi_table.treat_date >= mst.in_hosp_b_startdate THEN
      CASE ini_value.hosp_get_mst_procedure
        WHEN ''1'' THEN mst.in_hospital_cd_b1
        WHEN ''2'' THEN mst.in_hospital_cd_b2
      END
    ELSE NULL
  END AS pro_hosp_cd
FROM
  (SELECT
    imi2.mst_cd AS mst_cd,
    imi2.hosp_cd AS hosp_cd,
    imi2.procedure_cd AS procedure_cd,
    imi2.treat_date AS treat_date
  FROM
    medi_indo imi2
  WHERE
    imi2.mst_cd IS NOT NULL
    AND imi2.is_shot = ''0''
    AND imi2.procedure_cd IS NOT NULL
UNION ALL
  SELECT
    ti2.mst_cd AS mst_cd,
    ti2.hosp_cd AS hosp_cd,
    ti2.procedure_cd AS procedure_cd,
    ti2.treat_date AS treat_date
  FROM
    treatment_info ti2
  WHERE
    ti2.mst_cd IS NOT NULL
    AND ti2.is_shot = ''0''
    AND ti2.procedure_cd IS NOT NULL
) AS pro_medi_table
LEFT JOIN mst_procedure mst ON mst.procedure_cd = pro_medi_table.procedure_cd
  AND mst.facility_cd = @facilityCd
CROSS JOIN ini_value
WHERE
  (SELECT medicine_send_type::NUMERIC FROM ini_value) = 0
UNION ALL
SELECT
  ''投与薬剤情報(薬剤）'' AS title,
  MIN(pro_medi_table.mst_cd) AS mst_cd,
  pro_medi_table.hosp_cd AS hosp_cd,
  MAX(mst.pricedure_name) AS pro_title,
  pro_medi_table.procedure_cd AS procedure_cd,
  CASE
    WHEN pro_medi_table.procedure_cd = -9999 THEN
        MAX(ini_value.oxgen_procedure_code)
    WHEN ((MAX(pro_medi_table.treat_date) >= MAX(mst.in_hosp_a_startdate)) AND (MAX(pro_medi_table.treat_date) >= MAX(mst.in_hosp_b_startdate))) THEN
      CASE
        WHEN MAX(mst.in_hosp_a_startdate) > MAX(mst.in_hosp_b_startdate) THEN
          CASE MAX(ini_value.hosp_get_mst_procedure)
            WHEN ''1'' THEN MAX(mst.in_hospital_cd_a1)
            WHEN ''2'' THEN MAX(mst.in_hospital_cd_a2)
          END
        WHEN MAX(mst.in_hosp_a_startdate) < MAX(mst.in_hosp_b_startdate) THEN
          CASE MAX(ini_value.hosp_get_mst_procedure)
            WHEN ''1'' THEN MAX(mst.in_hospital_cd_b1)
            WHEN ''2'' THEN MAX(mst.in_hospital_cd_b2)
          END
      END
    WHEN MAX(pro_medi_table.treat_date) >= MAX(mst.in_hosp_a_startdate) THEN
      CASE MAX(ini_value.hosp_get_mst_procedure)
        WHEN ''1'' THEN MAX(mst.in_hospital_cd_a1)
        WHEN ''2'' THEN MAX(mst.in_hospital_cd_a2)
      END
    WHEN MAX(pro_medi_table.treat_date) >= MAX(mst.in_hosp_b_startdate) THEN
      CASE MAX(ini_value.hosp_get_mst_procedure)
        WHEN ''1'' THEN MAX(mst.in_hospital_cd_b1)
        WHEN ''2'' THEN MAX(mst.in_hospital_cd_b2)
      END
    ELSE NULL
  END AS pro_hosp_cd
FROM
  (SELECT
    imi2.mst_cd AS mst_cd,
    imi2.hosp_cd AS hosp_cd,
    imi2.procedure_cd AS procedure_cd,
    imi2.treat_date AS treat_date
  FROM
    medi_indo imi2
  WHERE
    imi2.mst_cd IS NOT NULL
    AND imi2.is_shot = ''0''
    AND imi2.procedure_cd IS NOT NULL
UNION ALL
  SELECT
    ti2.mst_cd AS mst_cd,
    ti2.hosp_cd AS hosp_cd,
    ti2.procedure_cd AS procedure_cd,
    ti2.treat_date AS treat_date
  FROM
    treatment_info ti2
  WHERE
    ti2.mst_cd IS NOT NULL
    AND ti2.is_shot = ''0''
    AND ti2.procedure_cd IS NOT NULL
) AS pro_medi_table
LEFT JOIN mst_procedure mst
  ON mst.procedure_cd = pro_medi_table.procedure_cd
  AND mst.facility_cd = @facilityCd
CROSS JOIN ini_value
WHERE
  (SELECT medicine_send_type::NUMERIC FROM ini_value) = 1
GROUP BY
  pro_medi_table.procedure_cd,
  pro_medi_table.hosp_cd
)
, equip_union AS (
-- 医療材料情報（吸着カラム,1次膜,2次膜,医療材料情報）
SELECT
  title,
  hosp_cd
FROM
  (SELECT
    ''吸着カラム'' AS title,
    ads.*
  FROM
    ind_adsorption ads
  WHERE
    ads.mst_cd IS NOT NULL
UNION ALL
  SELECT
    ''1次膜'' AS title,
    one.*
  FROM
    ind_one_film one
  WHERE
    one.mst_cd IS NOT NULL
UNION ALL
  SELECT
    ''2次膜'' AS title,
    two.*
  FROM
    ind_two_film two
  WHERE
    two.mst_cd IS NOT NULL
UNION ALL
  SELECT
    ''医療材料情報'' AS title,
    iei.*
  FROM
    ind_equip_info iei
  WHERE
    iei.mst_cd IS NOT NULL    
) AS ind_equip_table
ORDER BY
  ind_equip_table.temp_no
)
, equip_sort_num AS (
SELECT
  DISTINCT ON
  (un.hosp_cd) un.hosp_cd AS hosp_cd,
  un.r_num
FROM
  (SELECT
    ROW_NUMBER() OVER () AS r_num,
    ut.hosp_cd
  FROM
    equip_union ut
) AS un
ORDER BY
  un.hosp_cd,
  un.r_num
)
, equip_sort_union AS (
-- 医療材料情報の合算とソート
SELECT
  ams.title,
  ams.hosp_cd AS hosp_cd,
  NULL AS proc_cd
FROM
  (SELECT
    STRING_AGG(DISTINCT title, ''-'') AS title,
    hosp_cd
  FROM
    equip_union
  GROUP BY
    hosp_cd
) AS ams
INNER JOIN equip_sort_num AS un ON un.hosp_cd = ams.hosp_cd
ORDER BY
  un.r_num
)
, union_table AS (
-- 全項目をUNION ALL
SELECT
  ''治療方法'' AS title,
  tre.hosp_cd AS hosp_cd,
  NULL AS proc_cd,
  NULL AS add_class
FROM
  ind_treatment tre
WHERE
  tre.hosp_cd IS NOT NULL
UNION ALL
SELECT
  ''透析困難コード'' AS title,
  ddi.hosp_cd AS hosp_cd,
  NULL AS proc_cd,
  NULL AS add_class
FROM
  dial_diff_info ddi
WHERE
  ddi.hosp_cd IS NOT NULL
UNION ALL
SELECT
  ''加算情報(加算項目)'' AS title,
  ai.hosp_cd AS hosp_cd,
  NULL AS proc_cd,
  NULL AS add_class
FROM
  addition_info ai
WHERE
  CASE
      WHEN ai.add_class = ''13'' THEN false --慢性維持透析患者外来医学管理料
      WHEN ai.add_class = ''12'' --汎用
        AND ai.hosp_cd = ANY (select set_value from addition_cd_list)
        then false
      ELSE true
      END
  AND ai.hosp_cd IS NOT NULL
UNION ALL
  SELECT
    ''ダイアライザ'' AS title,
    dia.hosp_cd AS hosp_cd,
    NULL AS proc_cd,
    NULL AS add_class
  FROM
    ind_dialyzer dia
  WHERE
    dia.hosp_cd IS NOT NULL
UNION ALL
  SELECT
    eu.title AS title,
    eu.hosp_cd AS hosp_cd,
    NULL AS proc_cd,
    NULL AS add_class
  FROM
    equip_sort_union eu
  WHERE
    eu.hosp_cd IS NOT NULL
UNION ALL
  SELECT
    mu1.title AS title,
    mu1.hosp_cd AS hosp_cd,
    NULL AS proc_cd,
    NULL AS add_class
  FROM
    medi_union_1 mu1
  WHERE
    mu1.hosp_cd IS NOT NULL
UNION ALL
  SELECT
    ''加算情報(医学管理科)'' AS title,
    ai.hosp_cd AS hosp_cd,
    NULL AS proc_cd,
    ai.add_class AS add_class
  FROM
    addition_info ai
  WHERE
    CASE
      WHEN ai.add_class = ''13'' THEN true --慢性維持透析患者外来医学管理料
      WHEN ai.add_class = ''12'' --汎用
        AND ai.hosp_cd = ANY (select set_value from addition_cd_list)
        then true
      ELSE false
      END
    AND ai.hosp_cd IS NOT NULL
UNION ALL
  SELECT
    mu2.title AS title,
    mu2.hosp_cd AS hosp_cd,
    mu2.pro_hosp_cd AS proc_cd,
    NULL AS add_class
  FROM
    medi_union_2 mu2
  WHERE
    mu2.hosp_cd IS NOT NULL
    AND NULLIF(mu2.pro_hosp_cd, '''') IS NOT NULL
)
, numbered AS (
SELECT
  *,
  ROW_NUMBER() OVER () AS rn
FROM
  union_table
)
, recursive_rp AS (
-- 再帰で RP, RpItem を採番
SELECT
  n.rn,
  n.title,
  n.hosp_cd,
  n.proc_cd,
  n.add_class,
  1 AS RP,
  1 AS RpItem,
  NULL::text AS last_proc_cd,
  ARRAY[]::text[] AS proc_cd_list,
  FALSE AS need_procedure_insert,
  FALSE AS need_treatment_insert
FROM
  numbered n,
  ini_value m
WHERE
  n.rn = 1
UNION ALL
SELECT
  n.rn,
  n.title,
  n.hosp_cd,
  n.proc_cd,
  n.add_class,
  CASE
    WHEN n.proc_cd IS NOT NULL AND NOT (n.proc_cd = ANY(r.proc_cd_list)) THEN r.RP + 1
    WHEN r.RpItem >= 20 OR (m.medicine_send_type::NUMERIC = 0
      AND n.proc_cd IS NOT NULL) THEN r.RP + 1
    WHEN r.RpItem >= 20 OR n.proc_cd IS NULL
      AND n.add_class IS NOT NULL THEN r.RP + 1
    ELSE r.RP
  END AS RP,
  CASE
    WHEN ((n.proc_cd IS NOT NULL AND NOT (n.proc_cd = ANY(r.proc_cd_list)))
      OR (r.RpItem >= 20
      OR (m.medicine_send_type::NUMERIC = 0
      AND n.proc_cd IS NOT NULL))) THEN 2
    WHEN r.RpItem >= 20
      OR n.proc_cd IS NULL
      AND n.add_class IS NOT NULL THEN 1
    ELSE r.RpItem + 1
  END AS RpItem,
  CASE
    WHEN n.proc_cd IS NOT NULL THEN n.proc_cd
    ELSE r.last_proc_cd
  END AS last_proc_cd,
  CASE
    WHEN n.proc_cd IS NOT NULL
      AND NOT (n.proc_cd = ANY(r.proc_cd_list)) THEN r.proc_cd_list || n.proc_cd
    ELSE r.proc_cd_list
  END AS proc_cd_list,
  CASE
    WHEN ((n.proc_cd IS NOT NULL
      AND NOT (n.proc_cd = ANY(r.proc_cd_list)))
      OR (m.medicine_send_type::NUMERIC = 0
      AND n.proc_cd IS NOT NULL)
      OR r.RpItem >= 20
      AND n.proc_cd IS NOT NULL) THEN TRUE
    ELSE FALSE
  END AS need_procedure_insert,
  CASE
    WHEN r.RpItem >= 20
      AND n.proc_cd IS NULL THEN TRUE
    ELSE FALSE
  END AS need_treatment_insert
FROM
  recursive_rp r
JOIN numbered n ON n.rn = r.rn + 1
CROSS JOIN ini_value m
)
, procedure_inserts AS (
-- 手技コード差し込み
SELECT
  RP,
  1 AS RpItem,
  ''手技コード'' AS title,
  last_proc_cd AS hosp_cd,
  NULL::text AS proc_cd,
  (rn - 0.5)::NUMERIC AS sort_key
FROM
  recursive_rp
WHERE
  need_procedure_insert
)
, treatment_inserts AS (
-- 治療項目コード差し込み
SELECT
  RP,
  1 AS RpItem,
  ''治療方法'' AS title,
  tre.hosp_cd AS hosp_cd,
  NULL::text AS proc_cd,
  (rn - 0.5)::NUMERIC AS sort_key
FROM
  recursive_rp
CROSS JOIN ind_treatment tre
WHERE
  need_treatment_insert
)
, recursive_rp_with_sort AS (
SELECT
  RP,
  RpItem,
  title,
  hosp_cd,
  proc_cd,
  rn::NUMERIC AS sort_key
FROM
  recursive_rp
)
, final_data AS (
SELECT
  RP,
  RpItem,
  title,
  hosp_cd,
  proc_cd,
  sort_key
FROM
  recursive_rp_with_sort
UNION ALL
SELECT
  RP,
  RpItem,
  title,
  hosp_cd,
  proc_cd,
  sort_key
FROM
  procedure_inserts
UNION ALL
SELECT
  RP,
  RpItem,
  title,
  hosp_cd,
  proc_cd,
  sort_key
FROM
  treatment_inserts
)
, max_rp AS (
SELECT
  MAX(RP) AS max_rp
FROM
  final_data
)
, rp_series AS (
SELECT
  generate_series(1, (SELECT max_rp FROM max_rp)) AS RP
)
SELECT
  RP AS rp_no,
  ''01'' AS detail_id
FROM
  rp_series
WHERE
  rp_series.RP < 11;

-- SQL: -1103003 end', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム連携 透析実績連携 処置実績ファイル_オーダーインデックス', '2025-07-16 14:50:48.578', CURRENT_TIMESTAMP, '[{"sql_cd": -1102004, "field_name": "pat_personal_info", "replace_var": "@patPersonalInfo"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1103002, 'WITH RECURSIVE coop_ini_info AS (
--連携設定から取得
SELECT
  COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value,
  info ->> ''key1'' AS key1,
  info ->> ''key2'' AS key2
FROM
  mst_coop_ini AS ini
CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
WHERE
  ini.facility_cd = @facilityCd
  AND ini.is_del = ''0''
  AND COALESCE(info ->> ''key0'', '''') = @key0
  AND info ->> ''key1'' IN(
            ''SCM_CONV_UNIT_MEDI'',
            ''SCM_IN_HOSPITAL_CD'',
            ''SCM_COMMON''
        )
)
, ini_unit AS (
    SELECT
        key2,
        value
    FROM
        coop_ini_info
    WHERE
        key1 = ''SCM_CONV_UNIT_MEDI''
)

, ini_value AS(
--連携設定取得値
SELECT
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_MEDICINE'') AS hosp_get_mst_medicine,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_PROCEDURE'') AS hosp_get_mst_procedure
  )
, mst_medi_mix AS (
--調整薬剤マスタ
SELECT
  t1.idx AS idx,
  medicine_mix_cd AS mix_cd,
  t1.info ->> ''solvent'' AS solvent,
  t1.info ->> ''cd'' AS medi_cd,
  t1.info ->> ''amount'' AS amount,
  mst.unit AS unit,
  mst.is_shot AS is_shot,
  mst.in_hospital_cd_1 AS in_hospital_cd_1,
  mst.in_hospital_cd_2 AS in_hospital_cd_2,
  mst.in_hospital_cd_3 AS in_hospital_cd_3,
  mst.in_hospital_cd_4 AS in_hospital_cd_4,
  mst.is_disp as is_disp,
  mst.is_del as is_del  
FROM
  mst_medicine_mix mix
CROSS JOIN LATERAL json_array_elements(mix.mix_info ::json) WITH ORDINALITY AS t1(info, idx)
INNER JOIN mst_medicine AS mst ON mst.medicine_cd::text = info ->> ''cd''
  AND mst.is_shot = ''1''
  AND mst.is_del = ''0''
  AND mst.is_disp = ''1''
WHERE
  mix.is_del = ''0''
  AND mix.facility_cd = @facilityCd
  AND mst.facility_cd = @facilityCd
)
, do_ord_main AS (
(SELECT
  res.del_date as up_date_switch,
  res.rst_medi_info AS rst_medi_info,
  res.treat_date::TIMESTAMP AS treat_date
FROM ord_main_restore as res
JOIN sys_coop_journal AS journal ON res.ord_no = journal.ord_no
WHERE res.ord_no = @ordNo
  AND res.facility_cd = @facilityCd
  AND journal.facility_cd = @facilityCd
  AND journal.ctl_no = @ctlNo
  AND journal.reg_date >= res.del_date
ORDER BY res.del_date DESC LIMIT 1
)
UNION
(SELECT
  main.rst_edition_date as up_date_switch,
  main.rst_medi_info AS rst_medi_info,
  main.treat_date::TIMESTAMP AS treat_date
FROM ord_main AS main
  WHERE main.ord_no = @ordNo
  AND main.facility_cd = @facilityCd
)
ORDER BY
  up_date_switch DESC NULLS LAST
LIMIT 1
)
, medi_indo AS (
-- 投与薬剤情報
SELECT
  t1.idx as idx,
  t1.medi_info ->> ''cd'' AS mst_cd,
  CASE
    WHEN (om.treat_date >= mst_pro.in_hosp_a_startdate) 
      AND (om.treat_date >= mst_pro.in_hosp_b_startdate) THEN
      CASE
        WHEN mst_pro.in_hosp_a_startdate >= mst_pro.in_hosp_b_startdate THEN
          CASE ini_value.hosp_get_mst_procedure
            WHEN ''1'' THEN mst_pro.in_hospital_cd_a1
            WHEN ''2'' THEN mst_pro.in_hospital_cd_a2
          END
        WHEN mst_pro.in_hosp_a_startdate < mst_pro.in_hosp_b_startdate THEN
          CASE ini_value.hosp_get_mst_procedure
            WHEN ''1'' THEN mst_pro.in_hospital_cd_b1
            WHEN ''2'' THEN mst_pro.in_hospital_cd_b2
          END
      END
    WHEN om.treat_date >= mst_pro.in_hosp_a_startdate THEN
      CASE ini_value.hosp_get_mst_procedure
        WHEN ''1'' THEN mst_pro.in_hospital_cd_a1
        WHEN ''2'' THEN mst_pro.in_hospital_cd_a2
      END
    WHEN om.treat_date >= mst_pro.in_hosp_b_startdate THEN
      CASE ini_value.hosp_get_mst_procedure
        WHEN ''1'' THEN mst_pro.in_hospital_cd_b1
        WHEN ''2'' THEN mst_pro.in_hospital_cd_b2
      END
    ELSE NULL
  END AS pro_hosp_cd,
  CASE
    WHEN json_array_length(om.rst_medi_info::json) = 0 THEN NULL
    ELSE
      CASE t1.medi_info ->> ''medicine_type''
        WHEN ''1'' THEN
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_medi.in_hospital_cd_1
            WHEN ''2'' THEN mst_medi.in_hospital_cd_2
            WHEN ''3'' THEN mst_medi.in_hospital_cd_3
            WHEN ''4'' THEN mst_medi.in_hospital_cd_4
            ELSE NULL
          END
        WHEN ''2'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_mix.in_hospital_cd_1
            WHEN ''2'' THEN mst_mix.in_hospital_cd_2
            WHEN ''3'' THEN mst_mix.in_hospital_cd_3
            WHEN ''4'' THEN mst_mix.in_hospital_cd_4
            ELSE NULL
          END
      END
  END AS hosp_cd,
  CASE
    WHEN json_array_length(om.rst_medi_info::json) = 0 THEN NULL
    ELSE
      CASE t1.medi_info ->> ''medicine_type''
        WHEN ''1'' THEN (medi_info ->> ''amount'')::numeric
        WHEN ''2'' THEN
          CASE mst_mix.solvent
            WHEN ''0'' THEN
              (medi_info ->> ''amount'')::numeric * mst_mix.amount::numeric
            WHEN ''1'' THEN
              mst_mix.amount::numeric
          END
        ELSE 0
      END
  END AS amount,
  CASE
    WHEN json_array_length(om.rst_medi_info::json) = 0 THEN NULL
    ELSE
          CASE t1.medi_info ->> ''medicine_type''
            WHEN ''1'' THEN mst_medi.unit
            WHEN ''2'' THEN mst_mix.unit
          END
  END AS unit,
  CASE
    WHEN json_array_length(om.rst_medi_info::json) = 0 THEN NULL
    ELSE
      CASE t1.medi_info ->> ''medicine_type''
        WHEN ''1'' THEN mst_medi.is_shot
        WHEN ''2'' THEN mst_mix.is_shot
      END
  END AS is_shot,
  CASE t1.medi_info ->> ''medicine_type''
    WHEN ''1'' THEN mst_medi.is_disp 
    WHEN ''2'' THEN mst_mix.is_disp 
  END AS is_disp
FROM
  do_ord_main om
CROSS JOIN LATERAL json_array_elements(om.rst_medi_info::json) WITH ORDINALITY AS t1(medi_info, idx)
LEFT JOIN mst_medicine AS mst_medi ON mst_medi.medicine_cd::text = medi_info ->> ''cd''
  AND medi_info ->> ''medicine_type''::text = ''1'' AND mst_medi.facility_cd = @facilityCd
LEFT JOIN mst_medi_mix AS mst_mix ON mst_mix.mix_cd::text = medi_info ->> ''cd''
  AND medi_info ->> ''medicine_type''::text = ''2''
LEFT JOIN mst_procedure AS mst_pro ON mst_pro.procedure_cd::text = t1.medi_info ->> ''procedure_cd'' AND mst_pro.facility_cd = @facilityCd
CROSS JOIN ini_value
WHERE
  medi_info ->> ''effect_flg'' = ''1''

  AND (
    (medi_info ->> ''medicine_type''::text = ''1'' AND  mst_medi.is_del = ''0'')
    OR
    (medi_info ->> ''medicine_type''::text = ''2'' AND  mst_mix.is_del = ''0'')
  )
  
)
-- 送信履歴メモ.memoから取得
, memo_text AS (
SELECT
  save_2->>''memo'' AS memo
FROM
  pat_coop_detail
WHERE
  pat_id = @patId
  AND save_2->>''coop_cd'' = ''ind_dial''
  AND pat_coop_detail.facility_cd = @facilityCd
  AND save_2->>''ord_no'' = @ordNo::text
ORDER BY
  up_date DESC
LIMIT 1
)
, bounds AS (
SELECT
  memo,
  POSITION(''#I|'' IN memo) AS i_pos,
  POSITION(''#K'' IN memo) AS k_pos
FROM
  memo_text
)
, extracted AS (
SELECT
  substring(memo FROM i_pos + 3 FOR k_pos - (i_pos + 3)) AS i_segment
FROM
  bounds
)
, split_parts AS (
SELECT
  string_to_array(i_segment, ''|'') AS parts
FROM
  extracted
)
, item_info AS (
SELECT
  parts[i] AS item_value,
  i - 4 AS item_index
FROM
  split_parts,
  generate_series(5, CARDINALITY(parts)) AS i
)
, get_items AS (
SELECT
  item_index,
  item_value,
  substring(item_value FROM 1 FOR 2) AS rp_no,
  substring(item_value FROM 3 FOR 2) AS technique,
  substring(item_value FROM 5 FOR 2) AS med_no,
  substring(item_value FROM 7 FOR 6) AS med_code
FROM
  item_info
)
-- 同手技同薬剤コードは一つだけ出力
, get_items_total AS (
  SELECT DISTINCT ON (technique, med_code) *
    FROM get_items
    ORDER BY technique, med_code, item_index
)
-- コード桁数処理
, medi_indo_mi_cut AS (
  SELECT
    *,
    CASE
      WHEN octet_length(hosp_cd) <= 4 THEN hosp_cd
      ELSE (
        SELECT substring(hosp_cd FROM MIN(i))
        FROM generate_series(1, char_length(hosp_cd)) AS i
        WHERE octet_length(substring(hosp_cd FROM i)) <= 6
      )
    END AS hosp_cd_trimmed,
    RIGHT(pro_hosp_cd, 2) as pro_hosp_cd_trimmed
  FROM medi_indo
),
 unit_choice AS (
  SELECT DISTINCT ON (hosp_cd_trimmed, pro_hosp_cd_trimmed)
    hosp_cd_trimmed,
    pro_hosp_cd,
    unit
  FROM medi_indo_mi_cut
  WHERE is_shot = ''1'' AND is_disp = ''1''
  ORDER BY hosp_cd_trimmed, pro_hosp_cd_trimmed, idx
)

select
  ''01'' AS detail_id,
  gi.rp_no::numeric AS rp_no,
  gi.med_no::numeric AS medi_no,
  mi.hosp_cd_trimmed AS medi_cd,
  LEAST(SUM(TRUNC(mi.amount, 2)::FLOAT8), 9999999.99)::text AS amount,
  MIN(ini_unit.value) AS unit
FROM
  get_items_total gi
INNER JOIN medi_indo_mi_cut AS mi ON gi.med_code = LPAD(mi.hosp_cd_trimmed, 6,'' '')
  AND gi.technique = LPAD(pro_hosp_cd_trimmed, 2,'' '')
LEFT JOIN unit_choice uc
  ON mi.hosp_cd_trimmed = uc.hosp_cd_trimmed
  AND mi.pro_hosp_cd = uc.pro_hosp_cd
LEFT JOIN ini_unit
  ON uc.unit = ini_unit.key2
WHERE
  mi.is_shot = ''1'' and 
  mi.is_disp = ''1'' and
  gi.rp_no::numeric = @rpNo
  
GROUP BY gi.rp_no, gi.med_no, mi.hosp_cd_trimmed

ORDER BY rp_no, medi_no', '2', '[{}]', '0', '{"applications": [4]}', NULL, '(送信用)セコムの透析実績連携', '2025-06-03 08:56:02.129', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1102033, 'WITH raw_data AS (
	SELECT @contentJson::jsonb AS data
),
rows AS (
	SELECT JSONB_ARRAY_ELEMENTS(data) AS row
	FROM raw_data
)
SELECT  
  ''01'' AS detail_id,
  @facilityCd AS facility_cd,
  @ctlNo AS ctl_no,
  @key0 AS key0,
  @patId AS pat_id,
  @ordNo AS ord_no
WHERE EXISTS (
  SELECT 1 FROM rows
);', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム連携 透析指示連携 注射依頼(削除電文用)', '2025-07-29 18:23:10.538', CURRENT_TIMESTAMP, '[{"sql_cd": -1102029, "field_name": "content_json", "replace_var": "@contentJson"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1102032, 'WITH coop_ini_info AS (
    --連携設定から取得
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value,
        info ->> ''key1'' AS key1,
        info ->> ''key2'' AS key2
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE
        ini.facility_cd = @facilityCd
        AND ini.is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' in(
            ''SCM_COMMON'',
            ''SCM_IN_HOSPITAL_CD''
        )
)
, ord_main_max AS (
    (
        SELECT
            ord.ord_no,
            ord.del_date AS up_date,
            ord.treat_date,
            ord.ind_medi_info
        FROM
            ord_main_restore AS ord,
            sys_coop_journal AS journal
        WHERE
            ord.ord_no = @ordNo
            AND ord.facility_cd = @facilityCd
            AND journal.facility_cd = @facilityCd
            AND journal.ctl_no = @ctlNo
            AND ord.ord_no = journal.ord_no
            AND journal.reg_date >= ord.del_date
        ORDER BY
            del_date DESC
        LIMIT 1
    )
    UNION
    (
        SELECT
            ord.ord_no,
            ord.rst_edition_date AS up_date,
            ord.treat_date,
            ord.ind_medi_info
        FROM
            ord_main AS ord
        WHERE
            ord.ord_no = @ordNo
            AND ord.facility_cd = @facilityCd
    )
    ORDER BY
        up_date DESC NULLS LAST
    LIMIT 1
)
, ord_medi_infos AS (
    --通常薬剤
    SELECT
        ord_medi_info ->> ''cd'' AS medicine_cd,
        mp.procedure_cd,
        ord.treat_date,
        CASE
            (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_MEDICINE'')
            WHEN ''1'' THEN mm.in_hospital_cd_1
            WHEN ''2'' THEN mm.in_hospital_cd_2
            WHEN ''3'' THEN mm.in_hospital_cd_3
            WHEN ''4'' THEN mm.in_hospital_cd_4
        END AS medi_cd
    FROM
        ord_main_max ord
    CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info :: json) WITH ORDINALITY as t(ord_medi_info, idx)
    INNER JOIN mst_procedure mp ON 
        ord_medi_info ->> ''procedure_cd'' = mp.procedure_cd :: text AND mp.facility_cd = @facilityCd
    LEFT JOIN mst_medicine mm ON 
        ord_medi_info ->> ''cd'' = mm.medicine_cd :: text AND mm.facility_cd = @facilityCd
    WHERE
        ord_medi_info ->> ''medicine_type'' = ''1''
        AND mm.is_shot = ''1''
        AND mm.is_del = ''0''
        AND mm.is_disp = ''1''
    UNION ALL
    --調整薬剤
    SELECT
        medi_mix_info ->> ''cd'' AS medicine_cd,
        mp.procedure_cd,
        ord.treat_date,
        CASE
            (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_MEDICINE'')
            WHEN ''1'' THEN mm.in_hospital_cd_1
            WHEN ''2'' THEN mm.in_hospital_cd_2
            WHEN ''3'' THEN mm.in_hospital_cd_3
            WHEN ''4'' THEN mm.in_hospital_cd_4
        END AS medi_cd
    FROM
        ord_main_max ord
    CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info :: json) WITH ORDINALITY as t(ord_medi_info, idx)
    INNER JOIN mst_procedure mp ON
        ord_medi_info ->> ''procedure_cd'' = mp.procedure_cd :: text AND mp.facility_cd = @facilityCd
    LEFT JOIN mst_medicine_mix mmm ON
        ord_medi_info ->> ''cd'' = mmm.medicine_mix_cd :: text AND mmm.facility_cd = @facilityCd
    LEFT JOIN json_array_elements(mmm.mix_info :: json) medi_mix_info ON TRUE
    LEFT JOIN mst_medicine mm ON
        medi_mix_info ->> ''cd'' = mm.medicine_cd :: text AND mm.facility_cd = @facilityCd
    WHERE
        ord_medi_info ->> ''medicine_type'' = ''2''
        AND mm.is_shot = ''1''
        AND mm.is_del = ''0''
        AND mm.is_disp = ''1''
)
, procedure_code AS (
    --手技の院内コード
    SELECT
        MIN(NULLIF(CASE
        -- 両方とも利用開始日以降の場合
            WHEN ((omi.treat_date::TIMESTAMP >= mp.in_hosp_a_startdate)
                AND (omi.treat_date::TIMESTAMP >= mp.in_hosp_b_startdate)) THEN
                CASE
                    WHEN mp.in_hosp_a_startdate >= mp.in_hosp_b_startdate THEN
                        CASE ini_value.hosp_cd
                            WHEN ''1'' THEN mp.in_hospital_cd_a1
                            WHEN ''2'' THEN mp.in_hospital_cd_a2
                        END
                    WHEN mp.in_hosp_a_startdate < mp.in_hosp_b_startdate THEN
                        CASE ini_value.hosp_cd
                            WHEN ''1'' THEN mp.in_hospital_cd_b1
                            WHEN ''2'' THEN mp.in_hospital_cd_b2
                        END
                END
            -- 治療日がAの利用開始日以降の場合
            WHEN omi.treat_date::TIMESTAMP >= mp.in_hosp_a_startdate 
                AND (omi.treat_date::TIMESTAMP < mp.in_hosp_b_startdate 
                OR mp.in_hosp_b_startdate IS NULL) THEN
                CASE ini_value.hosp_cd
                    WHEN ''1'' THEN mp.in_hospital_cd_a1
                    WHEN ''2'' THEN mp.in_hospital_cd_a2
                END
            -- 治療日がBの利用開始日以降の場合
            WHEN omi.treat_date::TIMESTAMP >= mp.in_hosp_b_startdate 
                AND (omi.treat_date::TIMESTAMP < mp.in_hosp_a_startdate 
                OR mp.in_hosp_a_startdate IS NULL) THEN
                CASE ini_value.hosp_cd
                    WHEN ''1'' THEN mp.in_hospital_cd_b1
                    WHEN ''2'' THEN mp.in_hospital_cd_b2
                END
            ELSE NULL
	    END,'''')) AS procedure_hosp_cd,
        omi.procedure_cd
    FROM
        ord_medi_infos omi
        LEFT JOIN mst_procedure mp ON
            omi.procedure_cd = mp.procedure_cd AND mp.facility_cd = @facilityCd
        CROSS JOIN (
            SELECT 
            (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_PROCEDURE'') AS hosp_cd
            ) AS ini_value
    GROUP BY
        omi.procedure_cd
)
, final_ord_medi_infos AS (
    SELECT
        medi_cd,
        pc.procedure_hosp_cd
    FROM
        ord_medi_infos omi
    LEFT JOIN procedure_code pc ON omi.procedure_cd = pc.procedure_cd
    WHERE
        medi_cd IS NOT NULL
        AND pc.procedure_hosp_cd IS NOT NULL
)

SELECT
  ''01'' AS detail_id,
  @facilityCd AS facility_cd,
  @ctlNo AS ctl_no,
  @key0 AS key0,
  @patId AS pat_id,
  @ordNo AS ord_no
WHERE EXISTS (
  SELECT 1 FROM final_ord_medi_infos
)
', '2', '[{}]', '0', '{"applications": [4]}', NULL, '(送信用)セコムのrootからdetail、recordを特定するSQL', '2025-07-29 18:23:10.538', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1102030, '-- SQL: -1102030 begin
-- このSQLは、透析指示連携の最新の新規処理によって生成されたファイルの内容を出力します。
-- 処置依頼と注射依頼の各種ファイルのmst_coop_layout_detailを特定するために使用してください。
-- このSQLで取得したパラメータは子レイアウトのSQLで直接参照してください。

WITH raw_data AS (
	SELECT @contentJson::jsonb AS data
),
rows AS (
	SELECT JSONB_ARRAY_ELEMENTS(data) AS row
	FROM raw_data
)

-- colの番号は設計書の「No.」を表しています。
-- col1は「No.1」、col2は「No.2」...と続きます。
SELECT 
    ''01'' AS detail_id,
    row->>0  AS col1,
    row->>1  AS col2,
    row->>2  AS col3,
    row->>3  AS col4,
    row->>4  AS col5,
    row->>5  AS col6,
    row->>6  AS col7,
    row->>7  AS col8,
    row->>8  AS col9,
    row->>9  AS col10,
    row->>10 AS col11,
    row->>11 AS col12,
    row->>12 AS col13,
    row->>13 AS col14,
    row->>14 AS col15,
    row->>15 AS col16,
    row->>16 AS col17,
    row->>17 AS col18,
    row->>18 AS col19,
    row->>19 AS col20,
    row->>20 AS col21,
    row->>21 AS col22,
    row->>22 AS col23,
    row->>23 AS col24,
    row->>24 AS col25,
    row->>25 AS col26,
    row->>26 AS col27,
    row->>27 AS col28,
    row->>28 AS col29,
    row->>29 AS col30,
    row->>30 AS col31,
    row->>31 AS col32,
    row->>32 AS col33,
    row->>33 AS col34,
    row->>34 AS col35,
    row->>35 AS col36,
    row->>36 AS col37,
    row->>37 AS col38,
    row->>38 AS col39,
    row->>39 AS col40
FROM rows;
-- SQL: -1102030 end
', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム連携 透析指示連携 処置依頼/注射依頼(削除電文用)', '2025-07-25 11:43:52.23', CURRENT_TIMESTAMP, '[{"sql_cd": -1102029, "field_name": "content_json", "replace_var": "@contentJson"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1102025, 'select  
''01'' as detail_id,
@facilityCd AS facility_cd,
@ctlNo AS ctl_no,
@key0 AS key0,
@patId AS pat_id,
@ordNo AS ord_no,
@fileName AS file_name,
@folderName AS folder_name', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム連携 透析指示連携 注射依頼ファイル_ファイル作成終了', '2025-06-26 23:35:08.908', CURRENT_TIMESTAMP, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1102024, 'select  
''01'' as detail_id,
@facilityCd AS facility_cd,
@ctlNo AS ctl_no,
@key0 AS key0,
@patId AS pat_id,
@ordNo AS ord_no,
@fileName AS file_name,
@folderName AS folder_name', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム連携 透析指示連携 注射依頼ファイル_処置項目', '2025-06-26 23:35:08.908', CURRENT_TIMESTAMP, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1102023, 'select  
''01'' as detail_id,
@facilityCd AS facility_cd,
@ctlNo AS ctl_no,
@key0 AS key0,
@patId AS pat_id,
@ordNo AS ord_no,
@fileName AS file_name,
@folderName AS folder_name', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム連携 透析指示連携 注射依頼ファイル_実施単位', '2025-06-26 23:35:08.908', CURRENT_TIMESTAMP, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1102022, 'select  
''01'' as detail_id,
@facilityCd AS facility_cd,
@ctlNo AS ctl_no,
@key0 AS key0,
@patId AS pat_id,
@ordNo AS ord_no,
@fileName AS file_name,
@folderName AS folder_name', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム連携 透析指示連携 注射依頼ファイル_注射ヘッダー', '2025-06-26 23:35:08.908', CURRENT_TIMESTAMP, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1102021, 'select  
''01'' as detail_id,
@facilityCd AS facility_cd,
@ctlNo AS ctl_no,
@key0 AS key0,
@patId AS pat_id,
@ordNo AS ord_no,
@fileName AS file_name,
@folderName AS folder_name', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム連携 透析指示連携 注射依頼ファイル_オーダーインデックス', '2025-06-26 23:35:08.908', CURRENT_TIMESTAMP, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1102020, 'select  
''01'' as detail_id,
@facilityCd AS facility_cd,
@ctlNo AS ctl_no,
@key0 AS key0,
@patId AS pat_id,
@ordNo AS ord_no,
@fileName AS file_name,
@folderName AS folder_name', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム連携 透析指示連携 処置依頼ファイル_ファイル作成終了', '2025-06-26 23:35:08.908', CURRENT_TIMESTAMP, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1102019, 'select  
''01'' as detail_id,
@facilityCd AS facility_cd,
@ctlNo AS ctl_no,
@key0 AS key0,
@patId AS pat_id,
@ordNo AS ord_no,
@fileName AS file_name,
@folderName AS folder_name', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム連携 透析指示連携 処置依頼ファイル_処置項目', '2025-06-26 23:35:08.908', CURRENT_TIMESTAMP, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1102018, 'select  
''01'' as detail_id,
@facilityCd AS facility_cd,
@ctlNo AS ctl_no,
@key0 AS key0,
@patId AS pat_id,
@ordNo AS ord_no,
@fileName AS file_name,
@folderName AS folder_name', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム連携 透析指示連携 処置依頼ファイル_処置単位', '2025-06-26 23:35:08.908', CURRENT_TIMESTAMP, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1102017, 'select  
''01'' as detail_id,
@facilityCd AS facility_cd,
@ctlNo AS ctl_no,
@key0 AS key0,
@patId AS pat_id,
@ordNo AS ord_no,
@fileName AS file_name,
@folderName AS folder_name', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム連携 透析指示連携 処置依頼ファイル_処置ヘッダー', '2025-06-26 23:35:08.908', CURRENT_TIMESTAMP, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1102016, 'select  
''01'' as detail_id,
@facilityCd AS facility_cd,
@ctlNo AS ctl_no,
@key0 AS key0,
@patId AS pat_id,
@ordNo AS ord_no,
@fileName AS file_name,
@folderName AS folder_name', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム連携 透析指示連携 処置依頼ファイル_オーダーインデックス', '2025-06-26 23:35:08.908', CURRENT_TIMESTAMP, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1102011, 'WITH coop_ini_info AS (
    --連携設定から取得
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value,
        info ->> ''key1'' AS key1,
        info ->> ''key2'' AS key2
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE
        ini.facility_cd = @facilityCd
        AND ini.is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' in(
            ''SCM_COMMON'',
            ''SCM_IN_HOSPITAL_CD'',
            ''SCM_CONV_UNIT_MEDI''
        )
)
, ini_unit AS (
    SELECT
        key2,
        value
    FROM
        coop_ini_info
    WHERE
        key1 = ''SCM_CONV_UNIT_MEDI''
)
, facility_medicine_order as (
    -- 施設設定マスタ(No.107)
    SELECT
        ROW_NUMBER() OVER () AS setting_order, -- 適用順 
        datt.a1 AS setting_value -- 設定値
    FROM (
        SELECT
            TO_NUMBER(val, ''999999999999'') AS a1
        FROM unnest(
            COALESCE(
            string_to_array(
                (
                SELECT mst_f.value
                FROM mst_facility_setting AS mst_f
                WHERE mst_f.facility_setting_no = ''3007''
                    AND mst_f.facility_cd = @facilityCd
                ),
                '',''
            ),
            ARRAY[''0'']  -- デフォルト値を配列で補う
            )
        ) AS val
    ) AS datt
)
, medi_order as (
    -- 薬剤マスタの並び順
    select index_no::int as medi_code_order,
        TO_NUMBER(order_cd->>''code'', ''999999999999'') as medi_code,
        order_cd->>''name'' as name
    from mst_selector
        cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(order_cd, index_no)
    where facility_cd = @facilityCd
        and master_physical_name = ''mst_medicine''
)
, medi_class_order as (
    -- 薬剤分類マスタの並び順
    select index_no::int as medi_class_code_order,
        TO_NUMBER(order_cd->>''code'', ''999999999999'') as medi_class_code,
        order_cd->>''name'' as class_name
    from mst_selector
        cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(order_cd, index_no)
    where facility_cd = @facilityCd
        and master_physical_name = ''mst_medicine_class''
)
, timing_order as (
    -- 投与タイミングマスタの並び順
    select
        index_no ::int as timing_code_order
        , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') as timing_code
    from mst_selector
    cross join LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality as tmp(order_cd, index_no)
    where facility_cd = @facilityCd
        and master_physical_name = ''mst_medicate_timing''
)
, procedure_order as (
    -- 手技マスタの並び順
    select
        index_no ::int as procedure_code_order
        , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') as procedure_code
    from mst_selector
    cross join LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality as tmp(order_cd, index_no)
    where facility_cd = @facilityCd
    and master_physical_name = ''mst_procedure''
)
, mst_medi as (
    select
        medicine_cd,
        class_cd,
        medi_order.medi_code_order,
        medi_class_order.medi_class_code_order
    from mst_medicine mmd
        left join medi_order on mmd.medicine_cd = medi_order.medi_code
        left join medi_class_order on mmd.class_cd = medi_class_order.medi_class_code
    where facility_cd = @facilityCd
)
, ord_main_max AS (
    (
        SELECT
            ord.ord_no,
            ord.del_date AS up_date,
            ord.treat_date,
            ord.ind_medi_info
        FROM
            ord_main_restore AS ord,
            sys_coop_journal AS journal
        WHERE
            ord.ord_no = @ordNo
            AND ord.facility_cd = @facilityCd
            AND journal.facility_cd = @facilityCd
            AND journal.ctl_no = @ctlNo
            AND ord.ord_no = journal.ord_no
            AND journal.reg_date >= ord.del_date
        ORDER BY
            del_date DESC
        LIMIT 1
    )
    UNION
    (
        SELECT
            ord.ord_no,
            ord.rst_edition_date AS up_date,
            ord.treat_date,
            ord.ind_medi_info
        FROM
            ord_main AS ord
        WHERE
            ord.ord_no = @ordNo
            AND ord.facility_cd = @facilityCd
    )
    ORDER BY
        up_date DESC NULLS LAST
    LIMIT 1
)
, ord_medi_infos AS (
    --通常薬剤
    SELECT
        100 + t.idx as registration_order,
        ord_medi_info ->> ''cd'' AS medicine_cd,
        mm.class_cd AS class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        mp.procedure_cd,
        ord.treat_date,
        ord_medi_info->>''date_interval'' as date_interval,
        CASE
            (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_MEDICINE'')
            WHEN ''1'' THEN mm.in_hospital_cd_1
            WHEN ''2'' THEN mm.in_hospital_cd_2
            WHEN ''3'' THEN mm.in_hospital_cd_3
            WHEN ''4'' THEN mm.in_hospital_cd_4
        END AS medi_cd,
        TRUNC((ord_medi_info ->> ''amount'') :: NUMERIC, 2) AS medi_amount,
        ini_unit.value AS unit_convert
    FROM
        ord_main_max ord
    CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info :: json) WITH ORDINALITY as t(ord_medi_info, idx)
    INNER JOIN mst_procedure mp ON 
        ord_medi_info ->> ''procedure_cd'' = mp.procedure_cd :: text AND mp.facility_cd = @facilityCd
    LEFT JOIN mst_medicine mm ON 
        ord_medi_info ->> ''cd'' = mm.medicine_cd :: text AND mm.facility_cd = @facilityCd
    LEFT JOIN mst_medicine_class mmc on mm.class_cd = mmc.class_cd AND mmc.facility_cd = @facilityCd
    LEFT JOIN ini_unit ON mm.unit = ini_unit.key2
    WHERE
        ord_medi_info ->> ''medicine_type'' = ''1''
        AND mm.is_shot = ''1''
        AND mm.is_del = ''0''
        AND mm.is_disp = ''1''
    UNION ALL
    --調整薬剤
    SELECT
        100 + t.idx as registration_order,
        medi_mix_info ->> ''cd'' AS medicine_cd,
        mm.class_cd AS class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        mp.procedure_cd,
        ord.treat_date,
        ord_medi_info->>''date_interval'' as date_interval,
        CASE
            (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_MEDICINE'')
            WHEN ''1'' THEN mm.in_hospital_cd_1
            WHEN ''2'' THEN mm.in_hospital_cd_2
            WHEN ''3'' THEN mm.in_hospital_cd_3
            WHEN ''4'' THEN mm.in_hospital_cd_4
        END AS medi_cd,
        CASE
            medi_mix_info ->> ''solvent''
            WHEN ''0'' THEN TRUNC(
                (ord_medi_info ->> ''amount'') :: NUMERIC * (medi_mix_info ->> ''amount'') :: NUMERIC,
                2
            )
            WHEN ''1'' THEN TRUNC((medi_mix_info ->> ''amount'') :: NUMERIC, 2)
        END AS medi_amount,
        ini_unit.value AS unit_convert
    FROM
        ord_main_max ord
    CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info :: json) WITH ORDINALITY as t(ord_medi_info, idx)
    INNER JOIN mst_procedure mp ON
        ord_medi_info ->> ''procedure_cd'' = mp.procedure_cd :: text AND mp.facility_cd = @facilityCd
    LEFT JOIN mst_medicine_mix mmm ON
        ord_medi_info ->> ''cd'' = mmm.medicine_mix_cd :: text AND mmm.facility_cd = @facilityCd
    LEFT JOIN json_array_elements(mmm.mix_info :: json) medi_mix_info ON TRUE
    LEFT JOIN mst_medicine mm ON
        medi_mix_info ->> ''cd'' = mm.medicine_cd :: text AND mm.facility_cd = @facilityCd
    LEFT JOIN mst_medicine_class mmc ON mm.class_cd = mmc.class_cd AND mmc.facility_cd = @facilityCd
    LEFT JOIN ini_unit ON mm.unit = ini_unit.key2
    WHERE
        ord_medi_info ->> ''medicine_type'' = ''2''
        AND mm.is_shot = ''1''
        AND mm.is_del = ''0''
        AND mm.is_disp = ''1''
)
, procedure_code AS (
    --手技の院内コード
    SELECT
        MIN(NULLIF(CASE
        -- 両方とも利用開始日以降の場合
            WHEN ((omi.treat_date::TIMESTAMP >= mp.in_hosp_a_startdate)
                AND (omi.treat_date::TIMESTAMP >= mp.in_hosp_b_startdate)) THEN
                CASE
                    WHEN mp.in_hosp_a_startdate >= mp.in_hosp_b_startdate THEN
                        CASE ini_value.hosp_cd
                            WHEN ''1'' THEN mp.in_hospital_cd_a1
                            WHEN ''2'' THEN mp.in_hospital_cd_a2
                        END
                    WHEN mp.in_hosp_a_startdate < mp.in_hosp_b_startdate THEN
                        CASE ini_value.hosp_cd
                            WHEN ''1'' THEN mp.in_hospital_cd_b1
                            WHEN ''2'' THEN mp.in_hospital_cd_b2
                        END
                END
            -- 治療日がAの利用開始日以降の場合
            WHEN omi.treat_date::TIMESTAMP >= mp.in_hosp_a_startdate 
                AND (omi.treat_date::TIMESTAMP < mp.in_hosp_b_startdate 
                OR mp.in_hosp_b_startdate IS NULL) THEN
                CASE ini_value.hosp_cd
                    WHEN ''1'' THEN mp.in_hospital_cd_a1
                    WHEN ''2'' THEN mp.in_hospital_cd_a2
                END
            -- 治療日がBの利用開始日以降の場合
            WHEN omi.treat_date::TIMESTAMP >= mp.in_hosp_b_startdate 
                AND (omi.treat_date::TIMESTAMP < mp.in_hosp_a_startdate 
                OR mp.in_hosp_a_startdate IS NULL) THEN
                CASE ini_value.hosp_cd
                    WHEN ''1'' THEN mp.in_hospital_cd_b1
                    WHEN ''2'' THEN mp.in_hospital_cd_b2
                END
            ELSE NULL
	    END,'''')) AS procedure_hosp_cd,
        omi.procedure_cd
    FROM
        ord_medi_infos omi
        LEFT JOIN mst_procedure mp ON
            omi.procedure_cd = mp.procedure_cd AND mp.facility_cd = @facilityCd
        CROSS JOIN (
            SELECT 
            (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_PROCEDURE'') AS hosp_cd
            ) AS ini_value
    GROUP BY
        omi.procedure_cd
)
, final_ord_medi_infos AS (
    SELECT
        MIN(omi.registration_order) AS registration_order,
        MIN(mst_medi.medi_code_order) AS medi_code_order,
        MIN(mst_medi.medi_class_code_order) AS class_code_order,
        MIN(omi.medicine_type::numeric) AS medicine_type_order,
        MIN(t.timing_code_order) AS timing_code_order,
        MIN(p.procedure_code_order) AS procedure_code_order,
        MIN(omi.date_interval::numeric) AS date_interval,
        medi_cd,
        pc.procedure_hosp_cd,
        SUM(medi_amount) AS medi_amount,
        MIN(unit_convert) AS unit_convert
    FROM
        ord_medi_infos omi
    LEFT JOIN procedure_code pc ON omi.procedure_cd = pc.procedure_cd
    LEFT JOIN mst_medicine mm ON omi.medicine_cd = mm.medicine_cd :: text
    LEFT JOIN mst_medi ON mm.class_cd = mst_medi.class_cd AND mm.medicine_cd = mst_medi.medicine_cd
    LEFT JOIN timing_order t ON t.timing_code = omi.timing_cd::numeric
    LEFT JOIN procedure_order p ON p.procedure_code = omi.procedure_cd::numeric
    WHERE
        medi_cd IS NOT NULL
        AND pc.procedure_hosp_cd IS NOT NULL
    GROUP BY
        medi_cd,
        pc.procedure_hosp_cd
)
, sort_order AS (
    --薬剤の表示順
    SELECT
        ROW_NUMBER() OVER(
            order by 
            case  
                when (select setting_value from facility_medicine_order where setting_order = 1 ) = 0 then f.registration_order
                when (select setting_value from facility_medicine_order where setting_order = 1 ) = 1 then f.class_code_order
                when (select setting_value from facility_medicine_order where setting_order = 1 ) = 2 then f.medicine_type_order
                when (select setting_value from facility_medicine_order where setting_order = 1 ) = 3 then f.medi_code_order
                when (select setting_value from facility_medicine_order where setting_order = 1 ) = 4 then f.timing_code_order
                when (select setting_value from facility_medicine_order where setting_order = 1 ) = 5 then f.procedure_code_order
                when (select setting_value from facility_medicine_order where setting_order = 1 ) = 6 then f.date_interval end,
            case  
                when (select setting_value from facility_medicine_order where setting_order = 2 ) = 0 then f.registration_order
                when (select setting_value from facility_medicine_order where setting_order = 2 ) = 1 then f.class_code_order
                when (select setting_value from facility_medicine_order where setting_order = 2 ) = 2 then f.medicine_type_order
                when (select setting_value from facility_medicine_order where setting_order = 2 ) = 3 then f.medi_code_order
                when (select setting_value from facility_medicine_order where setting_order = 2 ) = 4 then f.timing_code_order
                when (select setting_value from facility_medicine_order where setting_order = 2 ) = 5 then f.procedure_code_order
                when (select setting_value from facility_medicine_order where setting_order = 2 ) = 6 then f.date_interval end,
            case  
                when (select setting_value from facility_medicine_order where setting_order = 3 ) = 0 then f.registration_order
                when (select setting_value from facility_medicine_order where setting_order = 3 ) = 1 then f.class_code_order
                when (select setting_value from facility_medicine_order where setting_order = 3 ) = 2 then f.medicine_type_order
                when (select setting_value from facility_medicine_order where setting_order = 3 ) = 3 then f.medi_code_order
                when (select setting_value from facility_medicine_order where setting_order = 3 ) = 4 then f.timing_code_order
                when (select setting_value from facility_medicine_order where setting_order = 3 ) = 5 then f.procedure_code_order
                when (select setting_value from facility_medicine_order where setting_order = 3 ) = 6 then f.date_interval end,
            case  
                when (select setting_value from facility_medicine_order where setting_order = 4 ) = 0 then f.registration_order
                when (select setting_value from facility_medicine_order where setting_order = 4 ) = 1 then f.class_code_order
                when (select setting_value from facility_medicine_order where setting_order = 4 ) = 2 then f.medicine_type_order
                when (select setting_value from facility_medicine_order where setting_order = 4 ) = 3 then f.medi_code_order
                when (select setting_value from facility_medicine_order where setting_order = 4 ) = 4 then f.timing_code_order
                when (select setting_value from facility_medicine_order where setting_order = 4 ) = 5 then f.procedure_code_order
                when (select setting_value from facility_medicine_order where setting_order = 4 ) = 6 then f.date_interval end,
            case  
                when (select setting_value from facility_medicine_order where setting_order = 5 ) = 0 then f.registration_order
                when (select setting_value from facility_medicine_order where setting_order = 5 ) = 1 then f.class_code_order
                when (select setting_value from facility_medicine_order where setting_order = 5 ) = 2 then f.medicine_type_order
                when (select setting_value from facility_medicine_order where setting_order = 5 ) = 3 then f.medi_code_order
                when (select setting_value from facility_medicine_order where setting_order = 5 ) = 4 then f.timing_code_order
                when (select setting_value from facility_medicine_order where setting_order = 5 ) = 5 then f.procedure_code_order
                when (select setting_value from facility_medicine_order where setting_order = 5 ) = 6 then f.date_interval end,
            case  
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 0 then f.registration_order
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 1 then f.class_code_order
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 2 then f.medicine_type_order
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 3 then f.medi_code_order
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 4 then f.timing_code_order
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 5 then f.procedure_code_order
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 6 then f.date_interval end,
            case  
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 0 then f.registration_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 1 then f.class_code_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 2 then f.medicine_type_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 3 then f.medi_code_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 4 then f.timing_code_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 5 then f.procedure_code_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 6 then f.date_interval end,
                f.medi_code_order
        ) as sort_key,
        medi_cd,
        procedure_hosp_cd,
        f.medi_amount,
        f.unit_convert
    FROM
        final_ord_medi_infos f
)
, procedure_hosp_order AS (
    SELECT
        procedure_hosp_cd,
        MIN(sort_key) AS min_sort_key
    FROM sort_order
    GROUP BY procedure_hosp_cd
)
, numbered_base AS (
    SELECT
        s.*,
        (ROW_NUMBER() OVER (PARTITION BY s.procedure_hosp_cd ORDER BY s.sort_key) - 1) / 10 + 1 AS rp_chunk,
        p.min_sort_key
    FROM sort_order s
    JOIN procedure_hosp_order p ON s.procedure_hosp_cd = p.procedure_hosp_cd
)
, rp_num_assigned AS (
    --RP番号の採番
    SELECT
        *,
        DENSE_RANK() OVER (ORDER BY min_sort_key, rp_chunk) AS rp_num
    FROM numbered_base
)
, medi_numbering AS (
	--薬品番号の採番
    SELECT
        *,
        ROW_NUMBER() OVER (ORDER BY rp_num,sort_key) AS new_sort_key,
        ROW_NUMBER() OVER (PARTITION BY rp_num ORDER BY sort_key) AS medi_num
    FROM rp_num_assigned
)
SELECT
    ''01'' AS detail_id,
    @key0 AS key0,
    @facilityCd AS facility_cd,
    @ctlNo AS ctl_no,
    @ordNo AS ord_no,
    @patId AS pat_id,
    sort_key,
    ROW_NUMBER() OVER (ORDER BY sort_key) AS rp_num,
    1 AS medi_num,
    LPAD(RIGHT(medi_cd,6),6,'' '') AS medi_cd,
    TRUNC(medi_amount, 2)::FLOAT8::TEXT AS medi_amount,
    unit_convert
FROM
    sort_order
WHERE
    sort_key <= 10
    AND (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''MEDICINE_SEND_TYPE'') = ''0''
UNION ALL
SELECT
    ''01'' as detail_id,
    @key0 AS key0,
    @facilityCd AS facility_cd,
    @ctlNo AS ctl_no,
    @ordNo AS ord_no,
    @patId AS pat_id,
    new_sort_key AS sort_key,
    rp_num,
    medi_num,
    LPAD(RIGHT(medi_cd,6),6,'' '') AS medi_cd,
    TRUNC(medi_amount, 2)::FLOAT8::TEXT AS medi_amount,
    unit_convert
FROM
    medi_numbering
WHERE
    rp_num <= 10
    AND new_sort_key <= 20
    AND (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''MEDICINE_SEND_TYPE'') = ''1''', '2', '[{}]', '0', '{"applications": [4]}', NULL, '(送信用)セコムの透析指示連携', '2025-06-27 10:16:58.198', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1102006, '-- SQL:-1102006 begin
WITH ord_main_switch AS(
    (
        SELECT ord.rst_dialysis_state as rst_dialysis_state,
            ord.rst_edition_date as up_date_switch
        FROM ord_main ord
        WHERE ord.ord_no = @ordNo
    )
    UNION
    (
        SELECT ord.rst_dialysis_state as rst_dialysis_state,
            ord.del_date as up_date_switch
        FROM ord_main_restore AS ord
            JOIN sys_coop_journal AS journal ON ord.ord_no = journal.ord_no
        WHERE ord.ord_no = @ordNo
            AND journal.ctl_no = @ctlNo
            AND ord.ord_no = journal.ord_no
            AND journal.reg_date >= ord.del_date
        ORDER BY del_date DESC
        LIMIT 1
    )
    ORDER BY up_date_switch DESC NULLS LAST
    LIMIT 1
)

SELECT ''01'' as detail_id,
    @facilityCd AS facility_cd,
    @ctlNo AS ctl_no,
    @key0 AS key0,
    @patId AS pat_id,
    @ordNo AS ord_no,
    @fileName AS file_name,
    @folderName AS folder_name
FROM ord_main_switch
WHERE rst_dialysis_state = ''0'';
-- SQL:-1102006 end', '2', '[{}]', '0', '{"applications": [4]}', NULL, '(送信用)セコムの透析指示連携_予約受付のdetail特定', '2025-06-25 16:03:16.883', CURRENT_TIMESTAMP, '[{"sql_cd": -1100009, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1102003, 'WITH coop_ini_info AS (
    --連携設定から取得
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value,
        info ->> ''key1'' AS key1,
        info ->> ''key2'' AS key2
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE
        ini.facility_cd = @facilityCd
        AND ini.is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' in(
            ''SCM_COMMON'',
            ''SCM_IN_HOSPITAL_CD'',
            ''SCM_CONV_UNIT_MEDI''
        )
)
, facility_medicine_order as (
    -- 施設設定マスタ(No.107)
    SELECT
        ROW_NUMBER() OVER () AS setting_order, -- 適用順 
        datt.a1 AS setting_value -- 設定値
    FROM (
        SELECT
            TO_NUMBER(val, ''999999999999'') AS a1
        FROM unnest(
            COALESCE(
            string_to_array(
                (
                SELECT mst_f.value
                FROM mst_facility_setting AS mst_f
                WHERE mst_f.facility_setting_no = ''3007''
                    AND mst_f.facility_cd = @facilityCd
                ),
                '',''
            ),
            ARRAY[''0'']  -- デフォルト値を配列で補う
            )
        ) AS val
    ) AS datt
)
, medi_order as (
    -- 薬剤マスタの並び順
    select index_no::int as medi_code_order,
        TO_NUMBER(order_cd->>''code'', ''999999999999'') as medi_code,
        order_cd->>''name'' as name
    from mst_selector
        cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(order_cd, index_no)
    where facility_cd = @facilityCd
        and master_physical_name = ''mst_medicine''
)
, medi_class_order as (
    -- 薬剤分類マスタの並び順
    select index_no::int as medi_class_code_order,
        TO_NUMBER(order_cd->>''code'', ''999999999999'') as medi_class_code,
        order_cd->>''name'' as class_name
    from mst_selector
        cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(order_cd, index_no)
    where facility_cd = @facilityCd
        and master_physical_name = ''mst_medicine_class''
)
, timing_order as (
    -- 投与タイミングマスタの並び順
    select
        index_no ::int as timing_code_order
        , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') as timing_code
    from mst_selector
    cross join LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality as tmp(order_cd, index_no)
    where facility_cd = @facilityCd
        and master_physical_name = ''mst_medicate_timing''
)
, procedure_order as (
    -- 手技マスタの並び順
    select
        index_no ::int as procedure_code_order
        , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') as procedure_code
    from mst_selector
    cross join LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality as tmp(order_cd, index_no)
    where facility_cd = @facilityCd
    and master_physical_name = ''mst_procedure''
)
, mst_medi as (
    select
        medicine_cd,
        class_cd,
        medi_order.medi_code_order,
        medi_class_order.medi_class_code_order
    from mst_medicine mmd
        left join medi_order on mmd.medicine_cd = medi_order.medi_code
        left join medi_class_order on mmd.class_cd = medi_class_order.medi_class_code
    where facility_cd = @facilityCd
)
, ord_main_max AS (
    (
        SELECT
            ord.ord_no,
            ord.del_date AS up_date,
            ord.treat_date,
            ord.ind_medi_info
        FROM
            ord_main_restore AS ord,
            sys_coop_journal AS journal
        WHERE
            ord.ord_no = @ordNo
            AND ord.facility_cd = @facilityCd
            AND journal.facility_cd = @facilityCd
            AND journal.ctl_no = @ctlNo
            AND ord.ord_no = journal.ord_no
            AND journal.reg_date >= ord.del_date
        ORDER BY
            del_date DESC
        LIMIT 1
    )
    UNION
    (
        SELECT
            ord.ord_no,
            ord.rst_edition_date AS up_date,
            ord.treat_date,
            ord.ind_medi_info
        FROM
            ord_main AS ord
        WHERE
            ord.ord_no = @ordNo
            AND ord.facility_cd = @facilityCd
    )
    ORDER BY
        up_date DESC NULLS LAST
    LIMIT 1
)
, ord_medi_infos AS (
    --通常薬剤
    SELECT
        100 + t.idx as registration_order,
        ord_medi_info ->> ''cd'' AS medicine_cd,
        mm.class_cd AS class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        mp.procedure_cd,
        ord.treat_date,
        ord_medi_info->>''date_interval'' as date_interval,
        CASE
            (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_MEDICINE'')
            WHEN ''1'' THEN mm.in_hospital_cd_1
            WHEN ''2'' THEN mm.in_hospital_cd_2
            WHEN ''3'' THEN mm.in_hospital_cd_3
            WHEN ''4'' THEN mm.in_hospital_cd_4
        END AS medi_cd
    FROM
        ord_main_max ord
    CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info :: json) WITH ORDINALITY as t(ord_medi_info, idx)
    INNER JOIN mst_procedure mp ON 
        ord_medi_info ->> ''procedure_cd'' = mp.procedure_cd :: text AND mp.facility_cd = @facilityCd
    LEFT JOIN mst_medicine mm ON 
        ord_medi_info ->> ''cd'' = mm.medicine_cd :: text AND mm.facility_cd = @facilityCd
    LEFT JOIN mst_medicine_class mmc on mm.class_cd = mmc.class_cd AND mmc.facility_cd = @facilityCd
    WHERE
        ord_medi_info ->> ''medicine_type'' = ''1''
        AND mm.is_shot = ''1''
        AND mm.is_del = ''0''
        AND mm.is_disp = ''1''
    UNION ALL
    --調整薬剤
    SELECT
        100 + t.idx as registration_order,
        medi_mix_info ->> ''cd'' AS medicine_cd,
        mm.class_cd AS class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        mp.procedure_cd,
        ord.treat_date,
        ord_medi_info->>''date_interval'' as date_interval,
        CASE
            (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_MEDICINE'')
            WHEN ''1'' THEN mm.in_hospital_cd_1
            WHEN ''2'' THEN mm.in_hospital_cd_2
            WHEN ''3'' THEN mm.in_hospital_cd_3
            WHEN ''4'' THEN mm.in_hospital_cd_4
        END AS medi_cd
    FROM
        ord_main_max ord
    CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info :: json) WITH ORDINALITY as t(ord_medi_info, idx)
    INNER JOIN mst_procedure mp ON
        ord_medi_info ->> ''procedure_cd'' = mp.procedure_cd :: text AND mp.facility_cd = @facilityCd
    LEFT JOIN mst_medicine_mix mmm ON
        ord_medi_info ->> ''cd'' = mmm.medicine_mix_cd :: text AND mmm.facility_cd = @facilityCd
    LEFT JOIN json_array_elements(mmm.mix_info :: json) medi_mix_info ON TRUE
    LEFT JOIN mst_medicine mm ON
        medi_mix_info ->> ''cd'' = mm.medicine_cd :: text AND mm.facility_cd = @facilityCd
    LEFT JOIN mst_medicine_class mmc ON mm.class_cd = mmc.class_cd AND mmc.facility_cd = @facilityCd
    WHERE
        ord_medi_info ->> ''medicine_type'' = ''2''
        AND mm.is_shot = ''1''
        AND mm.is_del = ''0''
        AND mm.is_disp = ''1''
)
, procedure_code AS (
    --手技の院内コード
    SELECT
        MIN(NULLIF(CASE
        -- 両方とも利用開始日以降の場合
            WHEN ((omi.treat_date::TIMESTAMP >= mp.in_hosp_a_startdate)
                AND (omi.treat_date::TIMESTAMP >= mp.in_hosp_b_startdate)) THEN
                CASE
                    WHEN mp.in_hosp_a_startdate >= mp.in_hosp_b_startdate THEN
                        CASE ini_value.hosp_cd
                            WHEN ''1'' THEN mp.in_hospital_cd_a1
                            WHEN ''2'' THEN mp.in_hospital_cd_a2
                        END
                    WHEN mp.in_hosp_a_startdate < mp.in_hosp_b_startdate THEN
                        CASE ini_value.hosp_cd
                            WHEN ''1'' THEN mp.in_hospital_cd_b1
                            WHEN ''2'' THEN mp.in_hospital_cd_b2
                        END
                END
            -- 治療日がAの利用開始日以降の場合
            WHEN omi.treat_date::TIMESTAMP >= mp.in_hosp_a_startdate 
                AND (omi.treat_date::TIMESTAMP < mp.in_hosp_b_startdate 
                OR mp.in_hosp_b_startdate IS NULL) THEN
                CASE ini_value.hosp_cd
                    WHEN ''1'' THEN mp.in_hospital_cd_a1
                    WHEN ''2'' THEN mp.in_hospital_cd_a2
                END
            -- 治療日がBの利用開始日以降の場合
            WHEN omi.treat_date::TIMESTAMP >= mp.in_hosp_b_startdate 
                AND (omi.treat_date::TIMESTAMP < mp.in_hosp_a_startdate 
                OR mp.in_hosp_a_startdate IS NULL) THEN
                CASE ini_value.hosp_cd
                    WHEN ''1'' THEN mp.in_hospital_cd_b1
                    WHEN ''2'' THEN mp.in_hospital_cd_b2
                END
            ELSE NULL
	    END,'''')) AS procedure_hosp_cd,
        omi.procedure_cd
    FROM
        ord_medi_infos omi
        LEFT JOIN mst_procedure mp ON
            omi.procedure_cd = mp.procedure_cd AND mp.facility_cd = @facilityCd
        CROSS JOIN (
            SELECT 
            (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_PROCEDURE'') AS hosp_cd
            ) AS ini_value
    GROUP BY
        omi.procedure_cd
)
, final_ord_medi_infos AS (
    SELECT
        MIN(omi.registration_order) AS registration_order,
        MIN(mst_medi.medi_code_order) AS medi_code_order,
        MIN(mst_medi.medi_class_code_order) AS class_code_order,
        MIN(omi.medicine_type::numeric) AS medicine_type_order,
        MIN(t.timing_code_order) AS timing_code_order,
        MIN(p.procedure_code_order) AS procedure_code_order,
        MIN(omi.date_interval::numeric) AS date_interval,
        medi_cd,
        pc.procedure_hosp_cd
    FROM
        ord_medi_infos omi
    LEFT JOIN procedure_code pc ON omi.procedure_cd = pc.procedure_cd
    LEFT JOIN mst_medicine mm ON omi.medicine_cd = mm.medicine_cd :: text
    LEFT JOIN mst_medi ON mm.class_cd = mst_medi.class_cd AND mm.medicine_cd = mst_medi.medicine_cd
    LEFT JOIN timing_order t ON t.timing_code = omi.timing_cd::numeric
    LEFT JOIN procedure_order p ON p.procedure_code = omi.procedure_cd::numeric
    WHERE
        medi_cd IS NOT NULL
        AND pc.procedure_hosp_cd IS NOT NULL
    GROUP BY
        medi_cd,
        pc.procedure_hosp_cd
)
, sort_order AS (
    --薬剤の表示順
    SELECT
        ROW_NUMBER() OVER(
            order by 
            case  
                when (select setting_value from facility_medicine_order where setting_order = 1 ) = 0 then f.registration_order
                when (select setting_value from facility_medicine_order where setting_order = 1 ) = 1 then f.class_code_order
                when (select setting_value from facility_medicine_order where setting_order = 1 ) = 2 then f.medicine_type_order
                when (select setting_value from facility_medicine_order where setting_order = 1 ) = 3 then f.medi_code_order
                when (select setting_value from facility_medicine_order where setting_order = 1 ) = 4 then f.timing_code_order
                when (select setting_value from facility_medicine_order where setting_order = 1 ) = 5 then f.procedure_code_order
                when (select setting_value from facility_medicine_order where setting_order = 1 ) = 6 then f.date_interval end,
            case  
                when (select setting_value from facility_medicine_order where setting_order = 2 ) = 0 then f.registration_order
                when (select setting_value from facility_medicine_order where setting_order = 2 ) = 1 then f.class_code_order
                when (select setting_value from facility_medicine_order where setting_order = 2 ) = 2 then f.medicine_type_order
                when (select setting_value from facility_medicine_order where setting_order = 2 ) = 3 then f.medi_code_order
                when (select setting_value from facility_medicine_order where setting_order = 2 ) = 4 then f.timing_code_order
                when (select setting_value from facility_medicine_order where setting_order = 2 ) = 5 then f.procedure_code_order
                when (select setting_value from facility_medicine_order where setting_order = 2 ) = 6 then f.date_interval end,
            case  
                when (select setting_value from facility_medicine_order where setting_order = 3 ) = 0 then f.registration_order
                when (select setting_value from facility_medicine_order where setting_order = 3 ) = 1 then f.class_code_order
                when (select setting_value from facility_medicine_order where setting_order = 3 ) = 2 then f.medicine_type_order
                when (select setting_value from facility_medicine_order where setting_order = 3 ) = 3 then f.medi_code_order
                when (select setting_value from facility_medicine_order where setting_order = 3 ) = 4 then f.timing_code_order
                when (select setting_value from facility_medicine_order where setting_order = 3 ) = 5 then f.procedure_code_order
                when (select setting_value from facility_medicine_order where setting_order = 3 ) = 6 then f.date_interval end,
            case  
                when (select setting_value from facility_medicine_order where setting_order = 4 ) = 0 then f.registration_order
                when (select setting_value from facility_medicine_order where setting_order = 4 ) = 1 then f.class_code_order
                when (select setting_value from facility_medicine_order where setting_order = 4 ) = 2 then f.medicine_type_order
                when (select setting_value from facility_medicine_order where setting_order = 4 ) = 3 then f.medi_code_order
                when (select setting_value from facility_medicine_order where setting_order = 4 ) = 4 then f.timing_code_order
                when (select setting_value from facility_medicine_order where setting_order = 4 ) = 5 then f.procedure_code_order
                when (select setting_value from facility_medicine_order where setting_order = 4 ) = 6 then f.date_interval end,
            case  
                when (select setting_value from facility_medicine_order where setting_order = 5 ) = 0 then f.registration_order
                when (select setting_value from facility_medicine_order where setting_order = 5 ) = 1 then f.class_code_order
                when (select setting_value from facility_medicine_order where setting_order = 5 ) = 2 then f.medicine_type_order
                when (select setting_value from facility_medicine_order where setting_order = 5 ) = 3 then f.medi_code_order
                when (select setting_value from facility_medicine_order where setting_order = 5 ) = 4 then f.timing_code_order
                when (select setting_value from facility_medicine_order where setting_order = 5 ) = 5 then f.procedure_code_order
                when (select setting_value from facility_medicine_order where setting_order = 5 ) = 6 then f.date_interval end,
            case  
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 0 then f.registration_order
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 1 then f.class_code_order
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 2 then f.medicine_type_order
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 3 then f.medi_code_order
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 4 then f.timing_code_order
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 5 then f.procedure_code_order
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 6 then f.date_interval end,
            case  
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 0 then f.registration_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 1 then f.class_code_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 2 then f.medicine_type_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 3 then f.medi_code_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 4 then f.timing_code_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 5 then f.procedure_code_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 6 then f.date_interval end,
                f.medi_code_order
        ) as sort_key,
        medi_cd,
        procedure_hosp_cd
    FROM
        final_ord_medi_infos f
)
, procedure_hosp_order AS (
    SELECT
        procedure_hosp_cd,
        MIN(sort_key) AS min_sort_key
    FROM sort_order
    GROUP BY procedure_hosp_cd
)
, numbered_base AS (
    SELECT
        s.*,
        (ROW_NUMBER() OVER (PARTITION BY s.procedure_hosp_cd ORDER BY s.sort_key) - 1) / 10 + 1 AS rp_chunk,
        p.min_sort_key
    FROM sort_order s
    JOIN procedure_hosp_order p ON s.procedure_hosp_cd = p.procedure_hosp_cd
)
, rp_num_assigned AS (
    --RP番号の採番
    SELECT
        *,
        DENSE_RANK() OVER (ORDER BY min_sort_key, rp_chunk) AS rp_num
    FROM numbered_base
)
, medi_numbering AS (
	--薬品番号の採番
    SELECT
        *,
        ROW_NUMBER() OVER (ORDER BY rp_num,sort_key) AS new_sort_key,
        ROW_NUMBER() OVER (PARTITION BY rp_num ORDER BY sort_key) AS medi_num
    FROM rp_num_assigned
)
SELECT
    ''01'' as detail_id,
    @key0 AS key0,
    @facilityCd AS facility_cd,
    @ctlNo AS ctl_no,
    @ordNo AS ord_no,
    @patId AS pat_id,
    sort_key,
    ROW_NUMBER() OVER (ORDER BY sort_key) AS rp_num,
    1 AS medi_count,
    LPAD(RIGHT(procedure_hosp_cd,2),2,'' '') AS procedure_hosp_cd
FROM
    sort_order
WHERE
    sort_key <= 10
    AND (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''MEDICINE_SEND_TYPE'') = ''0''
UNION ALL
SELECT
    ''01'' as detail_id,
    @key0 AS key0,
    @facilityCd AS facility_cd,
    @ctlNo AS ctl_no,
    @ordNo AS ord_no,
    @patId AS pat_id,
    ROW_NUMBER() OVER (ORDER BY rp_num) AS sort_key,
    rp_num,
    COUNT(*) AS medi_count,
    MIN(LPAD(RIGHT(procedure_hosp_cd,2),2,'' '')) AS procedure_hosp_cd
FROM
    medi_numbering
WHERE
    rp_num <= 10
    AND new_sort_key <= 20
    AND (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''MEDICINE_SEND_TYPE'') = ''1''
GROUP BY
    rp_num', '2', '[{}]', '0', '{"applications": [4]}', NULL, '(送信用)セコムの透析指示連携', '2025-06-27 10:16:58.198', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1100015, 'select
	-- 日付をYYYY/MM/DD形式に整形
	TO_CHAR(
    TO_DATE(jsonb_extract_path_text(save_2, @fileKind || ''_send_day''), ''YYYYMMDD''),
    ''YYYY-MM-DD''
  ) as occur_date,
	-- 時刻をHH24:MI:SS形式に整形
	TO_CHAR(
    TO_TIMESTAMP(jsonb_extract_path_text(save_2, @fileKind || ''_seq_no''), ''HH24MISS''),
    ''HH24:MI:SS''
  ) as occur_time
from
	pat_coop_detail
where
	facility_cd = @facilityCd
	and pat_id = @patId
	and (save_2 ->> ''ord_no'')::integer = @ordNo
	and (save_2 ->> ''coop_cd'') = @coopCd
order by
	up_date desc
limit 1;', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム連携 削除時の発生日/SEQ番号', '2025-07-15 17:03:42.136', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1100013, 'WITH forder_name AS (
    SELECT 
        COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS value
    FROM mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE facility_cd = @facilityCd
        AND is_del = ''0''
        AND COALESCE(info->>''key0'', '''') = @key0
        AND info->>''key1'' = @key1
        AND info->>''key2'' = CASE @fileKind
            WHEN ''treatment'' THEN ''TREAT_FOLDER''
            WHEN ''injection'' THEN ''INJECT_FOLDER''
            WHEN ''schedule'' THEN ''SCHE_FOLDER''
            WHEN ''medical'' THEN ''KARTE_FOLDER''
            WHEN ''xray'' THEN ''XRAY_FOLDER''
            ELSE NULL 
        END
)
SELECT COALESCE(
  (SELECT value FROM forder_name LIMIT 1),
  ''''
) AS folder_name;
', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'Secom連携_汎用（連携設定 フォルダ名取得用）', '2025-07-02 15:36:26.753', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1100011, 'select  
''01'' as detail_id,
@facilityCd AS facility_cd,
@ctlNo AS ctl_no,
@key0 AS key0,
@patId AS pat_id,
@ordNo AS ord_no', '2', '[{}]', '0', '{"applications": [4]}', NULL, '(送信用)セコムのrootからdetail、recordを特定するSQL', '2025-06-25 16:03:16.883', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1100010, 'select  
''01'' as detail_id,
@facilityCd AS facility_cd,
@ctlNo AS ctl_no,
@key0 AS key0,
@patId AS pat_id,
@ordNo AS ord_no,
@fileName AS file_name,
@folderName AS folder_name', '2', '[{}]', '0', '{"applications": [4]}', NULL, '(送信用)セコムのrootからdetail、recordを特定するSQL(カルテ用)', '2025-06-25 16:03:16.883', CURRENT_TIMESTAMP, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1100009, 'WITH coop_ini_info as (
--連携設定取得(pre_sqlにて取得)
SELECT
  coop_info ->> ''key1'' as key1,
  coop_info ->> ''key2'' as key2,
  coop_info ->> ''value'' as value
FROM
  json_array_elements(@coop_ini_info::json) coop_info
  WHERE
  COALESCE(coop_info ->> ''key1'', '''') = @key1
  and COALESCE(coop_info ->> ''key2'', '''') = @key2
)

select 
(select value from coop_ini_info)||  TO_CHAR(current_timestamp,''YYYYMMDDHH24MISS'') || ''.csv'' AS filename
', '2', '[]', '0', '{"applications": [4]}', NULL, 'Secom連携_RCyyyymmddhhmmss.xxx', '2025-07-08 15:03:25.061', CURRENT_TIMESTAMP, '[{"sql_cd": -1100005, "field_name": "coop_ini_info", "replace_var": "@coop_ini_info"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1100008, E'WITH coop_ini_info AS (
    --連携設定取得(pre_sqlにて取得)
    SELECT CASE
            WHEN @key2 = ''NULL'' THEN ''NULL''
            ELSE coop_info->>''value''
        END AS value
    FROM json_array_elements(@coop_ini_info::json) coop_info
    WHERE (
            @key2 = ''NULL''
            OR (
                COALESCE(coop_info->>''key1'', '''') = @key1
                AND COALESCE(coop_info->>''key2'', '''') = @key2
            )
        )
    LIMIT 1
), input_values AS (
    SELECT LPAD(RIGHT(@hosp_pat_id, 8), 8, ''0'')::text AS hospital_id,
        (
            SELECT value
            FROM coop_ini_info
        )::text AS ini_value,
        TO_CHAR(@time::timestamptz, ''YYYYMMDD_HH24MISS'') AS timestamp
),
folder_values AS (
    SELECT COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS value
    FROM mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE facility_cd = @facilityCd
        AND is_del = ''0''
        AND COALESCE(info->>''key0'', '''') = @key0
        AND info->>''key1'' = @key1
        AND info->>''key2'' IN (''TREAT_FOLDER'', ''INJECT_FOLDER'')
),
folder_check AS (
    SELECT COUNT(DISTINCT value) = 1 AS is_same_folder
    FROM folder_values
),
params AS (
    SELECT CASE
            WHEN @fileKind = ''treatment''
            AND (
                SELECT is_same_folder
                FROM folder_check
            ) THEN 1
            WHEN @fileKind = ''injection''
            AND (
                SELECT is_same_folder
                FROM folder_check
            ) THEN 2
            WHEN @fileKind = ''medical'' THEN 1
            ELSE 1
        END AS increment,
        CASE
            WHEN @fileKind = ''medical'' THEN ''medical''
            ELSE ''other''
        END AS kind_group
),
regexp_patterns AS (
    SELECT CASE
            WHEN kind_group = ''medical'' THEN ''_([0-9]{3})\\\\.[a-z0-9]+$''
            ELSE ''_([0-9]+)\\\\.[a-z0-9]+$''
        END AS regex
    FROM params
),
target_pattern AS (
    SELECT i.hospital_id || ''_'' || i.ini_value || ''_'' || i.timestamp AS base_name
    FROM input_values i
),
used_suffixes AS (
    SELECT SUBSTRING(
            path_part
            FROM ''_([0-9]+)\\.txt$''
        )::integer AS suffix
    FROM sys_coop_journal j
        CROSS JOIN LATERAL regexp_split_to_table(j.dump_path, ''\\|'') AS path_part
        JOIN target_pattern p ON TRUE
    WHERE path_part LIKE ''%'' || p.base_name || ''_%''
        AND path_part ~ (''_'' || ''[0-9]+'' || ''\\.txt$'')
        AND facility_cd = @facilityCd
        AND pat_id = @patId
),
next_suffix_raw AS (
    SELECT COALESCE(MAX(suffix), 0) AS max_suffix
    FROM used_suffixes
),
next_suffix AS (
    SELECT CASE
            WHEN p.kind_group = ''medical'' OR @fileKind = ''emrnote'' THEN ''.'' || LPAD((r.max_suffix + p.increment)::text, 3, ''0'')
            ELSE ''_'' || (r.max_suffix + p.increment)::text
        END AS next_suffix
    FROM next_suffix_raw r
        CROSS JOIN params p
),
filename AS (
    SELECT i.hospital_id || ''_'' || i.ini_value || ''_'' || i.timestamp || n.next_suffix || ''.'' || @file_extension AS filename
    FROM input_values i
        CROSS JOIN next_suffix n
)
SELECT *
FROM filename;', '2', '[]', '0', '{"applications": [4]}', NULL, 'Secom連携_nnnnnnnn_xxxxxxxx_yyyymmdd_hhmmss_zzz.xxx形式のファイル名', '2025-06-23 23:41:19.59', CURRENT_TIMESTAMP, '[{"sql_cd": -1100005, "field_name": "coop_ini_info", "replace_var": "@coop_ini_info"}, {"sql_cd": -1100006, "field_name": "hosp_pat_id", "replace_var": "@hosp_pat_id"}]');


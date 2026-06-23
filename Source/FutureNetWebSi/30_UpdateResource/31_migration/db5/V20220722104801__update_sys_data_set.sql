delete from ntss.sys_data_set where sql_cd in ('9613','9614','9615');
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (9615, 'with currentDate as (select to_char(current_date, ''yyyymmdd'') as nowDate),
     infectValue as (select (case
                                 when ''@infectInfo.infect'' = ''0''
                                     or ''@infectInfo.infect'' = ''1''
                                     or ''@infectInfo.infect'' = ''2''
                                     then ''@infectInfo.infect''
                                 else ''0'' end) as infectValue),
     examDate as (select to_char(to_date(''@infectInfo.examDate_Date'', ''yyyy-mm-dd''), ''yyyymmdd'') as examDate),
     changeOrNot as (select (case
                                 when (infectValue.infectValue <> coalesce(t0.infect, '''') or examDate.examDate <> coalesce(t0.exam_date, ''''))
                                     then true
                                 else false end) as res
                     from (select value ->> ''infect'' as infect, value ->> ''exam_date'' as exam_date
                           FROM pat_main,
                               jsonb_array_elements(infect_info) WITH ORDINALITY
                           WHERE is_del = ''0''
                             AND pat_id = @patId
                             AND value ->> ''infection_cd'' = ''@infectInfo.infectionCd'') t0,
                          infectValue,
                          examDate)
update pat_main
set infect_info = (case when ''@infectInfo.infectionCd'' != '''' and changeOrNot.res then jsonb_set(
        infect_info,
        array [
            (select ORDINALITY::INT - 1
             FROM pat_main d2,
                 jsonb_array_elements(infect_info) WITH ORDINALITY
             WHERE is_del = ''0''
               AND pat_id = @patId
               AND value ->> ''infection_cd'' = ''@infectInfo.infectionCd'')::text,
            ''exam_date''
            ],
        cast(''"''|| examDate.examDate ||''"'' as text)::jsonb
    ) else infect_info end)
from currentDate,
     infectValue,
     changeOrNot,
     examDate
WHERE is_del = ''0''
  AND pat_id = @patId
  and facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', null, '(受信用)日機装の患者プロファイル(感染症情報)', '2022-06-08 00:56:38.271', CURRENT_TIMESTAMP, null);
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (9614, 'with infectValue as (select (case
                                 when ''@infectInfo.infect'' = ''0''
                                     or ''@infectInfo.infect'' = ''1''
                                     or ''@infectInfo.infect'' = ''2''
                                     then ''@infectInfo.infect''
                                 else ''0'' end) as infectValue),
     examDate as (select to_char(to_date(''@infectInfo.examDate_Date'', ''yyyy-mm-dd''), ''yyyymmdd'') as examDate),
     changeOrNot as (select (case
                                 when (infectValue.infectValue <> coalesce(t0.infect, '''') or examDate.examDate <> coalesce(t0.exam_date, ''''))
                                     then true
                                 else false end) as res
                     from (select value ->> ''infect'' as infect, value ->> ''exam_date'' as exam_date
                           FROM pat_main,
                               jsonb_array_elements(infect_info) WITH ORDINALITY
                           WHERE is_del = ''0''
                             AND pat_id = @patId
                             AND value ->> ''infection_cd'' = ''@infectInfo.infectionCd'') t0,
                          infectValue,
                          examDate)
update pat_main
set infect_info = (case
                       when ''@infectInfo.infectionCd'' != '''' and changeOrNot.res then jsonb_set(
                               infect_info,
                               array [
                                   (select ORDINALITY::INT - 1
                                    FROM pat_main d2,
                                        jsonb_array_elements(infect_info) WITH ORDINALITY
                                    WHERE is_del = ''0''
                                      AND pat_id = @patId
                                      AND value ->> ''infection_cd'' = ''@infectInfo.infectionCd'')::text,
                                   ''infect''
                                   ],
                               cast(''"'' || infectValue.infectValue || ''"'' as text)::jsonb
                           )
                       else infect_info end)
from infectValue,
     changeOrNot,
     examDate
WHERE is_del = ''0''
  AND pat_id = @patId
  and facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', null, '(受信用)日機装の患者プロファイル(感染症情報)', '2022-06-08 00:56:38.271', CURRENT_TIMESTAMP, null);
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (9613, 'with currentDate as (select to_char(current_date, ''yyyymmdd'') as nowDate),
     infectValue as (select (case
                                 when ''@infectInfo.infect'' = ''0''
                                     or ''@infectInfo.infect'' = ''1''
                                     or ''@infectInfo.infect'' = ''2''
                                     then ''@infectInfo.infect''
                                 else ''0'' end) as infectValue),
     examDate as (select to_char(to_date(''@infectInfo.examDate_Date'', ''yyyy-mm-dd''), ''yyyymmdd'') as examDate),
     changeOrNot as (select (case
                                 when (infectValue.infectValue <> coalesce(t0.infect, '''') or examDate.examDate <> coalesce(t0.exam_date, ''''))
                                     then true
                                 else false end) as res
                     from (select value ->> ''infect'' as infect, value ->> ''exam_date'' as exam_date
                           FROM pat_main,
                               jsonb_array_elements(infect_info) WITH ORDINALITY
                           WHERE is_del = ''0''
                             AND pat_id = @patId
                             AND value ->> ''infection_cd'' = ''@infectInfo.infectionCd'') t0,
                          infectValue,
                          examDate)
update pat_main
set infect_info = (case
                       when ''@infectInfo.infectionCd'' != '''' and changeOrNot.res then jsonb_set(
                               infect_info,
                               array [
                                   (select ORDINALITY::INT - 1
                                    FROM pat_main d2,
                                        jsonb_array_elements(infect_info) WITH ORDINALITY
                                    WHERE is_del = ''0''
                                      AND pat_id = @patId
                                      AND value ->> ''infection_cd'' = ''@infectInfo.infectionCd'')::text,
                                   ''up_date''
                                   ],
                               cast(''"'' || currentDate.nowDate || ''"'' as text)::jsonb
                           )
                       else infect_info end)
from currentDate,
     infectValue,
     changeOrNot,
     examDate
WHERE is_del = ''0''
  AND pat_id = @patId
  and facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', null, '(受信用)日機装の患者プロファイル(感染症情報)', '2022-06-08 00:56:38.271', CURRENT_TIMESTAMP, null);

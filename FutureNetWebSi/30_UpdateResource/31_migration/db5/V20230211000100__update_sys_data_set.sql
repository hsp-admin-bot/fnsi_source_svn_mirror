DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (9615,9614,9613,7115,-2401);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9615, 'with currentDate as (select to_char(current_date, ''yyyymmdd'') as nowDate),
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
  and facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(感染症情報)', '2022-06-08 00:56:38.271', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9613, 'with currentDate as (select to_char(current_date, ''yyyymmdd'') as nowDate),
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
  and facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(感染症情報)', '2022-06-08 00:56:38.271', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9614, 'with infectValue as (select (case
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
  and facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(感染症情報)', '2022-06-08 00:56:38.271', CURRENT_TIMESTAMP, NULL);
  INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7115, 'SELECT
 COALESCE ( NULLIF ( info ->> ''dial_diff_cd'', '''' )) AS info_diff_cd
FROM
	pat_personal_main as ppm
	CROSS JOIN LATERAL json_array_elements (ppm.dial_diff_com_info :: json ) info 
WHERE
	pat_id = @patId 
	AND facility_cd = @facilityCd
	AND is_del = ''0''
	AND info ->> ''is_main'' = ''1''
	AND info ->> ''dial_diff_cd'' != @dialysis_difficulty_cd :: text
	AND @dialDiffComInfo.ctlNo = ''1''
	union
select ''0'' as info_diff_cd
order by info_diff_cd desc nulls last
limit 1', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(透析困難情報)の主透析困難cdの取得', '2022-08-05 11:01:31.53',CURRENT_TIMESTAMP, '[{"sql_cd": 7104, "field_name": "dialysis_difficulty_cd_no", "replace_var": "@dialysis_difficulty_cd"}]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2401, 'select

  ord.pat_id,

  ord.ord_no

from

  ord_main ord

where

    ord.is_del = ''0''

and ord.facility_cd = @facilityCd

and ord.treat_date =to_char(CURRENT_DATE, ''YYYYMMDD'')

', 2, '[{}]', '0', '{"applications": [4]}', NULL, '定時一括送信機能（患者プロファイル用）', '2020-03-11 18:05:37.059',CURRENT_TIMESTAMP, NULL);


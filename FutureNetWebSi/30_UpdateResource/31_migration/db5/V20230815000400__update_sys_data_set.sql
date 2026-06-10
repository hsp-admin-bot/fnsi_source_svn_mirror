delete from ntss.sys_data_set where sql_cd in (156, 139, 134, 131, 96, 80, 76, 72, 70, 66, 64, 61, 59, 58, 57, 56, 55, 54, 53, 51, 49, 48, 47, 46, 44, 42, 41, 40, 34, 32, 25, 24, 23, 21, 18, 14, -22, -31, -32, -33, -37, -98, -205, -301, -302, -303, -304, -401, -402, -403, -404, -405, -406, -407, -408, -409, -411, -412, -413, -414, -415, -416, -11001, -11003, -11005, -11007, -11008, -11009, -11010, -11011, -11012, -11013, -11014, -11015, -11016, -11017, -11018, -11019, -11020, -11021, -11022, -11023, -11024, -11025, -11026, -11027, -11028, -11029, -11030, -11031, -11032, -11033, -11034, -11035, -11036, -11037, -11038, -11039, -11041, -11042, -11043, -11045, -99998
);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-99998, 'select
  to_char(current_timestamp, ''YYYYMMDD_'') ||
  to_char(current_timestamp, ''HH24MISS_'') ||
  ''1_'' ||
  ppm.hosp_pat_id ||
  ''.dat'' as filename
from
  ntss.pat_personal_main as ppm
where
  pat_id = @patId', 3, '[{}]', '0', '{"applications": [4]}', NULL, 'パナ受付ファイル名取得', '2020-03-24 10:52:31.233', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-11045, 'WITH exchange AS ( SELECT unit_converted_amount, unit_converted_amount_second, is_exchange FROM mst_medicine WHERE medicine_cd = @id AND is_del = ''0'' AND facility_cd = @facilityCd
),
ord1 AS (SELECT
             treat_date,
             COUNT(*) as ord1
         FROM
             ord_main
         WHERE
             to_number(ind_cond_info -> ''25'' ->> ''value'', ''9999999999999999999'' ) = @id
             AND treat_date BETWEEN @dateFrom AND @dateTo
             AND is_del = ''0''
             AND facility_cd = @facilityCd
             AND pat_id is not null
         group by treat_date
),
ord2 AS (SELECT
             treat_date,
             SUM(to_number( mediInfo ->> ''amount'', ''9999999999999999999'')) as ord2
         FROM
             ord_main
             CROSS JOIN LATERAL json_array_elements ( ind_medi_info :: json ) mediInfo
         WHERE
             to_number(mediInfo ->> ''cd'', ''9999999999999999999'' ) = @id
             AND treat_date BETWEEN @dateFrom AND @dateTo
             AND is_del = ''0''
             AND facility_cd = @facilityCd
             AND pat_id is not null
         group by treat_date
)

 select
   treat_date, sum(count) as count
 from
   ((SELECT
         ord1.treat_date,
         COALESCE(case
                    when exchange.is_exchange = ''0''
                        AND (exchange.unit_converted_amount_second is NOT NULL OR
                             exchange.unit_converted_amount is NOT NULL)
                        AND exchange.unit_converted_amount_second != 0 then
                        round(((ord1.ord1) / exchange.unit_converted_amount) *
                              exchange.unit_converted_amount_second, 1)
                    when exchange.is_exchange = ''1''
                        AND (exchange.unit_converted_amount_second is NOT NULL OR
                             exchange.unit_converted_amount is NOT NULL)
                        AND exchange.unit_converted_amount_second != 0 then
                            CEILING((ord1.ord1) / exchange.unit_converted_amount) *
                            exchange.unit_converted_amount_second
                    when exchange.is_exchange = ''2''
                        AND ord1.ord1 <> ''0'' and ord1.ord1 is not null
                        AND exchange.unit_converted_amount_second is NOT NULL then
                        exchange.unit_converted_amount_second
                    ELSE 0 END
         , 0) as count
     from exchange,
         ord1)
     UNION ALL
    (SELECT
         ord2.treat_date,
         COALESCE(case
                    when exchange.is_exchange = ''0''
                        AND (exchange.unit_converted_amount_second is NOT NULL OR
                             exchange.unit_converted_amount is NOT NULL)
                        AND exchange.unit_converted_amount_second != 0 then
                        round(((ord2.ord2) / exchange.unit_converted_amount) *
                              exchange.unit_converted_amount_second, 1)
                    when exchange.is_exchange = ''1''
                        AND (exchange.unit_converted_amount_second is NOT NULL OR
                             exchange.unit_converted_amount is NOT NULL)
                        AND exchange.unit_converted_amount_second != 0 then
                            CEILING((ord2.ord2) / exchange.unit_converted_amount) *
                            exchange.unit_converted_amount_second
                    when exchange.is_exchange = ''2''
                        AND ord2.ord2 <> ''0'' and ord2.ord2 is not null
                        AND exchange.unit_converted_amount_second is NOT NULL then
                        exchange.unit_converted_amount_second
                    ELSE 0 END
         , 0) as count
     from exchange,
         ord2)
   ) t1
 group by treat_date
 order by treat_date asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-07-31 18:29:49', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-11043, 'WITH exchange AS ( SELECT unit_converted_amount, unit_converted_amount_second, is_exchange FROM mst_medicine WHERE medicine_cd = @id AND is_del = ''0'' AND facility_cd = @facilityCd
),
ord1 AS (SELECT
             treat_date,
             COUNT(*) as ord1
         FROM
             ord_main
         WHERE
             to_number(rst_cond_info -> ''25'' ->> ''value'', ''9999999999999999999'' ) = @id
             AND treat_date BETWEEN @dateFrom AND @dateTo
             AND is_del = ''0''
             AND facility_cd = @facilityCd
             AND pat_id is not null
         group by treat_date
),
ord2 AS (SELECT
             treat_date,
             SUM(to_number( mediInfo ->> ''amount'', ''9999999999999999999'')) as ord2
         FROM
             ord_main
             CROSS JOIN LATERAL json_array_elements ( rst_medi_info :: json ) mediInfo
         WHERE
             to_number(mediInfo ->> ''cd'', ''9999999999999999999'' ) = @id
             AND treat_date BETWEEN @dateFrom AND @dateTo
             AND is_del = ''0''
             AND facility_cd = @facilityCd
             AND pat_id is not null
         group by treat_date
),
ord3 AS (SELECT
             treat_date,
             SUM(to_number( mediInfo ->> ''amount'', ''9999999999999999999'')) as ord3
         FROM
             ord_main
             CROSS JOIN LATERAL json_array_elements ( rst_treatment_info :: json ) mediInfo
         WHERE
             to_number(mediInfo ->> ''treat_medicine_cd'', ''9999999999999999999'' ) = @id
             AND treat_date BETWEEN @dateFrom AND @dateTo
             AND is_del = ''0''
             AND facility_cd = @facilityCd
             AND pat_id is not null
         group by treat_date
)

 select
   treat_date, sum(count) as count
 from
   ((SELECT
         ord1.treat_date,
         COALESCE(case
                    when exchange.is_exchange = ''0''
                        AND (exchange.unit_converted_amount_second is NOT NULL OR
                             exchange.unit_converted_amount is NOT NULL)
                        AND exchange.unit_converted_amount_second != 0 then
                        round(((ord1.ord1) / exchange.unit_converted_amount) *
                              exchange.unit_converted_amount_second, 1)
                    when exchange.is_exchange = ''1''
                        AND (exchange.unit_converted_amount_second is NOT NULL OR
                             exchange.unit_converted_amount is NOT NULL)
                        AND exchange.unit_converted_amount_second != 0 then
                            CEILING((ord1.ord1) / exchange.unit_converted_amount) *
                            exchange.unit_converted_amount_second
                    when exchange.is_exchange = ''2''
                        and ord1.ord1 <> ''0'' and ord1.ord1 is not null
                        AND exchange.unit_converted_amount_second is NOT NULL then
                        exchange.unit_converted_amount_second
                    ELSE 0 END
         , 0) as count
     from exchange,
         ord1)
     UNION ALL
    (SELECT
         ord2.treat_date,
         COALESCE(case
                    when exchange.is_exchange = ''0''
                        AND (exchange.unit_converted_amount_second is NOT NULL OR
                             exchange.unit_converted_amount is NOT NULL)
                        AND exchange.unit_converted_amount_second != 0 then
                        round(((ord2.ord2) / exchange.unit_converted_amount) *
                              exchange.unit_converted_amount_second, 1)
                    when exchange.is_exchange = ''1''
                        AND (exchange.unit_converted_amount_second is NOT NULL OR
                             exchange.unit_converted_amount is NOT NULL)
                        AND exchange.unit_converted_amount_second != 0 then
                            CEILING((ord2.ord2) / exchange.unit_converted_amount) *
                            exchange.unit_converted_amount_second
                    when exchange.is_exchange = ''2''
                        and ord2.ord2 <> ''0'' and ord2.ord2 is not null
                        AND exchange.unit_converted_amount_second is NOT NULL then
                        exchange.unit_converted_amount_second
                    ELSE 0 END
         , 0) as count
     from exchange,
         ord2)
     UNION ALL
    (SELECT
         ord3.treat_date,
         COALESCE(case
                    when exchange.is_exchange = ''0''
                        AND (exchange.unit_converted_amount_second is NOT NULL OR
                             exchange.unit_converted_amount is NOT NULL)
                        AND exchange.unit_converted_amount_second != 0 then
                        round(((ord3.ord3) / exchange.unit_converted_amount) *
                              exchange.unit_converted_amount_second, 1)
                    when exchange.is_exchange = ''1''
                        AND (exchange.unit_converted_amount_second is NOT NULL OR
                             exchange.unit_converted_amount is NOT NULL)
                        AND exchange.unit_converted_amount_second != 0 then
                            CEILING((ord3.ord3) / exchange.unit_converted_amount) *
                            exchange.unit_converted_amount_second
                    when exchange.is_exchange = ''2''
                        and ord3.ord3 <> ''0'' and ord3.ord3 is not null
                        AND exchange.unit_converted_amount_second is NOT NULL then
                        exchange.unit_converted_amount_second
                    ELSE 0 END
         , 0) as count
     from exchange,
         ord3)
   ) t1
 group by treat_date
 order by treat_date asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-07-31 18:29:49', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-11042, 'WITH A AS (
    SELECT
        pat_id,
        MAX ( inOutInfo ->> ''ctl_no'' ) AS ctl_no
    FROM
        pat_unique
        CROSS JOIN LATERAL json_array_elements ( in_out_visit_history_info :: json ) inOutInfo
    WHERE
        is_del = ''0''
        AND facility_cd = @facilityCd
    GROUP BY
        pat_id
    ),
    B AS (
    SELECT
        pat_id,
        inOutInfo ->> ''ctl_no'' AS ctl_no,
        inOutInfo ->> ''in_out'' AS in_out
    FROM
        pat_unique
        CROSS JOIN LATERAL json_array_elements ( in_out_visit_history_info :: json ) inOutInfo
    WHERE
        is_del = ''0''
        AND facility_cd = @facilityCd
    ),
    in_out AS (
    SELECT
        B.pat_id,
        B.in_out

    FROM
        A INNER JOIN B ON A.pat_id = B.pat_id
        AND A.ctl_no = B.ctl_no
    )
SELECT
    treat_date,
    COUNT( * ) AS COUNT
FROM
    ord_main
    LEFT JOIN in_out ON ord_main.pat_id = in_out.pat_id
WHERE
    ord_main.treat_date BETWEEN @dateFrom AND @dateTo
    AND (in_out.in_out <> ''1'' or in_out.in_out is null)
    AND ord_main.facility_cd = @facilityCd
    AND ord_main.is_del = ''0''
    AND ord_main.rst_dialysis_state = ''0'' and ord_main.pat_id is not null
group by treat_date
order by treat_date asc;', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-05-26 16:49:16', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-11041, 'WITH A AS (
    SELECT
        pat_id,
        MAX ( inOutInfo ->> ''ctl_no'' ) AS ctl_no
    FROM
        pat_unique
        CROSS JOIN LATERAL json_array_elements ( in_out_visit_history_info :: json ) inOutInfo
    WHERE
        is_del = ''0''
        AND facility_cd = @facilityCd
    GROUP BY
        pat_id
    ),
    B AS (
    SELECT
        pat_id,
        inOutInfo ->> ''ctl_no'' AS ctl_no,
        inOutInfo ->> ''in_out'' AS in_out
    FROM
        pat_unique
        CROSS JOIN LATERAL json_array_elements ( in_out_visit_history_info :: json ) inOutInfo
    WHERE
        is_del = ''0''
        AND facility_cd = @facilityCd
    ),
    in_out AS (
    SELECT
        B.pat_id,
        B.in_out

    FROM
        A INNER JOIN B ON A.pat_id = B.pat_id
        AND A.ctl_no = B.ctl_no
    )
SELECT
    treat_date,
    COUNT( * ) AS COUNT
FROM
    ord_main
    LEFT JOIN in_out ON ord_main.pat_id = in_out.pat_id
WHERE
    ord_main.treat_date BETWEEN @dateFrom AND @dateTo
    AND in_out.in_out = ''1''
    AND ord_main.facility_cd = @facilityCd
    AND ord_main.is_del = ''0''
    AND ord_main.rst_dialysis_state = ''0'' and ord_main.pat_id is not null
group by treat_date
order by treat_date asc;', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-05-26 16:49:16', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-11039, 'SELECT treat_date, COUNT( * ) AS count
FROM
    ord_main,
    jsonb_to_recordset ( addition_info ) AS j1 ( cd TEXT, reg_date TEXT, is_enable TEXT )
WHERE
    treat_date BETWEEN @dateFrom AND @dateTo
 AND is_del = ''0''
 AND facility_cd = @facilityCd
 AND j1.cd = @itemId::text
 AND pat_id is not null
group by treat_date
order by treat_date asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2021-04-25 16:40:02', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-11038, 'SELECT e.event_start_date as treat_date, count(DISTINCT e.pat_id) AS count
FROM pat_event AS e,
mst_pat_event_sub_category AS s
WHERE date(e.event_start_date) >= @dateFrom
AND date(e.event_start_date) <= @dateTo
AND e.is_del = ''0''
AND s.sub_category_cd = e.sub_category_cd
AND s.is_del = ''0''
AND e.facility_cd = @facilityCd
AND s.facility_cd = @facilityCd
AND s.sub_category_cd = @id
group by treat_date
order by treat_date asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-07-31 18:29:49.294', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-11037, 'SELECT
  to_char(reg_rad_date, ''YYYYMMDD'') as treat_date,
  count(DISTINCT pat_id) AS count
FROM pat_rad_main
WHERE date(reg_rad_date) >= @dateFrom
  AND date(reg_rad_date) <= @dateTo
  AND is_del = ''0''
  AND facility_cd = @facilityCd
 group by treat_date
 order by treat_date asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-07-31 18:29:49.294', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-11036, 'SELECT
  to_char(reg_exam_date, ''YYYYMMDD'') as treat_date,
  count(DISTINCT pat_id) AS count
FROM pat_exam_main
WHERE date(reg_exam_date) >= @dateFrom
  AND date(reg_exam_date) <= @dateTo
  AND is_del = ''0''
  AND facility_cd = @facilityCd
 group by treat_date
 order by treat_date asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-07-31 18:29:49.294', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-11035, 'SELECT
  elem ->> ''period_start'' as treat_date,
  count(DISTINCT pat_id) AS count
FROM pat_unique,
     jsonb_array_elements(in_out_visit_history_info) AS elem
WHERE elem ->> ''move_in_out'' = ''11''
  AND elem ->> ''period_start'' >= @dateFrom
  AND elem ->> ''period_start'' <= @dateTo
  AND elem ->> ''facility_cd'' = @facilityCd
  AND is_del = ''0''
 group by treat_date
 order by treat_date asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-07-31 18:29:49.294', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-11034, 'SELECT
  elem ->> ''period_start'' as treat_date,
  count(DISTINCT pat_id) AS count
FROM pat_unique,
     jsonb_array_elements(in_out_visit_history_info) AS elem
WHERE elem ->> ''move_in_out'' = ''10''
  AND elem ->> ''period_start'' >= @dateFrom
  AND elem ->> ''period_start'' <= @dateTo
  AND elem ->> ''facility_cd'' = @facilityCd
  AND is_del = ''0''
 group by treat_date
 order by treat_date asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-07-31 18:29:49.294', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-11033, 'SELECT
  elem ->> ''period_end'' as treat_date,
  count(DISTINCT pat_id) AS count
FROM pat_unique,
     jsonb_array_elements(in_out_visit_history_info) AS elem
WHERE elem ->> ''move_in_out'' = ''9''
  AND elem ->> ''period_end'' >= @dateFrom
  AND elem ->> ''period_end'' <= @dateTo
  AND elem ->> ''facility_cd'' = @facilityCd
  AND is_del = ''0''
 group by treat_date
 order by treat_date asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-07-31 18:29:49.294', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-11032, 'SELECT
  elem ->> ''period_start'' as treat_date,
  count(DISTINCT pat_id) AS count
FROM pat_unique,
     jsonb_array_elements(in_out_visit_history_info) AS elem
WHERE elem ->> ''move_in_out'' = ''9''
  AND elem ->> ''period_start'' >= @dateFrom
  AND elem ->> ''period_start'' <= @dateTo
  AND elem ->> ''facility_cd'' = @facilityCd
  AND is_del = ''0''
 group by treat_date
 order by treat_date asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-07-31 18:29:49.294', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-11031, 'SELECT
  elem ->> ''period_start'' as treat_date,
  count(DISTINCT pat_id) AS count
FROM pat_unique,
     jsonb_array_elements(in_out_visit_history_info) AS elem
WHERE elem ->> ''move_in_out'' = ''8''
  AND elem ->> ''period_start'' >= @dateFrom
  AND elem ->> ''period_start'' <= @dateTo
  AND elem ->> ''facility_cd'' = @facilityCd
  AND is_del = ''0''
 group by treat_date
 order by treat_date asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-07-31 18:29:49.294', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-11030, 'SELECT
  elem ->> ''period_start'' as treat_date,
  count(DISTINCT pat_id) AS count
FROM pat_unique,
     jsonb_array_elements(in_out_visit_history_info) AS elem
WHERE elem ->> ''move_in_out'' = ''7''
  AND elem ->> ''period_start'' >= @dateFrom
  AND elem ->> ''period_start'' <= @dateTo
  AND elem ->> ''facility_cd'' = @facilityCd
  AND is_del = ''0''
 group by treat_date
 order by treat_date asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-07-31 18:29:49.294', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-11029, 'SELECT
  elem ->> ''period_start'' as treat_date,
  count(DISTINCT pat_id) AS count
FROM pat_unique,
     jsonb_array_elements(in_out_visit_history_info) AS elem
WHERE elem ->> ''move_in_out'' = ''6''
  AND elem ->> ''period_start'' >= @dateFrom
  AND elem ->> ''period_start'' <= @dateTo
  AND elem ->> ''facility_cd'' = @facilityCd
  AND is_del = ''0''
 group by treat_date
 order by treat_date asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-07-31 18:29:49.294', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-11028, 'SELECT
  elem ->> ''period_start'' as treat_date,
  count(DISTINCT pat_id) AS count
FROM pat_unique,
     jsonb_array_elements(in_out_visit_history_info) AS elem
WHERE elem ->> ''move_in_out'' = ''5''
  AND elem ->> ''period_start'' >= @dateFrom
  AND elem ->> ''period_start'' <= @dateTo
  AND elem ->> ''facility_cd'' = @facilityCd
  AND is_del = ''0''
 group by treat_date
 order by treat_date asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-07-31 18:29:49.294', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-11027, 'SELECT
  elem ->> ''period_start'' as treat_date,
  count(DISTINCT pat_id) AS count
FROM pat_unique,
     jsonb_array_elements(in_out_visit_history_info) AS elem
WHERE elem ->> ''move_in_out'' = ''4''
  AND elem ->> ''period_start'' >= @dateFrom
  AND elem ->> ''period_start'' <= @dateTo
  AND elem ->> ''facility_cd'' = @facilityCd
  AND is_del = ''0''
 group by treat_date
 order by treat_date asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-07-31 18:29:49.294', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-11026, 'SELECT
  elem ->> ''period_start'' as treat_date,
  count(DISTINCT pat_id) AS count
FROM pat_unique,
     jsonb_array_elements(in_out_visit_history_info) AS elem
WHERE elem ->> ''move_in_out'' = ''3''
  AND elem ->> ''period_start'' >= @dateFrom
  AND elem ->> ''period_start'' <= @dateTo
  AND elem ->> ''facility_cd'' = @facilityCd
  AND is_del = ''0''
 group by treat_date
 order by treat_date asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-07-31 18:29:49.294', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-11025, 'SELECT
  elem ->> ''period_start'' as treat_date,
  count(DISTINCT pat_id) AS count
FROM pat_unique,
     jsonb_array_elements(in_out_visit_history_info) AS elem
WHERE elem ->> ''move_in_out'' = ''2''
  AND elem ->> ''period_start'' >= @dateFrom
  AND elem ->> ''period_start'' <= @dateTo
  AND elem ->> ''facility_cd'' = @facilityCd
  AND is_del = ''0''
 group by treat_date
 order by treat_date asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-07-31 18:29:49.294', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-11024, 'SELECT
  elem ->> ''period_start'' as treat_date,
  count(DISTINCT pat_id) AS count
FROM pat_unique,
     jsonb_array_elements(in_out_visit_history_info) AS elem
WHERE elem ->> ''move_in_out'' = ''1''
  AND elem ->> ''period_start'' >= @dateFrom
  AND elem ->> ''period_start'' <= @dateTo
  AND elem ->> ''facility_cd'' = @facilityCd
  AND is_del = ''0''
 group by treat_date
 order by treat_date asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-07-31 18:29:49.294', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-11023, 'select treat_date, count(*) as count from ord_main
where rst_dialysis_state = ''6'' AND treat_date between @dateFrom and @dateTo and facility_cd = @facilityCd and rst_kur_cd = @id AND is_del = ''0'' and pat_id is not null group by treat_date order by treat_date asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-07-31 18:29:49', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-11022, 'select treat_date, count(*) as count from ord_main
where rst_dialysis_state = ''6'' AND treat_date between @dateFrom and @dateTo and facility_cd = @facilityCd and rst_treatment_cd = @id AND is_del = ''0'' and pat_id is not null group by treat_date order by treat_date asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-07-31 18:29:49', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-11021, 'select ordMain.treat_date as treat_date, count(*) as count from ord_main as ordMain left join mst_treatment as mstTreatment on ordMain.rst_treatment_cd = mstTreatment.treatment_cd
where ordMain.rst_dialysis_state = ''6'' AND mstTreatment.device_mode = ''9'' and ordMain.treat_date between @dateFrom and @dateTo and ordMain.facility_cd = @facilityCd AND ordMain.is_del = ''0'' and ordMain.pat_id is not null
group by ordMain.treat_date
order by ordMain.treat_date asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-07-31 18:29:49', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-11020, 'select ordMain.treat_date as treat_date, count(*) as count from ord_main as ordMain left join mst_treatment as mstTreatment on ordMain.rst_treatment_cd = mstTreatment.treatment_cd
where ordMain.rst_dialysis_state = ''6'' AND mstTreatment.device_mode != ''9'' and ordMain.treat_date between @dateFrom and @dateTo and ordMain.facility_cd = @facilityCd AND ordMain.is_del = ''0'' and ordMain.pat_id is not null
group by ordMain.treat_date
order by ordMain.treat_date asc ', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-07-31 18:29:49', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-11019, 'select treat_date, count(*) as count from ord_main where rst_dialysis_state = ''6'' AND treat_date between @dateFrom and @dateTo and (rst_in_out_class <> 1 or rst_in_out_class is null) and facility_cd = @facilityCd AND is_del = ''0'' and pat_id is not null
group by treat_date
order by treat_date asc ', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-07-31 18:29:49', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-11018, 'select treat_date, count(*) as count from ord_main where rst_dialysis_state = ''6'' AND treat_date between @dateFrom and @dateTo and rst_in_out_class = 1 and facility_cd = @facilityCd AND is_del = ''0'' and pat_id is not null
group by treat_date
order by treat_date asc ', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-07-31 18:29:49', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-11017, 'select treat_date, count(*) as count from ord_main where treat_date between @dateFrom and @dateTo and rst_dialysis_state = ''6'' and facility_cd = @facilityCd AND is_del = ''0'' and pat_id is not null
group by treat_date
order by treat_date asc ', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-07-31 18:29:49', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-11016, 'select treat_date, count(*) as count from ord_main
where treat_date between @dateFrom and @dateTo and facility_cd = @facilityCd and ind_kur_cd = @id AND is_del = ''0'' and rst_dialysis_state = ''0'' and pat_id is not null group by treat_date order by treat_date asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-07-31 18:29:49', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-11015, 'select treat_date, count(*) as count from ord_main
where treat_date between @dateFrom and @dateTo and facility_cd = @facilityCd and ind_treatment_cd = @id AND is_del = ''0'' and rst_dialysis_state = ''0'' and pat_id is not null group by treat_date order by treat_date asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-07-31 18:29:49', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-11014, 'select ordMain.treat_date as treat_date, count(*) as count from ord_main as ordMain left join mst_treatment as mstTreatment on ordMain.ind_treatment_cd = mstTreatment.treatment_cd
where mstTreatment.device_mode = ''9'' and ordMain.treat_date between @dateFrom and @dateTo and ordMain.facility_cd = @facilityCd AND ordMain.is_del = ''0''
 AND ordMain.rst_dialysis_state = ''0'' and ordMain.pat_id is not null
 group by ordMain.treat_date
 order by ordMain.treat_date asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-07-31 18:29:49', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-11013, 'SELECT ordMain.treat_date as treat_date, count(*) as count
from
    ord_main as ordMain
    left join mst_treatment as mstTreatment on ordMain.ind_treatment_cd = mstTreatment.treatment_cd
where
    mstTreatment.device_mode != ''9''
 AND ordMain.treat_date between @dateFrom and @dateTo
 AND ordMain.facility_cd = @facilityCd
 AND ordMain.is_del = ''0''
 AND ordMain.rst_dialysis_state = ''0''
 AND ordMain.pat_id is not null
group by ordMain.treat_date
order by ordMain.treat_date asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-07-31 18:29:49', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-11012, 'select treat_date, count(*) as count from ord_main where treat_date between @dateFrom and @dateTo and facility_cd = @facilityCd AND is_del = ''0'' and rst_dialysis_state = ''0'' and pat_id is not null
group by treat_date
order by treat_date asc ', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-07-31 18:29:49', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-11011, ' select
   treat_date, sum(count) as count
 from
   ((select treat_date, count(*) as count from ord_main where to_number(rst_cond_info->''5''->>''value'',''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo and is_del = ''0'' and facility_cd = @facilityCd and pat_id is not null group by treat_date)
     UNION ALL
    (select treat_date, count(*) as count from ord_main
      cross join lateral
        json_array_elements (rst_cond_info::json) equipInfo
        where to_number(equipInfo->>''cd'',''9999999999999999999.9999999999999999999'') = @id and to_number(equipInfo->>''equip_type'',''9'') = 1 and treat_date between @dateFrom and @dateTo and is_del = ''0'' and facility_cd = @facilityCd and pat_id is not null group by treat_date)
   ) t1
 group by treat_date
 order by treat_date asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-07-31 18:29:49', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-11010, ' select
   treat_date, sum(count) as count
 from
   ((select treat_date, count(*) from ord_main where  to_number(rst_cond_info->''5''->>''value'',''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by treat_date)
     UNION ALL
    (select treat_date, count(*) from ord_main where  to_number(rst_cond_info->''6''->>''value'',''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by treat_date)
     UNION ALL
    (select treat_date, count(*) from ord_main where  to_number(rst_cond_info->''7''->>''value'',''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by treat_date)
     UNION ALL
    (select treat_date, count(*) from ord_main where  to_number(rst_cond_info->''8''->>''value'',''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by treat_date)
     UNION ALL
    (select treat_date, count(*) from ord_main where  to_number(rst_cond_info->''9''->>''value'',''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by treat_date)
     UNION ALL
    (select treat_date, count(*) from ord_main where  to_number(rst_cond_info->''10''->>''value'',''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by treat_date)
     UNION ALL
    (select treat_date, count(*) from ord_main where  to_number(rst_cond_info->''11''->>''value'',''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by treat_date)
     UNION ALL
    (select treat_date, count(*) from ord_main where  to_number(rst_cond_info->''12''->>''value'',''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by treat_date)
     UNION ALL
    (select treat_date, count(*) from ord_main where  to_number(rst_cond_info->''13''->>''value'',''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by treat_date)
     UNION ALL
    (select treat_date,
            case
              when sum(to_number(equipInfo->>''amount'',''9999999999999999999.9999999999999999999'')) is not null then sum(to_number(equipInfo->>''amount'',''9999999999999999999.9999999999999999999''))
              else 0
            end
     from ord_main
        cross join lateral
          json_array_elements (rst_equip_info::json) equipInfo
          where to_number(equipInfo->>''cd'',''9999999999999999999.9999999999999999999'')  = @id and to_number(equipInfo->>''equip_type'',''9'') = 0 and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by treat_date)
   ) t1
 group by treat_date
 order by treat_date asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-07-31 18:29:49', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-11009, ' select
   treat_date, sum(count) as count
 from
   ((select treat_date, count(*) as count from ord_main where  to_number(rst_cond_info->''25''->>''value'', ''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo and is_del = ''0'' and facility_cd = @facilityCd and pat_id is not null group by treat_date)
     UNION ALL
    (select treat_date,
            case
              when sum(to_number( mediInfo ->> ''amount'', ''9999999999999999999.9999999999999999999'' )) is not null then sum(to_number( mediInfo ->> ''amount'', ''9999999999999999999.9999999999999999999'' ))
              else 0
            end as count from ord_main
      cross join lateral
        json_array_elements (rst_medi_info::json) mediInfo
        where to_number(mediInfo->>''cd'', ''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by treat_date)
     UNION ALL
    (select treat_date,
            case
              when sum(to_number( mediInfo ->> ''amount'', ''9999999999999999999.9999999999999999999'' )) is not null then sum(to_number( mediInfo ->> ''amount'', ''9999999999999999999.9999999999999999999'' ))
              else 0
            end as count from ord_main
      cross join lateral
        json_array_elements (rst_treatment_info::json) mediInfo
        where to_number(mediInfo->>''treat_medicine_cd'', ''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by treat_date)
   ) t1
 group by treat_date
 order by treat_date asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-07-31 18:29:49', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-11008, 'select
  COALESCE(
(select count(*) from ord_main where  to_number(rst_cond_info->''25''->>''value'',''9999999999999999999.9999999999999999999'') =  @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null) +
(select count(*) from ord_main
    cross join lateral
      json_array_elements (rst_medi_info::json) mediInfo
      where to_number(mediInfo->>''cd'',''9999999999999999999'')  =  @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null) +
(select count(*) from ord_main
    cross join lateral
      json_array_elements (rst_treatment_info::json) mediInfo
      where to_number(mediInfo->>''treat_medicine_cd'',''9999999999999999999'')  =  @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null)
, 0)
as count', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-07-31 18:29:49', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-11007, ' select
   treat_date, sum(count) as count
from
    ((select treat_date, count(*) as count from ord_main where to_number(ind_cond_info->''5''->>''value'', ''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo and is_del = ''0'' and facility_cd = @facilityCd and pat_id is not null group by treat_date)
    UNION ALL
    (select treat_date, count(*) as count from ord_main
    cross join lateral
    json_array_elements (ind_equip_info::json) equipInfo
    where to_number(equipInfo->>''cd'', ''9999999999999999999'') = @id and to_number(equipInfo->>''equip_type'', ''9'') = 1 and treat_date between @dateFrom and @dateTo and is_del = ''0'' and facility_cd = @facilityCd and pat_id is not null group by treat_date)
    ) t1
group by treat_date
order by treat_date asc ', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-07-31 18:29:49', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-11005, ' select
   treat_date, sum(count) as count
from
    ((select treat_date, count(*) from ord_main where to_number(ind_cond_info->''5''->>''value'', ''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by treat_date)
    UNION ALL
    (select treat_date, count(*) from ord_main where to_number(ind_cond_info->''6''->>''value'', ''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by treat_date)
    UNION ALL
    (select treat_date, count(*) from ord_main where to_number(ind_cond_info->''7''->>''value'', ''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by treat_date)
    UNION ALL
    (select treat_date, count(*) from ord_main where to_number(ind_cond_info->''8''->>''value'', ''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by treat_date)
    UNION ALL
    (select treat_date, count(*) from ord_main where to_number(ind_cond_info->''9''->>''value'', ''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by treat_date)
    UNION ALL
    (select treat_date, count(*) from ord_main where to_number(ind_cond_info->''10''->>''value'', ''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by treat_date)
    UNION ALL
    (select treat_date, count(*) from ord_main where to_number(ind_cond_info->''11''->>''value'', ''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by treat_date)
    UNION ALL
    (select treat_date, count(*) from ord_main where to_number(ind_cond_info->''12''->>''value'', ''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by treat_date)
    UNION ALL
    (select treat_date, count(*) from ord_main where to_number(ind_cond_info->''13''->>''value'', ''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by treat_date)
    UNION ALL
    (select treat_date,
    case
    when sum (to_number(equipInfo->>''amount'', ''9999999999999999999.9999999999999999999'')) is not null then sum (to_number(equipInfo->>''amount'', ''9999999999999999999.9999999999999999999''))
    else 0
    end
    from ord_main
    cross join lateral
    json_array_elements (ind_equip_info::json) equipInfo
    where to_number(equipInfo->>''cd'', ''9999999999999999999'') = @id and to_number(equipInfo->>''equip_type'', ''9'') = 0 and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by treat_date)
    ) t1
group by treat_date
order by treat_date asc ', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-07-31 18:29:49', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-11003, ' select
   treat_date, sum(count) as count
from
    ((select treat_date, count(*) as count from ord_main where to_number(ind_cond_info->''25''->>''value'', ''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo and is_del = ''0'' and facility_cd = @facilityCd and pat_id is not null group by treat_date)
    UNION ALL
    (select treat_date,
    case
    when sum (to_number( mediInfo ->> ''amount'', ''9999999999999999999.9999999999999999999'' )) is not null then sum (to_number( mediInfo ->> ''amount'', ''9999999999999999999.9999999999999999999'' ))
    else 0
    end as count from ord_main
    cross join lateral
    json_array_elements (ind_medi_info::json) mediInfo
    where to_number(mediInfo->>''cd'', ''9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by treat_date)
    ) t1
group by treat_date
order by treat_date asc ', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-07-31 18:29:49', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-11001, 'select
  COALESCE(
(select count(*) from ord_main where  to_number(ind_cond_info->''25''->>''value'',''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null) +
(select count(*) from ord_main
    cross join lateral
      json_array_elements (ind_medi_info::json) mediInfo
      where to_number(mediInfo->>''cd'',''9999999999999999999'')  = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null)
, 0) as count', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-07-31 18:29:49', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-416, 'select
	''バスキュラーアクセス'' as detail_id,
	ord.rst_cond_info->''2''->>''value_name_1'' as e01
from
	ord_main as ord
where
	ord.ord_no = @ordNo', 2, '[{}]', '1', '{"applications": [4]}', NULL, 'Medicom)経過情報（バスキュラーアクセス）', '2020-05-27 10:00:13.163', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-415, 'select
	''ブラッドアクセス'' as detail_id,
	ord.rst_cond_info->''2''->>''value_name_1'' as e01
from
	ord_main as ord
where
	ord.ord_no = @ordNo', 2, '[{}]', '1', '{"applications": [4]}', NULL, 'Medicom)経過情報（ブラッドアクセス）', '2020-05-27 10:00:13.163', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-414, 'select
	''ダイアライザ'' as detail_id,
	ord.rst_cond_info->''5''->>''value_name_1'' as e01
from
	ord_main as ord
where
	ord.ord_no = @ordNo', 2, '[{}]', '1', '{"applications": [4]}', NULL, 'Medicom)経過情報（ダイアライザ）', '2020-05-27 10:00:13.163', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-413, 'select
	''担当者'' as detail_id,
	case COALESCE(ord.rst_charge_user_info->>''user_last_name_1'',''NULL1'') when ''NULL1'' then case COALESCE(ord.rst_charge_user_info->>''user_last_name_2'',''NULL2'') when ''NULL2'' then ''担当医師'' else concat(ord.rst_charge_user_info->>''user_last_name_2'' , ord.rst_charge_user_info->>''user_first_name_2'') end else concat(ord.rst_charge_user_info->>''user_last_name_1'' , ord.rst_charge_user_info->>''user_first_name_1'') end as e01
from
	ord_main as ord
where
	ord.ord_no = @ordNo', 2, '[{}]', '1', '{"applications": [4]}', NULL, 'Medicom)経過情報（担当者）', '2020-05-27 10:00:13.163', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-412, 'select
	''回収者'' as detail_id,
	case COALESCE(ord.rst_return_user_info->>''user_last_name_1'',''NULL1'') when ''NULL1'' then case COALESCE(ord.rst_return_user_info->>''user_last_name_2'',''NULL2'') when ''NULL2'' then ''担当医師'' else concat(ord.rst_return_user_info->>''user_last_name_2'' , ord.rst_return_user_info->>''user_first_name_2'') end else concat(ord.rst_return_user_info->>''user_last_name_1'' , ord.rst_return_user_info->>''user_first_name_1'') end as e01
from
	ord_main as ord
where
	ord.ord_no = @ordNo', 2, '[{}]', '1', '{"applications": [4]}', NULL, 'Medicom)経過情報（回収者）', '2020-05-27 10:00:13.163', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-411, 'select
	''穿刺者'' as detail_id,
	case COALESCE(ord.rst_puncture_user_info->>''user_last_name_1'',''NULL1'') when ''NULL1'' then case COALESCE(ord.rst_puncture_user_info->>''user_last_name_2'',''NULL2'') when ''NULL2'' then ''担当医師'' else concat(ord.rst_puncture_user_info->>''user_last_name_2'' , ord.rst_puncture_user_info->>''user_first_name_2'') end else concat(ord.rst_puncture_user_info->>''user_last_name_1'' , ord.rst_puncture_user_info->>''user_first_name_1'') end as e01
from
	ord_main as ord
where
	ord.ord_no = @ordNo', 2, '[{}]', '1', '{"applications": [4]}', NULL, 'Medicom)経過情報（穿刺者）', '2020-05-27 10:00:13.163', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-409, 'select
	''血流量'' as detail_id,
	ord.rst_cond_info->''14''->>''value'' as e01
from
	ord_main ord
where
	ord.ord_no = @ordNo', 2, '[{}]', '1', '{"applications": [4]}', NULL, 'Medicom)経過情報（血流量）', '2020-05-27 10:00:13.163', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-408, 'select
	''透析回数'' as detail_id,
	case when ord.rst_dialysis_cnt is null then ord.rst_purification_cnt else ord.rst_dialysis_cnt end as e01
from
	ord_main ord
where
	ord.ord_no = @ordNo', 2, '[{}]', '1', '{"applications": [4]}', NULL, 'Medicom)経過情報（透析回数）', '2020-05-27 10:00:13', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-407, 'select
	''実績時間'' as detail_id,
	to_char(ord.rst_end_date-ord.rst_start_date,''HH24時間MI分'') as e01
from
	ord_main ord
where
	ord.ord_no = @ordNo', 2, '[{}]', '1', '{"applications": [4]}', NULL, 'Medicom)経過情報（実績時間）', '2020-05-27 10:00:13.163', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-406, 'select
	''透析時間'' as detail_id,
	to_char(ord.rst_end_date-ord.rst_start_date,''HH24時間MI分'') as e01
from
	ord_main ord
where
	ord.ord_no = @ordNo', 2, '[{}]', '1', '{"applications": [4]}', NULL, 'Medicom)経過情報（透析時間）', '2020-05-27 10:00:13.163', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-405, 'select
	''終了時刻'' as detail_id,
	to_char(ord.rst_end_date,''YYYY/MM/DD HH24:MI:SS'') as e01
from
	ord_main ord
where
	ord.ord_no = @ordNo', 2, '[{}]', '1', '{"applications": [4]}', NULL, 'Medicom)経過情報（終了時刻）', '2020-05-27 10:00:13.163', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-404, 'select
	''開始時刻'' as detail_id,
	to_char(ord.rst_start_date,''YYYY/MM/DD HH24:MI:SS'') as e01
from
	ord_main ord
where
	ord.ord_no = @ordNo', 2, '[{}]', '1', '{"applications": [4]}', NULL, 'Medicom)経過情報（開始時刻）', '2020-05-27 10:00:13.163', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-403, 'select
	''予定時間'' as detail_id,
	RIGHT(''00''||TRUNC(TO_NUMBER(ord.ind_cond_info->''1''->>''value'',''999999'')/60,0),2)||''時間''||RIGHT(''00''||MOD(TO_NUMBER(ord.ind_cond_info->''1''->>''value'',''999999''),60),2)||''分'' as e01
from
	ord_main ord
where
	ord.ord_no = @ordNo', 2, '[{}]', '1', '{"applications": [4]}', NULL, 'Medicom)経過情報（予定時間）', '2020-05-27 10:00:13.163', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-402, 'select
	''透析日'' as detail_id,
	to_char(ord.rst_start_date,''YYYY/MM/DD'') as e01
from
	ord_main ord
where
	ord.ord_no = @ordNo', 2, '[{}]', '1', '{"applications": [4]}', NULL, 'Medicom)経過情報（透析日）', '2020-05-27 10:00:13.163', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-401, 'select
	''血液浄化法'' as detail_id,
	ord.rst_treatment_name as e01
from
	ord_main ord
where
	ord.ord_no = @ordNo', 2, '[{}]', '1', '{"applications": [4]}', NULL, 'Medicom)経過情報（血液浄化法）', '2020-05-27 10:00:13.163', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-304, 'select
 ''透析条件'' as detail_id,
 split_part(cond_arr.cond_row,''-@-'',1) as e01,
 split_part(cond_arr.cond_row,''-@-'',2) as e02,
 COALESCE(nullif(split_part(cond_arr.cond_row,''-@-'',3),''''),''_'') as e03,
 COALESCE(nullif(split_part(cond_arr.cond_row,''-@-'',4),''''),''_'') as e04,
 COALESCE(nullif(split_part(cond_arr.cond_row,''-@-'',5),''''),''_'') as e05
from
(
 select
 regexp_split_to_table(array_to_string(array[
	concat(''002-@-透析時間-@-'',ord.rst_cond_info->''1''->>''value'' ,''-@--@-分'') ,
	concat(''003-@-VA-@-'',trim(mva.in_hospital_cd_1),''-@-'',ord.rst_cond_info->''2''->>''value_name_1'',''-@-'') ,
	concat(''004-@-DW-@-'',ord.rst_dw,''-@-'',''-@-'',''kg'') ,
	concat(''005-@-目標体重-@-'',ord.rst_cond_info->''3''->>''value'',''-@-'',''-@-'',''kg'') ,
	concat(''006-@-治療方法-@-'',mtt.in_hospital_cd_a1,''-@-'',ord.rst_treatment_name,''-@-'') ,
	concat(''007-@-除水量制限-@-'',to_char(to_number(ord.rst_cond_info->''4''->>''value'',''99.99''),''90.99''),''-@-'',''-@-'',''L''),
	concat(''008-@-ダイアライザー-@-'',trim(mdr.in_hospital_cd_1),''-@-'',ord.rst_cond_info->''5''->>''value_name_1'',''-@-''),
	concat(''009-@-吸着カラム-@-'',trim(meqad.in_hospital_cd_1),''-@-'',ord.rst_cond_info->''6''->>''value_name_1'',''-@-''),
	concat(''010-@-血流量-@-'',ord.rst_cond_info->''14''->>''value'',''-@-'',''-@-'',''mL/min''),
	concat(''011-@-抗凝固剤-@-'',(case ord.rst_cond_info->''25''->>''medicine_type'' when ''1'' then med25.in_hospital_cd_1 when ''2'' then mmx.in_hospital_cd_1 end) ,''-@-'',ord.rst_cond_info->''25''->>''value_name_1'',''-@-'') ,
	concat(''012-@-抗凝固剤ワンショット量-@-'',ord.rst_cond_info->''26''->>''value'',''-@-'',''-@-'',ord.rst_cond_info->''26''->>''unit''),
	concat(''013-@-抗凝固剤持続速度-@-'',ord.rst_cond_info->''27''->>''value'',''-@-'',''-@-'',ord.rst_cond_info->''27''->>''unit''),
	concat(''014-@-抗凝固剤持続総量-@-'',ord.rst_cond_info->''28''->>''value'',''-@-'',''-@-'',ord.rst_cond_info->''28''->>''unit''),
	concat(''015-@-IP使用選択-@-'',ord.rst_cond_info->''29''->>''value'',''-@-'',(case ord.rst_cond_info->''29''->>''value'' when ''1'' then ''使用する'' when ''0'' then ''使用しない'' else null end) ,''-@-''),
	concat(''016-@-IPワンショット量-@-'',ord.rst_cond_info->''31''->>''value'',''-@-'',''-@-'',''mL'') ,
	concat(''017-@-IP速度-@-'',ord.rst_cond_info->''32''->>''value'',''-@-'',''-@-'',''mL/h''),
	concat(''018-@-透析液-@-'',(case ord.rst_cond_info->''15''->>''medicine_type'' when ''1'' then trim(med15.in_hospital_cd_1) when ''2'' then trim(mmmx.in_hospital_cd_1) end) ,''-@-'',ord.rst_cond_info->''15''->>''value_name_1'',''-@-'') ,
	concat(''019-@-透析液流量-@-'',ord.rst_cond_info->''16''->>''value'',''-@-'',''-@-'',''mL/min'') ,
	concat(''020-@-透析液量-@-'',ord.rst_cond_info->''17''->>''value'',''-@-'',''-@-'',ord.rst_cond_info->''17''->>''unit'') ,
	concat(''021-@-透析液温度-@-'',ord.rst_cond_info->''18''->>''value'',''-@-'',''-@-'',''℃'') ,
	concat(''022-@-補液-@-'', (case ord.rst_cond_info->''19''->>''medicine_type'' when ''1'' then med19.in_hospital_cd_1 when ''2'' then mmmmx.in_hospital_cd_1 end),''-@-'',ord.rst_cond_info->''19''->>''value_name_1'',''-@-'') ,
	concat(''023-@-補液量-@-'',ord.rst_cond_info->''20''->>''value'',''-@-'',''-@-'',''L'') ,
	concat(''024-@-補液選択-@-'',ord.rst_cond_info->''21''->>''value'',''-@-'',(case ord.rst_cond_info->''21''->>''value'' when ''1'' then ''前補液'' when ''0'' then ''後補液'' else null end),''-@-'') ,
	concat(''025-@-補液温度-@-'',ord.rst_cond_info->''23''->>''value'',''-@-'',''-@-'',''℃'') ,
	concat(''029-@-シングルニードル電源-@-'',ord.rst_cond_info->''12''->>''value'',''-@-'',(case ord.rst_cond_info->''12''->>''value'' when ''1'' then ''使用する'' when ''0'' then ''使用しない'' else null end),''-@-'') ,
	concat(''030-@-補液使用数-@-'',ord.rst_cond_info->''22''->>''value'',''-@-'',''-@-'',ord.rst_cond_info->''22''->>''unit'') ,
	concat(''031-@-IPスタート-@-'',ord.rst_cond_info->''30''->>''value'',''-@-'',(case ord.rst_cond_info->''30''->>''value'' when ''0'' then ''手動'' when ''1'' then ''自動'' else null end),''-@-''),
	concat(''032-@-自動ワンショット-@-'',ord.rst_cond_info->''34''->>''value'',''-@-'',(case ord.rst_cond_info->''34''->>''value'' when ''1'' then ''使用する'' when ''0'' then ''使用しない'' else null end),''-@-''),
	concat(''033-@-IP電源自動切り-@-'',ord.rst_cond_info->''35''->>''value'',''-@-'',(case ord.rst_cond_info->''35''->>''value'' when ''1'' then ''入り'' when ''0'' then ''切り'' else null end),''-@-''),
	concat(''034-@-IP電源自動切り時間-@-'',ord.rst_cond_info->''36''->>''value'',''-@-'',''-@-'',''分'') ,
	concat(''035-@-IP電源OKモニタ切り-@-'',ord.rst_cond_info->''37''->>''value'',''-@-'',(case ord.rst_cond_info->''37''->>''value'' when ''1'' then ''入り'' when ''0'' then ''切り'' else null end),''-@-''),
	concat(''036-@-IP電源OKモニタ切り時間-@-'',ord.rst_cond_info->''38''->>''value'',''-@-'',''-@-'',''分''),
	concat(''037-@-IP速度最大値-@-'',ord.rst_cond_info->''33''->>''value'',''-@-'',''-@-'',''mL/h''),
	concat(''038-@-補液速度-@-'',ord.rst_cond_info->''24''->>''value'',''-@-'',''-@-'',''L/h''),
	concat(''039-@-1次膜-@-'',meqpr.in_hospital_cd_1,''-@-'',ord.rst_cond_info->''7''->>''value_name_1'',''-@-'') ,
	concat(''040-@-2次膜-@-'',meqse.in_hospital_cd_1,''-@-'',ord.rst_cond_info->''8''->>''value_name_1'',''-@-'')
	],''-@@-''),''-@@-'') as cond_row
from
  ord_main as ord
left outer join
   mst_equipment as meqa
  on
   meqa.equipment_cd = TO_NUMBER (ord.rst_cond_info->''9''->>''value'',''999999999999'')
  left outer join
   mst_equipment as meqv
  on
   meqv.equipment_cd = TO_NUMBER (ord.rst_cond_info->''10''->>''value'',''999999999999'')
  left outer join
   mst_equipment as meqsn
  on
   meqsn.equipment_cd = TO_NUMBER (ord.rst_cond_info->''11''->>''value'',''999999999999'')
 left outer join
  mst_equipment as meqad
 on
  meqad.equipment_cd = TO_NUMBER (ord.rst_cond_info->''6''->>''value'',''999999999999'')
 left outer join
  mst_equipment as meqpr
 on
  meqpr.equipment_cd = TO_NUMBER (ord.rst_cond_info->''7''->>''value'',''999999999999'')
 left outer join
  mst_equipment as meqbc
 on
  meqbc.equipment_cd = TO_NUMBER (ord.rst_cond_info->''13''->>''value'',''999999999999'')
 left outer join
  mst_equipment as meqse
 on
  meqse.equipment_cd = TO_NUMBER (ord.rst_cond_info->''8''->>''value'',''999999999999'')
 left outer join
  mst_medicine as med15
 on
  med15.medicine_cd = TO_NUMBER (ord.rst_cond_info->''15''->>''value'',''999999999999'')
 left outer join
  mst_medicine as med19
 on
  med19.medicine_cd = TO_NUMBER (ord.rst_cond_info->''19''->>''value'',''999999999999'')
 left outer join
  mst_medicine as med25
 on
  med25.medicine_cd = TO_NUMBER (ord.rst_cond_info->''25''->>''value'',''999999999999'')
 left outer join
  mst_treatment as mtt
 on
  mtt.treatment_cd = ord.rst_treatment_cd
 left outer join
  mst_dialyzer as mdr
 on
  mdr.dialyzer_cd =TO_NUMBER (ord.rst_cond_info->''5''->>''value'',''999999999999'')
 left outer join
  mst_va as mva
 on
  mva.va_cd =TO_NUMBER (ord.rst_cond_info->''2''->>''value'',''999999999999'')
 left outer join
  mst_bed as mbd
 on
  mbd.bed_cd =ord.rst_bed_cd
 left outer join
  mst_course as mcs
 on
  mcs.course_cd = ord.rst_course_cd
 left outer join
  mst_ward as mwd
 on
  mwd.ward_cd = ord.rst_ward_cd
  left outer join
  mst_medicine_mix as mmx
 on
  mmx.medicine_mix_cd = TO_NUMBER (ord.rst_cond_info->''25''->>''value'',''999999999999'')
  left outer join
  mst_medicine_mix as mmmx
 on
  mmmx.medicine_mix_cd = TO_NUMBER (ord.rst_cond_info->''15''->>''value'',''999999999999'')
  left outer join
  mst_medicine_mix as mmmmx
 on
  mmmmx.medicine_mix_cd = TO_NUMBER (ord.rst_cond_info->''19''->>''value'',''999999999999'')
 where
  ord.ord_no = @ordNo
  ) cond_arr
where
  length(split_part(cond_arr.cond_row,''-@-'',3)) > 0

', 2, '[{}]', '1', '{"applications": [4]}', NULL, 'SSI)実績）透析条件繰り返し部', '2020-05-22 16:51:10.646', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-303, 'select
	cost_fin.*,
	to_char(row_number() over(),''0000'') as cost_no
from
(
select
	all_cost.*
from
(
select --投与薬剤情報(通常)
	''投与薬剤'' as detail_id,
	mmd.in_hospital_cd_1 as e01,
	medi ->> ''name'' as e02,
	medi ->> ''class_name'' as e03,
	to_char(to_number(medi ->>''amount'',''99999.99'') ,''99990.99'')  as e04,
	medi ->> ''unit''as e05,
	mp.in_hospital_cd_a1 as e06,
	medi ->> ''procedure_name'' as e07
    from
      ord_main as ord
    cross join lateral
      json_array_elements (ord.rst_medi_info :: json) medi
	left outer join
	  mst_medicine as mmd
	on
	  mmd.medicine_cd = TO_NUMBER (medi ->> ''cd'',''999999999999'')
	left outer join
	  mst_procedure as mp
	on
	  mp.procedure_cd = TO_NUMBER (medi ->> ''procedure_cd'',''999999999999'')
    where
	  medi ->> ''effect_flg'' = ''1'' and
	  medi ->> ''medicine_type'' = ''1'' and
	COALESCE(mmd.in_hospital_cd_2, ''ZERO'') <> ''ZERO'' and
      ord.ord_no = @ordNo
	--order by medi ->> ''effect_date'',medi ->> ''cd''

union

select --投与薬剤情報(調製)
	 ''投与薬剤'' as detail_id,
	mmd.in_hospital_cd_1 as e1,
	mmd.medicine_name as e2,
	mmdc.class_name as e03 ,
	COALESCE((case mmxd->>''solvent'' when ''1'' then to_char(to_number(mmxd->>''amount'',''99999.99''),''99990.99'') else to_char(to_number(medi ->> ''amount'',''99999.99'') / mmx2.amount_unit * to_number(mmxd->>''amount'',''99999.99''),''99990.99'') end),''0.00'') as e04,
	COALESCE(mmd.unit_second, mmd.unit) as e05,
	mp.in_hospital_cd_a1 as e06,
	medi ->> ''procedure_name'' as e07
    from
      ord_main as ord
    cross join lateral
      json_array_elements (ord.rst_medi_info :: json) medi
	left outer join
	  mst_procedure as mp
	on
	  mp.procedure_cd = TO_NUMBER (medi ->> ''procedure_cd'',''999999999999'')
	left outer join
	  mst_medicine_mix as mmx
 	on
	  mmx.medicine_mix_cd = TO_NUMBER (medi ->> ''cd'',''999999999999''),
	mst_medicine_mix as mmx2
	cross join lateral
      json_array_elements (mmx2.mix_info :: json) mmxd
	left outer join
	  mst_medicine as mmd
	on
	  mmd.medicine_cd = TO_NUMBER (mmxd ->> ''cd'',''999999999999'')
	left outer join
	  mst_medicine_class as mmdc
	on
	  mmdc.class_cd = mmd.class_cd
    where
	  medi ->> ''effect_flg'' = ''1'' and
	  medi ->> ''medicine_type'' = ''2'' and
      ord.ord_no = @ordNo

union

select --処置薬剤情報
	''処置薬剤'' as detail_id,
	mmd.in_hospital_cd_1 as e01,
	tmedi ->> ''treat_medicine_name'' as e02,
	mmdc.class_name as e03 ,
	to_char(to_number(tmedi ->> ''amount'',''99999.99'') ,''99990.99'') as e04,
	tmedi ->> ''unit'' as e05,
	mp.in_hospital_cd_a1 as e06,
	tmedi ->> ''procedure_name'' as e07
    from
      ord_main as ord
    cross join lateral
      json_array_elements (ord.rst_treatment_info :: json) tmedi
	left outer join
	  mst_medicine as mmd
	on
	  mmd.medicine_cd = TO_NUMBER (tmedi ->> ''treat_medicine_cd'',''999999999999'')
	left outer join
	  mst_medicine_class as mmdc
	on
	  mmdc.class_cd = mmd.class_cd
	left outer join
	  mst_procedure as mp
	on
	  mp.procedure_cd = TO_NUMBER (tmedi ->> ''procedure_cd'',''999999999999'')
    where
      ord.ord_no = @ordNo
) all_cost

where
 all_cost.e01 is not null
) cost_fin', 2, '[{}]', '1', '{"applications": [4]}', NULL, 'SSI)実績）薬剤繰り返し部', '2020-05-22 12:43:46.177', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-302, 'select
	cost_fin.detail_id as detail_id,
	to_char(row_number() over(),''0000'') as cost_no,
	trim(cost_fin.e01) as e01,
	cost_fin.e02 as e02,
	cost_fin.e03 as e03,
	cost_fin.e04 as e04,
	cost_fin.e05 as e05,
	cost_fin.e06 as e06
from
(
select
	all_cost.*
from
(

select --血液回路情報
	''血液回路'' as detail_id,
	meq.in_hospital_cd_1 as e01,
	meq.equipment_name as e02,
	''血液回路'' as e03,
	''0''as e04,
	''1'' as e05,
	meq.unit as e06
 from
  ord_main ord
   left outer join
   mst_equipment as meq
  on
   meq.equipment_cd = TO_NUMBER (ord.rst_cond_info->''13''->>''value'',''999999999999'')
   where
  ord.ord_no = @ordNo

union

select --A針情報
	''穿刺針'' as detail_id,
	meq.in_hospital_cd_1 as e01,
	meq.equipment_name as e02,
	''A針'' as e03,
	''1''as e04,
	''1'' as e05,
	meq.unit as e06
 from
  ord_main ord
   left outer join
   mst_equipment as meq
  on
   meq.equipment_cd = TO_NUMBER (ord.rst_cond_info->''9''->>''value'',''999999999999'')
   where
  ord.ord_no = @ordNo

union

select --V針情報
	''穿刺針'' as detail_id,
	meq.in_hospital_cd_1 as e01,
	meq.equipment_name as e02,
	''V針'' as e03,
	''2''as e04,
	''1'' as e05,
	meq.unit as e06
 from
  ord_main ord
   left outer join
   mst_equipment as meq
  on
   meq.equipment_cd = TO_NUMBER (ord.rst_cond_info->''10''->>''value'',''999999999999'')
   where
  ord.ord_no = @ordNo

union

select --SN針情報
	''穿刺針'' as detail_id,
	meq.in_hospital_cd_1 as e01,
	meq.equipment_name as e02,
	''SN針'' as e03,
	''3''as e04,
	''1'' as e05,
	meq.unit as e06
 from
  ord_main ord
   left outer join
   mst_equipment as meq
  on
   meq.equipment_cd = TO_NUMBER (ord.rst_cond_info->''11''->>''value'',''999999999999'')
   where
  ord.ord_no = @ordNo

union

select --医材内穿刺針情報
	''穿刺針'' as detail_id,
	meq.in_hospital_cd_1 as e01,
	meq.equipment_name as e02,
	''穿刺針'' as e03,
	''0''as e04,
	equip ->> ''amount'' as e05,
	equip ->> ''unit'' as e06
 from
  ord_main ord
   cross join lateral
      json_array_elements (ord.rst_equip_info :: json) equip
	left outer join
	  mst_equipment as meq
	on
	  meq.equipment_cd = TO_NUMBER (equip ->> ''cd'',''999999999999'')
   where
  equip->>''class_type'' in (''2'',''3'') and
  ord.ord_no = @ordNo

union

select --医材情報
	''医材'' as detail_id,
	meq.in_hospital_cd_1 as e01,
	meq.equipment_name as e02,
	''医材'' as e03,
	''0''as e04,
	equip ->> ''amount'' as e05,
	equip ->> ''unit'' as e6
 from
  ord_main ord
   cross join lateral
      json_array_elements (ord.rst_equip_info :: json) equip
	left outer join
	  mst_equipment as meq
	on
	  meq.equipment_cd = TO_NUMBER (equip ->> ''cd'',''999999999999'')
   where
  equip->>''equip_type'' = ''0'' and
  equip->>''class_type'' not in (''2'',''3'') and
  ord.ord_no = @ordNo

union

select --1次膜情報
	''医材'' as detail_id,
	meq.in_hospital_cd_1 as e01,
	meq.equipment_name as e02,
	''1次膜'' as e03,
	''0''as e04,
	''1'' as e05,
	meq.unit as e06
from
	ord_main ord
	left outer join
 	 mst_equipment as meq
	on
 	 meq.equipment_cd = TO_NUMBER (ord.rst_cond_info->''7''->>''value'',''999999999999'')
where
	ord.ord_no = @ordNo

union

select --2次膜情報
	''医材'' as detail_id,
	meq.in_hospital_cd_1 as e01,
	meq.equipment_name as e02,
	''2次膜'' as e03,
	''0''as e04,
	''1'' as e05,
	meq.unit as e06
from
	ord_main ord
	left outer join
 	 mst_equipment as meq
	on
 	 meq.equipment_cd = TO_NUMBER (ord.rst_cond_info->''8''->>''value'',''999999999999'')
where
	ord.ord_no = @ordNo

union

select --吸着カラム情報
	''医材'' as detail_id,
	meq.in_hospital_cd_1 as e01,
	meq.equipment_name as e02,
	''吸着カラム'' as e03,
	''0''as e04,
	''1'' as e05,
	meq.unit as e06
from
	ord_main ord
	left outer join
 	 mst_equipment as meq
	on
 	 meq.equipment_cd = TO_NUMBER (ord.rst_cond_info->''6''->>''value'',''999999999999'')
where
	ord.ord_no = @ordNo
) all_cost

where
 all_cost.e01 is not null
--order by all_cost.e07,all_cost.e01
) cost_fin', 2, '[{}]', '1', '{"applications": [4]}', NULL, 'SSI)実績）医材繰り返し部', '2020-05-22 11:43:49.552', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-301, 'select
	treat_total.detail_id as detail_id,
	to_char(row_number() over(),''0000'') as cost_no,
	treat_total.e01 as e01,
	treat_total.e02 as e02,
	trim(treat_total.e03) as e03,
	treat_total.e04 as e04
from
(
select

	treat_fin.detail_id,
	treat_fin.e01,
	treat_fin.e02,
	treat_fin.e03,
	''-'' as e04
from
(
select
	treat_all.detail_id as detail_id,
	split_part(treat_all.e01,''-@-'',1) as e01,
	split_part(treat_all.e01,''-@-'',2) as e02,
	split_part(treat_all.e01,''-@-'',3) as e03
from
 (
select
 treats.detail_id,
 regexp_split_to_table(treats.e01,''-@@-'') as e01
from
  (
select --投与薬剤情報(通常)
	''処置行為'' as detail_id,
	''000000'' || ''-@-'' || ''区切り'' || ''-@-'' || ''1'' || ''-@@-'' || mmd.in_hospital_cd_2 || ''-@-'' || mmd.medicine_name || ''-@-'' || ''1''  as e01
    from
      ord_main as ord
    cross join lateral
      json_array_elements (ord.rst_medi_info :: json) medi
	left outer join
	  mst_medicine as mmd
	on
	  mmd.medicine_cd = TO_NUMBER (medi ->> ''cd'',''999999999999'')
    where
	  medi ->> ''effect_flg'' = ''1'' and
	  medi ->> ''medicine_type'' = ''1'' and
	  COALESCE(mmd.in_hospital_cd_2, ''ZERO'') <> ''ZERO'' and
      ord.ord_no = @ordNo

union all

select --投与薬剤情報(調製)
	''処置行為'' as detail_id,
	''000000'' || ''-@-'' || ''区切り'' || ''-@-'' || ''1'' || ''-@@-'' || mmx.in_hospital_cd_2 || ''-@-'' || mmx.medicine_mix_name || ''-@-'' || ''1''  as e01
    from
      ord_main as ord
    cross join lateral
      json_array_elements (ord.rst_medi_info :: json) medi
	left outer join
	  mst_medicine_mix as mmx
	on
	  mmx.medicine_mix_cd = TO_NUMBER (medi ->> ''cd'',''999999999999'')
    where
	  medi ->> ''effect_flg'' = ''1'' and
	  medi ->> ''medicine_type'' = ''2'' and
	  COALESCE(mmx.in_hospital_cd_2, ''ZERO'') <> ''ZERO'' and
      ord.ord_no = @ordNo

union all

select --処置薬剤情報
	''処置行為'',
	''000000'' || ''-@-'' || ''区切り'' || ''-@-'' || ''1'' || ''-@@-'' || mmd.in_hospital_cd_2 || ''-@-'' || mmd.medicine_name || ''-@-'' || ''1''  as e01
    from
      ord_main as ord
    cross join lateral
      json_array_elements (ord.rst_treatment_info :: json) tmedi
	left outer join
	  mst_medicine as mmd
	on
	  mmd.medicine_cd = TO_NUMBER (tmedi ->> ''treat_medicine_cd'',''999999999999'')
    where
      ord.ord_no = @ordNo  and
	  COALESCE(mmd.in_hospital_cd_2, ''ZERO'') <> ''ZERO''

union all

select --酸素情報
	''酸素手技'',
	''000000'' || ''-@-'' || ''区切り'' || ''-@-'' || ''1'' || ''-@@-'' || ''999999'' || ''-@-'' || ''酸素吸入'' || ''-@-'' || ''1''  as e01
    from
      ord_main as ord
    cross join lateral
      json_array_elements (ord.rst_treatment_info :: json) oxy
    where
	  COALESCE(oxy ->> ''oxygen_amount'',''end'') = ''end'' and
	  oxy ->> ''treat_class'' = ''3'' and
      ord.ord_no = @ordNo
  ) treats
 ) treat_all
 offset 1
) treat_fin

union all

select --投与薬剤情報(通常)
	''処置材料'' as detail_id,
	mmd.in_hospital_cd_1 as e01,
	mmd.medicine_name as e02,
	to_char(to_number(medi ->>''amount'',''99999.99'') ,''99990.99'')  as e03,
	COALESCE(mmd.unit_second,mmd.unit) as e04
    from
      ord_main as ord
    cross join lateral
      json_array_elements (ord.rst_medi_info :: json) medi
	left outer join
	  mst_medicine as mmd
	on
	  mmd.medicine_cd = TO_NUMBER (medi ->> ''cd'',''999999999999'')
    where
	  medi ->> ''effect_flg'' = ''1'' and
	  medi ->> ''medicine_type'' = ''1'' and
	  COALESCE(mmd.in_hospital_cd_2, ''ZERO'') <> ''ZERO'' and
      ord.ord_no = @ordNo

union all

select --投与薬剤情報(調製)
	''処置材料'' as detail_id,
	mmd.in_hospital_cd_1 as e01,
	mmd.medicine_name as e02 ,
	to_char(sum(to_number((case mmxd->>''solvent'' when ''1'' then to_char(to_number(mmxd->>''amount'',''99999.99'') ,''99999.99'') else to_char(to_number(medi ->> ''amount'',''99999.99'') / mmx2.amount_unit * to_number(COALESCE(mmxd->>''amount'',''0''),''99999.99'') ,''99999.99'') end),''99999.99'')),''9990.99'') as e03,
	COALESCE(mmd.unit_second, mmd.unit) as e04
    from
      ord_main as ord
    cross join lateral
      json_array_elements (ord.rst_medi_info :: json) medi
	left outer join
	  mst_medicine_mix as mmx
	on
	  mmx.medicine_mix_cd = TO_NUMBER (medi ->> ''cd'',''999999999999''),
	mst_medicine_mix as mmx2
	cross join lateral
      json_array_elements (mmx2.mix_info :: json) mmxd
	left outer join
	  mst_medicine as mmd
	on
	  mmd.medicine_cd = TO_NUMBER (mmxd ->> ''cd'',''999999999999'')
    where
	  medi ->> ''effect_flg'' = ''1'' and
	  medi ->> ''medicine_type'' = ''2'' and
	  COALESCE(mmx.in_hospital_cd_2, ''ZERO'') <> ''ZERO'' and
	  COALESCE(mmd.in_hospital_cd_1, ''ZERO'') <> ''ZERO'' and
      ord.ord_no = @ordNo
	 group by  detail_id,e01,e02,e04

union all

select --処置薬剤情報
	''処置材料'' as detail_id,
	mmd.in_hospital_cd_1 as e01,
	mmd.medicine_name as e02,
	(case  COALESCE(mmd.unit_second,''order'') when ''order'' then to_char(to_number(tmedi ->> ''amount'',''99999.99''),''99999.99'') else to_char(to_number(tmedi ->> ''amount'' ,''99990.99'') / mmd.unit_converted_amount * mmd.unit_converted_amount_second ,''99990.99'') end) as e03,
	 COALESCE(mmd.unit_second,mmd.unit) as e04
    from
      ord_main as ord
    cross join lateral
      json_array_elements (ord.rst_treatment_info :: json) tmedi
	left outer join
	  mst_medicine as mmd
	on
	  mmd.medicine_cd = TO_NUMBER (tmedi ->> ''treat_medicine_cd'',''999999999999'')
    where
      ord.ord_no = @ordNo  and
	  COALESCE(mmd.in_hospital_cd_2, ''ZERO'') <> ''ZERO''  and
	  COALESCE(mmd.in_hospital_cd_1, ''ZERO'') <> ''ZERO''

union all

select --酸素情報
	''酸素吸入量''as detail_id,
	 ''999999'' as e01,
	 ''酸素吸入'' as e02,
	 to_char(to_number(oxy ->> ''oxygen_amount'',''999999.99''),''999990.99'') as e03,
	 ''L'' as e04
    from
      ord_main as ord
    cross join lateral
      json_array_elements (ord.rst_treatment_info :: json) oxy
    where
	  COALESCE(oxy ->> ''oxygen_amount'',''end'') <> ''end'' and
	  oxy ->> ''treat_class'' = ''3'' and
      ord.ord_no = @ordNo
) treat_total
', 2, '[{}]', '1', '{"applications": [4]}', NULL, 'SSI)実績処置繰り返し部', '2020-05-20 19:57:15.246', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-205, 'select
	concat(@hosp_pat_id10,to_char(ord.ord_no,''000000000000'')) as tar_key,
	concat(@hosp_pat_id10,to_char(ord.ord_no,''000000000000''),to_char(ord.rst_edition,''0000'')) as xml_key
from
	ord_main ord
where
	ord.ord_no = @ordNo', 2, '[{}]', '0', '{"applications": [4]}', NULL, 'NEC)TAR送信データキー(pat_id,ord_no)', '2020-05-26 16:49:16.583', CURRENT_TIMESTAMP, '[{"sql_cd": -98, "field_name": "hosp_pat_id10", "replace_var": "@hosp_pat_id10"}]');
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-98, 'select
	to_char(to_number(ppm.hosp_pat_id,''999999999999''),''0000000000'') as hosp_pat_id10,
	to_char(to_number(ppm.hosp_pat_id,''999999999999''),''000000000000'') as hosp_pat_id12,
	to_char(to_number(ppm.hosp_pat_id,''999999999999''),''999999999999'') as hosp_pat_id,
	to_number(ppm.hosp_pat_id,''999999999999'') as hosp_pat_id_int
from
	pat_personal_main ppm
where
	ppm.pat_id = @patId
', 3, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）pat_id→hosp_pat_id', '2020-05-26 15:36:09.236', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-37, 'select
  personal_info_decrypt(user_last_name)       || '' '' || personal_info_decrypt(user_first_name) as user_name,
  personal_info_decrypt(user_last_name_kana)  || '' '' || personal_info_decrypt(user_first_name_kana) as user_name_kana,
  personal_info_decrypt(user_last_name_alpha) || '' '' || personal_info_decrypt(user_first_name_alpha) as user_name_alpha

from
  mst_personal_user
where
  user_id = @userId
and
  is_disp = ''1''
and
  is_del = ''0''
', 3, '[]', '0', '{"applications": [4]}', NULL, 'スタッフ名取得用　@ordno使用', '2020-03-31 14:39:00', CURRENT_TIMESTAMP, '[{"sql_cd": -22, "field_name": "staff_cd", "replace_var": "@userId"}]');
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-33, 'SELECT
  lpad(to_char(ord.rst_dw * 100, ''FM99999''), 4, '' '') AS dw
  , lpad(
    to_char(
      to_number(
        ord.rst_weight_info ->> ''weight_before''
        , ''999.99''
      ) * 100
      , ''FM99999''
    )
    , 5
    , '' ''
  ) AS weight_before
  , lpad(
    to_char(
      to_number(
        ord.rst_weight_info ->> ''weight_after''
        , ''999.99''
      ) * 100
      , ''FM99999''
    )
    , 5
    , '' ''
  ) AS weight_after
FROM
  ord_main ord
WHERE
  ord.ord_no = @ordNo
', 2, '[{}]', '0', '{"applications": [4]}', NULL, 'NEC)透析前後体重（9(5,2)）', '2020-05-18 12:55:11.326', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-32, 'select
 pis2.pis[1] as pi1,
 pis2.pis[2] as pi2,
 pis2.pis[3] as pi3,
 pis2.pis[4] as pi4,
 pis2.pis[5] as pi5
from
(
select array(
select
 pi.coop_code as insu_cd
from
 pat_insurance pi
where
 pi.pat_id = @patId and
 pi.is_del = ''0'' and
 COALESCE(pi.coop_code,''NO_INSU'') <> ''NO_INSU''
order by pi.is_selected desc,pi.up_date desc,pi.ctl_no) as pis
) as pis2', 3, '[{}]', '1', '{"applications": [4]}', NULL, 'NEC)保険情報取得', '2020-05-18 11:30:54.318', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-31, 'select
 pem.reg_order_class as exam_timing,
  COALESCE(ord.in_hospital_cd_1,''999999'') as bed_cd
from
 pat_exam_main pem,
 (select o.ind_bed_cd,bed.in_hospital_cd_1 from pat_exam_main p,ord_main o
  left outer join
   mst_bed as bed on o.ind_bed_cd = bed.bed_no
  where p.exam_main_cd = @ordNo and p.pat_id = o.pat_id and to_char(p.reg_exam_date,''YYYYMMDD'') = o.treat_date
  order by o.ind_treat_start_time limit 1 ) ord
where
 pem.exam_main_cd = @ordNo', 2, '[{}]', '0', '{"applications": [4]}', NULL, '日機装）検査区分・ベッド', '2020-05-13 12:35:00.087', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-22, 'select
	 staffs.*
from
(select
	staff ->>''staff_cd'' as staff_cd
from
	ord_main ord,
	pat_main pm
	cross join lateral
      json_array_elements (pm.charge_staff_info :: json) staff
where
	staff->>''is_main'' = ''1'' and
	ord.ord_no = @ordNo and
	pm.pat_id = ord.pat_id
union
select
 ord.ind_schedule_user_info->>''ind_user_id''

from
	ord_main ord
where
	ord.ord_no = @ordNo) staffs

limit 1', 2, '[{}]', '0', '{"applications": [4]}', NULL, '実績）担当医先頭１名(担当医→版確定者）', '2020-04-21 19:23:14.658', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (14, '{"collection": "pat_insurance_history", "eq": {"pat_id": "@patId"}, "lt": {"up_date": "@fromDate"}, "sort": {"up_date": "desc"}, "slice": {"up_date": 1}_insu_set_info&insu_info&insu_pub_info}', 4, '[{"preview": "12345678", "can_calc": "1", "data_code": "insu_no", "data_name": "保険者番号", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_no", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日機装　太郎", "can_calc": "1", "data_code": "insu_pat_name", "data_name": "保険者名称", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_pat_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "1", "data_code": "insu_pat_no", "data_name": "被保険者番号", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_pat_no", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "自費", "can_calc": "1", "data_code": "insu_kbn", "data_name": "保険区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "被保険者", "item": "被保険者"}, {"code": "1", "disp": "被扶養者", "item": "被扶養者"}], "data_class": "保険情報", "field_name": "insu_kbn", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "insu_pat_mark", "data_name": "被保険者記号", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_pat_mark", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "対象外", "can_calc": "1", "data_code": "cki_class", "data_name": "長期高額療養", "data_type": "string", "conv_table": [{"code": "0", "disp": "対象外", "item": "対象外"}, {"code": "1", "disp": "対象者", "item": "対象者"}, {"code": "2", "disp": "１０００円対象者", "item": "１０００円対象者"}, {"code": "3", "disp": "２０００円対象者", "item": "２０００円対象者"}], "data_class": "保険情報", "field_name": "cki_class", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "一般", "can_calc": "1", "data_code": "kki_class", "data_name": "高額受給後期高齢", "data_type": "string", "conv_table": [{"code": "0", "disp": "対象外", "item": "対象外"}, {"code": "1", "disp": "一般", "item": "一般"}, {"code": "2", "disp": "７割給付", "item": "７割給付"}], "data_class": "保険情報", "field_name": "kki_class", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "６歳未満", "can_calc": "1", "data_code": "und_six", "data_name": "6歳未満", "data_type": "string", "conv_table": [{"code": "0", "disp": "対象外", "item": "対象外"}, {"code": "1", "disp": "６歳未満", "item": "６歳未満"}], "data_class": "保険情報", "field_name": "und_six", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70", "can_calc": "1", "data_code": "futan_g", "data_name": "負担率(外来)", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "futan_g", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30", "can_calc": "1", "data_code": "futan_n", "data_name": "負担率(入院)", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "futan_n", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日機装　次郎", "can_calc": "1", "data_code": "insu_pub_no", "data_name": "公費負担者名", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_pub_no", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "1", "data_code": "insu_pub_no", "data_name": "公費負担者番号", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_pub_no", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "1", "data_code": "insu_pub_pat_no", "data_name": "公費受給者番号", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_pub_pat_no", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "主保険", "can_calc": "1", "data_code": "is_selected", "data_name": "主保険フラグ", "data_type": "string", "conv_table": [{"code": "0", "disp": "主保険ではない", "item": "主保険ではない"}, {"code": "1", "disp": "主保険", "item": "主保険"}], "data_class": "保険情報", "field_name": "is_selected", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "XX保険", "can_calc": "1", "data_code": "insu_name", "data_name": "保険名称", "data_type": "string", "conv_table": [], "data_class": "保険情報", "field_name": "insu_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/2/15", "can_calc": "1", "data_code": "insu_start_date", "data_name": "開始日", "data_type": "DateTime", "conv_table": [], "data_class": "保険情報", "field_name": "insu_start_date", "disp_format": "yyyy/mm/dd", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2021/2/15", "can_calc": "1", "data_code": "insu_end_date", "data_name": "終了日", "data_type": "DateTime", "conv_table": [], "data_class": "保険情報", "field_name": "insu_end_date", "disp_format": "yyyy/mm/dd", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2021/2/16", "can_calc": "1", "data_code": "insu_check_date", "data_name": "確認日", "data_type": "DateTime", "conv_table": [], "data_class": "保険情報", "field_name": "insu_check_date", "disp_format": "yyyy/mm/dd", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '患者情報：保険情報　@patId使用', '2021-10-05 21:41:55', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (18, '{"collection": "pat_personal_main_history", "eq": {"pat_id": "@patId", "is_del": "0"}, "lt": {"up_date": "@fromDate"}, "sort": {"up_date": "desc"}, "slice": {"up_date": 1}_dial_diff_com_info}', 4, '[{"preview": "あり", "can_calc": "0", "data_code": "is_pat_dial_diff", "data_name": "透析困難有無", "data_type": "string", "conv_table": [{"code": "0", "disp": "なし", "item": "なし"}, {"code": "1", "disp": "あり", "item": "あり"}], "data_class": "既往歴", "field_name": "is_pat_dial_diff", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "主たる透析困難コメントではない", "can_calc": "0", "data_code": "is_main", "data_name": "有無", "data_type": "string", "conv_table": [{"code": "0", "disp": "主たる透析困難コメントではない", "item": "主たる透析困難コメントではない"}, {"code": "1", "disp": "主たる透析困難コメント", "item": "主たる透析困難コメント"}], "data_class": "既往歴", "field_name": "is_main", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "車椅子", "can_calc": "0", "conv_sql": {"sql_cd": -3, "field_name": "dialysis_difficulty_name", "target_var": "@dialysisDifficultyCd"}, "data_code": "dialysis_difficulty_name", "data_name": "透析困難名", "data_type": "string", "conv_table": [], "data_class": "既往歴", "field_name": "pat_dial_diff_cd", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "conv_sql": {"sql_cd": -3, "field_name": "in_hospital_cd_1", "target_var": "@dialysisDifficultyCd"}, "data_code": "in_hospital_cd_1", "data_name": "連携コード1", "data_type": "string", "conv_table": [], "data_class": "既往歴", "field_name": "pat_dial_diff_cd1", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "conv_sql": {"sql_cd": -3, "field_name": "in_hospital_cd_2", "target_var": "@dialysisDifficultyCd"}, "data_code": "in_hospital_cd_2", "data_name": "連携コード2", "data_type": "string", "conv_table": [], "data_class": "既往歴", "field_name": "pat_dial_diff_cd2", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '患者情報：透析困難(主のみ)　@patId使用', '2020-03-24 00:00:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (21, '{"collection": "pat_group_detail_history", "eq": {"pat_id": "@patId"}, "lt": {"up_date": "@fromDate"}, "sort": {"up_date": "desc"}, "slice": {"up_date": 1}_none}', 4, '[{"preview": "Aグループ", "can_calc": "0", "data_code": "pat_group_name", "data_name": "患者グループ", "data_type": "string", "conv_table": [], "data_class": "既往歴", "field_name": "pat_group_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '患者情報：患者グループ　@patId使用', '2020-03-25 11:30:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (23, '{"collection": "pat_main_history", "eq": {"pat_id": "@patId", "is_del": "0"}, "lt": {"up_date": "@fromDate"}, "sort": {"up_date": "desc"}, "slice": {"up_date": 1}_infect_info(infect=2)}', 4, '[{"preview": "Hbc抗体", "can_calc": "0", "data_code": "infection_name", "data_name": "感染症", "data_type": "string", "conv_table": [], "data_class": "感染症(+)", "field_name": "infection_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "(+)", "can_calc": "0", "data_code": "infect", "data_name": "感染症結果", "data_type": "string", "conv_table": [{"code": "0", "disp": "不明", "item": "不明"}, {"code": "1", "disp": "(-)", "item": "(-)"}, {"code": "2", "disp": "(+)", "item": "(+)"}], "data_class": "感染症(+)", "field_name": "infect", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/01", "can_calc": "0", "data_code": "exam_date", "data_name": "感染症検査日", "data_type": "string", "conv_table": [], "data_class": "感染症(+)", "field_name": "exam_date", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/02", "can_calc": "0", "data_code": "up_date", "data_name": "感染症更新日", "data_type": "string", "conv_table": [], "data_class": "感染症(+)", "field_name": "up_date", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '患者情報：感染症(+)　@patId使用', '2020-03-25 14:07:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (24, '{"collection": "pat_main_history", "eq": {"pat_id": "@patId", "is_del": "0"}, "lt": {"up_date": "@fromDate"}, "sort": {"up_date": "desc"}, "slice": {"up_date": 1}_infect_info(infect=2=1)}', 4, '[{"preview": "Hbc抗体", "can_calc": "0", "data_code": "infection_name", "data_name": "感染症", "data_type": "string", "conv_table": [], "data_class": "感染症(+)(-)", "field_name": "infection_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "(-)", "can_calc": "0", "data_code": "infect", "data_name": "感染症結果", "data_type": "string", "conv_table": [{"code": "0", "disp": "不明", "item": "不明"}, {"code": "1", "disp": "(-)", "item": "(-)"}, {"code": "2", "disp": "(+)", "item": "(+)"}], "data_class": "感染症(+)(-)", "field_name": "infect", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/01", "can_calc": "0", "data_code": "exam_date", "data_name": "感染症検査日", "data_type": "string", "conv_table": [], "data_class": "感染症(+)(-)", "field_name": "exam_date", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/02", "can_calc": "0", "data_code": "up_date", "data_name": "感染症更新日", "data_type": "string", "conv_table": [], "data_class": "感染症(+)(-)", "field_name": "up_date", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '患者情報：感染症(+)(-)　@patId使用', '2020-03-25 14:07:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (25, '{"collection": "pat_main_history", "eq": {"pat_id": "@patId", "is_del": "0"}, "lt": {"up_date": "@fromDate"}, "sort": {"up_date": "desc"}, "slice": {"up_date": 1}_infect_info(infect=2=1=0)}', 4, '[{"preview": "Hbc抗体", "can_calc": "0", "data_code": "infection_name", "data_name": "感染症", "data_type": "string", "conv_table": [], "data_class": "感染症(+)(-)(不明)", "field_name": "infection_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "(不明)", "can_calc": "0", "data_code": "infect", "data_name": "感染症結果", "data_type": "string", "conv_table": [{"code": "0", "disp": "不明", "item": "不明"}, {"code": "1", "disp": "(-)", "item": "(-)"}, {"code": "2", "disp": "(+)", "item": "(+)"}], "data_class": "感染症(+)(-)(不明)", "field_name": "infect", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/01", "can_calc": "0", "data_code": "exam_date", "data_name": "感染症検査日", "data_type": "string", "conv_table": [], "data_class": "感染症(+)(-)(不明)", "field_name": "exam_date", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/02", "can_calc": "0", "data_code": "up_date", "data_name": "感染症更新日", "data_type": "string", "conv_table": [], "data_class": "感染症(+)(-)(不明)", "field_name": "up_date", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '患者情報：感染症(+)(-)(不明)　@patId使用', '2020-03-25 14:07:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (32, 'with tare_tbl as (
  select
    case when extract(dow from date) = 0 then tare_info->''7''
      when extract(dow from date) = 1 then tare_info->''1''
      when extract(dow from date) = 2 then tare_info->''2''
      when extract(dow from date) = 3 then tare_info->''3''
      when extract(dow from date) = 4 then tare_info->''4''
      when extract(dow from date) = 5 then tare_info->''5''
      when extract(dow from date) = 6 then tare_info->''6''
      else null
    end as tare_info
  from (
    select
      date_trunc(''day'', @date::timestamp) as date,
      tare_info
    from
      pat_main
    where
      pat_id = @patId and is_del = ''0''
  ) as pat_main
)

select
  tare_info->>''name_1'' as name_1,
  tare_info->>''weight_1'' as weight_1,
  tare_info->>''name_2'' as name_2,
  tare_info->>''weight_2'' as weight_2,
  tare_info->>''name_3'' as name_3,
  tare_info->>''weight_3'' as weight_3,
  tare_info->>''name_4'' as name_4,
  tare_info->>''weight_4'' as weight_4,
  tare_info->>''name_5'' as name_5,
  tare_info->>''weight_5'' as weight_5,
  to_number(tare_info->>''weight_1'', ''999999'')
    + to_number(tare_info->>''weight_2'', ''999999'')
    + to_number(tare_info->>''weight_3'', ''999999'')
    + to_number(tare_info->>''weight_4'', ''999999'')
    + to_number(tare_info->>''weight_5'', ''999999'')
 as weight_sum
from
  tare_tbl
;', 2, '[{"preview": "スリッパ", "can_calc": "0", "data_code": "name_1", "data_name": "風袋名称１", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "name_1", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "0", "data_code": "weight_1", "data_name": "風袋重量１", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "weight_1", "disp_format": "0", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "服", "can_calc": "0", "data_code": "name_2", "data_name": "風袋名称２", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "name_2", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "0", "data_code": "weight_2", "data_name": "風袋重量２", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "weight_2", "disp_format": "0", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "義足", "can_calc": "0", "data_code": "name_3", "data_name": "風袋名称３", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "name_3", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1200", "can_calc": "0", "data_code": "weight_3", "data_name": "風袋重量３", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "weight_3", "disp_format": "0", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他風袋１", "can_calc": "0", "data_code": "name_4", "data_name": "風袋名称４", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "name_4", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "weight_4", "data_name": "風袋重量４", "data_type": "decima", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "weight_4", "disp_format": "0", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他風袋２", "can_calc": "0", "data_code": "name_5", "data_name": "風袋名称５", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "name_5", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "weight_5", "data_name": "風袋重量５", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "weight_5", "disp_format": "0", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1800", "can_calc": "0", "data_code": "weight_sum", "data_name": "風袋重量合計", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "weight_sum", "disp_format": "0", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '患者情報：風袋　@patId @date使用', '2020-03-25 20:23:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (34, 'select
  wheel_chair_name,
  wheel_chair_weight
from
  mst_wheel_chair,
  (
    select
      mss.facility_cd, ms.*, row_number() over() as index
    from
      mst_selector mss
    cross join lateral jsonb_to_recordset(mss.order_settings->''items'') as ms
    (
      code bigint,
      name text
    )
    where
      facility_cd =
        (select
          facility_cd
        from
          pat_main
        where
          pat_id = @patId and is_del =''0''
        )
    and
      master_physical_name = ''mst_wheel_chair''
  ) ms
where
  mst_wheel_chair.wheel_chair_cd = ms.code
and
  pat_id = @patId
and
  is_disp = ''1''
and
  is_del = ''0''
and
  is_personal = ''1''
limit 1
', 2, '[{"preview": "車椅子１", "can_calc": "0", "data_code": "wheel_chair_name", "data_name": "車椅子名称", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "wheel_chair_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15000", "can_calc": "0", "data_code": "wheel_chair_weight", "data_name": "車椅子重量", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "wheel_chair_weight", "disp_format": "0", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '患者情報：車いす　＠patId使用', '2020-03-25 21:34:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (40, '{"collection": "pat_personal_main_history", "eq": {"pat_id": "@patId", "is_del": "0"}, "lt": {"up_date": "@fromDate"}, "sort": {"up_date": "desc"}, "slice": {"up_date": 1}_other_contact_info}', 4, '[{"preview": "キーパーソン", "can_calc": "0", "data_code": "is_key_person", "data_name": "キーパーソン", "data_type": "string", "conv_table": [{"code": "0", "disp": "■", "item": "非キーパーソン"}, {"code": "1", "disp": "□", "item": "キーパーソン"}], "data_class": "緊急連絡先", "field_name": "is_key_parson", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ニッキソウ　ジロウ", "can_calc": "0", "data_code": "other_name_kana", "data_name": "氏名フリガナ", "data_type": "string", "conv_table": [], "data_class": "緊急連絡先", "field_name": "other_name_kana", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日機装　次郎", "can_calc": "0", "data_code": "other_name", "data_name": "氏名", "data_type": "string", "conv_table": [], "data_class": "緊急連絡先", "field_name": "other_name", "disp_format": "", "data_category": "患者情報", "-facility_table": "", "facility_filter_type": "0"}, {"preview": "弟", "can_calc": "0", "data_code": "relation_name", "data_name": "続柄", "data_type": "string", "conv_table": [], "data_class": "緊急連絡先", "field_name": "relation_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "150-8677", "can_calc": "0", "data_code": "zip_cd", "data_name": "郵便番号", "data_type": "string", "conv_table": [], "data_class": "緊急連絡先", "field_name": "zip_cd", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "東京都渋谷区恵比寿2-27-10 日機装第２別館", "can_calc": "0", "data_code": "address", "data_name": "住所・番地・マンション", "data_type": "string", "conv_table": [], "data_class": "緊急連絡先", "field_name": "address", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "03-9876-5432", "can_calc": "0", "data_code": "tel1", "data_name": "電話番号1", "data_type": "string", "conv_table": [], "data_class": "緊急連絡先", "field_name": "tel1", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "080-9876-5432", "can_calc": "0", "data_code": "tel2", "data_name": "電話番号2", "data_type": "string", "conv_table": [], "data_class": "緊急連絡先", "field_name": "tel2", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "03-8765-4321", "can_calc": "0", "data_code": "fax", "data_name": "Fax番号", "data_type": "string", "conv_table": [], "data_class": "緊急連絡先", "field_name": "fax", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxxxxx@xxxx.xx.xx", "can_calc": "0", "data_code": "e_mail", "data_name": "メール", "data_type": "string", "conv_table": [], "data_class": "緊急連絡先", "field_name": "e_mail", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日機装", "can_calc": "0", "data_code": "work_name", "data_name": "勤務先名", "data_type": "string", "conv_table": [], "data_class": "緊急連絡先", "field_name": "work_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "03-5678-1234", "can_calc": "0", "data_code": "work_tel", "data_name": "勤務先電話番号", "data_type": "string", "conv_table": [], "data_class": "緊急連絡先", "field_name": "work_tel", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "緊急連絡先メモ１です。", "can_calc": "0", "data_code": "memo1", "data_name": "緊急連絡先メモ1", "data_type": "string", "conv_table": [], "data_class": "緊急連絡先", "field_name": "memo1", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "緊急連絡先メモ２です。", "can_calc": "0", "data_code": "memo2", "data_name": "緊急連絡先メモ2", "data_type": "string", "conv_table": [], "data_class": "緊急連絡先", "field_name": "memo2", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '患者情報：緊急連絡先　@patId使用', '2020-03-26 01:32:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (41, '{"collection": "pat_personal_main_history", "eq": {"pat_id": "@patId", "is_del": "0"}, "lt": {"up_date": "@fromDate"}, "sort": {"up_date": "desc"}, "slice": {"up_date": 1}_vendor_contact_info}', 4, '[{"preview": "業者1", "can_calc": "0", "data_code": "company_name", "data_name": "会社名", "data_type": "string", "conv_table": [], "data_class": "業者連絡先", "field_name": "company_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "150-8677", "can_calc": "0", "data_code": "zip_cd", "data_name": "郵便番号", "data_type": "string", "conv_table": [], "data_class": "業者連絡先", "field_name": "zip_cd", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "住所1", "can_calc": "0", "data_code": "address", "data_name": "住所・番地・マンション", "data_type": "string", "conv_table": [], "data_class": "業者連絡先", "field_name": "address", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "111-1111-1111", "can_calc": "0", "data_code": "company_tel", "data_name": "代表電話番号", "data_type": "string", "conv_table": [], "data_class": "業者連絡先", "field_name": "company_tel", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "222-2222-2222", "can_calc": "0", "data_code": "company_fax", "data_name": "代表Fax番号", "data_type": "string", "conv_table": [], "data_class": "業者連絡先", "field_name": "company_fax", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日機装　次郎", "can_calc": "0", "data_code": "worker_name", "data_name": "担当者名", "data_type": "string", "conv_table": [], "data_class": "業者連絡先", "field_name": "worker_name", "disp_format": "", "data_category": "患者情報", "-facility_table": "", "facility_filter_type": "0"}, {"preview": "090-9999-9999", "can_calc": "0", "data_code": "worker_tel", "data_name": "担当者電話番号", "data_type": "string", "conv_table": [], "data_class": "業者連絡先", "field_name": "worker_tel", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxxxxx@xxxx.xx.xx", "can_calc": "0", "data_code": "worker_e_mail", "data_name": "メール", "data_type": "string", "conv_table": [], "data_class": "業者連絡先", "field_name": "worker_e_mail", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "業者連絡先メモ１です。", "can_calc": "0", "data_code": "memo1", "data_name": "業者連絡先メモ1", "data_type": "string", "conv_table": [], "data_class": "業者連絡先", "field_name": "memo1", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "業者連絡先メモ２です。", "can_calc": "0", "data_code": "memo2", "data_name": "業者連絡先メモ2", "data_type": "string", "conv_table": [], "data_class": "業者連絡先", "field_name": "memo2", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '患者情報：業者連絡先　@patId使用', '2020-03-27 13:27:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (42, 'select
 a.*
from
  (select
    info->>''dial_diff_cd'' as pat_dial_diff_cd,
    info->>''dial_diff_cd'' as pat_dial_diff_cd1,
		 info->>''dial_diff_cd'' as pat_dial_diff_cd2,
    info->>''is_dial_diff'' as is_pat_dial_diff,
    info->>''is_main'' as is_main
  from
    pat_personal_main
  cross join lateral
    json_array_elements (pat_personal_main.dial_diff_com_info :: json) info
  where
    is_del = ''0''
  and
    pat_id = @patId
  ) a
where
  a.is_pat_dial_diff = ''1''', 3, '[{"preview": "主", "can_calc": "0", "data_code": "is_main", "data_name": "主たる透析困難", "data_type": "string", "conv_table": [{"code": "0", "disp": "", "item": ""}, {"code": "1", "disp": "主", "item": "主"}], "data_class": "既往歴(透析困難すべて)", "field_name": "is_main", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "あり", "can_calc": "0", "data_code": "is_pat_dial_diff", "data_name": "透析困難有無", "data_type": "string", "conv_table": [{"code": "0", "disp": "なし", "item": "なし"}, {"code": "1", "disp": "あり", "item": "あり"}], "data_class": "既往歴(透析困難すべて)", "field_name": "is_pat_dial_diff", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "車椅子", "can_calc": "0", "conv_sql": {"sql_cd": -3, "field_name": "dialysis_difficulty_name", "target_var": "@dialysisDifficultyCd"}, "data_code": "pat_dial_diff_cd", "data_name": "透析困難理由", "data_type": "string", "conv_table": [], "data_class": "既往歴(透析困難すべて)", "field_name": "pat_dial_diff_cd", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "conv_sql": {"sql_cd": -3, "field_name": "in_hospital_cd_1", "target_var": "@dialysisDifficultyCd"}, "data_code": "pat_dial_diff_cd1", "data_name": "透析困難理由連携コード1", "data_type": "string", "conv_table": [], "data_class": "既往歴(透析困難すべて)", "field_name": "pat_dial_diff_cd1", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "conv_sql": {"sql_cd": -3, "field_name": "in_hospital_cd_2", "target_var": "@dialysisDifficultyCd"}, "data_code": "in_hospital_cd_2", "data_name": "透析困難理由連携コード2", "data_type": "string", "conv_table": [], "data_class": "既往歴(透析困難すべて)", "field_name": "pat_dial_diff_cd2", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '患者情報：透析困難(すべて)　@patId', '2020-03-26 13:40:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (44, 'select
  CASE WHEN p.count > 0 THEN ''1'' ELSE ''0'' END as has_plan
from(
  select
    count(m.pat_id) as count
  from
    pat_exam_main as m
  where
    m.is_del = ''0''
    and jsonb_array_length(m.order_exam_set_info) > 0
      and m.pat_id = @patId
    and m.reg_exam_date between date_trunc(''day'', @date ::timestamp ) and date_trunc(''day'', @date ::timestamp) + ''1 days - 1 milliseconds''
    ) p
;', 2, '[{"preview": "〇", "can_calc": "0", "data_code": "has_plan", "data_name": "予定有無", "data_type": "string", "conv_table": [{"code": "0", "disp": "×", "item": "予定無し"}, {"code": "1", "disp": "〇", "item": "予定有り"}], "data_class": "検査予定(セット・指定日)", "field_name": "has_plan", "disp_format": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '検査予定(セット・指定日)：予定有無 @patId @date 使用', '2020-03-26 16:30:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (46, 'WITH pat_facility AS ( SELECT facility_cd FROM pat_exam_main WHERE pat_id = @patId LIMIT 1 ),
infection_order AS (
SELECT
	one_json ->> ''code'' AS infection_cd,
	json_idx AS infection_cd_order
FROM
	mst_selector
	CROSS JOIN lateral jsonb_array_elements ( order_settings -> ''items'' ) WITH ordinality AS tmp ( one_json, json_idx )
WHERE
	facility_cd = ( SELECT facility_cd FROM pat_facility )
	AND master_physical_name = ''mst_exam_item''
	) SELECT
	info ->> ''item_cd'' AS item_cd,
	item.in_hospital_cd1 AS in_hospital_cd1,
	item.in_hospital_cd2 AS in_hospital_cd2,
	item.in_hospital_cd3 AS in_hospital_cd3,
	item.sbt_cd1 AS sbt_cd1,
	item.sbt_cd2 AS sbt_cd2,
	item.sbt_cd3 AS sbt_cd3,
	info ->> ''item_name'' AS item_name,
	item.unit AS unit,
	p.reg_exam_date AS reg_exam_date,
	p.reg_order_class,
	p.exam_main_cd as exam_main_cd,
CASE

	WHEN item.normal_value_class = ''0'' THEN
	item.normal_value_upper ELSE
CASE

	WHEN @patSex = 1 THEN
	item.normal_value_upper_m
	WHEN @patSex = 2 THEN
	item.normal_value_upper_w ELSE item.normal_value_upper
END
	END AS upper,
CASE

		WHEN item.normal_value_class = ''0'' THEN
		item.normal_value_lower ELSE
	CASE

			WHEN @patSex = 1 THEN
			item.normal_value_lower_m
			WHEN @patSex = 2 THEN
			item.normal_value_lower_w ELSE item.normal_value_lower
		END
		END AS lower
	FROM
		(
		SELECT
			m.*
		FROM
			pat_exam_main AS m
		WHERE
			m.is_del = ''0''
			AND jsonb_array_length ( m.order_exam_set_info ) > 0
			AND m.pat_id = @patId
			AND m.reg_exam_date BETWEEN date_trunc ( ''day'', @date :: TIMESTAMP )
			AND date_trunc ( ''day'', @date :: TIMESTAMP ) + ''1 days - 1 milliseconds''
		ORDER BY
			m.reg_exam_date,
			( CASE m.reg_order_class WHEN ''0'' THEN ''a'' ELSE m.reg_order_class END )
		) p
		CROSS JOIN lateral json_array_elements ( p.exam_order_info :: json ) info
		LEFT OUTER JOIN mst_exam_item AS item ON info ->> ''item_cd'' = ( item.exam_item_cd || '''' )
		AND item.is_del = ''0''
		AND item.is_disp = ''1''
		LEFT JOIN infection_order AS inf ON info ->> ''item_cd'':: text = inf.infection_cd
ORDER BY
infection_cd_order;', 2, '[{"preview": "1234", "can_calc": "0", "data_code": "in_hospital_cd1", "data_name": "院内コード1", "data_type": "string", "conv_table": [], "data_class": "検査予定(単項目・指定日)", "field_name": "in_hospital_cd1", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4567", "can_calc": "0", "data_code": "in_hospital_cd2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "検査予定(単項目・指定日)", "field_name": "in_hospital_cd2", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7890", "can_calc": "0", "data_code": "in_hospital_cd3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "検査予定(単項目・指定日)", "field_name": "in_hospital_cd3", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0123", "can_calc": "0", "data_code": "sbt_cd1", "data_name": "属性コード1", "data_type": "string", "conv_table": [], "data_class": "検査予定(単項目・指定日)", "field_name": "sbt_cd1", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3456", "can_calc": "0", "data_code": "sbt_cd2", "data_name": "属性コード2", "data_type": "string", "conv_table": [], "data_class": "検査予定(単項目・指定日)", "field_name": "sbt_cd2", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6789", "can_calc": "0", "data_code": "sbt_cd3", "data_name": "属性コード3", "data_type": "string", "conv_table": [], "data_class": "検査予定(単項目・指定日)", "field_name": "sbt_cd3", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "検査項目テスト", "can_calc": "0", "data_code": "item_name", "data_name": "検査項目名", "data_type": "string", "conv_table": [], "data_class": "検査予定(単項目・指定日)", "field_name": "item_name", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mg/dL", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "検査予定(単項目・指定日)", "field_name": "unit", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/12", "can_calc": "0", "data_code": "reg_exam_date", "data_name": "検査日", "data_type": "DateTime", "conv_table": [], "data_class": "検査予定(単項目・指定日)", "field_name": "reg_exam_date", "disp_format": "yyyy/MM/dd", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析前", "can_calc": "0", "data_code": "reg_order_class", "data_name": "検査区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "その他", "item": "その他"}, {"code": "1", "disp": "透析前", "item": "透析前"}, {"code": "2", "disp": "透析後", "item": "透析後"}], "data_class": "検査予定(単項目・指定日)", "field_name": "reg_order_class", "disp_format": "", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15.0", "can_calc": "0", "data_code": "upper", "data_name": "正常値上限", "data_type": "decimal", "conv_table": [], "data_class": "検査予定(単項目・指定日)", "field_name": "upper", "disp_format": "0.0", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10.0", "can_calc": "0", "data_code": "lower", "data_name": "正常値下限", "data_type": "decimal", "conv_table": [], "data_class": "検査予定(単項目・指定日)", "field_name": "lower", "disp_format": "0.0", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '検査予定(単項目・指定日) @patId @date 使用', '2020-03-26 20:00:00', CURRENT_TIMESTAMP, '[{"sql_cd": -1, "field_name": "pat_sex", "replace_var": "@patSex"}]');
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (47, 'WITH pat_facility AS ( SELECT facility_cd FROM pat_exam_main WHERE pat_id = @patId LIMIT 1 ),
infection_order AS (
SELECT
	one_json ->> ''code'' AS infection_cd,
	json_idx AS infection_cd_order
FROM
	mst_selector
	CROSS JOIN lateral jsonb_array_elements ( order_settings -> ''items'' ) WITH ordinality AS tmp ( one_json, json_idx )
WHERE
	facility_cd = ( SELECT facility_cd FROM pat_facility )
	AND master_physical_name = ''mst_exam_item''
	)
select
  info->>''item_cd'' as item_cd,
  item.in_hospital_cd1 as in_hospital_cd1,
  item.in_hospital_cd2 as in_hospital_cd2,
  item.in_hospital_cd3 as in_hospital_cd3,
  item.sbt_cd1 as sbt_cd1,
  item.sbt_cd2 as sbt_cd2,
  item.sbt_cd3 as sbt_cd3,
  info->>''item_name'' as item_name,
  item.unit as unit,
  p.reg_exam_date as reg_exam_date,
  p.reg_order_class,
  p.exam_main_cd as exam_main_cd,
  CASE WHEN item.normal_value_class = ''0'' THEN
      item.normal_value_upper
  ELSE
    CASE WHEN @patSex = 1 THEN
      item.normal_value_upper_m
    WHEN @patSex = 2 THEN
      item.normal_value_upper_w
    ELSE
      item.normal_value_upper
    END
  END as upper,
  CASE WHEN item.normal_value_class = ''0'' THEN
      item.normal_value_lower
  ELSE
    CASE WHEN @patSex = 1 THEN
      item.normal_value_lower_m
    WHEN @patSex = 2 THEN
      item.normal_value_lower_w
    ELSE
      item.normal_value_lower
    END
  END as lower
from(
  select
    m.*
  from
    pat_exam_main as m
  where
    m.is_del = ''0''
    and jsonb_array_length(m.order_exam_set_info) > 0
      and m.pat_id = @patId
    and m.reg_exam_date between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
    order by m.reg_exam_date, (case m.reg_order_class when ''0'' then ''a''else m.reg_order_class end)
    ) p
  cross join lateral
    json_array_elements (p.exam_order_info :: json) info
  left outer join
  mst_exam_item as item on info->>''item_cd'' = (item.exam_item_cd || '''') and item.is_del = ''0'' and item.is_disp = ''1''
		LEFT JOIN infection_order AS inf ON info ->> ''item_cd'':: text = inf.infection_cd
ORDER BY
infection_cd_order;
;', 2, '[{"preview": "1234", "can_calc": "0", "data_code": "in_hospital_cd1", "data_name": "院内コード1", "data_type": "string", "conv_table": [], "data_class": "検査予定(単項目・日付範囲)", "field_name": "in_hospital_cd1", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4567", "can_calc": "0", "data_code": "in_hospital_cd2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "検査予定(単項目・日付範囲)", "field_name": "in_hospital_cd2", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7890", "can_calc": "0", "data_code": "in_hospital_cd3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "検査予定(単項目・日付範囲)", "field_name": "in_hospital_cd3", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0123", "can_calc": "0", "data_code": "sbt_cd1", "data_name": "属性コード1", "data_type": "string", "conv_table": [], "data_class": "検査予定(単項目・日付範囲)", "field_name": "sbt_cd1", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3456", "can_calc": "0", "data_code": "sbt_cd2", "data_name": "属性コード2", "data_type": "string", "conv_table": [], "data_class": "検査予定(単項目・日付範囲)", "field_name": "sbt_cd2", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6789", "can_calc": "0", "data_code": "sbt_cd3", "data_name": "属性コード3", "data_type": "string", "conv_table": [], "data_class": "検査予定(単項目・日付範囲)", "field_name": "sbt_cd3", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "検査項目テスト", "can_calc": "0", "data_code": "item_name", "data_name": "検査項目名", "data_type": "string", "conv_table": [], "data_class": "検査予定(単項目・日付範囲)", "field_name": "item_name", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mg/dL", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "検査予定(単項目・日付範囲)", "field_name": "unit", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/12", "can_calc": "0", "data_code": "reg_exam_date", "data_name": "検査日", "data_type": "DateTime", "conv_table": [], "data_class": "検査予定(単項目・日付範囲)", "field_name": "reg_exam_date", "disp_format": "yyyy/mm/dd", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析前", "can_calc": "0", "data_code": "reg_order_class", "data_name": "検査区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "その他", "item": "その他"}, {"code": "1", "disp": "透析前", "item": "透析前"}, {"code": "2", "disp": "透析後", "item": "透析後"}], "data_class": "検査予定(単項目・日付範囲)", "field_name": "reg_order_class", "disp_format": "", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15.0", "can_calc": "0", "data_code": "upper", "data_name": "正常値上限", "data_type": "decimal", "conv_table": [], "data_class": "検査予定(単項目・日付範囲)", "field_name": "upper", "disp_format": "0.0", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10.0", "can_calc": "0", "data_code": "lower", "data_name": "正常値下限", "data_type": "decimal", "conv_table": [], "data_class": "検査予定(単項目・日付範囲)", "field_name": "lower", "disp_format": "0.0", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [2, 3]}', '検査予定(単項目・日付範囲) @patId @fromDate @toDate 使用', '2020-03-26 20:00:00', CURRENT_TIMESTAMP, '[{"sql_cd": -1, "field_name": "pat_sex", "replace_var": "@patSex"}]');
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (48, 'WITH pat_facility AS ( SELECT facility_cd FROM pat_exam_main WHERE pat_id = @patId LIMIT 1 ),
infection_order AS (
SELECT
	one_json ->> ''code'' AS infection_cd,
	json_idx AS infection_cd_order
FROM
	mst_selector
	CROSS JOIN lateral jsonb_array_elements ( order_settings -> ''items'' ) WITH ordinality AS tmp ( one_json, json_idx )
WHERE
	facility_cd = ( SELECT facility_cd FROM pat_facility )
	AND master_physical_name = ''mst_exam_item''
	)
	select
  info->>''item_cd'' as item_cd,
  item.in_hospital_cd1 as in_hospital_cd1,
  item.in_hospital_cd2 as in_hospital_cd2,
  item.in_hospital_cd3 as in_hospital_cd3,
  item.sbt_cd1 as sbt_cd1,
  item.sbt_cd2 as sbt_cd2,
  item.sbt_cd3 as sbt_cd3,
  info->>''item_name'' as item_name,
  item.unit as unit,
  p.reg_exam_date as reg_exam_date,
  p.reg_order_class,
  p.exam_main_cd as exam_main_cd,
  CASE WHEN item.normal_value_class = ''0'' THEN
      item.normal_value_upper
  ELSE
    CASE WHEN @patSex = 1 THEN
      item.normal_value_upper_m
    WHEN @patSex = 2 THEN
      item.normal_value_upper_w
    ELSE
      item.normal_value_upper
    END
  END as upper,
  CASE WHEN item.normal_value_class = ''0'' THEN
      item.normal_value_lower
  ELSE
    CASE WHEN @patSex = 1 THEN
      item.normal_value_lower_m
    WHEN @patSex = 2 THEN
      item.normal_value_lower_w
    ELSE
      item.normal_value_lower
    END
  END as lower
from(
  select
    m.*
  from
    pat_exam_main as m
  where
    m.is_del = ''0''
    and jsonb_array_length(m.order_exam_set_info) > 0
      and m.pat_id = @patId
    and m.reg_exam_date >= date_trunc(''day'', @date ::timestamp)
    order by m.reg_exam_date, (case m.reg_order_class when ''0'' then ''a''else m.reg_order_class end)
    ) p
  cross join lateral
    json_array_elements (p.exam_order_info :: json) info
  left outer join
  mst_exam_item as item on info->>''item_cd'' = (item.exam_item_cd || '''')  and item.is_del =''0''  and item.is_disp =''1''
	LEFT JOIN infection_order AS inf ON info ->> ''item_cd'':: text = inf.infection_cd
	ORDER BY
infection_cd_order
	limit 100
;', 2, '[{"preview": "1234", "can_calc": "0", "data_code": "in_hospital_cd1", "data_name": "院内コード1", "data_type": "string", "conv_table": [], "data_class": "検査予定(単項目・指定日以降)", "field_name": "in_hospital_cd1", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4567", "can_calc": "0", "data_code": "in_hospital_cd2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "検査予定(単項目・指定日以降)", "field_name": "in_hospital_cd2", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7890", "can_calc": "0", "data_code": "in_hospital_cd3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "検査予定(単項目・指定日以降)", "field_name": "in_hospital_cd3", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0123", "can_calc": "0", "data_code": "sbt_cd1", "data_name": "属性コード1", "data_type": "string", "conv_table": [], "data_class": "検査予定(単項目・指定日以降)", "field_name": "sbt_cd1", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3456", "can_calc": "0", "data_code": "sbt_cd2", "data_name": "属性コード2", "data_type": "string", "conv_table": [], "data_class": "検査予定(単項目・指定日以降)", "field_name": "sbt_cd2", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6789", "can_calc": "0", "data_code": "sbt_cd3", "data_name": "属性コード3", "data_type": "string", "conv_table": [], "data_class": "検査予定(単項目・指定日以降)", "field_name": "sbt_cd3", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "検査項目テスト", "can_calc": "0", "data_code": "item_name", "data_name": "検査項目名", "data_type": "string", "conv_table": [], "data_class": "検査予定(単項目・指定日以降)", "field_name": "item_name", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mg/dL", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "検査予定(単項目・指定日以降)", "field_name": "unit", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/12", "can_calc": "0", "data_code": "reg_exam_date", "data_name": "検査日", "data_type": "DateTime", "conv_table": [], "data_class": "検査予定(単項目・指定日以降)", "field_name": "reg_exam_date", "disp_format": "yyyy/mm/dd", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析前", "can_calc": "0", "data_code": "reg_order_class", "data_name": "検査区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "その他", "item": "その他"}, {"code": "1", "disp": "透析前", "item": "透析前"}, {"code": "2", "disp": "透析後", "item": "透析後"}], "data_class": "検査予定(単項目・指定日以降)", "field_name": "reg_order_class", "disp_format": "", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15.0", "can_calc": "0", "data_code": "upper", "data_name": "正常値上限", "data_type": "decimal", "conv_table": [], "data_class": "検査予定(単項目・指定日以降)", "field_name": "upper", "disp_format": "0.0", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10.0", "can_calc": "0", "data_code": "lower", "data_name": "正常値下限", "data_type": "decimal", "conv_table": [], "data_class": "検査予定(単項目・指定日以降)", "field_name": "lower", "disp_format": "0.0", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '検査予定(単項目・指定日以降) @patId @date 使用', '2020-03-26 20:00:00', CURRENT_TIMESTAMP, '[{"sql_cd": -1, "field_name": "pat_sex", "replace_var": "@patSex"}]');
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (49, 'select
  CASE WHEN p.count > 0 THEN ''1'' ELSE ''0'' END as has_plan
from(
  select
    count(m.*) as count
  from
    pat_exam_main as m
  where
    m.is_del = ''0''
    and jsonb_array_length(m.order_exam_set_info) > 0
      and m.pat_id = @patId
    and m.reg_exam_date between date_trunc(''day'', @date ::timestamp ) and date_trunc(''day'', @date ::timestamp) + ''1 days - 1 milliseconds''
    ) p
;', 2, '[{"preview": "〇", "can_calc": "0", "data_code": "has_plan", "data_name": "予定有無", "data_type": "string", "conv_table": [{"code": "0", "disp": "×", "item": "予定無し"}, {"code": "1", "disp": "〇", "item": "予定有り"}], "data_class": "検査予定(単項目・指定日)", "field_name": "has_plan", "disp_format": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '検査予定(単項目・指定日)：予定有無 @patId @date 使用', '2020-03-26 20:00:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (51, 'with input_params_expand as
(
  select
    pat_event_cd
    ,json_idx
    ,input_param
  from
    pat_event
    cross join lateral jsonb_array_elements(input_params) with ordinality as tmp(input_param, json_idx)
  where
    is_del = ''0''
    and use_type = 2 and ord_no = @ordNo and pat_id = @patId
)
, result_params_expand as
(
  select
    pat_event_cd
    ,json_idx
    ,result_param
  from
    pat_event
    cross join lateral jsonb_array_elements(result_params) with ordinality as tmp(result_param, json_idx)
  where
    is_del = ''0''
    and use_type = 2 and ord_no = @ordNo and pat_id = @patId
)
, pe_basicinfo as
(
  select
    pat_event_cd
    ,event_start_date
    ,event_end_date
    ,category_name
    ,sub_category_name
    ,reg_staff_info->>''reg_staff_name'' as reg_staff_name
    ,reg_date
    ,up_staff_info->>''up_staff_name'' as up_staff_name
    ,up_date
  from
    pat_event
  where
    is_del = ''0''
    and use_type = 2 and ord_no = @ordNo and pat_id = @patId
)
, pe_picked as
(
  select
    ipe.pat_event_cd
    ,ipe.json_idx
    ,input_param
    ,result_param
  from
    input_params_expand as ipe
    inner join result_params_expand as rpe
      on ipe.pat_event_cd = rpe.pat_event_cd and ipe.json_idx = rpe.json_idx
  where
    input_param->>''format_class'' = ''1''
)
, pe_array_agg as
(
  select
    pat_event_cd
    ,array_agg(input_param order by json_idx) as picked_input_params
    ,array_agg(result_param order by json_idx) as picked_result_params
  from
    pe_picked
  group by pat_event_cd
)

select
  pe_array_agg.pat_event_cd
  ,event_start_date
  ,event_end_date
  ,category_name
  ,sub_category_name
  ,reg_staff_name
  ,reg_date
  ,up_staff_name
  ,up_date
  ,picked_input_params[1]->>''field_name'' as data1_field_name
  ,picked_input_params[2]->>''field_name'' as data2_field_name
  ,picked_input_params[3]->>''field_name'' as data3_field_name
  ,picked_input_params[4]->>''field_name'' as data4_field_name
  ,picked_input_params[5]->>''field_name'' as data5_field_name
  ,picked_input_params[6]->>''field_name'' as data6_field_name
  ,picked_input_params[7]->>''field_name'' as data7_field_name
  ,picked_input_params[8]->>''field_name'' as data8_field_name
  ,picked_input_params[9]->>''field_name'' as data9_field_name
  ,picked_input_params[10]->>''field_name'' as data10_field_name
  ,picked_result_params[1]->>''result_value'' as data1
  ,picked_result_params[2]->>''result_value'' as data2
  ,picked_result_params[3]->>''result_value'' as data3
  ,picked_result_params[4]->>''result_value'' as data4
  ,picked_result_params[5]->>''result_value'' as data5
  ,picked_result_params[6]->>''result_value'' as data6
  ,picked_result_params[7]->>''result_value'' as data7
  ,picked_result_params[8]->>''result_value'' as data8
  ,picked_result_params[9]->>''result_value'' as data9
  ,picked_result_params[10]->>''result_value'' as data10
from
  pe_array_agg
  inner join pe_basicinfo on pe_array_agg.pat_event_cd = pe_basicinfo.pat_event_cd
;', 2, '[{"preview": "2020/03/26", "can_calc": "0", "data_code": "event_date", "data_name": "イベント開始日", "data_type": "DateTime", "conv_table": [], "data_class": "テキストエリア", "field_name": "event_start_date", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "event_end_date", "data_name": "イベント終了日", "data_type": "DateTime", "conv_table": [], "data_class": "テキストエリア", "field_name": "event_end_date", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "観察記録", "can_calc": "0", "data_code": "category_name", "data_name": "カテゴリ名", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "category_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "SOAP", "can_calc": "0", "data_code": "sub_category_name", "data_name": "サブカテゴリ名", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "sub_category_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師１", "can_calc": "0", "data_code": "reg_staff_name", "data_name": "起票者", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "reg_staff_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/25", "can_calc": "0", "data_code": "reg_date", "data_name": "起票日", "data_type": "DateTime", "conv_table": [], "data_class": "テキストエリア", "field_name": "reg_date", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師２", "can_calc": "0", "data_code": "up_staff_name", "data_name": "最終編集者", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "up_staff_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "up_date", "data_name": "最終編集日", "data_type": "DateTime", "conv_table": [], "data_class": "テキストエリア", "field_name": "up_date", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data1_field_name", "data_name": "データ1 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data1_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data2_field_name", "data_name": "データ2 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data2_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data3_field_name", "data_name": "データ3 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data3_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data4_field_name", "data_name": "データ4 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data4_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data5_field_name", "data_name": "データ5 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data5_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data6_field_name", "data_name": "データ6 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data6_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data7_field_name", "data_name": "データ7 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data7_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data8_field_name", "data_name": "データ8 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data8_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data9_field_name", "data_name": "データ9 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data9_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data10_field_name", "data_name": "データ10 フィールド名", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data10_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data1", "data_name": "データ1", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data1", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data2", "data_name": "データ2", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data2", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data3", "data_name": "データ3", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data3", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data4", "data_name": "データ4", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data4", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data5", "data_name": "データ5", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data5", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data6", "data_name": "データ6", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data6", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data7", "data_name": "データ7", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data7", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data8", "data_name": "データ8", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data8", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data9", "data_name": "データ9", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data9", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data10", "data_name": "データ10", "data_type": "string", "conv_table": [], "data_class": "テキストエリア", "field_name": "data10", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '観察記録 透析レポート テキストエリア @ordNo 使用', '2020-03-27 23:59:59', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (53, 'select
  spitz.spitz_name
from(
  select
    m.*
  from
    pat_exam_main as m
  where
    m.is_del = ''0''
    and jsonb_array_length(m.order_exam_set_info) > 0
     and m.pat_id = @patId
    and m.reg_exam_date between date_trunc(''day'',  @treatDate ::timestamp ) and date_trunc(''day'',  @treatDate ::timestamp) + ''1 days - 1 milliseconds''
    order by m.reg_exam_date
    ) p
  cross join lateral
    json_array_elements (p.order_label_info :: json) info
  left outer join
    mst_spitz as spitz on info->>''spitz_cd'' = spitz.spitz_cd::TEXT and spitz.is_del =''0'' and spitz.is_disp =''1''
where
  spitz.spitz_name is not null
	group by
  spitz.spitz_name
;', 2, '[{"preview": "採血管テスト", "can_calc": "0", "data_code": "spitz_name", "data_name": "採血管名", "data_type": "string", "conv_table": [], "data_class": "検査予定(採血管・指定日)", "field_name": "spitz_name", "disp_format": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '検査予定(採血管・指定日) @patId @date 使用', '2020-03-26 21:00:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (54, 'select
  spitz.spitz_name
from(
  select
    m.*
  from
    pat_exam_main as m
  where
    m.is_del = ''0''
    and jsonb_array_length(m.order_exam_set_info) > 0
     and m.pat_id = @patId
    and m.reg_exam_date between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
    order by m.reg_exam_date
    ) p
  cross join lateral
    json_array_elements (p.order_label_info :: json) info
  left outer join
    mst_spitz as spitz on info->>''spitz_cd'' = spitz.spitz_cd::TEXT and spitz.is_del =''0'' and spitz.is_disp =''1''
where
  spitz.spitz_name is not null
	group by
  spitz.spitz_name
;', 2, '[{"preview": "採血管テスト", "can_calc": "0", "data_code": "spitz_name", "data_name": "採血管名", "data_type": "string", "conv_table": [], "data_class": "検査予定(採血管・日付範囲)", "field_name": "spitz_name", "disp_format": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [2, 3]}', '検査予定(採血管・日付範囲) @patId @fromDate @toDate 使用', '2020-03-26 21:00:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (55, 'select
  spitz.spitz_name
from(
  select
    m.*
  from
    pat_exam_main as m
  where
    m.is_del = ''0''
    and jsonb_array_length(m.order_exam_set_info) > 0
      and m.pat_id = @patId
    and m.reg_exam_date >= date_trunc(''day'', @date ::timestamp )
    order by m.reg_exam_date
    limit 100
    ) p
  cross join lateral
    json_array_elements (p.exam_order_info :: json) info
  left outer join
    mst_exam_item as item on info->>''item_cd'' = (item.exam_item_cd || '''')  and  item.is_del =''0'' and item.is_disp =''1''
  left outer join
    mst_spitz as spitz on item.spitz_cd = spitz.spitz_cd  and spitz.is_del =''0'' and spitz.is_disp =''1''
where
  spitz.spitz_name is not null
group by
  spitz.spitz_name
;', 2, '[{"preview": "採血管テスト", "can_calc": "0", "data_code": "spitz_name", "data_name": "採血管名", "data_type": "string", "conv_table": [], "data_class": "検査予定(採血管・指定日以降)", "field_name": "spitz_name", "disp_format": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '検査予定(採血管・指定日以降) @patId @date 使用', '2020-03-26 21:00:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (56, 'select
  p.reg_rad_date,
  p.rad_result_cd,
  info->>''rad_set_name'' as rad_set_name,
  mst.rad_set_abb_name,
  mst.rad_item_info->0->>''ctl_name'' as ctl_name1,
  mst.rad_item_info->0->>''item_cd'' as item_cd1,
  mst.rad_item_info->1->>''ctl_name'' as ctl_name2,
  mst.rad_item_info->1->>''item_cd'' as item_cd2,
  mst.rad_item_info->2->>''ctl_name'' as ctl_name3,
  mst.rad_item_info->2->>''item_cd'' as item_cd3,
  mst.rad_item_info->3->>''ctl_name'' as ctl_name4,
  mst.rad_item_info->3->>''item_cd'' as item_cd4,
  mst.rad_item_info->4->>''ctl_name'' as ctl_name5,
  mst.rad_item_info->4->>''item_cd'' as item_cd5,
  mst.rad_item_info->5->>''ctl_name'' as ctl_name6,
  mst.rad_item_info->5->>''item_cd'' as item_cd6,
  mst.in_hospital_cd1 as in_hospital_cd1,
  mst.in_hospital_cd2 as in_hospital_cd2,
  mst.in_hospital_cd3 as in_hospital_cd3,
  mst.sbt_cd1 as sbt_cd1,
  mst.sbt_cd2 as sbt_cd2,
  mst.sbt_cd3 as sbt_cd3
from(
  select
   m.*
  from
    pat_rad_main as m
  where
    m.is_del = ''0''
    and jsonb_array_length(m.order_rad_set_info) > 0
    and m.pat_id = @patId
    and m.reg_rad_date between date_trunc(''day'', @date ::timestamp ) and date_trunc(''day'', @date ::timestamp) + ''1 days - 1 milliseconds''
    order by m.reg_rad_date
    ) p
  cross join lateral
    json_array_elements (p.order_rad_set_info :: json) info
  left outer join
    mst_rad_set as mst on info->>''rad_set_cd'' = (mst.rad_set_cd || '''') and mst.is_del = ''0'' and mst.is_disp = ''1''
;', 2, '[{"preview": "2011/03/12", "can_calc": "0", "data_code": "reg_rad_date", "data_name": "検査日", "data_type": "DateTime", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "reg_rad_date", "disp_format": "yyyy/mm/dd", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:00", "can_calc": "0", "data_code": "reg_rad_date", "data_name": "検査時刻", "data_type": "DateTime", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "reg_rad_date", "disp_format": "HH:mm", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "放射線検査テスト", "can_calc": "0", "data_code": "rad_set_name", "data_name": "放射線検査名", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "rad_set_name", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "放射線テスト", "can_calc": "0", "data_code": "rad_set_abb_name", "data_name": "省略 放射線検査名", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "rad_set_abb_name", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "方法テスト", "can_calc": "0", "data_code": "ctl_name1", "data_name": "方法", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "ctl_name1", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "item_cd1", "data_name": "方法コード", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "item_cd1", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "区分テスト", "can_calc": "0", "data_code": "ctl_name2", "data_name": "区分", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "ctl_name2", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2222", "can_calc": "0", "data_code": "item_cd2", "data_name": "区分コード", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "item_cd2", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "部位テスト", "can_calc": "0", "data_code": "ctl_name3", "data_name": "部位", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "ctl_name3", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "333", "can_calc": "0", "data_code": "item_cd3", "data_name": "部位コード", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "item_cd3", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "左右テスト", "can_calc": "0", "data_code": "ctl_name4", "data_name": "左右", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "ctl_name4", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "item_cd4", "data_name": "左右コード", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "item_cd4", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "体位テスト", "can_calc": "0", "data_code": "ctl_name5", "data_name": "体位", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "ctl_name5", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5", "can_calc": "0", "data_code": "item_cd5", "data_name": "体位コード", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "item_cd5", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "方向テスト", "can_calc": "0", "data_code": "ctl_name6", "data_name": "方向", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "ctl_name6", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6", "can_calc": "0", "data_code": "item_cd6", "data_name": "方向コード", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "item_cd6", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234", "can_calc": "0", "data_code": "in_hospital_cd1", "data_name": "院内コード1", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "in_hospital_cd1", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4567", "can_calc": "0", "data_code": "in_hospital_cd2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "in_hospital_cd2", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7890", "can_calc": "0", "data_code": "in_hospital_cd3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "in_hospital_cd3", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0123", "can_calc": "0", "data_code": "sbt_cd1", "data_name": "属性コード1", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "sbt_cd1", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3456", "can_calc": "0", "data_code": "sbt_cd2", "data_name": "属性コード2", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "sbt_cd2", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6789", "can_calc": "0", "data_code": "sbt_cd3", "data_name": "属性コード3", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日)", "field_name": "sbt_cd3", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '放射線検査予定(指定日) @patId @date 使用', '2020-03-26 22:30:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (57, 'select
  p.reg_rad_date,
  p.rad_result_cd,
  info->>''rad_set_name'' as rad_set_name,
  mst.rad_set_abb_name,
  mst.rad_item_info->0->>''ctl_name'' as ctl_name1,
  mst.rad_item_info->0->>''item_cd'' as item_cd1,
  mst.rad_item_info->1->>''ctl_name'' as ctl_name2,
  mst.rad_item_info->1->>''item_cd'' as item_cd2,
  mst.rad_item_info->2->>''ctl_name'' as ctl_name3,
  mst.rad_item_info->2->>''item_cd'' as item_cd3,
  mst.rad_item_info->3->>''ctl_name'' as ctl_name4,
  mst.rad_item_info->3->>''item_cd'' as item_cd4,
  mst.rad_item_info->4->>''ctl_name'' as ctl_name5,
  mst.rad_item_info->4->>''item_cd'' as item_cd5,
  mst.rad_item_info->5->>''ctl_name'' as ctl_name6,
  mst.rad_item_info->5->>''item_cd'' as item_cd6,
  mst.in_hospital_cd1 as in_hospital_cd1,
  mst.in_hospital_cd2 as in_hospital_cd2,
  mst.in_hospital_cd3 as in_hospital_cd3,
  mst.sbt_cd1 as sbt_cd1,
  mst.sbt_cd2 as sbt_cd2,
  mst.sbt_cd3 as sbt_cd3
from(
  select
   m.*
  from
    pat_rad_main as m
  where
    m.is_del = ''0''
    and jsonb_array_length(m.order_rad_set_info) > 0
    and m.pat_id = @patId
    and m.reg_rad_date between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
    order by m.reg_rad_date
    ) p
  cross join lateral
    json_array_elements (p.order_rad_set_info :: json) info
  left outer join
    mst_rad_set as mst on mst.is_del = ''0'' and mst.is_disp = ''1'' and info->>''rad_set_cd'' = (mst.rad_set_cd || '''')
;', 2, '[{"preview": "2011/03/12", "can_calc": "0", "data_code": "reg_rad_date", "data_name": "検査日", "data_type": "DateTime", "conv_table": [], "data_class": "放射線検査予定(日付範囲)", "field_name": "reg_rad_date", "disp_format": "yyyy/mm/dd", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:00", "can_calc": "0", "data_code": "reg_rad_date", "data_name": "検査時刻", "data_type": "DateTime", "conv_table": [], "data_class": "放射線検査予定(日付範囲)", "field_name": "reg_rad_date", "disp_format": "hh:mm", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "放射線検査テスト", "can_calc": "0", "data_code": "rad_set_name", "data_name": "放射線検査名", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(日付範囲)", "field_name": "rad_set_name", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "放射線テスト", "can_calc": "0", "data_code": "rad_set_abb_name", "data_name": "省略 放射線検査名", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(日付範囲)", "field_name": "rad_set_abb_name", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "方法テスト", "can_calc": "0", "data_code": "ctl_name1", "data_name": "方法", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(日付範囲)", "field_name": "ctl_name1", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "item_cd1", "data_name": "方法コード", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(日付範囲)", "field_name": "item_cd1", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "区分テスト", "can_calc": "0", "data_code": "ctl_name2", "data_name": "区分", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(日付範囲)", "field_name": "ctl_name2", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2222", "can_calc": "0", "data_code": "item_cd2", "data_name": "区分コード", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(日付範囲)", "field_name": "item_cd2", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "部位テスト", "can_calc": "0", "data_code": "ctl_name3", "data_name": "部位", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(日付範囲)", "field_name": "ctl_name3", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "333", "can_calc": "0", "data_code": "item_cd3", "data_name": "部位コード", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(日付範囲)", "field_name": "item_cd3", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "左右テスト", "can_calc": "0", "data_code": "ctl_name4", "data_name": "左右", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(日付範囲)", "field_name": "ctl_name4", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "item_cd4", "data_name": "左右コード", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(日付範囲)", "field_name": "item_cd4", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "体位テスト", "can_calc": "0", "data_code": "ctl_name5", "data_name": "体位", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(日付範囲)", "field_name": "ctl_name5", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5", "can_calc": "0", "data_code": "item_cd5", "data_name": "体位コード", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(日付範囲)", "field_name": "item_cd5", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "方向テスト", "can_calc": "0", "data_code": "ctl_name6", "data_name": "方向", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(日付範囲)", "field_name": "ctl_name6", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6", "can_calc": "0", "data_code": "item_cd6", "data_name": "方向コード", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(日付範囲)", "field_name": "item_cd6", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234", "can_calc": "0", "data_code": "in_hospital_cd1", "data_name": "院内コード1", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(日付範囲)", "field_name": "in_hospital_cd1", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4567", "can_calc": "0", "data_code": "in_hospital_cd2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(日付範囲)", "field_name": "in_hospital_cd2", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7890", "can_calc": "0", "data_code": "in_hospital_cd3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(日付範囲)", "field_name": "in_hospital_cd3", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0123", "can_calc": "0", "data_code": "sbt_cd1", "data_name": "属性コード1", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(日付範囲)", "field_name": "sbt_cd1", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3456", "can_calc": "0", "data_code": "sbt_cd2", "data_name": "属性コード2", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(日付範囲)", "field_name": "sbt_cd2", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6789", "can_calc": "0", "data_code": "sbt_cd3", "data_name": "属性コード3", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(日付範囲)", "field_name": "sbt_cd3", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [2, 3]}', '放射線検査予定(日付範囲) @patId @fromDate @toDate 使用', '2020-03-26 22:30:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (58, 'select
  p.reg_rad_date,
  p.rad_result_cd,
  info->>''rad_set_name'' as rad_set_name,
  mst.rad_set_abb_name,
  mst.rad_item_info->0->>''ctl_name'' as ctl_name1,
  mst.rad_item_info->0->>''item_cd'' as item_cd1,
  mst.rad_item_info->1->>''ctl_name'' as ctl_name2,
  mst.rad_item_info->1->>''item_cd'' as item_cd2,
  mst.rad_item_info->2->>''ctl_name'' as ctl_name3,
  mst.rad_item_info->2->>''item_cd'' as item_cd3,
  mst.rad_item_info->3->>''ctl_name'' as ctl_name4,
  mst.rad_item_info->3->>''item_cd'' as item_cd4,
  mst.rad_item_info->4->>''ctl_name'' as ctl_name5,
  mst.rad_item_info->4->>''item_cd'' as item_cd5,
  mst.rad_item_info->5->>''ctl_name'' as ctl_name6,
  mst.rad_item_info->5->>''item_cd'' as item_cd6,
  mst.in_hospital_cd1 as in_hospital_cd1,
  mst.in_hospital_cd2 as in_hospital_cd2,
  mst.in_hospital_cd3 as in_hospital_cd3,
  mst.sbt_cd1 as sbt_cd1,
  mst.sbt_cd2 as sbt_cd2,
  mst.sbt_cd3 as sbt_cd3
from(
  select
   m.*
  from
    pat_rad_main as m
  where
    m.is_del = ''0''
    and jsonb_array_length(m.order_rad_set_info) > 0
    and m.pat_id = @patId
    and m.reg_rad_date >= date_trunc(''day'', @date ::timestamp )
    order by m.reg_rad_date
    ) p
  cross join lateral
    json_array_elements (p.order_rad_set_info :: json) info
  left outer join
    mst_rad_set as mst on info->>''rad_set_cd'' = (mst.rad_set_cd || '''') and mst.is_del = ''0'' and mst.is_disp = ''1''
  limit 100
;', 2, '[{"preview": "2011/03/12", "can_calc": "0", "data_code": "reg_rad_date", "data_name": "検査日", "data_type": "DateTime", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "reg_rad_date", "disp_format": "yyyy/mm/dd", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:00", "can_calc": "0", "data_code": "reg_rad_date", "data_name": "検査時刻", "data_type": "DateTime", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "reg_rad_date", "disp_format": "hh:mm", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "放射線検査テスト", "can_calc": "0", "data_code": "rad_set_name", "data_name": "放射線検査名", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "rad_set_name", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "放射線テスト", "can_calc": "0", "data_code": "rad_set_abb_name", "data_name": "省略 放射線検査名", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "rad_set_abb_name", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "方法テスト", "can_calc": "0", "data_code": "ctl_name1", "data_name": "方法", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "ctl_name1", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "item_cd1", "data_name": "方法コード", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "item_cd1", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "区分テスト", "can_calc": "0", "data_code": "ctl_name2", "data_name": "区分", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "ctl_name2", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2222", "can_calc": "0", "data_code": "item_cd2", "data_name": "区分コード", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "item_cd2", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "部位テスト", "can_calc": "0", "data_code": "ctl_name3", "data_name": "部位", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "ctl_name3", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "333", "can_calc": "0", "data_code": "item_cd3", "data_name": "部位コード", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "item_cd3", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "左右テスト", "can_calc": "0", "data_code": "ctl_name4", "data_name": "左右", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "ctl_name4", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "item_cd4", "data_name": "左右コード", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "item_cd4", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "体位テスト", "can_calc": "0", "data_code": "ctl_name5", "data_name": "体位", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "ctl_name5", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5", "can_calc": "0", "data_code": "item_cd5", "data_name": "体位コード", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "item_cd5", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "方向テスト", "can_calc": "0", "data_code": "ctl_name6", "data_name": "方向", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "ctl_name6", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6", "can_calc": "0", "data_code": "item_cd6", "data_name": "方向コード", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "item_cd6", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234", "can_calc": "0", "data_code": "in_hospital_cd1", "data_name": "院内コード1", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "in_hospital_cd1", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4567", "can_calc": "0", "data_code": "in_hospital_cd2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "in_hospital_cd2", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7890", "can_calc": "0", "data_code": "in_hospital_cd3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "in_hospital_cd3", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0123", "can_calc": "0", "data_code": "sbt_cd1", "data_name": "属性コード1", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "sbt_cd1", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3456", "can_calc": "0", "data_code": "sbt_cd2", "data_name": "属性コード2", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "sbt_cd2", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6789", "can_calc": "0", "data_code": "sbt_cd3", "data_name": "属性コード3", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "sbt_cd3", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '放射線検査予定(指定日以降) @patId @date 使用', '2020-03-26 22:30:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (59, 'select
  CASE WHEN p.count > 0 THEN ''1'' ELSE ''0'' END as has_plan
from(
  select
    count(m.*) as count
  from
    pat_rad_main as m
  where
    m.is_del = ''0''
    and jsonb_array_length(m.order_rad_set_info) > 0
      and m.pat_id = @patId
    and m.reg_rad_date between date_trunc(''day'', @date ::timestamp ) and date_trunc(''day'', @date ::timestamp) + ''1 days - 1 milliseconds''
    ) p
;', 2, '[{"preview": "〇", "can_calc": "0", "data_code": "has_plan", "data_name": "予定有無", "data_type": "string", "conv_table": [{"code": "0", "disp": "×", "item": "予定無し"}, {"code": "1", "disp": "〇", "item": "予定有り"}], "data_class": "放射線検査予定(指定日)", "field_name": "has_plan", "disp_format": "", "data_category": "一般撮影", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '放射線検査予定(指定日)：予定有無 @patId @date 使用', '2020-03-26 22:00:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (61, 'with input_params_expand as
(
  select
    pat_event_cd
    ,json_idx
    ,input_param
  from
    pat_event
    cross join lateral jsonb_array_elements(input_params) with ordinality as tmp(input_param, json_idx)
  where
    is_del = ''0''
    and use_type = 2 and ord_no = @ordNo
)
, result_params_expand as
(
  select
    pat_event_cd
    ,json_idx
    ,result_param
  from
    pat_event
    cross join lateral jsonb_array_elements(result_params) with ordinality as tmp(result_param, json_idx)
  where
    is_del = ''0''
    and use_type = 2 and ord_no = @ordNo
)
, pe_basicinfo as
(
  select
    pat_event_cd
    ,event_start_date as event_date
    ,event_end_date
    ,category_name
    ,sub_category_name
    ,reg_staff_info->>''reg_staff_name'' as reg_staff_name
    ,reg_date
    ,up_staff_info->>''up_staff_name'' as up_staff_name
    ,up_date
  from
    pat_event
  where
    is_del = ''0''
    and use_type = 2 and ord_no = @ordNo
)
, pe_picked as
(
  select
    ipe.pat_event_cd
    ,ipe.json_idx
    ,input_param
    ,result_param
  from
    input_params_expand as ipe
    inner join result_params_expand as rpe
      on ipe.pat_event_cd = rpe.pat_event_cd and ipe.json_idx = rpe.json_idx
  where
    input_param->>''format_class'' = ''2''
)
, pe_array_agg as
(
  select
    pat_event_cd
    ,array_agg(input_param order by json_idx) as picked_input_params
    ,array_agg(result_param order by json_idx) as picked_result_params
  from
    pe_picked
  group by pat_event_cd
)

select
  pe_array_agg.pat_event_cd
  ,to_date(event_date, ''YYYYMMDD'') as event_date
  ,to_date(event_end_date, ''YYYYMMDD'') as event_end_date
  ,category_name
  ,sub_category_name
  ,reg_staff_name
  ,reg_date
  ,up_staff_name
  ,up_date

  ,picked_input_params[1]->>''field_name'' as data1_field_name
  ,picked_input_params[2]->>''field_name'' as data2_field_name
  ,picked_input_params[3]->>''field_name'' as data3_field_name
  ,picked_input_params[4]->>''field_name'' as data4_field_name
  ,picked_input_params[5]->>''field_name'' as data5_field_name
  ,picked_input_params[6]->>''field_name'' as data6_field_name
  ,picked_input_params[7]->>''field_name'' as data7_field_name
  ,picked_input_params[8]->>''field_name'' as data8_field_name
  ,picked_input_params[9]->>''field_name'' as data9_field_name
  ,picked_input_params[10]->>''field_name'' as data10_field_name

  ,(picked_result_params[1]->''result_value''->0)->>''name'' as data1_pic1_name
  ,(picked_result_params[1]->''result_value''->0)->>''file_name'' as data1_pic1_file_name
  ,(picked_result_params[1]->''result_value''->0)->>''file_path'' as data1_pic1_file_path
  ,(picked_result_params[1]->''result_value''->1)->>''name'' as data1_pic2_name
  ,(picked_result_params[1]->''result_value''->1)->>''file_name'' as data1_pic2_file_name
  ,(picked_result_params[1]->''result_value''->1)->>''file_path'' as data1_pic2_file_path
  ,(picked_result_params[1]->''result_value''->2)->>''name'' as data1_pic3_name
  ,(picked_result_params[1]->''result_value''->2)->>''file_name'' as data1_pic3_file_name
  ,(picked_result_params[1]->''result_value''->2)->>''file_path'' as data1_pic3_file_path
  ,(picked_result_params[1]->''result_value''->3)->>''name'' as data1_pic4_name
  ,(picked_result_params[1]->''result_value''->3)->>''file_name'' as data1_pic4_file_name
  ,(picked_result_params[1]->''result_value''->3)->>''file_path'' as data1_pic4_file_path
  ,(picked_result_params[1]->''result_value''->4)->>''name'' as data1_pic5_name
  ,(picked_result_params[1]->''result_value''->4)->>''file_name'' as data1_pic5_file_name
  ,(picked_result_params[1]->''result_value''->4)->>''file_path'' as data1_pic5_file_path
  ,(picked_result_params[1]->''result_value''->5)->>''name'' as data1_pic6_name
  ,(picked_result_params[1]->''result_value''->5)->>''file_name'' as data1_pic6_file_name
  ,(picked_result_params[1]->''result_value''->5)->>''file_path'' as data1_pic6_file_path
  ,(picked_result_params[1]->''result_value''->6)->>''name'' as data1_pic7_name
  ,(picked_result_params[1]->''result_value''->6)->>''file_name'' as data1_pic7_file_name
  ,(picked_result_params[1]->''result_value''->6)->>''file_path'' as data1_pic7_file_path
  ,(picked_result_params[1]->''result_value''->7)->>''name'' as data1_pic8_name
  ,(picked_result_params[1]->''result_value''->7)->>''file_name'' as data1_pic8_file_name
  ,(picked_result_params[1]->''result_value''->7)->>''file_path'' as data1_pic8_file_path
  ,(picked_result_params[1]->''result_value''->8)->>''name'' as data1_pic9_name
  ,(picked_result_params[1]->''result_value''->8)->>''file_name'' as data1_pic9_file_name
  ,(picked_result_params[1]->''result_value''->8)->>''file_path'' as data1_pic9_file_path

  ,(picked_result_params[2]->''result_value''->0)->>''name'' as data2_pic1_name
  ,(picked_result_params[2]->''result_value''->0)->>''file_name'' as data2_pic1_file_name
  ,(picked_result_params[2]->''result_value''->0)->>''file_path'' as data2_pic1_file_path
  ,(picked_result_params[2]->''result_value''->1)->>''name'' as data2_pic2_name
  ,(picked_result_params[2]->''result_value''->1)->>''file_name'' as data2_pic2_file_name
  ,(picked_result_params[2]->''result_value''->1)->>''file_path'' as data2_pic2_file_path
  ,(picked_result_params[2]->''result_value''->2)->>''name'' as data2_pic3_name
  ,(picked_result_params[2]->''result_value''->2)->>''file_name'' as data2_pic3_file_name
  ,(picked_result_params[2]->''result_value''->2)->>''file_path'' as data2_pic3_file_path
  ,(picked_result_params[2]->''result_value''->3)->>''name'' as data2_pic4_name
  ,(picked_result_params[2]->''result_value''->3)->>''file_name'' as data2_pic4_file_name
  ,(picked_result_params[2]->''result_value''->3)->>''file_path'' as data2_pic4_file_path
  ,(picked_result_params[2]->''result_value''->4)->>''name'' as data2_pic5_name
  ,(picked_result_params[2]->''result_value''->4)->>''file_name'' as data2_pic5_file_name
  ,(picked_result_params[2]->''result_value''->4)->>''file_path'' as data2_pic5_file_path
  ,(picked_result_params[2]->''result_value''->5)->>''name'' as data2_pic6_name
  ,(picked_result_params[2]->''result_value''->5)->>''file_name'' as data2_pic6_file_name
  ,(picked_result_params[2]->''result_value''->5)->>''file_path'' as data2_pic6_file_path
  ,(picked_result_params[2]->''result_value''->6)->>''name'' as data2_pic7_name
  ,(picked_result_params[2]->''result_value''->6)->>''file_name'' as data2_pic7_file_name
  ,(picked_result_params[2]->''result_value''->6)->>''file_path'' as data2_pic7_file_path
  ,(picked_result_params[2]->''result_value''->7)->>''name'' as data2_pic8_name
  ,(picked_result_params[2]->''result_value''->7)->>''file_name'' as data2_pic8_file_name
  ,(picked_result_params[2]->''result_value''->7)->>''file_path'' as data2_pic8_file_path
  ,(picked_result_params[2]->''result_value''->8)->>''name'' as data2_pic9_name
  ,(picked_result_params[2]->''result_value''->8)->>''file_name'' as data2_pic9_file_name
  ,(picked_result_params[2]->''result_value''->8)->>''file_path'' as data2_pic9_file_path

  ,(picked_result_params[3]->''result_value''->0)->>''name'' as data3_pic1_name
  ,(picked_result_params[3]->''result_value''->0)->>''file_name'' as data3_pic1_file_name
  ,(picked_result_params[3]->''result_value''->0)->>''file_path'' as data3_pic1_file_path
  ,(picked_result_params[3]->''result_value''->1)->>''name'' as data3_pic2_name
  ,(picked_result_params[3]->''result_value''->1)->>''file_name'' as data3_pic2_file_name
  ,(picked_result_params[3]->''result_value''->1)->>''file_path'' as data3_pic2_file_path
  ,(picked_result_params[3]->''result_value''->2)->>''name'' as data3_pic3_name
  ,(picked_result_params[3]->''result_value''->2)->>''file_name'' as data3_pic3_file_name
  ,(picked_result_params[3]->''result_value''->2)->>''file_path'' as data3_pic3_file_path
  ,(picked_result_params[3]->''result_value''->3)->>''name'' as data3_pic4_name
  ,(picked_result_params[3]->''result_value''->3)->>''file_name'' as data3_pic4_file_name
  ,(picked_result_params[3]->''result_value''->3)->>''file_path'' as data3_pic4_file_path
  ,(picked_result_params[3]->''result_value''->4)->>''name'' as data3_pic5_name
  ,(picked_result_params[3]->''result_value''->4)->>''file_name'' as data3_pic5_file_name
  ,(picked_result_params[3]->''result_value''->4)->>''file_path'' as data3_pic5_file_path
  ,(picked_result_params[3]->''result_value''->5)->>''name'' as data3_pic6_name
  ,(picked_result_params[3]->''result_value''->5)->>''file_name'' as data3_pic6_file_name
  ,(picked_result_params[3]->''result_value''->5)->>''file_path'' as data3_pic6_file_path
  ,(picked_result_params[3]->''result_value''->6)->>''name'' as data3_pic7_name
  ,(picked_result_params[3]->''result_value''->6)->>''file_name'' as data3_pic7_file_name
  ,(picked_result_params[3]->''result_value''->6)->>''file_path'' as data3_pic7_file_path
  ,(picked_result_params[3]->''result_value''->7)->>''name'' as data3_pic8_name
  ,(picked_result_params[3]->''result_value''->7)->>''file_name'' as data3_pic8_file_name
  ,(picked_result_params[3]->''result_value''->7)->>''file_path'' as data3_pic8_file_path
  ,(picked_result_params[3]->''result_value''->8)->>''name'' as data3_pic9_name
  ,(picked_result_params[3]->''result_value''->8)->>''file_name'' as data3_pic9_file_name
  ,(picked_result_params[3]->''result_value''->8)->>''file_path'' as data3_pic9_file_path

  ,(picked_result_params[4]->''result_value''->0)->>''name'' as data4_pic1_name
  ,(picked_result_params[4]->''result_value''->0)->>''file_name'' as data4_pic1_file_name
  ,(picked_result_params[4]->''result_value''->0)->>''file_path'' as data4_pic1_file_path
  ,(picked_result_params[4]->''result_value''->1)->>''name'' as data4_pic2_name
  ,(picked_result_params[4]->''result_value''->1)->>''file_name'' as data4_pic2_file_name
  ,(picked_result_params[4]->''result_value''->1)->>''file_path'' as data4_pic2_file_path
  ,(picked_result_params[4]->''result_value''->2)->>''name'' as data4_pic3_name
  ,(picked_result_params[4]->''result_value''->2)->>''file_name'' as data4_pic3_file_name
  ,(picked_result_params[4]->''result_value''->2)->>''file_path'' as data4_pic3_file_path
  ,(picked_result_params[4]->''result_value''->3)->>''name'' as data4_pic4_name
  ,(picked_result_params[4]->''result_value''->3)->>''file_name'' as data4_pic4_file_name
  ,(picked_result_params[4]->''result_value''->3)->>''file_path'' as data4_pic4_file_path
  ,(picked_result_params[4]->''result_value''->4)->>''name'' as data4_pic5_name
  ,(picked_result_params[4]->''result_value''->4)->>''file_name'' as data4_pic5_file_name
  ,(picked_result_params[4]->''result_value''->4)->>''file_path'' as data4_pic5_file_path
  ,(picked_result_params[4]->''result_value''->5)->>''name'' as data4_pic6_name
  ,(picked_result_params[4]->''result_value''->5)->>''file_name'' as data4_pic6_file_name
  ,(picked_result_params[4]->''result_value''->5)->>''file_path'' as data4_pic6_file_path
  ,(picked_result_params[4]->''result_value''->6)->>''name'' as data4_pic7_name
  ,(picked_result_params[4]->''result_value''->6)->>''file_name'' as data4_pic7_file_name
  ,(picked_result_params[4]->''result_value''->6)->>''file_path'' as data4_pic7_file_path
  ,(picked_result_params[4]->''result_value''->7)->>''name'' as data4_pic8_name
  ,(picked_result_params[4]->''result_value''->7)->>''file_name'' as data4_pic8_file_name
  ,(picked_result_params[4]->''result_value''->7)->>''file_path'' as data4_pic8_file_path
  ,(picked_result_params[4]->''result_value''->8)->>''name'' as data4_pic9_name
  ,(picked_result_params[4]->''result_value''->8)->>''file_name'' as data4_pic9_file_name
  ,(picked_result_params[4]->''result_value''->8)->>''file_path'' as data4_pic9_file_path

  ,(picked_result_params[5]->''result_value''->0)->>''name'' as data5_pic1_name
  ,(picked_result_params[5]->''result_value''->0)->>''file_name'' as data5_pic1_file_name
  ,(picked_result_params[5]->''result_value''->0)->>''file_path'' as data5_pic1_file_path
  ,(picked_result_params[5]->''result_value''->1)->>''name'' as data5_pic2_name
  ,(picked_result_params[5]->''result_value''->1)->>''file_name'' as data5_pic2_file_name
  ,(picked_result_params[5]->''result_value''->1)->>''file_path'' as data5_pic2_file_path
  ,(picked_result_params[5]->''result_value''->2)->>''name'' as data5_pic3_name
  ,(picked_result_params[5]->''result_value''->2)->>''file_name'' as data5_pic3_file_name
  ,(picked_result_params[5]->''result_value''->2)->>''file_path'' as data5_pic3_file_path
  ,(picked_result_params[5]->''result_value''->3)->>''name'' as data5_pic4_name
  ,(picked_result_params[5]->''result_value''->3)->>''file_name'' as data5_pic4_file_name
  ,(picked_result_params[5]->''result_value''->3)->>''file_path'' as data5_pic4_file_path
  ,(picked_result_params[5]->''result_value''->4)->>''name'' as data5_pic5_name
  ,(picked_result_params[5]->''result_value''->4)->>''file_name'' as data5_pic5_file_name
  ,(picked_result_params[5]->''result_value''->4)->>''file_path'' as data5_pic5_file_path
  ,(picked_result_params[5]->''result_value''->5)->>''name'' as data5_pic6_name
  ,(picked_result_params[5]->''result_value''->5)->>''file_name'' as data5_pic6_file_name
  ,(picked_result_params[5]->''result_value''->5)->>''file_path'' as data5_pic6_file_path
  ,(picked_result_params[5]->''result_value''->6)->>''name'' as data5_pic7_name
  ,(picked_result_params[5]->''result_value''->6)->>''file_name'' as data5_pic7_file_name
  ,(picked_result_params[5]->''result_value''->6)->>''file_path'' as data5_pic7_file_path
  ,(picked_result_params[5]->''result_value''->7)->>''name'' as data5_pic8_name
  ,(picked_result_params[5]->''result_value''->7)->>''file_name'' as data5_pic8_file_name
  ,(picked_result_params[5]->''result_value''->7)->>''file_path'' as data5_pic8_file_path
  ,(picked_result_params[5]->''result_value''->8)->>''name'' as data5_pic9_name
  ,(picked_result_params[5]->''result_value''->8)->>''file_name'' as data5_pic9_file_name
  ,(picked_result_params[5]->''result_value''->8)->>''file_path'' as data5_pic9_file_path

  ,(picked_result_params[6]->''result_value''->0)->>''name'' as data6_pic1_name
  ,(picked_result_params[6]->''result_value''->0)->>''file_name'' as data6_pic1_file_name
  ,(picked_result_params[6]->''result_value''->0)->>''file_path'' as data6_pic1_file_path
  ,(picked_result_params[6]->''result_value''->1)->>''name'' as data6_pic2_name
  ,(picked_result_params[6]->''result_value''->1)->>''file_name'' as data6_pic2_file_name
  ,(picked_result_params[6]->''result_value''->1)->>''file_path'' as data6_pic2_file_path
  ,(picked_result_params[6]->''result_value''->2)->>''name'' as data6_pic3_name
  ,(picked_result_params[6]->''result_value''->2)->>''file_name'' as data6_pic3_file_name
  ,(picked_result_params[6]->''result_value''->2)->>''file_path'' as data6_pic3_file_path
  ,(picked_result_params[6]->''result_value''->3)->>''name'' as data6_pic4_name
  ,(picked_result_params[6]->''result_value''->3)->>''file_name'' as data6_pic4_file_name
  ,(picked_result_params[6]->''result_value''->3)->>''file_path'' as data6_pic4_file_path
  ,(picked_result_params[6]->''result_value''->4)->>''name'' as data6_pic5_name
  ,(picked_result_params[6]->''result_value''->4)->>''file_name'' as data6_pic5_file_name
  ,(picked_result_params[6]->''result_value''->4)->>''file_path'' as data6_pic5_file_path
  ,(picked_result_params[6]->''result_value''->5)->>''name'' as data6_pic6_name
  ,(picked_result_params[6]->''result_value''->5)->>''file_name'' as data6_pic6_file_name
  ,(picked_result_params[6]->''result_value''->5)->>''file_path'' as data6_pic6_file_path
  ,(picked_result_params[6]->''result_value''->6)->>''name'' as data6_pic7_name
  ,(picked_result_params[6]->''result_value''->6)->>''file_name'' as data6_pic7_file_name
  ,(picked_result_params[6]->''result_value''->6)->>''file_path'' as data6_pic7_file_path
  ,(picked_result_params[6]->''result_value''->7)->>''name'' as data6_pic8_name
  ,(picked_result_params[6]->''result_value''->7)->>''file_name'' as data6_pic8_file_name
  ,(picked_result_params[6]->''result_value''->7)->>''file_path'' as data6_pic8_file_path
  ,(picked_result_params[6]->''result_value''->8)->>''name'' as data6_pic9_name
  ,(picked_result_params[6]->''result_value''->8)->>''file_name'' as data6_pic9_file_name
  ,(picked_result_params[6]->''result_value''->8)->>''file_path'' as data6_pic9_file_path

  ,(picked_result_params[7]->''result_value''->0)->>''name'' as data7_pic1_name
  ,(picked_result_params[7]->''result_value''->0)->>''file_name'' as data7_pic1_file_name
  ,(picked_result_params[7]->''result_value''->0)->>''file_path'' as data7_pic1_file_path
  ,(picked_result_params[7]->''result_value''->1)->>''name'' as data7_pic2_name
  ,(picked_result_params[7]->''result_value''->1)->>''file_name'' as data7_pic2_file_name
  ,(picked_result_params[7]->''result_value''->1)->>''file_path'' as data7_pic2_file_path
  ,(picked_result_params[7]->''result_value''->2)->>''name'' as data7_pic3_name
  ,(picked_result_params[7]->''result_value''->2)->>''file_name'' as data7_pic3_file_name
  ,(picked_result_params[7]->''result_value''->2)->>''file_path'' as data7_pic3_file_path
  ,(picked_result_params[7]->''result_value''->3)->>''name'' as data7_pic4_name
  ,(picked_result_params[7]->''result_value''->3)->>''file_name'' as data7_pic4_file_name
  ,(picked_result_params[7]->''result_value''->3)->>''file_path'' as data7_pic4_file_path
  ,(picked_result_params[7]->''result_value''->4)->>''name'' as data7_pic5_name
  ,(picked_result_params[7]->''result_value''->4)->>''file_name'' as data7_pic5_file_name
  ,(picked_result_params[7]->''result_value''->4)->>''file_path'' as data7_pic5_file_path
  ,(picked_result_params[7]->''result_value''->5)->>''name'' as data7_pic6_name
  ,(picked_result_params[7]->''result_value''->5)->>''file_name'' as data7_pic6_file_name
  ,(picked_result_params[7]->''result_value''->5)->>''file_path'' as data7_pic6_file_path
  ,(picked_result_params[7]->''result_value''->6)->>''name'' as data7_pic7_name
  ,(picked_result_params[7]->''result_value''->6)->>''file_name'' as data7_pic7_file_name
  ,(picked_result_params[7]->''result_value''->6)->>''file_path'' as data7_pic7_file_path
  ,(picked_result_params[7]->''result_value''->7)->>''name'' as data7_pic8_name
  ,(picked_result_params[7]->''result_value''->7)->>''file_name'' as data7_pic8_file_name
  ,(picked_result_params[7]->''result_value''->7)->>''file_path'' as data7_pic8_file_path
  ,(picked_result_params[7]->''result_value''->8)->>''name'' as data7_pic9_name
  ,(picked_result_params[7]->''result_value''->8)->>''file_name'' as data7_pic9_file_name
  ,(picked_result_params[7]->''result_value''->8)->>''file_path'' as data7_pic9_file_path

  ,(picked_result_params[8]->''result_value''->0)->>''name'' as data8_pic1_name
  ,(picked_result_params[8]->''result_value''->0)->>''file_name'' as data8_pic1_file_name
  ,(picked_result_params[8]->''result_value''->0)->>''file_path'' as data8_pic1_file_path
  ,(picked_result_params[8]->''result_value''->1)->>''name'' as data8_pic2_name
  ,(picked_result_params[8]->''result_value''->1)->>''file_name'' as data8_pic2_file_name
  ,(picked_result_params[8]->''result_value''->1)->>''file_path'' as data8_pic2_file_path
  ,(picked_result_params[8]->''result_value''->2)->>''name'' as data8_pic3_name
  ,(picked_result_params[8]->''result_value''->2)->>''file_name'' as data8_pic3_file_name
  ,(picked_result_params[8]->''result_value''->2)->>''file_path'' as data8_pic3_file_path
  ,(picked_result_params[8]->''result_value''->3)->>''name'' as data8_pic4_name
  ,(picked_result_params[8]->''result_value''->3)->>''file_name'' as data8_pic4_file_name
  ,(picked_result_params[8]->''result_value''->3)->>''file_path'' as data8_pic4_file_path
  ,(picked_result_params[8]->''result_value''->4)->>''name'' as data8_pic5_name
  ,(picked_result_params[8]->''result_value''->4)->>''file_name'' as data8_pic5_file_name
  ,(picked_result_params[8]->''result_value''->4)->>''file_path'' as data8_pic5_file_path
  ,(picked_result_params[8]->''result_value''->5)->>''name'' as data8_pic6_name
  ,(picked_result_params[8]->''result_value''->5)->>''file_name'' as data8_pic6_file_name
  ,(picked_result_params[8]->''result_value''->5)->>''file_path'' as data8_pic6_file_path
  ,(picked_result_params[8]->''result_value''->6)->>''name'' as data8_pic7_name
  ,(picked_result_params[8]->''result_value''->6)->>''file_name'' as data8_pic7_file_name
  ,(picked_result_params[8]->''result_value''->6)->>''file_path'' as data8_pic7_file_path
  ,(picked_result_params[8]->''result_value''->7)->>''name'' as data8_pic8_name
  ,(picked_result_params[8]->''result_value''->7)->>''file_name'' as data8_pic8_file_name
  ,(picked_result_params[8]->''result_value''->7)->>''file_path'' as data8_pic8_file_path
  ,(picked_result_params[8]->''result_value''->8)->>''name'' as data8_pic9_name
  ,(picked_result_params[8]->''result_value''->8)->>''file_name'' as data8_pic9_file_name
  ,(picked_result_params[8]->''result_value''->8)->>''file_path'' as data8_pic9_file_path

  ,(picked_result_params[9]->''result_value''->0)->>''name'' as data9_pic1_name
  ,(picked_result_params[9]->''result_value''->0)->>''file_name'' as data9_pic1_file_name
  ,(picked_result_params[9]->''result_value''->0)->>''file_path'' as data9_pic1_file_path
  ,(picked_result_params[9]->''result_value''->1)->>''name'' as data9_pic2_name
  ,(picked_result_params[9]->''result_value''->1)->>''file_name'' as data9_pic2_file_name
  ,(picked_result_params[9]->''result_value''->1)->>''file_path'' as data9_pic2_file_path
  ,(picked_result_params[9]->''result_value''->2)->>''name'' as data9_pic3_name
  ,(picked_result_params[9]->''result_value''->2)->>''file_name'' as data9_pic3_file_name
  ,(picked_result_params[9]->''result_value''->2)->>''file_path'' as data9_pic3_file_path
  ,(picked_result_params[9]->''result_value''->3)->>''name'' as data9_pic4_name
  ,(picked_result_params[9]->''result_value''->3)->>''file_name'' as data9_pic4_file_name
  ,(picked_result_params[9]->''result_value''->3)->>''file_path'' as data9_pic4_file_path
  ,(picked_result_params[9]->''result_value''->4)->>''name'' as data9_pic5_name
  ,(picked_result_params[9]->''result_value''->4)->>''file_name'' as data9_pic5_file_name
  ,(picked_result_params[9]->''result_value''->4)->>''file_path'' as data9_pic5_file_path
  ,(picked_result_params[9]->''result_value''->5)->>''name'' as data9_pic6_name
  ,(picked_result_params[9]->''result_value''->5)->>''file_name'' as data9_pic6_file_name
  ,(picked_result_params[9]->''result_value''->5)->>''file_path'' as data9_pic6_file_path
  ,(picked_result_params[9]->''result_value''->6)->>''name'' as data9_pic7_name
  ,(picked_result_params[9]->''result_value''->6)->>''file_name'' as data9_pic7_file_name
  ,(picked_result_params[9]->''result_value''->6)->>''file_path'' as data9_pic7_file_path
  ,(picked_result_params[9]->''result_value''->7)->>''name'' as data9_pic8_name
  ,(picked_result_params[9]->''result_value''->7)->>''file_name'' as data9_pic8_file_name
  ,(picked_result_params[9]->''result_value''->7)->>''file_path'' as data9_pic8_file_path
  ,(picked_result_params[9]->''result_value''->8)->>''name'' as data9_pic9_name
  ,(picked_result_params[9]->''result_value''->8)->>''file_name'' as data9_pic9_file_name
  ,(picked_result_params[9]->''result_value''->8)->>''file_path'' as data9_pic9_file_path

  ,(picked_result_params[10]->''result_value''->0)->>''name'' as data10_pic1_name
  ,(picked_result_params[10]->''result_value''->0)->>''file_name'' as data10_pic1_file_name
  ,(picked_result_params[10]->''result_value''->0)->>''file_path'' as data10_pic1_file_path
  ,(picked_result_params[10]->''result_value''->1)->>''name'' as data10_pic2_name
  ,(picked_result_params[10]->''result_value''->1)->>''file_name'' as data10_pic2_file_name
  ,(picked_result_params[10]->''result_value''->1)->>''file_path'' as data10_pic2_file_path
  ,(picked_result_params[10]->''result_value''->2)->>''name'' as data10_pic3_name
  ,(picked_result_params[10]->''result_value''->2)->>''file_name'' as data10_pic3_file_name
  ,(picked_result_params[10]->''result_value''->2)->>''file_path'' as data10_pic3_file_path
  ,(picked_result_params[10]->''result_value''->3)->>''name'' as data10_pic4_name
  ,(picked_result_params[10]->''result_value''->3)->>''file_name'' as data10_pic4_file_name
  ,(picked_result_params[10]->''result_value''->3)->>''file_path'' as data10_pic4_file_path
  ,(picked_result_params[10]->''result_value''->4)->>''name'' as data10_pic5_name
  ,(picked_result_params[10]->''result_value''->4)->>''file_name'' as data10_pic5_file_name
  ,(picked_result_params[10]->''result_value''->4)->>''file_path'' as data10_pic5_file_path
  ,(picked_result_params[10]->''result_value''->5)->>''name'' as data10_pic6_name
  ,(picked_result_params[10]->''result_value''->5)->>''file_name'' as data10_pic6_file_name
  ,(picked_result_params[10]->''result_value''->5)->>''file_path'' as data10_pic6_file_path
  ,(picked_result_params[10]->''result_value''->6)->>''name'' as data10_pic7_name
  ,(picked_result_params[10]->''result_value''->6)->>''file_name'' as data10_pic7_file_name
  ,(picked_result_params[10]->''result_value''->6)->>''file_path'' as data10_pic7_file_path
  ,(picked_result_params[10]->''result_value''->7)->>''name'' as data10_pic8_name
  ,(picked_result_params[10]->''result_value''->7)->>''file_name'' as data10_pic8_file_name
  ,(picked_result_params[10]->''result_value''->7)->>''file_path'' as data10_pic8_file_path
  ,(picked_result_params[10]->''result_value''->8)->>''name'' as data10_pic9_name
  ,(picked_result_params[10]->''result_value''->8)->>''file_name'' as data10_pic9_file_name
  ,(picked_result_params[10]->''result_value''->8)->>''file_path'' as data10_pic9_file_path

from
  pe_array_agg
  inner join pe_basicinfo on pe_array_agg.pat_event_cd = pe_basicinfo.pat_event_cd
;', 2, '[{"preview": "2020/03/26", "can_calc": "0", "data_code": "event_date", "data_name": "イベント開始日", "data_type": "DateTime", "conv_table": [], "data_class": "画像", "field_name": "event_date", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "event_end_date", "data_name": "イベント終了日", "data_type": "DateTime", "conv_table": [], "data_class": "画像", "field_name": "event_end_date", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "観察記録", "can_calc": "0", "data_code": "category_name", "data_name": "カテゴリ名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "category_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "SOAP", "can_calc": "0", "data_code": "sub_category_name", "data_name": "サブカテゴリ名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "sub_category_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師１", "can_calc": "0", "data_code": "reg_staff_name", "data_name": "起票者", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "reg_staff_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/25", "can_calc": "0", "data_code": "reg_date", "data_name": "起票日", "data_type": "DateTime", "conv_table": [], "data_class": "画像", "field_name": "reg_date", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師２", "can_calc": "0", "data_code": "up_staff_name", "data_name": "最終編集者", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "up_staff_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "up_date", "data_name": "最終編集日", "data_type": "DateTime", "conv_table": [], "data_class": "画像", "field_name": "up_date", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート関連画像", "can_calc": "0", "data_code": "data1_field_name", "data_name": "データ1 フィールド名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data1_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート関連画像", "can_calc": "0", "data_code": "data2_field_name", "data_name": "データ2 フィールド名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data2_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート関連画像", "can_calc": "0", "data_code": "data3_field_name", "data_name": "データ3 フィールド名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data3_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート関連画像", "can_calc": "0", "data_code": "data4_field_name", "data_name": "データ4 フィールド名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data4_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート関連画像", "can_calc": "0", "data_code": "data5_field_name", "data_name": "データ5 フィールド名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data5_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート関連画像", "can_calc": "0", "data_code": "data6_field_name", "data_name": "データ6 フィールド名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data6_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート関連画像", "can_calc": "0", "data_code": "data7_field_name", "data_name": "データ7 フィールド名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data7_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート関連画像", "can_calc": "0", "data_code": "data8_field_name", "data_name": "データ8 フィールド名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data8_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート関連画像", "can_calc": "0", "data_code": "data9_field_name", "data_name": "データ9 フィールド名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data9_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート関連画像", "can_calc": "0", "data_code": "data10_field_name", "data_name": "データ10 フィールド名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data10_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data1_pic1_name", "data_name": "データ1 画像1 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data1_pic1_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data1_pic1_file_name", "data_name": "データ1 画像1 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data1_pic1_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data1_pic1_file_path", "data_name": "データ1 画像1 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data1_pic1_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data1_pic2_name", "data_name": "データ1 画像2 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data1_pic2_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data1_pic2_file_name", "data_name": "データ1 画像2 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data1_pic2_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data1_pic2_file_path", "data_name": "データ1 画像2 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data1_pic2_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data1_pic3_name", "data_name": "データ1 画像3 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data1_pic3_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data1_pic3_file_name", "data_name": "データ1 画像3 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data1_pic3_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data1_pic3_file_path", "data_name": "データ1 画像3 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data1_pic3_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data1_pic4_name", "data_name": "データ1 画像4 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data1_pic4_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data1_pic4_file_name", "data_name": "データ1 画像4 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data1_pic4_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data1_pic4_file_path", "data_name": "データ1 画像4 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data1_pic4_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data1_pic5_name", "data_name": "データ1 画像5 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data1_pic5_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data1_pic5_file_name", "data_name": "データ1 画像5 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data1_pic5_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data1_pic5_file_path", "data_name": "データ1 画像5 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data1_pic5_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data1_pic6_name", "data_name": "データ1 画像6 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data1_pic6_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data1_pic6_file_name", "data_name": "データ1 画像6 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data1_pic6_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data1_pic6_file_path", "data_name": "データ1 画像6 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data1_pic6_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data1_pic7_name", "data_name": "データ1 画像7 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data1_pic7_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data1_pic7_file_name", "data_name": "データ1 画像7 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data1_pic7_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data1_pic7_file_path", "data_name": "データ1 画像7 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data1_pic7_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data1_pic8_name", "data_name": "データ1 画像8 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data1_pic8_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data1_pic8_file_name", "data_name": "データ1 画像8 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data1_pic8_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data1_pic8_file_path", "data_name": "データ1 画像8 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data1_pic8_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data1_pic9_name", "data_name": "データ1 画像9 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data1_pic9_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data1_pic9_file_name", "data_name": "データ1 画像9 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data1_pic9_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data1_pic9_file_path", "data_name": "データ1 画像9 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data1_pic9_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data2_pic1_name", "data_name": "データ2 画像1 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data2_pic1_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data2_pic1_file_name", "data_name": "データ2 画像1 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data2_pic1_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data2_pic1_file_path", "data_name": "データ2 画像1 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data2_pic1_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data2_pic2_name", "data_name": "データ2 画像2 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data2_pic2_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data2_pic2_file_name", "data_name": "データ2 画像2 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data2_pic2_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data2_pic2_file_path", "data_name": "データ2 画像2 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data2_pic2_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data2_pic3_name", "data_name": "データ2 画像3 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data2_pic3_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data2_pic3_file_name", "data_name": "データ2 画像3 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data2_pic3_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data2_pic3_file_path", "data_name": "データ2 画像3 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data2_pic3_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data2_pic4_name", "data_name": "データ2 画像4 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data2_pic4_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data2_pic4_file_name", "data_name": "データ2 画像4 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data2_pic4_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data2_pic4_file_path", "data_name": "データ2 画像4 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data2_pic4_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data2_pic5_name", "data_name": "データ2 画像5 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data2_pic5_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data2_pic5_file_name", "data_name": "データ2 画像5 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data2_pic5_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data2_pic5_file_path", "data_name": "データ2 画像5 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data2_pic5_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data2_pic6_name", "data_name": "データ2 画像6 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data2_pic6_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data2_pic6_file_name", "data_name": "データ2 画像6 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data2_pic6_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data2_pic6_file_path", "data_name": "データ2 画像6 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data2_pic6_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data2_pic7_name", "data_name": "データ2 画像7 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data2_pic7_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data2_pic7_file_name", "data_name": "データ2 画像7 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data2_pic7_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data2_pic7_file_path", "data_name": "データ2 画像7 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data2_pic7_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data2_pic8_name", "data_name": "データ2 画像8 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data2_pic8_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data2_pic8_file_name", "data_name": "データ2 画像8 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data2_pic8_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data2_pic8_file_path", "data_name": "データ2 画像8 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data2_pic8_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data2_pic9_name", "data_name": "データ2 画像9 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data2_pic9_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data2_pic9_file_name", "data_name": "データ2 画像9 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data2_pic9_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data2_pic9_file_path", "data_name": "データ2 画像9 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data2_pic9_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data3_pic1_name", "data_name": "データ3 画像1 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data3_pic1_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data3_pic1_file_name", "data_name": "データ3 画像1 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data3_pic1_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data3_pic1_file_path", "data_name": "データ3 画像1 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data3_pic1_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data3_pic2_name", "data_name": "データ3 画像2 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data3_pic2_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data3_pic2_file_name", "data_name": "データ3 画像2 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data3_pic2_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data3_pic2_file_path", "data_name": "データ3 画像2 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data3_pic2_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data3_pic3_name", "data_name": "データ3 画像3 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data3_pic3_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data3_pic3_file_name", "data_name": "データ3 画像3 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data3_pic3_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data3_pic3_file_path", "data_name": "データ3 画像3 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data3_pic3_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data3_pic4_name", "data_name": "データ3 画像4 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data3_pic4_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data3_pic4_file_name", "data_name": "データ3 画像4 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data3_pic4_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data3_pic4_file_path", "data_name": "データ3 画像4 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data3_pic4_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data3_pic5_name", "data_name": "データ3 画像5 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data3_pic5_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data3_pic5_file_name", "data_name": "データ3 画像5 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data3_pic5_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data3_pic5_file_path", "data_name": "データ3 画像5 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data3_pic5_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data3_pic6_name", "data_name": "データ3 画像6 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data3_pic6_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data3_pic6_file_name", "data_name": "データ3 画像6 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data3_pic6_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data3_pic6_file_path", "data_name": "データ3 画像6 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data3_pic6_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data3_pic7_name", "data_name": "データ3 画像7 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data3_pic7_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data3_pic7_file_name", "data_name": "データ3 画像7 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data3_pic7_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data3_pic7_file_path", "data_name": "データ3 画像7 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data3_pic7_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data3_pic8_name", "data_name": "データ3 画像8 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data3_pic8_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data3_pic8_file_name", "data_name": "データ3 画像8 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data3_pic8_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data3_pic8_file_path", "data_name": "データ3 画像8 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data3_pic8_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data3_pic9_name", "data_name": "データ3 画像9 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data3_pic9_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data3_pic9_file_name", "data_name": "データ3 画像9 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data3_pic9_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data3_pic9_file_path", "data_name": "データ3 画像9 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data3_pic9_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data4_pic1_name", "data_name": "データ4 画像1 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data4_pic1_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data4_pic1_file_name", "data_name": "データ4 画像1 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data4_pic1_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data4_pic1_file_path", "data_name": "データ4 画像1 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data4_pic1_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data4_pic2_name", "data_name": "データ4 画像2 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data4_pic2_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data4_pic2_file_name", "data_name": "データ4 画像2 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data4_pic2_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data4_pic2_file_path", "data_name": "データ4 画像2 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data4_pic2_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data4_pic3_name", "data_name": "データ4 画像3 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data4_pic3_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data4_pic3_file_name", "data_name": "データ4 画像3 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data4_pic3_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data4_pic3_file_path", "data_name": "データ4 画像3 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data4_pic3_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data4_pic4_name", "data_name": "データ4 画像4 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data4_pic4_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data4_pic4_file_name", "data_name": "データ4 画像4 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data4_pic4_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data4_pic4_file_path", "data_name": "データ4 画像4 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data4_pic4_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data4_pic5_name", "data_name": "データ4 画像5 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data4_pic5_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data4_pic5_file_name", "data_name": "データ4 画像5 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data4_pic5_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data4_pic5_file_path", "data_name": "データ4 画像5 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data4_pic5_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data4_pic6_name", "data_name": "データ4 画像6 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data4_pic6_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data4_pic6_file_name", "data_name": "データ4 画像6 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data4_pic6_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data4_pic6_file_path", "data_name": "データ4 画像6 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data4_pic6_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data4_pic7_name", "data_name": "データ4 画像7 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data4_pic7_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data4_pic7_file_name", "data_name": "データ4 画像7 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data4_pic7_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data4_pic7_file_path", "data_name": "データ4 画像7 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data4_pic7_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data4_pic8_name", "data_name": "データ4 画像8 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data4_pic8_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data4_pic8_file_name", "data_name": "データ4 画像8 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data4_pic8_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data4_pic8_file_path", "data_name": "データ4 画像8 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data4_pic8_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data4_pic9_name", "data_name": "データ4 画像9 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data4_pic9_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data4_pic9_file_name", "data_name": "データ4 画像9 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data4_pic9_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data4_pic9_file_path", "data_name": "データ4 画像9 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data4_pic9_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data5_pic1_name", "data_name": "データ5 画像1 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data5_pic1_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data5_pic1_file_name", "data_name": "データ5 画像1 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data5_pic1_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data5_pic1_file_path", "data_name": "データ5 画像1 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data5_pic1_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data5_pic2_name", "data_name": "データ5 画像2 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data5_pic2_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data5_pic2_file_name", "data_name": "データ5 画像2 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data5_pic2_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data5_pic2_file_path", "data_name": "データ5 画像2 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data5_pic2_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data5_pic3_name", "data_name": "データ5 画像3 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data5_pic3_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data5_pic3_file_name", "data_name": "データ5 画像3 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data5_pic3_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data5_pic3_file_path", "data_name": "データ5 画像3 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data5_pic3_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data5_pic4_name", "data_name": "データ5 画像4 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data5_pic4_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data5_pic4_file_name", "data_name": "データ5 画像4 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data5_pic4_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data5_pic4_file_path", "data_name": "データ5 画像4 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data5_pic4_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data5_pic5_name", "data_name": "データ5 画像5 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data5_pic5_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data5_pic5_file_name", "data_name": "データ5 画像5 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data5_pic5_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data5_pic5_file_path", "data_name": "データ5 画像5 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data5_pic5_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data5_pic6_name", "data_name": "データ5 画像6 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data5_pic6_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data5_pic6_file_name", "data_name": "データ5 画像6 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data5_pic6_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data5_pic6_file_path", "data_name": "データ5 画像6 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data5_pic6_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data5_pic7_name", "data_name": "データ5 画像7 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data5_pic7_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data5_pic7_file_name", "data_name": "データ5 画像7 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data5_pic7_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data5_pic7_file_path", "data_name": "データ5 画像7 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data5_pic7_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data5_pic8_name", "data_name": "データ5 画像8 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data5_pic8_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data5_pic8_file_name", "data_name": "データ5 画像8 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data5_pic8_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data5_pic8_file_path", "data_name": "データ5 画像8 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data5_pic8_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data5_pic9_name", "data_name": "データ5 画像9 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data5_pic9_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data5_pic9_file_name", "data_name": "データ5 画像9 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data5_pic9_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data5_pic9_file_path", "data_name": "データ5 画像9 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data5_pic9_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data6_pic1_name", "data_name": "データ6 画像1 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data6_pic1_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data6_pic1_file_name", "data_name": "データ6 画像1 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data6_pic1_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data6_pic1_file_path", "data_name": "データ6 画像1 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data6_pic1_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data6_pic2_name", "data_name": "データ6 画像2 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data6_pic2_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data6_pic2_file_name", "data_name": "データ6 画像2 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data6_pic2_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data6_pic2_file_path", "data_name": "データ6 画像2 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data6_pic2_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data6_pic3_name", "data_name": "データ6 画像3 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data6_pic3_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data6_pic3_file_name", "data_name": "データ6 画像3 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data6_pic3_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data6_pic3_file_path", "data_name": "データ6 画像3 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data6_pic3_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data6_pic4_name", "data_name": "データ6 画像4 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data6_pic4_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data6_pic4_file_name", "data_name": "データ6 画像4 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data6_pic4_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data6_pic4_file_path", "data_name": "データ6 画像4 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data6_pic4_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data6_pic5_name", "data_name": "データ6 画像5 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data6_pic5_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data6_pic5_file_name", "data_name": "データ6 画像5 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data6_pic5_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data6_pic5_file_path", "data_name": "データ6 画像5 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data6_pic5_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data6_pic6_name", "data_name": "データ6 画像6 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data6_pic6_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data6_pic6_file_name", "data_name": "データ6 画像6 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data6_pic6_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data6_pic6_file_path", "data_name": "データ6 画像6 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data6_pic6_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data6_pic7_name", "data_name": "データ6 画像7 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data6_pic7_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data6_pic7_file_name", "data_name": "データ6 画像7 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data6_pic7_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data6_pic7_file_path", "data_name": "データ6 画像7 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data6_pic7_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data6_pic8_name", "data_name": "データ6 画像8 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data6_pic8_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data6_pic8_file_name", "data_name": "データ6 画像8 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data6_pic8_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data6_pic8_file_path", "data_name": "データ6 画像8 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data6_pic8_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data6_pic9_name", "data_name": "データ6 画像9 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data6_pic9_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data6_pic9_file_name", "data_name": "データ6 画像9 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data6_pic9_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data6_pic9_file_path", "data_name": "データ6 画像9 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data6_pic9_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data7_pic1_name", "data_name": "データ7 画像1 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data7_pic1_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data7_pic1_file_name", "data_name": "データ7 画像1 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data7_pic1_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data7_pic1_file_path", "data_name": "データ7 画像1 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data7_pic1_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data7_pic2_name", "data_name": "データ7 画像2 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data7_pic2_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data7_pic2_file_name", "data_name": "データ7 画像2 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data7_pic2_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data7_pic2_file_path", "data_name": "データ7 画像2 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data7_pic2_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data7_pic3_name", "data_name": "データ7 画像3 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data7_pic3_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data7_pic3_file_name", "data_name": "データ7 画像3 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data7_pic3_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data7_pic3_file_path", "data_name": "データ7 画像3 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data7_pic3_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data7_pic4_name", "data_name": "データ7 画像4 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data7_pic4_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data7_pic4_file_name", "data_name": "データ7 画像4 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data7_pic4_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data7_pic4_file_path", "data_name": "データ7 画像4 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data7_pic4_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data7_pic5_name", "data_name": "データ7 画像5 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data7_pic5_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data7_pic5_file_name", "data_name": "データ7 画像5 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data7_pic5_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data7_pic5_file_path", "data_name": "データ7 画像5 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data7_pic5_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data7_pic6_name", "data_name": "データ7 画像6 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data7_pic6_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data7_pic6_file_name", "data_name": "データ7 画像6 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data7_pic6_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data7_pic6_file_path", "data_name": "データ7 画像6 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data7_pic6_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data7_pic7_name", "data_name": "データ7 画像7 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data7_pic7_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data7_pic7_file_name", "data_name": "データ7 画像7 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data7_pic7_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data7_pic7_file_path", "data_name": "データ7 画像7 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data7_pic7_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data7_pic8_name", "data_name": "データ7 画像8 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data7_pic8_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data7_pic8_file_name", "data_name": "データ7 画像8 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data7_pic8_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data7_pic8_file_path", "data_name": "データ7 画像8 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data7_pic8_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data7_pic9_name", "data_name": "データ7 画像9 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data7_pic9_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data7_pic9_file_name", "data_name": "データ7 画像9 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data7_pic9_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data7_pic9_file_path", "data_name": "データ7 画像9 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data7_pic9_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data8_pic1_name", "data_name": "データ8 画像1 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data8_pic1_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data8_pic1_file_name", "data_name": "データ8 画像1 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data8_pic1_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data8_pic1_file_path", "data_name": "データ8 画像1 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data8_pic1_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data8_pic2_name", "data_name": "データ8 画像2 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data8_pic2_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data8_pic2_file_name", "data_name": "データ8 画像2 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data8_pic2_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data8_pic2_file_path", "data_name": "データ8 画像2 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data8_pic2_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data8_pic3_name", "data_name": "データ8 画像3 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data8_pic3_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data8_pic3_file_name", "data_name": "データ8 画像3 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data8_pic3_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data8_pic3_file_path", "data_name": "データ8 画像3 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data8_pic3_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data8_pic4_name", "data_name": "データ8 画像4 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data8_pic4_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data8_pic4_file_name", "data_name": "データ8 画像4 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data8_pic4_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data8_pic4_file_path", "data_name": "データ8 画像4 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data8_pic4_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data8_pic5_name", "data_name": "データ8 画像5 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data8_pic5_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data8_pic5_file_name", "data_name": "データ8 画像5 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data8_pic5_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data8_pic5_file_path", "data_name": "データ8 画像5 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data8_pic5_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data8_pic6_name", "data_name": "データ8 画像6 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data8_pic6_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data8_pic6_file_name", "data_name": "データ8 画像6 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data8_pic6_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data8_pic6_file_path", "data_name": "データ8 画像6 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data8_pic6_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data8_pic7_name", "data_name": "データ8 画像7 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data8_pic7_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data8_pic7_file_name", "data_name": "データ8 画像7 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data8_pic7_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data8_pic7_file_path", "data_name": "データ8 画像7 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data8_pic7_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data8_pic8_name", "data_name": "データ8 画像8 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data8_pic8_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data8_pic8_file_name", "data_name": "データ8 画像8 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data8_pic8_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data8_pic8_file_path", "data_name": "データ8 画像8 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data8_pic8_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data8_pic9_name", "data_name": "データ8 画像9 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data8_pic9_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data8_pic9_file_name", "data_name": "データ8 画像9 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data8_pic9_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data8_pic9_file_path", "data_name": "データ8 画像9 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data8_pic9_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data9_pic1_name", "data_name": "データ9 画像1 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data9_pic1_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data9_pic1_file_name", "data_name": "データ9 画像1 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data9_pic1_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data9_pic1_file_path", "data_name": "データ9 画像1 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data9_pic1_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data9_pic2_name", "data_name": "データ9 画像2 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data9_pic2_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data9_pic2_file_name", "data_name": "データ9 画像2 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data9_pic2_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data9_pic2_file_path", "data_name": "データ9 画像2 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data9_pic2_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data9_pic3_name", "data_name": "データ9 画像3 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data9_pic3_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data9_pic3_file_name", "data_name": "データ9 画像3 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data9_pic3_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data9_pic3_file_path", "data_name": "データ9 画像3 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data9_pic3_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data9_pic4_name", "data_name": "データ9 画像4 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data9_pic4_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data9_pic4_file_name", "data_name": "データ9 画像4 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data9_pic4_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data9_pic4_file_path", "data_name": "データ9 画像4 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data9_pic4_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data9_pic5_name", "data_name": "データ9 画像5 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data9_pic5_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data9_pic5_file_name", "data_name": "データ9 画像5 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data9_pic5_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data9_pic5_file_path", "data_name": "データ9 画像5 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data9_pic5_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data9_pic6_name", "data_name": "データ9 画像6 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data9_pic6_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data9_pic6_file_name", "data_name": "データ9 画像6 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data9_pic6_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data9_pic6_file_path", "data_name": "データ9 画像6 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data9_pic6_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data9_pic7_name", "data_name": "データ9 画像7 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data9_pic7_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data9_pic7_file_name", "data_name": "データ9 画像7 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data9_pic7_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data9_pic7_file_path", "data_name": "データ9 画像7 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data9_pic7_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data9_pic8_name", "data_name": "データ9 画像8 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data9_pic8_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data9_pic8_file_name", "data_name": "データ9 画像8 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data9_pic8_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data9_pic8_file_path", "data_name": "データ9 画像8 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data9_pic8_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data9_pic9_name", "data_name": "データ9 画像9 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data9_pic9_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data9_pic9_file_name", "data_name": "データ9 画像9 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data9_pic9_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data9_pic9_file_path", "data_name": "データ9 画像9 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data9_pic9_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data10_pic1_name", "data_name": "データ10 画像1 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data10_pic1_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data10_pic1_file_name", "data_name": "データ10 画像1 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data10_pic1_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data10_pic1_file_path", "data_name": "データ10 画像1 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data10_pic1_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data10_pic2_name", "data_name": "データ10 画像2 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data10_pic2_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data10_pic2_file_name", "data_name": "データ10 画像2 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data10_pic2_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data10_pic2_file_path", "data_name": "データ10 画像2 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data10_pic2_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data10_pic3_name", "data_name": "データ10 画像3 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data10_pic3_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data10_pic3_file_name", "data_name": "データ10 画像3 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data10_pic3_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data10_pic3_file_path", "data_name": "データ10 画像3 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data10_pic3_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data10_pic4_name", "data_name": "データ10 画像4 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data10_pic4_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data10_pic4_file_name", "data_name": "データ10 画像4 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data10_pic4_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data10_pic4_file_path", "data_name": "データ10 画像4 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data10_pic4_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data10_pic5_name", "data_name": "データ10 画像5 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data10_pic5_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data10_pic5_file_name", "data_name": "データ10 画像5 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data10_pic5_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data10_pic5_file_path", "data_name": "データ10 画像5 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data10_pic5_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data10_pic6_name", "data_name": "データ10 画像6 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data10_pic6_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data10_pic6_file_name", "data_name": "データ10 画像6 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data10_pic6_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data10_pic6_file_path", "data_name": "データ10 画像6 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data10_pic6_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data10_pic7_name", "data_name": "データ10 画像7 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data10_pic7_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data10_pic7_file_name", "data_name": "データ10 画像7 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data10_pic7_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data10_pic7_file_path", "data_name": "データ10 画像7 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data10_pic7_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data10_pic8_name", "data_name": "データ10 画像8 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data10_pic8_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data10_pic8_file_name", "data_name": "データ10 画像8 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data10_pic8_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data10_pic8_file_path", "data_name": "データ10 画像8 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data10_pic8_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート画像", "can_calc": "0", "data_code": "data10_pic9_name", "data_name": "データ10 画像9 名前", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data10_pic9_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "report.png", "can_calc": "0", "data_code": "data10_pic9_file_name", "data_name": "データ10 画像9 ファイル名", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data10_pic9_file_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/report.png", "can_calc": "0", "data_code": "data10_pic9_file_path", "data_name": "データ10 画像9 ファイルパス", "data_type": "string", "conv_table": [], "data_class": "画像", "field_name": "data10_pic9_file_path", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '観察記録 透析レポート 画像 @ordNo 使用', '2020-03-27 23:59:59', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (64, 'with input_params_expand as
(
  select
    pat_event_cd
    ,json_idx
    ,input_param
  from
    pat_event
    cross join lateral jsonb_array_elements(input_params) with ordinality as tmp(input_param, json_idx)
  where
    is_del = ''0''
    and use_type = 2 and ord_no = @ordNo
)
, result_params_expand as
(
  select
    pat_event_cd
    ,json_idx
    ,result_param
  from
    pat_event
    cross join lateral jsonb_array_elements(result_params) with ordinality as tmp(result_param, json_idx)
  where
    is_del = ''0''
    and use_type = 2 and ord_no = @ordNo
)
, pe_basicinfo as
(
  select
    pat_event_cd
    ,event_start_date as event_date
    ,event_end_date
    ,category_name
    ,sub_category_name
    ,reg_staff_info->>''reg_staff_name'' as reg_staff_name
    ,reg_date
    ,up_staff_info->>''up_staff_name'' as up_staff_name
    ,up_date
  from
    pat_event
  where
    is_del = ''0''
    and use_type = 2 and ord_no = @ordNo
)
, pe_picked as
(
  select
    ipe.pat_event_cd
    ,ipe.json_idx
    ,input_param
    ,result_param
  from
    input_params_expand as ipe
    inner join result_params_expand as rpe
      on ipe.pat_event_cd = rpe.pat_event_cd and ipe.json_idx = rpe.json_idx
  where
    input_param->>''format_class'' = ''3''
)
, pe_array_agg as
(
  select
    pat_event_cd
    ,array_agg(input_param order by json_idx) as picked_input_params
    ,array_agg(result_param order by json_idx) as picked_result_params
  from
    pe_picked
  group by pat_event_cd
)

select
  pe_array_agg.pat_event_cd
  ,to_date(event_date, ''YYYYMMDD'') as event_date
  ,to_date(event_end_date, ''YYYYMMDD'') as event_end_date
  ,category_name
  ,sub_category_name
  ,reg_staff_name
  ,reg_date
  ,up_staff_name
  ,up_date

  ,picked_input_params[1]->>''field_name'' as data1_field_name
  ,picked_input_params[2]->>''field_name'' as data2_field_name
  ,picked_input_params[3]->>''field_name'' as data3_field_name
  ,picked_input_params[4]->>''field_name'' as data4_field_name
  ,picked_input_params[5]->>''field_name'' as data5_field_name
  ,picked_input_params[6]->>''field_name'' as data6_field_name
  ,picked_input_params[7]->>''field_name'' as data7_field_name
  ,picked_input_params[8]->>''field_name'' as data8_field_name
  ,picked_input_params[9]->>''field_name'' as data9_field_name
  ,picked_input_params[10]->>''field_name'' as data10_field_name
  ,picked_input_params[11]->>''field_name'' as data11_field_name
  ,picked_input_params[12]->>''field_name'' as data12_field_name
  ,picked_input_params[13]->>''field_name'' as data13_field_name
  ,picked_input_params[14]->>''field_name'' as data14_field_name
  ,picked_input_params[15]->>''field_name'' as data15_field_name
  ,picked_input_params[16]->>''field_name'' as data16_field_name
  ,picked_input_params[17]->>''field_name'' as data17_field_name
  ,picked_input_params[18]->>''field_name'' as data18_field_name
  ,picked_input_params[19]->>''field_name'' as data19_field_name
  ,picked_input_params[20]->>''field_name'' as data20_field_name
  ,picked_input_params[21]->>''field_name'' as data21_field_name
  ,picked_input_params[22]->>''field_name'' as data22_field_name
  ,picked_input_params[23]->>''field_name'' as data23_field_name
  ,picked_input_params[24]->>''field_name'' as data24_field_name
  ,picked_input_params[25]->>''field_name'' as data25_field_name
  ,picked_input_params[26]->>''field_name'' as data26_field_name
  ,picked_input_params[27]->>''field_name'' as data27_field_name
  ,picked_input_params[28]->>''field_name'' as data28_field_name
  ,picked_input_params[29]->>''field_name'' as data29_field_name
  ,picked_input_params[30]->>''field_name'' as data30_field_name

  ,picked_result_params[1]->''result_value''->>''name'' as data1_name
  ,picked_result_params[1]->''result_value''->>''score'' as data1_score
  ,picked_result_params[2]->''result_value''->>''name'' as data2_name
  ,picked_result_params[2]->''result_value''->>''score'' as data2_score
  ,picked_result_params[3]->''result_value''->>''name'' as data3_name
  ,picked_result_params[3]->''result_value''->>''score'' as data3_score
  ,picked_result_params[4]->''result_value''->>''name'' as data4_name
  ,picked_result_params[4]->''result_value''->>''score'' as data4_score
  ,picked_result_params[5]->''result_value''->>''name'' as data5_name
  ,picked_result_params[5]->''result_value''->>''score'' as data5_score
  ,picked_result_params[6]->''result_value''->>''name'' as data6_name
  ,picked_result_params[6]->''result_value''->>''score'' as data6_score
  ,picked_result_params[7]->''result_value''->>''name'' as data7_name
  ,picked_result_params[7]->''result_value''->>''score'' as data7_score
  ,picked_result_params[8]->''result_value''->>''name'' as data8_name
  ,picked_result_params[8]->''result_value''->>''score'' as data8_score
  ,picked_result_params[9]->''result_value''->>''name'' as data9_name
  ,picked_result_params[9]->''result_value''->>''score'' as data9_score
  ,picked_result_params[10]->''result_value''->>''name'' as data10_name
  ,picked_result_params[10]->''result_value''->>''score'' as data10_score
  ,picked_result_params[11]->''result_value''->>''name'' as data11_name
  ,picked_result_params[11]->''result_value''->>''score'' as data11_score
  ,picked_result_params[12]->''result_value''->>''name'' as data12_name
  ,picked_result_params[12]->''result_value''->>''score'' as data12_score
  ,picked_result_params[13]->''result_value''->>''name'' as data13_name
  ,picked_result_params[13]->''result_value''->>''score'' as data13_score
  ,picked_result_params[14]->''result_value''->>''name'' as data14_name
  ,picked_result_params[14]->''result_value''->>''score'' as data14_score
  ,picked_result_params[15]->''result_value''->>''name'' as data15_name
  ,picked_result_params[15]->''result_value''->>''score'' as data15_score
  ,picked_result_params[16]->''result_value''->>''name'' as data16_name
  ,picked_result_params[16]->''result_value''->>''score'' as data16_score
  ,picked_result_params[17]->''result_value''->>''name'' as data17_name
  ,picked_result_params[17]->''result_value''->>''score'' as data17_score
  ,picked_result_params[18]->''result_value''->>''name'' as data18_name
  ,picked_result_params[18]->''result_value''->>''score'' as data18_score
  ,picked_result_params[19]->''result_value''->>''name'' as data19_name
  ,picked_result_params[19]->''result_value''->>''score'' as data19_score
  ,picked_result_params[20]->''result_value''->>''name'' as data20_name
  ,picked_result_params[20]->''result_value''->>''score'' as data20_score
  ,picked_result_params[21]->''result_value''->>''name'' as data21_name
  ,picked_result_params[21]->''result_value''->>''score'' as data21_score
  ,picked_result_params[22]->''result_value''->>''name'' as data22_name
  ,picked_result_params[22]->''result_value''->>''score'' as data22_score
  ,picked_result_params[23]->''result_value''->>''name'' as data23_name
  ,picked_result_params[23]->''result_value''->>''score'' as data23_score
  ,picked_result_params[24]->''result_value''->>''name'' as data24_name
  ,picked_result_params[24]->''result_value''->>''score'' as data24_score
  ,picked_result_params[25]->''result_value''->>''name'' as data25_name
  ,picked_result_params[25]->''result_value''->>''score'' as data25_score
  ,picked_result_params[26]->''result_value''->>''name'' as data26_name
  ,picked_result_params[26]->''result_value''->>''score'' as data26_score
  ,picked_result_params[27]->''result_value''->>''name'' as data27_name
  ,picked_result_params[27]->''result_value''->>''score'' as data27_score
  ,picked_result_params[28]->''result_value''->>''name'' as data28_name
  ,picked_result_params[28]->''result_value''->>''score'' as data28_score
  ,picked_result_params[29]->''result_value''->>''name'' as data29_name
  ,picked_result_params[29]->''result_value''->>''score'' as data29_score
  ,picked_result_params[30]->''result_value''->>''name'' as data30_name
  ,picked_result_params[30]->''result_value''->>''score'' as data30_score

from
  pe_array_agg
  inner join pe_basicinfo on pe_array_agg.pat_event_cd = pe_basicinfo.pat_event_cd
;', 2, '[{"preview": "2020/03/26", "can_calc": "0", "data_code": "event_date", "data_name": "イベント開始日", "data_type": "DateTime", "conv_table": [], "data_class": "リスト", "field_name": "event_date", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "event_end_date", "data_name": "イベント終了日", "data_type": "DateTime", "conv_table": [], "data_class": "リスト", "field_name": "event_end_date", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "観察記録", "can_calc": "0", "data_code": "category_name", "data_name": "カテゴリ名", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "category_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "SOAP", "can_calc": "0", "data_code": "sub_category_name", "data_name": "サブカテゴリ名", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "sub_category_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師１", "can_calc": "0", "data_code": "reg_staff_name", "data_name": "起票者", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "reg_staff_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/25", "can_calc": "0", "data_code": "reg_date", "data_name": "起票日", "data_type": "DateTime", "conv_table": [], "data_class": "リスト", "field_name": "reg_date", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師２", "can_calc": "0", "data_code": "up_staff_name", "data_name": "最終編集者", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "up_staff_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "up_date", "data_name": "最終編集日", "data_type": "DateTime", "conv_table": [], "data_class": "リスト", "field_name": "up_date", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択リスト", "can_calc": "0", "data_code": "data1_field_name", "data_name": "データ1 フィールド名", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data1_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択リスト", "can_calc": "0", "data_code": "data2_field_name", "data_name": "データ2 フィールド名", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data2_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択リスト", "can_calc": "0", "data_code": "data3_field_name", "data_name": "データ3 フィールド名", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data3_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択リスト", "can_calc": "0", "data_code": "data4_field_name", "data_name": "データ4 フィールド名", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data4_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択リスト", "can_calc": "0", "data_code": "data5_field_name", "data_name": "データ5 フィールド名", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data5_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択リスト", "can_calc": "0", "data_code": "data6_field_name", "data_name": "データ6 フィールド名", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data6_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択リスト", "can_calc": "0", "data_code": "data7_field_name", "data_name": "データ7 フィールド名", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data7_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択リスト", "can_calc": "0", "data_code": "data8_field_name", "data_name": "データ8 フィールド名", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data8_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択リスト", "can_calc": "0", "data_code": "data9_field_name", "data_name": "データ9 フィールド名", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data9_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択リスト", "can_calc": "0", "data_code": "data10_field_name", "data_name": "データ10 フィールド名", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data10_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択リスト", "can_calc": "0", "data_code": "data11_field_name", "data_name": "データ11 フィールド名", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data11_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択リスト", "can_calc": "0", "data_code": "data12_field_name", "data_name": "データ12 フィールド名", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data12_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択リスト", "can_calc": "0", "data_code": "data13_field_name", "data_name": "データ13 フィールド名", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data13_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択リスト", "can_calc": "0", "data_code": "data14_field_name", "data_name": "データ14 フィールド名", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data14_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択リスト", "can_calc": "0", "data_code": "data15_field_name", "data_name": "データ15 フィールド名", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data15_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択リスト", "can_calc": "0", "data_code": "data16_field_name", "data_name": "データ16 フィールド名", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data16_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択リスト", "can_calc": "0", "data_code": "data17_field_name", "data_name": "データ17 フィールド名", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data17_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択リスト", "can_calc": "0", "data_code": "data18_field_name", "data_name": "データ18 フィールド名", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data18_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択リスト", "can_calc": "0", "data_code": "data19_field_name", "data_name": "データ19 フィールド名", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data19_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択リスト", "can_calc": "0", "data_code": "data20_field_name", "data_name": "データ20 フィールド名", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data20_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択リスト", "can_calc": "0", "data_code": "data21_field_name", "data_name": "データ21 フィールド名", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data21_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択リスト", "can_calc": "0", "data_code": "data22_field_name", "data_name": "データ22 フィールド名", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data22_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択リスト", "can_calc": "0", "data_code": "data23_field_name", "data_name": "データ23 フィールド名", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data23_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択リスト", "can_calc": "0", "data_code": "data24_field_name", "data_name": "データ24 フィールド名", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data24_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択リスト", "can_calc": "0", "data_code": "data25_field_name", "data_name": "データ25 フィールド名", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data25_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択リスト", "can_calc": "0", "data_code": "data26_field_name", "data_name": "データ26 フィールド名", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data26_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択リスト", "can_calc": "0", "data_code": "data27_field_name", "data_name": "データ27 フィールド名", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data27_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択リスト", "can_calc": "0", "data_code": "data28_field_name", "data_name": "データ28 フィールド名", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data28_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択リスト", "can_calc": "0", "data_code": "data29_field_name", "data_name": "データ29 フィールド名", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data29_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択リスト", "can_calc": "0", "data_code": "data30_field_name", "data_name": "データ30 フィールド名", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data30_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "リストの項目", "can_calc": "0", "data_code": "data1_name", "data_name": "データ1 名前", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data1_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data1_score", "data_name": "データ1 スコア", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data1_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "リストの項目", "can_calc": "0", "data_code": "data2_name", "data_name": "データ2 名前", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data2_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data2_score", "data_name": "データ2 スコア", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data2_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "リストの項目", "can_calc": "0", "data_code": "data3_name", "data_name": "データ3 名前", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data3_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data3_score", "data_name": "データ3 スコア", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data3_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "リストの項目", "can_calc": "0", "data_code": "data4_name", "data_name": "データ4 名前", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data4_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data4_score", "data_name": "データ4 スコア", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data4_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "リストの項目", "can_calc": "0", "data_code": "data5_name", "data_name": "データ5 名前", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data5_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data5_score", "data_name": "データ5 スコア", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data5_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "リストの項目", "can_calc": "0", "data_code": "data6_name", "data_name": "データ6 名前", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data6_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data6_score", "data_name": "データ6 スコア", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data6_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "リストの項目", "can_calc": "0", "data_code": "data7_name", "data_name": "データ7 名前", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data7_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data7_score", "data_name": "データ7 スコア", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data7_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "リストの項目", "can_calc": "0", "data_code": "data8_name", "data_name": "データ8 名前", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data8_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data8_score", "data_name": "データ8 スコア", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data8_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "リストの項目", "can_calc": "0", "data_code": "data9_name", "data_name": "データ9 名前", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data9_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data9_score", "data_name": "データ9 スコア", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data9_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "リストの項目", "can_calc": "0", "data_code": "data10_name", "data_name": "データ10 名前", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data10_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data10_score", "data_name": "データ10 スコア", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data10_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "リストの項目", "can_calc": "0", "data_code": "data11_name", "data_name": "データ11 名前", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data11_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data11_score", "data_name": "データ11 スコア", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data11_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "リストの項目", "can_calc": "0", "data_code": "data12_name", "data_name": "データ12 名前", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data12_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data12_score", "data_name": "データ12 スコア", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data12_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "リストの項目", "can_calc": "0", "data_code": "data13_name", "data_name": "データ13 名前", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data13_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data13_score", "data_name": "データ13 スコア", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data13_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "リストの項目", "can_calc": "0", "data_code": "data14_name", "data_name": "データ14 名前", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data14_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data14_score", "data_name": "データ14 スコア", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data14_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "リストの項目", "can_calc": "0", "data_code": "data15_name", "data_name": "データ15 名前", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data15_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data15_score", "data_name": "データ15 スコア", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data15_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "リストの項目", "can_calc": "0", "data_code": "data16_name", "data_name": "データ16 名前", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data16_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data16_score", "data_name": "データ16 スコア", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data16_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "リストの項目", "can_calc": "0", "data_code": "data17_name", "data_name": "データ17 名前", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data17_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data17_score", "data_name": "データ17 スコア", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data17_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "リストの項目", "can_calc": "0", "data_code": "data18_name", "data_name": "データ18 名前", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data18_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data18_score", "data_name": "データ18 スコア", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data18_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "リストの項目", "can_calc": "0", "data_code": "data19_name", "data_name": "データ19 名前", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data19_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data19_score", "data_name": "データ19 スコア", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data19_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "リストの項目", "can_calc": "0", "data_code": "data20_name", "data_name": "データ20 名前", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data20_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data20_score", "data_name": "データ20 スコア", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data20_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "リストの項目", "can_calc": "0", "data_code": "data21_name", "data_name": "データ21 名前", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data21_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data21_score", "data_name": "データ21 スコア", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data21_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "リストの項目", "can_calc": "0", "data_code": "data22_name", "data_name": "データ22 名前", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data22_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data22_score", "data_name": "データ22 スコア", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data22_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "リストの項目", "can_calc": "0", "data_code": "data23_name", "data_name": "データ23 名前", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data23_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data23_score", "data_name": "データ23 スコア", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data23_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "リストの項目", "can_calc": "0", "data_code": "data24_name", "data_name": "データ24 名前", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data24_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data24_score", "data_name": "データ24 スコア", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data24_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "リストの項目", "can_calc": "0", "data_code": "data25_name", "data_name": "データ25 名前", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data25_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data25_score", "data_name": "データ25 スコア", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data25_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "リストの項目", "can_calc": "0", "data_code": "data26_name", "data_name": "データ26 名前", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data26_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data26_score", "data_name": "データ26 スコア", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data26_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "リストの項目", "can_calc": "0", "data_code": "data27_name", "data_name": "データ27 名前", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data27_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data27_score", "data_name": "データ27 スコア", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data27_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "リストの項目", "can_calc": "0", "data_code": "data28_name", "data_name": "データ28 名前", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data28_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data28_score", "data_name": "データ28 スコア", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data28_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "リストの項目", "can_calc": "0", "data_code": "data29_name", "data_name": "データ29 名前", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data29_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data29_score", "data_name": "データ29 スコア", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data29_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "リストの項目", "can_calc": "0", "data_code": "data30_name", "data_name": "データ30 名前", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data30_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data30_score", "data_name": "データ30 スコア", "data_type": "string", "conv_table": [], "data_class": "リスト", "field_name": "data30_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '観察記録 透析レポート リスト @ordNo 使用', '2020-03-27 23:59:59', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (66, 'with input_params_expand as
(
  select
    pat_event_cd
    ,json_idx
    ,input_param
  from
    pat_event
    cross join lateral jsonb_array_elements(input_params) with ordinality as tmp(input_param, json_idx)
  where
    is_del = ''0''
    and use_type = 2 and ord_no = @ordNo
)
, result_params_expand as
(
  select
    pat_event_cd
    ,json_idx
    ,result_param
  from
    pat_event
    cross join lateral jsonb_array_elements(result_params) with ordinality as tmp(result_param, json_idx)
  where
    is_del = ''0''
    and use_type = 2 and ord_no = @ordNo
)
, pe_basicinfo as
(
  select
    pat_event_cd
    ,event_start_date as event_date
    ,event_end_date
    ,category_name
    ,sub_category_name
    ,reg_staff_info->>''reg_staff_name'' as reg_staff_name
    ,reg_date
    ,up_staff_info->>''up_staff_name'' as up_staff_name
    ,up_date
  from
    pat_event
  where
    is_del = ''0''
    and use_type = 2 and ord_no = @ordNo
)
, pe_picked as
(
  select
    ipe.pat_event_cd
    ,ipe.json_idx
    ,input_param
    ,result_param
  from
    input_params_expand as ipe
    inner join result_params_expand as rpe
      on ipe.pat_event_cd = rpe.pat_event_cd and ipe.json_idx = rpe.json_idx
  where
    input_param->>''format_class'' = ''4''
)
, pe_array_agg as
(
  select
    pat_event_cd
    ,array_agg(input_param order by json_idx) as picked_input_params
    ,array_agg(result_param order by json_idx) as picked_result_params
  from
    pe_picked
  group by pat_event_cd
)

select
  pe_array_agg.pat_event_cd
  ,to_date(event_date, ''YYYYMMDD'') as event_date
  ,to_date(event_end_date, ''YYYYMMDD'') as event_end_date
  ,category_name
  ,sub_category_name
  ,reg_staff_name
  ,reg_date
  ,up_staff_name
  ,up_date

  ,picked_input_params[1]->>''field_name'' as data1_field_name
  ,picked_input_params[2]->>''field_name'' as data2_field_name
  ,picked_input_params[3]->>''field_name'' as data3_field_name
  ,picked_input_params[4]->>''field_name'' as data4_field_name
  ,picked_input_params[5]->>''field_name'' as data5_field_name
  ,picked_input_params[6]->>''field_name'' as data6_field_name
  ,picked_input_params[7]->>''field_name'' as data7_field_name
  ,picked_input_params[8]->>''field_name'' as data8_field_name
  ,picked_input_params[9]->>''field_name'' as data9_field_name
  ,picked_input_params[10]->>''field_name'' as data10_field_name
  ,picked_input_params[11]->>''field_name'' as data11_field_name
  ,picked_input_params[12]->>''field_name'' as data12_field_name
  ,picked_input_params[13]->>''field_name'' as data13_field_name
  ,picked_input_params[14]->>''field_name'' as data14_field_name
  ,picked_input_params[15]->>''field_name'' as data15_field_name
  ,picked_input_params[16]->>''field_name'' as data16_field_name
  ,picked_input_params[17]->>''field_name'' as data17_field_name
  ,picked_input_params[18]->>''field_name'' as data18_field_name
  ,picked_input_params[19]->>''field_name'' as data19_field_name
  ,picked_input_params[20]->>''field_name'' as data20_field_name
  ,picked_input_params[21]->>''field_name'' as data21_field_name
  ,picked_input_params[22]->>''field_name'' as data22_field_name
  ,picked_input_params[23]->>''field_name'' as data23_field_name
  ,picked_input_params[24]->>''field_name'' as data24_field_name
  ,picked_input_params[25]->>''field_name'' as data25_field_name
  ,picked_input_params[26]->>''field_name'' as data26_field_name
  ,picked_input_params[27]->>''field_name'' as data27_field_name
  ,picked_input_params[28]->>''field_name'' as data28_field_name
  ,picked_input_params[29]->>''field_name'' as data29_field_name
  ,picked_input_params[30]->>''field_name'' as data30_field_name

  ,picked_result_params[1]->''result_value''->>''name'' as data1_name
  ,picked_result_params[1]->''result_value''->>''score'' as data1_score
  ,picked_result_params[2]->''result_value''->>''name'' as data2_name
  ,picked_result_params[2]->''result_value''->>''score'' as data2_score
  ,picked_result_params[3]->''result_value''->>''name'' as data3_name
  ,picked_result_params[3]->''result_value''->>''score'' as data3_score
  ,picked_result_params[4]->''result_value''->>''name'' as data4_name
  ,picked_result_params[4]->''result_value''->>''score'' as data4_score
  ,picked_result_params[5]->''result_value''->>''name'' as data5_name
  ,picked_result_params[5]->''result_value''->>''score'' as data5_score
  ,picked_result_params[6]->''result_value''->>''name'' as data6_name
  ,picked_result_params[6]->''result_value''->>''score'' as data6_score
  ,picked_result_params[7]->''result_value''->>''name'' as data7_name
  ,picked_result_params[7]->''result_value''->>''score'' as data7_score
  ,picked_result_params[8]->''result_value''->>''name'' as data8_name
  ,picked_result_params[8]->''result_value''->>''score'' as data8_score
  ,picked_result_params[9]->''result_value''->>''name'' as data9_name
  ,picked_result_params[9]->''result_value''->>''score'' as data9_score
  ,picked_result_params[10]->''result_value''->>''name'' as data10_name
  ,picked_result_params[10]->''result_value''->>''score'' as data10_score
  ,picked_result_params[11]->''result_value''->>''name'' as data11_name
  ,picked_result_params[11]->''result_value''->>''score'' as data11_score
  ,picked_result_params[12]->''result_value''->>''name'' as data12_name
  ,picked_result_params[12]->''result_value''->>''score'' as data12_score
  ,picked_result_params[13]->''result_value''->>''name'' as data13_name
  ,picked_result_params[13]->''result_value''->>''score'' as data13_score
  ,picked_result_params[14]->''result_value''->>''name'' as data14_name
  ,picked_result_params[14]->''result_value''->>''score'' as data14_score
  ,picked_result_params[15]->''result_value''->>''name'' as data15_name
  ,picked_result_params[15]->''result_value''->>''score'' as data15_score
  ,picked_result_params[16]->''result_value''->>''name'' as data16_name
  ,picked_result_params[16]->''result_value''->>''score'' as data16_score
  ,picked_result_params[17]->''result_value''->>''name'' as data17_name
  ,picked_result_params[17]->''result_value''->>''score'' as data17_score
  ,picked_result_params[18]->''result_value''->>''name'' as data18_name
  ,picked_result_params[18]->''result_value''->>''score'' as data18_score
  ,picked_result_params[19]->''result_value''->>''name'' as data19_name
  ,picked_result_params[19]->''result_value''->>''score'' as data19_score
  ,picked_result_params[20]->''result_value''->>''name'' as data20_name
  ,picked_result_params[20]->''result_value''->>''score'' as data20_score
  ,picked_result_params[21]->''result_value''->>''name'' as data21_name
  ,picked_result_params[21]->''result_value''->>''score'' as data21_score
  ,picked_result_params[22]->''result_value''->>''name'' as data22_name
  ,picked_result_params[22]->''result_value''->>''score'' as data22_score
  ,picked_result_params[23]->''result_value''->>''name'' as data23_name
  ,picked_result_params[23]->''result_value''->>''score'' as data23_score
  ,picked_result_params[24]->''result_value''->>''name'' as data24_name
  ,picked_result_params[24]->''result_value''->>''score'' as data24_score
  ,picked_result_params[25]->''result_value''->>''name'' as data25_name
  ,picked_result_params[25]->''result_value''->>''score'' as data25_score
  ,picked_result_params[26]->''result_value''->>''name'' as data26_name
  ,picked_result_params[26]->''result_value''->>''score'' as data26_score
  ,picked_result_params[27]->''result_value''->>''name'' as data27_name
  ,picked_result_params[27]->''result_value''->>''score'' as data27_score
  ,picked_result_params[28]->''result_value''->>''name'' as data28_name
  ,picked_result_params[28]->''result_value''->>''score'' as data28_score
  ,picked_result_params[29]->''result_value''->>''name'' as data29_name
  ,picked_result_params[29]->''result_value''->>''score'' as data29_score
  ,picked_result_params[30]->''result_value''->>''name'' as data30_name
  ,picked_result_params[30]->''result_value''->>''score'' as data30_score

from
  pe_array_agg
  inner join pe_basicinfo on pe_array_agg.pat_event_cd = pe_basicinfo.pat_event_cd
;', 2, '[{"preview": "2020/03/26", "can_calc": "0", "data_code": "event_date", "data_name": "イベント開始日", "data_type": "DateTime", "conv_table": [], "data_class": "ラジオボタン", "field_name": "event_date", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "event_end_date", "data_name": "イベント終了日", "data_type": "DateTime", "conv_table": [], "data_class": "ラジオボタン", "field_name": "event_end_date", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "観察記録", "can_calc": "0", "data_code": "category_name", "data_name": "カテゴリ名", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "category_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "SOAP", "can_calc": "0", "data_code": "sub_category_name", "data_name": "サブカテゴリ名", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "sub_category_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師１", "can_calc": "0", "data_code": "reg_staff_name", "data_name": "起票者", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "reg_staff_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/25", "can_calc": "0", "data_code": "reg_date", "data_name": "起票日", "data_type": "DateTime", "conv_table": [], "data_class": "ラジオボタン", "field_name": "reg_date", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師２", "can_calc": "0", "data_code": "up_staff_name", "data_name": "最終編集者", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "up_staff_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "up_date", "data_name": "最終編集日", "data_type": "DateTime", "conv_table": [], "data_class": "ラジオボタン", "field_name": "up_date", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data1_field_name", "data_name": "データ1 フィールド名", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data1_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data2_field_name", "data_name": "データ2 フィールド名", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data2_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data3_field_name", "data_name": "データ3 フィールド名", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data3_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data4_field_name", "data_name": "データ4 フィールド名", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data4_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data5_field_name", "data_name": "データ5 フィールド名", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data5_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data6_field_name", "data_name": "データ6 フィールド名", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data6_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data7_field_name", "data_name": "データ7 フィールド名", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data7_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data8_field_name", "data_name": "データ8 フィールド名", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data8_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data9_field_name", "data_name": "データ9 フィールド名", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data9_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data10_field_name", "data_name": "データ10 フィールド名", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data10_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data11_field_name", "data_name": "データ11 フィールド名", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data11_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data12_field_name", "data_name": "データ12 フィールド名", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data12_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data13_field_name", "data_name": "データ13 フィールド名", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data13_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data14_field_name", "data_name": "データ14 フィールド名", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data14_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data15_field_name", "data_name": "データ15 フィールド名", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data15_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data16_field_name", "data_name": "データ16 フィールド名", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data16_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data17_field_name", "data_name": "データ17 フィールド名", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data17_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data18_field_name", "data_name": "データ18 フィールド名", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data18_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data19_field_name", "data_name": "データ19 フィールド名", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data19_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data20_field_name", "data_name": "データ20 フィールド名", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data20_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data21_field_name", "data_name": "データ21 フィールド名", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data21_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data22_field_name", "data_name": "データ22 フィールド名", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data22_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data23_field_name", "data_name": "データ23 フィールド名", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data23_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data24_field_name", "data_name": "データ24 フィールド名", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data24_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data25_field_name", "data_name": "データ25 フィールド名", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data25_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data26_field_name", "data_name": "データ26 フィールド名", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data26_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data27_field_name", "data_name": "データ27 フィールド名", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data27_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data28_field_name", "data_name": "データ28 フィールド名", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data28_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data29_field_name", "data_name": "データ29 フィールド名", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data29_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data30_field_name", "data_name": "データ30 フィールド名", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data30_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ラジオボタンの項目", "can_calc": "0", "data_code": "data1_name", "data_name": "データ1 名前", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data1_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data1_score", "data_name": "データ1 スコア", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data1_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ラジオボタンの項目", "can_calc": "0", "data_code": "data2_name", "data_name": "データ2 名前", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data2_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data2_score", "data_name": "データ2 スコア", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data2_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ラジオボタンの項目", "can_calc": "0", "data_code": "data3_name", "data_name": "データ3 名前", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data3_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data3_score", "data_name": "データ3 スコア", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data3_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ラジオボタンの項目", "can_calc": "0", "data_code": "data4_name", "data_name": "データ4 名前", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data4_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data4_score", "data_name": "データ4 スコア", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data4_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ラジオボタンの項目", "can_calc": "0", "data_code": "data5_name", "data_name": "データ5 名前", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data5_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data5_score", "data_name": "データ5 スコア", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data5_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ラジオボタンの項目", "can_calc": "0", "data_code": "data6_name", "data_name": "データ6 名前", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data6_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data6_score", "data_name": "データ6 スコア", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data6_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ラジオボタンの項目", "can_calc": "0", "data_code": "data7_name", "data_name": "データ7 名前", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data7_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data7_score", "data_name": "データ7 スコア", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data7_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ラジオボタンの項目", "can_calc": "0", "data_code": "data8_name", "data_name": "データ8 名前", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data8_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data8_score", "data_name": "データ8 スコア", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data8_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ラジオボタンの項目", "can_calc": "0", "data_code": "data9_name", "data_name": "データ9 名前", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data9_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data9_score", "data_name": "データ9 スコア", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data9_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ラジオボタンの項目", "can_calc": "0", "data_code": "data10_name", "data_name": "データ10 名前", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data10_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data10_score", "data_name": "データ10 スコア", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data10_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ラジオボタンの項目", "can_calc": "0", "data_code": "data11_name", "data_name": "データ11 名前", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data11_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data11_score", "data_name": "データ11 スコア", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data11_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ラジオボタンの項目", "can_calc": "0", "data_code": "data12_name", "data_name": "データ12 名前", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data12_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data12_score", "data_name": "データ12 スコア", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data12_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ラジオボタンの項目", "can_calc": "0", "data_code": "data13_name", "data_name": "データ13 名前", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data13_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data13_score", "data_name": "データ13 スコア", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data13_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ラジオボタンの項目", "can_calc": "0", "data_code": "data14_name", "data_name": "データ14 名前", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data14_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data14_score", "data_name": "データ14 スコア", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data14_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ラジオボタンの項目", "can_calc": "0", "data_code": "data15_name", "data_name": "データ15 名前", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data15_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data15_score", "data_name": "データ15 スコア", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data15_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ラジオボタンの項目", "can_calc": "0", "data_code": "data16_name", "data_name": "データ16 名前", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data16_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data16_score", "data_name": "データ16 スコア", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data16_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ラジオボタンの項目", "can_calc": "0", "data_code": "data17_name", "data_name": "データ17 名前", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data17_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data17_score", "data_name": "データ17 スコア", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data17_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ラジオボタンの項目", "can_calc": "0", "data_code": "data18_name", "data_name": "データ18 名前", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data18_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data18_score", "data_name": "データ18 スコア", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data18_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ラジオボタンの項目", "can_calc": "0", "data_code": "data19_name", "data_name": "データ19 名前", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data19_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data19_score", "data_name": "データ19 スコア", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data19_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ラジオボタンの項目", "can_calc": "0", "data_code": "data20_name", "data_name": "データ20 名前", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data20_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data20_score", "data_name": "データ20 スコア", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data20_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ラジオボタンの項目", "can_calc": "0", "data_code": "data21_name", "data_name": "データ21 名前", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data21_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data21_score", "data_name": "データ21 スコア", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data21_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ラジオボタンの項目", "can_calc": "0", "data_code": "data22_name", "data_name": "データ22 名前", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data22_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data22_score", "data_name": "データ22 スコア", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data22_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ラジオボタンの項目", "can_calc": "0", "data_code": "data23_name", "data_name": "データ23 名前", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data23_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data23_score", "data_name": "データ23 スコア", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data23_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ラジオボタンの項目", "can_calc": "0", "data_code": "data24_name", "data_name": "データ24 名前", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data24_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data24_score", "data_name": "データ24 スコア", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data24_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ラジオボタンの項目", "can_calc": "0", "data_code": "data25_name", "data_name": "データ25 名前", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data25_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data25_score", "data_name": "データ25 スコア", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data25_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ラジオボタンの項目", "can_calc": "0", "data_code": "data26_name", "data_name": "データ26 名前", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data26_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data26_score", "data_name": "データ26 スコア", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data26_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ラジオボタンの項目", "can_calc": "0", "data_code": "data27_name", "data_name": "データ27 名前", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data27_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data27_score", "data_name": "データ27 スコア", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data27_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ラジオボタンの項目", "can_calc": "0", "data_code": "data28_name", "data_name": "データ28 名前", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data28_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data28_score", "data_name": "データ28 スコア", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data28_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ラジオボタンの項目", "can_calc": "0", "data_code": "data29_name", "data_name": "データ29 名前", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data29_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data29_score", "data_name": "データ29 スコア", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data29_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ラジオボタンの項目", "can_calc": "0", "data_code": "data30_name", "data_name": "データ30 名前", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data30_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data30_score", "data_name": "データ30 スコア", "data_type": "string", "conv_table": [], "data_class": "ラジオボタン", "field_name": "data30_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '観察記録 透析レポート ラジオボタン @ordNo 使用', '2020-03-27 23:59:59', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (70, 'with input_params_expand as
(
  select
    pat_event_cd
    ,json_idx
    ,input_param
  from
    pat_event
    cross join lateral jsonb_array_elements(input_params) with ordinality as tmp(input_param, json_idx)
  where
    is_del = ''0''
    and use_type = 2 and ord_no = @ordNo
)
, result_params_expand as
(
  select
    pat_event_cd
    ,json_idx
    ,result_param
  from
    pat_event
    cross join lateral jsonb_array_elements(result_params) with ordinality as tmp(result_param, json_idx)
  where
    is_del = ''0''
    and use_type = 2 and ord_no = @ordNo
)
, pe_basicinfo as
(
  select
    pat_event_cd
    ,event_start_date as event_date
    ,event_end_date
    ,category_name
    ,sub_category_name
    ,reg_staff_info->>''reg_staff_name'' as reg_staff_name
    ,reg_date
    ,up_staff_info->>''up_staff_name'' as up_staff_name
    ,up_date
  from
    pat_event
  where
    is_del = ''0''
    and use_type = 2 and ord_no = @ordNo
)
, pe_picked as
(
  select
    ipe.pat_event_cd
    ,ipe.json_idx
    ,input_param
    ,result_param
  from
    input_params_expand as ipe
    inner join result_params_expand as rpe
      on ipe.pat_event_cd = rpe.pat_event_cd and ipe.json_idx = rpe.json_idx
  where
    input_param->>''format_class'' = ''6''
)
, pe_array_agg as
(
  select
    pat_event_cd
    ,array_agg(input_param order by json_idx) as picked_input_params
    ,array_agg(result_param order by json_idx) as picked_result_params
  from
    pe_picked
  group by pat_event_cd
)

select
  pe_array_agg.pat_event_cd
  ,to_date(event_date, ''YYYYMMDD'') as event_date
  ,to_date(event_end_date, ''YYYYMMDD'') as event_end_date
  ,category_name
  ,sub_category_name
  ,reg_staff_name
  ,reg_date
  ,up_staff_name
  ,up_date

  ,picked_input_params[1]->>''field_name'' as data1_field_name
  ,picked_input_params[2]->>''field_name'' as data2_field_name
  ,picked_input_params[3]->>''field_name'' as data3_field_name
  ,picked_input_params[4]->>''field_name'' as data4_field_name
  ,picked_input_params[5]->>''field_name'' as data5_field_name
  ,picked_input_params[6]->>''field_name'' as data6_field_name
  ,picked_input_params[7]->>''field_name'' as data7_field_name
  ,picked_input_params[8]->>''field_name'' as data8_field_name
  ,picked_input_params[9]->>''field_name'' as data9_field_name
  ,picked_input_params[10]->>''field_name'' as data10_field_name
  ,picked_input_params[11]->>''field_name'' as data11_field_name
  ,picked_input_params[12]->>''field_name'' as data12_field_name
  ,picked_input_params[13]->>''field_name'' as data13_field_name
  ,picked_input_params[14]->>''field_name'' as data14_field_name
  ,picked_input_params[15]->>''field_name'' as data15_field_name
  ,picked_input_params[16]->>''field_name'' as data16_field_name
  ,picked_input_params[17]->>''field_name'' as data17_field_name
  ,picked_input_params[18]->>''field_name'' as data18_field_name
  ,picked_input_params[19]->>''field_name'' as data19_field_name
  ,picked_input_params[20]->>''field_name'' as data20_field_name
  ,picked_input_params[21]->>''field_name'' as data21_field_name
  ,picked_input_params[22]->>''field_name'' as data22_field_name
  ,picked_input_params[23]->>''field_name'' as data23_field_name
  ,picked_input_params[24]->>''field_name'' as data24_field_name
  ,picked_input_params[25]->>''field_name'' as data25_field_name
  ,picked_input_params[26]->>''field_name'' as data26_field_name
  ,picked_input_params[27]->>''field_name'' as data27_field_name
  ,picked_input_params[28]->>''field_name'' as data28_field_name
  ,picked_input_params[29]->>''field_name'' as data29_field_name
  ,picked_input_params[30]->>''field_name'' as data30_field_name

  ,trim
  (trailing '', '' from
    coalesce((picked_result_params[1]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->19)->>''name'', '''')
  ) as data1_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[1]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->19)->>''score'', '''')
  ) as data1_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[2]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->19)->>''name'', '''')
  ) as data2_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[2]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->19)->>''score'', '''')
  ) as data2_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[3]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->19)->>''name'', '''')
  ) as data3_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[3]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->19)->>''score'', '''')
  ) as data3_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[4]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->19)->>''name'', '''')
  ) as data4_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[4]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->19)->>''score'', '''')
  ) as data4_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[5]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->19)->>''name'', '''')
  ) as data5_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[5]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->19)->>''score'', '''')
  ) as data5_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[6]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->19)->>''name'', '''')
  ) as data6_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[6]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->19)->>''score'', '''')
  ) as data6_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[7]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->19)->>''name'', '''')
  ) as data7_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[7]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->19)->>''score'', '''')
  ) as data7_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[8]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->19)->>''name'', '''')
  ) as data8_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[8]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->19)->>''score'', '''')
  ) as data8_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[9]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->19)->>''name'', '''')
  ) as data9_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[9]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->19)->>''score'', '''')
  ) as data9_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[10]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->19)->>''name'', '''')
  ) as data10_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[10]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->19)->>''score'', '''')
  ) as data10_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[11]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->19)->>''name'', '''')
  ) as data11_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[11]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->19)->>''score'', '''')
  ) as data11_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[12]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->19)->>''name'', '''')
  ) as data12_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[12]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->19)->>''score'', '''')
  ) as data12_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[13]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->19)->>''name'', '''')
  ) as data13_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[13]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->19)->>''score'', '''')
  ) as data13_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[14]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->19)->>''name'', '''')
  ) as data14_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[14]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->19)->>''score'', '''')
  ) as data14_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[15]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->19)->>''name'', '''')
  ) as data15_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[15]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->19)->>''score'', '''')
  ) as data15_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[16]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->19)->>''name'', '''')
  ) as data16_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[16]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->19)->>''score'', '''')
  ) as data16_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[17]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->19)->>''name'', '''')
  ) as data17_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[17]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->19)->>''score'', '''')
  ) as data17_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[18]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->19)->>''name'', '''')
  ) as data18_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[18]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->19)->>''score'', '''')
  ) as data18_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[19]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->19)->>''name'', '''')
  ) as data19_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[19]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[19]->''result_value''->19)->>''score'', '''')
  ) as data19_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[20]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->19)->>''name'', '''')
  ) as data20_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[20]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[20]->''result_value''->19)->>''score'', '''')
  ) as data20_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[21]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->19)->>''name'', '''')
  ) as data21_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[21]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[21]->''result_value''->19)->>''score'', '''')
  ) as data21_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[22]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->19)->>''name'', '''')
  ) as data22_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[22]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[22]->''result_value''->19)->>''score'', '''')
  ) as data22_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[23]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->19)->>''name'', '''')
  ) as data23_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[23]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[23]->''result_value''->19)->>''score'', '''')
  ) as data23_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[24]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->19)->>''name'', '''')
  ) as data24_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[24]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[24]->''result_value''->19)->>''score'', '''')
  ) as data24_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[25]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->19)->>''name'', '''')
  ) as data25_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[25]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[25]->''result_value''->19)->>''score'', '''')
  ) as data25_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[26]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->19)->>''name'', '''')
  ) as data26_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[26]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[26]->''result_value''->19)->>''score'', '''')
  ) as data26_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[27]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->19)->>''name'', '''')
  ) as data27_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[27]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[27]->''result_value''->19)->>''score'', '''')
  ) as data27_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[28]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->19)->>''name'', '''')
  ) as data28_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[28]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[28]->''result_value''->19)->>''score'', '''')
  ) as data28_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[29]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->19)->>''name'', '''')
  ) as data29_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[29]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[29]->''result_value''->19)->>''score'', '''')
  ) as data29_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[30]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->19)->>''name'', '''')
  ) as data30_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[30]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[30]->''result_value''->19)->>''score'', '''')
  ) as data30_score

from
  pe_array_agg
  inner join pe_basicinfo on pe_array_agg.pat_event_cd = pe_basicinfo.pat_event_cd
;', 2, '[{"preview": "2020/03/26", "can_calc": "0", "data_code": "event_date", "data_name": "イベント開始日", "data_type": "DateTime", "conv_table": [], "data_class": "チェック", "field_name": "event_date", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "event_end_date", "data_name": "イベント終了日", "data_type": "DateTime", "conv_table": [], "data_class": "チェック", "field_name": "event_end_date", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "観察記録", "can_calc": "0", "data_code": "category_name", "data_name": "カテゴリ名", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "category_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "SOAP", "can_calc": "0", "data_code": "sub_category_name", "data_name": "サブカテゴリ名", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "sub_category_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師１", "can_calc": "0", "data_code": "reg_staff_name", "data_name": "起票者", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "reg_staff_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/25", "can_calc": "0", "data_code": "reg_date", "data_name": "起票日", "data_type": "DateTime", "conv_table": [], "data_class": "チェック", "field_name": "reg_date", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師２", "can_calc": "0", "data_code": "up_staff_name", "data_name": "最終編集者", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "up_staff_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "up_date", "data_name": "最終編集日", "data_type": "DateTime", "conv_table": [], "data_class": "チェック", "field_name": "up_date", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data1_field_name", "data_name": "データ1 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data1_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data2_field_name", "data_name": "データ2 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data2_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data3_field_name", "data_name": "データ3 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data3_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data4_field_name", "data_name": "データ4 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data4_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data5_field_name", "data_name": "データ5 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data5_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data6_field_name", "data_name": "データ6 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data6_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data7_field_name", "data_name": "データ7 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data7_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data8_field_name", "data_name": "データ8 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data8_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data9_field_name", "data_name": "データ9 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data9_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data10_field_name", "data_name": "データ10 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data10_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data11_field_name", "data_name": "データ11 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data11_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data12_field_name", "data_name": "データ12 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data12_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data13_field_name", "data_name": "データ13 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data13_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data14_field_name", "data_name": "データ14 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data14_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data15_field_name", "data_name": "データ15 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data15_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data16_field_name", "data_name": "データ16 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data16_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data17_field_name", "data_name": "データ17 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data17_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data18_field_name", "data_name": "データ18 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data18_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data19_field_name", "data_name": "データ19 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data19_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data20_field_name", "data_name": "データ20 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data20_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data21_field_name", "data_name": "データ21 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data21_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data22_field_name", "data_name": "データ22 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data22_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data23_field_name", "data_name": "データ23 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data23_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data24_field_name", "data_name": "データ24 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data24_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data25_field_name", "data_name": "データ25 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data25_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data26_field_name", "data_name": "データ26 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data26_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data27_field_name", "data_name": "データ27 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data27_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data28_field_name", "data_name": "データ28 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data28_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data29_field_name", "data_name": "データ29 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data29_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェック内容", "can_calc": "0", "data_code": "data30_field_name", "data_name": "データ30 フィールド名", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data30_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data1_name", "data_name": "データ1 名前", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data1_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data1_score", "data_name": "データ1 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data1_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data2_name", "data_name": "データ2 名前", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data2_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data2_score", "data_name": "データ2 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data2_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data3_name", "data_name": "データ3 名前", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data3_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data3_score", "data_name": "データ3 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data3_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data4_name", "data_name": "データ4 名前", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data4_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data4_score", "data_name": "データ4 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data4_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data5_name", "data_name": "データ5 名前", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data5_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data5_score", "data_name": "データ5 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data5_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data6_name", "data_name": "データ6 名前", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data6_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data6_score", "data_name": "データ6 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data6_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data7_name", "data_name": "データ7 名前", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data7_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data7_score", "data_name": "データ7 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data7_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data8_name", "data_name": "データ8 名前", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data8_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data8_score", "data_name": "データ8 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data8_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data9_name", "data_name": "データ9 名前", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data9_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data9_score", "data_name": "データ9 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data9_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data10_name", "data_name": "データ10 名前", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data10_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data10_score", "data_name": "データ10 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data10_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data11_name", "data_name": "データ11 名前", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data11_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data11_score", "data_name": "データ11 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data11_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data12_name", "data_name": "データ12 名前", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data12_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data12_score", "data_name": "データ12 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data12_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data13_name", "data_name": "データ13 名前", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data13_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data13_score", "data_name": "データ13 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data13_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data14_name", "data_name": "データ14 名前", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data14_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data14_score", "data_name": "データ14 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data14_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data15_name", "data_name": "データ15 名前", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data15_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data15_score", "data_name": "データ15 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data15_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data16_name", "data_name": "データ16 名前", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data16_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data16_score", "data_name": "データ16 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data16_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data17_name", "data_name": "データ17 名前", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data17_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data17_score", "data_name": "データ17 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data17_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data18_name", "data_name": "データ18 名前", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data18_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data18_score", "data_name": "データ18 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data18_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data19_name", "data_name": "データ19 名前", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data19_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data19_score", "data_name": "データ19 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data19_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data20_name", "data_name": "データ20 名前", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data20_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data20_score", "data_name": "データ20 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data20_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data21_name", "data_name": "データ21 名前", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data21_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data21_score", "data_name": "データ21 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data21_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data22_name", "data_name": "データ22 名前", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data22_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data22_score", "data_name": "データ22 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data22_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data23_name", "data_name": "データ23 名前", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data23_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data23_score", "data_name": "データ23 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data23_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data24_name", "data_name": "データ24 名前", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data24_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data24_score", "data_name": "データ24 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data24_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data25_name", "data_name": "データ25 名前", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data25_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data25_score", "data_name": "データ25 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data25_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data26_name", "data_name": "データ26 名前", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data26_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data26_score", "data_name": "データ26 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data26_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data27_name", "data_name": "データ27 名前", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data27_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data27_score", "data_name": "データ27 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data27_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data28_name", "data_name": "データ28 名前", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data28_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data28_score", "data_name": "データ28 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data28_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data29_name", "data_name": "データ29 名前", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data29_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data29_score", "data_name": "データ29 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data29_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "チェックの項目1, チェックの項目3", "can_calc": "0", "data_code": "data30_name", "data_name": "データ30 名前", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data30_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data30_score", "data_name": "データ30 スコア", "data_type": "string", "conv_table": [], "data_class": "チェック", "field_name": "data30_score", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '観察記録 透析レポート チェック @ordNo 使用', '2020-03-27 23:59:59', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (72, 'with input_params_expand as
(
  select
    pat_event_cd
    ,json_idx
    ,input_param
  from
    pat_event
    cross join lateral jsonb_array_elements(input_params) with ordinality as tmp(input_param, json_idx)
  where
    is_del = ''0''
    and use_type = 2 and ord_no = @ordNo
)
, result_params_expand as
(
  select
    pat_event_cd
    ,json_idx
    ,result_param
  from
    pat_event
    cross join lateral jsonb_array_elements(result_params) with ordinality as tmp(result_param, json_idx)
  where
    is_del = ''0''
    and use_type = 2 and ord_no = @ordNo
)
, pe_basicinfo as
(
  select
    pat_event_cd
    ,event_start_date as event_date
    ,event_end_date
    ,category_name
    ,sub_category_name
    ,reg_staff_info->>''reg_staff_name'' as reg_staff_name
    ,reg_date
    ,up_staff_info->>''up_staff_name'' as up_staff_name
    ,up_date
  from
    pat_event
  where
    is_del = ''0''
    and use_type = 2 and ord_no = @ordNo
)
, pe_picked as
(
  select
    ipe.pat_event_cd
    ,ipe.json_idx
    ,input_param
    ,result_param
  from
    input_params_expand as ipe
    inner join result_params_expand as rpe
      on ipe.pat_event_cd = rpe.pat_event_cd and ipe.json_idx = rpe.json_idx
  where
    input_param->>''format_class'' = ''7''
)
, pe_array_agg as
(
  select
    pat_event_cd
    ,array_agg(input_param order by json_idx) as picked_input_params
    ,array_agg(result_param order by json_idx) as picked_result_params
  from
    pe_picked
  group by pat_event_cd
)

select
  pe_array_agg.pat_event_cd
  ,to_date(event_date, ''YYYYMMDD'') as event_date
  ,to_date(event_end_date, ''YYYYMMDD'') as event_end_date
  ,category_name
  ,sub_category_name
  ,reg_staff_name
  ,reg_date
  ,up_staff_name
  ,up_date

  ,picked_input_params[1]->>''field_name'' as data1_field_name
  ,picked_input_params[2]->>''field_name'' as data2_field_name
  ,picked_input_params[3]->>''field_name'' as data3_field_name
  ,picked_input_params[4]->>''field_name'' as data4_field_name
  ,picked_input_params[5]->>''field_name'' as data5_field_name

  ,picked_result_params[1]->''result_value''->0->>''file_name'' as data1_file_name1
  ,picked_result_params[1]->''result_value''->0->>''file_path'' as data1_file_path1
  ,picked_result_params[1]->''result_value''->1->>''file_name'' as data1_file_name2
  ,picked_result_params[1]->''result_value''->1->>''file_path'' as data1_file_path2
  ,picked_result_params[1]->''result_value''->2->>''file_name'' as data1_file_name3
  ,picked_result_params[1]->''result_value''->2->>''file_path'' as data1_file_path3
  ,picked_result_params[1]->''result_value''->3->>''file_name'' as data1_file_name4
  ,picked_result_params[1]->''result_value''->3->>''file_path'' as data1_file_path4
  ,picked_result_params[1]->''result_value''->4->>''file_name'' as data1_file_name5
  ,picked_result_params[1]->''result_value''->4->>''file_path'' as data1_file_path5
  ,picked_result_params[1]->''result_value''->5->>''file_name'' as data1_file_name6
  ,picked_result_params[1]->''result_value''->5->>''file_path'' as data1_file_path6
  ,picked_result_params[1]->''result_value''->6->>''file_name'' as data1_file_name7
  ,picked_result_params[1]->''result_value''->6->>''file_path'' as data1_file_path7
  ,picked_result_params[1]->''result_value''->7->>''file_name'' as data1_file_name8
  ,picked_result_params[1]->''result_value''->7->>''file_path'' as data1_file_path8
  ,picked_result_params[1]->''result_value''->8->>''file_name'' as data1_file_name9
  ,picked_result_params[1]->''result_value''->8->>''file_path'' as data1_file_path9
  ,picked_result_params[1]->''result_value''->9->>''file_name'' as data1_file_name10
  ,picked_result_params[1]->''result_value''->9->>''file_path'' as data1_file_path10

  ,picked_result_params[2]->''result_value''->0->>''file_name'' as data2_file_name1
  ,picked_result_params[2]->''result_value''->0->>''file_path'' as data2_file_path1
  ,picked_result_params[2]->''result_value''->1->>''file_name'' as data2_file_name2
  ,picked_result_params[2]->''result_value''->1->>''file_path'' as data2_file_path2
  ,picked_result_params[2]->''result_value''->2->>''file_name'' as data2_file_name3
  ,picked_result_params[2]->''result_value''->2->>''file_path'' as data2_file_path3
  ,picked_result_params[2]->''result_value''->3->>''file_name'' as data2_file_name4
  ,picked_result_params[2]->''result_value''->3->>''file_path'' as data2_file_path4
  ,picked_result_params[2]->''result_value''->4->>''file_name'' as data2_file_name5
  ,picked_result_params[2]->''result_value''->4->>''file_path'' as data2_file_path5
  ,picked_result_params[2]->''result_value''->5->>''file_name'' as data2_file_name6
  ,picked_result_params[2]->''result_value''->5->>''file_path'' as data2_file_path6
  ,picked_result_params[2]->''result_value''->6->>''file_name'' as data2_file_name7
  ,picked_result_params[2]->''result_value''->6->>''file_path'' as data2_file_path7
  ,picked_result_params[2]->''result_value''->7->>''file_name'' as data2_file_name8
  ,picked_result_params[2]->''result_value''->7->>''file_path'' as data2_file_path8
  ,picked_result_params[2]->''result_value''->8->>''file_name'' as data2_file_name9
  ,picked_result_params[2]->''result_value''->8->>''file_path'' as data2_file_path9
  ,picked_result_params[2]->''result_value''->9->>''file_name'' as data2_file_name10
  ,picked_result_params[2]->''result_value''->9->>''file_path'' as data2_file_path10

  ,picked_result_params[3]->''result_value''->0->>''file_name'' as data3_file_name1
  ,picked_result_params[3]->''result_value''->0->>''file_path'' as data3_file_path1
  ,picked_result_params[3]->''result_value''->1->>''file_name'' as data3_file_name2
  ,picked_result_params[3]->''result_value''->1->>''file_path'' as data3_file_path2
  ,picked_result_params[3]->''result_value''->2->>''file_name'' as data3_file_name3
  ,picked_result_params[3]->''result_value''->2->>''file_path'' as data3_file_path3
  ,picked_result_params[3]->''result_value''->3->>''file_name'' as data3_file_name4
  ,picked_result_params[3]->''result_value''->3->>''file_path'' as data3_file_path4
  ,picked_result_params[3]->''result_value''->4->>''file_name'' as data3_file_name5
  ,picked_result_params[3]->''result_value''->4->>''file_path'' as data3_file_path5
  ,picked_result_params[3]->''result_value''->5->>''file_name'' as data3_file_name6
  ,picked_result_params[3]->''result_value''->5->>''file_path'' as data3_file_path6
  ,picked_result_params[3]->''result_value''->6->>''file_name'' as data3_file_name7
  ,picked_result_params[3]->''result_value''->6->>''file_path'' as data3_file_path7
  ,picked_result_params[3]->''result_value''->7->>''file_name'' as data3_file_name8
  ,picked_result_params[3]->''result_value''->7->>''file_path'' as data3_file_path8
  ,picked_result_params[3]->''result_value''->8->>''file_name'' as data3_file_name9
  ,picked_result_params[3]->''result_value''->8->>''file_path'' as data3_file_path9
  ,picked_result_params[3]->''result_value''->9->>''file_name'' as data3_file_name10
  ,picked_result_params[3]->''result_value''->9->>''file_path'' as data3_file_path10

  ,picked_result_params[4]->''result_value''->0->>''file_name'' as data4_file_name1
  ,picked_result_params[4]->''result_value''->0->>''file_path'' as data4_file_path1
  ,picked_result_params[4]->''result_value''->1->>''file_name'' as data4_file_name2
  ,picked_result_params[4]->''result_value''->1->>''file_path'' as data4_file_path2
  ,picked_result_params[4]->''result_value''->2->>''file_name'' as data4_file_name3
  ,picked_result_params[4]->''result_value''->2->>''file_path'' as data4_file_path3
  ,picked_result_params[4]->''result_value''->3->>''file_name'' as data4_file_name4
  ,picked_result_params[4]->''result_value''->3->>''file_path'' as data4_file_path4
  ,picked_result_params[4]->''result_value''->4->>''file_name'' as data4_file_name5
  ,picked_result_params[4]->''result_value''->4->>''file_path'' as data4_file_path5
  ,picked_result_params[4]->''result_value''->5->>''file_name'' as data4_file_name6
  ,picked_result_params[4]->''result_value''->5->>''file_path'' as data4_file_path6
  ,picked_result_params[4]->''result_value''->6->>''file_name'' as data4_file_name7
  ,picked_result_params[4]->''result_value''->6->>''file_path'' as data4_file_path7
  ,picked_result_params[4]->''result_value''->7->>''file_name'' as data4_file_name8
  ,picked_result_params[4]->''result_value''->7->>''file_path'' as data4_file_path8
  ,picked_result_params[4]->''result_value''->8->>''file_name'' as data4_file_name9
  ,picked_result_params[4]->''result_value''->8->>''file_path'' as data4_file_path9
  ,picked_result_params[4]->''result_value''->9->>''file_name'' as data4_file_name10
  ,picked_result_params[4]->''result_value''->9->>''file_path'' as data4_file_path10

  ,picked_result_params[5]->''result_value''->0->>''file_name'' as data5_file_name1
  ,picked_result_params[5]->''result_value''->0->>''file_path'' as data5_file_path1
  ,picked_result_params[5]->''result_value''->1->>''file_name'' as data5_file_name2
  ,picked_result_params[5]->''result_value''->1->>''file_path'' as data5_file_path2
  ,picked_result_params[5]->''result_value''->2->>''file_name'' as data5_file_name3
  ,picked_result_params[5]->''result_value''->2->>''file_path'' as data5_file_path3
  ,picked_result_params[5]->''result_value''->3->>''file_name'' as data5_file_name4
  ,picked_result_params[5]->''result_value''->3->>''file_path'' as data5_file_path4
  ,picked_result_params[5]->''result_value''->4->>''file_name'' as data5_file_name5
  ,picked_result_params[5]->''result_value''->4->>''file_path'' as data5_file_path5
  ,picked_result_params[5]->''result_value''->5->>''file_name'' as data5_file_name6
  ,picked_result_params[5]->''result_value''->5->>''file_path'' as data5_file_path6
  ,picked_result_params[5]->''result_value''->6->>''file_name'' as data5_file_name7
  ,picked_result_params[5]->''result_value''->6->>''file_path'' as data5_file_path7
  ,picked_result_params[5]->''result_value''->7->>''file_name'' as data5_file_name8
  ,picked_result_params[5]->''result_value''->7->>''file_path'' as data5_file_path8
  ,picked_result_params[5]->''result_value''->8->>''file_name'' as data5_file_name9
  ,picked_result_params[5]->''result_value''->8->>''file_path'' as data5_file_path9
  ,picked_result_params[5]->''result_value''->9->>''file_name'' as data5_file_name10
  ,picked_result_params[5]->''result_value''->9->>''file_path'' as data5_file_path10

from
  pe_array_agg
  inner join pe_basicinfo on pe_array_agg.pat_event_cd = pe_basicinfo.pat_event_cd
;', 2, '[{"preview": "2020/03/26", "can_calc": "0", "data_code": "event_date", "data_name": "イベント開始日", "data_type": "DateTime", "conv_table": [], "data_class": "添付ファイル", "field_name": "event_date", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "event_end_date", "data_name": "イベント終了日", "data_type": "DateTime", "conv_table": [], "data_class": "添付ファイル", "field_name": "event_end_date", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "観察記録", "can_calc": "0", "data_code": "category_name", "data_name": "カテゴリ名", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "category_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "SOAP", "can_calc": "0", "data_code": "sub_category_name", "data_name": "サブカテゴリ名", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "sub_category_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師１", "can_calc": "0", "data_code": "reg_staff_name", "data_name": "起票者", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "reg_staff_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/25", "can_calc": "0", "data_code": "reg_date", "data_name": "起票日", "data_type": "DateTime", "conv_table": [], "data_class": "添付ファイル", "field_name": "reg_date", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師２", "can_calc": "0", "data_code": "up_staff_name", "data_name": "最終編集者", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "up_staff_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "up_date", "data_name": "最終編集日", "data_type": "DateTime", "conv_table": [], "data_class": "添付ファイル", "field_name": "up_date", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "関連添付ファイル", "can_calc": "0", "data_code": "data1_field_name", "data_name": "データ1 フィールド名", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data1_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "関連添付ファイル", "can_calc": "0", "data_code": "data2_field_name", "data_name": "データ2 フィールド名", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data2_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "関連添付ファイル", "can_calc": "0", "data_code": "data3_field_name", "data_name": "データ3 フィールド名", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data3_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "関連添付ファイル", "can_calc": "0", "data_code": "data4_field_name", "data_name": "データ4 フィールド名", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data4_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "関連添付ファイル", "can_calc": "0", "data_code": "data5_field_name", "data_name": "データ5 フィールド名", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data5_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data1_file_name1", "data_name": "データ1 ファイル名1", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data1_file_name1", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data1_file_path1", "data_name": "データ1 ファイルパス1", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data1_file_path1", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data1_file_name2", "data_name": "データ1 ファイル名2", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data1_file_name2", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data1_file_path2", "data_name": "データ1 ファイルパス2", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data1_file_path2", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data1_file_name3", "data_name": "データ1 ファイル名3", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data1_file_name3", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data1_file_path3", "data_name": "データ1 ファイルパス3", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data1_file_path3", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data1_file_name4", "data_name": "データ1 ファイル名4", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data1_file_name4", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data1_file_path4", "data_name": "データ1 ファイルパス4", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data1_file_path4", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data1_file_name5", "data_name": "データ1 ファイル名5", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data1_file_name5", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data1_file_path5", "data_name": "データ1 ファイルパス5", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data1_file_path5", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data1_file_name6", "data_name": "データ1 ファイル名6", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data1_file_name6", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data1_file_path6", "data_name": "データ1 ファイルパス6", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data1_file_path6", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data1_file_name7", "data_name": "データ1 ファイル名7", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data1_file_name7", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data1_file_path7", "data_name": "データ1 ファイルパス7", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data1_file_path7", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data1_file_name8", "data_name": "データ1 ファイル名8", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data1_file_name8", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data1_file_path8", "data_name": "データ1 ファイルパス8", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data1_file_path8", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data1_file_name9", "data_name": "データ1 ファイル名9", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data1_file_name9", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data1_file_path9", "data_name": "データ1 ファイルパス9", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data1_file_path9", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data1_file_name10", "data_name": "データ1 ファイル名10", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data1_file_name10", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data1_file_path10", "data_name": "データ1 ファイルパス10", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data1_file_path10", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data2_file_name1", "data_name": "データ2 ファイル名1", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data2_file_name1", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data2_file_path1", "data_name": "データ2 ファイルパス1", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data2_file_path1", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data2_file_name2", "data_name": "データ2 ファイル名2", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data2_file_name2", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data2_file_path2", "data_name": "データ2 ファイルパス2", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data2_file_path2", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data2_file_name3", "data_name": "データ2 ファイル名3", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data2_file_name3", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data2_file_path3", "data_name": "データ2 ファイルパス3", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data2_file_path3", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data2_file_name4", "data_name": "データ2 ファイル名4", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data2_file_name4", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data2_file_path4", "data_name": "データ2 ファイルパス4", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data2_file_path4", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data2_file_name5", "data_name": "データ2 ファイル名5", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data2_file_name5", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data2_file_path5", "data_name": "データ2 ファイルパス5", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data2_file_path5", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data2_file_name6", "data_name": "データ2 ファイル名6", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data2_file_name6", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data2_file_path6", "data_name": "データ2 ファイルパス6", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data2_file_path6", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data2_file_name7", "data_name": "データ2 ファイル名7", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data2_file_name7", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data2_file_path7", "data_name": "データ2 ファイルパス7", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data2_file_path7", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data2_file_name8", "data_name": "データ2 ファイル名8", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data2_file_name8", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data2_file_path8", "data_name": "データ2 ファイルパス8", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data2_file_path8", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data2_file_name9", "data_name": "データ2 ファイル名9", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data2_file_name9", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data2_file_path9", "data_name": "データ2 ファイルパス9", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data2_file_path9", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data2_file_name10", "data_name": "データ2 ファイル名10", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data2_file_name10", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data2_file_path10", "data_name": "データ2 ファイルパス10", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data2_file_path10", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data3_file_name1", "data_name": "データ3 ファイル名1", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data3_file_name1", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data3_file_path1", "data_name": "データ3 ファイルパス1", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data3_file_path1", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data3_file_name2", "data_name": "データ3 ファイル名2", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data3_file_name2", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data3_file_path2", "data_name": "データ3 ファイルパス2", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data3_file_path2", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data3_file_name3", "data_name": "データ3 ファイル名3", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data3_file_name3", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data3_file_path3", "data_name": "データ3 ファイルパス3", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data3_file_path3", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data3_file_name4", "data_name": "データ3 ファイル名4", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data3_file_name4", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data3_file_path4", "data_name": "データ3 ファイルパス4", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data3_file_path4", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data3_file_name5", "data_name": "データ3 ファイル名5", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data3_file_name5", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data3_file_path5", "data_name": "データ3 ファイルパス5", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data3_file_path5", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data3_file_name6", "data_name": "データ3 ファイル名6", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data3_file_name6", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data3_file_path6", "data_name": "データ3 ファイルパス6", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data3_file_path6", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data3_file_name7", "data_name": "データ3 ファイル名7", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data3_file_name7", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data3_file_path7", "data_name": "データ3 ファイルパス7", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data3_file_path7", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data3_file_name8", "data_name": "データ3 ファイル名8", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data3_file_name8", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data3_file_path8", "data_name": "データ3 ファイルパス8", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data3_file_path8", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data3_file_name9", "data_name": "データ3 ファイル名9", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data3_file_name9", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data3_file_path9", "data_name": "データ3 ファイルパス9", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data3_file_path9", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data3_file_name10", "data_name": "データ3 ファイル名10", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data3_file_name10", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data3_file_path10", "data_name": "データ3 ファイルパス10", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data3_file_path10", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data4_file_name1", "data_name": "データ4 ファイル名1", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data4_file_name1", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data4_file_path1", "data_name": "データ4 ファイルパス1", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data4_file_path1", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data4_file_name2", "data_name": "データ4 ファイル名2", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data4_file_name2", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data4_file_path2", "data_name": "データ4 ファイルパス2", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data4_file_path2", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data4_file_name3", "data_name": "データ4 ファイル名3", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data4_file_name3", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data4_file_path3", "data_name": "データ4 ファイルパス3", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data4_file_path3", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data4_file_name4", "data_name": "データ4 ファイル名4", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data4_file_name4", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data4_file_path4", "data_name": "データ4 ファイルパス4", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data4_file_path4", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data4_file_name5", "data_name": "データ4 ファイル名5", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data4_file_name5", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data4_file_path5", "data_name": "データ4 ファイルパス5", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data4_file_path5", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data4_file_name6", "data_name": "データ4 ファイル名6", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data4_file_name6", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data4_file_path6", "data_name": "データ4 ファイルパス6", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data4_file_path6", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data4_file_name7", "data_name": "データ4 ファイル名7", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data4_file_name7", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data4_file_path7", "data_name": "データ4 ファイルパス7", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data4_file_path7", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data4_file_name8", "data_name": "データ4 ファイル名8", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data4_file_name8", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data4_file_path8", "data_name": "データ4 ファイルパス8", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data4_file_path8", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data4_file_name9", "data_name": "データ4 ファイル名9", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data4_file_name9", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data4_file_path9", "data_name": "データ4 ファイルパス9", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data4_file_path9", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data4_file_name10", "data_name": "データ4 ファイル名10", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data4_file_name10", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data4_file_path10", "data_name": "データ4 ファイルパス10", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data4_file_path10", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data5_file_name1", "data_name": "データ5 ファイル名1", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data5_file_name1", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data5_file_path1", "data_name": "データ5 ファイルパス1", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data5_file_path1", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data5_file_name2", "data_name": "データ5 ファイル名2", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data5_file_name2", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data5_file_path2", "data_name": "データ5 ファイルパス2", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data5_file_path2", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data5_file_name3", "data_name": "データ5 ファイル名3", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data5_file_name3", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data5_file_path3", "data_name": "データ5 ファイルパス3", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data5_file_path3", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data5_file_name4", "data_name": "データ5 ファイル名4", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data5_file_name4", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data5_file_path4", "data_name": "データ5 ファイルパス4", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data5_file_path4", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data5_file_name5", "data_name": "データ5 ファイル名5", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data5_file_name5", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data5_file_path5", "data_name": "データ5 ファイルパス5", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data5_file_path5", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data5_file_name6", "data_name": "データ5 ファイル名6", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data5_file_name6", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data5_file_path6", "data_name": "データ5 ファイルパス6", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data5_file_path6", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data5_file_name7", "data_name": "データ5 ファイル名7", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data5_file_name7", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data5_file_path7", "data_name": "データ5 ファイルパス7", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data5_file_path7", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data5_file_name8", "data_name": "データ5 ファイル名8", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data5_file_name8", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data5_file_path8", "data_name": "データ5 ファイルパス8", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data5_file_path8", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data5_file_name9", "data_name": "データ5 ファイル名9", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data5_file_name9", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data5_file_path9", "data_name": "データ5 ファイルパス9", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data5_file_path9", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "添付ファイル.txt", "can_calc": "0", "data_code": "data5_file_name10", "data_name": "データ5 ファイル名10", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data5_file_name10", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "/abc/def/添付ファイル.txt", "can_calc": "0", "data_code": "data5_file_path10", "data_name": "データ5 ファイルパス10", "data_type": "string", "conv_table": [], "data_class": "添付ファイル", "field_name": "data5_file_path10", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '観察記録 透析レポート 添付ファイル @ordNo 使用', '2020-03-27 23:59:59', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (76, 'with input_params_expand as
(
  select
    pat_event_cd
    ,json_idx
    ,input_param
  from
    pat_event
    cross join lateral jsonb_array_elements(input_params) with ordinality as tmp(input_param, json_idx)
  where
    is_del = ''0''
    and use_type = 2 and ord_no = @ordNo
)
, result_params_expand as
(
  select
    pat_event_cd
    ,json_idx
    ,result_param
  from
    pat_event
    cross join lateral jsonb_array_elements(result_params) with ordinality as tmp(result_param, json_idx)
  where
    is_del = ''0''
    and use_type = 2 and ord_no = @ordNo
)
, pe_basicinfo_plus as
(
  select
    pat_event_cd
    ,event_start_date
    ,event_end_date
    ,category_name
    ,sub_category_name
    ,reg_staff_info->>''reg_staff_name'' as reg_staff_name
    ,reg_date
    ,up_staff_info->>''up_staff_name'' as up_staff_name
    ,up_date
    ,score_total
  from
    pat_event
  where
    is_del = ''0''
    and use_type = 2 and ord_no = @ordNo
)
, pe_picked as
(
  select
    ipe.pat_event_cd
    ,ipe.json_idx
    ,input_param
    ,result_param
  from
    input_params_expand as ipe
    inner join result_params_expand as rpe
      on ipe.pat_event_cd = rpe.pat_event_cd and ipe.json_idx = rpe.json_idx
  where
    input_param->>''format_class'' = ''8''
)
, pe_array_agg as
(
  select
    pat_event_cd
    ,array_agg(input_param order by json_idx) as picked_input_params
    ,array_agg(result_param order by json_idx) as picked_result_params
  from
    pe_picked
  group by pat_event_cd
)

select
  pe_array_agg.pat_event_cd
  ,to_date(event_start_date, ''YYYYMMDD'') as event_date
  ,to_date(event_end_date, ''YYYYMMDD'') as event_end_date
  ,category_name
  ,sub_category_name
  ,reg_staff_name
  ,reg_date
  ,up_staff_name
  ,up_date

  ,picked_input_params[1]->>''field_name'' as data1_field_name
  ,picked_input_params[2]->>''field_name'' as data2_field_name
  ,picked_input_params[3]->>''field_name'' as data3_field_name
  ,picked_input_params[4]->>''field_name'' as data4_field_name
  ,picked_input_params[5]->>''field_name'' as data5_field_name

  ,rtrim(picked_result_params[1]->''result_value''->>''score'' || '' '' || coalesce(picked_result_params[1]->''result_value''->>''unit'', ''''), '' '') as data1
  ,rtrim(picked_result_params[2]->''result_value''->>''score'' || '' '' || coalesce(picked_result_params[2]->''result_value''->>''unit'', ''''), '' '') as data2
  ,rtrim(picked_result_params[3]->''result_value''->>''score'' || '' '' || coalesce(picked_result_params[3]->''result_value''->>''unit'', ''''), '' '') as data3
  ,rtrim(picked_result_params[4]->''result_value''->>''score'' || '' '' || coalesce(picked_result_params[4]->''result_value''->>''unit'', ''''), '' '') as data4
  ,rtrim(picked_result_params[5]->''result_value''->>''score'' || '' '' || coalesce(picked_result_params[5]->''result_value''->>''unit'', ''''), '' '') as data5

  , score_total || '''' as score_total

from
  pe_array_agg
  inner join pe_basicinfo_plus on pe_array_agg.pat_event_cd = pe_basicinfo_plus.pat_event_cd
;', 2, '[{"preview": "2020/03/26", "can_calc": "0", "data_code": "event_date", "data_name": "イベント開始日", "data_type": "DateTime", "conv_table": [], "data_class": "スコア計算", "field_name": "event_date", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "event_end_date", "data_name": "イベント終了日", "data_type": "DateTime", "conv_table": [], "data_class": "スコア計算", "field_name": "event_end_date", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "観察記録", "can_calc": "0", "data_code": "category_name", "data_name": "カテゴリ名", "data_type": "string", "conv_table": [], "data_class": "スコア計算", "field_name": "category_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "SOAP", "can_calc": "0", "data_code": "sub_category_name", "data_name": "サブカテゴリ名", "data_type": "string", "conv_table": [], "data_class": "スコア計算", "field_name": "sub_category_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師１", "can_calc": "0", "data_code": "reg_staff_name", "data_name": "起票者", "data_type": "string", "conv_table": [], "data_class": "スコア計算", "field_name": "reg_staff_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/25", "can_calc": "0", "data_code": "reg_date", "data_name": "起票日", "data_type": "DateTime", "conv_table": [], "data_class": "スコア計算", "field_name": "reg_date", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師２", "can_calc": "0", "data_code": "up_staff_name", "data_name": "最終編集者", "data_type": "string", "conv_table": [], "data_class": "スコア計算", "field_name": "up_staff_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "up_date", "data_name": "最終編集日", "data_type": "DateTime", "conv_table": [], "data_class": "スコア計算", "field_name": "up_date", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "スコア説明", "can_calc": "0", "data_code": "data1_field_name", "data_name": "データ1 フィールド名", "data_type": "string", "conv_table": [], "data_class": "スコア計算", "field_name": "data1_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "スコア説明", "can_calc": "0", "data_code": "data2_field_name", "data_name": "データ2 フィールド名", "data_type": "string", "conv_table": [], "data_class": "スコア計算", "field_name": "data2_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "スコア説明", "can_calc": "0", "data_code": "data3_field_name", "data_name": "データ3 フィールド名", "data_type": "string", "conv_table": [], "data_class": "スコア計算", "field_name": "data3_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "スコア説明", "can_calc": "0", "data_code": "data4_field_name", "data_name": "データ4 フィールド名", "data_type": "string", "conv_table": [], "data_class": "スコア計算", "field_name": "data4_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "スコア説明", "can_calc": "0", "data_code": "data5_field_name", "data_name": "データ5 フィールド名", "data_type": "string", "conv_table": [], "data_class": "スコア計算", "field_name": "data5_field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30 点", "can_calc": "0", "data_code": "data1", "data_name": "データ1", "data_type": "string", "conv_table": [], "data_class": "スコア計算", "field_name": "data1", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30 点", "can_calc": "0", "data_code": "data2", "data_name": "データ2", "data_type": "string", "conv_table": [], "data_class": "スコア計算", "field_name": "data2", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30 点", "can_calc": "0", "data_code": "data3", "data_name": "データ3", "data_type": "string", "conv_table": [], "data_class": "スコア計算", "field_name": "data3", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30 点", "can_calc": "0", "data_code": "data4", "data_name": "データ4", "data_type": "string", "conv_table": [], "data_class": "スコア計算", "field_name": "data4", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30 点", "can_calc": "0", "data_code": "data5", "data_name": "データ5", "data_type": "string", "conv_table": [], "data_class": "スコア計算", "field_name": "data5", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500 点", "can_calc": "0", "data_code": "score_total", "data_name": "スコア合計", "data_type": "string", "conv_table": [], "data_class": "スコア計算", "field_name": "score_total", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '観察記録 透析レポート スコア計算 @ordNo 使用', '2020-03-27 23:59:59', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (80, 'with input_params_expand as
(
  select
    pat_event_cd
    ,json_idx
    ,input_param
  from
    pat_event
    cross join lateral jsonb_array_elements(input_params) with ordinality as tmp(input_param, json_idx)
  where
    is_del = ''0''
    and use_type = 2 and ord_no = @ordNo
)
, result_params_expand as
(
  select
    pat_event_cd
    ,json_idx
    ,result_param
  from
    pat_event
    cross join lateral jsonb_array_elements(result_params) with ordinality as tmp(result_param, json_idx)
  where
    is_del = ''0''
    and use_type = 2 and ord_no = @ordNo
)
, pe_basicinfo_plus as
(
  select
    pat_event_cd
    ,event_start_date as event_date
    ,event_end_date
    ,category_name
    ,sub_category_name
    ,reg_staff_info->>''reg_staff_name'' as reg_staff_name
    ,pat_event.reg_date
    ,up_staff_info->>''up_staff_name'' as up_staff_name
    ,pat_event.up_date
    ,to_date(bbs_info.notice_start_date, ''YYYYMMDD'') as notice_start_date
    ,to_date(bbs_info.notice_end_date, ''YYYYMMDD'') as notice_end_date
  from
    pat_event
    left outer join bbs_info
      on pat_event.bbs_ctl_no = bbs_info.bbs_ctl_no and bbs_info.is_del = ''0'' and bbs_info.is_disp = ''1''
  where
    pat_event.is_del = ''0''
    and use_type = 2 and pat_event.ord_no = @ordNo
)
, pe_picked as
(
  select
    ipe.pat_event_cd
    ,ipe.json_idx
    ,input_param
    ,result_param
  from
    input_params_expand as ipe
    inner join result_params_expand as rpe
      on ipe.pat_event_cd = rpe.pat_event_cd and ipe.json_idx = rpe.json_idx
  where
    input_param->>''format_class'' = ''10''
)
, pe_array_agg as
(
  select
    pat_event_cd
    ,array_agg(input_param order by json_idx) as picked_input_params
    ,array_agg(result_param order by json_idx) as picked_result_params
  from
    pe_picked
  group by pat_event_cd
)

select
  pe_array_agg.pat_event_cd
  ,to_date(event_date, ''YYYYMMDD'') as event_date
  ,to_date(event_end_date, ''YYYYMMDD'') as event_end_date
  ,category_name
  ,sub_category_name
  ,reg_staff_name
  ,reg_date
  ,up_staff_name
  ,up_date
  ,picked_input_params[1]->>''field_name'' as field_name
  ,case
    when notice_start_date is null then ''掲示板掲載なし''
    else ''掲示板掲載あり''
  end as is_linked
  ,to_char(notice_start_date, ''YYYY/MM/DD'') || '' ～ '' || to_char(notice_end_date, ''YYYY/MM/DD'') as bbs_notice_term

from
  pe_array_agg
  inner join pe_basicinfo_plus on pe_array_agg.pat_event_cd = pe_basicinfo_plus.pat_event_cd
;', 2, '[{"preview": "2020/03/26", "can_calc": "0", "data_code": "event_date", "data_name": "イベント開始日", "data_type": "DateTime", "conv_table": [], "data_class": "掲示板リンク", "field_name": "event_date", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "event_end_date", "data_name": "イベント終了日", "data_type": "DateTime", "conv_table": [], "data_class": "掲示板リンク", "field_name": "event_end_date", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "観察記録", "can_calc": "0", "data_code": "category_name", "data_name": "カテゴリ名", "data_type": "string", "conv_table": [], "data_class": "掲示板リンク", "field_name": "category_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "リンク", "can_calc": "0", "data_code": "sub_category_name", "data_name": "サブカテゴリ名", "data_type": "string", "conv_table": [], "data_class": "掲示板リンク", "field_name": "sub_category_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "リンク情報", "can_calc": "0", "data_code": "field_name", "data_name": "フィールド名", "data_type": "string", "conv_table": [], "data_class": "掲示板リンク", "field_name": "field_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師１", "can_calc": "0", "data_code": "reg_staff_name", "data_name": "起票者", "data_type": "string", "conv_table": [], "data_class": "掲示板リンク", "field_name": "reg_staff_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/25", "can_calc": "0", "data_code": "reg_date", "data_name": "起票日", "data_type": "DateTime", "conv_table": [], "data_class": "掲示板リンク", "field_name": "reg_date", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師２", "can_calc": "0", "data_code": "up_staff_name", "data_name": "最終編集者", "data_type": "string", "conv_table": [], "data_class": "掲示板リンク", "field_name": "up_staff_name", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "up_date", "data_name": "最終編集日", "data_type": "DateTime", "conv_table": [], "data_class": "掲示板リンク", "field_name": "up_date", "disp_format": "yyyy/mm/dd", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "掲示板掲載あり", "can_calc": "0", "data_code": "is_linked", "data_name": "掲示板掲載有無", "data_type": "string", "conv_table": [], "data_class": "掲示板リンク", "field_name": "is_linked", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27～2020/03/28", "can_calc": "0", "data_code": "bbs_notice_term", "data_name": "掲示板掲載期間", "data_type": "string", "conv_table": [], "data_class": "掲示板リンク", "field_name": "bbs_notice_term", "disp_format": "", "data_category": "観察記録", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '観察記録 透析レポート 掲示板リンク @ordNo 使用', '2020-03-27 23:59:59', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (96, 'with ord_tbl as (
  select
    ord_no,
    facility_cd,
    pat_id,
    case
      when coalesce(rst_dialysis_state, ''0'') = ''0'' then to_timestamp( treat_date || coalesce(ind_treat_start_time, ''2359'' ) || ''59'', ''yyyymmddhh24miss'')
      else coalesce(rst_cond_send_date, rst_start_date)
    end as key_date,
    case
      when coalesce(rst_dialysis_state, ''0'') = ''0'' then ind_bed_cd
      else rst_bed_cd
    end as bed_cd
  from
    ord_main
  where
    ord_no = @ordNo and is_del = ''0''

), bed_tbl as (
  select
    *
  from
    mst_bed
  where
    bed_cd = (select bed_cd from ord_tbl)
  and
    is_disp = ''1''
  and
    is_del = ''0''

), machine_tbl as (
  select
    mm.*,
    mmt.machine_type
  from
    mst_machine as mm
      left join mst_machine_type as mmt on mm.machine_type_cd = mmt.machine_type_cd
  where
    machine_no = (select machine_no from bed_tbl)
  and
    is_disp =''1''
  and
    is_del = ''0''

), mente_tbl as (
  select
    mmr.*
  from
    mnt_motion_record mmr
      inner join machine_tbl as mt
        on mmr.facility_cd = mt.facility_cd
          and mmr.machine_type_cd = mt.machine_type_cd
          and mmr.machine_serial = mt.machine_serial
  where
    mmr.event_reg_date <= (select key_date from ord_tbl)
  and
    mmr.data_type = 4

), mente_tbl1 as (
  select
    *
  from
    mente_tbl
  where
    test_type = 1
  order by
    event_reg_date desc
  limit 1

), mente_tbl2 as (
  select
    *
  from
    mente_tbl
  where
    test_type = 2
  order by
    event_reg_date desc
  limit 1

), mente_tbl3 as (
  select
    *
  from
    mente_tbl
  where
    test_type = 3
  order by
    event_reg_date desc
  limit 1

), mente_tbl4 as (
  select
    *
  from
    mente_tbl
  where
    test_type = 4
  order by
    event_reg_date desc
  limit 1

), mente_tbl5 as (
  select
    *
  from
    mente_tbl
  where
    test_type = 5
  order by
    event_reg_date desc
  limit 1

), mente_tbl6 as (
  select
    *
  from
    mente_tbl
  where
    test_type = 6
  order by
    event_reg_date desc
  limit 1

), mente_tbl7 as (
  select
    *
  from
    mente_tbl
  where
    test_type = 7
  order by
    event_reg_date desc
  limit 1

)


select
  mt.machine_no,
  mt.machine_type,
  mt.com_format_cd,
  mt.setting_date,

  tbl1.event_reg_date as dt1_date,
  tbl1.contents->>''43'' as dt1_data43,
  tbl1.contents->>''44'' as dt1_data44,
  tbl1.contents->>''45'' as dt1_data45,
  tbl1.contents->>''46'' as dt1_data46,
  case
    when tbl1.contents->>''47'' in (''000'', ''0101'', ''0201'', ''0301'') then ''1''
    else ''0''
  end as dt1_data47,
  tbl1.contents->>''48'' as dt1_data48,
  tbl1.contents->>''49'' as dt1_data49,

  tbl2.event_reg_date as dt2_date,
  tbl2.contents->>''53'' as dt2_data53,
  tbl2.contents->>''54'' as dt2_data54,

  tbl3.event_reg_date as dt3_date,
  tbl3.contents->>''58'' as dt3_data58,

  tbl4.event_reg_date as dt4_date,
  tbl4.contents->>''63'' as dt4_data63,
  tbl4.contents->>''64'' as dt4_data64,
  case
    when tbl4.contents->>''65'' in (''3001'', ''3101'') then ''1''
    else ''0''
  end as dt4_data65,

  tbl5.event_reg_date as dt5_date,
  tbl5.contents->>''5'' as dt5_data5,
  case
    when tbl5.contents->>''6'' = ''0001'' then ''1''
    else ''0''
  end as dt5_data6,
  tbl5.contents->>''7'' as dt5_data7,
  tbl5.contents->>''8'' as dt5_data8,
  tbl5.contents->>''9'' as dt5_data9,
  tbl5.contents->>''10'' as dt5_data10,
  tbl5.contents->>''11'' as dt5_data11,

  tbl6.event_reg_date as dt6_date,
  tbl6.contents->>''4'' as dt6_data4,
  tbl6.contents->>''5'' as dt6_data5,
  case
    when tbl6.contents->>''6'' = ''3001'' then ''1''
    else ''0''
  end as dt6_data6,

  tbl7.event_reg_date as dt7_date,
  tbl7.machine_record_message as dt7_message

from
  machine_tbl as mt
   left join mente_tbl1 as tbl1
     on mt.facility_cd = tbl1.facility_cd
       and mt.machine_type_cd = tbl1.machine_type_cd
       and mt.machine_serial = tbl1.machine_serial
   left join mente_tbl2 as tbl2
     on mt.facility_cd = tbl2.facility_cd
       and mt.machine_type_cd = tbl2.machine_type_cd
       and mt.machine_serial = tbl2.machine_serial
   left join mente_tbl3 as tbl3
     on mt.facility_cd = tbl3.facility_cd
       and mt.machine_type_cd = tbl3.machine_type_cd
       and mt.machine_serial = tbl3.machine_serial
   left join mente_tbl4 as tbl4
     on mt.facility_cd = tbl4.facility_cd
       and mt.machine_type_cd = tbl4.machine_type_cd
       and mt.machine_serial = tbl4.machine_serial
   left join mente_tbl5 as tbl5
     on mt.facility_cd = tbl5.facility_cd
       and mt.machine_type_cd = tbl5.machine_type_cd
       and mt.machine_serial = tbl5.machine_serial
   left join mente_tbl6 as tbl6
     on mt.facility_cd = tbl6.facility_cd
       and mt.machine_type_cd = tbl6.machine_type_cd
       and mt.machine_serial = tbl6.machine_serial
   left join mente_tbl7 as tbl7
     on mt.facility_cd = tbl7.facility_cd
       and mt.machine_type_cd = tbl7.machine_type_cd
       and mt.machine_serial = tbl7.machine_serial

', 2, '[{"preview": "1", "can_calc": "0", "data_code": "machine_no", "data_name": "装置番号", "data_type": "string", "conv_table": [], "data_class": "自己診断", "field_name": "machine_no", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "DCS3", "can_calc": "0", "data_code": "machine_type", "data_name": "機種", "data_type": "string", "conv_table": [], "data_class": "自己診断", "field_name": "machine_type", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/18 08:00", "can_calc": "0", "data_code": "dt1_date", "data_name": "配管自己診断測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "自己診断", "field_name": "dt1_date", "disp_format": "yyyy/mm/dd hh:mm", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/18 08:00", "can_calc": "0", "data_code": "dt2_date", "data_name": "漏血テスト測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "自己診断", "field_name": "dt2_date", "disp_format": "yyyy/mm/dd hh:mm", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/18 08:00", "can_calc": "0", "data_code": "dt4_date", "data_name": "濃度自己診断測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "自己診断", "field_name": "dt4_date", "disp_format": "yyyy/mm/dd hh:mm", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/18 08:00", "can_calc": "0", "data_code": "dt3_date", "data_name": "透析液流量自己診断測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "自己診断", "field_name": "dt3_date", "disp_format": "yyyy/mm/dd hh:mm", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/18 08:00", "can_calc": "0", "data_code": "dt5_date", "data_name": "配管テスト測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "自己診断", "field_name": "dt5_date", "disp_format": "yyyy/mm/dd hh:mm", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/18 08:00", "can_calc": "0", "data_code": "dt6_date", "data_name": "希釈テスト測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "自己診断", "field_name": "dt6_date", "disp_format": "yyyy/mm/dd hh:mm", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/18 08:00", "can_calc": "0", "data_code": "dt7_date", "data_name": "通信共通自己診断測定日時", "data_type": "DateTime", "conv_table": [], "data_class": "自己診断", "field_name": "dt7_date", "disp_format": "yyyy/mm/dd hh:mm", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/01/01", "can_calc": "0", "data_code": "relation_name", "data_name": "設置日", "data_type": "DateTime", "conv_table": [], "data_class": "自己診断", "field_name": "relation_name", "disp_format": "yyyy/mm/dd", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "dt1_data47", "data_name": "配管自己診断測定結果", "data_type": "string", "conv_table": [{"code": "0", "disp": "不合格", "item": "不合格"}, {"code": "1", "disp": "合格", "item": "合格"}], "data_class": "自己診断", "field_name": "dt1_data47", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "13", "can_calc": "0", "data_code": "dt1_data43", "data_name": "配管系漏れ(陰圧)", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt1_data43", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "dt1_data44", "data_name": "配管系漏れ(陽圧)", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt1_data44", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-3", "can_calc": "0", "data_code": "dt1_data48", "data_name": "除水テスト", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt1_data48", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-40", "can_calc": "0", "data_code": "dt1_data46", "data_name": "バランステスト", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt1_data46", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5", "can_calc": "0", "data_code": "dt1_data45", "data_name": "CFフィルタ漏れ", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt1_data45", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "dt1_data49", "data_name": "CFsフィルタ漏れ", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt1_data49", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.203", "can_calc": "0", "data_code": "dt2_data53", "data_name": "赤電圧", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt2_data53", "disp_format": "0.000", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.426", "can_calc": "0", "data_code": "dt2_data54", "data_name": "緑電圧", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt2_data54", "disp_format": "0.000", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "dt4_data65", "data_name": "濃度自己診断結果", "data_type": "string", "conv_table": [{"code": "0", "disp": "不合格", "item": "不合格"}, {"code": "1", "disp": "合格", "item": "合格"}], "data_class": "自己診断", "field_name": "dt4_data65", "disp_format": "0.000", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dt4_data63", "data_name": "B原液濃度", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt4_data63", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dt4_data64", "data_name": "A原液濃度", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt4_data64", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dt3_data58", "data_name": "透析液流量測定値", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt3_data58", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dt5_data5", "data_name": "排液判定時間", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt5_data5", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "dt5_data6", "data_name": "配管テスト結果", "data_type": "string", "conv_table": [{"code": "0", "disp": "不合格", "item": "不合格"}, {"code": "1", "disp": "合格", "item": "合格"}], "data_class": "自己診断", "field_name": "dt5_data6", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-10", "can_calc": "0", "data_code": "dt5_data7", "data_name": "給水圧", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt5_data7", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "dt5_data8", "data_name": "送液圧（低）", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt5_data8", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30", "can_calc": "0", "data_code": "dt5_data9", "data_name": "送液圧（高）", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt5_data9", "disp_format": "0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10.0", "can_calc": "0", "data_code": "dt5_data10", "data_name": "濃度セル3", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt5_data10", "disp_format": "0.0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15.0", "can_calc": "0", "data_code": "dt5_data11", "data_name": "濃度セル4", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt5_data11", "disp_format": "0.0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.00", "can_calc": "0", "data_code": "dt6_data4", "data_name": "B液濃度", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt6_data4", "disp_format": "0.00", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10.0", "can_calc": "0", "data_code": "dt6_data5", "data_name": "透析液濃度", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt6_data5", "disp_format": "0.0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "合格", "can_calc": "0", "data_code": "dt6_data6", "data_name": "希釈テスト結果", "data_type": "string", "conv_table": [{"code": "0", "disp": "不合格", "item": "不合格"}, {"code": "1", "disp": "合格", "item": "合格"}], "data_class": "自己診断", "field_name": "dt6_data6", "disp_format": "", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}, {"preview": "自己診断メッセージです。", "can_calc": "0", "data_code": "dt7_message", "data_name": "通信共通自己診断測定結果", "data_type": "decimal", "conv_table": [], "data_class": "自己診断", "field_name": "dt7_message", "disp_format": "0.0", "data_category": "機器保守", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 9]}', '装置保守：自己診断　@ordNo使用', '2020-03-30 16:59:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (131, 'with tmp as(
  select
    count(distinct mst_kur.kur_name) as num_of_kinds
 from
    ord_main  left  join   mst_kur  on  mst_kur.kur_cd=ord_main.ind_kur_cd  and  mst_kur.is_del= ''0''
  where
    ord_main.is_del = ''0''
   and ord_no in (@ordNos)
)
, kur_name_tbl as(
  select
  mst_kur.kur_name as  ind_kur_name
  from ord_main   left  join   mst_kur  on  mst_kur.kur_cd=ord_main.ind_kur_cd  and  mst_kur.is_del= ''0''
    where  ord_main.is_del = ''0''
    and ord_no in (@ordNos)
    and ind_kur_name is not null
  limit 1
)

select
 case
   when num_of_kinds = 0 then ''クール未登録''
   when num_of_kinds = 1 then (select * from kur_name_tbl)
   else ''複数クール選択''
 end as kur_selection_name
from
  tmp
;', 2, '[{"preview": "午後", "can_calc": "", "data_code": "kur_selection_name", "data_name": "選択クール名", "data_type": "string", "conv_table": [], "data_class": "選択クール名", "field_name": "kur_selection_name", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": ""}]', '0', '{"applications": [1]}', '{"classes": [5]}', '配布リスト(ベッド) 選択クール名 @ordNos 使用', '2020-04-09 16:01:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (134, 'UPSERT TEST with ord_key_tbl as (
  select
    facility_cd
  from
    ord_main
  where
    ord_no = @ordNo
), medicine_tbl as (
  select
    *
  from
    mst_medicine
  where
    mst_medicine.facility_cd = (select facility_cd from ord_key_tbl)
  and
    mst_medicine.is_disp = ''1''
  and
    mst_medicine.is_del = ''0''
), medicine_mix_tbl as (
  select
    *
  from
    mst_medicine_mix
  where
    mst_medicine_mix.facility_cd = (select facility_cd from ord_key_tbl)
  and
    mst_medicine_mix.is_disp = ''1''
  and
    mst_medicine_mix.is_del = ''0''
), medicine_class_tbl as (
  select
    *
  from
    mst_medicine_class
  where
    mst_medicine_class.facility_cd = (select facility_cd from ord_key_tbl)
  and
    mst_medicine_class.is_disp = ''1''
  and
    mst_medicine_class.is_del = ''0''
), timing_tbl as (
  select
    *
  from
    mst_medicate_timing
  where
    mst_medicate_timing.facility_cd = (select facility_cd from ord_key_tbl)
  and
    mst_medicate_timing.is_disp = ''1''
  and
    mst_medicate_timing.is_del = ''0''
), procedure_tbl as (
  select
    *
  from
    mst_procedure
  where
    mst_procedure.facility_cd = (select facility_cd from ord_key_tbl)
  and
    mst_procedure.is_disp = ''1''
  and
    mst_procedure.is_del = ''0''
), ord_tbl as (
  select
    ord_no,
    facility_cd,
    to_date(treat_date, ''yyyymmdd'') as treat_date,
    info->>''no'' as no,
    info->>''medicine_type'' as medicine_type,
    info->>''cd'' as cd,
    info->>''amount'' as amount,
    to_date(info->>''init_date'', ''yyyymmdd'') as init_date,
    info->>''date_interval'' as date_interval,
    info->>''timing_cd'' as timing_cd,
    info->>''procedure_cd'' as procedure_cd,
    info->>''comment'' as comment,
    info->>''ind_user_id'' as ind_user_id,
    info->>''ind_user_last_name'' as ind_user_last_name,
    info->>''ind_user_first_name'' as ind_user_first_name,
    info->>''upd_user_id'' as upd_user_id,
    info->>''upd_user_last_name'' as upd_user_last_name,
    info->>''upd_user_first_name'' as upd_user_first_name,
    info->>''input_class'' as input_class,
    info->>''is_editable'' as is_editable,
    info->>''cop_order_no'' as cop_order_no
  from
    ord_main
      cross join lateral
        json_array_elements (ord_main.ind_medi_info :: json) info
  where
    ord_no = @ordNo
)
select
  ord.*,
  case
    when medicine_type = ''2'' then mix.medicine_mix_name
    else med.medicine_name
  end as medicine_name,
  case
    when medicine_type = ''2'' then mix.unit
    else med.unit
  end as medicine_unit,
  case
    when medicine_type = ''2'' then mix.class_cd
    else med.class_cd
  end as class_cd,
  case
    when medicine_type = ''2'' then mix_cls.class_name
    else med_cls.class_name
  end as class_name,
  case
    when medicine_type = ''2'' then mix_cls.class_type
    else med_cls.class_type
  end as class_type,
  tim.medicate_timing_name,
  pro.pricedure_name
from
  ord_tbl as ord
  left join medicine_tbl as med on ord.cd = med.medicine_cd::text
  left join medicine_mix_tbl as mix on ord.cd = mix.medicine_mix_cd::text
  left join medicine_class_tbl as med_cls on med.class_cd = med_cls.class_cd
  left join medicine_class_tbl as mix_cls on mix.class_cd = mix_cls.class_cd
  left join timing_tbl as tim on ord.timing_cd = tim.medicate_timing_cd::text
  left join procedure_tbl as pro on ord.procedure_cd = pro.procedure_cd::text
where
  ord.ord_no = @ordNo', 2, '[{"preview": "1", "can_calc": "0", "data_code": "medi_class_cd", "data_name": "薬剤分類コード", "data_type": "decimal", "conv_table": [], "data_class": "投薬", "field_name": "class_cd", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "medi_class_type", "data_name": "分類区分", "data_type": "decimal", "conv_table": [], "data_class": "投薬", "field_name": "class_type", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "medi_cd", "data_name": "薬剤(調整薬剤)コード", "data_type": "decimal", "conv_table": [], "data_class": "投薬", "field_name": "cd", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/04", "can_calc": "0", "data_code": "treat_date", "data_name": "指示日", "data_type": "DateTime", "conv_table": [], "data_class": "投薬", "field_name": "treat_date", "disp_format": "yyyy/mm/dd", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/07", "can_calc": "0", "data_code": "init_date", "data_name": "指示開始日", "data_type": "DateTime", "conv_table": [], "data_class": "投薬", "field_name": "init_date", "disp_format": "[h]:mm", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト薬剤１", "can_calc": "0", "data_code": "medi_name", "data_name": "薬剤名", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medicine_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "項目未分類", "can_calc": "0", "data_code": "class_name", "data_name": "薬剤分類名", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "class_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "medi_amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "投薬", "field_name": "amount", "disp_format": "0", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "medicine_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medicine_unit", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "静脈側回路内注射", "can_calc": "0", "data_code": "pricedure_name", "data_name": "手技", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "pricedure_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析中", "can_calc": "0", "data_code": "medicate_timing_name", "data_name": "投与時間帯", "data_type": "strnig", "conv_table": [], "data_class": "投薬", "field_name": "medi_timing_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "予定薬剤です。", "can_calc": "0", "data_code": "comment", "data_name": "コメント", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "comment", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト医師", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "ind_user_id", "data_name": "指示者", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "ind_user_id", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "upd_user_id", "data_name": "更新者", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "upd_user_id", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "毎回", "can_calc": "0", "data_code": "date_interval", "data_name": "投与間隔", "data_type": "string", "conv_table": [{"code": "0", "disp": "毎回", "item": "毎回"}, {"code": "1", "disp": "毎週", "item": "毎週"}, {"code": "2", "disp": "1回/2週", "item": "1回/2週"}, {"code": "3", "disp": "1回/3週", "item": "1回/3週"}, {"code": "4", "disp": "1回/4週", "item": "1回/4週"}, {"code": "5", "disp": "1回/月：第1曜日", "item": "1回/月：第1曜日"}, {"code": "6", "disp": "1回/月：第2曜日", "item": "1回/月：第2曜日"}, {"code": "7", "disp": "1回/月：第3曜日", "item": "1回/月：第3曜日"}, {"code": "8", "disp": "1回/月：第4曜日", "item": "1回/月：第4曜日"}, {"code": "9", "disp": "1回/月：最終曜日", "item": "1回/月：最終曜日"}, {"code": "10", "disp": "1回/3月：最終治療日", "item": "1回/月：最終治療日"}], "data_class": "投薬", "field_name": "date_interval", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [2]}', '{"classes": [1, 9]}', NULL, '2019-05-29 17:24:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (139, 'select * from sys_country where country_cd_alpha3 = @countryCdAlpha3', 2, '[{"preview": "2021/02/22", "can_calc": "0", "data_code": "notice_fac_cal_start_date", "data_name": "イベント開始日", "data_type": "DateTime", "conv_table": [], "data_class": "施設イベント", "field_name": "notice_fac_cal_start_date", "disp_format": "yyyy/mm/dd", "data_category": "施設イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2021/08/22", "can_calc": "0", "data_code": "notice_fac_cal_end_date", "data_name": "イベント終了日", "data_type": "DateTime", "conv_table": [], "data_class": "施設イベント", "field_name": "notice_fac_cal_end_date", "disp_format": "yyyy/mm/dd", "data_category": "施設イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2021/02/23", "can_calc": "0", "data_code": "notice_start_date", "data_name": "掲載開始日", "data_type": "DateTime", "conv_table": [], "data_class": "施設イベント", "field_name": "notice_start_date", "disp_format": "yyyy/mm/dd", "data_category": "施設イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2021/06/22", "can_calc": "0", "data_code": "notice_end_date", "data_name": "掲載終了日", "data_type": "DateTime", "conv_table": [], "data_class": "施設イベント", "field_name": "notice_end_date", "disp_format": "yyyy/mm/dd", "data_category": "施設イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "起票者１", "can_calc": "0", "data_code": "reg_staff_name", "data_name": "起票者", "data_type": "string", "conv_table": [], "data_class": "施設イベント", "field_name": "reg_staff_name", "disp_format": "", "data_category": "施設イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "更新者１", "can_calc": "0", "data_code": "upd_staff_name", "data_name": "最終更新者", "data_type": "string", "conv_table": [], "data_class": "施設イベント", "field_name": "upd_staff_name", "disp_format": "", "data_category": "施設イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "タイトル１", "can_calc": "0", "data_code": "title", "data_name": "タイトル", "data_type": "string", "conv_table": [], "data_class": "施設イベント", "field_name": "title", "disp_format": "", "data_category": "施設イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "内容１", "can_calc": "0", "data_code": "content", "data_name": "内容", "data_type": "string", "conv_table": [], "data_class": "施設イベント", "field_name": "content", "disp_format": "", "data_category": "施設イベント", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": []}', '汎用　国籍名取得用　@countryCdAlpha3', '2021-03-31 14:09:45', CURRENT_TIMESTAMP, '[]');
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (156, 'SELECT
	rst_bed_cd,
	rst_machine_name,
	rst_start_date,
	rst_dialysis_state
from ord_main ord
where ord.facility_cd = @facilityCd
and rst_start_date >= @fromDate
and rst_start_date <= @toDate
and ord.rst_dialysis_state <>''0''
and rst_machine_name <>''''
order by rst_start_date desc
;', 2, '[{"preview": "2020/04/07", "can_calc": "0", "data_code": "rst_start_date", "data_name": "使用日", "data_type": "DateTime", "conv_table": [], "data_class": "装置一覧表", "field_name": "rst_start_date", "disp_format": "yyyy/mm/dd", "data_category": "装置一覧表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "装置A", "can_calc": "0", "data_code": "rst_machine_name", "data_name": "装置名", "data_type": "string", "conv_table": [], "data_class": "装置一覧表", "field_name": "rst_machine_name", "disp_format": "", "data_category": "装置一覧表", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [11]}', '@facilityCd  @fromdate  @todate', '2021-06-07 16:46:44.127', CURRENT_TIMESTAMP, NULL);

delete from sys_data_set where sql_cd = '-21012';
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-21012, 'select substring(treat_date, 1, 6) as treat_date, count(*) as count from ord_main where treat_date between @dateFrom and @dateTo and facility_cd = @facilityCd AND is_del = ''0'' and rst_dialysis_state = ''0'' and pat_id is not null
group by substring(treat_date, 1, 6)
order by substring(treat_date, 1, 6) asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

delete from sys_data_set where sql_cd = '-21013';
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-21013, 'SELECT substring(ordMain.treat_date, 1, 6) as treat_date, count(*) as count
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
group by substring(ordMain.treat_date, 1, 6)
order by substring(ordMain.treat_date, 1, 6) asc;', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

delete from sys_data_set where sql_cd = '-21014';
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-21014, 'select substring(ordMain.treat_date, 1, 6) as treat_date, count(*) as count from ord_main as ordMain left join mst_treatment as mstTreatment on ordMain.ind_treatment_cd = mstTreatment.treatment_cd
where mstTreatment.device_mode = ''9'' and ordMain.treat_date between @dateFrom and @dateTo and ordMain.facility_cd = @facilityCd AND ordMain.is_del = ''0''
 AND ordMain.rst_dialysis_state = ''0'' and ordMain.pat_id is not null
group by substring(ordMain.treat_date, 1, 6)
order by substring(ordMain.treat_date, 1, 6) asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

delete from sys_data_set where sql_cd = '-21017';
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-21017, 'select substring(treat_date, 1, 6) as treat_date, count(*) as count from ord_main where treat_date between @dateFrom and @dateTo and rst_dialysis_state = ''6'' and facility_cd = @facilityCd AND is_del = ''0'' and pat_id is not null
group by substring(treat_date, 1, 6)
order by substring(treat_date, 1, 6) asc ', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

delete from sys_data_set where sql_cd = '-21018';
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-21018, 'select substring(treat_date, 1, 6) as treat_date, count(*) as count from ord_main where rst_dialysis_state = ''6'' AND treat_date between @dateFrom and @dateTo and rst_in_out_class = 1 and facility_cd = @facilityCd AND is_del = ''0'' and pat_id is not null
group by substring(treat_date, 1, 6)
order by substring(treat_date, 1, 6) asc ', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

delete from sys_data_set where sql_cd = '-21019';
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-21019, 'select substring(treat_date, 1, 6) as treat_date, count(*) as count from ord_main where rst_dialysis_state = ''6'' AND treat_date between @dateFrom and @dateTo and (rst_in_out_class <> 1 or rst_in_out_class is null) and facility_cd = @facilityCd AND is_del = ''0'' and pat_id is not null
group by substring(treat_date, 1, 6)
order by substring(treat_date, 1, 6) asc ', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

delete from sys_data_set where sql_cd = '-21020';
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-21020, 'select substring(ordMain.treat_date, 1, 6) as treat_date, count(*) as count from ord_main as ordMain left join mst_treatment as mstTreatment on ordMain.rst_treatment_cd = mstTreatment.treatment_cd
where ordMain.rst_dialysis_state = ''6'' AND mstTreatment.device_mode != ''9'' and ordMain.treat_date between @dateFrom and @dateTo and ordMain.facility_cd = @facilityCd AND ordMain.is_del = ''0'' and ordMain.pat_id is not null
group by substring(ordMain.treat_date, 1, 6)
order by substring(ordMain.treat_date, 1, 6) asc ', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

delete from sys_data_set where sql_cd = '-21021';
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-21021, 'select substring(ordMain.treat_date, 1, 6) as treat_date, count(*) as count from ord_main as ordMain left join mst_treatment as mstTreatment on ordMain.rst_treatment_cd = mstTreatment.treatment_cd
where ordMain.rst_dialysis_state = ''6'' AND mstTreatment.device_mode = ''9'' and ordMain.treat_date between @dateFrom and @dateTo and ordMain.facility_cd = @facilityCd AND ordMain.is_del = ''0'' and ordMain.pat_id is not null
group by substring(ordMain.treat_date, 1, 6)
order by substring(ordMain.treat_date, 1, 6) asc ', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

delete from sys_data_set where sql_cd = '-21024';
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-21024, 'SELECT
  substring(elem ->> ''period_start'', 1, 6) as treat_date,
  count(DISTINCT pat_id) AS count
FROM pat_unique,
     jsonb_array_elements(in_out_visit_history_info) AS elem
WHERE elem ->> ''move_in_out'' = ''1''
  AND elem ->> ''period_start'' >= @dateFrom
  AND elem ->> ''period_start'' <= @dateTo
  AND elem ->> ''facility_cd'' = @facilityCd
  AND is_del = ''0''
 group by substring(elem ->> ''period_start'', 1, 6)
 order by substring(elem ->> ''period_start'', 1, 6) asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

delete from sys_data_set where sql_cd = '-21025';
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-21025, 'SELECT
  substring(elem ->> ''period_start'', 1, 6) as treat_date,
  count(DISTINCT pat_id) AS count
FROM pat_unique,
     jsonb_array_elements(in_out_visit_history_info) AS elem
WHERE elem ->> ''move_in_out'' = ''2''
  AND elem ->> ''period_start'' >= @dateFrom
  AND elem ->> ''period_start'' <= @dateTo
  AND elem ->> ''facility_cd'' = @facilityCd
  AND is_del = ''0''
 group by substring(elem ->> ''period_start'', 1, 6)
 order by substring(elem ->> ''period_start'', 1, 6) asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

delete from sys_data_set where sql_cd = '-21026';
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-21026, 'SELECT
  substring(elem ->> ''period_start'', 1, 6) as treat_date,
  count(DISTINCT pat_id) AS count
FROM pat_unique,
     jsonb_array_elements(in_out_visit_history_info) AS elem
WHERE elem ->> ''move_in_out'' = ''3''
  AND elem ->> ''period_start'' >= @dateFrom
  AND elem ->> ''period_start'' <= @dateTo
  AND elem ->> ''facility_cd'' = @facilityCd
  AND is_del = ''0''
 group by substring(elem ->> ''period_start'', 1, 6)
 order by substring(elem ->> ''period_start'', 1, 6) asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

delete from sys_data_set where sql_cd = '-21027';
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-21027, 'SELECT
  substring(elem ->> ''period_start'', 1, 6) as treat_date,
  count(DISTINCT pat_id) AS count
FROM pat_unique,
     jsonb_array_elements(in_out_visit_history_info) AS elem
WHERE elem ->> ''move_in_out'' = ''4''
  AND elem ->> ''period_start'' >= @dateFrom
  AND elem ->> ''period_start'' <= @dateTo
  AND elem ->> ''facility_cd'' = @facilityCd
  AND is_del = ''0''
 group by substring(elem ->> ''period_start'', 1, 6)
 order by substring(elem ->> ''period_start'', 1, 6) asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

delete from sys_data_set where sql_cd = '-21028';
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-21028, 'SELECT
  substring(elem ->> ''period_start'', 1, 6) as treat_date,
  count(DISTINCT pat_id) AS count
FROM pat_unique,
     jsonb_array_elements(in_out_visit_history_info) AS elem
WHERE elem ->> ''move_in_out'' = ''5''
  AND elem ->> ''period_start'' >= @dateFrom
  AND elem ->> ''period_start'' <= @dateTo
  AND elem ->> ''facility_cd'' = @facilityCd
  AND is_del = ''0''
 group by substring(elem ->> ''period_start'', 1, 6)
 order by substring(elem ->> ''period_start'', 1, 6) asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

delete from sys_data_set where sql_cd = '-21029';
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-21029, 'SELECT
  substring(elem ->> ''period_start'', 1, 6) as treat_date,
  count(DISTINCT pat_id) AS count
FROM pat_unique,
     jsonb_array_elements(in_out_visit_history_info) AS elem
WHERE elem ->> ''move_in_out'' = ''6''
  AND elem ->> ''period_start'' >= @dateFrom
  AND elem ->> ''period_start'' <= @dateTo
  AND elem ->> ''facility_cd'' = @facilityCd
  AND is_del = ''0''
 group by substring(elem ->> ''period_start'', 1, 6)
 order by substring(elem ->> ''period_start'', 1, 6) asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

delete from sys_data_set where sql_cd = '-21030';
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-21030, 'SELECT
  substring(elem ->> ''period_start'', 1, 6) as treat_date,
  count(DISTINCT pat_id) AS count
FROM pat_unique,
     jsonb_array_elements(in_out_visit_history_info) AS elem
WHERE elem ->> ''move_in_out'' = ''7''
  AND elem ->> ''period_start'' >= @dateFrom
  AND elem ->> ''period_start'' <= @dateTo
  AND elem ->> ''facility_cd'' = @facilityCd
  AND is_del = ''0''
 group by substring(elem ->> ''period_start'', 1, 6)
 order by substring(elem ->> ''period_start'', 1, 6) asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

delete from sys_data_set where sql_cd = '-21031';
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-21031, 'SELECT
  substring(elem ->> ''period_start'', 1, 6) as treat_date,
  count(DISTINCT pat_id) AS count
FROM pat_unique,
     jsonb_array_elements(in_out_visit_history_info) AS elem
WHERE elem ->> ''move_in_out'' = ''8''
  AND elem ->> ''period_start'' >= @dateFrom
  AND elem ->> ''period_start'' <= @dateTo
  AND elem ->> ''facility_cd'' = @facilityCd
  AND is_del = ''0''
 group by substring(elem ->> ''period_start'', 1, 6)
 order by substring(elem ->> ''period_start'', 1, 6) asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

delete from sys_data_set where sql_cd = '-21032';
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-21032, 'SELECT
  substring(elem ->> ''period_start'', 1, 6) as treat_date,
  count(DISTINCT pat_id) AS count
FROM pat_unique,
     jsonb_array_elements(in_out_visit_history_info) AS elem
WHERE elem ->> ''move_in_out'' = ''9''
  AND elem ->> ''period_start'' >= @dateFrom
  AND elem ->> ''period_start'' <= @dateTo
  AND elem ->> ''facility_cd'' = @facilityCd
  AND is_del = ''0''
 group by substring(elem ->> ''period_start'', 1, 6)
 order by substring(elem ->> ''period_start'', 1, 6) asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

delete from sys_data_set where sql_cd = '-21033';
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-21033, 'SELECT
  substring(elem ->> ''period_end'', 1, 6) as treat_date,
  count(DISTINCT pat_id) AS count
FROM pat_unique,
     jsonb_array_elements(in_out_visit_history_info) AS elem
WHERE elem ->> ''move_in_out'' = ''9''
  AND elem ->> ''period_end'' >= @dateFrom
  AND elem ->> ''period_end'' <= @dateTo
  AND elem ->> ''facility_cd'' = @facilityCd
  AND is_del = ''0''
 group by substring(elem ->> ''period_end'', 1, 6)
 order by substring(elem ->> ''period_end'', 1, 6) asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

delete from sys_data_set where sql_cd = '-21034';
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-21034, 'SELECT
  substring(elem ->> ''period_start'', 1, 6) as treat_date,
  count(DISTINCT pat_id) AS count
FROM pat_unique,
     jsonb_array_elements(in_out_visit_history_info) AS elem
WHERE elem ->> ''move_in_out'' = ''10''
  AND elem ->> ''period_start'' >= @dateFrom
  AND elem ->> ''period_start'' <= @dateTo
  AND elem ->> ''facility_cd'' = @facilityCd
  AND is_del = ''0''
 group by substring(elem ->> ''period_start'', 1, 6)
 order by substring(elem ->> ''period_start'', 1, 6) asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

delete from sys_data_set where sql_cd = '-21035';
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-21035, 'SELECT
  substring(elem ->> ''period_start'', 1, 6) as treat_date,
  count(DISTINCT pat_id) AS count
FROM pat_unique,
     jsonb_array_elements(in_out_visit_history_info) AS elem
WHERE elem ->> ''move_in_out'' = ''11''
  AND elem ->> ''period_start'' >= @dateFrom
  AND elem ->> ''period_start'' <= @dateTo
  AND elem ->> ''facility_cd'' = @facilityCd
  AND is_del = ''0''
 group by substring(elem ->> ''period_start'', 1, 6)
 order by substring(elem ->> ''period_start'', 1, 6) asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

delete from sys_data_set where sql_cd = '-21036';
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-21036, 'SELECT
  substring(to_char(reg_exam_date, ''YYYYMMDD''), 1, 6) as treat_date,
  count(DISTINCT pat_id) AS count
FROM pat_exam_main
WHERE date(reg_exam_date) >= @dateFrom
  AND date(reg_exam_date) <= @dateTo
  AND is_del = ''0''
  AND facility_cd = @facilityCd
 group by substring(to_char(reg_exam_date, ''YYYYMMDD''), 1, 6)
 order by substring(to_char(reg_exam_date, ''YYYYMMDD''), 1, 6) asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

delete from sys_data_set where sql_cd = '-21037';
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-21037, 'SELECT
  substring(to_char(reg_rad_date, ''YYYYMMDD''), 1, 6) as treat_date,
  count(DISTINCT pat_id) AS count
FROM pat_rad_main
WHERE date(reg_rad_date) >= @dateFrom
  AND date(reg_rad_date) <= @dateTo
  AND is_del = ''0''
  AND facility_cd = @facilityCd
 group by substring(to_char(reg_rad_date, ''YYYYMMDD''), 1, 6)
 order by substring(to_char(reg_rad_date, ''YYYYMMDD''), 1, 6) asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

delete from sys_data_set where sql_cd = '-21041';
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-21041, 'WITH A AS (
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
    substring(treat_date, 1, 6) as treat_date,
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
group by substring(treat_date, 1, 6)
order by substring(treat_date, 1, 6) asc;', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

delete from sys_data_set where sql_cd = '-21042';
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-21042, 'WITH A AS (
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
    substring(treat_date, 1, 6) as treat_date,
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
group by substring(treat_date, 1, 6)
order by substring(treat_date, 1, 6) asc;', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

delete from sys_data_set where sql_cd = '-21046';
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-21046, 'select substring(treat_date, 1, 6) as treat_date, count(*) as count from ord_main
where treat_date between @dateFrom and @dateTo and facility_cd = @facilityCd and (ind_kur_cd is null or ind_kur_cd = 0) AND is_del = ''0'' and rst_dialysis_state = ''0'' and pat_id is not null
group by substring(treat_date, 1, 6)
order by substring(treat_date, 1, 6) asc ', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

delete from sys_data_set where sql_cd = '-21047';
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-21047, 'select substring(treat_date, 1, 6) as treat_date, count(*) as count from ord_main
where rst_dialysis_state = ''6'' AND treat_date between @dateFrom and @dateTo and facility_cd = @facilityCd and (rst_kur_cd is null or rst_kur_cd = 0) AND is_del = ''0'' and pat_id is not null
group by substring(treat_date, 1, 6)
order by substring(treat_date, 1, 6) asc ', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

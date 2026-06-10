DELETE FROM "ntss"."sys_data_set" where sql_cd in (-21012, -21041, -21014, -21042, -21015, -21016, -21046, -21007);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-21012, 'select substring(treat_date, 1, 6) as treat_date, count(*) as count from ord_main where treat_date between @dateFrom and @dateTo and facility_cd = @facilityCd AND is_del = ''0''  and pat_id is not null
group by substring(treat_date, 1, 6)
order by substring(treat_date, 1, 6) asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2023-07-17 21:01:37.092', '2023-07-17 21:01:37.092', NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-21041, 'WITH in_out AS (
    SELECT
        pat_id,
        inOutInfo ->> ''ctl_no'' AS ctl_no,
        inOutInfo ->> ''in_out'' AS in_out,
        inOutInfo ->> ''period_start'' AS startDate,
        COALESCE(LEAD(inOutInfo ->> ''period_start'') OVER (PARTITION BY pat_id ORDER BY inOutInfo ->> ''period_start''), ''99990101'' ) AS endDate
    FROM
        pat_unique
        CROSS JOIN LATERAL json_array_elements ( in_out_visit_history_info :: json ) inOutInfo
    WHERE
        is_del = ''0''
        AND facility_cd = @facilityCd
    )
SELECT
    substring(treat_date, 1, 6) as treat_date,
    COUNT( * ) AS COUNT
FROM
    ord_main
    LEFT JOIN in_out ON ord_main.pat_id = in_out.pat_id
				                and substring(treat_date, 1, 6) >= substring(in_out.startDate, 1, 6)
                    and substring(treat_date, 1, 6) < substring(in_out.endDate, 1, 6)
WHERE
    ord_main.treat_date BETWEEN @dateFrom AND @dateTo
    AND in_out.in_out = ''1''
    AND ord_main.facility_cd = @facilityCd
    AND ord_main.is_del = ''0''
    AND ord_main.pat_id is not null
group by substring(treat_date, 1, 6)
order by substring(treat_date, 1, 6) asc;', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2023-07-17 21:01:37.092', '2023-07-17 21:01:37.092', NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-21042, 'WITH in_out AS (
    SELECT
        pat_id,
        inOutInfo ->> ''ctl_no'' AS ctl_no,
        inOutInfo ->> ''in_out'' AS in_out,
        inOutInfo ->> ''period_start'' AS period_start
    FROM pat_unique CROSS JOIN LATERAL json_array_elements ( in_out_visit_history_info :: json ) inOutInfo
    WHERE is_del = ''0'' AND facility_cd = @facilityCd
  )
  ,in_out_period AS (
    SELECT
        pat_id,
        ctl_no,
        in_out,
        period_start,
		COALESCE( LEAD ( period_start, 1, NULL ) OVER ( PARTITION BY pat_id ORDER BY period_start ASC ), ''99990101'' ) AS period_end
    FROM in_out where period_start is not null 
  )
SELECT
    substring(treat_date, 1, 6) as treat_date,
    COUNT( * ) AS COUNT
FROM
    ord_main
    LEFT JOIN in_out_period i ON ord_main.pat_id = i.pat_id
WHERE
    ord_main.treat_date BETWEEN @dateFrom AND @dateTo
    AND (i.in_out <> ''1'' or i.in_out is null)
    AND ord_main.facility_cd = @facilityCd
    AND ord_main.is_del = ''0''
    AND ord_main.rst_dialysis_state = ''0'' and ord_main.pat_id is not null
group by substring(treat_date, 1, 6)
order by substring(treat_date, 1, 6) asc;', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2023-07-17 21:01:37.092', '2023-07-17 21:01:37.092', NULL);

INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-21014, 'select substring(ordMain.treat_date, 1, 6) as treat_date, count(*) as count from ord_main as ordMain left join mst_treatment as mstTreatment on ordMain.ind_treatment_cd = mstTreatment.treatment_cd
where mstTreatment.device_mode = ''9'' and ordMain.treat_date between @dateFrom and @dateTo and ordMain.facility_cd = @facilityCd AND ordMain.is_del = ''0'' and ordMain.pat_id is not null
group by substring(ordMain.treat_date, 1, 6)
order by substring(ordMain.treat_date, 1, 6) asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2023-07-17 21:01:37.092', '2023-07-17 21:01:37.092', NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-21015, 'select substring(treat_date, 1, 6) as treat_date, count(*) as count from ord_main
where treat_date between @dateFrom and @dateTo and facility_cd = @facilityCd and ind_treatment_cd = @id AND is_del = ''0'' and pat_id is not null group by substring(treat_date, 1, 6) order by substring(treat_date, 1, 6) asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2023-07-17 21:01:37.036', '2023-07-17 21:01:37.036', NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-21016, 'select substring(treat_date, 1, 6) as treat_date, count(*) as count from ord_main
where treat_date between @dateFrom and @dateTo and facility_cd = @facilityCd and ind_kur_cd = @id AND is_del = ''0'' and pat_id is not null group by substring(treat_date, 1, 6) order by substring(treat_date, 1, 6) asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2023-07-17 21:01:37.036', '2023-07-17 21:01:37.036', NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-21046, 'select substring(treat_date, 1, 6) as treat_date, count(*) as count from ord_main
where treat_date between @dateFrom and @dateTo and facility_cd = @facilityCd and (ind_kur_cd is null or ind_kur_cd = 0) AND is_del = ''0'' and pat_id is not null
group by substring(treat_date, 1, 6)
order by substring(treat_date, 1, 6) asc ', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2023-07-17 21:01:37.092', '2023-07-17 21:01:37.092', NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-21007, ' SELECT
   substring(treat_date, 1, 6) as treat_date, sum(count) as count
 from
   (select
      treat_date, sum(count) as count
    from
      ((select treat_date, count(*) as count from ord_main where (ind_cond_info->''5''->>''value'')::numeric = @id and treat_date between @dateFrom and @dateTo and is_del = ''0'' and facility_cd = @facilityCd and pat_id is not null group by treat_date)
        UNION ALL
       (select treat_date, sum((equipInfo->>''amount'')::numeric) as count from ord_main
         cross join lateral
           json_array_elements (ind_equip_info::json) equipInfo
           where (equipInfo->>''cd'')::numeric = @id and (equipInfo->>''equip_type'')::numeric = 1 and treat_date between @dateFrom and @dateTo and is_del = ''0'' and facility_cd = @facilityCd and pat_id is not null group by treat_date)
      ) t1
    group by treat_date
    order by treat_date asc
   ) t2
 group by substring(treat_date, 1, 6)
 order by substring(treat_date, 1, 6) asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2023-07-17 21:01:37.036', '2023-07-17 21:01:37.036', NULL);

DELETE FROM "ntss"."sys_data_set" where sql_cd in (-11012, -11041, -11042, -11013, -11014, -11016, -11046, -11007);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-11012, 'select treat_date, count(*) as count from ord_main where treat_date between @dateFrom and @dateTo and facility_cd = @facilityCd AND is_del = ''0'' and pat_id is not null group by treat_date order by treat_date asc ', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-07-31 18:29:49', '2023-08-16 21:08:44.271', NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-11041, 'WITH in_out AS (
    SELECT
        pat_id,
        inOutInfo ->> ''ctl_no'' AS ctl_no,
        inOutInfo ->> ''in_out'' AS in_out,
        inOutInfo ->> ''period_start'' AS startDate,
        COALESCE(LEAD(inOutInfo ->> ''period_start'') OVER (PARTITION BY pat_id ORDER BY inOutInfo ->> ''period_start''), ''99990101'' ) AS endDate
    FROM
        pat_unique
        CROSS JOIN LATERAL json_array_elements ( in_out_visit_history_info :: json ) inOutInfo
    WHERE
        is_del = ''0''
        AND facility_cd = @facilityCd
    )
SELECT
    treat_date,
    COUNT( * ) AS COUNT
FROM
    ord_main
    LEFT JOIN in_out ON ord_main.pat_id = in_out.pat_id
                    and ord_main.treat_date >= in_out.startDate 
                    and ord_main.treat_date < in_out.endDate
WHERE
    ord_main.treat_date BETWEEN @dateFrom AND @dateTo
    AND in_out.in_out = ''1''
    AND ord_main.facility_cd = @facilityCd
    AND ord_main.is_del = ''0''
    AND ord_main.pat_id is not null
group by treat_date
order by treat_date asc;', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-05-26 16:49:16', '2023-08-16 21:08:44.271', NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-11042, 'WITH in_out AS (
    SELECT
        pat_id,
        inOutInfo ->> ''ctl_no'' AS ctl_no,
        inOutInfo ->> ''in_out'' AS in_out,
        inOutInfo ->> ''period_start'' AS period_start
    FROM pat_unique CROSS JOIN LATERAL json_array_elements ( in_out_visit_history_info :: json ) inOutInfo
    WHERE is_del = ''0'' AND facility_cd = @facilityCd
  )
  ,in_out_period AS (
    SELECT
        pat_id,
        ctl_no,
        in_out,
        period_start,
		COALESCE( LEAD ( period_start, 1, NULL ) OVER ( PARTITION BY pat_id ORDER BY period_start ASC ), ''99990101'' ) AS period_end
    FROM in_out where period_start is not null 
  )
SELECT treat_date, COUNT( * ) AS COUNT
FROM ord_main
    LEFT JOIN in_out_period i ON ord_main.pat_id = i.pat_id and period_start<=period_end and ord_main.treat_date >= i.period_start and ord_main.treat_date < i.period_end
WHERE
    ord_main.treat_date BETWEEN @dateFrom AND @dateTo
    AND (i.in_out <> ''1'' or i.in_out is null)
    AND ord_main.facility_cd = @facilityCd
    AND ord_main.is_del = ''0''
    AND ord_main.pat_id is not null
group by treat_date
order by treat_date asc;', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-05-26 16:49:16', '2025-03-06 21:08:44.271', NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-11013, 'SELECT ordMain.treat_date as treat_date, count(*) as count
from
    ord_main as ordMain
    left join mst_treatment as mstTreatment on ordMain.ind_treatment_cd = mstTreatment.treatment_cd
where
    mstTreatment.device_mode != ''9''
 AND ordMain.treat_date between @dateFrom and @dateTo
 AND ordMain.facility_cd = @facilityCd
 AND ordMain.is_del = ''0''
 AND ordMain.pat_id is not null
group by ordMain.treat_date
order by ordMain.treat_date asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-07-31 18:29:49', '2023-08-16 21:08:44.271', NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-11014, 'select ordMain.treat_date as treat_date, count(*) as count from ord_main as ordMain left join mst_treatment as mstTreatment on ordMain.ind_treatment_cd = mstTreatment.treatment_cd
where mstTreatment.device_mode = ''9'' and ordMain.treat_date between @dateFrom and @dateTo and ordMain.facility_cd = @facilityCd AND ordMain.is_del = ''0''
 AND ordMain.pat_id is not null
 group by ordMain.treat_date
 order by ordMain.treat_date asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-07-31 18:29:49', '2023-08-16 21:08:44.271', NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-11016, 'select treat_date, count(*) as count from ord_main
where treat_date between @dateFrom and @dateTo and facility_cd = @facilityCd and ind_kur_cd = @id AND is_del = ''0'' and pat_id is not null group by treat_date order by treat_date asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-07-31 18:29:49', '2023-08-16 21:08:44.271', NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-11046, 'select treat_date, count(*) as count from ord_main 
 where treat_date between @dateFrom and @dateTo and facility_cd = @facilityCd and (ind_kur_cd is null or ind_kur_cd = 0) AND is_del = ''0'' and pat_id is not null
 group by treat_date
 order by treat_date asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-07-31 18:29:49', '2025-03-06 21:08:44.271', NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-11007, ' select
   treat_date, sum(count) as count
from
    ((select treat_date, count(*) as count from ord_main where (ind_cond_info->''5''->>''value'')::numeric = @id and treat_date between @dateFrom and @dateTo and is_del = ''0'' and facility_cd = @facilityCd and pat_id is not null group by treat_date)
    UNION ALL
    (select treat_date, sum((equipInfo->>''amount'')::numeric) as count from ord_main
    cross join lateral
    json_array_elements (ind_equip_info::json) equipInfo
    where (equipInfo->>''cd'')::numeric = @id and (equipInfo->>''equip_type'')::numeric = 1 and treat_date between @dateFrom and @dateTo and is_del = ''0'' and facility_cd = @facilityCd and pat_id is not null group by treat_date)
    ) t1
group by treat_date
order by treat_date asc ', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-07-31 18:29:49', '2023-08-16 21:08:44.271', NULL);

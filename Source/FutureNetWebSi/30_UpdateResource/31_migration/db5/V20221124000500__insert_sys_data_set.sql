delete from sys_data_set where sql_cd = '-21003';
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-21003, ' SELECT
   substring(treat_date, 1, 6) as treat_date, sum(count) as count
 from
   (select
      treat_date, sum(count) as count
    from
      ((select treat_date, count(*) as count from ord_main where  to_number(ind_cond_info->''25''->>''value'',''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo and is_del = ''0'' and facility_cd = @facilityCd and pat_id is not null group by treat_date)
        UNION ALL
       (select treat_date,
               case
                 when sum(to_number( mediInfo ->> ''amount'', ''9999999999999999999.9999999999999999999'' )) is not null then sum(to_number( mediInfo ->> ''amount'', ''9999999999999999999.9999999999999999999'' ))
                 else 0
               end as count from ord_main
         cross join lateral
           json_array_elements (ind_medi_info::json) mediInfo
           where to_number(mediInfo->>''cd'',''9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by treat_date)
      ) t1
    group by treat_date
    order by treat_date asc
   ) t2
 group by substring(treat_date, 1, 6)
 order by substring(treat_date, 1, 6) asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

delete from sys_data_set where sql_cd = '-21005';
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-21005, '
 SELECT
   substring(treat_date, 1, 6) as treat_date, sum(count) as count
 from
   (select
      treat_date, sum(count) as count
    from
      ((select treat_date, count(*) from ord_main where  to_number(ind_cond_info->''5''->>''value'',''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by treat_date)
        UNION ALL
       (select treat_date, count(*) from ord_main where  to_number(ind_cond_info->''6''->>''value'',''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by treat_date)
        UNION ALL
       (select treat_date, count(*) from ord_main where  to_number(ind_cond_info->''7''->>''value'',''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by treat_date)
        UNION ALL
       (select treat_date, count(*) from ord_main where  to_number(ind_cond_info->''8''->>''value'',''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by treat_date)
        UNION ALL
       (select treat_date, count(*) from ord_main where  to_number(ind_cond_info->''9''->>''value'',''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by treat_date)
        UNION ALL
       (select treat_date, count(*) from ord_main where  to_number(ind_cond_info->''10''->>''value'',''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by treat_date)
        UNION ALL
       (select treat_date, count(*) from ord_main where  to_number(ind_cond_info->''11''->>''value'',''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by treat_date)
        UNION ALL
       (select treat_date, count(*) from ord_main where  to_number(ind_cond_info->''12''->>''value'',''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by treat_date)
        UNION ALL
       (select treat_date, count(*) from ord_main where  to_number(ind_cond_info->''13''->>''value'',''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by treat_date)
        UNION ALL
       (select treat_date,
               case
                 when sum(to_number(equipInfo->>''amount'',''9999999999999999999.9999999999999999999'')) is not null then sum(to_number(equipInfo->>''amount'',''9999999999999999999.9999999999999999999''))
                 else 0
               end
        from ord_main
           cross join lateral
             json_array_elements (ind_equip_info::json) equipInfo
             where to_number(equipInfo->>''cd'',''9999999999999999999'')  = @id and to_number(equipInfo->>''equip_type'',''9'') = 0 and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by treat_date)
      ) t1
    group by treat_date
    order by treat_date asc
   ) t2
 group by substring(treat_date, 1, 6)
 order by substring(treat_date, 1, 6) asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

delete from sys_data_set where sql_cd = '-21007';
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-21007, '
 SELECT
   substring(treat_date, 1, 6) as treat_date, sum(count) as count
 from
   (select
      treat_date, sum(count) as count
    from
      ((select treat_date, count(*) as count from ord_main where to_number(ind_cond_info->''5''->>''value'',''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo and is_del = ''0'' and facility_cd = @facilityCd and pat_id is not null group by treat_date)
        UNION ALL
       (select treat_date, count(*) as count from ord_main
         cross join lateral
           json_array_elements (ind_equip_info::json) equipInfo
           where to_number(equipInfo->>''cd'',''9999999999999999999'') = @id and to_number(equipInfo->>''equip_type'',''9'') = 1 and treat_date between @dateFrom and @dateTo and is_del = ''0'' and facility_cd = @facilityCd and pat_id is not null group by treat_date)
      ) t1
    group by treat_date
    order by treat_date asc
   ) t2
 group by substring(treat_date, 1, 6)
 order by substring(treat_date, 1, 6) asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

delete from sys_data_set where sql_cd = '-21045';
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-21045, 'WITH exchange AS ( SELECT unit_converted_amount, unit_converted_amount_second, is_exchange FROM mst_medicine WHERE medicine_cd = @id AND is_del = ''0'' AND facility_cd = @facilityCd
),
ord1 AS (SELECT
             substring(treat_date, 1, 6) as treat_date,
             COUNT(*) as ord1
         FROM
             ord_main
         WHERE
             to_number(ind_cond_info -> ''25'' ->> ''value'', ''9999999999999999999'' ) = @id
             AND treat_date BETWEEN @dateFrom AND @dateTo
             AND is_del = ''0''
             AND facility_cd = @facilityCd
             AND pat_id is not null
         group by substring(treat_date, 1, 6)
),
ord2 AS (SELECT
             substring(treat_date, 1, 6) as treat_date,
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
         group by substring(treat_date, 1, 6)
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
 order by treat_date asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

delete from sys_data_set where sql_cd = '-21009';
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-21009, ' SELECT
   substring(treat_date, 1, 6) as treat_date, sum(count) as count
 from
   (select
      treat_date, sum(count) as count
    from
      ((select treat_date, count(*) as count from ord_main where  to_number(rst_cond_info->''25''->>''value'',''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo and is_del = ''0'' and facility_cd = @facilityCd and pat_id is not null group by treat_date)
        UNION ALL
       (select treat_date,
               case
                 when sum(to_number( mediInfo ->> ''amount'', ''9999999999999999999.9999999999999999999'' )) is not null then sum(to_number( mediInfo ->> ''amount'', ''9999999999999999999.9999999999999999999'' ))
                 else 0
               end as count from ord_main
         cross join lateral
           json_array_elements (rst_medi_info::json) mediInfo
           where to_number(mediInfo->>''cd'',''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by treat_date)
        UNION ALL
       (select treat_date,
               case
                 when sum(to_number( mediInfo ->> ''amount'', ''9999999999999999999.9999999999999999999'' )) is not null then sum(to_number( mediInfo ->> ''amount'', ''9999999999999999999.9999999999999999999'' ))
                 else 0
               end as count from ord_main
         cross join lateral
           json_array_elements (rst_treatment_info::json) mediInfo
           where to_number(mediInfo->>''treat_medicine_cd'',''9999999999999999999.9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by treat_date)
      ) t1
    group by treat_date
    order by treat_date asc
   ) t2
 group by substring(treat_date, 1, 6)
 order by substring(treat_date, 1, 6) asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

delete from sys_data_set where sql_cd = '-21010';
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-21010, '
 SELECT
   substring(treat_date, 1, 6) as treat_date, sum(count) as count
 from
   (select
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
    order by treat_date asc
   ) t2
 group by substring(treat_date, 1, 6)
 order by substring(treat_date, 1, 6) asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

delete from sys_data_set where sql_cd = '-21011';
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-21011, '
 SELECT
   substring(treat_date, 1, 6) as treat_date, sum(count) as count
 from
   (select
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
    order by treat_date asc
   ) t2
 group by substring(treat_date, 1, 6)
 order by substring(treat_date, 1, 6) asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

delete from sys_data_set where sql_cd = '-21043';
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-21043, 'WITH exchange AS ( SELECT unit_converted_amount, unit_converted_amount_second, is_exchange FROM mst_medicine WHERE medicine_cd = @id AND is_del = ''0'' AND facility_cd = @facilityCd
),
ord1 AS (SELECT
             substring(treat_date, 1, 6) as treat_date,
             COUNT(*) as ord1
         FROM
             ord_main
         WHERE
             to_number(rst_cond_info -> ''25'' ->> ''value'', ''9999999999999999999'' ) = @id
             AND treat_date BETWEEN @dateFrom AND @dateTo
             AND is_del = ''0''
             AND facility_cd = @facilityCd
             AND pat_id is not null
         group by substring(treat_date, 1, 6)
),
ord2 AS (SELECT
             substring(treat_date, 1, 6) as treat_date,
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
         group by substring(treat_date, 1, 6)
),
ord3 AS (SELECT
             substring(treat_date, 1, 6) as treat_date,
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
         group by substring(treat_date, 1, 6)
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
 order by treat_date asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

delete from sys_data_set where sql_cd = '-21015';
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-21015, 'select substring(treat_date, 1, 6) as treat_date, count(*) as count from ord_main
where treat_date between @dateFrom and @dateTo and facility_cd = @facilityCd and ind_treatment_cd = @id AND is_del = ''0'' and rst_dialysis_state = ''0'' and pat_id is not null group by substring(treat_date, 1, 6) order by substring(treat_date, 1, 6) asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

delete from sys_data_set where sql_cd = '-21016';
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-21016, 'select substring(treat_date, 1, 6) as treat_date, count(*) as count from ord_main
where treat_date between @dateFrom and @dateTo and facility_cd = @facilityCd and ind_kur_cd = @id AND is_del = ''0'' and rst_dialysis_state = ''0'' and pat_id is not null group by substring(treat_date, 1, 6) order by substring(treat_date, 1, 6) asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

delete from sys_data_set where sql_cd = '-21022';
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-21022, 'select substring(treat_date, 1, 6) as treat_date, count(*) as count from ord_main
where rst_dialysis_state = ''6'' AND treat_date between @dateFrom and @dateTo and facility_cd = @facilityCd and rst_treatment_cd = @id AND is_del = ''0'' and pat_id is not null group by substring(treat_date, 1, 6) order by substring(treat_date, 1, 6) asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

delete from sys_data_set where sql_cd = '-21023';
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-21023, 'select substring(treat_date, 1, 6) as treat_date, count(*) as count from ord_main
where rst_dialysis_state = ''6'' AND treat_date between @dateFrom and @dateTo and facility_cd = @facilityCd and rst_kur_cd = @id AND is_del = ''0'' and pat_id is not null group by substring(treat_date, 1, 6) order by substring(treat_date, 1, 6) asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

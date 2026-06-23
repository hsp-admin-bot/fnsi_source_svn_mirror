UPDATE "ntss"."sys_data_set"
SET "sql" = ' select
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
order by treat_date asc ',
    "up_date" = CURRENT_TIMESTAMP
WHERE "sql_cd" = -11003;

UPDATE "ntss"."sys_data_set"
SET "sql" = ' select
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
order by treat_date asc ',
    "up_date" = CURRENT_TIMESTAMP
WHERE "sql_cd" = -11005;

UPDATE "ntss"."sys_data_set"
SET "sql" = ' select
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
order by treat_date asc ',
    "up_date" = CURRENT_TIMESTAMP
WHERE "sql_cd" = -11007;

UPDATE "ntss"."sys_data_set"
SET "sql" = ' select
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
 order by treat_date asc',
    "up_date" = CURRENT_TIMESTAMP
WHERE "sql_cd" = -11009;

UPDATE "ntss"."sys_data_set"
SET "sql" = ' select
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
 order by treat_date asc',
    "up_date" = CURRENT_TIMESTAMP
WHERE "sql_cd" = -11010;

UPDATE "ntss"."sys_data_set"
SET "sql" = ' select
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
 order by treat_date asc',
    "up_date" = CURRENT_TIMESTAMP
WHERE "sql_cd" = -11011;

UPDATE "ntss"."sys_data_set"
SET "sql" = 'SELECT ordMain.treat_date as treat_date, count(*) as count
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
order by ordMain.treat_date asc',
    "up_date" = CURRENT_TIMESTAMP
WHERE "sql_cd" = -11013;

UPDATE "ntss"."sys_data_set"
SET "sql" = 'select treat_date, count(*) as count from ord_main
where treat_date between @dateFrom and @dateTo and facility_cd = @facilityCd and ind_treatment_cd = @id AND is_del = ''0'' and rst_dialysis_state = ''0'' and pat_id is not null group by treat_date order by treat_date asc',
    "up_date" = CURRENT_TIMESTAMP
WHERE "sql_cd" = -11015;

UPDATE "ntss"."sys_data_set"
SET "sql" = 'select treat_date, count(*) as count from ord_main
where treat_date between @dateFrom and @dateTo and facility_cd = @facilityCd and ind_kur_cd = @id AND is_del = ''0'' and rst_dialysis_state = ''0'' and pat_id is not null group by treat_date order by treat_date asc',
    "up_date" = CURRENT_TIMESTAMP
WHERE "sql_cd" = -11016;

UPDATE "ntss"."sys_data_set"
SET "sql" = 'select treat_date, count(*) as count from ord_main
where rst_dialysis_state = ''6'' AND treat_date between @dateFrom and @dateTo and facility_cd = @facilityCd and rst_treatment_cd = @id AND is_del = ''0'' and pat_id is not null group by treat_date order by treat_date asc',
    "up_date" = CURRENT_TIMESTAMP
WHERE "sql_cd" = -11022;

UPDATE "ntss"."sys_data_set"
SET "sql" = 'select treat_date, count(*) as count from ord_main
where rst_dialysis_state = ''6'' AND treat_date between @dateFrom and @dateTo and facility_cd = @facilityCd and rst_kur_cd = @id AND is_del = ''0'' and pat_id is not null group by treat_date order by treat_date asc',
    "up_date" = CURRENT_TIMESTAMP
WHERE "sql_cd" = -11023;

UPDATE "ntss"."sys_data_set"
SET "sql" = 'SELECT e.event_start_date as treat_date, count(DISTINCT e.pat_id) AS count
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
order by treat_date asc',
    "up_date" = CURRENT_TIMESTAMP
WHERE "sql_cd" = -11038;

UPDATE "ntss"."sys_data_set"
SET "sql" = 'SELECT treat_date, COUNT( * ) AS count
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
order by treat_date asc',
    "up_date" = CURRENT_TIMESTAMP
WHERE "sql_cd" = -11039;

UPDATE "ntss"."sys_data_set"
SET "sql" = 'WITH A AS (
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
order by treat_date asc;',
    "up_date" = CURRENT_TIMESTAMP
WHERE "sql_cd" = -11041;

UPDATE "ntss"."sys_data_set"
SET "sql" = 'WITH A AS (
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
order by treat_date asc;',
    "up_date" = CURRENT_TIMESTAMP
WHERE "sql_cd" = -11042;

UPDATE "ntss"."sys_data_set"
SET "sql" = 'WITH exchange AS ( SELECT unit_converted_amount, unit_converted_amount_second, is_exchange FROM mst_medicine WHERE medicine_cd = @id AND is_del = ''0'' AND facility_cd = @facilityCd
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
 order by treat_date asc',
    "up_date" = CURRENT_TIMESTAMP
WHERE "sql_cd" = -11043;

UPDATE "ntss"."sys_data_set"
SET "sql" = 'WITH exchange AS ( SELECT unit_converted_amount, unit_converted_amount_second, is_exchange FROM mst_medicine WHERE medicine_cd = @id AND is_del = ''0'' AND facility_cd = @facilityCd
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
 order by treat_date asc',
    "up_date" = CURRENT_TIMESTAMP
WHERE "sql_cd" = -11045;
DELETE FROM "ntss"."sys_data_set" where sql_cd in (-11011, -11015, -11046, -11042);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info")
 VALUES (-11011,
'select
   treat_date, sum(count) as count
 from
   ((select treat_date, count(*) as count
   from ord_main where (rst_cond_info->''5''->>''value'')::numeric = @id and treat_date between @dateFrom and @dateTo and is_del = ''0'' and facility_cd = @facilityCd and pat_id is not null group by treat_date)
     UNION ALL
    (select treat_date, sum((equipInfo->>''amount'')::numeric) AS COUNT from ord_main
      cross join lateral
        json_array_elements (rst_equip_info::json) equipInfo
        where (equipInfo->>''cd'')::numeric = @id and (equipInfo->>''equip_type'')::numeric = 1 and treat_date between @dateFrom and @dateTo and is_del = ''0'' and facility_cd = @facilityCd and pat_id is not null group by treat_date)
   ) t1
 group by treat_date
 order by treat_date asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-07-31 18:29:49', '2025-03-06 16:08:44.271', NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info")
 VALUES (-11015,
'select treat_date, count(*) as count from ord_main
 where treat_date between @dateFrom and @dateTo and facility_cd = @facilityCd and ind_treatment_cd = @id AND is_del = ''0''
 and (rst_dialysis_state between ''0'' and ''6'') and pat_id is not null
 group by treat_date order by treat_date asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-07-31 18:29:49', '2025-03-06 21:08:44.271', NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info")
 VALUES (-11046,
'select treat_date, count(*) as count from ord_main 
 where treat_date between @dateFrom and @dateTo and facility_cd = @facilityCd and (ind_kur_cd is null or ind_kur_cd = 0) AND is_del = ''0''
  and rst_dialysis_state = ''0'' and pat_id is not null
 group by treat_date
 order by treat_date asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-07-31 18:29:49', '2025-03-06 21:08:44.271', NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info")
 VALUES (-11042,
'WITH in_out AS (
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
		COALESCE( LEAD ( period_start, 1, NULL ) OVER ( PARTITION BY pat_id ORDER BY pat_id,ctl_no, period_start ASC ), ''99990101'' ) AS period_end
    FROM in_out where period_start is not null 
  )
SELECT treat_date, COUNT( * ) AS COUNT
FROM ord_main
    LEFT JOIN in_out_period i ON ord_main.pat_id = i.pat_id and period_start<=period_end and ord_main.treat_date between i.period_start and i.period_end
WHERE
    ord_main.treat_date BETWEEN @dateFrom AND @dateTo
    AND (i.in_out <> ''1'' or i.in_out is null)
    AND ord_main.facility_cd = @facilityCd
    AND ord_main.is_del = ''0''
    AND ord_main.rst_dialysis_state = ''0'' and ord_main.pat_id is not null
group by treat_date
order by treat_date asc;', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-05-26 16:49:16', '2025-03-06 21:08:44.271', NULL);

DELETE FROM "ntss"."sys_data_set" where sql_cd in (-21011, -21013, -21042);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info")
VALUES (-21011
, 'SELECT
   substring(treat_date, 1, 6) as treat_date, sum(count) as count
 from
   (select
      treat_date, sum(count) as count
    from
      ((select treat_date, count(*) as count
	  from ord_main where (rst_cond_info->''5''->>''value'')::numeric = @id and treat_date between @dateFrom and @dateTo and is_del = ''0'' and facility_cd = @facilityCd and pat_id is not null group by treat_date)
        UNION ALL
       (select treat_date, sum((equipInfo->>''amount'')::numeric) AS count from ord_main
         cross join lateral
           json_array_elements (rst_equip_info::json) equipInfo
           where (equipInfo->>''cd'')::numeric = @id and (equipInfo->>''equip_type'')::numeric = 1 and treat_date between @dateFrom and @dateTo and is_del = ''0'' and facility_cd = @facilityCd and pat_id is not null group by treat_date)
      ) t1
    group by treat_date
    order by treat_date asc
   ) t2
 group by substring(treat_date, 1, 6)
 order by substring(treat_date, 1, 6) asc', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2023-07-17 21:01:37.036', '2023-07-17 21:01:37.036', NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info")
VALUES (-21013
, 'SELECT substring(ordMain.treat_date, 1, 6) as treat_date, count(*) as count
from ord_main as ordMain left join mst_treatment as mstTreatment on ordMain.ind_treatment_cd = mstTreatment.treatment_cd
where mstTreatment.device_mode != ''9''
 AND ordMain.treat_date between @dateFrom and @dateTo AND ordMain.facility_cd = @facilityCd AND ordMain.is_del = ''0''
 AND (ordMain.rst_dialysis_state between ''0'' and ''6'')
 AND ordMain.pat_id is not null
group by substring(ordMain.treat_date, 1, 6)
order by substring(ordMain.treat_date, 1, 6) asc;', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2023-07-17 21:01:37.092', '2023-07-17 21:01:37.092', NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info")
VALUES (-21042
, 'WITH in_out AS (
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
		COALESCE( LEAD ( period_start, 1, NULL ) OVER ( PARTITION BY pat_id ORDER BY pat_id,ctl_no, period_start ASC ), ''99990101'' ) AS period_end
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

DELETE FROM "ntss"."sys_data_set" where sql_cd in (-11044);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info")
VALUES (-11044, 'select unit_second as unit from mst_medicine where medicine_cd = @id AND facility_cd = @facilityCd', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-07-31 18:29:49', '2020-07-31 18:29:49', NULL);
DELETE FROM "ntss"."sys_data_set" where sql_cd in (-11043, -11045, -21043, -21045, -11003, -21003, -21009, -11009);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info")
VALUES (-21045
, 'SELECT
	substring(supplies_base_date, 1, 6) AS treat_date,
	SUM(receipt_value::NUMERIC) AS COUNT 
FROM ord_material_save 
WHERE facility_cd = @facilityCd
	AND supplies_cd=@id::TEXT
	AND ind_rst_class = ''1'' 
	AND pat_id IS NOT NULL
	--<>調製薬剤,処置調製薬剤,抗凝固剤調製薬剤（調製薬剤）
	AND supplies_class NOT IN (''13'', ''15'', ''17'') 
	AND supplies_base_date BETWEEN @dateFrom AND @dateTo
GROUP BY substring(supplies_base_date, 1, 6) 
ORDER BY substring(supplies_base_date, 1, 6) ASC', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2023-07-17 21:01:37.036', '2025-03-06 21:01:37.036', NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info")
VALUES (-11045
, 'SELECT
	supplies_base_date AS treat_date,
	SUM(receipt_value::NUMERIC) AS COUNT 
FROM ord_material_save 
WHERE facility_cd = @facilityCd
	AND supplies_cd=@id::TEXT
	AND ind_rst_class = ''1'' 
	AND pat_id IS NOT NULL
	--<>調製薬剤,処置調製薬剤,抗凝固剤調製薬剤（調製薬剤）
	AND supplies_class NOT IN (''13'', ''15'', ''17'') 
	AND supplies_base_date BETWEEN @dateFrom AND @dateTo
GROUP BY supplies_base_date 
ORDER BY supplies_base_date ASC', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-07-31 18:29:49', '2025-03-06 21:08:44.271', NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info")
VALUES (-21043
, 'SELECT
	substring(supplies_base_date, 1, 6) AS treat_date,
	SUM(receipt_value::NUMERIC) AS COUNT 
FROM ord_material_save 
WHERE facility_cd = @facilityCd
	AND supplies_cd=@id::TEXT
	AND ind_rst_class = ''2'' 
	AND pat_id IS NOT NULL
	--<>調製薬剤,処置調製薬剤,抗凝固剤調製薬剤（調製薬剤）
	AND supplies_class NOT IN ( ''13'', ''15'', ''17'' ) 
	AND supplies_base_date BETWEEN @dateFrom AND @dateTo
GROUP BY substring(supplies_base_date, 1, 6) 
ORDER BY substring(supplies_base_date, 1, 6) ASC', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2023-07-17 21:01:37.036', '2025-03-06 21:01:37.036', NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info")
VALUES (-11043
, 'SELECT
	supplies_base_date AS treat_date,
	SUM(receipt_value::NUMERIC) AS COUNT 
FROM ord_material_save 
WHERE facility_cd = @facilityCd
	AND supplies_cd=@id::TEXT
	AND ind_rst_class = ''2'' 
	AND pat_id IS NOT NULL
	--<>調製薬剤,処置調製薬剤,抗凝固剤調製薬剤（調製薬剤）
	AND supplies_class NOT IN ( ''13'', ''15'', ''17'' ) 
	AND supplies_base_date BETWEEN @dateFrom AND @dateTo
GROUP BY supplies_base_date 
ORDER BY supplies_base_date ASC', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-07-31 18:29:49', '2025-03-06 21:08:44.271', NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info")
VALUES (-21003
, 'SELECT
	substring(supplies_base_date, 1, 6) AS treat_date,
	SUM(ind_rst_value::NUMERIC) AS COUNT 
FROM ord_material_save 
WHERE facility_cd = @facilityCd
	AND supplies_cd=@id::TEXT
	AND ind_rst_class = ''1'' 
	AND pat_id IS NOT NULL
	--<>調製薬剤,処置調製薬剤,抗凝固剤調製薬剤（調製薬剤）
	AND supplies_class NOT IN ( ''20'', ''21'', ''22'' ) 
	AND supplies_base_date BETWEEN @dateFrom AND @dateTo
GROUP BY substring(supplies_base_date, 1, 6) 
ORDER BY substring(supplies_base_date, 1, 6)  ASC', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2023-07-17 21:01:37.036', '2025-03-06 21:01:37.036', NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info")
VALUES (-11003
, 'SELECT
	supplies_base_date AS treat_date,
	SUM(ind_rst_value::NUMERIC) AS COUNT 
FROM ord_material_save 
WHERE facility_cd = @facilityCd
	AND supplies_cd=@id::TEXT
	AND ind_rst_class = ''1'' 
	AND pat_id IS NOT NULL
	--<>調製薬剤,処置調製薬剤,抗凝固剤調製薬剤（調製薬剤）
	AND supplies_class NOT IN ( ''20'', ''21'', ''22'' ) 
	AND supplies_base_date BETWEEN @dateFrom AND @dateTo
GROUP BY supplies_base_date 
ORDER BY supplies_base_date ASC', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-07-31 18:29:49', '2025-03-06 21:08:44.271', NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info")
VALUES (-11009
, 'SELECT
	supplies_base_date AS treat_date,
	SUM(ind_rst_value::NUMERIC) AS COUNT 
FROM ord_material_save 
WHERE facility_cd = @facilityCd
	AND supplies_cd=@id::TEXT
	AND ind_rst_class = ''2'' 
	AND pat_id IS NOT NULL
	--<>調製薬剤,処置調製薬剤,抗凝固剤調製薬剤（調製薬剤）
	AND supplies_class NOT IN ( ''20'', ''21'', ''22'' ) 
	AND supplies_base_date BETWEEN @dateFrom AND @dateTo
GROUP BY supplies_base_date 
ORDER BY supplies_base_date ASC', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-07-31 18:29:49', '2025-03-06 21:08:44.271', NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info")
VALUES (-21009
, 'SELECT
	substring(supplies_base_date, 1, 6) AS treat_date,
	SUM(ind_rst_value::NUMERIC) AS COUNT 
FROM ord_material_save 
WHERE facility_cd = @facilityCd
	AND supplies_cd=@id::TEXT
	AND ind_rst_class = ''2'' 
	AND pat_id IS NOT NULL
	--<>調製薬剤,処置調製薬剤,抗凝固剤調製薬剤（調製薬剤）
	AND supplies_class NOT IN ( ''20'', ''21'', ''22'' ) 
	AND supplies_base_date BETWEEN @dateFrom AND @dateTo
GROUP BY substring(supplies_base_date, 1, 6) 
ORDER BY substring(supplies_base_date, 1, 6)  ASC', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2023-07-17 21:01:37.036', '2025-03-06 21:01:37.036', NULL);

DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-11044,-21045,-21003,-11004,-21005,-11006,-21007,-21043,-21009,-21010,-21023,-21022,-21016,-21011,-21015,-21039);

DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-11045,-11003,-11005,-11007,-11043,-11009,-11010,-11042,-11041,-11012,-11011,-11015,-11014,-11013,-11022,-11021,-11020,-11019,-11046,-11018,-11017,-11016,-11035,-11038,-11037,-11036,-11023,-11034,-11033,-11039);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-11007, ' select
   cd,treat_date, sum(count) as count
from
    ((select (ind_cond_info->''5''->>''value'')::numeric cd, treat_date, count(*) as count from ord_main where (ind_cond_info->''5''->>''value'')::numeric in (@idStrArr) and treat_date between @dateFrom and @dateTo and is_del = ''0'' and facility_cd = @facilityCd and pat_id is not null group by (ind_cond_info->''5''->>''value'')::numeric,treat_date)
    UNION ALL
    (select (equipInfo->>''cd'')::numeric cd,treat_date, sum((equipInfo->>''amount'')::numeric) as count from ord_main
    cross join lateral
    json_array_elements (ind_equip_info::json) equipInfo
    where (equipInfo->>''cd'')::numeric in (@idStrArr) and (equipInfo->>''equip_type'')::numeric = 1 and treat_date between @dateFrom and @dateTo and is_del = ''0'' and facility_cd = @facilityCd and pat_id is not null group by (equipInfo->>''cd'')::numeric,treat_date)
    ) t1
group by cd,treat_date
order by treat_date asc ', 2, '[]'::jsonb, '0', '{"applications": []}'::jsonb, '{"classes": []}'::jsonb, 'データリスト', '2020-07-31 18:29:49.000', '2023-08-16 21:08:44.271', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-21045, 'SELECT
	supplies_cd cd,
	substring(supplies_base_date, 1, 6) AS treat_date,
	SUM(receipt_value::NUMERIC) AS COUNT 
FROM ord_material_save 
WHERE facility_cd = @facilityCd
	AND supplies_cd in (@idStrArr)
	AND ind_rst_class = ''1'' 
	AND pat_id IS NOT NULL
	--<>調製薬剤,処置調製薬剤,抗凝固剤調製薬剤（調製薬剤）
	AND supplies_class NOT IN (''13'', ''15'', ''17'') 
	AND supplies_base_date BETWEEN @dateFrom AND @dateTo
GROUP BY supplies_cd,substring(supplies_base_date, 1, 6) 
ORDER BY substring(supplies_base_date, 1, 6) ASC', 2, '[]'::jsonb, '0', '{"applications": []}'::jsonb, '{"classes": []}'::jsonb, 'データリスト', '2023-07-17 21:01:37.036', '2025-03-06 21:01:37.036', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-21003, 'SELECT
	supplies_cd cd,
	substring(supplies_base_date, 1, 6) AS treat_date,
	SUM(ind_rst_value::NUMERIC) AS COUNT 
FROM ord_material_save 
WHERE facility_cd = @facilityCd
	AND supplies_cd in (@idStrArr)
	AND ind_rst_class = ''1'' 
	AND pat_id IS NOT NULL
	--<>調製薬剤,処置調製薬剤,抗凝固剤調製薬剤（調製薬剤）
	AND supplies_class NOT IN ( ''20'', ''21'', ''22'' ) 
	AND supplies_base_date BETWEEN @dateFrom AND @dateTo
GROUP BY supplies_cd,substring(supplies_base_date, 1, 6) 
ORDER BY substring(supplies_base_date, 1, 6)  ASC', 2, '[]'::jsonb, '0', '{"applications": []}'::jsonb, '{"classes": []}'::jsonb, 'データリスト', '2023-07-17 21:01:37.036', '2025-03-06 21:01:37.036', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-21005, 'WITH filtered_orders AS (
  SELECT 
    ind_cond_info,
    ind_equip_info,
    treat_date
  FROM ord_main 
  WHERE treat_date BETWEEN @dateFrom AND @dateTo 
    AND is_del = ''0'' 
    AND facility_cd = @facilityCd 
    AND pat_id IS NOT NULL
),
cond_data AS (
  SELECT 
    to_number(value, ''9999999999999999999.9999999999999999999'') as cd,
    treat_date,
    COUNT(*) as count
  FROM filtered_orders,
  LATERAL (
    VALUES 
      (ind_cond_info->''5''->>''value''),
      (ind_cond_info->''6''->>''value''),
      (ind_cond_info->''7''->>''value''),
      (ind_cond_info->''8''->>''value''),
      (ind_cond_info->''9''->>''value''),
      (ind_cond_info->''10''->>''value''),
      (ind_cond_info->''11''->>''value''),
      (ind_cond_info->''12''->>''value''),
      (ind_cond_info->''13''->>''value'')
  ) AS t(value)
  WHERE to_number(value, ''9999999999999999999.9999999999999999999'') IN (@idStrArr)
    AND value IS NOT NULL
  GROUP BY cd, treat_date
),
equip_data AS (
  SELECT 
    to_number(equipInfo->>''cd'', ''9999999999999999999'') as cd,
    treat_date,
    COALESCE(SUM(to_number(equipInfo->>''amount'', ''9999999999999999999.9999999999999999999'')), 0) as count
  FROM filtered_orders
  CROSS JOIN LATERAL json_array_elements(ind_equip_info::json) equipInfo
  WHERE to_number(equipInfo->>''cd'', ''9999999999999999999'') IN (@idStrArr)
    AND to_number(equipInfo->>''equip_type'', ''9'') = 0
  GROUP BY cd, treat_date
),
combined_data AS (
  SELECT cd, treat_date, count FROM cond_data
  UNION ALL
  SELECT cd, treat_date, count FROM equip_data
)
SELECT 
  cd,
  SUBSTRING(treat_date, 1, 6) as treat_month,
  SUM(count) as count
FROM combined_data
GROUP BY cd, SUBSTRING(treat_date, 1, 6)
ORDER BY cd, treat_month ASC;', 2, '[]'::jsonb, '0', '{"applications": []}'::jsonb, '{"classes": []}'::jsonb, 'データリスト', '2023-07-17 21:01:37.036', '2023-07-17 21:01:37.036', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-21007, ' SELECT
   cd,substring(treat_date, 1, 6) as treat_date, sum(count) as count
 from
   (select
      cd,treat_date, sum(count) as count
    from
      ((select ind_cond_info->''5''->>''value'' cd, treat_date, count(*) as count from ord_main where (ind_cond_info->''5''->>''value'') in (@idStrArr) and treat_date between @dateFrom and @dateTo and is_del = ''0'' and facility_cd = @facilityCd and pat_id is not null group by cd,treat_date)
        UNION ALL
       (select equipInfo->>''cd'' cd,treat_date, sum((equipInfo->>''amount'')::numeric) as count from ord_main
         cross join lateral
           json_array_elements (ind_equip_info::json) equipInfo
           where (equipInfo->>''cd'') in (@idStrArr) and (equipInfo->>''equip_type'')::numeric = 1 and treat_date between @dateFrom and @dateTo and is_del = ''0'' and facility_cd = @facilityCd and pat_id is not null group by cd,treat_date)
      ) t1
    group by cd,treat_date
    order by treat_date asc
   ) t2
 group by cd,substring(treat_date, 1, 6)
 order by substring(treat_date, 1, 6) asc', 2, '[]'::jsonb, '0', '{"applications": []}'::jsonb, '{"classes": []}'::jsonb, 'データリスト', '2023-07-17 21:01:37.036', '2023-07-17 21:01:37.036', NULL);
 
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-21043, 'SELECT
	supplies_cd cd,
	substring(supplies_base_date, 1, 6) AS treat_date,
	SUM(receipt_value::NUMERIC) AS COUNT 
FROM ord_material_save 
WHERE facility_cd = @facilityCd
	AND supplies_cd in (@idStrArr)
	AND ind_rst_class = ''2'' 
	AND pat_id IS NOT NULL
	--<>調製薬剤,処置調製薬剤,抗凝固剤調製薬剤（調製薬剤）
	AND supplies_class NOT IN ( ''13'', ''15'', ''17'' ) 
	AND supplies_base_date BETWEEN @dateFrom AND @dateTo
GROUP BY supplies_cd,substring(supplies_base_date, 1, 6)
ORDER BY substring(supplies_base_date, 1, 6) ASC', 2, '[]'::jsonb, '0', '{"applications": []}'::jsonb, '{"classes": []}'::jsonb, 'データリスト', '2023-07-17 21:01:37.036', '2025-03-06 21:01:37.036', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-21009, 'SELECT
	supplies_cd cd,
	substring(supplies_base_date, 1, 6) AS treat_date,
	SUM(ind_rst_value::NUMERIC) AS COUNT 
FROM ord_material_save 
WHERE facility_cd = @facilityCd
	AND supplies_cd in (@idStrArr)
	AND ind_rst_class = ''2'' 
	AND pat_id IS NOT NULL
	--<>調製薬剤,処置調製薬剤,抗凝固剤調製薬剤（調製薬剤）
	AND supplies_class NOT IN ( ''20'', ''21'', ''22'' ) 
	AND supplies_base_date BETWEEN @dateFrom AND @dateTo
GROUP BY supplies_cd,substring(supplies_base_date, 1, 6) 
ORDER BY substring(supplies_base_date, 1, 6)  ASC', 2, '[]'::jsonb, '0', '{"applications": []}'::jsonb, '{"classes": []}'::jsonb, 'データリスト', '2023-07-17 21:01:37.036', '2025-03-06 21:01:37.036', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-21010, 'SELECT
   cd,substring(treat_date, 1, 6) as treat_date, sum(count) as count
 from
   (select
      cd,treat_date, sum(count) as count
    from
      ((select to_number(rst_cond_info->''5''->>''value'',''9999999999999999999.9999999999999999999'') cd,treat_date, count(*) from ord_main where  to_number(rst_cond_info->''5''->>''value'',''9999999999999999999.9999999999999999999'') in (@idStrArr) and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by cd,treat_date)
        UNION ALL
       (select to_number(rst_cond_info->''6''->>''value'',''9999999999999999999.9999999999999999999'') cd,treat_date, count(*) from ord_main where  to_number(rst_cond_info->''6''->>''value'',''9999999999999999999.9999999999999999999'') in (@idStrArr) and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by cd,treat_date)
        UNION ALL
       (select to_number(rst_cond_info->''7''->>''value'',''9999999999999999999.9999999999999999999'') cd,treat_date, count(*) from ord_main where  to_number(rst_cond_info->''7''->>''value'',''9999999999999999999.9999999999999999999'') in (@idStrArr) and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by cd,treat_date)
        UNION ALL
       (select to_number(rst_cond_info->''8''->>''value'',''9999999999999999999.9999999999999999999'') cd,treat_date, count(*) from ord_main where  to_number(rst_cond_info->''8''->>''value'',''9999999999999999999.9999999999999999999'') in (@idStrArr) and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by cd,treat_date)
        UNION ALL
       (select to_number(rst_cond_info->''9''->>''value'',''9999999999999999999.9999999999999999999'') cd,treat_date, count(*) from ord_main where  to_number(rst_cond_info->''9''->>''value'',''9999999999999999999.9999999999999999999'') in (@idStrArr) and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by cd,treat_date)
        UNION ALL
       (select to_number(rst_cond_info->''10''->>''value'',''9999999999999999999.9999999999999999999'') cd,treat_date, count(*) from ord_main where  to_number(rst_cond_info->''10''->>''value'',''9999999999999999999.9999999999999999999'') in (@idStrArr) and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by cd,treat_date)
        UNION ALL
       (select to_number(rst_cond_info->''11''->>''value'',''9999999999999999999.9999999999999999999'') cd,treat_date, count(*) from ord_main where  to_number(rst_cond_info->''11''->>''value'',''9999999999999999999.9999999999999999999'') in (@idStrArr) and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by cd,treat_date)
        UNION ALL
       (select to_number(rst_cond_info->''12''->>''value'',''9999999999999999999.9999999999999999999'') cd,treat_date, count(*) from ord_main where  to_number(rst_cond_info->''12''->>''value'',''9999999999999999999.9999999999999999999'') in (@idStrArr) and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by cd,treat_date)
        UNION ALL
       (select to_number(rst_cond_info->''13''->>''value'',''9999999999999999999.9999999999999999999'') cd,treat_date, count(*) from ord_main where  to_number(rst_cond_info->''13''->>''value'',''9999999999999999999.9999999999999999999'') in (@idStrArr) and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by cd,treat_date)
        UNION ALL
       (select to_number(equipInfo->>''cd'',''9999999999999999999.9999999999999999999'') cd,treat_date,
               case
                 when sum(to_number(equipInfo->>''amount'',''9999999999999999999.9999999999999999999'')) is not null then sum(to_number(equipInfo->>''amount'',''9999999999999999999.9999999999999999999''))
                 else 0
               end
        from ord_main
           cross join lateral
             json_array_elements (rst_equip_info::json) equipInfo
             where to_number(equipInfo->>''cd'',''9999999999999999999.9999999999999999999'')  in (@idStrArr) and to_number(equipInfo->>''equip_type'',''9'') = 0 and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by cd,treat_date)
      ) t1
    group by cd,treat_date
    order by treat_date asc
   ) t2
 group by cd,substring(treat_date, 1, 6)
 order by substring(treat_date, 1, 6) asc', 2, '[]'::jsonb, '0', '{"applications": []}'::jsonb, '{"classes": []}'::jsonb, 'データリスト', '2023-07-17 21:01:37.036', '2023-07-17 21:01:37.036', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-21023, 'select rst_kur_cd cd, substring(treat_date, 1, 6) as treat_date, count(*) as count from ord_main
where rst_dialysis_state = ''6'' AND treat_date between @dateFrom and @dateTo and facility_cd = @facilityCd and rst_kur_cd in (@idStrArr) AND is_del = ''0'' and pat_id is not null group by rst_kur_cd, substring(treat_date, 1, 6) order by substring(treat_date, 1, 6) asc', 2, '[]'::jsonb, '0', '{"applications": []}'::jsonb, '{"classes": []}'::jsonb, 'データリスト', '2023-07-17 21:01:37.036', '2023-07-17 21:01:37.036', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-21022, 'select rst_treatment_cd cd, substring(treat_date, 1, 6) as treat_date, count(*) as count from ord_main
where rst_dialysis_state = ''6'' AND treat_date between @dateFrom and @dateTo and facility_cd = @facilityCd and rst_treatment_cd in (@idStrArr) AND is_del = ''0'' and pat_id is not null group by rst_treatment_cd, substring(treat_date, 1, 6) order by substring(treat_date, 1, 6) asc', 2, '[]'::jsonb, '0', '{"applications": []}'::jsonb, '{"classes": []}'::jsonb, 'データリスト', '2023-07-17 21:01:37.036', '2023-07-17 21:01:37.036', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-21016, 'select ind_kur_cd cd, substring(treat_date, 1, 6) as treat_date, count(*) as count from ord_main
where treat_date between @dateFrom and @dateTo and facility_cd = @facilityCd and ind_kur_cd in (@idStrArr) AND is_del = ''0'' and pat_id is not null group by ind_kur_cd, substring(treat_date, 1, 6) order by substring(treat_date, 1, 6) asc', 2, '[]'::jsonb, '0', '{"applications": []}'::jsonb, '{"classes": []}'::jsonb, 'データリスト', '2023-07-17 21:01:37.036', '2023-07-17 21:01:37.036', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-21011, 'SELECT
   cd, substring(treat_date, 1, 6) as treat_date, sum(count) as count
 from
   (select
      cd, treat_date, sum(count) as count
    from
      ((select (rst_cond_info->''5''->>''value'') cd, treat_date, count(*) as count
	  from ord_main where (rst_cond_info->''5''->>''value'') in (@idStrArr) and treat_date between @dateFrom and @dateTo and is_del = ''0'' and facility_cd = @facilityCd and pat_id is not null group by (rst_cond_info->''5''->>''value''),treat_date)
        UNION ALL
       (select (equipInfo->>''cd'') cd, treat_date, sum((equipInfo->>''amount'')::numeric) AS count from ord_main
         cross join lateral
           json_array_elements (rst_equip_info::json) equipInfo
           where (equipInfo->>''cd'') in (@idStrArr) and (equipInfo->>''equip_type'')::numeric = 1 and treat_date between @dateFrom and @dateTo and is_del = ''0'' and facility_cd = @facilityCd and pat_id is not null group by (equipInfo->>''cd''),treat_date)
      ) t1
    group by cd, treat_date
    order by treat_date asc
   ) t2
 group by cd, substring(treat_date, 1, 6)
 order by substring(treat_date, 1, 6) asc', 2, '[]'::jsonb, '0', '{"applications": []}'::jsonb, '{"classes": []}'::jsonb, 'データリスト', '2023-07-17 21:01:37.036', '2023-07-17 21:01:37.036', NULL);
 
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-21015, 'select ind_treatment_cd cd, substring(treat_date, 1, 6) as treat_date, count(*) as count from ord_main
where treat_date between @dateFrom and @dateTo and facility_cd = @facilityCd and ind_treatment_cd in (@idStrArr) AND is_del = ''0'' and pat_id is not null group by ind_treatment_cd, substring(treat_date, 1, 6) order by substring(treat_date, 1, 6) asc', 2, '[]'::jsonb, '0', '{"applications": []}'::jsonb, '{"classes": []}'::jsonb, 'データリスト', '2023-07-17 21:01:37.036', '2023-07-17 21:01:37.036', NULL);


INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-11004, 'select mstMedi.medicine_cd cd
      ,mstMedi.unit
  from mst_medicine mstMedi
 where mstMedi.medicine_cd in (@idStrArr) and @kubun = 1
union
select mstMediMix.medicine_mix_cd cd
      ,mstMediMix.unit
  from mst_medicine_mix mstMediMix
 where mstMediMix.medicine_mix_cd in (@idStrArr) and @kubun = 2', 2, '[]'::jsonb, '0', '{"applications": []}'::jsonb, '{"classes": []}'::jsonb, 'データリスト', '2023-07-17 21:00:07.781', '2023-07-17 21:00:07.781', NULL);
 
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-11006, 'select equipment_cd cd,unit from mst_equipment where equipment_cd in (@idStrArr) AND is_del = ''0'' AND facility_cd = @facilityCd', 2, '[]'::jsonb, '0', '{"applications": []}'::jsonb, '{"classes": []}'::jsonb, 'データリスト', '2023-07-17 21:00:07.781', '2023-07-17 21:00:07.781', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-11044, 'select medicine_cd cd,unit_second as unit from mst_medicine where medicine_cd in (@ids) AND facility_cd = @facilityCd', 2, '[]'::jsonb, '0', '{"applications": []}'::jsonb, '{"classes": []}'::jsonb, 'データリスト', '2020-07-31 18:29:49.000', '2020-07-31 18:29:49.000', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-11045, 'SELECT
	T01.supplies_cd cd,
	T01.supplies_base_date AS treat_date,
	SUM(T01.receipt_value::NUMERIC) AS COUNT 
FROM ord_material_save T01
WHERE T01.facility_cd = @facilityCd
	AND T01.supplies_cd in (@idStrArr)
	AND T01.ind_rst_class = ''1'' 
	AND T01.pat_id IS NOT NULL
	--<>調製薬剤,処置調製薬剤,抗凝固剤調製薬剤（調製薬剤）
	AND T01.supplies_class NOT IN (''13'', ''15'', ''17'') 
	AND T01.supplies_base_date BETWEEN @dateFrom AND @dateTo
GROUP BY T01.supplies_cd,T01.supplies_base_date
ORDER BY T01.supplies_base_date ASC', 2, '[]'::jsonb, '0', '{"applications": []}'::jsonb, '{"classes": []}'::jsonb, 'データリスト', '2020-07-31 18:29:49.000', '2025-03-06 21:08:44.271', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-11003, 'SELECT
	supplies_cd cd,
	supplies_base_date AS treat_date,
	SUM(ind_rst_value::NUMERIC) AS COUNT 
FROM ord_material_save 
WHERE facility_cd = @facilityCd
	AND supplies_cd in (@idStrArr)
	AND ind_rst_class = ''1'' 
	AND pat_id IS NOT NULL
	--<>調製薬剤,処置調製薬剤,抗凝固剤調製薬剤（調製薬剤）
	AND supplies_class NOT IN ( ''20'', ''21'', ''22'' ) 
	AND supplies_base_date BETWEEN @dateFrom AND @dateTo
GROUP BY supplies_cd,supplies_base_date 
ORDER BY supplies_base_date ASC', 2, '[]'::jsonb, '0', '{"applications": []}'::jsonb, '{"classes": []}'::jsonb, 'データリスト', '2020-07-31 18:29:49.000', '2025-03-06 21:08:44.271', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-11005, ' select
   id cd, treat_date, sum(count) as count
from
    ((select to_number(ind_cond_info->''5''->>''value'', ''9999999999999999999.9999999999999999999'') id,treat_date, count(*) count from ord_main where to_number(ind_cond_info->''5''->>''value'', ''9999999999999999999.9999999999999999999'') in (@idStrArr) and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by to_number(ind_cond_info->''5''->>''value'', ''9999999999999999999.9999999999999999999''),treat_date)
    UNION ALL
    (select to_number(ind_cond_info->''6''->>''value'', ''9999999999999999999.9999999999999999999'') id,treat_date, count(*) count from ord_main where to_number(ind_cond_info->''6''->>''value'', ''9999999999999999999.9999999999999999999'') in (@idStrArr) and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by to_number(ind_cond_info->''6''->>''value'', ''9999999999999999999.9999999999999999999''),treat_date)
    UNION ALL
    (select to_number(ind_cond_info->''7''->>''value'', ''9999999999999999999.9999999999999999999'') id,treat_date, count(*) count from ord_main where to_number(ind_cond_info->''7''->>''value'', ''9999999999999999999.9999999999999999999'') in (@idStrArr) and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by to_number(ind_cond_info->''7''->>''value'', ''9999999999999999999.9999999999999999999''),treat_date)
    UNION ALL
    (select to_number(ind_cond_info->''8''->>''value'', ''9999999999999999999.9999999999999999999'') id,treat_date, count(*) count from ord_main where to_number(ind_cond_info->''8''->>''value'', ''9999999999999999999.9999999999999999999'') in (@idStrArr) and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by to_number(ind_cond_info->''8''->>''value'', ''9999999999999999999.9999999999999999999''),treat_date)
    UNION ALL
    (select to_number(ind_cond_info->''9''->>''value'', ''9999999999999999999.9999999999999999999'') id,treat_date, count(*) count from ord_main where to_number(ind_cond_info->''9''->>''value'', ''9999999999999999999.9999999999999999999'') in (@idStrArr) and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by to_number(ind_cond_info->''9''->>''value'', ''9999999999999999999.9999999999999999999''),treat_date)
    UNION ALL
    (select to_number(ind_cond_info->''10''->>''value'', ''9999999999999999999.9999999999999999999'') id,treat_date, count(*) count from ord_main where to_number(ind_cond_info->''10''->>''value'', ''9999999999999999999.9999999999999999999'') in (@idStrArr) and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by to_number(ind_cond_info->''10''->>''value'', ''9999999999999999999.9999999999999999999''),treat_date)
    UNION ALL
    (select to_number(ind_cond_info->''11''->>''value'', ''9999999999999999999.9999999999999999999'') id,treat_date, count(*) count from ord_main where to_number(ind_cond_info->''11''->>''value'', ''9999999999999999999.9999999999999999999'') in (@idStrArr) and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by to_number(ind_cond_info->''11''->>''value'', ''9999999999999999999.9999999999999999999''),treat_date)
    UNION ALL
    (select to_number(ind_cond_info->''12''->>''value'', ''9999999999999999999.9999999999999999999'') id,treat_date, count(*) count from ord_main where to_number(ind_cond_info->''12''->>''value'', ''9999999999999999999.9999999999999999999'') in (@idStrArr) and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by to_number(ind_cond_info->''12''->>''value'', ''9999999999999999999.9999999999999999999''),treat_date)
    UNION ALL
    (select to_number(ind_cond_info->''13''->>''value'', ''9999999999999999999.9999999999999999999'') id,treat_date, count(*) count from ord_main where to_number(ind_cond_info->''13''->>''value'', ''9999999999999999999.9999999999999999999'') in (@idStrArr) and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by to_number(ind_cond_info->''13''->>''value'', ''9999999999999999999.9999999999999999999''),treat_date)
    UNION ALL
    (select to_number(equipInfo->>''cd'', ''9999999999999999999''),treat_date,
    case
    when sum (to_number(equipInfo->>''amount'', ''9999999999999999999.9999999999999999999'')) is not null then sum (to_number(equipInfo->>''amount'', ''9999999999999999999.9999999999999999999''))
    else 0
    end count
    from ord_main
    cross join lateral
    json_array_elements (ind_equip_info::json) equipInfo
    where to_number(equipInfo->>''cd'', ''9999999999999999999'') in (@idStrArr) and to_number(equipInfo->>''equip_type'', ''9'') = 0 and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by to_number(equipInfo->>''cd'', ''9999999999999999999''),treat_date)
    ) t1
group by id,treat_date
order by treat_date asc', 2, '[]'::jsonb, '0', '{"applications": []}'::jsonb, '{"classes": []}'::jsonb, 'データリスト', '2020-07-31 18:29:49.000', '2023-08-16 21:08:44.271', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-11039, 'SELECT j1.cd cd, treat_date, COUNT( * ) AS count
FROM
    ord_main,
    jsonb_to_recordset ( addition_info ) AS j1 ( cd TEXT, reg_date TEXT, is_enable TEXT )
WHERE
    treat_date BETWEEN @dateFrom AND @dateTo
 AND is_del = ''0''
 AND facility_cd = @facilityCd
 AND j1.cd in (@idStrArr)
 AND pat_id is not null
group by j1.cd,treat_date
order by treat_date asc   ', 2, '[]'::jsonb, '0', '{"applications": []}'::jsonb, '{"classes": []}'::jsonb, 'データリスト', '2021-04-25 16:40:02.000', '2023-08-16 21:08:44.271', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-11037, 'SELECT
  to_char(reg_rad_date, ''YYYYMMDD'') as treat_date,
  count(DISTINCT pat_id) AS count
FROM pat_rad_main
WHERE date(reg_rad_date) >= @dateFrom
  AND date(reg_rad_date) <= @dateTo
  AND is_del = ''0''
  AND facility_cd = @facilityCd
 group by treat_date
 order by treat_date asc', 2, '[]'::jsonb, '0', '{"applications": []}'::jsonb, '{"classes": []}'::jsonb, 'データリスト', '2020-07-31 18:29:49.294', '2023-08-16 21:08:44.271', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-11036, 'SELECT
  to_char(reg_exam_date, ''YYYYMMDD'') as treat_date,
  count(DISTINCT pat_id) AS count
FROM pat_exam_main
WHERE date(reg_exam_date) >= @dateFrom
  AND date(reg_exam_date) <= @dateTo
  AND is_del = ''0''
  AND facility_cd = @facilityCd
 group by treat_date
 order by treat_date asc', 2, '[]'::jsonb, '0', '{"applications": []}'::jsonb, '{"classes": []}'::jsonb, 'データリスト', '2020-07-31 18:29:49.294', '2023-08-16 21:08:44.271', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-11035, 'SELECT
  elem ->> ''move_in_out'' as in_out_type,
  elem ->> ''period_start'' as treat_date,
  count(DISTINCT pat_id) AS count
FROM pat_unique,
     jsonb_array_elements(in_out_visit_history_info) AS elem
WHERE elem ->> ''move_in_out'' in (@inOutTypes)
  AND elem ->> ''period_start'' >= @dateFrom
  AND elem ->> ''period_start'' <= @dateTo
  AND elem ->> ''facility_cd'' = @facilityCd
  AND is_del = ''0''
 group by elem ->> ''move_in_out'', treat_date
 order by treat_date asc    ', 2, '[]'::jsonb, '0', '{"applications": []}'::jsonb, '{"classes": []}'::jsonb, 'データリスト', '2020-07-31 18:29:49.294', '2023-08-16 21:08:44.271', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-11034, 'SELECT
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
 order by treat_date asc', 2, '[]'::jsonb, '0', '{"applications": []}'::jsonb, '{"classes": []}'::jsonb, 'データリスト', '2020-07-31 18:29:49.294', '2023-08-16 21:08:44.271', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-11033, 'SELECT
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
 order by treat_date asc', 2, '[]'::jsonb, '0', '{"applications": []}'::jsonb, '{"classes": []}'::jsonb, 'データリスト', '2020-07-31 18:29:49.294', '2023-08-16 21:08:44.271', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-11021, 'select ordMain.treat_date as treat_date, count(*) as count from ord_main as ordMain left join mst_treatment as mstTreatment on ordMain.rst_treatment_cd = mstTreatment.treatment_cd
where ordMain.rst_dialysis_state = ''6'' AND mstTreatment.device_mode = ''9'' and ordMain.treat_date between @dateFrom and @dateTo and ordMain.facility_cd = @facilityCd AND ordMain.is_del = ''0'' and ordMain.pat_id is not null
group by ordMain.treat_date
order by ordMain.treat_date asc', 2, '[]'::jsonb, '0', '{"applications": []}'::jsonb, '{"classes": []}'::jsonb, 'データリスト', '2020-07-31 18:29:49.000', '2023-08-16 21:08:44.271', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-11020, 'select ordMain.treat_date as treat_date, count(*) as count from ord_main as ordMain left join mst_treatment as mstTreatment on ordMain.rst_treatment_cd = mstTreatment.treatment_cd
where ordMain.rst_dialysis_state = ''6'' AND mstTreatment.device_mode != ''9'' and ordMain.treat_date between @dateFrom and @dateTo and ordMain.facility_cd = @facilityCd AND ordMain.is_del = ''0'' and ordMain.pat_id is not null
group by ordMain.treat_date
order by ordMain.treat_date asc ', 2, '[]'::jsonb, '0', '{"applications": []}'::jsonb, '{"classes": []}'::jsonb, 'データリスト', '2020-07-31 18:29:49.000', '2023-08-16 21:08:44.271', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-11019, 'select treat_date, count(*) as count from ord_main where rst_dialysis_state = ''6'' AND treat_date between @dateFrom and @dateTo and (rst_in_out_class <> 1 or rst_in_out_class is null) and facility_cd = @facilityCd AND is_del = ''0'' and pat_id is not null
group by treat_date
order by treat_date asc ', 2, '[]'::jsonb, '0', '{"applications": []}'::jsonb, '{"classes": []}'::jsonb, 'データリスト', '2020-07-31 18:29:49.000', '2023-08-16 21:08:44.271', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-11018, 'select treat_date, count(*) as count from ord_main where rst_dialysis_state = ''6'' AND treat_date between @dateFrom and @dateTo and rst_in_out_class = 1 and facility_cd = @facilityCd AND is_del = ''0'' and pat_id is not null
group by treat_date
order by treat_date asc ', 2, '[]'::jsonb, '0', '{"applications": []}'::jsonb, '{"classes": []}'::jsonb, 'データリスト', '2020-07-31 18:29:49.000', '2023-08-16 21:08:44.271', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-11017, 'select treat_date, count(*) as count from ord_main where treat_date between @dateFrom and @dateTo and rst_dialysis_state = ''6'' and facility_cd = @facilityCd AND is_del = ''0'' and pat_id is not null
group by treat_date
order by treat_date asc ', 2, '[]'::jsonb, '0', '{"applications": []}'::jsonb, '{"classes": []}'::jsonb, 'データリスト', '2020-07-31 18:29:49.000', '2023-08-16 21:08:44.271', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-11010, '  select
   cd,treat_date, sum(count) as count
 from
   ((select to_number(rst_cond_info->''5''->>''value'',''9999999999999999999.9999999999999999999'') cd, treat_date, count(*) from ord_main where  to_number(rst_cond_info->''5''->>''value'',''9999999999999999999.9999999999999999999'') in (@idStrArr) and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by to_number(rst_cond_info->''5''->>''value'',''9999999999999999999.9999999999999999999''),treat_date)
     UNION ALL
    (select to_number(rst_cond_info->''6''->>''value'',''9999999999999999999.9999999999999999999'') cd, treat_date, count(*) from ord_main where  to_number(rst_cond_info->''6''->>''value'',''9999999999999999999.9999999999999999999'') in (@idStrArr) and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by to_number(rst_cond_info->''6''->>''value'',''9999999999999999999.9999999999999999999''),treat_date)
     UNION ALL
    (select to_number(rst_cond_info->''7''->>''value'',''9999999999999999999.9999999999999999999'') cd, treat_date, count(*) from ord_main where  to_number(rst_cond_info->''7''->>''value'',''9999999999999999999.9999999999999999999'') in (@idStrArr) and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by to_number(rst_cond_info->''7''->>''value'',''9999999999999999999.9999999999999999999''),treat_date)
     UNION ALL
    (select to_number(rst_cond_info->''8''->>''value'',''9999999999999999999.9999999999999999999'') cd, treat_date, count(*) from ord_main where  to_number(rst_cond_info->''8''->>''value'',''9999999999999999999.9999999999999999999'') in (@idStrArr) and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by to_number(rst_cond_info->''8''->>''value'',''9999999999999999999.9999999999999999999''),treat_date)
     UNION ALL
    (select to_number(rst_cond_info->''9''->>''value'',''9999999999999999999.9999999999999999999'') cd, treat_date, count(*) from ord_main where  to_number(rst_cond_info->''9''->>''value'',''9999999999999999999.9999999999999999999'') in (@idStrArr) and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by to_number(rst_cond_info->''9''->>''value'',''9999999999999999999.9999999999999999999''),treat_date)
     UNION ALL
    (select to_number(rst_cond_info->''10''->>''value'',''9999999999999999999.9999999999999999999'') cd, treat_date, count(*) from ord_main where  to_number(rst_cond_info->''10''->>''value'',''9999999999999999999.9999999999999999999'') in (@idStrArr) and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by to_number(rst_cond_info->''10''->>''value'',''9999999999999999999.9999999999999999999''),treat_date)
     UNION ALL
    (select to_number(rst_cond_info->''11''->>''value'',''9999999999999999999.9999999999999999999'') cd, treat_date, count(*) from ord_main where  to_number(rst_cond_info->''11''->>''value'',''9999999999999999999.9999999999999999999'') in (@idStrArr) and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by to_number(rst_cond_info->''11''->>''value'',''9999999999999999999.9999999999999999999''),treat_date)
     UNION ALL
    (select to_number(rst_cond_info->''12''->>''value'',''9999999999999999999.9999999999999999999'') cd, treat_date, count(*) from ord_main where  to_number(rst_cond_info->''12''->>''value'',''9999999999999999999.9999999999999999999'') in (@idStrArr) and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by to_number(rst_cond_info->''12''->>''value'',''9999999999999999999.9999999999999999999''),treat_date)
     UNION ALL
    (select to_number(rst_cond_info->''13''->>''value'',''9999999999999999999.9999999999999999999'') cd, treat_date, count(*) from ord_main where  to_number(rst_cond_info->''13''->>''value'',''9999999999999999999.9999999999999999999'') in (@idStrArr) and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by to_number(rst_cond_info->''13''->>''value'',''9999999999999999999.9999999999999999999''),treat_date)
     UNION ALL
    (select to_number(equipInfo->>''cd'',''9999999999999999999.9999999999999999999'') cd, treat_date,
            case
              when sum(to_number(equipInfo->>''amount'',''9999999999999999999.9999999999999999999'')) is not null then sum(to_number(equipInfo->>''amount'',''9999999999999999999.9999999999999999999''))
              else 0
            end
     from ord_main
        cross join lateral
          json_array_elements (rst_equip_info::json) equipInfo
          where to_number(equipInfo->>''cd'',''9999999999999999999.9999999999999999999'')  in (@idStrArr) and to_number(equipInfo->>''equip_type'',''9'') = 0 and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd and pat_id is not null group by to_number(equipInfo->>''cd'',''9999999999999999999.9999999999999999999''),treat_date)
   ) t1
 group by cd,treat_date
 order by treat_date asc', 2, '[]'::jsonb, '0', '{"applications": []}'::jsonb, '{"classes": []}'::jsonb, 'データリスト', '2020-07-31 18:29:49.000', '2023-08-16 21:08:44.271', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-11043, 'SELECT
	supplies_cd cd,
	supplies_base_date AS treat_date,
	SUM(receipt_value::NUMERIC) AS COUNT 
FROM ord_material_save 
WHERE facility_cd = @facilityCd
	AND supplies_cd in (@idStrArr)
	AND ind_rst_class = ''2'' 
	AND pat_id IS NOT NULL
	--<>調製薬剤,処置調製薬剤,抗凝固剤調製薬剤（調製薬剤）
	AND supplies_class NOT IN ( ''13'', ''15'', ''17'' ) 
	AND supplies_base_date BETWEEN @dateFrom AND @dateTo
GROUP BY supplies_cd,supplies_base_date 
ORDER BY supplies_base_date ASC', 2, '[]'::jsonb, '0', '{"applications": []}'::jsonb, '{"classes": []}'::jsonb, 'データリスト', '2020-07-31 18:29:49.000', '2025-03-06 21:08:44.271', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-11009, 'SELECT
	supplies_cd cd,
	supplies_base_date AS treat_date,
	SUM(ind_rst_value::NUMERIC) AS COUNT 
FROM ord_material_save 
WHERE facility_cd = @facilityCd
	AND supplies_cd in (@idStrArr)
	AND ind_rst_class = ''2'' 
	AND pat_id IS NOT NULL
	--<>調製薬剤,処置調製薬剤,抗凝固剤調製薬剤（調製薬剤）
	AND supplies_class NOT IN ( ''20'', ''21'', ''22'' ) 
	AND supplies_base_date BETWEEN @dateFrom AND @dateTo
GROUP BY supplies_cd,supplies_base_date 
ORDER BY supplies_base_date ASC', 2, '[]'::jsonb, '0', '{"applications": []}'::jsonb, '{"classes": []}'::jsonb, 'データリスト', '2020-07-31 18:29:49.000', '2025-03-06 21:08:44.271', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-11022, 'select rst_treatment_cd cd, treat_date, count(*) as count from ord_main
where rst_dialysis_state = ''6'' AND treat_date between @dateFrom and @dateTo and facility_cd = @facilityCd and rst_treatment_cd in (@idStrArr) AND is_del = ''0'' and pat_id is not null group by rst_treatment_cd,treat_date order by treat_date asc', 2, '[]'::jsonb, '0', '{"applications": []}'::jsonb, '{"classes": []}'::jsonb, 'データリスト', '2020-07-31 18:29:49.000', '2023-08-16 21:08:44.271', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-11023, 'select rst_kur_cd cd, treat_date, count(*) as count from ord_main
where rst_dialysis_state = ''6'' AND treat_date between @dateFrom and @dateTo and facility_cd = @facilityCd and rst_kur_cd in (@idStrArr) AND is_del = ''0'' and pat_id is not null group by rst_kur_cd,treat_date order by treat_date asc', 2, '[]'::jsonb, '0', '{"applications": []}'::jsonb, '{"classes": []}'::jsonb, 'データリスト', '2020-07-31 18:29:49.000', '2023-08-16 21:08:44.271', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-11038, 'SELECT s.sub_category_cd cd,e.event_start_date as treat_date, count(DISTINCT e.pat_id) AS count
FROM pat_event AS e,
mst_pat_event_sub_category AS s
WHERE date(e.event_start_date) >= @dateFrom
AND date(e.event_start_date) <= @dateTo
AND e.is_del = ''0''
AND s.sub_category_cd = e.sub_category_cd
AND s.is_del = ''0''
AND e.facility_cd = @facilityCd
AND s.facility_cd = @facilityCd
AND s.sub_category_cd in (@idStrArr)
group by s.sub_category_cd,treat_date
order by treat_date asc', 2, '[]'::jsonb, '0', '{"applications": []}'::jsonb, '{"classes": []}'::jsonb, 'データリスト', '2020-07-31 18:29:49.294', '2023-08-16 21:08:44.271', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-11015, '  select ind_treatment_cd cd, treat_date, count(*) as count from ord_main
 where treat_date between @dateFrom and @dateTo and facility_cd = @facilityCd and ind_treatment_cd in (@idStrArr) AND is_del = ''0''
 and (rst_dialysis_state between ''0'' and ''6'') and pat_id is not null
 group by ind_treatment_cd, treat_date order by treat_date asc', 2, '[]'::jsonb, '0', '{"applications": []}'::jsonb, '{"classes": []}'::jsonb, 'データリスト', '2020-07-31 18:29:49.000', '2025-03-06 21:08:44.271', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-11012, 'select treat_date, count(*) as count from ord_main where treat_date between @dateFrom and @dateTo and facility_cd = @facilityCd AND is_del = ''0'' and pat_id is not null group by treat_date order by treat_date asc ', 2, '[]'::jsonb, '0', '{"applications": []}'::jsonb, '{"classes": []}'::jsonb, 'データリスト', '2020-07-31 18:29:49.000', '2023-08-16 21:08:44.271', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-11041, 'WITH in_out AS (
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
order by treat_date asc;', 2, '[]'::jsonb, '0', '{"applications": []}'::jsonb, '{"classes": []}'::jsonb, 'データリスト', '2020-05-26 16:49:16.000', '2023-08-16 21:08:44.271', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-11042, 'WITH in_out AS (
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
order by treat_date asc;', 2, '[]'::jsonb, '0', '{"applications": []}'::jsonb, '{"classes": []}'::jsonb, 'データリスト', '2020-05-26 16:49:16.000', '2025-03-06 21:08:44.271', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-11013, 'SELECT ordMain.treat_date as treat_date, count(*) as count
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
order by ordMain.treat_date asc', 2, '[]'::jsonb, '0', '{"applications": []}'::jsonb, '{"classes": []}'::jsonb, 'データリスト', '2020-07-31 18:29:49.000', '2023-08-16 21:08:44.271', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-11014, 'select ordMain.treat_date as treat_date, count(*) as count from ord_main as ordMain left join mst_treatment as mstTreatment on ordMain.ind_treatment_cd = mstTreatment.treatment_cd
where mstTreatment.device_mode = ''9'' and ordMain.treat_date between @dateFrom and @dateTo and ordMain.facility_cd = @facilityCd AND ordMain.is_del = ''0''
 AND ordMain.pat_id is not null
 group by ordMain.treat_date
 order by ordMain.treat_date asc', 2, '[]'::jsonb, '0', '{"applications": []}'::jsonb, '{"classes": []}'::jsonb, 'データリスト', '2020-07-31 18:29:49.000', '2023-08-16 21:08:44.271', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-11016, ' select ind_kur_cd cd, treat_date, count(*) as count from ord_main
 where treat_date between @dateFrom and @dateTo and facility_cd = @facilityCd and ind_kur_cd in (@idStrArr) AND is_del = ''0''
 and (rst_dialysis_state between ''0'' and ''6'') and pat_id is not null
 group by ind_kur_cd, treat_date order by treat_date asc    ', 2, '[]'::jsonb, '0', '{"applications": []}'::jsonb, '{"classes": []}'::jsonb, 'データリスト', '2020-07-31 18:29:49.000', '2023-08-16 21:08:44.271', NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-11046, 'select treat_date, count(*) as count from ord_main 
 where treat_date between @dateFrom and @dateTo and facility_cd = @facilityCd and (ind_kur_cd is null or ind_kur_cd = 0) AND is_del = ''0'' and pat_id is not null
 group by treat_date
 order by treat_date asc', 2, '[]'::jsonb, '0', '{"applications": []}'::jsonb, '{"classes": []}'::jsonb, 'データリスト', '2020-07-31 18:29:49.000', '2025-03-06 21:08:44.271', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-11011, 'select
   cd, treat_date, sum(count) as count
 from
   ((select (rst_cond_info->''5''->>''value'')::numeric cd,treat_date, count(*) as count
   from ord_main where (rst_cond_info->''5''->>''value'')::numeric in (@idStrArr) and treat_date between @dateFrom and @dateTo and is_del = ''0'' and facility_cd = @facilityCd and pat_id is not null group by (rst_cond_info->''5''->>''value'')::numeric,treat_date)
     UNION ALL
    (select (equipInfo->>''cd'')::numeric cd, treat_date, sum((equipInfo->>''amount'')::numeric) AS COUNT from ord_main
      cross join lateral
        json_array_elements (rst_equip_info::json) equipInfo
        where (equipInfo->>''cd'')::numeric in (@idStrArr) and (equipInfo->>''equip_type'')::numeric = 1 and treat_date between @dateFrom and @dateTo and is_del = ''0'' and facility_cd = @facilityCd and pat_id is not null group by (equipInfo->>''cd'')::numeric,treat_date)
   ) t1
 group by cd, treat_date
 order by treat_date asc', 2, '[]'::jsonb, '0', '{"applications": []}'::jsonb, '{"classes": []}'::jsonb, 'データリスト', '2020-07-31 18:29:49.000', '2025-03-06 16:08:44.271', NULL);
 
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-21039, 'SELECT j1.cd cd, substring(treat_date, 1, 6) treat_date, COUNT( * ) AS count
FROM
    ord_main,
    jsonb_to_recordset ( addition_info ) AS j1 ( cd TEXT, reg_date TEXT, is_enable TEXT )
WHERE
    treat_date BETWEEN @dateFrom AND @dateTo
 AND is_del = ''0''
 AND facility_cd = @facilityCd
 AND j1.cd in (@idStrArr)
 AND pat_id is not null
group by j1.cd,treat_date
order by treat_date asc  ', 2, '[]'::jsonb, '0', '{"applications": []}'::jsonb, '{"classes": []}'::jsonb, 'データリスト', '2021-04-25 16:40:02.000', '2023-08-16 21:08:44.271', NULL);

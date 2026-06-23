DELETE FROM ntss.sys_data_set
WHERE sql_cd=-310011;

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-310011, 'WITH
output_item AS(
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = @key0
    AND info ->> ''key1'' = ''EXAM_ORD''
    AND info ->> ''key2'' = ''OUTPUT_ITEM''
),
output_in_out AS(
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = @key0
    AND info ->> ''key1'' = ''EXAM_ORD''
    AND info ->> ''key2'' = ''OUTPUT_IN_OUT''
),
item_set_no AS (
SELECT info.value ->> ''set_cd'' AS no
FROM ( 
                select
                  m.* 
                from
                  pat_exam_main as m 
                where
                  m.is_del = ''0'' 
                  and jsonb_array_length(m.order_exam_set_info) > 0 
                  and m.exam_main_cd = @ordNo
              ) p 
              cross join lateral json_array_elements(p.order_exam_set_info ::json) info 
              inner join mst_exam_set as item 
                on info ->> ''set_cd'' = (item.exam_set_cd || '''')
)
select
  count(1) as exam_set_cnt
        from
          ( 
            select
              1
            from
              ( 
                select
                  m.* 
                from
                  pat_exam_main as m 
                where
                  m.is_del = ''0'' 
                  and jsonb_array_length(m.order_exam_set_info) > 0 
                  and m.exam_main_cd = @ordNo
              ) p 
              cross join lateral json_array_elements(p.exam_order_info ::json) info 
              join mst_exam_item as item 
                on info ->> ''item_cd'' = (item.exam_item_cd || '''')
                AND 
                CASE (SELECT value FROM output_in_out)
                WHEN ''1'' THEN item.is_in_hospital = ''0''
                WHEN ''2'' THEN item.is_in_hospital = ''1''
                ELSE true
                END 
              WHERE info ->> ''set_cd'' IN (SELECT no FROM item_set_no)
              AND 
              CASE (SELECT value FROM output_item)
              WHEN ''1'' THEN false
              ELSE true
              END
            union all 
            select
              1
            from
              ( 
                select
                  m.* 
                from
                  pat_exam_main as m 
                where
                  m.is_del = ''0'' 
                  and jsonb_array_length(m.order_exam_set_info) > 0 
                  and m.exam_main_cd = @ordNo
              ) p 
              cross join lateral json_array_elements(p.order_exam_set_info ::json) info 
              left outer join mst_exam_set as item 
                on info ->> ''set_cd'' = (item.exam_set_cd || '''')
              WHERE info ->> ''set_cd'' IN (SELECT no FROM item_set_no)
              AND 
              CASE (SELECT value FROM output_item)
              WHEN ''2'' THEN false
              ELSE true
              END
          ) exam_all ', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'Medicom検査オーダ 検査項目カウント', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-310010);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-310010, 'WITH
exam_item AS(
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = ''MED''
    AND info ->> ''key1'' = ''MST''
    AND info ->> ''key2'' = ''EXAM_ITEM''
),
exam_set AS(
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = ''MED''
    AND info ->> ''key1'' = ''MST''
    AND info ->> ''key2'' = ''EXAM_SET''
),
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
    AND info ->> ''key0'' = ''MED''
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
    AND info ->> ''key0'' = ''MED''
    AND info ->> ''key1'' = ''EXAM_ORD''
    AND info ->> ''key2'' = ''OUTPUT_IN_OUT''
),
item_set_no AS (
select info.value ->> ''set_cd'' AS no
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
                AND 
                CASE (SELECT value FROM output_in_out)
                WHEN ''1'' THEN item.is_in_hospital = ''0''
                WHEN ''2'' THEN item.is_in_hospital = ''1''
                ELSE true
                END
),
institution_cd AS (
 SELECT
        UNNEST(string_to_array(COALESCE(
                    NULLIF(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ), '','')) AS exam_institution_cd
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(
                ini.coop_ini_info::json
            ) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = ''MED''
    AND info ->> ''key1'' = ''EXAM_ORD''
    AND info ->> ''key2'' = ''EXAM_INSTITUTION_CD''
)
select
  ''検査項目'' as detail_id,
  (select exam_institution_cd from institution_cd) as exam_institution_cd,
  (exam_full.exam_row + 1) as exam_row,
  LEFT(max(case exam_full.exam_col when 0 then exam_full.in_hospital_cd else null end ), 17) as exam1,
  max(case exam_full.exam_col when 0 then exam_full.sub_no else '' '' end ) as exam1p,
  LEFT(max(case exam_full.exam_col when 1 then exam_full.in_hospital_cd else '' '' end ), 17) as exam2,
  max(case exam_full.exam_col when 1 then exam_full.sub_no else '' '' end ) as exam2p,
  LEFT(max(case exam_full.exam_col when 2 then exam_full.in_hospital_cd else '' '' end ), 17) as exam3,
  max(case exam_full.exam_col when 2 then exam_full.sub_no else '' '' end ) as exam3p,
  LEFT(max(case exam_full.exam_col when 3 then exam_full.in_hospital_cd else '' '' end ), 17) as exam4,
  max(case exam_full.exam_col when 3 then exam_full.sub_no else '' '' end ) as exam4p,
  LEFT(max(case exam_full.exam_col when 4 then exam_full.in_hospital_cd else '' '' end ), 17) as exam5,
  max(case exam_full.exam_col when 4 then exam_full.sub_no else '' '' end ) as exam5p
from
  ( 
    select
      (row_number() over () - 1) / 5 as exam_row
      , (row_number() over () - 1) % 5 as exam_col
      , exam.sub_no
      , exam.in_hospital_cd
    from
      ( 
        select
          exam_all.* 
        from
          ( 
            select
              info ->> ''item_cd'' as seq_no
              , ''6'' as sub_no -- 子（検査項目）
              , info ->> ''item_cd'' as item_cd 
              , info ->> ''item_name'' as item_name
              , CASE (SELECT value FROM exam_item)
              WHEN ''1'' THEN item.in_hospital_cd1
              WHEN ''2'' THEN item.in_hospital_cd2
              WHEN ''3'' THEN item.in_hospital_cd3
              ELSE NULL
              END as in_hospital_cd
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
              left outer join mst_exam_item as item 
                on info ->> ''item_cd'' = (item.exam_item_cd || '''') 
              WHERE info ->> ''set_cd'' IN (SELECT no FROM item_set_no)
              AND 
              CASE (SELECT value FROM output_item)
              WHEN ''1'' THEN false
              ELSE true
              END
            union all 
            select
              info ->> ''set_cd'' as seq_no
              , ''5'' as sub_no -- 親（検査セット）
              , info ->> ''set_cd'' as item_cd 
              , info ->> ''set_name'' as item_name
              , CASE (SELECT value FROM exam_set)
              WHEN ''1'' THEN item.in_hospital_cd1
              WHEN ''2'' THEN item.in_hospital_cd2
              WHEN ''3'' THEN item.in_hospital_cd3
              ELSE NULL
              END as in_hospital_cd
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
          ) exam_all
        order by
          seq_no ASC 
          , sub_no ASC
      ) exam
  ) exam_full 
group by
  exam_full.exam_row 
order by
  exam_row', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'Medicom検査オーダ 繰り返し部', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
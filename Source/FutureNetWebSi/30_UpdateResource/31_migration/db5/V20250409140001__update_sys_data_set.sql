DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-310001, -310002, -310003, -310005, -310006, -310007, -310008, -310010, -310011, -310012, -310014, -310016);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-310001, 'SELECT
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
    AND info ->> ''key2'' = ''EXAM_INSTITUTION_CD''', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom検査オーダ連携用の[連携設定→検査機関コード]値取得', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-310002, 'SELECT
        UNNEST(string_to_array(COALESCE(
                    NULLIF(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ), '','')) AS facility_no
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(
                ini.coop_ini_info::json
            ) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = @key0
    AND info ->> ''key1'' = ''EXAM_ORD''
    AND info ->> ''key2'' = ''FACILITY_NO''', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom検査オーダ連携用の[連携設定→施設NO]値取得', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-310003, 'WITH def_course AS(
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
    AND info ->> ''key2'' = ''DEFAULT_COURSE''
),
def_ward AS(
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
    AND info ->> ''key2'' = ''DEFAULT_WARD''
)

SELECT
  medical_care_info ->> ''ward_cd'' AS ward_cd
  , ward.ward_name AS ward_name
  , LEFT(COALESCE(ward.in_hospital_cd_1, (SELECT value FROM def_ward)), 15) AS ward_in_hospital_cd
  , medical_care_info ->> ''main_course_cd'' AS main_course_cd
  , course.course_name AS course_name
  , LEFT(COALESCE(course.in_hospital_cd_1, (SELECT value FROM def_course)), 15) AS course_in_hospital_cd
FROM
  pat_main AS main 
  LEFT JOIN mst_ward AS ward ON ward.ward_cd ::TEXT = main.medical_care_info ->> ''ward_cd'' 
  LEFT JOIN mst_course AS course ON course.course_cd ::TEXT = main.medical_care_info ->> ''main_course_cd'' 
WHERE
  pat_id = @patId', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'Medicom検査オーダ', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-310005, 'WITH other_sex AS(
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
    AND info ->> ''key2'' = ''DEFAULT_SEX''
),
pat_id_digit AS(
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
    AND info ->> ''key2'' = ''PAT_ID_DIGIT''
),
pat_id_padding AS(
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
    AND info ->> ''key2'' = ''PAT_ID_PADDING''
),
unset_default_name AS(
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
    AND info ->> ''key2'' = ''UNSET_DEFAULT_NAME''
),
outside_terms_default_name AS(
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
    AND info ->> ''key2'' = ''OUTSIDE_TERMS_DEFAULT_NAME''
)

SELECT
  CASE 
    WHEN @patSex::text IN (''1'',''2'') THEN @patSex::text
    ELSE (SELECT value FROM other_sex)
    END AS pat_sex,
  CASE (SELECT value FROM pat_id_padding)
    WHEN ''0'' THEN LPAD(@hospPatId::text, (SELECT value FROM pat_id_digit)::smallint, ''0'')
    WHEN ''1'' THEN RPAD(@hospPatId::text, (SELECT value FROM pat_id_digit)::smallint, ''0'') 
    ELSE @hospPatId::text
    END AS hosp_pat_id,
  CASE 
    WHEN COALESCE(@patNameKana,'''') = '''' THEN (SELECT value FROM unset_default_name)
    ELSE 
        CASE
        WHEN @patNameKana  ~ ''^[ァ-ヶｦ-ﾟｱ-ﾝ 　]+$'' THEN LEFT(hankana_translate(@patNameKana), 20)
        ELSE (SELECT value FROM outside_terms_default_name)
        END
    END AS pat_name_kana', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom検査オーダ連携用の連携設定で変換する値取得', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, '[{"sql_cd": -310004, "field_name": "hosp_pat_id", "replace_var": "@hospPatId"}, {"sql_cd": -310004, "field_name": "pat_name_kana", "replace_var": "@patNameKana"}, {"sql_cd": -310004, "field_name": "pat_sex", "replace_var": "@patSex"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-310006, 'WITH exam_data AS(
  SELECT
    TO_CHAR(reg_exam_date, ''YYYYMMDD'') AS exam_date,
    CASE reg_order_class
      WHEN ''0'' THEN '' ''
      ELSE reg_order_class
    END AS exam_timing,
    exam_set_info ->> ''set_cd'' AS exam_set_cd,
    pat_id
  FROM
    ntss.pat_exam_main
    CROSS JOIN
      LATERAL json_array_elements(
        pat_exam_main.order_exam_set_info::json
      ) exam_set_info
  WHERE
    exam_main_cd = @ordNo
  limit 1
),
exam_set_data AS(
  SELECT
    other_exam_time
  FROM
    mst_exam_set
  WHERE
    exam_set_cd = (
      SELECT
        exam_set_cd
      FROM
        exam_data
    )::int
),
ord_data AS(
  SELECT
    ord_main.ind_treat_start_time,
    ord_main.ind_cond_info,
    ord_main.ind_bed_cd
  FROM
    ord_main
  WHERE
    pat_id = (
      SELECT
        pat_id
      FROM
        exam_data
    )
  AND treat_date = (
      SELECT
        exam_date
      FROM
        exam_data
    )
  AND ind_kur_cd > 0
  AND ord_main.is_del = ''0''
  ORDER BY
    ind_treat_start_time ASC
  LIMIT 1
),
before_margin AS(
  SELECT
    COALESCE(
      NULLIF(
        info ->> ''value'',
        ''''
      ),
      info ->> ''default_v''
    ) AS value
  FROM
    mst_coop_ini AS ini
    CROSS JOIN
      LATERAL json_array_elements(
        ini.coop_ini_info::json
      ) info
  WHERE
    facility_cd = @facilityCd
  AND is_del = ''0''
  AND info ->> ''key0'' = @key0
  AND info ->> ''key1'' = ''EXAM_ORD''
  AND info ->> ''key2'' = ''BEFORE_MARGIN''
),
after_margin AS(
  SELECT
    COALESCE(
      NULLIF(
        info ->> ''value'',
        ''''
      ),
      info ->> ''default_v''
    ) AS value
  FROM
    mst_coop_ini AS ini
    CROSS JOIN
      LATERAL json_array_elements(
        ini.coop_ini_info::json
      ) info
  WHERE
    facility_cd = @facilityCd
  AND is_del = ''0''
  AND info ->> ''key0'' = @key0
  AND info ->> ''key1'' = ''EXAM_ORD''
  AND info ->> ''key2'' = ''AFTER_MARGIN''
),
output_bed_no AS(
  SELECT
    COALESCE(
      NULLIF(
        info ->> ''value'',
        ''''
      ),
      info ->> ''default_v''
    ) AS value
  FROM
    mst_coop_ini AS ini
    CROSS JOIN
      LATERAL json_array_elements(
        ini.coop_ini_info::json
      ) info
  WHERE
    facility_cd = @facilityCd
  AND is_del = ''0''
  AND info ->> ''key0'' = @key0
  AND info ->> ''key1'' = ''EXAM_ORD''
  AND info ->> ''key2'' = ''OUTPUT_BED_NO''
)
SELECT
  exam_date,
  exam_timing,
  CASE exam_timing
    WHEN ''1'' THEN to_char((
        ind_treat_start_time::time - ((
            SELECT
              value
            FROM
              before_margin
          ) || '' minutes'')::interval
      ), ''HH24MI'')
    WHEN ''2'' THEN to_char((
        ind_treat_start_time::time + (
          ind_cond_info -> ''1'' ->> ''value'' || '' minutes''
        )::interval + ((
            SELECT
              value
            FROM
              after_margin
          ) || '' minutes'')::interval
      ), ''HH24MI'')
    ELSE(
      SELECT
        other_exam_time
      FROM
        exam_set_data
    )
  END AS exam_time,
  CASE(
      SELECT
        value
      FROM
        output_bed_no
    )
    WHEN ''1'' THEN
        ord_data.ind_bed_cd::text
    ELSE ''    ''
  END AS bed_cd
FROM
  exam_data,
  ord_data', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'Medicom', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-310007, 'WITH  sequence_digit AS(
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
    AND info ->> ''key2'' = ''SEQUENCE_DIGIT''
),
journal AS (
  SELECT
    COUNT(1) AS CNT 
  FROM
    sys_coop_journal AS coop1 
    JOIN sys_coop_journal AS coop2 
    ON coop1.facility_cd = coop2.facility_cd
    AND coop1.ctl_no = @ctlNo
    AND coop1.coop_cd = coop2.coop_cd
    AND TO_CHAR(coop2.reg_date, ''YYYYMMDD'') = TO_CHAR(coop1.reg_date, ''YYYYMMDD'') 
    AND coop2.ctl_no < @ctlNo
)

SELECT to_char(CURRENT_TIMESTAMP, ''YYMMDD'') || LPAD(((SELECT CNT FROM journal) % (RPAD(''1'', value::smallint, ''0'')::smallint))::text, value::smallint, ''0'') || ''.txt'' AS filename FROM sequence_digit', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom検査オーダファイル名取得', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-310008, 'WITH
min_staff_ctl_no AS (
SELECT min(staff.value ->> ''ctl_no'') AS min_is_main_ctl_no
FROM pat_main 
        CROSS JOIN
            LATERAL json_array_elements(pat_main.charge_staff_info::json) staff
    WHERE
        pat_id = @patId
        AND staff.value ->> ''is_main'' = ''1'' 
),
staff AS (
SELECT 
    staff.value ->> ''staff_cd'' staff_cd
from pat_main 
        CROSS JOIN
            LATERAL json_array_elements(pat_main.charge_staff_info::json) staff
    WHERE
        pat_id = @patId
        and staff.value ->> ''ctl_no'' = (SELECT min_is_main_ctl_no FROM min_staff_ctl_no)
),
def_doctor AS(
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
    AND info ->> ''key2'' = ''DEFAULT_DOCTOR''
)


SELECT 
    CASE 
    WHEN (SELECT min_is_main_ctl_no FROM min_staff_ctl_no) IS NULL THEN (SELECT value FROM def_doctor)
    ELSE (SELECT staff_cd FROM staff)
    END AS staff_cd
    ,CASE 
    WHEN (SELECT min_is_main_ctl_no FROM min_staff_ctl_no) IS NULL THEN 0
    ELSE 1
    END AS is_conv', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom検査オーダ担当医取得事前SQL', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
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
    AND info ->> ''key0'' = @key0
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
    AND info ->> ''key0'' = @key0
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
    AND info ->> ''key0'' = @key0
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
              WHERE info ->> ''no'' IN (SELECT no FROM item_set_no)
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
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-310012, 'WITH  coop_update AS(
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
    AND info ->> ''key2'' = ''COOP_UPDATE''
), ord_coop AS (
SELECT ctl_no
FROM ord_coop_no
WHERE
ord_no = @ordNo
AND coop_cd = ''exam_ord''
AND facility_cd = @facilityCd
AND status = ''1''
)

SELECT ''O1'' AS kbn
WHERE 
CASE (SELECT value FROM coop_update)
WHEN ''0'' THEN (SELECT ctl_no FROM ord_coop) IS NULL
ELSE true
END', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'Medicom検査オーダ 修正連携判定', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-310014, 'with
min_staff_ctl_no AS (
SELECT min(staff.value ->> ''ctl_no'') AS min_is_main_ctl_no
FROM pat_main 
        CROSS JOIN
            LATERAL json_array_elements(pat_main.charge_staff_info::json) staff
    WHERE
        pat_id = @patId
        AND staff.value ->> ''is_main'' = ''1'' 
)
,staff AS (
SELECT 
    staff.value ->> ''staff_cd'' staff_cd
from pat_main 
        CROSS JOIN
            LATERAL json_array_elements(pat_main.charge_staff_info::json) staff
    WHERE
        pat_id = @patId
        and staff.value ->> ''ctl_no'' = (SELECT min_is_main_ctl_no FROM min_staff_ctl_no)
)
,def_doctor AS(
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
    AND info ->> ''key2'' = ''DEFAULT_DOCTOR''
)
, doctor_data as(
SELECT 
    CASE 
    WHEN (SELECT min_is_main_ctl_no FROM min_staff_ctl_no) IS NULL THEN (SELECT value FROM def_doctor)
    ELSE (SELECT staff_cd FROM staff)
    END AS staff_cd
)
,exam_data as (
    select
        TO_CHAR(
            reg_exam_date,
            ''YYYYMMDD''
        ) as exam_date,
        case
            reg_order_class
    when ''0'' then '' ''
            else reg_order_class
        end as exam_timing,
        order_exam_set_info
    from
        ntss.pat_exam_main
    where
        exam_main_cd = @ordNo ::integer
        --    )
),
output_item as(
    select
        coalesce(
            nullif(
                info ->> ''value'',
                ''''
            ),
            info ->> ''default_v''
        ) as value
    from
        mst_coop_ini as ini
    cross join
            lateral json_array_elements(
            ini.coop_ini_info::json
        ) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = @key0
        and info ->> ''key1'' = ''EXAM_ORD''
        and info ->> ''key2'' = ''OUTPUT_ITEM''
)
,
exam_set as(
    select
        exam_set.other_exam_time
    from
        (
            select
                order_exam_set_info
            from
                exam_data
        ) p
    cross join lateral json_array_elements(
            p.order_exam_set_info ::json
        ) info
    inner join mst_exam_set as exam_set 
                on
        info ->> ''set_cd'' = (
            exam_set.exam_set_cd || ''''
        )
),
before_margin as(
    select
        coalesce(
            nullif(
                info ->> ''value'',
                ''''
            ),
            info ->> ''default_v''
        ) as value
    from
        mst_coop_ini as ini
    cross join
            lateral json_array_elements(
            ini.coop_ini_info::json
        ) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = @key0
        and info ->> ''key1'' = ''EXAM_ORD''
        and info ->> ''key2'' = ''BEFORE_MARGIN''
),
after_margin as(
    select
        coalesce(
            nullif(
                info ->> ''value'',
                ''''
            ),
            info ->> ''default_v''
        ) as value
    from
        mst_coop_ini as ini
    cross join
            lateral json_array_elements(
            ini.coop_ini_info::json
        ) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = @key0
        and info ->> ''key1'' = ''EXAM_ORD''
        and info ->> ''key2'' = ''AFTER_MARGIN''
),
ord_data as(
    select
        ord.ord_no,
        ord.ind_treat_start_time,
        ind_cond_info -> ''1'' ->> ''value'' as plan_dialysis_time
    from
        (
            select
                *
            from
                ord_main
            where
                pat_id = @patId ::integer
                and treat_date = (
                    select
                        exam_date
                    from
                        exam_data
                )
                and is_del = ''0''
            order by
                ind_treat_start_time asc
            limit 1
        ) ord
),
exam_time as (
    select
        (
            select
                ord_no
            from
                ord_data
        ) as ord_no,
        exam_date,
        exam_timing,
        case
            exam_timing
  when ''1'' then 
  to_char(
                (
                    (
                        select
                            ind_treat_start_time
                        from
                            ord_data
                    )::time - (
                        (
                            select
                                value
                            from
                                before_margin
                        ) || '' minutes''
                    )::interval
                ),
                ''HH24MI''
            )
            when ''2'' then 
  to_char(
                (
                    (
                        select
                            ind_treat_start_time
                        from
                            ord_data
                    )::time + (
                        (
                            select
                                plan_dialysis_time
                            from
                                ord_data
                        ) || '' minutes''
                    )::interval + (
                        (
                            select
                                value
                            from
                                after_margin
                        ) || '' minutes''
                    )::interval
                ),
                ''HH24MI''
            )
            else (
                select
                    other_exam_time
                from
                    exam_set
            )
        end as exam_time
    from
        exam_data
),
output_in_out as(
    select
        coalesce(
            nullif(
                info ->> ''value'',
                ''''
            ),
            info ->> ''default_v''
        ) as value
    from
        mst_coop_ini as ini
    cross join
            lateral json_array_elements(
            ini.coop_ini_info::json
        ) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = @key0
        and info ->> ''key1'' = ''EXAM_ORD''
        and info ->> ''key2'' = ''OUTPUT_IN_OUT''
),
item_set_no as (
    --SELECT info.value ->> ''no'' AS no
    select
        info ->> ''set_cd'' as no
    from
        (
            select
                m.*
            from
                pat_exam_main as m
            where
                m.is_del = ''0''
                and jsonb_array_length(m.order_exam_set_info) > 0
                    and m.exam_main_cd = @ordNo ::integer
        ) p
    cross join lateral json_array_elements(
            p.order_exam_set_info ::json
        ) info
    inner join mst_exam_set as item 
                on
        info ->> ''set_cd'' = (
            item.exam_set_cd || ''''
        )
),
exam_items AS (
select
    item_cd,
    item_name,
    in_hospital_cd1,
    in_hospital_cd2,
    in_hospital_cd3
from
    (
        select
            info ->> ''set_cd'' as seq_no,
            ''6'' as sub_no,
            -- 子（検査項目）
            info ->> ''item_cd'' as item_cd,
            info ->> ''item_name'' as item_name,
            item.in_hospital_cd1,
            item.in_hospital_cd2,
            item.in_hospital_cd3
        from
            (
                select
                    m.*
                from
                    pat_exam_main as m
                where
                    m.is_del = ''0''
                    and jsonb_array_length(m.order_exam_set_info) > 0
                        and m.exam_main_cd = @ordNo ::integer
            ) p
        cross join lateral json_array_elements(
                p.exam_order_info ::json
            ) info
        join mst_exam_item as item 
            on
            info ->> ''item_cd'' = (
                item.exam_item_cd || ''''
            )
            and 
                case (select value from output_in_out)
                when ''1'' then item.is_in_hospital = ''0''
                when ''2'' then item.is_in_hospital = ''1''
                else true
            end
        where
            info ->> ''set_cd'' in (
                select
                    no
                from
                    item_set_no
            )
            and
          case
                (
                    select
                        value
                    from
                        output_item
                )
                when ''1'' then false
                else true
            end
    union all
        select
            info ->> ''set_cd'' as seq_no,
            ''5'' as sub_no,
            -- 親（検査セット）
            info ->> ''set_cd'' as item_cd,
            info ->> ''set_name'' as item_name,
            item.in_hospital_cd1,
            item.in_hospital_cd2,
            item.in_hospital_cd3
        from
            (
                select
                    m.*
                from
                    pat_exam_main as m
                where
                    m.is_del = ''0''
                    and jsonb_array_length(m.order_exam_set_info) > 0
                        and m.exam_main_cd = @ordNo ::integer
            ) p
        cross join lateral json_array_elements(
                p.order_exam_set_info ::json
            ) info
        left outer join mst_exam_set as item
            on
            info ->> ''set_cd'' = (
                item.exam_set_cd || ''''
            )
        where
            info ->> ''set_cd'' in (
                select
                    no
                from
                    item_set_no
            )
            and 
          case
                (
                    select
                        value
                    from
                        output_item
                )
                when ''2'' then false
                else true
            end
    ) exam_all
order by
    item_cd
)
INSERT INTO ntss.pat_coop_detail(
    facility_cd,
    pat_id,
    save_1,
    save_2,
    is_disp,
    is_del,
    user_id,
    up_date,
    reg_date,
    coop_version
)
SELECT
    @facilityCd,
    @patId::integer,
    ''{"pkg": "MED"}''::jsonb,
    jsonb_build_object(
        ''ord_no'', (SELECT ord_no FROM ord_data),
        ''hosp_pat_id'', LPAD(@hospPatId::text, 12, ''0''),
        ''exam_date'', (SELECT exam_date FROM exam_data), 
        ''exam_timing'', (SELECT exam_timing FROM exam_data),
        ''exam_time'', (SELECT exam_time FROM exam_time),
        ''staff_cd'',(SELECT staff_cd FROM doctor_data),
        ''exam_items'',
        (select jsonb_agg(
            jsonb_build_object(
                    ''exam_cd'',item_cd,
                    ''exam_name'',item_name,
                    ''in_hospital_cd1'',in_hospital_cd1,
                    ''in_hospital_cd2'',in_hospital_cd2,
                    ''in_hospital_cd3'',in_hospital_cd3
                )
            )
            from exam_items
        )::jsonb),
    ''1'',
    ''0'',
    - 1,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    ''MED''
FROM
    exam_items
    limit 1', 2, '[]'::jsonb, '0', '{"applications": [6]}'::jsonb, NULL, 'Medicom検査依頼実績連携', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, '[{"sql_cd": -310009, "field_name": "staff_cd", "replace_var": "@doctorCd"}, {"sql_cd": -310009, "field_name": "user_name", "replace_var": "@doctorName"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-310016, 'WITH exam_data AS(
  SELECT
    TO_CHAR(reg_exam_date, ''YYYYMMDD'') AS exam_date,
    reg_order_class
  FROM
    ntss.pat_exam_main
  WHERE
    exam_main_cd = @ordNo::integer
    AND facility_cd = @facilityCd
),
ord_data AS(
  SELECT
    1 AS exist
  FROM
    ord_main
  WHERE
    treat_date = (SELECT exam_date FROM exam_data)
    AND facility_cd = @facilityCd
    AND pat_id = @patId::integer
    AND is_del = ''0''
  LIMIT 1
)
SELECT 1
WHERE (SELECT reg_order_class FROM exam_data) = ''0''
OR (SELECT exist FROM ord_data) IS NOT NULL', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom検査オーダ 連携判定', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-1202002,-1202003,-1202004,-1202005,-1202006);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1202002, 'WITH do_pat_exam_main AS (
    SELECT
        emc.exam_main_cd
        , emc.reg_exam_date
        , emc.reg_order_class
        , emc.pat_id
        , 0 AS idx
        , emc.up_date
        , (elem ->> ''set_cd'')::int AS set_cd
    FROM
      pat_exam_main_hst AS emc
      LEFT JOIN LATERAL jsonb_array_elements(emc.order_exam_set_info) AS elem ON true
    WHERE exam_main_cd = @ordNo
    UNION
    SELECT
        emc.exam_main_cd
        , emc.reg_exam_date
        , emc.reg_order_class
        , emc.pat_id
        , 0 AS idx
        , emc.up_date
        , (elem ->> ''set_cd'')::int AS set_cd
    FROM
      pat_exam_main AS emc
      LEFT JOIN LATERAL jsonb_array_elements(emc.order_exam_set_info) AS elem ON true
    WHERE exam_main_cd = @ordNo
    ORDER BY
        idx ASC
        , up_date DESC
    LIMIT 1
),
do_ord_main AS (
  (
    SELECT
      ord_i.rst_edition_date as up_date_switch,
      COALESCE(ord_i.ind_kur_cd, (ord_i.ind_schedule_user_info ->> ''ind_kur_cd_before'')::int) as ind_kur_cd,
      ord_i.ind_cond_info -> ''1'' ->> ''value'' AS treat_times
    FROM ord_main_restore as ord_i
    WHERE ord_i.pat_id = (SELECT pat_id FROM do_pat_exam_main) AND ord_i.treat_date = TO_CHAR((SELECT reg_exam_date FROM do_pat_exam_main), ''YYYYMMDD'') AND
          ord_i.ind_kur_cd > 0 AND ord_i.is_del = ''0''
    ORDER BY ord_i.del_date DESC LIMIT 1
  )
  UNION
  (
    SELECT
      ord_i.rst_edition_date as up_date_switch,
      COALESCE(ord_i.ind_kur_cd, (ord_i.ind_schedule_user_info ->> ''ind_kur_cd_before'')::int) as ind_kur_cd,
      ord_i.ind_cond_info -> ''1'' ->> ''value'' AS treat_times
    FROM ord_main AS ord_i
    WHERE ord_i.pat_id = (SELECT pat_id FROM do_pat_exam_main) AND ord_i.treat_date = TO_CHAR((SELECT reg_exam_date FROM do_pat_exam_main), ''YYYYMMDD'') AND
          ord_i.ind_kur_cd > 0 AND ord_i.is_del = ''0''
  )
  ORDER BY
    up_date_switch DESC NULLS LAST
  LIMIT 1
),
standard_start_time as (
  -- クールの開始時間
  select
    COALESCE(NULLIF(kur_standard_start_time,''''),''000000'') as kur_standard_start_time
  from mst_kur where kur_cd = (SELECT ind_kur_cd FROM do_ord_main)
),
other_start_time AS(
-- セットの開始時間（その他の透析時刻）
  select
    other_exam_time
  FROM mst_exam_set
  where  exam_set_cd = (SELECT set_cd FROM do_pat_exam_main)
),
margin_time_0 as (
    -- 透析前マージン時間
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''EXAM_MARGIN_TIME''
        and info->>''key2'' = ''DIAL_BEFORE''
),
margin_time_1 as (
    -- 透析後マージン時間
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''EXAM_MARGIN_TIME''
        and info->>''key2'' = ''DIAL_AFTER''
)
select
  COALESCE(CASE reg_order_class
    WHEN ''1'' THEN
      -- 透析前
      TO_CHAR(
          (SUBSTRING((SELECT kur_standard_start_time FROM standard_start_time) FROM 1 FOR 2)::int || '':'' ||
           SUBSTRING((SELECT kur_standard_start_time FROM standard_start_time) FROM 3 FOR 2)::int || '':'' ||
           SUBSTRING((SELECT kur_standard_start_time FROM standard_start_time) FROM 5 FOR 2)::int
          )::time
          - (INTERVAL ''1minute'' * TO_NUMBER( COALESCE(NULLIF((SELECT value FROM margin_time_0),''''),''0''), ''FM999999''))
      , ''HH24MI'')
    WHEN ''2'' then
      -- 透析後
      TO_CHAR(
          (SUBSTRING((SELECT kur_standard_start_time FROM standard_start_time) FROM 1 FOR 2)::int || '':'' ||
           SUBSTRING((SELECT kur_standard_start_time FROM standard_start_time) FROM 3 FOR 2)::int || '':'' ||
           SUBSTRING((SELECT kur_standard_start_time FROM standard_start_time) FROM 5 FOR 2)::int
          )::time
          + (INTERVAL ''1minute'' * TO_NUMBER( COALESCE(NULLIF((SELECT treat_times FROM do_ord_main),''''),''0''), ''FM999999''))
          + (INTERVAL ''1minute'' * TO_NUMBER( COALESCE(NULLIF((SELECT value FROM margin_time_1),''''),''0''), ''FM999999''))
      , ''HH24MI'')
    WHEN ''0'' then
      -- その他
      (SELECT other_exam_time FROM other_start_time)
    ELSE NULL  END , ''0000'') AS treat_time
from do_pat_exam_main', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'SX_血液検査依頼検査予定時刻', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1202003, 'SELECT
  ward.ward_name AS ward_name
  , course.course_name AS course_name
FROM
  pat_main AS main
  LEFT JOIN mst_ward AS ward ON ward.ward_cd ::TEXT = main.medical_care_info ->> ''ward_cd''
  LEFT JOIN mst_course AS course ON course.course_cd ::TEXT = main.medical_care_info ->> ''dialysis_course_cd''
WHERE
  main.pat_id = @patId
  AND main.facility_cd = @facilityCd
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'SX_血液検査依頼病棟・透析実施科', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1202004, 'SELECT
  CASE
    WHEN ppm.in_out_class IN (0, 1) THEN ppm.in_out_class
    ELSE NULL
    END AS in_out_class
  , CASE @aligh
		WHEN ''0'' THEN lpad(lpad(RIGHT(hosp_pat_id, COALESCE(@len, 15)), COALESCE(@len, 15), ''0''), 15, ''0'')
    ELSE rpad(lpad(RIGHT(hosp_pat_id, COALESCE(@len, 15)), COALESCE(@len, 15), ''0''), 15, ''0'')
    END AS hosp_pat_id
  , TRIM(CONCAT(personal_info_decrypt(pat_last_name_kana), '' '', personal_info_decrypt(pat_first_name_kana))) AS pat_name_kana
  , CASE
    WHEN ppm.pat_sex IN (1, 2) THEN ppm.pat_sex
    ELSE 0
    END AS pat_sex
  , SUBSTRING(ppm.pat_birthday, 3) AS pat_birthday
FROM pat_personal_main ppm
WHERE
  ppm.pat_id = @patId
', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'SX_血液検査依頼患者情報', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1201009, "field_name": "len", "replace_var": "@len"}, {"sql_cd": -1201008, "field_name": "aligh", "replace_var": "@aligh"}]'::jsonb);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1202005, 'WITH dump_text AS (
SELECT
  convert_from(scj.dump, ''shift-jis'') AS dump_text
FROM
  sys_coop_journal AS scj
WHERE
  pat_id = @patId
  AND facility_cd = @facilityCd
  AND crud IN (''C'', ''U'')
  AND ord_no = @ordNo
  AND coop_cd = @coopCd
  AND key0 = @key0
  AND ana_result = ''9''
  AND coop_result IN (''9'',''8'',''1'',''0'')
ORDER BY
  scj.up_date DESC
LIMIT 1
)
SELECT
  CASE Count(*)
    WHEN 0 THEN NULL
	ELSE 1
  END AS dump_result
FROM
	dump_text', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'SX_血液検査依頼従来処理呼出判定', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1202006, 'select
  CASE @dumpResult
    WHEN ''1'' THEN ''01''
    ELSE ''02''
    END AS detail_id,
  @facilityCd AS facility_cd,
  @ctlNo AS ctl_no,
  @key0 AS key0,
  @patId AS pat_id,
  @ordNo AS ord_no', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'SX_血液検査依頼削除使用レイアウト判定', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1202005, "field_name": "dump_result", "replace_var": "@dumpResult"}]'::jsonb);

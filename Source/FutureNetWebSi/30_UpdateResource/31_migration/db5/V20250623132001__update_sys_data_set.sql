DELETE FROM sys_data_set WHERE sql_cd IN 
(-1202002);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1202002, 'WITH do_pat_exam_main AS (
    SELECT
        emc.exam_main_cd
        , emc.reg_exam_date
        , emc.reg_order_class
        , emc.exam_order_info
        , emc.is_del
        , emc.order_exam_set_info
        , emc.pat_id
        , 0 AS idx
        , emc.up_date
        , (elem ->> ''set_cd'')::int AS set_cd
    FROM 
      pat_exam_main_hst AS emc
      LEFT JOIN LATERAL jsonb_array_elements(emc.order_exam_set_info) AS elem ON true
    WHERE exam_main_cd = @ordNo
    AND is_del = ''0''
    UNION
    SELECT
        emc.exam_main_cd
        , emc.reg_exam_date
        , emc.reg_order_class
        , emc.exam_order_info
        , emc.is_del
        , emc.order_exam_set_info
        , emc.pat_id
        , 0 AS idx
        , emc.up_date
        , (elem ->> ''set_cd'')::int AS set_cd
    FROM 
      pat_exam_main AS emc
      LEFT JOIN LATERAL jsonb_array_elements(emc.order_exam_set_info) AS elem ON true
    WHERE exam_main_cd = @ordNo

    AND is_del = ''0''
    ORDER BY
        idx ASC
        , up_date DESC
    LIMIT 1
),
do_ord_main AS (
  (
    SELECT
      ord_i.rst_edition_date as up_date_switch,
      ord_i.ord_no AS ord_no,
      ord_i.rst_equip_info AS rst_equip_info,
      ord_i.rst_cond_info AS rst_cond_info,
      ord_i.ind_treat_start_time,
      ord_i.ind_cond_info,
      ord_i.ind_kur_cd,
      ord_i.ind_cond_info -> ''1'' ->> ''value'' AS treat_times
    FROM ord_main_restore as ord_i
    JOIN sys_coop_journal AS journal ON ord_i.ord_no = journal.ord_no
    WHERE ord_i.pat_id = (SELECT pat_id FROM do_pat_exam_main) AND ord_i.treat_date = TO_CHAR((SELECT reg_exam_date FROM do_pat_exam_main), ''YYYYMMDD'') AND
          ord_i.ind_kur_cd > 0 AND ord_i.is_del = ''0''
    ORDER BY ord_i.del_date DESC LIMIT 1
  )
  UNION
  (
    SELECT
      ord_i.rst_edition_date as up_date_switch,
      ord_i.ord_no AS ord_no,
      ord_i.rst_equip_info AS rst_equip_info,
      ord_i.rst_cond_info AS rst_cond_info,
      ord_i.ind_treat_start_time,
      ord_i.ind_cond_info,
      ord_i.ind_kur_cd,
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
        and info->>''key1'' = ''MARGIN_TIME''
        and info->>''key2'' = ''0''
),
margin_time_1 as (
    -- 透析後マージン時間
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''MARGIN_TIME''
        and info->>''key2'' = ''1''
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
    ELSE NULL  END , '''') AS treat_time
from do_pat_exam_main', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'SX_血液検査依頼検査予定時刻', '2025-06-17 16:24:02.961', CURRENT_TIMESTAMP, NULL);


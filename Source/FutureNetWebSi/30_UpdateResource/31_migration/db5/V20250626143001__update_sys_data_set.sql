DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-1202001,-1202002,-1202007,-1202008);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1202001, 'WITH do_pat_exam_main AS (
    SELECT
        exam_main_cd
        , reg_exam_date
        , reg_order_class
        , exam_order_info
        , is_del
        , order_exam_set_info
        , pat_id
        , 0 AS idx
        , up_date
    FROM pat_exam_main_hst
    WHERE exam_main_cd = @ordNo
    UNION
    SELECT
        exam_main_cd
        , reg_exam_date
        , reg_order_class
        , exam_order_info
        , is_del
        , order_exam_set_info
        , pat_id
        , 0 AS idx
        , up_date
    FROM pat_exam_main
    WHERE exam_main_cd = @ordNo
    ORDER BY
        idx ASC
        , up_date DESC
    LIMIT 1
),
dialysis_kbn_1 as (
    -- 透析区分1(透析前)
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as kbn
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''CONV_EXAMIN_ORDER_CLASS_TO_KARTE''
        and info->>''key2'' = ''1''
),
dialysis_kbn_2 as (
    -- 透析区分2(透析後)
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as kbn
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''CONV_EXAMIN_ORDER_CLASS_TO_KARTE''
        and info->>''key2'' = ''2''
),
dialysis_kbn_0 as (
    -- 透析区分0(その他)
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as kbn
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''CONV_EXAMIN_ORDER_CLASS_TO_KARTE''
        and info->>''key2'' = ''0''
)
select
  TO_CHAR(reg_exam_date, ''YYYYMMDD'') as exam_date_yyyymmdd,  --検査予定日
  TO_CHAR(reg_exam_date, ''YYMMDD'')   as exam_date_yymmdd,     --採取日

  COALESCE(CASE reg_order_class
    WHEN ''1'' THEN coalesce( (SELECT kbn FROM dialysis_kbn_1) , ''1'')
    WHEN ''2'' THEN coalesce( (SELECT kbn FROM dialysis_kbn_2) , ''2'')
    WHEN ''0'' THEN coalesce( (SELECT kbn FROM dialysis_kbn_0) , ''0'')
    ELSE NULL  END , '''') AS dialysis_kbn --透析区分
from do_pat_exam_main



', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'SX_血液検査依頼検査情報', '2025-06-13 14:55:54.000', CURRENT_TIMESTAMP, NULL);
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
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1202007, 'WITH coop_ini_info AS (
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
        , info ->> ''key1'' AS key1
        , info ->> ''key2'' AS key2
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE
        facility_cd = @facilityCd
        AND is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = @key0
)
, exam_inhosp AS ( --検査項目マスタの使用院内コード番号
    SELECT *
    FROM coop_ini_info
    WHERE key1 = ''SX_EXAM_SCHE_INFO''
        AND key2 = ''EXAM_INHOSP''
)
, exam_set_inhosp AS ( --検査セットマスタの使用院内コード番号
    SELECT *
    FROM coop_ini_info
    WHERE key1 = ''SX_EXAM_SCHE_INFO''
        AND key2 = ''EXAM_SET_INHOSP''
)
, output_setting AS ( --院外院内フラグ(0:両方, 1:院内のみ,2:院外のみ)
    SELECT *
    FROM coop_ini_info
    WHERE key1 = ''IN_OUT_HOSPITAL''
        AND key2 = ''OUTPUTSETTING''
)
, do_pat_exam_main AS (
    SELECT
        exam_order_info
        , 0 AS idx
        , up_date
    FROM pat_exam_main_hst
    WHERE exam_main_cd = @ordNo
    UNION
    SELECT
        exam_order_info
        , 1 AS idx
        , up_date
    FROM pat_exam_main
    WHERE exam_main_cd = @ordNo
    ORDER BY
        idx ASC
        , up_date DESC
    LIMIT 1
)
SELECT lpad(RIGHT(TO_CHAR(COUNT(DISTINCT mes.exam_set_cd), ''FM999999999''), 3), 3, '' '') AS count
FROM do_pat_exam_main pem
CROSS JOIN LATERAL jsonb_array_elements(pem.exam_order_info) info
LEFT JOIN mst_exam_set mes ON info ->> ''set_cd'' = mes.exam_set_cd ::text
LEFT JOIN mst_exam_item mei ON info ->> ''item_cd'' = mei.exam_item_cd ::text
WHERE
  mes.facility_cd = @facilityCd
  AND mes.is_del = ''0''
  AND mes.is_disp = ''1''
  AND coalesce(
    (
      CASE (SELECT value FROM exam_set_inhosp)
      WHEN ''1'' THEN mes.in_hospital_cd1
      WHEN ''2'' THEN mes.in_hospital_cd2
      WHEN ''3'' THEN mes.in_hospital_cd3
      ELSE mes.in_hospital_cd1
      END
    ), '''') <> ''''
  AND mei.facility_cd = @facilityCd
  AND mei.is_del = ''0''
  AND mei.is_disp = ''1''
  AND coalesce(
    (
      CASE (SELECT value FROM exam_inhosp)
      WHEN ''1'' THEN mei.in_hospital_cd1
      WHEN ''2'' THEN mei.in_hospital_cd2
      WHEN ''3'' THEN mei.in_hospital_cd3
      ELSE mei.in_hospital_cd1
      END
    ), '''') <> ''''
  AND CASE (SELECT value FROM output_setting)
    WHEN ''1'' THEN mei.is_in_hospital = ''1'' --院内のみ
    WHEN ''2'' THEN mei.is_in_hospital = ''0'' --院外のみ
    ELSE true
    END', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'SX_血液検査依頼項目数', '2025-06-19 11:08:22.806', CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1202008, 'WITH coop_ini_info AS (
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
        , info ->> ''key1'' AS key1
        , info ->> ''key2'' AS key2
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE
        facility_cd = @facilityCd
        AND is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = @key0
)
, exam_inhosp AS ( --検査項目マスタの使用院内コード番号
    SELECT *
    FROM coop_ini_info
    WHERE key1 = ''SX_EXAM_SCHE_INFO''
        AND key2 = ''EXAM_INHOSP''
)
, exam_set_inhosp AS ( --検査セットマスタの使用院内コード番号
    SELECT *
    FROM coop_ini_info
    WHERE key1 = ''SX_EXAM_SCHE_INFO''
        AND key2 = ''EXAM_SET_INHOSP''
)
, output_setting AS ( --院外院内フラグ(0:両方, 1:院内のみ,2:院外のみ)
    SELECT *
    FROM coop_ini_info
    WHERE key1 = ''IN_OUT_HOSPITAL''
        AND key2 = ''OUTPUTSETTING''
)
, do_pat_exam_main AS (
    SELECT
        exam_order_info
        , 0 AS idx
        , up_date
    FROM pat_exam_main_hst
    WHERE exam_main_cd = @ordNo
    UNION
    SELECT
        exam_order_info
        , 1 AS idx
        , up_date
    FROM pat_exam_main
    WHERE exam_main_cd = @ordNo
    ORDER BY
        idx ASC
        , up_date DESC
    LIMIT 1
)
, exam_set_order AS (
  SELECT
    index_no ::int AS idx_no
    , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS exam_set_code
  FROM mst_selector
  CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
  WHERE facility_cd = @facilityCd
    AND master_physical_name = ''mst_exam_set''
)
, exam_item_order AS (
  SELECT
    index_no ::int AS idx_no
    , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS exam_item_code
  FROM mst_selector
  CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
  WHERE facility_cd = @facilityCd
    AND master_physical_name = ''mst_exam_item''
)
, exam_data AS (
  SELECT
    CASE (SELECT value FROM exam_set_inhosp)
      WHEN ''1'' THEN mes.in_hospital_cd1
      WHEN ''2'' THEN mes.in_hospital_cd2
      WHEN ''3'' THEN mes.in_hospital_cd3
      ELSE mes.in_hospital_cd1
      END AS set_hosp_cd
    , CASE (SELECT value FROM exam_inhosp)
      WHEN ''1'' THEN mei.in_hospital_cd1
      WHEN ''2'' THEN mei.in_hospital_cd2
      WHEN ''3'' THEN mei.in_hospital_cd3
      ELSE mei.in_hospital_cd1
      END AS item_hosp_cd
    , eso.idx_no AS set_idx_no
    , eio.idx_no AS item_idx_no
  FROM do_pat_exam_main pem
  CROSS JOIN LATERAL jsonb_array_elements(pem.exam_order_info) info
  LEFT JOIN mst_exam_set mes ON info ->> ''set_cd'' = mes.exam_set_cd ::text
  LEFT JOIN exam_set_order eso ON info ->> ''set_cd'' = eso.exam_set_code ::text
  LEFT JOIN mst_exam_item mei ON info ->> ''item_cd'' = mei.exam_item_cd ::text
  LEFT JOIN exam_item_order eio ON info ->> ''item_cd'' = eio.exam_item_code ::text
  WHERE
    mes.facility_cd = @facilityCd
    AND mes.is_del = ''0''
    AND mes.is_disp = ''1''
    AND coalesce(
      (
        CASE (SELECT value FROM exam_set_inhosp)
        WHEN ''1'' THEN mes.in_hospital_cd1
        WHEN ''2'' THEN mes.in_hospital_cd2
        WHEN ''3'' THEN mes.in_hospital_cd3
        ELSE mes.in_hospital_cd1
        END
      ), '''') <> ''''
    AND mei.facility_cd = @facilityCd
    AND mei.is_del = ''0''
    AND mei.is_disp = ''1''
    AND coalesce(
      (
        CASE (SELECT value FROM exam_inhosp)
        WHEN ''1'' THEN mei.in_hospital_cd1
        WHEN ''2'' THEN mei.in_hospital_cd2
        WHEN ''3'' THEN mei.in_hospital_cd3
        ELSE mei.in_hospital_cd1
        END
      ), '''') <> ''''
    AND CASE (SELECT value FROM output_setting)
      WHEN ''1'' THEN mei.is_in_hospital = ''1'' --院内のみ
      WHEN ''2'' THEN mei.is_in_hospital = ''0'' --院外のみ
      ELSE true --両方
      END
)
SELECT
  ''検査項目'' as detail_id,
  (exam_full.exam_row + 1) as exam_row,
  max(case exam_full.exam_col when 0 then exam_full.hosp_cd else null end) as exam1,
  max(case exam_full.exam_col when 1 then exam_full.hosp_cd else null end) as exam2,
  max(case exam_full.exam_col when 2 then exam_full.hosp_cd else null end) as exam3,
  max(case exam_full.exam_col when 3 then exam_full.hosp_cd else null end) as exam4,
  max(case exam_full.exam_col when 4 then exam_full.hosp_cd else null end) as exam5,
  max(case exam_full.exam_col when 5 then exam_full.hosp_cd else null end) as exam6,
  max(case exam_full.exam_col when 6 then exam_full.hosp_cd else null end) as exam7,
  max(case exam_full.exam_col when 7 then exam_full.hosp_cd else null end) as exam8,
  max(case exam_full.exam_col when 8 then exam_full.hosp_cd else null end) as exam9,
  @key0 AS key0,
  @facilityCd AS facility_cd,
  @ordNo AS ord_no
FROM (
  SELECT
    (row_number() over () - 1) / 9 as exam_row
    , (row_number() over () - 1) % 9 as exam_col
    , exam.hosp_cd as hosp_cd
  FROM (
    SELECT
      data_list.hosp_cd AS hosp_cd
    FROM (
      SELECT DISTINCT--検査セットコード
        exam_data.set_hosp_cd AS hosp_cd
        , exam_data.set_idx_no AS set_idx_no
        , 0 AS item_idx_no
      FROM exam_data
      UNION ALL
      SELECT --検査項目コード
        exam_data.item_hosp_cd AS hosp_cd
        , exam_data.set_idx_no AS set_idx_no
        , exam_data.item_idx_no AS item_idx_no
      FROM exam_data
    ) data_list
    ORDER BY
      data_list.set_idx_no ASC
      , data_list.item_idx_no ASC
  ) exam
) exam_full
group by
  detail_id
  , exam_full.exam_row
order by
  exam_row', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'SX_血液検査依頼検査項目', '2025-06-12 17:35:49.385', CURRENT_TIMESTAMP, NULL);

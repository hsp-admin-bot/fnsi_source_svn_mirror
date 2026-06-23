DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-1202008);

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
    WHERE key1 = ''SX_EXAM_SCHE_INFO''
        AND key2 = ''EXAM_OUTPUT''
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

DELETE FROM ntss.sys_data_set
WHERE sql_cd=-501102;
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-501102, 'WITH  ord_main_max AS (
  (
    SELECT
      ord.ord_no,
      ord.del_date as up_date,
      ord.rst_equip_info,
      ord.rst_cond_info
    FROM
      ord_main_restore AS ord,
      sys_coop_journal as journal
    WHERE
      ord.ord_no = @ordNo
      AND journal.ctl_no = @ctlNo
      AND ord.ord_no = journal.ord_no
      AND journal.reg_date >= ord.del_date
    ORDER BY
      del_date DESC
    LIMIT
      1
  )
  UNION
  (
    SELECT
      ord.ord_no,
      ord.rst_edition_date as up_date,
      ord.rst_equip_info,
      ord.rst_cond_info
    FROM
      ord_main AS ord
    WHERE
      ord.ord_no = @ordNo
  )
  ORDER BY
    up_date DESC NULLS LAST
  LIMIT
    1
)
,equip_order_data AS (
  SELECT
      ROW_NUMBER() OVER ()                         AS no2
    , TO_NUMBER(elem, ''999999999999'')              AS ora
  FROM unnest(
        string_to_array(
            COALESCE(
                (
                  SELECT mst_f.value
                  FROM   mst_facility_setting AS mst_f
                  WHERE  mst_f.facility_setting_no = ''3006''
                    AND  mst_f.facility_cd       = @facilityCd
                  LIMIT  1
                ),
                ''0''
            ),
            '',''
        )
      ) AS elem
)
select
  cost_fin.detail_id as detail_id,
  to_char(row_number() over(
    ORDER BY
    CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 0 THEN cost_fin.meq_reg_order
        WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 1 THEN cost_fin.meq_class_code_order
        WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 2 THEN cost_fin.meq_code_order END,
    CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 0 THEN cost_fin.meq_reg_order
        WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 1 THEN cost_fin.meq_class_code_order
        WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 2 THEN cost_fin.meq_code_order END,
    CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 0 THEN cost_fin.meq_reg_order
        WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 1 THEN cost_fin.meq_class_code_order
        WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 2 THEN cost_fin.meq_code_order END, cost_fin.meq_code_order
  ),''FM9999'') as cost_no,
  trim(cost_fin.e01) as e01,
  cost_fin.e02 as e02,
  cost_fin.e03 as e03,
  cost_fin.e04 as e04,
  cost_fin.e05 as e05,
  cost_fin.e06 as e06
from
(
  select
    all_cost.*
    , ROW_NUMBER() OVER(ORDER BY all_cost.meq_reg_order_text) AS meq_reg_order
  from
  (
    WITH equip_order AS (
      SELECT
        index_no ::int AS meq_code_order
        , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS meq_code
      FROM mst_selector
      CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
      WHERE facility_cd = @facilityCd
        AND master_physical_name = ''mst_equipment''
    )
    , equip_class_order as (
      SELECT
        index_no ::int AS meq_class_code_order
        , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS meq_class_code
      FROM mst_selector
      CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
      WHERE facility_cd = @facilityCd
        AND master_physical_name = ''mst_equipment_class''
    )
    , dialyzer_order AS (
      SELECT
        index_no ::int AS mdi_code_order
        , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS mdi_code
      FROM mst_selector
      CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
      WHERE facility_cd = @facilityCd
        AND master_physical_name = ''mst_dialyzer''
    )
    , mst_equip AS (
      SELECT
        equipment_cd
        , equipment_name
        , meq.class_cd as class_cd
        , unit
        , meq.in_hospital_cd_1 as in_hospital_cd_1
        , equip_order.meq_code_order
        , equip_class_order.meq_class_code_order
        , mst_equipment_class.class_name as class_name
      FROM mst_equipment meq
      LEFT JOIN equip_order ON meq.equipment_cd = equip_order.meq_code
      LEFT JOIN equip_class_order ON meq.class_cd = equip_class_order.meq_class_code
      LEFT JOIN mst_equipment_class ON meq.class_cd = mst_equipment_class.class_cd
      WHERE meq.facility_cd = @facilityCd
    )
    , mst_dialyzer_wrap AS (
      SELECT
        dialyzer_cd
        , model_number
        , mdi.in_hospital_cd_1 as in_hospital_cd_1
        , dialyzer_order.mdi_code_order
      FROM mst_dialyzer mdi
      LEFT JOIN dialyzer_order ON mdi.dialyzer_cd = dialyzer_order.mdi_code
      WHERE mdi.facility_cd = @facilityCd
    )
    select --ダイアライザ
      ''ダイアライザ'' as detail_id,
      mdi.in_hospital_cd_1 as e01,
      mdi.model_number as e02,
      ''ダイアライザ'' as e03,
      ''0''as e04,
      ''1'' as e05,
      '''' as e06,
        0 AS meq_reg_order_text,
        ''0'' AS meq_class_code_order,
        mdi.mdi_code_order AS meq_code_order
    from
      ord_main_max ord
      left outer join
      mst_dialyzer_wrap as mdi
      on
      mdi.dialyzer_cd = TO_NUMBER (ord.rst_cond_info->''5''->>''value'',''999999999999'')
    where
      ord.ord_no = @ordNo

    union
    select --吸着カラム情報
      ''医材'' as detail_id,
      meq.in_hospital_cd_1 as e01,
      meq.equipment_name as e02,
      meq.class_name as e03,
      ''0''as e04,
      ''1'' as e05,
      meq.unit as e06,
        1 AS meq_reg_order_text,
        meq.meq_class_code_order AS meq_class_code_order,
        meq.meq_code_order AS meq_code_order
    from
      ord_main_max ord
      left outer join
      mst_equip as meq
      on
      meq.equipment_cd = TO_NUMBER (ord.rst_cond_info->''6''->>''value'',''999999999999'')
    where
      ord.ord_no = @ordNo

    union

    select --1次膜情報
      ''医材'' as detail_id,
      meq.in_hospital_cd_1 as e01,
      meq.equipment_name as e02,
      meq.class_name as e03,
      ''0''as e04,
      ''1'' as e05,
      meq.unit as e06,
        2 AS meq_reg_order_text,
        meq.meq_class_code_order AS meq_class_code_order,
        meq.meq_code_order AS meq_code_order
    from
      ord_main_max ord
      left outer join
      mst_equip as meq
      on
      meq.equipment_cd = TO_NUMBER (ord.rst_cond_info->''7''->>''value'',''999999999999'')
    where
      ord.ord_no = @ordNo

    union

    select --2次膜情報
      ''医材'' as detail_id,
      meq.in_hospital_cd_1 as e01,
      meq.equipment_name as e02,
      meq.class_name as e03,
      ''0''as e04,
      ''1'' as e05,
      meq.unit as e06,
        3 AS meq_reg_order_text,
        meq.meq_class_code_order AS meq_class_code_order,
        meq.meq_code_order AS meq_code_order
    from
      ord_main_max ord
      left outer join
      mst_equip as meq
      on
      meq.equipment_cd = TO_NUMBER (ord.rst_cond_info->''8''->>''value'',''999999999999'')
    where
      ord.ord_no = @ordNo

    union

    select --A針情報
      ''穿刺針'' as detail_id,
      meq.in_hospital_cd_1 as e01,
      meq.equipment_name as e02,
      meq.class_name as e03,
      ''1''as e04,
      ''1'' as e05,
      meq.unit as e06,
        4 AS meq_reg_order_text,
        meq.meq_class_code_order AS meq_class_code_order,
        meq.meq_code_order AS meq_code_order
    from
      ord_main_max ord
      left outer join
      mst_equip as meq
      on
      meq.equipment_cd = TO_NUMBER (ord.rst_cond_info->''9''->>''value'',''999999999999'')
    where
      ord.ord_no = @ordNo

    union

    select --V針情報
      ''穿刺針'' as detail_id,
      meq.in_hospital_cd_1 as e01,
      meq.equipment_name as e02,
      meq.class_name as e03,
      ''2''as e04,
      ''1'' as e05,
      meq.unit as e06,
        5 AS meq_reg_order_text,
        meq.meq_class_code_order AS meq_class_code_order,
        meq.meq_code_order AS meq_code_order
    from
      ord_main_max ord
      left outer join
      mst_equip as meq
      on
      meq.equipment_cd = TO_NUMBER (ord.rst_cond_info->''10''->>''value'',''999999999999'')
    where
      ord.ord_no = @ordNo

    union

    select --SN針情報
      ''穿刺針'' as detail_id,
      meq.in_hospital_cd_1 as e01,
      meq.equipment_name as e02,
      meq.class_name as e03,
      ''3''as e04,
      ''1'' as e05,
      meq.unit as e06,
        6 AS meq_reg_order_text,
        meq.meq_class_code_order AS meq_class_code_order,
        meq.meq_code_order AS meq_code_order
    from
      ord_main_max ord
      left outer join
      mst_equip as meq
      on
      meq.equipment_cd = TO_NUMBER (ord.rst_cond_info->''11''->>''value'',''999999999999'')
    where
      ord.ord_no = @ordNo

    union

    select --血液回路情報
      ''血液回路'' as detail_id,
      meq.in_hospital_cd_1 as e01,
      meq.equipment_name as e02,
      meq.class_name as e03,
      ''0''as e04,
      ''1'' as e05,
      meq.unit as e06,
        7 AS meq_reg_order_text,
        meq.meq_class_code_order AS meq_class_code_order,
        meq.meq_code_order AS meq_code_order
    from
      ord_main_max ord
      left outer join
      mst_equip as meq
      on
      meq.equipment_cd = TO_NUMBER (ord.rst_cond_info->''13''->>''value'',''999999999999'')
    where
      ord.ord_no = @ordNo
    union

    select --医材情報
      ''医材'' as detail_id,
      meq.in_hospital_cd_1 as e01,
      meq.equipment_name as e02,
      meq.class_name as e03,
      ''0'' as e04,
      t.equip ->> ''amount'' as e05,
      t.equip ->> ''unit'' as e06,
        100 + t.idx AS meq_reg_order_text,
        meq.meq_class_code_order AS meq_class_code_order,
        meq.meq_code_order AS meq_code_order
    from
      ord_main_max ord
      cross join lateral
          json_array_elements (ord.rst_equip_info :: json) WITH ORDINALITY AS t(equip, idx)
      left outer join
        mst_equip as meq
      on
        meq.equipment_cd = TO_NUMBER (t.equip ->> ''cd'',''999999999999'')
    where
      ord.ord_no = @ordNo
  ) all_cost

  where
    all_cost.e01 is not null
) cost_fin
ORDER BY
  CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 0 THEN cost_fin.meq_reg_order
      WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 1 THEN cost_fin.meq_class_code_order
      WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 2 THEN cost_fin.meq_code_order END,
  CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 0 THEN cost_fin.meq_reg_order
      WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 1 THEN cost_fin.meq_class_code_order
      WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 2 THEN cost_fin.meq_code_order END,
  CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 0 THEN cost_fin.meq_reg_order
      WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 1 THEN cost_fin.meq_class_code_order
      WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 2 THEN cost_fin.meq_code_order END, cost_fin.meq_code_order', 2, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'SSI)実績）医材繰り返し部', '2025-03-17 09:41:58.788', CURRENT_TIMESTAMP, NULL);
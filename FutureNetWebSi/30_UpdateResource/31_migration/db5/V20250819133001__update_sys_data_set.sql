DELETE FROM ntss.sys_data_set
WHERE sql_cd=-1201005;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1201005, '--設定関連
with equip_idx as (
    -- 医療材料の出力処方情報数
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as idx
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''SX_DIAL_INFO''
        and info->>''key2'' = ''EQUIPMENT_INHOSP''
),
dialyzer_idx as (
    -- ダイアライザの出力処方情報数
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as idx
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''SX_DIAL_INFO''
        and info->>''key2'' = ''DIALYZER_INHOSP''
),

--施設設定
do_order_data_from AS (
SELECT ROW_NUMBER () OVER () AS no2, TO_NUMBER(datt.a1  :: text, ''999999999999'') AS ora
FROM (SELECT TO_NUMBER((unnest(string_to_array((
SELECT mst_f.value AS rtt
  FROM mst_facility_setting AS mst_f 
  WHERE mst_f.facility_setting_no = ''3006'' AND mst_f.facility_cd = @facilityCd),'',''))), ''999999999999'') AS a1) AS datt
),

--医療材料マスタ
do_mstmeq_cd AS (
SELECT index_no AS meq_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS meq_code, order_cd ->> ''name'' AS meq_code_name
FROM mst_selector
    CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd 
   AND master_physical_name = ''mst_equipment'' 
),

--医療材料分類マスタ
do_mstmeq_class_cd AS (
SELECT index_no AS meq_class_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS meq_class_code,order_cd ->> ''name'' AS meq_class_code_name
FROM mst_selector
    CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd 
   AND master_physical_name = ''mst_equipment_class'' 
),
--医療材料マスタソート
mstmeq_sort AS (
  SELECT 
    meq.equipment_cd AS equipment_cd
    , CASE WHEN 1 in (SELECT ora FROM do_order_data_from) THEN TO_NUMBER(do_mstmeq_class_cd.meq_class_code_order :: text, ''999999999999'') ELSE NULL END AS cl_cd_f
    , CASE WHEN 2 in (SELECT ora FROM do_order_data_from) THEN TO_NUMBER(do_mstmeq_cd.meq_code_order :: text, ''999999999999'') ELSE NULL END AS eq_cd_f
  FROM
    do_mstmeq_cd
    LEFT JOIN mst_equipment AS meq ON do_mstmeq_cd.meq_code = meq.equipment_cd
    LEFT JOIN do_mstmeq_class_cd ON do_mstmeq_class_cd.meq_class_code = meq.class_cd
),

target_order AS (
  (
    SELECT
      ord_i.del_date as up_date_switch,
      ord_i.ord_no AS ord_no,
      ord_i.rst_equip_info AS rst_equip_info,
      ord_i.rst_cond_info AS rst_cond_info
    FROM ord_main_restore as ord_i
    JOIN sys_coop_journal AS journal ON ord_i.ord_no = journal.ord_no
    WHERE ord_i.ord_no = @ordNo
      AND journal.ctl_no = @ctlNo
      AND ord_i.ord_no = journal.ord_no
      AND journal.reg_date >= ord_i.del_date
    ORDER BY ord_i.del_date DESC LIMIT 1
  )
  UNION
  (
    SELECT
      ord_i.rst_edition_date as up_date_switch,
      ord_i.ord_no AS ord_no,
      ord_i.rst_equip_info AS rst_equip_info,
      ord_i.rst_cond_info AS rst_cond_info
    FROM ord_main AS ord_i
    WHERE ord_i.ord_no = @ordNo
  )
  ORDER BY
    up_date_switch DESC NULLS LAST
  LIMIT 1


),
--1次膜、2次膜、吸着カラム、穿刺針、血液回路の抽出
membrane_raw AS (
  SELECT
    key,
    (value ->> ''value'')::int AS equip_cd
  FROM target_order,
       jsonb_each(target_order.rst_cond_info) AS j(key, value)
  WHERE key IN (''6'',''7'',''8'',''9'',''10'',''11'',''13'') AND value ->> ''value'' IS NOT NULL
),

membrane_data AS (
select
    CASE key
      WHEN ''6'' THEN ''吸着カラム''
      WHEN ''7'' THEN ''1次膜''
      WHEN ''8'' THEN ''2次膜''
      WHEN ''9'' THEN ''穿刺針(A針)''
      WHEN ''10'' THEN ''穿刺針(V針)''
      WHEN ''11'' THEN ''穿刺針(SN)''
      WHEN ''13'' THEN ''血液回路''
    END AS category,
    equipment_name as name,
    CASE key
      WHEN ''6'' THEN 0.1
      WHEN ''7'' THEN 0.2
      WHEN ''8'' THEN 0.3
      WHEN ''9'' THEN 0.4
      WHEN ''10'' THEN 0.5
      WHEN ''11'' THEN 0.6
      WHEN ''13'' THEN 0.7
    END AS login_ord,
    msort.cl_cd_f AS cl_cd_f,
    msort.eq_cd_f AS eq_cd_f,
    CASE (SELECT idx FROM equip_idx)
      WHEN ''1'' THEN equipment.in_hospital_cd_1
      WHEN ''2'' THEN equipment.in_hospital_cd_2
      WHEN ''3'' THEN equipment.in_hospital_cd_3
      WHEN ''4'' THEN equipment.in_hospital_cd_4
      ELSE equipment.in_hospital_cd_1
    END AS code,
    1 AS quantity
  FROM membrane_raw m
  LEFT JOIN mst_equipment equipment ON m.equip_cd = equipment.equipment_cd
  LEFT JOIN mstmeq_sort msort ON msort.equipment_cd = m.equip_cd
),

--医療材料 + ダイアライザの抽出
equip_items AS (
  SELECT item, index_no
  FROM (
    SELECT *
    FROM target_order,
         jsonb_array_elements(rst_equip_info) with ordinality as elem(item, index_no)
  ) AS t
),
equip_parsed AS (
  SELECT
    (item ->> ''equip_type'')::int AS equip_type,
    (item ->> ''cd'')::int AS cd,
    (item ->> ''amount'')::numeric AS amount,
    (item ->> ''name'') AS name,
    index_no AS login_ord
    FROM equip_items
),
medical_data AS (
  SELECT
    ''医療材料'' AS category,
    e.name as name,
    e.login_ord AS login_ord,
    msort.cl_cd_f AS cl_cd_f,
    msort.eq_cd_f AS eq_cd_f,
    CASE
      WHEN e.equip_type = 0 THEN
        CASE (SELECT idx FROM equip_idx)
          WHEN ''1'' THEN eq.in_hospital_cd_1
          WHEN ''2'' THEN eq.in_hospital_cd_2
          WHEN ''3'' THEN eq.in_hospital_cd_3
          WHEN ''4'' THEN eq.in_hospital_cd_4
          ELSE eq.in_hospital_cd_1
          END
      WHEN e.equip_type = 1 THEN
        CASE (SELECT idx FROM dialyzer_idx)
          WHEN ''1'' THEN d.in_hospital_cd_1
          WHEN ''2'' THEN d.in_hospital_cd_2
          WHEN ''3'' THEN d.in_hospital_cd_3
          WHEN ''4'' THEN d.in_hospital_cd_4
          ELSE d.in_hospital_cd_1
        END
    END AS code,
    e.amount AS quantity
  FROM equip_parsed e
  LEFT JOIN mst_equipment eq ON e.cd = eq.equipment_cd
  LEFT JOIN mst_dialyzer d ON e.cd = d.dialyzer_cd
  LEFT JOIN mstmeq_sort msort ON msort.equipment_cd = e.cd
),
-- 同コードで合算
do_data AS (
  select code, SUM(quantity)AS  quantity , 
  MIN(login_ord) AS login_ord , MIN(cl_cd_f) AS cl_cd , MIN(eq_cd_f) AS eq_cd
  from
  (SELECT * FROM membrane_data WHERE code IS NOT NULL
  UNION ALL
  SELECT *  FROM medical_data  WHERE code IS NOT NULL
  ) as alldata
  GROUP BY alldata.code 
)
, numbered_data AS (
  SELECT
    ROW_NUMBER() OVER (
      ORDER BY 
        CASE WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 1) = 0 THEN login_ord
             WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 1) = 1 THEN cl_cd
             WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 1) = 2 THEN eq_cd END,
        CASE WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 2) = 0 THEN login_ord
             WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 2) = 1 THEN cl_cd
             WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 2) = 2 THEN eq_cd END,
        CASE WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 3) = 0 THEN login_ord
             WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 3) = 1 THEN cl_cd
             WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 3) = 2 THEN eq_cd END
    ) AS rn,
    code,
    quantity 
  FROM do_data
  where coalesce(code, '''') != '''' 
  LIMIT 12
)
SELECT
  COALESCE(MAX(CASE WHEN rn = 1 THEN code END), '''') AS code1,
  COALESCE(MAX(CASE WHEN rn = 1 THEN RIGHT(quantity::text, 6) END), '''') AS quantity1,
  COALESCE(MAX(CASE WHEN rn = 2 THEN code END), '''') AS code2,
  COALESCE(MAX(CASE WHEN rn = 2 THEN RIGHT(quantity::text, 6) END), '''') AS quantity2,
  COALESCE(MAX(CASE WHEN rn = 3 THEN code END), '''') AS code3,
  COALESCE(MAX(CASE WHEN rn = 3 THEN RIGHT(quantity::text, 6) END), '''') AS quantity3,
  COALESCE(MAX(CASE WHEN rn = 4 THEN code END), '''') AS code4,
  COALESCE(MAX(CASE WHEN rn = 4 THEN RIGHT(quantity::text, 6) END), '''') AS quantity4,
  COALESCE(MAX(CASE WHEN rn = 5 THEN code END), '''') AS code5,
  COALESCE(MAX(CASE WHEN rn = 5 THEN RIGHT(quantity::text, 6) END), '''') AS quantity5,
  COALESCE(MAX(CASE WHEN rn = 6 THEN code END), '''') AS code6,
  COALESCE(MAX(CASE WHEN rn = 6 THEN RIGHT(quantity::text, 6) END), '''') AS quantity6,
  COALESCE(MAX(CASE WHEN rn = 7 THEN code END), '''') AS code7,
  COALESCE(MAX(CASE WHEN rn = 7 THEN RIGHT(quantity::text, 6) END), '''') AS quantity7,
  COALESCE(MAX(CASE WHEN rn = 8 THEN code END), '''') AS code8,
  COALESCE(MAX(CASE WHEN rn = 8 THEN RIGHT(quantity::text, 6) END), '''') AS quantity8,
  COALESCE(MAX(CASE WHEN rn = 9 THEN code END), '''') AS code9,
  COALESCE(MAX(CASE WHEN rn = 9 THEN RIGHT(quantity::text, 6) END), '''') AS quantity9,
  COALESCE(MAX(CASE WHEN rn = 10 THEN code END), '''') AS code10,
  COALESCE(MAX(CASE WHEN rn = 10 THEN RIGHT(quantity::text, 6) END), '''') AS quantity10,
  COALESCE(MAX(CASE WHEN rn = 11 THEN code END), '''') AS code11,
  COALESCE(MAX(CASE WHEN rn = 11 THEN RIGHT(quantity::text, 6) END), '''') AS quantity11,
  COALESCE(MAX(CASE WHEN rn = 12 THEN code END), '''') AS code12,
  COALESCE(MAX(CASE WHEN rn = 12 THEN RIGHT(quantity::text, 6) END), '''') AS quantity12
FROM numbered_data;
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '医材出力(MAX12)', '2025-05-23 17:36:09.485', CURRENT_TIMESTAMP, NULL);

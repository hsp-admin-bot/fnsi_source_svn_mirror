
DELETE FROM sys_data_set WHERE sql_cd IN 
(-1201003,-1201005,-1201006);


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
--1次膜、2次膜、吸着カラムの抽出
membrane_raw AS (
  SELECT
    key,
    (value ->> ''value'')::int AS equip_cd
  FROM target_order,
       jsonb_each(target_order.rst_cond_info) AS j(key, value)
  WHERE key IN (''6'',''7'',''8'') AND value ->> ''value'' IS NOT NULL
),

membrane_data AS (
select
    CASE key
      WHEN ''6'' THEN ''吸着カラム''
      WHEN ''7'' THEN ''1次膜''
      WHEN ''8'' THEN ''2次膜''
    END AS category,
    equipment_name as name,
    0 AS login_ord,
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


INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1201003, '--設定関連
with medicine_mode as (
    -- セット薬剤出力切り替え
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as flg
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''RST_SET_MEDICINE_RESOLVE''
        and info->>''key2'' = ''KOU_COAG_RESOLVE_MODE''
),
medicine_idx as (
    -- 薬剤マスタの使用院内コード番号 
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as idx
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''SX_DIAL_INFO''
        and info->>''key2'' = ''MEDICINE_INHOSP''
),
mix_medicine_idx as (
    -- 調合薬剤マスタの使用院内コード番号 
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as idx
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''SX_DIAL_INFO''
        and info->>''key2'' = ''MEDICINE_MIX_INHOSP''
),
do_ord_main AS (
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
cond_info AS (
  SELECT 
    TO_NUMBER( rst_cond_info -> ''25'' ->> ''value'', ''FM999999999999'' ) AS medicine_cd,
    (rst_cond_info -> ''25'') ->> ''medicine_type'' AS medicine_type,
CASE
    -- 数量 どちらかが入力されいない場合、一方を出力
   WHEN NULLIF(rst_cond_info -> ''26'' ->> ''value'', '''') IS NULL
   AND NULLIF(rst_cond_info -> ''28'' ->> ''value'', '''') IS NULL THEN NULL
  ELSE
    TRUNC(
      COALESCE(NULLIF(rst_cond_info -> ''26'' ->> ''value'', '''')::numeric, 0) +
      COALESCE(NULLIF(rst_cond_info -> ''28'' ->> ''value'', '''')::numeric, 0),
    2) * 100
    END AS total_value
  FROM do_ord_main
)

SELECT * FROM
  (select
  -- コード
    COALESCE(CASE 
      WHEN ci.medicine_type = ''1'' THEN
        CASE (SELECT idx FROM medicine_idx)
          WHEN ''1'' THEN m.in_hospital_cd_1
          WHEN ''2'' THEN m.in_hospital_cd_2
          WHEN ''3'' THEN m.in_hospital_cd_3
          WHEN ''4'' THEN m.in_hospital_cd_4
          ELSE m.in_hospital_cd_1
        END
      WHEN ci.medicine_type = ''2'' THEN
        CASE (SELECT idx FROM mix_medicine_idx)
          WHEN ''1'' THEN mm.in_hospital_cd_1
          WHEN ''2'' THEN mm.in_hospital_cd_2
          WHEN ''3'' THEN mm.in_hospital_cd_3
          ELSE mm.in_hospital_cd_1
        END
    END, '''') AS code,

    -- 総量（value + factor 8桁まで）
    CASE 
      WHEN ci.medicine_cd IS NOT NULL 
      THEN RIGHT(TO_CHAR(FLOOR(ci.total_value), ''FM999999999999''), 8)
      ELSE ''''
    END AS quantity,
    
    -- 単位
    COALESCE(CASE 
      WHEN ci.medicine_type = ''1'' THEN m.unit_second
      WHEN ci.medicine_type = ''2'' THEN mm.unit
    END, '''') AS unit
  
  FROM cond_info ci
  LEFT JOIN mst_medicine m ON ci.medicine_cd = m.medicine_cd
  LEFT JOIN mst_medicine_mix mm ON ci.medicine_cd = mm.medicine_mix_cd
  
  where ci.medicine_type = ''1'' or (ci.medicine_type = ''2'' AND (SELECT flg FROM medicine_mode)  IN (''0'',''1''))
 ) as all_data
 where code != ''''
 
  

', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'SX_抗凝固剤', '2025-05-23 17:36:09.485', CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1201006, 'WITH medi_order_data AS (
  SELECT
    ROW_NUMBER () OVER () AS no2
    , datt.a1
  FROM (
    SELECT
      TO_NUMBER((unnest(string_to_array((
        SELECT mst_f.value AS rtt
        FROM mst_facility_setting AS mst_f
        WHERE mst_f.facility_setting_no = ''3007'' AND mst_f.facility_cd = @facilityCd
      ),'',''))), ''999999999999''
    ) AS a1
  ) AS datt
)
, do_ord_main AS (
  (
    SELECT
      ord_i.del_date as up_date_switch,
      ord_i.rst_cond_info AS rst_cond_info,
      ord_i.rst_medi_info AS rst_medi_info,
      ord_i.rst_treatment_info AS rst_treatment_info
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
      ord_i.rst_cond_info AS rst_cond_info,
      ord_i.rst_medi_info AS rst_medi_info,
      ord_i.rst_treatment_info AS rst_treatment_info
    FROM ord_main AS ord_i
    WHERE ord_i.ord_no = @ordNo
  )
  ORDER BY
    up_date_switch DESC NULLS LAST
  LIMIT 1
)
, coop_ini_info AS (
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
, kou_coag_resolve_mode AS ( --抗凝固剤分解パターン
    SELECT *
    FROM coop_ini_info
    WHERE key1 = ''RST_SET_MEDICINE_RESOLVE''
      AND key2 = ''KOU_COAG_RESOLVE_MODE''
)
, medicine_inhosp AS ( --薬剤マスタの使用院内コード番号
    SELECT *
    FROM coop_ini_info
    WHERE key1 = ''SX_DIAL_INFO''
      AND key2 = ''MEDICINE_INHOSP''
)
, medi_order AS (
  SELECT
    index_no ::int AS medi_code_order
    , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_code
  FROM mst_selector
  CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
  WHERE facility_cd = @facilityCd
    AND master_physical_name = ''mst_medicine''
)
, medi_class_order AS (
  SELECT
    index_no ::int AS medi_class_code_order
    , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_class_code
  FROM mst_selector
  CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
  WHERE facility_cd = @facilityCd
    AND master_physical_name = ''mst_medicine_class''
)
, timing_order AS (
  SELECT
    index_no ::int AS timing_code_order
    , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS timing_code
  FROM mst_selector
  CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
  WHERE facility_cd = @facilityCd
    AND master_physical_name = ''mst_medicate_timing''
)
, procedure_order AS (
  SELECT
    index_no ::int AS procedure_code_order
    , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS procedure_code
  FROM mst_selector
  CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
  WHERE facility_cd = @facilityCd
    AND master_physical_name = ''mst_procedure''
)
, mst_medi AS (
  SELECT
    medicine_cd
    , medicine_name
    , class_cd
    , unit
    , in_hospital_cd_1
    , in_hospital_cd_2
    , in_hospital_cd_3
    , in_hospital_cd_4
    , medi_order.medi_code_order
    , medi_class_order.medi_class_code_order
  FROM mst_medicine mmd
  LEFT JOIN medi_order ON mmd.medicine_cd = medi_order.medi_code
  LEFT JOIN medi_class_order ON mmd.class_cd = medi_class_order.medi_class_code
  WHERE facility_cd = @facilityCd
)
,select_rst_medi AS ( --薬剤
  SELECT
    ''実績詳細'' AS detail_id
    , kinds
    , CASE (SELECT value FROM medicine_inhosp)
      WHEN ''1'' THEN mmd.in_hospital_cd_1
      WHEN ''2'' THEN mmd.in_hospital_cd_2
      WHEN ''3'' THEN mmd.in_hospital_cd_3
      WHEN ''4'' THEN mmd.in_hospital_cd_4
      END AS e01 --項目コード
    , rst_medi.amount
    , mmd.unit AS e05
    , ROW_NUMBER() OVER(
      ORDER BY
      CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''0'' THEN temp_no
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''1'' THEN medi_class_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''2'' THEN medicine_type
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''3'' THEN medi_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''4'' THEN timing_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''5'' THEN procedure_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''6'' THEN interval_no END,
      CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''0'' THEN temp_no
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''1'' THEN medi_class_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''2'' THEN medicine_type
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''3'' THEN medi_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''4'' THEN timing_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''5'' THEN procedure_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''6'' THEN interval_no END,
      CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''0'' THEN temp_no
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''1'' THEN medi_class_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''2'' THEN medicine_type
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''3'' THEN medi_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''4'' THEN timing_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''5'' THEN procedure_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''6'' THEN interval_no END,
      CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''0'' THEN temp_no
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''1'' THEN medi_class_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''2'' THEN medicine_type
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''3'' THEN medi_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''4'' THEN timing_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''5'' THEN procedure_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''6'' THEN interval_no END,
      CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''0'' THEN temp_no
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''1'' THEN medi_class_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''2'' THEN medicine_type
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''3'' THEN medi_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''4'' THEN timing_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''5'' THEN procedure_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''6'' THEN interval_no END,
      CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''0'' THEN temp_no
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''1'' THEN medi_class_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''2'' THEN medicine_type
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''3'' THEN medi_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''4'' THEN timing_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''5'' THEN procedure_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''6'' THEN interval_no END,
      CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''0'' THEN temp_no
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''1'' THEN medi_class_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''2'' THEN medicine_type
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''3'' THEN medi_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''4'' THEN timing_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''5'' THEN procedure_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''6'' THEN interval_no END, medi_code_order
      ) AS e09
  FROM (
    SELECT
      --補液
      1000 AS temp_no --登録順
      , 1 AS medicine_type --通常→調整
      , NULL ::integer AS timing_cd --タイミング
      , NULL ::integer AS procedure_cd --手技
      , 999 AS interval_no --投与間隔
      , ''治療条件補液'' AS kinds
      , info.value ->> ''value'' AS medi_cd --薬剤マスタキー
      , TO_NUMBER(COALESCE(ord.rst_cond_info -> ''22'' ->> ''value'', ''0''), ''FM999999999.999999999'') AS amount --使用量
    FROM do_ord_main ord
    CROSS JOIN lateral jsonb_each(ord.rst_cond_info) AS info
    WHERE
       info.key IN (''19'')
      AND ord.rst_cond_info -> ''19'' ->> ''medicine_type'' = ''1''
    UNION ALL
    SELECT
      --抗凝固剤分解薬剤
      2000 AS temp_no --登録順
      , 2 AS medicine_type --通常→調整
      , NULL ::integer AS timing_cd --タイミング
      , NULL ::integer AS procedure_cd --手技
      , 999 AS interval_no --投与間隔
      , ''治療条件抗凝固剤'' AS kinds
      , t2.mmxd ->> ''cd'' AS medi_cd --薬剤マスタキー
      , TO_NUMBER (t2.mmxd ->> ''amount'', ''FM999999999.999999999'') AS amount --使用量
    FROM do_ord_main ord
    CROSS JOIN lateral jsonb_each(ord.rst_cond_info) AS info
    LEFT OUTER JOIN mst_medicine_mix AS mmx
      ON mmx.medicine_mix_cd = TO_NUMBER(ord.rst_cond_info -> ''25'' ->> ''value'', ''FM999999999999'')
    CROSS JOIN LATERAL json_array_elements(mmx.mix_info ::json) WITH ORDINALITY AS t2(mmxd, idx)
    WHERE
      info.key IN (''25'')
      AND ord.rst_cond_info -> ''25'' ->> ''medicine_type'' = ''2''
      AND (SELECT value FROM kou_coag_resolve_mode) IN (''1'',''2'')
    UNION ALL
    SELECT
      --投与薬剤(通常)
      3000 + t.idx AS temp_no --登録順
      , 1 AS medicine_type --通常→調整
      , (t.medi ->> ''timing_cd'') ::int AS timing_cd --タイミング
      , (t.medi ->> ''procedure_cd'') ::int AS procedure_cd --手技
      , (t.medi ->> ''date_interval'') ::int AS interval_no --投与間隔
      , ''投与薬剤(通常)'' AS kinds
      , t.medi ->> ''cd'' AS medi_cd
      , TO_NUMBER(COALESCE(t.medi ->> ''amount'', ''0''), ''FM999999999.999999999'') AS amount
    FROM do_ord_main ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) WITH ORDINALITY AS t(medi, idx)
    WHERE
      t.medi ->> ''medicine_type'' = ''1''
      AND t.medi ->> ''effect_flg'' = ''1''
    UNION ALL
    SELECT
      --投与薬剤(調整)
      3000 + t.idx AS temp_no --登録順
      , 2 AS medicine_type --通常→調整
      , (t.medi ->> ''timing_cd'') ::int AS timing_cd --タイミング
      , (t.medi ->> ''procedure_cd'') ::int AS procedure_cd --手技
      , (t.medi ->> ''date_interval'') ::int AS interval_no --投与間隔
      , ''投与薬剤(調整)'' AS kinds
      , t2.mmxd ->> ''cd'' AS medi_cd
      , CASE t2.mmxd ->> ''solvent''
        WHEN ''0'' THEN TO_NUMBER(COALESCE(t.medi ->> ''amount'', ''0''), ''FM999999999.999999999'')
          * TO_NUMBER(COALESCE(t2.mmxd ->> ''amount'', ''0''), ''FM999999999.999999999'')
        WHEN ''1'' THEN TO_NUMBER(COALESCE(t2.mmxd ->> ''amount'', ''0''), ''FM999999999.999999999'')
        END AS amount
    FROM do_ord_main ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) WITH ORDINALITY AS t(medi, idx)
    LEFT OUTER JOIN mst_medicine_mix AS mmx
      ON mmx.medicine_mix_cd = TO_NUMBER(t.medi ->> ''cd'', ''FM999999999999'')
    CROSS JOIN LATERAL json_array_elements(mmx.mix_info ::json) WITH ORDINALITY AS t2(mmxd, idx)
    WHERE
      t.medi ->> ''medicine_type'' = ''2''
      AND t.medi ->> ''effect_flg'' = ''1''
    UNION ALL
    SELECT
      --愁訴処置薬剤(通常)
      4000 + t.idx AS temp_no --登録順
      , 1 AS medicine_type --通常→調整
      , NULL ::integer AS timing_cd --タイミング
      , (t.tmedi ->> ''procedure_cd'') ::int AS procedure_cd --手技
      , NULL ::integer AS interval_no --投与間隔
      , ''愁訴処置薬剤(通常)'' AS kinds
      , t.tmedi ->> ''treat_medicine_cd'' AS medi_cd
      , TO_NUMBER(COALESCE(t.tmedi ->> ''amount'', ''0''), ''FM999999999.999999999'') AS amount
    FROM do_ord_main ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) WITH ORDINALITY AS t(tmedi, idx)
    WHERE
      t.tmedi ->> ''treat_class'' IN (''1'',''2'')
      AND t.tmedi ->> ''medicine_type'' = ''1''
    UNION ALL
    SELECT
      --愁訴処置薬剤(調整)
      4000 + t.idx AS temp_no --登録順
      , 2 AS medicine_type --通常→調整
      , NULL ::integer AS timing_cd --タイミング
      , (t.tmedi ->> ''procedure_cd'') ::int AS procedure_cd --手技
      , NULL ::integer AS interval_no --投与間隔
      , ''愁訴処置薬剤(調整)'' AS kinds
      , t2.mmxd ->> ''cd'' AS medi_cd
      , CASE t2.mmxd ->> ''solvent''
        WHEN ''0'' THEN TO_NUMBER(COALESCE(t.tmedi ->> ''amount'', ''0''), ''FM999999999.999999999'')
          * TO_NUMBER(COALESCE(t2.mmxd ->> ''amount'', ''0''), ''FM999999999.999999999'')
        WHEN ''1'' THEN TO_NUMBER(COALESCE(t2.mmxd ->> ''amount'', ''0''), ''FM999999999.999999999'')
        END AS amount
    FROM do_ord_main ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) WITH ORDINALITY AS t(tmedi, idx)
    LEFT OUTER JOIN mst_medicine_mix AS mmx
      ON mmx.medicine_mix_cd = TO_NUMBER(t.tmedi ->> ''treat_medicine_cd'', ''FM999999999999'')
    CROSS JOIN LATERAL json_array_elements(mmx.mix_info ::json) WITH ORDINALITY AS t2(mmxd, idx)
    WHERE
      t.tmedi ->> ''treat_class'' IN (''0'',''2'')
      AND t.tmedi ->> ''medicine_type'' = ''2''
  ) AS rst_medi
  LEFT JOIN mst_medi mmd ON rst_medi.medi_cd = mmd.medicine_cd::text
  LEFT JOIN timing_order ON rst_medi.timing_cd = timing_order.timing_code
  LEFT JOIN procedure_order ON rst_medi.procedure_cd = procedure_order.procedure_code
),
sum_count as (
  select
    MIN (ttm.e09) as no
    , ttm.e01 as hosp_cd
    , SUM(ttm.amount) AS amount
    , (select count(tt.e01)
        from select_rst_medi tt
        where tt.e01 = ttm.e01) as count
    from select_rst_medi ttm
    group by ttm.e01
)
select
    ''薬剤'' AS detail_id
    ,sm.no
    ,sm.hosp_cd as hosp_cd
    ,lpad(RIGHT(TO_CHAR(sm.amount, ''FM99999999999V99''), 8), 8, '' '') as amount
    ,tt.e05 as unit
    ,lpad(RIGHT(TO_CHAR(sm.count, ''FM9999''), 2), 2,'' '') as count
from sum_count as sm
left join select_rst_medi tt on tt.e09 = sm.no
WHERE COALESCE(hosp_cd, '''') <> ''''
order by no asc
limit 135
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'SX_透析液', '2025-05-23 17:36:09.485', CURRENT_TIMESTAMP, NULL);

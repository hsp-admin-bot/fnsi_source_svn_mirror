DELETE FROM sys_data_set WHERE sql_cd IN 
(-1201000,-1201001,-1201002,-1201003,-1201005);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1201000, 'select 
  TO_CHAR(TO_TIMESTAMP(medical_care_info ->> ''dialysis_start_date'' || ''000000'', ''YYYYMMDDHH24MISS''),''YYYYMMDD'') AS dialysis_start, --透析導入日　YYYYMMDD
  TO_CHAR(TO_TIMESTAMP(medical_care_info ->> ''hospital_start_date'' || ''000000'', ''YYYYMMDDHH24MISS''),''YYYYMMDD'') AS hospital_start --当院開始日　YYYYMMDD
from pat_main
where
	is_del = ''0''
	AND pat_id = @patId', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '患者診療情報', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);


INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1201001, '--設定関連
with in_out_0 as (
    -- 入外区分0(外来)
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as kbn
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''CONV_INOUT_TO_KARTE''
        and info->>''key2'' = ''0''
),
in_out_1 as (
    -- 入外区分1(入院)
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as kbn
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''CONV_INOUT_TO_KARTE''
        and info->>''key2'' = ''1''
),
treat_idx as (
    -- 治療項目マスタの使用院内コード番号
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as idx
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''SX_DIAL_INFO''
        and info->>''key2'' = ''TREAT_INHOSP''
)

select
  COALESCE(CASE ord.rst_in_out_class    WHEN ''0'' THEN (SELECT kbn FROM in_out_0) WHEN ''1'' THEN (SELECT kbn FROM in_out_1) ELSE NULL  END , '''') AS in_out, --入外区分
  COALESCE(ord.rst_bed_name , '''') as bed_name, --ベッド名称 
  COALESCE(
    CASE
      WHEN mtr.in_hosp_a_startdate <= NOW()
           AND (
             mtr.in_hosp_b_startdate IS NULL
             OR (
               mtr.in_hosp_b_startdate <= NOW()
               AND mtr.in_hosp_a_startdate >= mtr.in_hosp_b_startdate::timestamp
             )
           ) THEN
        CASE (SELECT idx FROM treat_idx)
          WHEN ''1'' THEN mtr.in_hospital_cd_a1
          WHEN ''2'' THEN mtr.in_hospital_cd_a2
          WHEN ''3'' THEN mtr.in_hospital_cd_a3
          WHEN ''4'' THEN mtr.in_hospital_cd_a4
          else mtr.in_hospital_cd_b1
          END
      WHEN mtr.in_hosp_b_startdate <= NOW() THEN
        CASE (SELECT idx FROM treat_idx)
          WHEN ''1'' THEN mtr.in_hospital_cd_b1
          WHEN ''2'' THEN mtr.in_hospital_cd_b2
          WHEN ''3'' THEN mtr.in_hospital_cd_b3
          WHEN ''4'' THEN mtr.in_hospital_cd_b4
          else mtr.in_hospital_cd_b1
        END
      ELSE NULL
    END,
    ''-''
  ) AS treat_hospital_cd, --治療法
  COALESCE(mtr.treatment_name , '''') as treatment_name --治療法名称

from ord_main as ord
  left join mst_treatment mtr ON ord.rst_treatment_cd = mtr.treatment_cd
where
  ord_no =  @ordNo
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '患者診療情報', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);


INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1201002, '--設定関連
with dialyzer_idx as (
    -- ダイアライザマスタの使用院内コード番号 
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as idx
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''SX_DIAL_INFO''
        and info->>''key2'' = ''DIALYZER_INHOSP''
)

select
  COALESCE(mdr.model_number, '''') AS dialyzer, -- ダイアライザ名
  COALESCE(
     CASE (SELECT idx FROM dialyzer_idx)
          WHEN ''1'' THEN mdr.in_hospital_cd_1
          WHEN ''2'' THEN mdr.in_hospital_cd_2
          WHEN ''3'' THEN mdr.in_hospital_cd_3
          WHEN ''4'' THEN mdr.in_hospital_cd_4
          ELSE mdr.in_hospital_cd_1
      END, '''') AS dialyzer_cd -- ダイアライザコード

from ord_main as ord
  LEFT JOIN mst_dialyzer AS mdr ON mdr.dialyzer_cd = TO_NUMBER( ord.rst_cond_info -> ''5'' ->> ''value'', ''FM999999999999'' )
where
  ord_no =  @ordNo
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'SX_ダイアライザ', CURRENT_TIMESTAMP,CURRENT_TIMESTAMP, NULL);

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
        and info->>''key2'' = ''MEDICINE_INHOS''
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
cond_info AS (
  SELECT 
    TO_NUMBER( rst_cond_info -> ''25'' ->> ''value'', ''FM999999999999'' ) AS medicine_cd,
    (rst_cond_info -> ''25'') ->> ''medicine_type'' AS medicine_type,
    -- 数量 どちらかが入力されいない場合、一方を出力
    CASE
      WHEN NULLIF(rst_cond_info -> ''26'' ->> ''value'', '''') IS NULL
      AND NULLIF(rst_cond_info -> ''28'' ->> ''value'', '''') IS NULL THEN NULL
    ELSE
      COALESCE(TO_NUMBER(NULLIF(rst_cond_info -> ''26'' ->> ''value'', ''''), ''FM999999999999''), 0) +
      COALESCE(TO_NUMBER(NULLIF(rst_cond_info -> ''28'' ->> ''value'', ''''), ''FM999999999999''), 0)
    END AS total_value
  FROM ord_main
  WHERE ord_no = @ordNo
)

  select
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
      WHEN ci.medicine_type = ''2'' AND (SELECT flg FROM medicine_mode) != ''3'' THEN
        CASE (SELECT idx FROM mix_medicine_idx)
          WHEN ''1'' THEN mm.in_hospital_cd_1
          WHEN ''2'' THEN mm.in_hospital_cd_2
          WHEN ''3'' THEN mm.in_hospital_cd_3
          ELSE mm.in_hospital_cd_1
        END
    END, '''') AS code,

    -- 総量（value + factor × 100）
    CASE 
      WHEN ci.medicine_cd IS NOT NULL 
        AND ci.medicine_type IN (''1'', ''2'')
        AND NOT ((SELECT flg FROM medicine_mode) = ''3'' AND ci.medicine_type = ''2'')
      THEN (ci.total_value * 100)::text
      ELSE ''''
    END AS quantity,

    -- 単位
    COALESCE(CASE 
      WHEN ci.medicine_type = ''1'' THEN m.unit_second
      WHEN ci.medicine_type = ''2'' AND (SELECT flg FROM medicine_mode) != ''3'' THEN mm.unit
    END, '''') AS unit
  
  FROM cond_info ci
  LEFT JOIN mst_medicine m ON ci.medicine_cd = m.medicine_cd
  LEFT JOIN mst_medicine_mix mm ON ci.medicine_cd = mm.medicine_mix_cd

', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'SX_抗凝固剤', CURRENT_TIMESTAMP,CURRENT_TIMESTAMP, NULL);



INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1201005, '--設定関連
with equip_idx as (
    -- 投与薬剤の出力処方情報数
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
    -- 投与薬剤の出力処方情報数
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
  WHERE meq.in_hospital_cd_1 IS NOT NULL
),

target_order AS (
  SELECT * FROM ord_main WHERE ord_no = @ordNo
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
    WHERE ord_no = @ordNo
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
  LIMIT 12
)

SELECT
COALESCE(MAX(CASE WHEN rn = 1 THEN code END), '''') AS code1,
COALESCE(MAX(CASE WHEN rn = 1 THEN quantity::text END), '''') AS quantity1,
COALESCE(MAX(CASE WHEN rn = 2 THEN code END), '''') AS code2,
COALESCE(MAX(CASE WHEN rn = 2 THEN quantity::text END), '''') AS quantity2,
COALESCE(MAX(CASE WHEN rn = 3 THEN code END), '''') AS code3,
COALESCE(MAX(CASE WHEN rn = 3 THEN quantity::text END), '''') AS quantity3,
COALESCE(MAX(CASE WHEN rn = 4 THEN code END), '''') AS code4,
COALESCE(MAX(CASE WHEN rn = 4 THEN quantity::text END), '''') AS quantity4,
COALESCE(MAX(CASE WHEN rn = 5 THEN code END), '''') AS code5,
COALESCE(MAX(CASE WHEN rn = 5 THEN quantity::text END), '''') AS quantity5,
COALESCE(MAX(CASE WHEN rn = 6 THEN code END), '''') AS code6,
COALESCE(MAX(CASE WHEN rn = 6 THEN quantity::text END), '''') AS quantity6,
COALESCE(MAX(CASE WHEN rn = 7 THEN code END), '''') AS code7,
COALESCE(MAX(CASE WHEN rn = 7 THEN quantity::text END), '''') AS quantity7,
COALESCE(MAX(CASE WHEN rn = 8 THEN code END), '''') AS code8,
COALESCE(MAX(CASE WHEN rn = 8 THEN quantity::text END), '''') AS quantity8,
COALESCE(MAX(CASE WHEN rn = 9 THEN code END), '''') AS code9,
COALESCE(MAX(CASE WHEN rn = 9 THEN quantity::text END), '''') AS quantity9,
COALESCE(MAX(CASE WHEN rn = 10 THEN code END), '''') AS code10,
COALESCE(MAX(CASE WHEN rn = 10 THEN quantity::text END), '''') AS quantity10,
COALESCE(MAX(CASE WHEN rn = 11 THEN code END), '''') AS code11,
COALESCE(MAX(CASE WHEN rn = 11 THEN quantity::text END), '''') AS quantity11,
COALESCE(MAX(CASE WHEN rn = 12 THEN code END), '''') AS code12,
COALESCE(MAX(CASE WHEN rn = 12 THEN quantity::text END), '''') AS quantity12
FROM numbered_data

', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '医材出力(MAX12)', CURRENT_TIMESTAMP,CURRENT_TIMESTAMP, NULL);



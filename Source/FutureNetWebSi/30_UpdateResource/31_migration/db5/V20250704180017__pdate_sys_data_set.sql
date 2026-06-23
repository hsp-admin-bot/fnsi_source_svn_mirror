DELETE FROM sys_data_set WHERE sql_cd IN 
(
-1201000,-1201001,-1201003,-1201004,-1201005
,-1200002,-1200003,-1200001,-1201007,-1201008,-1201009);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1201000, 'select 
  medical_care_info ->> ''dialysis_start_date'' AS dialysis_start, --透析導入日　YYYYMMDD
  medical_care_info ->> ''hospital_start_date'' AS hospital_start --当院開始日　YYYYMMDD
,medical_care_info
  from pat_main
where
	is_del = ''0''
	AND pat_id = @patId', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '患者診療情報', '2025-05-23 17:36:09.485', CURRENT_TIMESTAMP, NULL);


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
),
do_ord_main AS (
  (
    SELECT
      ord_i.del_date as up_date_switch,
      ord_i.ord_no AS ord_no,
      ord_i.rst_in_out_class AS rst_in_out_class,
      ord_i.rst_bed_name AS rst_bed_name,
      ord_i.treat_date AS treat_date,
      ord_i.rst_treatment_cd AS rst_treatment_cd
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
      ord_i.rst_in_out_class AS rst_in_out_class,
      ord_i.rst_bed_name AS rst_bed_name,
      ord_i.treat_date AS treat_date,
      ord_i.rst_treatment_cd AS rst_treatment_cd
    FROM ord_main AS ord_i
    WHERE ord_i.ord_no = @ordNo
  )
  ORDER BY
    up_date_switch DESC NULLS LAST
  LIMIT 1
)

select
  COALESCE(CASE ord.rst_in_out_class    
    WHEN ''0'' THEN (SELECT kbn FROM in_out_0) 
    WHEN ''1'' THEN (SELECT kbn FROM in_out_1) 
    ELSE NULL  END , '''') AS in_out, --入外区分
  COALESCE(ord.rst_bed_name , '''') as bed_name, --ベッド名称 
  COALESCE(
      CASE (SELECT idx FROM treat_idx)
      WHEN ''1''
          THEN CASE
          WHEN CAST(ord.treat_date as DATE) >= mtr.in_hosp_a_startdate
          AND CAST(ord.treat_date as DATE) >= mtr.in_hosp_b_startdate
              THEN CASE
              WHEN mtr.in_hosp_a_startdate >= mtr.in_hosp_b_startdate
                  THEN mtr.in_hospital_cd_a1
              WHEN mtr.in_hosp_a_startdate < mtr.in_hosp_b_startdate
                  THEN mtr.in_hospital_cd_b1
              END
          WHEN CAST(ord.treat_date as DATE) >= mtr.in_hosp_a_startdate
          AND (CAST(ord.treat_date as DATE) < mtr.in_hosp_b_startdate
              OR mtr.in_hosp_b_startdate IS NULL)
              THEN mtr.in_hospital_cd_a1
          WHEN (CAST(ord.treat_date as DATE) < mtr.in_hosp_a_startdate
              OR mtr.in_hosp_a_startdate IS NULL)
          AND CAST(ord.treat_date as DATE) >= mtr.in_hosp_b_startdate
              THEN mtr.in_hospital_cd_b1
          ELSE NULL
          END
      WHEN ''2''
          THEN CASE
          WHEN CAST(ord.treat_date as DATE) >= mtr.in_hosp_a_startdate
          AND CAST(ord.treat_date as DATE) >= mtr.in_hosp_b_startdate
              THEN CASE
              WHEN mtr.in_hosp_a_startdate >= mtr.in_hosp_b_startdate
                  THEN mtr.in_hospital_cd_a2
              WHEN mtr.in_hosp_a_startdate < mtr.in_hosp_b_startdate
                  THEN mtr.in_hospital_cd_b2
              END
          WHEN CAST(ord.treat_date as DATE) >= mtr.in_hosp_a_startdate
          AND (CAST(ord.treat_date as DATE) < mtr.in_hosp_b_startdate
              OR mtr.in_hosp_b_startdate IS NULL)
              THEN mtr.in_hospital_cd_a2
          WHEN (CAST(ord.treat_date as DATE) < mtr.in_hosp_a_startdate
              OR mtr.in_hosp_a_startdate IS NULL)
          AND CAST(ord.treat_date as DATE) >= mtr.in_hosp_b_startdate
              THEN mtr.in_hospital_cd_b2
          ELSE NULL
          END
      WHEN ''3''
      THEN CASE
          WHEN CAST(ord.treat_date as DATE) >= mtr.in_hosp_a_startdate
          AND CAST(ord.treat_date as DATE) >= mtr.in_hosp_b_startdate
              THEN CASE
              WHEN mtr.in_hosp_a_startdate >= mtr.in_hosp_b_startdate
                  THEN mtr.in_hospital_cd_a3
              WHEN mtr.in_hosp_a_startdate < mtr.in_hosp_b_startdate
                  THEN mtr.in_hospital_cd_b3
              END
          WHEN CAST(ord.treat_date as DATE) >= mtr.in_hosp_a_startdate
          AND (CAST(ord.treat_date as DATE) < mtr.in_hosp_b_startdate
              OR mtr.in_hosp_b_startdate IS NULL)
              THEN mtr.in_hospital_cd_a3
          WHEN (CAST(ord.treat_date as DATE) < mtr.in_hosp_a_startdate
              OR mtr.in_hosp_a_startdate IS NULL)
          AND CAST(ord.treat_date as DATE) >= mtr.in_hosp_b_startdate
              THEN mtr.in_hospital_cd_b3
          ELSE NULL
          END
      WHEN ''4''
      THEN CASE
          WHEN CAST(ord.treat_date as DATE) >= mtr.in_hosp_a_startdate
          AND CAST(ord.treat_date as DATE) >= mtr.in_hosp_b_startdate
              THEN CASE
              WHEN mtr.in_hosp_a_startdate >= mtr.in_hosp_b_startdate
                  THEN mtr.in_hospital_cd_a4
              WHEN mtr.in_hosp_a_startdate < mtr.in_hosp_b_startdate
                  THEN mtr.in_hospital_cd_b4
              END
          WHEN CAST(ord.treat_date as DATE) >= mtr.in_hosp_a_startdate
          AND (CAST(ord.treat_date as DATE) < mtr.in_hosp_b_startdate
              OR mtr.in_hosp_b_startdate IS NULL)
              THEN mtr.in_hospital_cd_a4
          WHEN (CAST(ord.treat_date as DATE) < mtr.in_hosp_a_startdate
              OR mtr.in_hosp_a_startdate IS NULL)
          AND CAST(ord.treat_date as DATE) >= mtr.in_hosp_b_startdate
              THEN mtr.in_hospital_cd_b4
          ELSE NULL
          END
      END
  , ''-'')AS treat_hospital_cd, --治療法
  COALESCE(mtr.treatment_name , '''') as treatment_name --治療法名称

from do_ord_main as ord
  left join mst_treatment mtr ON ord.rst_treatment_cd = mtr.treatment_cd
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '患者診療情報', '2025-05-23 17:36:09.485', CURRENT_TIMESTAMP, NULL);



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
  
  where ci.medicine_type = ''1'' or (ci.medicine_type = ''2'' AND (SELECT flg FROM medicine_mode)  IN (''1'',''2''))
 ) as all_data
 where code != ''''
 
  

', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'SX_抗凝固剤', '2025-05-23 17:36:09.485', CURRENT_TIMESTAMP, NULL);



INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1201004, '--設定関連
with medicine_idx as (
    -- 透析液の使用院内コード番号 
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as idx
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''SX_DIAL_INFO''
        and info->>''key2'' = ''MEDICINE_INHOSP''
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
)

SELECT * FROM
  (select
  COALESCE(
     CASE (SELECT idx FROM medicine_idx)
          WHEN ''1'' THEN mdr.in_hospital_cd_1
          WHEN ''2'' THEN mdr.in_hospital_cd_2
          WHEN ''3'' THEN mdr.in_hospital_cd_3
          WHEN ''4'' THEN mdr.in_hospital_cd_4
          ELSE mdr.in_hospital_cd_1
      END, '''') AS medicine_cd, -- 透析液コード
      
  COALESCE(
      RIGHT(TO_CHAR(FLOOR(TRUNC(COALESCE(NULLIF(ord.rst_cond_info -> ''16'' ->> ''value'', '''')::numeric, 0),2) * 100), ''FM999999999999''), 6)
      ,'''') as quantity, -- 数量
            
  COALESCE(mdr.unit_second, '''') AS unit          -- 単位

from do_ord_main as ord
  LEFT JOIN mst_medicine mdr ON mdr.medicine_cd = TO_NUMBER( ord.rst_cond_info -> ''15'' ->> ''value'', ''FM999999999999'' )
 ) as all_data
 where medicine_cd != ''''
 
  
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'SX_薬剤', '2025-05-23 17:36:09.485', CURRENT_TIMESTAMP, NULL);



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

', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '医材出力(MAX12)', '2025-05-23 17:36:09.485', CURRENT_TIMESTAMP, NULL);




INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1201007, 'SELECT
CASE
		@aligh
		WHEN ''0'' THEN
	lpad(right(hosp_pat_id,COALESCE(@len, 12)), 12,''0'') else rpad(right(hosp_pat_id,COALESCE(@len, 12)), 12,''0'')
	END AS hosp_pat_id
FROM
	pat_personal_main
WHERE
	is_del = ''0''
	AND pat_id = @patId', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'SX_患者ID(透析実績)', '2025-05-30 17:21:59.877', CURRENT_TIMESTAMP, '[{"sql_cd": -1200009, "field_name": "len", "replace_var": "@len"}, {"sql_cd": -1200008, "field_name": "aligh", "replace_var": "@aligh"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1201008, 'SELECT COALESCE(
  (
SELECT COALESCE
	( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' )
FROM
	mst_coop_ini AS ini
	CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info
WHERE
	facility_cd =@facilityCd
	AND is_del = ''0''
	AND COALESCE(info->>''key0'','''') = @key0
	AND info ->> ''key1'' = ''DIALYSISSEND''
	AND info ->> ''key2'' = ''PAT_ALIGN''
    LIMIT 1
  ),
  ''0'' -- ← データが存在しない場合、0
) AS aligh;', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'SX_患者ID(透析実績)', '2025-05-30 17:21:59.877', CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1201009, 'SELECT COALESCE(
  (
SELECT COALESCE
	(info ->> ''value'', info ->> ''default_v'')::int
FROM
	mst_coop_ini AS ini
	CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info
WHERE
	facility_cd =@facilityCd
	AND is_del = ''0''
	AND COALESCE(info->>''key0'','''') = @key0
	AND info ->> ''key1'' = ''SX_PAT_INFO''
	AND info ->> ''key2'' = ''PAT_LENGTH''
    LIMIT 1
  ),
  ''12'' -- ← データが存在しない場合、12
) AS len;', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'SX_患者ID(透析実績)', '2025-05-30 17:21:59.877', CURRENT_TIMESTAMP, NULL);


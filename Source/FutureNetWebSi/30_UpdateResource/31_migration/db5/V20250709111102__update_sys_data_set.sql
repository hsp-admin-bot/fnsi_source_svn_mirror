delete from ntss.sys_data_set
where sql_cd in (-1100006,-1102002);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1102002, 'WITH RECURSIVE coop_ini_info AS (
--連携設定より取得
SELECT
  COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value,
  info ->> ''key1'' AS key1,
  info ->> ''key2'' AS key2
FROM
  mst_coop_ini AS ini
CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
WHERE
  facility_cd = @facilityCd
  AND is_del = ''0''
  AND COALESCE(info ->> ''key0'', '''') = @key0
  AND info ->> ''key1'' IN (
        ''SCM_COMMON'',
        ''SCM_IN_HOSPITAL_CD'',
        ''SCM_CONV_UNIT_EQUIP'',
        ''SCM_CONV_UNIT_MEDI''
    )
)
, ini_value AS (
--連携設定からvalue値取得
SELECT
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''TREAT_ITEM_UNIT'') AS treat_item_unit,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''DIALYZER_UNIT'') AS dialyzer_unit,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''MEDICINE_SEND_TYPE'') AS medicine_send_type,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_CONV_UNIT_EQUIP'' AND key2 = ''個'') AS unit_equip,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_CONV_UNIT_MEDI'' AND key2 = ''ml'') AS unit_medi,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_TREATMENT'') AS hosp_get_mst_treatment,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_EQUIPMENT'') AS hosp_get_mst_equipment,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_DIALYZER'') AS hosp_get_mst_dialyzer,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_MEDICINE'') AS hosp_get_mst_medicine,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_PROCEDURE'') AS hosp_get_mst_procedure,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_DIALYSIS_DIFFICULTY'') AS hosp_get_mst_dia_diff
)
, auth_info AS (
--患者個人情報取得(pre_sqlにて取得)
SELECT
  auth_info ->> ''dial_diff_cd'' AS dial_diff_cd,
  auth_info ->> ''is_dial_diff'' AS is_dial_diff
FROM
  json_array_elements(@patPersonalInfo::json) auth_info
)
, mst_medi_mix AS (
--調整薬剤マスタ
SELECT
  t1.idx AS idx,
  medicine_mix_cd AS mix_cd,
  t1.info ->> ''solvent'' AS solvent,
  t1.info ->> ''cd'' AS medi_cd,
  t1.info ->> ''amount'' AS amount,
  mst.unit AS unit,
  mst.is_shot AS is_shot,
  mst.in_hospital_cd_1 AS in_hospital_cd_1,
  mst.in_hospital_cd_2 AS in_hospital_cd_2,
  mst.in_hospital_cd_3 AS in_hospital_cd_3,
  mst.in_hospital_cd_4 AS in_hospital_cd_4
FROM
  mst_medicine_mix mix
CROSS JOIN LATERAL json_array_elements(mix.mix_info ::json) WITH ORDINALITY AS t1(info, idx)
INNER JOIN mst_medicine AS mst ON
  mst.medicine_cd::text = info ->> ''cd''
  AND mst.is_shot = ''0''
WHERE
  mix.is_del = ''0''
  AND mix.facility_cd = @facilityCd
)
, medi_order_data AS (
-- 施設設定マスタから投与薬剤表示順を取得
SELECT
  ROW_NUMBER () OVER () AS no2,
  TO_NUMBER((UNNEST(string_to_array((COALESCE(mst.value, sys.default_value)), '',''))), ''999999999999'') AS a1
FROM
  sys_facility_setting AS sys
LEFT JOIN mst_facility_setting AS mst ON
  mst.facility_setting_no = ''3007''
  AND mst.facility_cd = @facilityCd
WHERE
  sys.facility_setting_no = ''3007''
)
, medi_order AS (
-- 薬剤マスタ表示順
SELECT
  index_no ::int AS medi_code_order
    ,
  TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_code
FROM
  mst_selector
CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ORDINALITY AS tmp(order_cd, index_no)
WHERE
  facility_cd = @facilityCd
  AND master_physical_name = ''mst_medicine''
)
, medi_class_order AS (
-- 薬剤分類マスタ表示順
SELECT
  index_no ::int AS medi_class_code_order
    ,
  TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_class_code
FROM
  mst_selector
CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ORDINALITY AS tmp(order_cd, index_no)
WHERE
  facility_cd = @facilityCd
  AND master_physical_name = ''mst_medicine_class''
)
, timing_order AS (
-- 投与タイミングマスタ表示順
SELECT
  index_no ::int AS timing_code_order
    ,
  TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS timing_code
FROM
  mst_selector
CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ORDINALITY AS tmp(order_cd, index_no)
WHERE
  facility_cd = @facilityCd
  AND master_physical_name = ''mst_medicate_timing''
)
, procedure_order AS (
-- 手技マスタ表示順
SELECT
  index_no ::int AS procedure_code_order
    ,
  TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS procedure_code
FROM
  mst_selector
CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ORDINALITY AS tmp(order_cd, index_no)
WHERE
  facility_cd = @facilityCd
  AND master_physical_name = ''mst_procedure''
)
, mst_medi AS (
-- 薬剤マスタから薬剤コード、薬剤分類コード表示順をまとめ
SELECT
  medicine_cd,
  medi_order.medi_code_order,
  medi_class_order.medi_class_code_order
FROM
  mst_medicine mmd
LEFT JOIN medi_order ON
  mmd.medicine_cd = medi_order.medi_code
LEFT JOIN medi_class_order ON
  mmd.class_cd = medi_class_order.medi_class_code
WHERE
  facility_cd = @facilityCd
)
, equip_order_data AS (
-- 施設設定マスタから、医療材料表示順を取得
SELECT
  ROW_NUMBER () OVER () AS no2,
  TO_NUMBER((UNNEST(string_to_array((COALESCE(mst.value, sys.default_value)), '',''))), ''999999999999'') AS ora
FROM
  sys_facility_setting AS sys
LEFT JOIN mst_facility_setting AS mst ON
  mst.facility_setting_no = ''3006''
  AND mst.facility_cd = @facilityCd
WHERE
  sys.facility_setting_no = ''3006''
)
, equip_order AS (
-- 医療材料マスタ表示順
SELECT
  index_no ::int AS meq_code_order
                ,
  TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS meq_code
FROM
  mst_selector
CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ORDINALITY AS tmp(order_cd, index_no)
WHERE
  facility_cd = @facilityCd
  AND master_physical_name = ''mst_equipment''
)
, equip_class_order AS (
-- 医療材料分類マスタ表示順
SELECT
  index_no ::int AS meq_class_code_order
                ,
  TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS meq_class_code
FROM
  mst_selector
CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ORDINALITY AS tmp(order_cd, index_no)
WHERE
  facility_cd = @facilityCd
  AND master_physical_name = ''mst_equipment_class''
)
, mst_equip AS (
-- 医療材料マスタと表示順
SELECT
  equipment_cd,
  equipment_name,
  class_cd,
  unit,
  in_hospital_cd_1,
  equip_order.meq_code_order,
  equip_class_order.meq_class_code_order
FROM
  mst_equipment meq
LEFT JOIN equip_order ON meq.equipment_cd = equip_order.meq_code
LEFT JOIN equip_class_order ON meq.class_cd = equip_class_order.meq_class_code
WHERE
  facility_cd = @facilityCd
)
, ind_treatment AS (
-- 治療方法コード
SELECT
  1000 AS temp_no,
  om.ind_treatment_cd AS mst_cd,
  CASE
    -- 両方とも利用開始日以降の場合
    WHEN ((om.treat_date::TIMESTAMP >= mt.in_hosp_a_startdate)
      AND (om.treat_date::TIMESTAMP >= mt.in_hosp_b_startdate)) THEN
      CASE
      WHEN mt.in_hosp_a_startdate > mt.in_hosp_b_startdate THEN
          CASE
        ini_value.hosp_get_mst_treatment
            WHEN ''1'' THEN mt.in_hospital_cd_a1
        WHEN ''2'' THEN mt.in_hospital_cd_a2
        WHEN ''3'' THEN mt.in_hospital_cd_a3
        WHEN ''4'' THEN mt.in_hospital_cd_a4
      END
      WHEN mt.in_hosp_a_startdate < mt.in_hosp_b_startdate THEN
          CASE
        ini_value.hosp_get_mst_treatment
            WHEN ''1'' THEN mt.in_hospital_cd_b1
        WHEN ''2'' THEN mt.in_hospital_cd_b2
        WHEN ''3'' THEN mt.in_hospital_cd_b3
        WHEN ''4'' THEN mt.in_hospital_cd_b4
      END
    END
    -- 治療日よりAの利用日開始日以降の場合
    WHEN om.treat_date::TIMESTAMP >= mt.in_hosp_a_startdate THEN
      CASE
      ini_value.hosp_get_mst_treatment
        WHEN ''1'' THEN mt.in_hospital_cd_a1
      WHEN ''2'' THEN mt.in_hospital_cd_a2
      WHEN ''3'' THEN mt.in_hospital_cd_a3
      WHEN ''4'' THEN mt.in_hospital_cd_a4
    END
    -- 治療日よりBの利用日開始日以降の場合
    WHEN om.treat_date::TIMESTAMP >= mt.in_hosp_b_startdate THEN
      CASE
      ini_value.hosp_get_mst_treatment
        WHEN ''1'' THEN mt.in_hospital_cd_b1
      WHEN ''2'' THEN mt.in_hospital_cd_b2
      WHEN ''3'' THEN mt.in_hospital_cd_b3
      WHEN ''4'' THEN mt.in_hospital_cd_b4
    END
    ELSE NULL
  END AS hosp_cd,
  1 AS amount,
  COALESCE(ini_value.treat_item_unit, '''') AS unit
FROM
  ord_main om
INNER JOIN mst_treatment AS mt ON
  mt.treatment_cd = om.ind_treatment_cd
CROSS JOIN ini_value
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
)
, ind_dialyzer AS (
-- ダイアライザ
SELECT
  1200 AS temp_no,
  om.ind_cond_info->''5''->>''value'' AS mst_cd,
  CASE
    ini_value.hosp_get_mst_dialyzer
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd,
  1 AS amount,
  COALESCE(ini_value.dialyzer_unit, '''') AS unit
FROM
  ord_main om
INNER JOIN mst_dialyzer AS mst ON
  mst.dialyzer_cd::text = om.ind_cond_info->''5''->>''value''
CROSS JOIN ini_value
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
)
, ind_adsorption AS (
-- 吸着カラム
SELECT
  1300 AS temp_no,
  om.ind_cond_info->''6''->>''value'' AS mst_cd,
  meq.meq_class_code_order AS meq_class_code_order,
  meq.meq_code_order AS meq_code_order,
  CASE
    ini_value.hosp_get_mst_equipment
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd,
  1 AS amount,
  CASE
    WHEN mst.unit = ''個'' THEN ini_value.unit_equip
    ELSE ''''
  END AS unit
FROM
  ord_main om
INNER JOIN mst_equipment AS mst ON
  mst.equipment_cd::text = om.ind_cond_info->''6''->>''value''
LEFT OUTER JOIN mst_equip AS meq ON
  meq.equipment_cd = TO_NUMBER(om.ind_cond_info->''6''->>''value'', ''FM999999999999'')
LEFT OUTER JOIN mst_equipment_class AS meqc ON
  meqc.class_cd = meq.class_cd
CROSS JOIN ini_value
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
)
, ind_coagulant AS (
-- 抗凝固剤
SELECT
  1800 AS temp_no,
  om.ind_cond_info->''25''->>''value'' AS mst_cd,
  (om.ind_cond_info->''25''->>''medicine_type'')::integer AS medicine_type,
  NULL::integer AS timing_cd,
  NULL::integer AS procedure_cd,
  999 AS interval_no,
  CASE
    WHEN COALESCE(om.ind_cond_info->''25''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE
      om.ind_cond_info->''25''->>''medicine_type''
        WHEN ''1'' THEN 
          CASE
        ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_medi.in_hospital_cd_1
        WHEN ''2'' THEN mst_medi.in_hospital_cd_2
        WHEN ''3'' THEN mst_medi.in_hospital_cd_3
        WHEN ''4'' THEN mst_medi.in_hospital_cd_4
        ELSE NULL
      END
      WHEN ''2'' THEN 
          CASE
        ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_mix.in_hospital_cd_1
        WHEN ''2'' THEN mst_mix.in_hospital_cd_2
        WHEN ''3'' THEN mst_mix.in_hospital_cd_3
        WHEN ''4'' THEN mst_mix.in_hospital_cd_4
        ELSE NULL
      END
    END
  END AS hosp_cd,
  CASE
    WHEN COALESCE(om.ind_cond_info->''25''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE
      om.ind_cond_info->''25''->>''medicine_type''
        WHEN ''1'' THEN (om.ind_cond_info->''26''->>''value'')::numeric + (om.ind_cond_info->''28''->>''value'')::numeric
      WHEN ''2'' THEN 
          CASE
        mst_mix.solvent
            WHEN ''0'' THEN
              ((om.ind_cond_info->''26''->>''value'')::numeric + (om.ind_cond_info->''28''->>''value'')::numeric) * mst_mix.amount::numeric
        WHEN ''1'' THEN mst_mix.amount::numeric
      END
    END
  END AS amount,
  CASE
    WHEN COALESCE(om.ind_cond_info->''25''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE
      om.ind_cond_info->''25''->>''medicine_type''
        WHEN ''1'' THEN 
          CASE
        WHEN mst_medi.unit = ''ml'' THEN ini_value.unit_medi
        ELSE ''''
      END
      WHEN ''2'' THEN 
          CASE
        WHEN mst_mix.unit = ''ml'' THEN ini_value.unit_medi
        ELSE ''''
      END
    END
  END AS unit
FROM
  ord_main om
LEFT JOIN mst_medicine AS mst_medi ON
  mst_medi.medicine_cd::text = om.ind_cond_info->''25''->>''value''
  AND mst_medi.is_shot = ''0''
  AND om.ind_cond_info->''25''->>''medicine_type''::text = ''1''
LEFT JOIN mst_medi_mix AS mst_mix ON
  mst_mix.mix_cd::text = om.ind_cond_info->''25''->>''value''
  AND om.ind_cond_info->''25''->>''medicine_type''::text = ''2''
CROSS JOIN ini_value
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
)
, ind_touseki AS (
-- 透析液
SELECT
  1900 AS temp_no,
  om.ind_cond_info->''15''->>''value'' AS mst_cd,
  (om.ind_cond_info->''15''->>''medicine_type'')::integer AS medicine_type,
  NULL::integer AS timing_cd,
  NULL::integer AS procedure_cd,
  999 AS interval_no,
  CASE
    WHEN COALESCE(om.ind_cond_info->''15''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE
      om.ind_cond_info->''15''->>''medicine_type''
      WHEN ''1'' THEN 
        CASE
        ini_value.hosp_get_mst_medicine
          WHEN ''1'' THEN mst_medi.in_hospital_cd_1
        WHEN ''2'' THEN mst_medi.in_hospital_cd_2
        WHEN ''3'' THEN mst_medi.in_hospital_cd_3
        WHEN ''4'' THEN mst_medi.in_hospital_cd_4
        ELSE NULL
      END
      WHEN ''2'' THEN 
        CASE
        ini_value.hosp_get_mst_medicine
          WHEN ''1'' THEN mst_mix.in_hospital_cd_1
        WHEN ''2'' THEN mst_mix.in_hospital_cd_2
        WHEN ''3'' THEN mst_mix.in_hospital_cd_3
        WHEN ''4'' THEN mst_mix.in_hospital_cd_4
        ELSE NULL
      END
    END
  END AS hosp_cd,
  CASE
    WHEN COALESCE(om.ind_cond_info->''15''->>''value'', '''') = '''' THEN NULL
    ELSE
      CAST(om.ind_cond_info->''16''->>''value'' AS NUMERIC)
  END AS amount,
  CASE
    WHEN COALESCE(om.ind_cond_info->''15''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE
      om.ind_cond_info->''15''->>''medicine_type''
        WHEN ''1'' THEN 
          CASE
        WHEN mst_medi.unit = ''ml'' THEN ini_value.unit_medi
        ELSE ''''
      END
      WHEN ''2'' THEN 
          CASE
        WHEN mst_mix.unit = ''ml'' THEN ini_value.unit_medi
        ELSE ''''
      END
    END
  END AS unit
FROM
  ord_main om
LEFT JOIN mst_medicine AS mst_medi ON
  mst_medi.medicine_cd::text = om.ind_cond_info->''15''->>''value''
  AND mst_medi.is_shot = ''0''
  AND om.ind_cond_info->''15''->>''medicine_type''::text = ''1''
LEFT JOIN mst_medi_mix AS mst_mix ON
  mst_mix.mix_cd::text = om.ind_cond_info->''15''->>''value''
  AND om.ind_cond_info->''15''->>''medicine_type''::text = ''2''
CROSS JOIN ini_value
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
)
, ind_hoeki AS (
-- 補液
SELECT
  2000 AS temp_no,
  om.ind_cond_info->''19''->>''value'' AS mst_cd,
  (om.ind_cond_info->''19''->>''medicine_type'')::integer AS medicine_type,
  NULL::integer AS timing_cd,
  NULL::integer AS procedure_cd,
  999 AS interval_no,  
  CASE
    WHEN COALESCE(om.ind_cond_info->''19''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE
      om.ind_cond_info->''19''->>''medicine_type''
        WHEN ''1'' THEN 
          CASE
        ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_medi.in_hospital_cd_1
        WHEN ''2'' THEN mst_medi.in_hospital_cd_2
        WHEN ''3'' THEN mst_medi.in_hospital_cd_3
        WHEN ''4'' THEN mst_medi.in_hospital_cd_4
        ELSE NULL
      END
      WHEN ''2'' THEN 
          CASE
        ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_mix.in_hospital_cd_1
        WHEN ''2'' THEN mst_mix.in_hospital_cd_2
        WHEN ''3'' THEN mst_mix.in_hospital_cd_3
        WHEN ''4'' THEN mst_mix.in_hospital_cd_4
        ELSE NULL
      END
    END
  END AS hosp_cd,
  CASE
    WHEN COALESCE(om.ind_cond_info->''19''->>''value'', '''') = '''' THEN NULL
    ELSE
      (om.ind_cond_info->''22''->>''value'')::numeric
  END AS amount,
  CASE
    WHEN COALESCE(om.ind_cond_info->''19''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE
      om.ind_cond_info->''19''->>''medicine_type''
        WHEN ''1'' THEN 
          CASE
        WHEN mst_medi.unit = ''ml'' THEN ini_value.unit_medi
        ELSE ''''
      END
      WHEN ''2'' THEN 
          CASE
        WHEN mst_mix.unit = ''ml'' THEN ini_value.unit_medi
        ELSE ''''
      END
    END
  END AS unit
FROM
  ord_main om
LEFT JOIN mst_medicine AS mst_medi ON
  mst_medi.medicine_cd::text = om.ind_cond_info->''19''->>''value''
  AND mst_medi.is_shot = ''0''
  AND om.ind_cond_info->''19''->>''medicine_type''::text = ''1''
LEFT JOIN mst_medi_mix AS mst_mix ON
  mst_mix.mix_cd::text = om.ind_cond_info->''19''->>''value''
  AND om.ind_cond_info->''19''->>''medicine_type''::text = ''2''
CROSS JOIN ini_value
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
)
, ind_one_film AS (
-- 1次膜
SELECT
  1500 AS temp_no,
  om.ind_cond_info->''7''->>''value'' AS mst_cd,
  meq.meq_class_code_order AS meq_class_code_order,
  meq.meq_code_order AS meq_code_order,
  CASE
    ini_value.hosp_get_mst_equipment
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd,
  1 AS amount,
  CASE
    WHEN mst.unit = ''個'' THEN ini_value.unit_equip
    ELSE ''''
  END AS unit
FROM
  ord_main om
INNER JOIN mst_equipment AS mst ON
  mst.equipment_cd::text = om.ind_cond_info->''7''->>''value''
LEFT OUTER JOIN mst_equip AS meq ON
  meq.equipment_cd = TO_NUMBER(om.ind_cond_info->''7''->>''value'', ''FM999999999999'')
LEFT OUTER JOIN mst_equipment_class AS meqc ON
  meqc.class_cd = meq.class_cd
CROSS JOIN ini_value
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
)
, ind_two_film AS (
-- 2次膜
SELECT
  1600 AS temp_no,
  om.ind_cond_info->''8''->>''value'' AS mst_cd,
  meq.meq_class_code_order AS meq_class_code_order,
  meq.meq_code_order AS meq_code_order,
  CASE
    ini_value.hosp_get_mst_equipment
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd,
  1 AS amount,
  CASE
    WHEN mst.unit = ''個'' THEN ini_value.unit_equip
    ELSE ''''
  END AS unit
FROM
  ord_main om
INNER JOIN mst_equipment AS mst ON
  mst.equipment_cd::text = om.ind_cond_info->''8''->>''value''
LEFT OUTER JOIN mst_equip AS meq ON
  meq.equipment_cd = TO_NUMBER(om.ind_cond_info->''8''->>''value'', ''FM999999999999'')
LEFT OUTER JOIN mst_equipment_class AS meqc ON
  meqc.class_cd = meq.class_cd
CROSS JOIN ini_value
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
)
, medi_indo AS (
-- 投与薬剤情報
SELECT
  2100 + t1.idx AS temp_no,
  t1.medi_info ->> ''cd'' AS mst_cd,
  (t1.medi_info ->> ''medicine_type'')::integer AS medicine_type,
  (t1.medi_info ->> ''timing_cd'')::integer AS timing_cd,
  (t1.medi_info ->> ''procedure_cd'')::integer AS procedure_cd,
  (t1.medi_info ->> ''date_interval'')::integer AS interval_no,
  om.treat_date::TIMESTAMP AS treat_date,
  CASE
    WHEN json_array_length(om.ind_medi_info::json) = 0 THEN NULL
    ELSE
      CASE
      t1.medi_info ->> ''medicine_type''
        WHEN ''1'' THEN 
          CASE
        ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_medi.in_hospital_cd_1
        WHEN ''2'' THEN mst_medi.in_hospital_cd_2
        WHEN ''3'' THEN mst_medi.in_hospital_cd_3
        WHEN ''4'' THEN mst_medi.in_hospital_cd_4
        ELSE NULL
      END
      WHEN ''2'' THEN 
          CASE
        ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_mix.in_hospital_cd_1
        WHEN ''2'' THEN mst_mix.in_hospital_cd_2
        WHEN ''3'' THEN mst_mix.in_hospital_cd_3
        WHEN ''4'' THEN mst_mix.in_hospital_cd_4
        ELSE NULL
      END
    END
  END AS hosp_cd,
  CASE
    WHEN json_array_length(om.ind_medi_info::json) = 0 THEN NULL
    ELSE
      CASE
      t1.medi_info ->> ''medicine_type''
        WHEN ''1'' THEN CAST(medi_info ->> ''amount'' AS NUMERIC)
      WHEN ''2'' THEN
          CASE
        mst_mix.solvent
            WHEN ''0'' THEN
              CAST(medi_info ->> ''amount'' AS NUMERIC) * CAST(mst_mix.amount AS NUMERIC)
        WHEN ''1'' THEN
              CAST(mst_mix.amount AS NUMERIC)
      END
      ELSE 0
    END
  END AS amount,
  CASE
    WHEN json_array_length(om.ind_medi_info::json) = 0 THEN NULL
    ELSE
      CASE
      t1.medi_info ->> ''medicine_type''
        WHEN ''1'' THEN 
          CASE
        WHEN mst_medi.unit = ''ml'' THEN ini_value.unit_medi
        ELSE ''''
      END
      WHEN ''2'' THEN 
          CASE
        WHEN mst_mix.unit = ''ml'' THEN ini_value.unit_medi
        ELSE ''''
      END
    END
  END AS unit,
  CASE
    WHEN json_array_length(om.ind_medi_info::json) = 0 THEN NULL
    ELSE
        CASE t1.medi_info ->> ''medicine_type''
             WHEN ''1'' THEN mst_medi.is_shot
        WHEN ''2'' THEN mst_mix.is_shot
      END
  END AS is_shot
FROM
  ord_main om
CROSS JOIN LATERAL json_array_elements(om.ind_medi_info::json) WITH ORDINALITY AS t1(medi_info, idx)
LEFT JOIN mst_medicine AS mst_medi ON
  mst_medi.medicine_cd::text = medi_info ->> ''cd''
    AND medi_info ->> ''medicine_type''::text = ''1''
  LEFT JOIN mst_medi_mix AS mst_mix ON
    mst_mix.mix_cd::text = medi_info ->> ''cd''
    AND medi_info ->> ''medicine_type''::text = ''2''
  CROSS JOIN ini_value
  WHERE
    om.is_del = ''0''
    AND om.ord_no = @ordNo
    AND om.pat_id = @patId
)
, ind_equip_info AS (
-- 医療材料コード
SELECT
  1700 + t1.idx AS temp_no,
  t1.equip_info ->> ''cd'' AS mst_cd,
  meq.meq_class_code_order AS meq_class_code_order,
  meq.meq_code_order AS meq_code_order,
  CASE
    ini_value.hosp_get_mst_equipment
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd,
  CAST(t1.equip_info->>''amount'' AS NUMERIC) AS amount,
  CASE
    WHEN mst.unit = ''個'' THEN ini_value.unit_equip
    ELSE ''''
  END AS unit
FROM
  ord_main om
CROSS JOIN LATERAL json_array_elements(om.ind_equip_info ::json) WITH ORDINALITY AS t1(equip_info, idx)
INNER JOIN mst_equipment AS mst ON
  mst.equipment_cd::text = t1.equip_info ->> ''cd''
LEFT OUTER JOIN mst_equip AS meq ON
  meq.equipment_cd = TO_NUMBER(t1.equip_info ->> ''cd'', ''FM999999999999'')
LEFT OUTER JOIN mst_equipment_class AS meqc ON
  meqc.class_cd = meq.class_cd
CROSS JOIN ini_value
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
)
, dial_diff_info AS (
-- 透析困難コード
SELECT
  1100 AS temp_no,
  CASE
    ini_value.hosp_get_mst_dia_diff
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    ELSE NULL
  END AS hosp_cd,
  1 AS amount,
  '''' AS unit
FROM
  auth_info ai
LEFT JOIN mst_dialysis_difficulty AS mst ON
  mst.dialysis_difficulty_cd::text = ai.dial_diff_cd
  AND mst.is_del = ''0''
CROSS JOIN ini_value
WHERE
  ai.is_dial_diff = ''1''
)
, medi_union_1 AS (
-- 薬剤情報（抗凝固剤、透析液、補液、投与薬剤情報(手技なし)）
SELECT
  title,
  hosp_cd,
  amount,
  unit,
  ROW_NUMBER() OVER(
      ORDER BY
      CASE 
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''0'' THEN temp_no
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''1'' THEN medi_class_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''2'' THEN medicine_type
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''3'' THEN medi_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''4'' THEN timing_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''5'' THEN procedure_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''6'' THEN interval_no
      END,
      CASE
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''0'' THEN temp_no
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''1'' THEN medi_class_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''2'' THEN medicine_type
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''3'' THEN medi_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''4'' THEN timing_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''5'' THEN procedure_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''6'' THEN interval_no
      END,
      CASE
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''0'' THEN temp_no
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''1'' THEN medi_class_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''2'' THEN medicine_type
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''3'' THEN medi_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''4'' THEN timing_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''5'' THEN procedure_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''6'' THEN interval_no
      END,
      CASE
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''0'' THEN temp_no
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''1'' THEN medi_class_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''2'' THEN medicine_type
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''3'' THEN medi_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''4'' THEN timing_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''5'' THEN procedure_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''6'' THEN interval_no
      END,
      CASE
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''0'' THEN temp_no
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''1'' THEN medi_class_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''2'' THEN medicine_type
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''3'' THEN medi_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''4'' THEN timing_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''5'' THEN procedure_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''6'' THEN interval_no
      END,
      CASE
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''0'' THEN temp_no
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''1'' THEN medi_class_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''2'' THEN medicine_type
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''3'' THEN medi_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''4'' THEN timing_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''5'' THEN procedure_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''6'' THEN interval_no
      END,
      CASE
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''0'' THEN temp_no
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''1'' THEN medi_class_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''2'' THEN medicine_type
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''3'' THEN medi_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''4'' THEN timing_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''5'' THEN procedure_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''6'' THEN interval_no
      END,
      medi_code_order
      ) AS sort_num
FROM
  (SELECT
    coa.temp_no AS temp_no,
    coa.medicine_type AS medicine_type,
    coa.timing_cd AS timing_cd,
    coa.procedure_cd AS procedure_cd,
    coa.interval_no AS interval_no,
    ''抗凝固剤'' AS title,
    coa.mst_cd AS mst_cd,
    coa.hosp_cd AS hosp_cd,
    coa.amount AS amount,
    coa.unit AS unit
  FROM
    ind_coagulant coa
  WHERE
    coa.mst_cd IS NOT NULL
UNION ALL
  SELECT
    tou.temp_no AS temp_no,
    tou.medicine_type AS medicine_type,
    tou.timing_cd AS timing_cd,
    tou.procedure_cd AS procedure_cd,
    tou.interval_no AS interval_no,
    ''透析液'' AS title,
    tou.mst_cd AS mst_cd,
    tou.hosp_cd AS hosp_cd,
    tou.amount AS amount,
    tou.unit AS unit
  FROM
    ind_touseki tou
  WHERE
    tou.mst_cd IS NOT NULL
UNION ALL
  SELECT
    hoe.temp_no AS temp_no,
    hoe.medicine_type AS medicine_type,
    hoe.timing_cd AS timing_cd,
    hoe.procedure_cd AS procedure_cd,
    hoe.interval_no AS interval_no,
    ''補液'' AS title,
    hoe.mst_cd AS mst_cd,
    hoe.hosp_cd AS hosp_cd,
    hoe.amount AS amount,
    hoe.unit AS unit
  FROM
    ind_hoeki hoe
  WHERE
    hoe.mst_cd IS NOT NULL
UNION ALL
  SELECT
    imi.temp_no AS temp_no,
    imi.medicine_type AS medicine_type,
    imi.timing_cd AS timing_cd,
    imi.procedure_cd AS procedure_cd,
    imi.interval_no AS interval_no,
    ''投与薬剤情報(手技なし）'' AS title,
    imi.mst_cd AS mst_cd,
    imi.hosp_cd AS hosp_cd,
    imi.amount AS amount,
    imi.unit AS unit
  FROM
    medi_indo imi
  WHERE
    imi.mst_cd IS NOT NULL
    AND imi.is_shot = ''0''
    AND imi.procedure_cd IS NULL
) AS ind_medi_table
LEFT JOIN mst_medi mmd ON
  ind_medi_table.mst_cd = mmd.medicine_cd::text
LEFT JOIN timing_order ON
  ind_medi_table.timing_cd = timing_order.timing_code
LEFT JOIN procedure_order ON
  ind_medi_table.procedure_cd = procedure_order.procedure_code
ORDER BY
  sort_num
)
, medi_union_2 AS (
SELECT
  ''投与薬剤情報(薬剤）'' AS title,
  imi2.mst_cd AS mst_cd,
  imi2.hosp_cd AS hosp_cd,
  SUM(imi2.amount) AS amount,
  MAX(imi2.unit) AS unit,
  MAX(mst.pricedure_name) AS pro_title,
  imi2.procedure_cd AS procedure_cd,
  CASE
    WHEN ((MAX(imi2.treat_date) >= MAX(mst.in_hosp_a_startdate)) AND (MAX(imi2.treat_date) >= MAX(mst.in_hosp_b_startdate))) THEN
      CASE
        WHEN MAX(mst.in_hosp_a_startdate) > MAX(mst.in_hosp_b_startdate) THEN
          CASE MAX(ini_value.hosp_get_mst_procedure)
            WHEN ''1'' THEN MAX(mst.in_hospital_cd_a1)
            WHEN ''2'' THEN MAX(mst.in_hospital_cd_a2)
          END
        WHEN MAX(mst.in_hosp_a_startdate) < MAX(mst.in_hosp_b_startdate) THEN
          CASE MAX(ini_value.hosp_get_mst_procedure)
            WHEN ''1'' THEN MAX(mst.in_hospital_cd_b1)
            WHEN ''2'' THEN MAX(mst.in_hospital_cd_b2)
          END
      END
    WHEN MAX(imi2.treat_date) >= MAX(mst.in_hosp_a_startdate) THEN
      CASE MAX(ini_value.hosp_get_mst_procedure)
        WHEN ''1'' THEN MAX(mst.in_hospital_cd_a1)
        WHEN ''2'' THEN MAX(mst.in_hospital_cd_a2)
      END
    WHEN MAX(imi2.treat_date) >= MAX(mst.in_hosp_b_startdate) THEN
      CASE MAX(ini_value.hosp_get_mst_procedure)
        WHEN ''1'' THEN MAX(mst.in_hospital_cd_b1)
        WHEN ''2'' THEN MAX(mst.in_hospital_cd_b2)
      END
    ELSE NULL
  END AS pro_hosp_cd
FROM
  medi_indo imi2
INNER JOIN mst_procedure mst
  ON mst.procedure_cd = imi2.procedure_cd
CROSS JOIN ini_value
WHERE
  imi2.mst_cd IS NOT NULL
  AND imi2.is_shot = ''0''
  AND imi2.procedure_cd IS NOT NULL
GROUP BY
  imi2.procedure_cd,
  imi2.mst_cd,
  imi2.hosp_cd
)
, equip_union AS (
-- 医療材料情報（吸着カラム,1次膜,2次膜,医療材料情報）
SELECT
  title,
  hosp_cd,
  amount,
  unit,
  ROW_NUMBER() OVER(
      ORDER BY
  CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 0 THEN ind_equip_table.temp_no
        WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 1 THEN ind_equip_table.meq_class_code_order
        WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 2 THEN ind_equip_table.meq_code_order END,
    CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 0 THEN ind_equip_table.temp_no
        WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 1 THEN ind_equip_table.meq_class_code_order
        WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 2 THEN ind_equip_table.meq_code_order END,
    CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 0 THEN ind_equip_table.temp_no
        WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 1 THEN ind_equip_table.meq_class_code_order
        WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 2 THEN ind_equip_table.meq_code_order END, 
    ind_equip_table.meq_code_order
      ) AS sort_num
FROM
  (SELECT
    ''吸着カラム'' AS title,
    ads.*
  FROM
    ind_adsorption ads
  WHERE
    ads.mst_cd IS NOT NULL
UNION ALL
  SELECT
    ''1次膜'' AS title,
    one.*
  FROM
    ind_one_film one
  WHERE
    one.mst_cd IS NOT NULL
UNION ALL
  SELECT
    ''2次膜'' AS title,
    two.*
  FROM
    ind_two_film two
  WHERE
    two.mst_cd IS NOT NULL
UNION ALL
  SELECT
    ''医療材料情報'' AS title,
    iei.*
  FROM
    ind_equip_info iei
  WHERE
    iei.mst_cd IS NOT NULL    
) AS ind_equip_table
ORDER BY
  sort_num
)
, equip_sort_num AS (
SELECT
  DISTINCT ON (un.hosp_cd) un.hosp_cd AS hosp_cd,
  un.r_num
FROM
  (SELECT
    ROW_NUMBER() OVER () AS r_num,
    ut.hosp_cd
  FROM
    equip_union ut
) AS un
ORDER BY
  un.hosp_cd,
  un.r_num
)
, equip_sort_union AS (
-- 医療材料情報の合算とソート
SELECT
  ams.title,
  ams.hosp_cd AS hosp_cd,
  ams.amount AS amount,
  ams.unit AS unit,
  NULL AS proc_cd
FROM
  (SELECT
    STRING_AGG(DISTINCT title, ''-'') AS title,
    hosp_cd,
    SUM(amount) AS amount,
    unit
  FROM
    equip_union
  GROUP BY
    hosp_cd,
    unit
) AS ams
INNER JOIN equip_sort_num AS un ON un.hosp_cd = ams.hosp_cd
ORDER BY un.r_num
)
, union_table AS (
-- 全項目をUNION ALL
SELECT
  ''治療方法'' AS title,
  tre.hosp_cd AS hosp_cd,
  tre.amount AS amount,
  tre.unit AS unit,
  NULL AS proc_cd
FROM
  ind_treatment tre
WHERE
  tre.hosp_cd IS NOT NULL
UNION ALL
SELECT
  ''透析困難コード'' AS title,
  ddi.hosp_cd AS hosp_cd,
  ddi.amount AS amount,
  ddi.unit AS unit,
  NULL AS proc_cd
FROM
  dial_diff_info ddi
WHERE
  ddi.hosp_cd IS NOT NULL
UNION ALL
SELECT
  ''ダイアライザ'' AS title,
  dia.hosp_cd AS hosp_cd,
  dia.amount AS amount,
  dia.unit AS unit,
  NULL AS proc_cd
FROM
  ind_dialyzer dia
WHERE
  dia.hosp_cd IS NOT NULL
UNION ALL
SELECT
  eu.title AS title,
  eu.hosp_cd AS hosp_cd,
  eu.amount AS amount,
  eu.unit AS unit,
  NULL AS proc_cd
FROM
  equip_sort_union eu
WHERE
  eu.hosp_cd IS NOT NULL
UNION ALL
SELECT
  mu1.title AS title,
  mu1.hosp_cd AS hosp_cd,
  mu1.amount AS amount,
  mu1.unit AS unit,
  NULL AS proc_cd
FROM
  medi_union_1 mu1
WHERE
  mu1.hosp_cd IS NOT NULL
UNION ALL
SELECT
  mu2.title AS title,
  mu2.hosp_cd AS hosp_cd,
  mu2.amount AS amount,
  mu2.unit AS unit,
  mu2.pro_hosp_cd AS proc_cd
FROM
  medi_union_2 mu2
WHERE
  mu2.hosp_cd IS NOT NULL
)
, numbered AS (
SELECT
  *,
  ROW_NUMBER() OVER () AS rn
FROM
  union_table
)
, recursive_rp AS (
-- 再帰で RP, RpItem を採番
SELECT
  n.rn,
  n.title,
  n.hosp_cd,
  n.amount,
  n.unit,
  n.proc_cd,
  1 AS RP,
  1 AS RpItem,
  NULL::text AS last_proc_cd,
  ARRAY[]::text[] AS proc_cd_list,
  FALSE AS need_procedure_insert,
  FALSE AS need_treatment_insert
FROM
  numbered n,
  ini_value m
WHERE
  n.rn = 1
UNION ALL
SELECT
  n.rn,
  n.title,
  n.hosp_cd,
  n.amount,
  n.unit,
  n.proc_cd,
  CASE
    WHEN n.proc_cd IS NOT NULL
     AND NOT (n.proc_cd = ANY(r.proc_cd_list))
         THEN r.RP + 1
    WHEN r.RpItem >= 20 OR (m.medicine_send_type::NUMERIC = 0 AND n.proc_cd IS NOT NULL)
          THEN r.RP + 1
    ELSE r.RP
  END AS RP,
  CASE
    WHEN ((n.proc_cd IS NOT NULL
        AND NOT (n.proc_cd = ANY(r.proc_cd_list)))
        OR (r.RpItem >= 20 OR (m.medicine_send_type::NUMERIC = 0 AND n.proc_cd IS NOT NULL))
          )
          THEN 2
    ELSE r.RpItem + 1
  END AS RpItem,
  CASE
    WHEN n.proc_cd IS NOT NULL THEN n.proc_cd
    ELSE r.last_proc_cd
  END AS last_proc_cd,
  CASE
    WHEN n.proc_cd IS NOT NULL
       AND NOT (n.proc_cd = ANY(r.proc_cd_list))
            THEN r.proc_cd_list || n.proc_cd
    ELSE r.proc_cd_list
  END AS proc_cd_list,
  CASE
    WHEN((n.proc_cd IS NOT NULL
        AND NOT (n.proc_cd = ANY(r.proc_cd_list)))
        OR (m.medicine_send_type::NUMERIC = 0 AND n.proc_cd IS NOT NULL)
        OR r.RpItem >= 20 AND n.proc_cd IS NOT NULL
          )
        THEN TRUE
    ELSE FALSE
  END AS need_procedure_insert,
  CASE
    WHEN r.RpItem >= 20 AND n.proc_cd IS NULL
        THEN TRUE
    ELSE FALSE
  END AS need_treatment_insert
  FROM
    recursive_rp r
  JOIN numbered n ON n.rn = r.rn + 1
  CROSS JOIN ini_value m
)
, procedure_inserts AS (
-- 手技コード差し込み
SELECT
  RP,
  1 AS RpItem,
  ''手技コード'' AS title,
  last_proc_cd AS hosp_cd,
  1 AS amount,
  '''' AS unit,
  NULL::text AS proc_cd,
  (rn - 0.5)::NUMERIC AS sort_key
FROM
  recursive_rp
WHERE
  need_procedure_insert
)
, treatment_inserts AS (
-- 治療項目コード差し込み
SELECT
  RP,
  1 AS RpItem,
  ''治療方法'' AS title,
  tre.hosp_cd AS hosp_cd,
  tre.amount AS amount,
  tre.unit AS unit,
  NULL::text AS proc_cd,
  (rn - 0.5)::NUMERIC AS sort_key
FROM
  recursive_rp
  CROSS JOIN ind_treatment tre
WHERE
  need_treatment_insert
)
, recursive_rp_with_sort AS (
SELECT
  RP,
  RpItem,
  title,
  hosp_cd,
  amount,
  unit,
  proc_cd,
  rn::NUMERIC AS sort_key
FROM
  recursive_rp
)
, final_data AS (
SELECT
  RP,
  RpItem,
  title,
  hosp_cd,
  amount,
  unit,
  proc_cd,
  sort_key
FROM
  recursive_rp_with_sort
UNION ALL
SELECT
  RP,
  RpItem,
  title,
  hosp_cd,
  amount,
  unit,
  proc_cd,
  sort_key
FROM
  procedure_inserts
UNION ALL
SELECT
  RP,
  RpItem,
  title,
  hosp_cd,
  amount,
  unit,
  proc_cd,
  sort_key
FROM
  treatment_inserts
)
SELECT
  RP AS rp_no,
  RpItem AS item_no,
  hosp_cd AS medi_cd,
  amount AS medi_amount,
  unit,
  ''01'' AS detail_id
FROM
  final_data
ORDER BY
  RP,
  sort_key
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)セコムの透析指示_処置項目情報取得', '2025-07-01 17:38:01.233', CURRENT_TIMESTAMP, '[{"sql_cd": -1102004, "field_name": "pat_personal_info", "replace_var": "@patPersonalInfo"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1100006, 'WITH coop_ini_info AS (
    -- 連携設定取得(pre_sqlにて取得)
    SELECT coop_info->>''key1'' AS key1,
        coop_info->>''key2'' AS key2,
        coop_info->>''value'' AS value
    FROM json_array_elements(@coopIniInfo::json) coop_info
)
, converted_in_out_class AS (
    -- in_out_class変換値の取得（なければ''1''をデフォルトにする）
    SELECT ppm.pat_id,
        ppm.hosp_pat_id,
        ppm.in_out_class,
        COALESCE((  
            SELECT value
            FROM coop_ini_info
            WHERE key1 = ''CONV_INOUT_TO_KARTE''
                AND key2 = CASE
                    WHEN ppm.in_out_class::text = ''3'' THEN ''0''
                    ELSE ppm.in_out_class::text
                END
        ), ''1'') AS converted_in_out_class
    FROM pat_personal_main ppm
    WHERE ppm.pat_id = @patId
        AND ppm.is_del = ''0''
)
, ini_value AS (
    -- 患者ID桁数の取得
    SELECT (
            SELECT value
            FROM coop_ini_info
            WHERE key1 = ''SCM_COMMON''
                AND key2 = ''PATID_LEN''
        ) AS patid_len
)
SELECT LPAD(
    RIGHT(converted.hosp_pat_id::text, ini_value.patid_len::integer),
    ini_value.patid_len::integer,''0'') AS hosp_pat_id,
    converted.converted_in_out_class AS in_out_class
FROM converted_in_out_class converted
    CROSS JOIN ini_value;', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Secom連携_汎用（表示用患者ID、患者個人情報.入外区分取得）', '2025-05-27 13:22:20.351', CURRENT_TIMESTAMP, '[{"sql_cd": -1100005, "field_name": "coop_ini_info", "replace_var": "@coopIniInfo"}]'::jsonb);
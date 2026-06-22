DELETE FROM ntss.sys_data_set WHERE sql_cd=-1103001;

INSERT INTO ntss.sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-1103001, '-- SQL: -1103001 begin
WITH RECURSIVE coop_ini_info AS (
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
        ''SCM_CONV_UNIT_MEDI'',
        ''SCM_CONV_UNIT_EQUIP'',
        ''SCM_IN_HOSPITAL_CD'',
        ''SCM_DIALYSISSEND''
    )
)
, ini_unit_medi AS (
    SELECT
        key2,
        value
    FROM
        coop_ini_info
    WHERE
        key1 = ''SCM_CONV_UNIT_MEDI''
)
, ini_unit_equip AS (
    SELECT
        key2,
        value
    FROM
        coop_ini_info
    WHERE
        key1 = ''SCM_CONV_UNIT_EQUIP''
)
, ini_value AS (
--連携設定からvalue値取得
SELECT
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''MEDICINE_SEND_TYPE'') AS medicine_send_type,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''DIALYZER_UNIT'') AS dialyzer_unit,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''TREAT_ITEM_UNIT'') AS treat_item_unit,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''DIAL_DIFF_COMMENT_UNIT'') AS dial_diff_comment_unit,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_TREATMENT'') AS hosp_get_mst_treatment,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_DIALYZER'') AS hosp_get_mst_dialyzer,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_EQUIPMENT'') AS hosp_get_mst_equipment,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_MEDICINE'') AS hosp_get_mst_medicine,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_PROCEDURE'') AS hosp_get_mst_procedure,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_DIALYSIS_DIFFICULTY'') AS hosp_get_mst_dia_diff,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_ADDITION'') AS hosp_get_mst_addition,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND'' AND key2 = ''OXGEN_PROCEDURE_CODE'') AS oxgen_procedure_code,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND'' AND key2 = ''OXGEN_UNIT_CODE'') AS oxgen_unit_code,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND'' AND key2 = ''OXGEN_MEDI_CODE'') AS oxgen_medi_code,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND'' AND key2 = ''TREAT_CONVERT'') AS treat_convert,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND'' AND key2 = ''ADDITION_CD'') AS addition_cd
)
, addition_cd_list as (
SELECT
  UNNEST(string_to_array(addition_cd, '','')) AS set_value
FROM ini_value
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
  (t1.info ->> ''cd'')::integer AS medi_cd,
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
INNER JOIN mst_medicine AS mst ON mst.medicine_cd::text = info ->> ''cd''
  AND mst.facility_cd = @facilityCd
  AND mst.is_shot = ''0''
  AND mst.is_del = ''0''
  AND mst.is_disp = ''1''
WHERE
  mix.is_del = ''0''
  AND mix.facility_cd = @facilityCd
)
, medi_order_data AS (
-- 施設設定マスタから投与薬剤表示順を取得
    SELECT
        ROW_NUMBER() OVER () AS no2,
        datt.a1
    FROM (
        SELECT
            TO_NUMBER(val, ''999999999999'') AS a1
        FROM unnest(
            COALESCE(
            string_to_array(
                (
                SELECT mst_f.value
                FROM mst_facility_setting AS mst_f
                WHERE mst_f.facility_setting_no = ''3007''
                    AND mst_f.facility_cd = @facilityCd
                ),
                '',''
            ),
            ARRAY[''0'']  -- デフォルトで0:登録順を返却
            )
        ) AS val
    ) AS datt
)
, medi_order AS (
-- 薬剤マスタ表示順
SELECT
  index_no ::int AS medi_code_order,
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
  index_no ::int AS medi_class_code_order,
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
  index_no ::int AS timing_code_order,
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
  index_no ::int AS procedure_code_order,
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
  class_cd,
  medi_order.medi_code_order,
  medi_class_order.medi_class_code_order
FROM
  mst_medicine mmd
LEFT JOIN medi_order ON mmd.medicine_cd = medi_order.medi_code
LEFT JOIN medi_class_order ON mmd.class_cd = medi_class_order.medi_class_code
WHERE
  facility_cd = @facilityCd
)
, equip_order_data AS (
-- 施設設定マスタから、医療材料表示順を取得
    SELECT
        ROW_NUMBER() OVER () AS no2,
        TO_NUMBER(val, ''999999999999'') AS ora
    FROM UNNEST(
        COALESCE(
            string_to_array(
            (
                SELECT mst_f.value
                FROM mst_facility_setting AS mst_f
                WHERE mst_f.facility_setting_no = ''3006''
                AND mst_f.facility_cd = @facilityCd
            ),
            '',''
            ),
            ARRAY[''0'']  -- デフォルトで0:登録順を返却
        )
    ) AS val
)
, equip_order AS (
-- 医療材料マスタ表示順
SELECT
  index_no ::int AS meq_code_order,
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
  index_no ::int AS meq_class_code_order,
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
, do_ord_main AS (
(SELECT
  res.del_date as up_date_switch,
  res.rst_treatment_cd as rst_treatment_cd,
  res.rst_cond_info as rst_cond_info,
  res.rst_medi_info AS rst_medi_info,
  res.rst_treatment_info as rst_treatment_info,
  res.rst_equip_info as rst_equip_info,
  res.addition_info as addition_info,
  res.treat_date::TIMESTAMP AS treat_date,
  res.rst_start_date AS rst_start_date,
  res.rst_end_date AS rst_end_date
FROM ord_main_restore as res
JOIN sys_coop_journal AS journal ON res.ord_no = journal.ord_no
WHERE res.ord_no = @ordNo
  AND res.facility_cd = @facilityCd
  AND res.pat_id = @patId
  AND res.is_del = ''0''
  AND res.ord_no = journal.ord_no
  AND journal.ctl_no = @ctlNo
  AND journal.reg_date >= res.del_date
ORDER BY res.del_date DESC LIMIT 1
)
UNION
(SELECT
  main.rst_edition_date as up_date_switch,
  main.rst_treatment_cd as rst_treatment_cd,
  main.rst_cond_info as rst_cond_info,
  main.rst_medi_info AS rst_medi_info,
  main.rst_treatment_info as rst_treatment_info,
  main.rst_equip_info as rst_equip_info,
  main.addition_info as addition_info,
  main.treat_date::TIMESTAMP AS treat_date,
  main.rst_start_date AS rst_start_date,
  main.rst_end_date AS rst_end_date
FROM ord_main AS main
  WHERE main.ord_no = @ordNo
  AND main.facility_cd = @facilityCd
  AND main.pat_id = @patId
  AND main.is_del = ''0''
)
ORDER BY
  up_date_switch DESC NULLS LAST
LIMIT 1
)
, treat_convert_part AS (
-- 連携設定.治療方法変換設定をテーブル化
SELECT
  key2 AS hosp_cd,
  split_part(t1.set_value, '','', 1) AS dialysis_time,
  split_part(t1.set_value, '','', 2) AS convert_cd,
  t1.no
FROM
  (SELECT
    key2
    , UNNEST(string_to_array(value, ''_'')) AS set_value
    ,generate_subscripts(string_to_array(value, ''_''), 1) as no
  FROM
    coop_ini_info ini
  WHERE key1 = ''SCM_DIALYSISSEND''
 ) t1
)
, parsed_ranges_check AS (
-- 治療方法変換設定チェック
SELECT distinct
  hosp_cd,
  ''NG'' AS check_result
FROM (
  SELECT
    CASE WHEN dialysis_time ~ ''^\d+(\.\d+)?$''
    THEN NULLIF(dialysis_time, '''')
    ELSE NULL
    END AS lower_bound,
    NULLIF(convert_cd, '''') AS value,
    treat_convert_part.hosp_cd
  FROM treat_convert_part
) check_part
WHERE lower_bound IS NULL
  OR value IS NULL
)
, treat_convert AS (
    SELECT
        treat_convert_part.hosp_cd,
        convert_cd AS convert_cd,
        dialysis_time::numeric AS lower_bound,
        lead(dialysis_time::numeric, 1, 100000) OVER (PARTITION BY treat_convert_part.hosp_cd ORDER BY dialysis_time::numeric) -0.0001 AS upper_bound
    FROM treat_convert_part
    LEFT JOIN parsed_ranges_check on treat_convert_part.hosp_cd = parsed_ranges_check.hosp_cd
    WHERE parsed_ranges_check.check_result IS NULL
)
, ord_main_tre AS (
-- 治療方法コード
SELECT
  10000000 AS temp_no,
  om.rst_treatment_cd AS mst_cd,
  CASE
    -- 両方とも利用開始日以降の場合
    WHEN ((om.treat_date::TIMESTAMP >= mt.in_hosp_a_startdate)
      AND (om.treat_date::TIMESTAMP >= mt.in_hosp_b_startdate)) THEN
      CASE
        WHEN mt.in_hosp_a_startdate > mt.in_hosp_b_startdate THEN
          CASE ini_value.hosp_get_mst_treatment
            WHEN ''1'' THEN mt.in_hospital_cd_a1
            WHEN ''2'' THEN mt.in_hospital_cd_a2
            WHEN ''3'' THEN mt.in_hospital_cd_a3
            WHEN ''4'' THEN mt.in_hospital_cd_a4
          END
        WHEN mt.in_hosp_a_startdate < mt.in_hosp_b_startdate THEN
          CASE ini_value.hosp_get_mst_treatment
            WHEN ''1'' THEN mt.in_hospital_cd_b1
            WHEN ''2'' THEN mt.in_hospital_cd_b2
            WHEN ''3'' THEN mt.in_hospital_cd_b3
            WHEN ''4'' THEN mt.in_hospital_cd_b4
          END
      END
    -- 治療日よりAの利用日開始日以降の場合
    WHEN om.treat_date::TIMESTAMP >= mt.in_hosp_a_startdate THEN
      CASE ini_value.hosp_get_mst_treatment
        WHEN ''1'' THEN mt.in_hospital_cd_a1
        WHEN ''2'' THEN mt.in_hospital_cd_a2
        WHEN ''3'' THEN mt.in_hospital_cd_a3
        WHEN ''4'' THEN mt.in_hospital_cd_a4
      END
    -- 治療日よりBの利用日開始日以降の場合
    WHEN om.treat_date::TIMESTAMP >= mt.in_hosp_b_startdate THEN
      CASE ini_value.hosp_get_mst_treatment
        WHEN ''1'' THEN mt.in_hospital_cd_b1
        WHEN ''2'' THEN mt.in_hospital_cd_b2
        WHEN ''3'' THEN mt.in_hospital_cd_b3
        WHEN ''4'' THEN mt.in_hospital_cd_b4
      END
    ELSE NULL
  END AS hosp_cd,
  1 AS amount,
  COALESCE(ini_value.treat_item_unit, '''') AS unit,
  FLOOR(EXTRACT(epoch FROM (date_trunc(''minute'', om.rst_end_date) - date_trunc(''minute'', om.rst_start_date))) / 60) AS dialysis_time
FROM
  do_ord_main om
INNER JOIN mst_treatment AS mt ON mt.treatment_cd = om.rst_treatment_cd
  AND mt.facility_cd = @facilityCd
CROSS JOIN ini_value
)
, ind_treatment AS (
SELECT
  CASE ini_value.treat_convert
    WHEN ''0'' THEN tre.hosp_cd
    WHEN ''1'' THEN tc.convert_cd
  END AS hosp_cd,
  tre.amount AS amount,
  tre.unit AS unit,
  NULL AS proc_cd
FROM
  ord_main_tre tre
LEFT JOIN treat_convert tc ON tc.hosp_cd = tre.hosp_cd
AND tre.dialysis_time BETWEEN tc.lower_bound AND tc.upper_bound
CROSS JOIN ini_value
)
, ind_dialyzer AS (
-- ダイアライザ
SELECT
  20000000 AS temp_no,
  (om.rst_cond_info->''5''->>''value'')::integer AS mst_cd,
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
  do_ord_main om
INNER JOIN mst_dialyzer AS mst ON mst.dialyzer_cd::text = om.rst_cond_info ->''5''->>''value''
  AND mst.facility_cd = @facilityCd
CROSS JOIN ini_value
)
, ind_adsorption AS (
-- 吸着カラム
SELECT
  21000000 AS temp_no,
  (om.rst_cond_info->''6''->>''value'')::integer AS mst_cd,
  21000000 AS meq_class_code_order,
  21000000 AS meq_code_order,
  CASE ini_value.hosp_get_mst_equipment
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd,
  1 AS amount,
  ini_unit_equip.value AS unit
FROM
  do_ord_main om
INNER JOIN mst_equipment AS mst ON mst.equipment_cd::text = om.rst_cond_info->''6''->>''value''
  AND mst.facility_cd = @facilityCd
LEFT OUTER JOIN mst_equip AS meq ON meq.equipment_cd = TO_NUMBER(om.rst_cond_info->''6''->>''value'', ''FM999999999999'')
LEFT OUTER JOIN mst_equipment_class AS meqc ON meqc.class_cd = meq.class_cd
  AND meqc.facility_cd = @facilityCd
LEFT JOIN ini_unit_equip ON mst.unit = ini_unit_equip.key2
CROSS JOIN ini_value
)
, ind_coagulant AS (
-- 抗凝固剤
SELECT
  CASE
    WHEN COALESCE(om.rst_cond_info->''25''->> ''value'', '''') = '''' THEN NULL
    ELSE
      CASE om.rst_cond_info->''25''->> ''medicine_type''
        WHEN ''1'' THEN 30000000
        WHEN ''2'' THEN 30000000 + mst_mix.idx
      END
  END AS temp_no,
  CASE om.rst_cond_info -> ''25'' ->>''medicine_type''
    WHEN ''1'' THEN (om.rst_cond_info->''25''->>''value'')::integer
    WHEN ''2'' THEN mst_mix.medi_cd
  END AS mst_cd,
  30000000 AS medicine_type,
  30000000 AS timing_code_order,
  30000000 AS procedure_code_order,
  30000000 AS interval_no,
  CASE
    WHEN COALESCE(om.rst_cond_info->''25''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE om.rst_cond_info->''25''->>''medicine_type''
        WHEN ''1'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_medi.in_hospital_cd_1
            WHEN ''2'' THEN mst_medi.in_hospital_cd_2
            WHEN ''3'' THEN mst_medi.in_hospital_cd_3
            WHEN ''4'' THEN mst_medi.in_hospital_cd_4
            ELSE NULL
          END
        WHEN ''2'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_mix.in_hospital_cd_1
            WHEN ''2'' THEN mst_mix.in_hospital_cd_2
            WHEN ''3'' THEN mst_mix.in_hospital_cd_3
            WHEN ''4'' THEN mst_mix.in_hospital_cd_4
            ELSE NULL
          END
      END
  END AS hosp_cd,
  CASE
    WHEN COALESCE(om.rst_cond_info->''25''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE om.rst_cond_info->''25''->>''medicine_type''
        WHEN ''1'' THEN (om.rst_cond_info->''26''->>''value'')::NUMERIC + (om.rst_cond_info->''28''->>''value'')::NUMERIC
        WHEN ''2'' THEN 
          CASE mst_mix.solvent
            WHEN ''0'' THEN
              ((om.rst_cond_info->''26''->>''value'')::NUMERIC 
              + (om.rst_cond_info->''28''->>''value'')::NUMERIC) * mst_mix.amount::NUMERIC
            WHEN ''1'' THEN mst_mix.amount::NUMERIC
          END
      END
  END AS amount,
  CASE
    WHEN COALESCE(om.rst_cond_info->''25''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE om.rst_cond_info->''25''->>''medicine_type''
        WHEN ''1'' THEN 
          iumedi.value
        WHEN ''2'' THEN 
          iumix.value
      END
  END AS unit
FROM
  do_ord_main om
LEFT JOIN mst_medicine AS mst_medi ON mst_medi.medicine_cd::text = om.rst_cond_info->''25''->>''value''
  AND mst_medi.facility_cd = @facilityCd
  AND mst_medi.is_shot = ''0''
  AND mst_medi.is_del = ''0''
  AND mst_medi.is_disp = ''1''
  AND om.rst_cond_info->''25''->>''medicine_type''::text = ''1''
LEFT JOIN ini_unit_medi AS iumedi ON mst_medi.unit = iumedi.key2
LEFT JOIN mst_medi_mix AS mst_mix ON mst_mix.mix_cd::text = om.rst_cond_info->''25''->>''value''
  AND om.rst_cond_info->''25''->>''medicine_type''::text = ''2''
LEFT JOIN ini_unit_medi AS iumix ON mst_mix.unit = iumix.key2
CROSS JOIN ini_value
)
, ind_touseki AS (
-- 透析液
SELECT
  31000000 AS temp_no,
  (om.rst_cond_info->''15''->>''value'')::integer AS mst_cd,
  31000000 AS medi_code_order,
  31000000 AS medi_class_code_order,
  31000000 AS medicine_type,
  31000000 AS timing_code_order,
  31000000 AS procedure_code_order,
  31000000 AS interval_no,
  CASE
    WHEN COALESCE(om.rst_cond_info->''15''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE om.rst_cond_info->''15''->>''medicine_type''
        WHEN ''1'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_medi.in_hospital_cd_1
            WHEN ''2'' THEN mst_medi.in_hospital_cd_2
            WHEN ''3'' THEN mst_medi.in_hospital_cd_3
            WHEN ''4'' THEN mst_medi.in_hospital_cd_4
            ELSE NULL
          END
        WHEN ''2'' THEN 
          CASE ini_value.hosp_get_mst_medicine
                  WHEN ''1'' THEN mst_mix.in_hospital_cd_1
            WHEN ''2'' THEN mst_mix.in_hospital_cd_2
            WHEN ''3'' THEN mst_mix.in_hospital_cd_3
            WHEN ''4'' THEN mst_mix.in_hospital_cd_4
            ELSE NULL
          END
      END
  END AS hosp_cd,
  CASE
    WHEN COALESCE(om.rst_cond_info->''15''->>''value'', '''') = '''' THEN NULL
    ELSE
        (om.rst_cond_info->''17''->>''value'')::NUMERIC
  END AS amount,
  CASE
    WHEN COALESCE(om.rst_cond_info->''15''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE om.rst_cond_info->''15''->>''medicine_type''
        WHEN ''1'' THEN 
          iumedi.value
        WHEN ''2'' THEN 
          iumix.value
      END
  END AS unit
FROM
  do_ord_main om
LEFT JOIN mst_medicine AS mst_medi ON mst_medi.medicine_cd::text = om.rst_cond_info->''15''->>''value''
  AND mst_medi.facility_cd = @facilityCd
  AND mst_medi.is_shot = ''0''
  AND mst_medi.is_del = ''0''
  AND mst_medi.is_disp = ''1''
  AND om.rst_cond_info->''15''->>''medicine_type''::text = ''1''
LEFT JOIN ini_unit_medi AS iumedi ON mst_medi.unit = iumedi.key2
LEFT JOIN mst_medi_mix AS mst_mix ON mst_mix.mix_cd::text = om.rst_cond_info->''15''->>''value''
  AND om.rst_cond_info->''15''->>''medicine_type''::text = ''2''
LEFT JOIN ini_unit_medi AS iumix ON mst_mix.unit = iumix.key2
CROSS JOIN ini_value
)
, ind_hoeki AS (
-- 補液
SELECT
  32000000 AS temp_no,
  (om.rst_cond_info->''19''->>''value'')::integer AS mst_cd,
  32000000 AS medi_code_order,
  32000000 AS medi_class_code_order,
  32000000 AS medicine_type,
  32000000 AS timing_code_order,
  32000000 AS procedure_code_order,
  32000000 AS interval_no,  
  CASE
    WHEN COALESCE(om.rst_cond_info->''19''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE om.rst_cond_info->''19''->>''medicine_type''
        WHEN ''1'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_medi.in_hospital_cd_1
            WHEN ''2'' THEN mst_medi.in_hospital_cd_2
            WHEN ''3'' THEN mst_medi.in_hospital_cd_3
            WHEN ''4'' THEN mst_medi.in_hospital_cd_4
            ELSE NULL
          END
        WHEN ''2'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_mix.in_hospital_cd_1
            WHEN ''2'' THEN mst_mix.in_hospital_cd_2
            WHEN ''3'' THEN mst_mix.in_hospital_cd_3
            WHEN ''4'' THEN mst_mix.in_hospital_cd_4
            ELSE NULL
          END
      END
  END AS hosp_cd,
  CASE
    WHEN COALESCE(om.rst_cond_info->''19''->>''value'', '''') = '''' THEN NULL
    ELSE
      (om.rst_cond_info->''22''->>''value'')::NUMERIC
  END AS amount,
  CASE
    WHEN COALESCE(om.rst_cond_info->''19''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE om.rst_cond_info->''19''->>''medicine_type''
        WHEN ''1'' THEN 
          iumedi.value
        WHEN ''2'' THEN 
          iumix.value
      END
  END AS unit
FROM
  do_ord_main om
LEFT JOIN mst_medicine AS mst_medi ON mst_medi.medicine_cd::text = om.rst_cond_info->''19''->>''value''
  AND mst_medi.facility_cd = @facilityCd
  AND mst_medi.is_shot = ''0''
  AND mst_medi.is_del = ''0''
  AND mst_medi.is_disp = ''1''
  AND om.rst_cond_info->''19''->>''medicine_type''::text = ''1''
LEFT JOIN ini_unit_medi AS iumedi ON mst_medi.unit = iumedi.key2
LEFT JOIN mst_medi_mix AS mst_mix ON mst_mix.mix_cd::text = om.rst_cond_info->''19''->>''value''
  AND om.rst_cond_info->''19''->>''medicine_type''::text = ''2''
LEFT JOIN ini_unit_medi AS iumix ON mst_mix.unit = iumix.key2
CROSS JOIN ini_value
)
, ind_one_film AS (
-- 1次膜
SELECT
  22000000 AS temp_no,
  (om.rst_cond_info->''7''->>''value'')::integer AS mst_cd,
  22000000 AS meq_class_code_order,
  22000000 AS meq_code_order,
  CASE ini_value.hosp_get_mst_equipment
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd,
  1 AS amount,
  ini_unit_equip.value AS unit
FROM
  do_ord_main om
INNER JOIN mst_equipment AS mst ON mst.equipment_cd::text = om.rst_cond_info->''7''->>''value''
  AND mst.facility_cd = @facilityCd
LEFT OUTER JOIN mst_equip AS meq ON
  meq.equipment_cd = TO_NUMBER(om.rst_cond_info->''7''->>''value'', ''FM999999999999'')
LEFT OUTER JOIN mst_equipment_class AS meqc ON meqc.class_cd = meq.class_cd
  AND meqc.facility_cd = @facilityCd
LEFT JOIN ini_unit_equip ON mst.unit = ini_unit_equip.key2
CROSS JOIN ini_value
)
, ind_two_film AS (
-- 2次膜
SELECT
  23000000 AS temp_no,
  (om.rst_cond_info->''8''->>''value'')::integer AS mst_cd,
  23000000 AS meq_class_code_order,
  23000000 AS meq_code_order,
  CASE ini_value.hosp_get_mst_equipment
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd,
  1 AS amount,
  ini_unit_equip.value AS unit
FROM
  do_ord_main om
INNER JOIN mst_equipment AS mst ON mst.equipment_cd::text = om.rst_cond_info->''8''->>''value''
  AND mst.facility_cd = @facilityCd
LEFT OUTER JOIN mst_equip AS meq ON meq.equipment_cd = TO_NUMBER(om.rst_cond_info->''8''->>''value'', ''FM999999999999'')
LEFT OUTER JOIN mst_equipment_class AS meqc ON meqc.class_cd = meq.class_cd
  AND meqc.facility_cd = @facilityCd
LEFT JOIN ini_unit_equip ON mst.unit = ini_unit_equip.key2
CROSS JOIN ini_value
)
, medi_indo AS (
-- 投与薬剤情報
SELECT
  33000000 + t1.idx AS temp_no,
  CASE t1.medi_info ->> ''medicine_type''
    WHEN ''1'' THEN (t1.medi_info ->> ''cd'')::integer 
    WHEN ''2'' THEN mst_mix.medi_cd
  END AS mst_cd,
  (t1.medi_info ->> ''medicine_type'')::integer AS medicine_type,
  (t1.medi_info ->> ''timing_cd'')::integer AS timing_cd,
  (t1.medi_info ->> ''procedure_cd'')::integer AS procedure_cd,
  (t1.medi_info ->> ''date_interval'')::integer AS interval_no,
  om.treat_date::TIMESTAMP AS treat_date,
  CASE
    WHEN json_array_length(om.rst_medi_info::json) = 0 THEN NULL
    ELSE
      CASE t1.medi_info ->> ''medicine_type''
        WHEN ''1'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_medi.in_hospital_cd_1
            WHEN ''2'' THEN mst_medi.in_hospital_cd_2
            WHEN ''3'' THEN mst_medi.in_hospital_cd_3
            WHEN ''4'' THEN mst_medi.in_hospital_cd_4
            ELSE NULL
          END
        WHEN ''2'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_mix.in_hospital_cd_1
            WHEN ''2'' THEN mst_mix.in_hospital_cd_2
            WHEN ''3'' THEN mst_mix.in_hospital_cd_3
            WHEN ''4'' THEN mst_mix.in_hospital_cd_4
            ELSE NULL
          END
      END
  END AS hosp_cd,
  CASE
    WHEN json_array_length(om.rst_medi_info::json) = 0 THEN NULL
    ELSE
      CASE t1.medi_info ->> ''medicine_type''
        WHEN ''1'' THEN TRUNC((medi_info ->> ''amount'')::NUMERIC, 4)
        WHEN ''2'' THEN
          CASE mst_mix.solvent
            WHEN ''0'' THEN
              TRUNC((medi_info ->> ''amount'')::NUMERIC * mst_mix.amount::NUMERIC, 4)
            WHEN ''1'' THEN
              TRUNC(mst_mix.amount::NUMERIC, 4)
          END
        ELSE 0
      END
  END AS amount,
  CASE
    WHEN json_array_length(om.rst_medi_info::json) = 0 THEN NULL
    ELSE
      CASE t1.medi_info ->> ''medicine_type''
        WHEN ''1'' THEN 
          iumedi.value
        WHEN ''2'' THEN 
          iumix.value
      END
  END AS unit,
  CASE
    WHEN json_array_length(om.rst_medi_info::json) = 0 THEN NULL
    ELSE
      CASE t1.medi_info ->> ''medicine_type''
        WHEN ''1'' THEN mst_medi.is_shot
        WHEN ''2'' THEN mst_mix.is_shot
      END
  END AS is_shot
FROM
  do_ord_main om
CROSS JOIN LATERAL json_array_elements(om.rst_medi_info::json) WITH ORDINALITY AS t1(medi_info, idx)
LEFT JOIN mst_medicine AS mst_medi ON mst_medi.medicine_cd::text = medi_info ->> ''cd''
  AND medi_info ->> ''medicine_type''::text = ''1''
  AND mst_medi.facility_cd = @facilityCd
  AND mst_medi.is_del = ''0''
  AND mst_medi.is_disp = ''1''
LEFT JOIN ini_unit_medi AS iumedi ON mst_medi.unit = iumedi.key2
LEFT JOIN mst_medi_mix AS mst_mix ON mst_mix.mix_cd::text = medi_info ->> ''cd''
  AND medi_info ->> ''medicine_type''::text = ''2''
LEFT JOIN ini_unit_medi AS iumix ON mst_mix.unit = iumix.key2
CROSS JOIN ini_value
WHERE
  medi_info ->> ''effect_flg''::text = ''1''
)
, treatment_info AS (
-- 愁訴処置情報
SELECT
  50000000 + t1.idx AS temp_no,
  CASE
    WHEN t1.tre_info ->> ''treat_class'' = ''3''
      AND t1.tre_info ->> ''oxygen_amount'' IS NOT NULL
      AND ini_value.oxgen_medi_code <> ''''
      AND ini_value.oxgen_procedure_code <> '''' THEN
      -9999
    else
    	CASE (t1.tre_info ->> ''medicine_type'')
		    WHEN ''1'' THEN (t1.tre_info ->> ''treat_medicine_cd'')::integer
		    WHEN ''2'' THEN mst_mix.medi_cd
      	END
  END AS mst_cd,
  (t1.tre_info ->> ''medicine_type'')::integer AS medicine_type,
  NULL::integer AS timing_cd,
  CASE
    WHEN t1.tre_info ->> ''treat_class'' = ''3''
      AND t1.tre_info ->> ''oxygen_amount'' IS NOT NULL
      AND ini_value.oxgen_medi_code <> ''''
      AND ini_value.oxgen_procedure_code <> '''' THEN
      -9999
    ELSE
      (t1.tre_info ->> ''procedure_cd'')::integer
  END AS procedure_cd,
  NULL::integer AS interval_no,
  om.treat_date::TIMESTAMP AS treat_date,
  CASE
    WHEN json_array_length(om.rst_treatment_info::json) = 0 THEN NULL
    WHEN t1.tre_info ->> ''treat_class'' = ''3''
      AND t1.tre_info ->> ''oxygen_amount'' IS NOT NULL
      AND ini_value.oxgen_medi_code <> ''''
      AND ini_value.oxgen_procedure_code <> '''' THEN
      ini_value.oxgen_medi_code
    ELSE
      CASE t1.tre_info ->> ''medicine_type''
        WHEN ''1'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_medi.in_hospital_cd_1
            WHEN ''2'' THEN mst_medi.in_hospital_cd_2
            WHEN ''3'' THEN mst_medi.in_hospital_cd_3
            WHEN ''4'' THEN mst_medi.in_hospital_cd_4
            ELSE NULL
          END
        WHEN ''2'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_mix.in_hospital_cd_1
            WHEN ''2'' THEN mst_mix.in_hospital_cd_2
            WHEN ''3'' THEN mst_mix.in_hospital_cd_3
            WHEN ''4'' THEN mst_mix.in_hospital_cd_4
            ELSE NULL
          END
      END
  END AS hosp_cd,
  CASE
    WHEN json_array_length(om.rst_treatment_info::json) = 0 THEN NULL
    WHEN t1.tre_info ->> ''treat_class'' = ''3''
      AND t1.tre_info ->> ''oxygen_amount'' IS NOT NULL
      AND ini_value.oxgen_medi_code <> ''''
      AND ini_value.oxgen_procedure_code <> '''' THEN
        (t1.tre_info ->> ''oxygen_amount'')::NUMERIC
    ELSE
      CASE t1.tre_info ->> ''medicine_type''
        WHEN ''1'' THEN TRUNC((t1.tre_info ->> ''amount'')::NUMERIC, 4)
        WHEN ''2'' THEN
          CASE mst_mix.solvent
            WHEN ''0'' THEN
              TRUNC((t1.tre_info ->> ''amount'')::NUMERIC * mst_mix.amount::NUMERIC, 4)
            WHEN ''1'' THEN
              TRUNC(mst_mix.amount::NUMERIC, 4)
          END
        ELSE 0
      END
  END AS amount,
  CASE
    WHEN json_array_length(om.rst_treatment_info::json) = 0 THEN NULL
    WHEN t1.tre_info ->> ''treat_class'' = ''3''
      AND t1.tre_info ->> ''oxygen_amount'' IS NOT NULL
      AND ini_value.oxgen_medi_code <> ''''
      AND ini_value.oxgen_procedure_code <> '''' THEN
      COALESCE((SELECT value FROM ini_unit_equip WHERE key2 = ''L''), (SELECT value FROM ini_unit_medi WHERE key2 = ''L''), '''')
    ELSE
      CASE t1.tre_info ->> ''medicine_type''
        WHEN ''1'' THEN
          iumedi.value
        WHEN ''2'' THEN
          iumix.value
      END
  END AS unit,
  CASE
    WHEN json_array_length(om.rst_treatment_info::json) = 0 THEN NULL
    WHEN t1.tre_info ->> ''treat_class'' = ''3''
      AND t1.tre_info ->> ''oxygen_amount'' IS NOT NULL
      AND ini_value.oxgen_medi_code <> ''''
      AND ini_value.oxgen_procedure_code <> '''' THEN
        ''0''
    ELSE
      CASE t1.tre_info ->> ''medicine_type''
        WHEN ''1'' THEN mst_medi.is_shot
        WHEN ''2'' THEN mst_mix.is_shot
      END
  END AS is_shot
FROM
  do_ord_main om
CROSS JOIN LATERAL json_array_elements(om.rst_treatment_info::json) WITH ORDINALITY AS t1(tre_info, idx)
LEFT JOIN mst_medicine AS mst_medi ON mst_medi.medicine_cd::text = t1.tre_info ->> ''treat_medicine_cd''
  AND mst_medi.facility_cd = @facilityCd
  AND mst_medi.is_shot = ''0''
  AND mst_medi.is_del = ''0''
  AND mst_medi.is_disp = ''1''
  AND t1.tre_info ->> ''medicine_type''::text = ''1''
LEFT JOIN ini_unit_medi AS iumedi ON mst_medi.unit = iumedi.key2
LEFT JOIN mst_medi_mix AS mst_mix ON mst_mix.mix_cd::text = t1.tre_info ->> ''treat_medicine_cd''
  AND t1.tre_info ->> ''medicine_type''::text = ''2''
LEFT JOIN ini_unit_medi AS iumix ON mst_mix.unit = iumix.key2
CROSS JOIN ini_value
)
, ind_equip_info AS (
-- 医療材料コード
SELECT
  24000000 + t1.idx AS temp_no,
  (t1.equip_info ->> ''cd'')::integer AS mst_cd,
  24000000 + meq.meq_class_code_order AS meq_class_code_order,
  24000000 + meq.meq_code_order AS meq_code_order,
  CASE ini_value.hosp_get_mst_equipment
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd,
  CAST(t1.equip_info->>''amount'' AS NUMERIC) AS amount,
  ini_unit_equip.value AS unit
FROM
  do_ord_main om
CROSS JOIN LATERAL json_array_elements(om.rst_equip_info::json) WITH ORDINALITY AS t1(equip_info, idx)
INNER JOIN mst_equipment AS mst ON mst.equipment_cd::text = t1.equip_info ->> ''cd''
  AND mst.facility_cd = @facilityCd
LEFT OUTER JOIN mst_equip AS meq ON
  meq.equipment_cd = TO_NUMBER(t1.equip_info ->> ''cd'', ''FM999999999999'')
LEFT OUTER JOIN mst_equipment_class AS meqc ON meqc.class_cd = meq.class_cd
  AND meqc.facility_cd = @facilityCd
LEFT JOIN ini_unit_equip ON mst.unit = ini_unit_equip.key2
CROSS JOIN ini_value
)
, dial_diff_info AS (
-- 透析困難コード
SELECT
  13000000 AS temp_no,
  CASE ini_value.hosp_get_mst_dia_diff
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    ELSE NULL
  END AS hosp_cd,
  1 AS amount,
  '''' AS unit
FROM
  auth_info ai
LEFT JOIN mst_dialysis_difficulty AS mst ON mst.dialysis_difficulty_cd::text = ai.dial_diff_cd
  AND mst.is_del = ''0''
  AND mst.facility_cd = @facilityCd
CROSS JOIN ini_value
WHERE
  ai.is_dial_diff = ''1''
)
, addition_info AS (
-- 加算情報
SELECT
  13000000 + t1.idx AS temp_no,
  (t1.addi_info ->> ''cd'')::integer AS mst_cd,
  CASE ini_value.hosp_get_mst_addition
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    ELSE NULL
  END AS hosp_cd,
  1 AS amount,
  CASE 
      WHEN mst.addition_class = ''2'' THEN (select dial_diff_comment_unit from ini_value)
      ELSE ''''
  END AS unit,
  mst.addition_class AS add_class
FROM
  do_ord_main om
LEFT JOIN LATERAL (
  SELECT x.elem, x.ord FROM do_ord_main om
  CROSS JOIN LATERAL jsonb_array_elements(om.addition_info) WITH ORDINALITY AS x(elem, ord)
  WHERE
    jsonb_typeof(om.addition_info) = ''array''
) AS t1(addi_info, idx) ON TRUE
LEFT JOIN mst_addition AS mst ON mst.addition_cd ::text = t1.addi_info ->> ''cd''
  AND mst.is_del = ''0''
  AND mst.facility_cd = @facilityCd
CROSS JOIN ini_value
)
, medi_union_1 AS (
-- 薬剤情報（抗凝固剤、透析液、補液、投与薬剤情報(手技なし)、愁訴処置情報（手技なし））
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
  (
  SELECT
    coa.temp_no AS temp_no,
    coa.medicine_type AS medicine_type,
    coa.timing_code_order AS timing_code_order,
    coa.procedure_code_order AS procedure_code_order,
    coa.interval_no AS interval_no,
    ''抗凝固剤'' AS title,
    coa.mst_cd AS mst_cd,
    30000000 + mst_medi.medi_code_order AS medi_code_order,
    30000000 + mst_medi.medi_class_code_order AS medi_class_code_order,
    coa.hosp_cd AS hosp_cd,
    COALESCE(coa.amount,0) AS amount,
    coa.unit AS unit
  FROM
    ind_coagulant coa
    LEFT JOIN mst_medi ON coa.mst_cd = mst_medi.medicine_cd
  WHERE
    coa.mst_cd IS NOT NULL
UNION ALL
  SELECT
    tou.temp_no AS temp_no,
    tou.medicine_type AS medicine_type,
    tou.timing_code_order AS timing_code_order,
    tou.procedure_code_order AS procedure_code_order,
    tou.interval_no AS interval_no,
    ''透析液'' AS title,
    tou.mst_cd AS mst_cd,
    tou.medi_code_order AS medi_code_order,
    tou.medi_class_code_order AS medi_class_code_order,
    tou.hosp_cd AS hosp_cd,
    COALESCE(tou.amount,0) AS amount,
    tou.unit AS unit
  FROM
    ind_touseki tou
  WHERE
    tou.mst_cd IS NOT NULL
UNION ALL
  SELECT
    hoe.temp_no AS temp_no,
    hoe.medicine_type AS medicine_type,
    hoe.timing_code_order AS timing_code_order,
    hoe.procedure_code_order AS procedure_code_order,
    hoe.interval_no AS interval_no,
    ''補液'' AS title,
    hoe.mst_cd AS mst_cd,
    hoe.medi_code_order AS medi_code_order,
    hoe.medi_class_code_order AS medi_class_code_order,
    hoe.hosp_cd AS hosp_cd,
    COALESCE(hoe.amount,0) AS amount,
    hoe.unit AS unit
  FROM
    ind_hoeki hoe
  WHERE
    hoe.mst_cd IS NOT NULL
UNION ALL
  SELECT
    MIN(pro_medi_table.temp_no) AS temp_no,
    MIN(pro_medi_table.medicine_type) AS medicine_type,
    MIN(pro_medi_table.timing_code_order) AS timing_code_order,
    MIN(pro_medi_table.procedure_code_order) AS procedure_code_order,
    MIN(pro_medi_table.interval_no) AS interval_no,
    MIN(pro_medi_table.title) AS title,
    MIN(pro_medi_table.mst_cd) AS mst_cd,
    MIN(pro_medi_table.medi_code_order) AS medi_code_order,
    MIN(pro_medi_table.medi_class_code_order) AS medi_class_code_order,
    pro_medi_table.hosp_cd AS hosp_cd,
    SUM(pro_medi_table.amount) AS amount,
    MIN(pro_medi_table.unit) AS unit
  FROM
  (
  SELECT
    imi.temp_no,
    33000000 + imi.medicine_type as medicine_type,
    33000000 + COALESCE(t.timing_code_order, 0) AS timing_code_order,
    33000000 + COALESCE(p.procedure_code_order, 0) AS procedure_code_order,
    33000000 + COALESCE(imi.interval_no, 0) AS interval_no,
    33000000 + COALESCE(mst_medi.medi_code_order, 0) AS medi_code_order,
    33000000 + COALESCE(mst_medi.medi_class_code_order, 0) AS medi_class_code_order,
    imi.mst_cd::integer AS mst_cd,
    imi.hosp_cd AS hosp_cd,
    imi.amount AS amount,
    imi.unit AS unit,
    imi.procedure_cd AS procedure_cd,
    imi.treat_date AS treat_date,
    ''投与薬剤情報(手技無し)'' AS title
  FROM
    medi_indo imi
  LEFT JOIN mst_medicine mm ON imi.mst_cd = mm.medicine_cd
  LEFT JOIN mst_medi ON mm.class_cd = mst_medi.class_cd AND mm.medicine_cd = mst_medi.medicine_cd
  LEFT JOIN timing_order t ON t.timing_code = imi.timing_cd
  LEFT JOIN procedure_order p ON p.procedure_code = imi.procedure_cd
  WHERE
    imi.mst_cd IS NOT NULL
    AND imi.is_shot = ''0''
  UNION ALL
  SELECT
    ti.temp_no,
    50000000 + ti.medicine_type as medicine_type,
    50000000 + COALESCE(t.timing_code_order, 0) AS timing_code_order,
    50000000 + COALESCE(p.procedure_code_order,0) AS procedure_code_order,
    50000000 + COALESCE(ti.interval_no, 0) AS interval_no,
    50000000 + COALESCE(mst_medi.medi_code_order, 0) AS medi_code_order,
    50000000 + COALESCE(mst_medi.medi_class_code_order, 0) AS medi_class_code_order,
    ti.mst_cd::integer AS mst_cd,
    ti.hosp_cd AS hosp_cd,
    ti.amount AS amount,
    ti.unit AS unit,
    ti.procedure_cd AS procedure_cd,
    ti.treat_date AS treat_date,
    ''愁訴処置情報(手技無し)'' AS title
  FROM
    treatment_info ti
  LEFT JOIN mst_medicine mm ON ti.mst_cd = mm.medicine_cd
  LEFT JOIN mst_medi ON mm.class_cd = mst_medi.class_cd AND mm.medicine_cd = mst_medi.medicine_cd
  LEFT JOIN timing_order t ON t.timing_code = ti.timing_cd
  LEFT JOIN procedure_order p ON p.procedure_code = ti.procedure_cd
  WHERE
    ti.mst_cd IS NOT NULL
    AND ti.is_shot = ''0''
  ) AS pro_medi_table
  LEFT JOIN mst_procedure mst ON mst.procedure_cd = pro_medi_table.procedure_cd AND mst.facility_cd = @facilityCd
  CROSS JOIN ini_value
  WHERE
    pro_medi_table.procedure_cd IS NULL
    OR (
      pro_medi_table.procedure_cd <> -9999
      AND NULLIF(
        CASE
          -- ▼治療日が A/B の両開始日を満たしている場合（より新しい方を優先）
          WHEN pro_medi_table.treat_date >= mst.in_hosp_a_startdate
            AND pro_medi_table.treat_date >= mst.in_hosp_b_startdate THEN
            CASE
              -- Aの方が新しければA系の施設CDを参照
              WHEN mst.in_hosp_a_startdate > mst.in_hosp_b_startdate THEN
                CASE ini_value.hosp_get_mst_procedure
                  WHEN ''1'' THEN mst.in_hospital_cd_a1
                  WHEN ''2'' THEN mst.in_hospital_cd_a2
                END
              -- Bの方が新しければB系の施設CDを参照
              WHEN mst.in_hosp_a_startdate < mst.in_hosp_b_startdate THEN
                CASE ini_value.hosp_get_mst_procedure
                  WHEN ''1'' THEN mst.in_hospital_cd_b1
                  WHEN ''2'' THEN mst.in_hospital_cd_b2
                END
            END
          -- ▼治療日がAの開始日だけを満たしている場合
          WHEN pro_medi_table.treat_date >= mst.in_hosp_a_startdate THEN
            CASE ini_value.hosp_get_mst_procedure
              WHEN ''1'' THEN mst.in_hospital_cd_a1
              WHEN ''2'' THEN mst.in_hospital_cd_a2
            END
          -- ▼治療日がBの開始日だけを満たしている場合
          WHEN pro_medi_table.treat_date >= mst.in_hosp_b_startdate THEN
            CASE ini_value.hosp_get_mst_procedure
              WHEN ''1'' THEN mst.in_hospital_cd_b1
              WHEN ''2'' THEN mst.in_hospital_cd_b2
            END
          -- ▼どちらの開始日も満たしていない、またはNULL含む場合
          ELSE NULL
        END
        , '''') IS NULL
    )
  GROUP BY
    pro_medi_table.hosp_cd
) AS ind_medi_table
CROSS JOIN do_ord_main om
CROSS JOIN ini_value
ORDER BY
  sort_num
)
, pro_medi_table AS (
  SELECT 
    t.*,
    m.pricedure_name AS pro_title,
    CASE
      WHEN t.procedure_cd = -9999 THEN
        ini_value.oxgen_procedure_code
      WHEN ((t.treat_date >= m.in_hosp_a_startdate)
        AND (t.treat_date >= m.in_hosp_b_startdate)) THEN
        CASE
          WHEN m.in_hosp_a_startdate > m.in_hosp_b_startdate THEN
            CASE ini_value.hosp_get_mst_procedure
              WHEN ''1'' THEN m.in_hospital_cd_a1
              WHEN ''2'' THEN m.in_hospital_cd_a2
            END
          WHEN m.in_hosp_a_startdate < m.in_hosp_b_startdate THEN
            CASE ini_value.hosp_get_mst_procedure
              WHEN ''1'' THEN m.in_hospital_cd_b1
              WHEN ''2'' THEN m.in_hospital_cd_b2
            END
        END
      WHEN t.treat_date >= m.in_hosp_a_startdate THEN
        CASE ini_value.hosp_get_mst_procedure
          WHEN ''1'' THEN m.in_hospital_cd_a1
          WHEN ''2'' THEN m.in_hospital_cd_a2
        END
      WHEN t.treat_date >= m.in_hosp_b_startdate THEN
        CASE ini_value.hosp_get_mst_procedure
          WHEN ''1'' THEN m.in_hospital_cd_b1
          WHEN ''2'' THEN m.in_hospital_cd_b2
        END
      ELSE NULL
    END AS pro_hosp_cd
  FROM (
    SELECT
        imi.temp_no,
        33000000 + imi.medicine_type as medicine_type,
        33000000 + coalesce(t.timing_code_order, 0) AS timing_code_order,
        33000000 + coalesce(p.procedure_code_order, 0) AS procedure_code_order,
        33000000 + coalesce(imi.interval_no, 0) AS interval_no,
        33000000 + coalesce(mst_medi.medi_code_order, 0) AS medi_code_order,
        33000000 + coalesce(mst_medi.medi_class_code_order, 0) AS medi_class_code_order,
        imi.mst_cd::integer AS mst_cd,
        imi.hosp_cd AS hosp_cd,
        imi.amount AS amount,
        imi.unit AS unit,
        imi.procedure_cd AS procedure_cd,
        imi.treat_date AS treat_date,
        ''投与薬剤情報(手技有り)'' AS title
    FROM
      medi_indo imi
    LEFT JOIN mst_medicine mm ON imi.mst_cd = mm.medicine_cd
    LEFT JOIN mst_medi ON mm.class_cd = mst_medi.class_cd AND mm.medicine_cd = mst_medi.medicine_cd
    LEFT JOIN timing_order t ON t.timing_code = imi.timing_cd
    LEFT JOIN procedure_order p ON p.procedure_code = imi.procedure_cd
    WHERE
      imi.mst_cd IS NOT NULL
      AND imi.is_shot = ''0''
  UNION ALL
    SELECT
        ti.temp_no,
        50000000 + ti.medicine_type as medicine_type,
        50000000 + coalesce(t.timing_code_order, 0) AS timing_code_order,
        50000000 + coalesce(p.procedure_code_order, 0) AS procedure_code_order,
        50000000 + coalesce(ti.interval_no, 0) AS interval_no,
        50000000 + coalesce(mst_medi.medi_code_order, 0) AS medi_code_order,
        50000000 + coalesce(mst_medi.medi_class_code_order, 0) AS medi_class_code_order,
        ti.mst_cd::integer AS mst_cd,
        ti.hosp_cd AS hosp_cd,
        ti.amount AS amount,
        ti.unit AS unit,
        ti.procedure_cd AS procedure_cd,
        ti.treat_date AS treat_date,
        ''愁訴処置情報(手技有り)'' AS title
    FROM
      treatment_info ti
    LEFT JOIN mst_medicine mm ON ti.mst_cd = mm.medicine_cd
    LEFT JOIN mst_medi ON mm.class_cd = mst_medi.class_cd AND mm.medicine_cd = mst_medi.medicine_cd
    LEFT JOIN timing_order t ON t.timing_code = ti.timing_cd
    LEFT JOIN procedure_order p ON p.procedure_code = ti.procedure_cd
    WHERE
      ti.mst_cd IS NOT NULL
      AND ti.is_shot = ''0''
      ) t
  CROSS JOIN ini_value
  LEFT JOIN mst_procedure m ON m.procedure_cd = t.procedure_cd AND m.facility_cd = @facilityCd
)
, medi_union_2 AS (
-- 投与薬剤情報(手技あり)、愁訴処置情報（手技あり）
SELECT
    p.temp_no AS temp_no,
    p.medicine_type AS medicine_type,
    p.timing_code_order AS timing_code_order,
    p.procedure_code_order AS procedure_code_order,
    p.interval_no AS interval_no,
    p.medi_code_order AS medi_code_order,
    p.medi_class_code_order AS medi_class_code_order,
    p.mst_cd AS mst_cd,
    p.hosp_cd AS hosp_cd,
    p.amount AS amount,
    p.unit AS unit,
    p.title AS title,
    p.procedure_cd AS procedure_cd,
    p.pro_hosp_cd AS pro_hosp_cd,
  CASE
    WHEN p.procedure_cd = -9999 THEN true
    ELSE false
  END AS oxgen_flg
FROM
  pro_medi_table p
WHERE
  (SELECT medicine_send_type::NUMERIC FROM ini_value) = 0
  AND procedure_cd IS NOT NULL
UNION ALL
SELECT
    MIN(p.temp_no) AS temp_no,
    MIN(p.medicine_type) AS medicine_type,
    MIN(p.timing_code_order) AS timing_code_order,
    MIN(p.procedure_code_order) AS procedure_code_order,
    MIN(p.interval_no) AS interval_no,
    MIN(p.medi_code_order) AS medi_code_order,
    MIN(p.medi_class_code_order) AS medi_class_code_order,
    MIN(p.mst_cd) AS mst_cd,
    p.hosp_cd,
    SUM(p.amount) AS amount,
    MIN(p.unit) AS unit,    
    MIN(p.title) AS title,
    MIN(p.procedure_cd) AS procedure_cd,
    p.pro_hosp_cd,
  CASE
    WHEN MIN(p.procedure_cd) = -9999 THEN true
    ELSE false
  END AS oxgen_flg
FROM
  pro_medi_table p
WHERE
  (SELECT medicine_send_type::NUMERIC FROM ini_value) = 1
  AND procedure_cd IS NOT NULL
GROUP BY
  pro_hosp_cd,
  hosp_cd
order by pro_hosp_cd
)
, medi_union_2_with_sorted AS (
    select 
    title,
    mst_cd,
    hosp_cd,
    amount,
    unit,
    procedure_cd,
    pro_hosp_cd,
    oxgen_flg,
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
        ) AS in_grp_rank
    from medi_union_2
    order by in_grp_rank
)
, group_scored AS (
  SELECT
    r.*,
    -- 各グループ（pro_hosp_cd）に属する行の中で最小の in_grp_rank をグループの「強さ」として採用
    -- → グループ内で一番上位に来る要素の順位をグループ全体の強さの代表値とする
    MIN(in_grp_rank) OVER (PARTITION BY pro_hosp_cd) AS grp_strength
  FROM medi_union_2_with_sorted r
)
, with_grp_order AS (
  SELECT
    g.*,
    -- grp_strength が若い（= グループの代表+順位が高い）ほど強いとみなし、グループに順位を付与
    -- → 強いグループから順に DENSE_RANK() を振る
    DENSE_RANK() OVER (ORDER BY grp_strength) AS grp_rank_by_strength
  FROM group_scored g
)
, procedure_medi_sorted AS (
-- 薬剤ごとに出力する場合は施設設定マスタの並び順をそのまま出力
  select 
    title,
    mst_cd,
    hosp_cd,
    amount,
    unit,
    procedure_cd,
    pro_hosp_cd,
    oxgen_flg,
    in_grp_rank as sort_num
  from medi_union_2_with_sorted
  cross join ini_value
  where ini_value.medicine_send_type = ''0''
  union all
-- 手技でまとめる場合はgroup_scored、with_grp_orderの処理結果を出力
  SELECT
    title,
    mst_cd,
    hosp_cd,
    amount,
    unit,
    procedure_cd,
    pro_hosp_cd,
    oxgen_flg,
    -- グループ順位 × 大きな係数 + グループ内順位 で全体のソートキーを生成
    (grp_rank_by_strength * 1000000) + in_grp_rank AS sort_num
  FROM with_grp_order
  cross join ini_value
  where ini_value.medicine_send_type = ''1''
  ORDER BY sort_num
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
  DISTINCT ON
  (un.hosp_cd) un.hosp_cd AS hosp_cd,
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
ORDER BY
  un.r_num
)
, union_table AS (
-- 全項目をUNION ALL
SELECT
  ''治療方法'' AS title,
  tre.hosp_cd AS hosp_cd,
  tre.amount AS amount,
  tre.unit AS unit,
  NULL AS proc_cd,
  NULL AS add_class,
  false AS oxgen_flg
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
  NULL AS proc_cd,
  NULL AS add_class,
  false AS oxgen_flg
FROM
  dial_diff_info ddi
WHERE
  ddi.hosp_cd IS NOT NULL
UNION ALL
SELECT
  ''加算情報(加算項目)'' AS title,
  ai.hosp_cd AS hosp_cd,
  ai.amount AS amount,
  ai.unit AS unit,
  NULL AS proc_cd,
  NULL AS add_class,
  false AS oxgen_flg
FROM
  addition_info ai
WHERE
  CASE
      WHEN ai.add_class = ''13'' THEN false --慢性維持透析患者外来医学管理料
      WHEN ai.add_class = ''12'' --汎用
        AND ai.hosp_cd = ANY (select set_value from addition_cd_list)
        then false
      ELSE true
      END
  AND ai.hosp_cd IS NOT NULL
UNION ALL
  SELECT
    ''ダイアライザ'' AS title,
    dia.hosp_cd AS hosp_cd,
    dia.amount AS amount,
    dia.unit AS unit,
    NULL AS proc_cd,
    NULL AS add_class,
    false AS oxgen_flg
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
    NULL AS proc_cd,
    NULL AS add_class,
    false AS oxgen_flg
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
    NULL AS proc_cd,
    NULL AS add_class,
    false AS oxgen_flg
  FROM
    medi_union_1 mu1
  WHERE
    mu1.hosp_cd IS NOT NULL
UNION ALL
  SELECT
    ''加算情報(医学管理科)'' AS title,
    ai.hosp_cd AS hosp_cd,
    ai.amount AS amount,
    ai.unit AS unit,
    NULL AS proc_cd,
    ai.add_class AS add_class,
    false AS oxgen_flg
  FROM
    addition_info ai
  WHERE
    CASE
      WHEN ai.add_class = ''13'' THEN true --慢性維持透析患者外来医学管理料
      WHEN ai.add_class = ''12'' --汎用
        AND ai.hosp_cd = ANY (select set_value from addition_cd_list)
        then true
      ELSE false
      END
    AND ai.hosp_cd IS NOT NULL
UNION ALL
  SELECT
    pms.title AS title,
    pms.hosp_cd AS hosp_cd,
    pms.amount AS amount,
    pms.unit AS unit,
    pms.pro_hosp_cd AS proc_cd,
    NULL AS add_class,
    pms.oxgen_flg AS oxgen_flg
  FROM
    procedure_medi_sorted pms
  WHERE
    pms.hosp_cd IS NOT NULL
    AND NULLIF(pms.pro_hosp_cd, '''') IS NOT NULL
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
  n.add_class,
  n.oxgen_flg,
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
  n.add_class,
  n.oxgen_flg,
  CASE
    WHEN n.proc_cd IS NOT NULL AND NOT (n.proc_cd = ANY(r.proc_cd_list)) THEN r.RP + 1
    WHEN r.RpItem >= 20 OR (m.medicine_send_type::NUMERIC = 0
      AND n.proc_cd IS NOT NULL) THEN r.RP + 1
    WHEN r.RpItem >= 20 OR n.proc_cd IS NULL
      AND n.add_class IS NOT NULL THEN r.RP + 1
    ELSE r.RP
  END AS RP,
  CASE
    WHEN ((n.proc_cd IS NOT NULL AND NOT (n.proc_cd = ANY(r.proc_cd_list)))
      OR (r.RpItem >= 20
      OR (m.medicine_send_type::NUMERIC = 0
      AND n.proc_cd IS NOT NULL))) THEN 2
    WHEN r.RpItem >= 20
      OR n.proc_cd IS NULL
      AND n.add_class IS NOT NULL THEN 1
    ELSE r.RpItem + 1
  END AS RpItem,
  CASE
    WHEN n.proc_cd IS NOT NULL THEN n.proc_cd
    ELSE r.last_proc_cd
  END AS last_proc_cd,
  CASE
    WHEN n.proc_cd IS NOT NULL
      AND NOT (n.proc_cd = ANY(r.proc_cd_list)) THEN r.proc_cd_list || n.proc_cd
    ELSE r.proc_cd_list
  END AS proc_cd_list,
  CASE
    WHEN ((n.proc_cd IS NOT NULL
      AND NOT (n.proc_cd = ANY(r.proc_cd_list)))
      OR (m.medicine_send_type::NUMERIC = 0
      AND n.proc_cd IS NOT NULL)
      OR r.RpItem >= 20
      AND n.proc_cd IS NOT NULL) THEN TRUE
    ELSE FALSE
  END AS need_procedure_insert,
  CASE
    WHEN r.RpItem >= 20
      AND n.proc_cd IS NULL THEN TRUE
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
  CASE WHEN oxgen_flg
    THEN COALESCE((SELECT oxgen_unit_code FROM ini_value), '''')
    ELSE ''''
  END AS unit,
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
  ''01'' AS detail_id,
  RP AS rp_no,
  RpItem AS item_no,
  title AS title,
  CASE 
  WHEN octet_length(hosp_cd) <= 4 THEN hosp_cd
  ELSE substring(
      hosp_cd FROM (
      SELECT MIN(i)
      FROM generate_series(1, char_length(hosp_cd)) AS i
      WHERE octet_length(substring(hosp_cd FROM i)) <= 8
      )
  )
  END AS hosp_cd,
  LEAST(TRUNC(COALESCE(amount,0), 4)::FLOAT8, 99999.9999)::text AS amount,
  unit
FROM
  final_data
WHERE
  RP < 11
ORDER BY
  RP,
  sort_key;

-- SQL: -1103001 end', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)セコムの透析実績連携', '2025-07-16 14:50:48.578', current_timestamp, '[{"sql_cd": -1102004, "field_name": "pat_personal_info", "replace_var": "@patPersonalInfo"}]'::jsonb);
DELETE FROM sys_data_set WHERE sql_cd IN (-1103014);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1103014, '-- SQL: -11030014 begin
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
        ''SCM_IN_HOSPITAL_CD'',
        ''SCM_DIALYSISSEND''
    )
)
, ini_value AS (
--連携設定からvalue値取得
SELECT
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''MEDICINE_SEND_TYPE'') AS medicine_send_type,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_TREATMENT'') AS hosp_get_mst_treatment,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_DIALYZER'') AS hosp_get_mst_dialyzer,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_EQUIPMENT'') AS hosp_get_mst_equipment,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_MEDICINE'') AS hosp_get_mst_medicine,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_PROCEDURE'') AS hosp_get_mst_procedure,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_DIALYSIS_DIFFICULTY'') AS hosp_get_mst_dia_diff,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_ADDITION'') AS hosp_get_mst_addition,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND'' AND key2 = ''OXGEN_PROCEDURE_CODE'') AS oxgen_procedure_code,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND'' AND key2 = ''OXGEN_MEDI_CODE'') AS oxgen_medi_code,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND'' AND key2 = ''TREAT_CONVERT'') AS treat_convert
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
, rst_treatment AS (
-- 治療方法コード
SELECT
  1000 AS temp_no,
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
  END AS hosp_cd
FROM
  do_ord_main om
INNER JOIN mst_treatment AS mt ON mt.treatment_cd = om.rst_treatment_cd
  AND mt.facility_cd = @facilityCd
CROSS JOIN ini_value
)
, rst_dialyzer AS (
-- ダイアライザ
SELECT
  2000 AS temp_no,
  om.rst_cond_info->''5''->>''value'' AS mst_cd,
  CASE ini_value.hosp_get_mst_dialyzer
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd
FROM
  do_ord_main om
INNER JOIN mst_dialyzer AS mst ON mst.dialyzer_cd::text = om.rst_cond_info ->''5''->>''value''
  AND mst.facility_cd = @facilityCd
CROSS JOIN ini_value
)
, rst_adsorption AS (
-- 吸着カラム
SELECT
  2100 AS temp_no,
  om.rst_cond_info->''6''->>''value'' AS mst_cd,
  CASE ini_value.hosp_get_mst_equipment
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd
FROM
  do_ord_main om
INNER JOIN mst_equipment AS mst ON mst.equipment_cd::text = om.rst_cond_info->''6''->>''value''
  AND mst.facility_cd = @facilityCd
CROSS JOIN ini_value
)
, rst_coagulant AS (
-- 抗凝固剤
SELECT
  3000 AS temp_no,
  om.rst_cond_info->''25''->>''value'' AS mst_cd,
  (om.rst_cond_info->''25''->>''medicine_type'')::integer AS medicine_type,
  NULL::integer AS procedure_cd,
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
  END AS hosp_cd
FROM
  do_ord_main om
LEFT JOIN mst_medicine AS mst_medi ON mst_medi.medicine_cd::text = om.rst_cond_info->''25''->>''value''
  AND mst_medi.facility_cd = @facilityCd
  AND mst_medi.is_shot = ''0''
  AND mst_medi.is_del = ''0''
  AND mst_medi.is_disp = ''1''
  AND om.rst_cond_info->''25''->>''medicine_type''::text = ''1''
LEFT JOIN mst_medi_mix AS mst_mix ON mst_mix.mix_cd::text = om.rst_cond_info->''25''->>''value''
  AND om.rst_cond_info->''25''->>''medicine_type''::text = ''2''
CROSS JOIN ini_value
)
, rst_touseki AS (
-- 透析液
SELECT
  3100 AS temp_no,
  om.rst_cond_info->''15''->>''value'' AS mst_cd,
  (om.rst_cond_info->''15''->>''medicine_type'')::integer AS medicine_type,
  NULL::integer AS procedure_cd,
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
  END AS hosp_cd
FROM
  do_ord_main om
LEFT JOIN mst_medicine AS mst_medi ON mst_medi.medicine_cd::text = om.rst_cond_info->''15''->>''value''
  AND mst_medi.facility_cd = @facilityCd
  AND mst_medi.is_shot = ''0''
  AND mst_medi.is_del = ''0''
  AND mst_medi.is_disp = ''1''
  AND om.rst_cond_info->''15''->>''medicine_type''::text = ''1''
LEFT JOIN mst_medi_mix AS mst_mix ON mst_mix.mix_cd::text = om.rst_cond_info->''15''->>''value''
  AND om.rst_cond_info->''15''->>''medicine_type''::text = ''2''
CROSS JOIN ini_value
)
, rst_hoeki AS (
-- 補液
SELECT
  3200 AS temp_no,
  om.rst_cond_info->''19''->>''value'' AS mst_cd,
  (om.rst_cond_info->''19''->>''medicine_type'')::integer AS medicine_type,
  NULL::integer AS procedure_cd,
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
  END AS hosp_cd
FROM
  do_ord_main om
LEFT JOIN mst_medicine AS mst_medi ON mst_medi.medicine_cd::text = om.rst_cond_info->''19''->>''value''
  AND mst_medi.facility_cd = @facilityCd
  AND mst_medi.is_shot = ''0''
  AND mst_medi.is_del = ''0''
  AND mst_medi.is_disp = ''1''
  AND om.rst_cond_info->''19''->>''medicine_type''::text = ''1''
LEFT JOIN mst_medi_mix AS mst_mix ON mst_mix.mix_cd::text = om.rst_cond_info->''19''->>''value''
  AND om.rst_cond_info->''19''->>''medicine_type''::text = ''2''
CROSS JOIN ini_value
)
, rst_one_film AS (
-- 1次膜
SELECT
  2200 AS temp_no,
  om.rst_cond_info->''7''->>''value'' AS mst_cd,
  CASE ini_value.hosp_get_mst_equipment
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd
FROM
  do_ord_main om
INNER JOIN mst_equipment AS mst ON mst.equipment_cd::text = om.rst_cond_info->''7''->>''value''
  AND mst.facility_cd = @facilityCd
CROSS JOIN ini_value
)
, rst_two_film AS (
-- 2次膜
SELECT
  2300 AS temp_no,
  om.rst_cond_info->''8''->>''value'' AS mst_cd,
  CASE ini_value.hosp_get_mst_equipment
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd
FROM
  do_ord_main om
INNER JOIN mst_equipment AS mst ON mst.equipment_cd::text = om.rst_cond_info->''8''->>''value''
  AND mst.facility_cd = @facilityCd
CROSS JOIN ini_value
)
, medi_indo AS (
-- 投与薬剤情報
SELECT
  3300 + t1.idx AS temp_no,
  t1.medi_info ->> ''cd'' AS mst_cd,
  (t1.medi_info ->> ''medicine_type'')::integer AS medicine_type,
  (t1.medi_info ->> ''procedure_cd'')::integer AS procedure_cd,
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
LEFT JOIN mst_medi_mix AS mst_mix ON mst_mix.mix_cd::text = medi_info ->> ''cd''
  AND medi_info ->> ''medicine_type''::text = ''2''
CROSS JOIN ini_value
WHERE
  medi_info ->> ''effect_flg''::text = ''1''
)
, treatment_info AS (
-- 愁訴処置情報
SELECT
  3400 + t1.idx AS temp_no,
  CASE
    WHEN t1.tre_info ->> ''treat_class'' = ''3''
      AND t1.tre_info ->> ''oxygen_amount'' IS NOT NULL
      AND ini_value.oxgen_medi_code <> ''''
      AND ini_value.oxgen_procedure_code <> '''' THEN
      ''oxgen_medi_code''
    ELSE
      t1.tre_info ->> ''treat_medicine_cd''
  END AS mst_cd,
  (t1.tre_info ->> ''medicine_type'')::integer AS medicine_type,
  CASE
    WHEN t1.tre_info ->> ''treat_class'' = ''3''
      AND t1.tre_info ->> ''oxygen_amount'' IS NOT NULL
      AND ini_value.oxgen_medi_code <> ''''
      AND ini_value.oxgen_procedure_code <> '''' THEN
      -9999
    ELSE
      (t1.tre_info ->> ''procedure_cd'')::integer
  END AS procedure_cd,
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
  AND t1.tre_info ->> ''medicine_type''::text = ''1''
  AND mst_medi.facility_cd = @facilityCd
  AND mst_medi.is_shot = ''0''
  AND mst_medi.is_del = ''0''
  AND mst_medi.is_disp = ''1''
LEFT JOIN mst_medi_mix AS mst_mix ON mst_mix.mix_cd::text = t1.tre_info ->> ''treat_medicine_cd''
  AND t1.tre_info ->> ''medicine_type''::text = ''2''
CROSS JOIN ini_value
)
, rst_equip_info AS (
-- 医療材料コード
SELECT
  2400 + t1.idx AS temp_no,
  t1.equip_info ->> ''cd'' AS mst_cd,
  CASE ini_value.hosp_get_mst_equipment
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd
FROM
  do_ord_main om
CROSS JOIN LATERAL json_array_elements(om.rst_equip_info::json) WITH ORDINALITY AS t1(equip_info, idx)
INNER JOIN mst_equipment AS mst ON mst.equipment_cd::text = t1.equip_info ->> ''cd''
  AND mst.facility_cd = @facilityCd
CROSS JOIN ini_value
)
, dial_diff_info AS (
-- 透析困難コード
SELECT
  1300 AS temp_no,
  CASE ini_value.hosp_get_mst_dia_diff
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    ELSE NULL
  END AS hosp_cd
FROM
  auth_info ai
LEFT JOIN mst_dialysis_difficulty AS mst ON mst.dialysis_difficulty_cd::text = ai.dial_diff_cd
  AND mst.facility_cd = @facilityCd
  AND mst.is_del = ''0''
CROSS JOIN ini_value
WHERE
  ai.is_dial_diff = ''1''
)
, addition_info AS (
-- 加算情報
SELECT
  1300 + t1.idx AS temp_no,
  t1.addi_info ->> ''cd'' AS mst_cd,
  CASE ini_value.hosp_get_mst_addition
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    ELSE NULL
  END AS hosp_cd,
  mst.addition_class AS add_class,
  mst.in_hospital_cd_2 AS hosp_2_cd
FROM
  do_ord_main om
LEFT JOIN LATERAL (
  SELECT x.elem, x.ord FROM do_ord_main om
  CROSS JOIN LATERAL jsonb_array_elements(om.addition_info) WITH ORDINALITY AS x(elem, ord)
  WHERE
    jsonb_typeof(om.addition_info) = ''array''
) AS t1(addi_info, idx) ON TRUE
LEFT JOIN mst_addition AS mst ON mst.addition_cd ::text = t1.addi_info ->> ''cd''
  AND mst.facility_cd = @facilityCd
  AND mst.is_del = ''0''
CROSS JOIN ini_value
)
, medi_union_1 AS (
-- 薬剤情報（抗凝固剤、透析液、補液、投与薬剤情報(手技なし)、愁訴処置情報（手技なし））
SELECT
  title,
  hosp_cd
FROM
  (SELECT
    coa.temp_no AS temp_no,
    coa.medicine_type AS medicine_type,
    coa.procedure_cd AS procedure_cd,
    ''抗凝固剤'' AS title,
    coa.mst_cd AS mst_cd,
    coa.hosp_cd AS hosp_cd
  FROM
    rst_coagulant coa
  WHERE
    coa.mst_cd IS NOT NULL
UNION ALL
  SELECT
    tou.temp_no AS temp_no,
    tou.medicine_type AS medicine_type,
    tou.procedure_cd AS procedure_cd,
    ''透析液'' AS title,
    tou.mst_cd AS mst_cd,
    tou.hosp_cd AS hosp_cd
  FROM
    rst_touseki tou
  WHERE
    tou.mst_cd IS NOT NULL
UNION ALL
  SELECT
    hoe.temp_no AS temp_no,
    hoe.medicine_type AS medicine_type,
    hoe.procedure_cd AS procedure_cd,
    ''補液'' AS title,
    hoe.mst_cd AS mst_cd,
    hoe.hosp_cd AS hosp_cd
  FROM
    rst_hoeki hoe
  WHERE
    hoe.mst_cd IS NOT NULL
UNION ALL
  SELECT
    imi.temp_no AS temp_no,
    imi.medicine_type AS medicine_type,
    imi.procedure_cd AS procedure_cd,
    ''投与薬剤情報(手技なし）'' AS title,
    imi.mst_cd AS mst_cd,
    imi.hosp_cd AS hosp_cd
  FROM
    medi_indo imi
  WHERE
    imi.mst_cd IS NOT NULL
    AND imi.is_shot = ''0''
    AND imi.procedure_cd IS NULL
    AND (SELECT medicine_send_type::NUMERIC FROM ini_value) = 0
UNION ALL
  SELECT
    MIN(imi.temp_no) AS temp_no,
    MIN(imi.medicine_type) AS medicine_type,
    imi.procedure_cd AS procedure_cd,
    ''投与薬剤情報(手技なし）'' AS title,
    MIN(imi.mst_cd) AS mst_cd,
    imi.hosp_cd AS hosp_cd
  FROM
    medi_indo imi
  WHERE
    imi.mst_cd IS NOT NULL
    AND imi.is_shot = ''0''
    AND imi.procedure_cd IS NULL
    AND (SELECT medicine_send_type::NUMERIC FROM ini_value) = 1
  GROUP BY
    imi.procedure_cd,
    imi.hosp_cd
UNION ALL
  SELECT
    ti.temp_no AS temp_no,
    ti.medicine_type AS medicine_type,
    ti.procedure_cd AS procedure_cd,
    ''愁訴処置情報(手技なし）'' AS title,
    ti.mst_cd AS mst_cd,
    ti.hosp_cd AS hosp_cd
  FROM
    treatment_info ti
  WHERE
    ti.mst_cd IS NOT NULL
    AND ti.is_shot = ''0''
    AND ti.procedure_cd IS NULL
    AND (SELECT medicine_send_type::NUMERIC FROM ini_value) = 0
UNION ALL
  SELECT
    MIN(ti.temp_no) AS temp_no,
    MIN(ti.medicine_type) AS medicine_type,
    ti.procedure_cd AS procedure_cd,
    ''愁訴処置情報(手技なし）'' AS title,
    MIN(ti.mst_cd) AS mst_cd,
    ti.hosp_cd AS hosp_cd
  FROM
    treatment_info ti
  WHERE
    ti.mst_cd IS NOT NULL
    AND ti.is_shot = ''0''
    AND ti.procedure_cd IS NULL
    AND (SELECT medicine_send_type::NUMERIC FROM ini_value) = 1
  GROUP BY
    ti.procedure_cd,
    ti.hosp_cd
) AS rst_medi_table
ORDER BY
  temp_no
)
, medi_union_2 AS (
-- 投与薬剤情報(手技あり)、愁訴処置情報（手技あり）
SELECT
  ''投与薬剤/愁訴処置情報(薬剤）'' AS title,
  mst_cd,
  hosp_cd,
  MAX(mst.pricedure_name) AS pro_title,
  pro_medi_table.procedure_cd,
  CASE
    WHEN pro_medi_table.procedure_cd = -9999 THEN
      MAX(ini_value.oxgen_procedure_code)
    WHEN ((MAX(pro_medi_table.treat_date) >= MAX(mst.in_hosp_a_startdate))
      AND (MAX(pro_medi_table.treat_date) >= MAX(mst.in_hosp_b_startdate))) THEN
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
    WHEN MAX(pro_medi_table.treat_date) >= MAX(mst.in_hosp_a_startdate) THEN
      CASE MAX(ini_value.hosp_get_mst_procedure)
        WHEN ''1'' THEN MAX(mst.in_hospital_cd_a1)
        WHEN ''2'' THEN MAX(mst.in_hospital_cd_a2)
      END
    WHEN MAX(pro_medi_table.treat_date) >= MAX(mst.in_hosp_b_startdate) THEN
      CASE MAX(ini_value.hosp_get_mst_procedure)
        WHEN ''1'' THEN MAX(mst.in_hospital_cd_b1)
        WHEN ''2'' THEN MAX(mst.in_hospital_cd_b2)
      END
    ELSE NULL
  END AS pro_hosp_cd
FROM
  (SELECT
    imi2.mst_cd AS mst_cd,
    imi2.hosp_cd AS hosp_cd,
    imi2.procedure_cd AS procedure_cd,
    imi2.treat_date AS treat_date
  FROM
    medi_indo imi2
  WHERE
    imi2.mst_cd IS NOT NULL
    AND imi2.is_shot = ''0''
    AND imi2.procedure_cd IS NOT NULL
UNION ALL
  SELECT
    ti2.mst_cd AS mst_cd,
    ti2.hosp_cd AS hosp_cd,
    ti2.procedure_cd AS procedure_cd,
    ti2.treat_date AS treat_date
  FROM
    treatment_info ti2
  WHERE
    ti2.mst_cd IS NOT NULL
    AND ti2.is_shot = ''0''
    AND ti2.procedure_cd IS NOT NULL
) AS pro_medi_table
LEFT JOIN mst_procedure mst ON mst.procedure_cd = pro_medi_table.procedure_cd
  AND mst.facility_cd = @facilityCd
CROSS JOIN ini_value
WHERE
  (SELECT medicine_send_type::NUMERIC FROM ini_value) = 0
GROUP BY
  pro_medi_table.procedure_cd,
  pro_medi_table.mst_cd,
  pro_medi_table.hosp_cd
UNION ALL
SELECT
  ''投与薬剤情報(薬剤）'' AS title,
  MIN(pro_medi_table.mst_cd) AS mst_cd,
  pro_medi_table.hosp_cd AS hosp_cd,
  MAX(mst.pricedure_name) AS pro_title,
  pro_medi_table.procedure_cd AS procedure_cd,
  CASE
    WHEN pro_medi_table.procedure_cd = -9999 THEN
        MAX(ini_value.oxgen_procedure_code)
    WHEN ((MAX(pro_medi_table.treat_date) >= MAX(mst.in_hosp_a_startdate)) AND (MAX(pro_medi_table.treat_date) >= MAX(mst.in_hosp_b_startdate))) THEN
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
    WHEN MAX(pro_medi_table.treat_date) >= MAX(mst.in_hosp_a_startdate) THEN
      CASE MAX(ini_value.hosp_get_mst_procedure)
        WHEN ''1'' THEN MAX(mst.in_hospital_cd_a1)
        WHEN ''2'' THEN MAX(mst.in_hospital_cd_a2)
      END
    WHEN MAX(pro_medi_table.treat_date) >= MAX(mst.in_hosp_b_startdate) THEN
      CASE MAX(ini_value.hosp_get_mst_procedure)
        WHEN ''1'' THEN MAX(mst.in_hospital_cd_b1)
        WHEN ''2'' THEN MAX(mst.in_hospital_cd_b2)
      END
    ELSE NULL
  END AS pro_hosp_cd
FROM
  (SELECT
    imi2.mst_cd AS mst_cd,
    imi2.hosp_cd AS hosp_cd,
    imi2.procedure_cd AS procedure_cd,
    imi2.treat_date AS treat_date
  FROM
    medi_indo imi2
  WHERE
    imi2.mst_cd IS NOT NULL
    AND imi2.is_shot = ''0''
    AND imi2.procedure_cd IS NOT NULL
UNION ALL
  SELECT
    ti2.mst_cd AS mst_cd,
    ti2.hosp_cd AS hosp_cd,
    ti2.procedure_cd AS procedure_cd,
    ti2.treat_date AS treat_date
  FROM
    treatment_info ti2
  WHERE
    ti2.mst_cd IS NOT NULL
    AND ti2.is_shot = ''0''
    AND ti2.procedure_cd IS NOT NULL
) AS pro_medi_table
LEFT JOIN mst_procedure mst
  ON mst.procedure_cd = pro_medi_table.procedure_cd
  AND mst.facility_cd = @facilityCd
CROSS JOIN ini_value
WHERE
  (SELECT medicine_send_type::NUMERIC FROM ini_value) = 1
GROUP BY
  pro_medi_table.procedure_cd,
  pro_medi_table.hosp_cd
)
, equip_union AS (
-- 医療材料情報（吸着カラム,1次膜,2次膜,医療材料情報）
SELECT
  title,
  hosp_cd
FROM
  (SELECT
    ''吸着カラム'' AS title,
    ads.*
  FROM
    rst_adsorption ads
  WHERE
    ads.mst_cd IS NOT NULL
UNION ALL
  SELECT
    ''1次膜'' AS title,
    one.*
  FROM
    rst_one_film one
  WHERE
    one.mst_cd IS NOT NULL
UNION ALL
  SELECT
    ''2次膜'' AS title,
    two.*
  FROM
    rst_two_film two
  WHERE
    two.mst_cd IS NOT NULL
UNION ALL
  SELECT
    ''医療材料情報'' AS title,
    iei.*
  FROM
    rst_equip_info iei
  WHERE
    iei.mst_cd IS NOT NULL    
) AS rst_equip_table
ORDER BY
  rst_equip_table.temp_no
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
  NULL AS proc_cd
FROM
  (SELECT
    STRING_AGG(DISTINCT title, ''-'') AS title,
    hosp_cd
  FROM
    equip_union
  GROUP BY
    hosp_cd
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
  NULL AS proc_cd,
  NULL AS add_class
FROM
  rst_treatment tre
WHERE
  tre.hosp_cd IS NOT NULL
UNION ALL
SELECT
  ''透析困難コード'' AS title,
  ddi.hosp_cd AS hosp_cd,
  NULL AS proc_cd,
  NULL AS add_class
FROM
  dial_diff_info ddi
WHERE
  ddi.hosp_cd IS NOT NULL
UNION ALL
SELECT
  ''加算情報(加算項目)'' AS title,
  ai.hosp_cd AS hosp_cd,
  NULL AS proc_cd,
  NULL AS add_class
FROM
  addition_info ai
WHERE
  (ai.add_class <> ''13''
    OR COALESCE(ai.hosp_2_cd, '''') <> '''')
    AND ai.hosp_cd IS NOT NULL
UNION ALL
  SELECT
    ''ダイアライザ'' AS title,
    dia.hosp_cd AS hosp_cd,
    NULL AS proc_cd,
    NULL AS add_class
  FROM
    rst_dialyzer dia
  WHERE
    dia.hosp_cd IS NOT NULL
UNION ALL
  SELECT
    eu.title AS title,
    eu.hosp_cd AS hosp_cd,
    NULL AS proc_cd,
    NULL AS add_class
  FROM
    equip_sort_union eu
  WHERE
    eu.hosp_cd IS NOT NULL
UNION ALL
  SELECT
    mu1.title AS title,
    mu1.hosp_cd AS hosp_cd,
    NULL AS proc_cd,
    NULL AS add_class
  FROM
    medi_union_1 mu1
  WHERE
    mu1.hosp_cd IS NOT NULL
UNION ALL
  SELECT
    ''加算情報(医学管理科)'' AS title,
    ai.hosp_cd AS hosp_cd,
    NULL AS proc_cd,
    ai.add_class AS add_class
  FROM
    addition_info ai
  WHERE
    (ai.add_class = ''13''
      AND COALESCE(ai.hosp_2_cd, '''') = '''')
    AND ai.hosp_cd IS NOT NULL
UNION ALL
  SELECT
    mu2.title AS title,
    mu2.hosp_cd AS hosp_cd,
    mu2.pro_hosp_cd AS proc_cd,
    NULL AS add_class
  FROM
    medi_union_2 mu2
  WHERE
    mu2.hosp_cd IS NOT NULL
    AND mu2.pro_hosp_cd IS NOT NULL
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
  n.proc_cd,
  n.add_class,
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
  n.proc_cd,
  n.add_class,
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
  NULL::text AS proc_cd,
  (rn - 0.5)::NUMERIC AS sort_key
FROM
  recursive_rp
CROSS JOIN rst_treatment tre
WHERE
  need_treatment_insert
)
, recursive_rp_with_sort AS (
SELECT
  RP,
  RpItem,
  title,
  hosp_cd,
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
  proc_cd,
  sort_key
FROM
  treatment_inserts
)
SELECT
  ''01'' AS detail_id,
  @facilityCd AS facility_cd,
  @ctlNo AS ctl_no,
  @key0 AS key0,
  @patId AS pat_id,
  @ordNo AS ord_no
WHERE
EXISTS (
  SELECT 1 FROM final_data
)
-- SQL: -1103014 end', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析実績連携 処置実績ファイル_ファイル出力有無', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1102004, "field_name": "pat_personal_info", "replace_var": "@patPersonalInfo"}]'::jsonb);
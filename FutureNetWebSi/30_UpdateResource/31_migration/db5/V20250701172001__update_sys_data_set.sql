delete from "sys_data_set" where sql_cd in (-1102002);

INSERT INTO sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-1102002, 'WITH coop_ini_info AS (
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
,
auth_info AS (
--患者個人情報取得(pre_sqlにて取得)
SELECT
  auth_info ->> ''dial_diff_cd'' AS dial_diff_cd
FROM
  json_array_elements(@patPersonalInfo::json) auth_info
)
,
mst_medi_mix AS (
--調整薬剤マスタ
SELECT
  medicine_mix_cd AS mix_cd,
  info ->> ''solvent'' AS solvent,
  info ->> ''cd'' AS medi_cd,
  info ->> ''amount'' AS amount,
  mst.unit AS unit,
  mst.in_hospital_cd_1 AS in_hospital_cd_1,
  mst.in_hospital_cd_2 AS in_hospital_cd_2,
  mst.in_hospital_cd_3 AS in_hospital_cd_3,
  mst.in_hospital_cd_4 AS in_hospital_cd_4
FROM 
  mst_medicine_mix mix
CROSS JOIN LATERAL json_array_elements(mix.mix_info::json) info
INNER JOIN mst_medicine AS mst ON mst.medicine_cd::text = info ->> ''cd''
    AND mst.is_shot = ''0''
WHERE
  mix.is_del = ''0''
  AND mix.facility_cd = @facilityCd
)
,
ind_treatment AS (
-- 治療方法コード
SELECT
  CASE
    -- 両方とも利用開始日以降の場合
    WHEN ((om.treat_date::TIMESTAMP >= mt.in_hosp_a_startdate)
      AND (om.treat_date::TIMESTAMP >= mt.in_hosp_b_startdate)) THEN
      CASE
        WHEN mt.in_hosp_a_startdate > mt.in_hosp_b_startdate THEN
          CASE ini_value.hosp_get_cd
            WHEN ''1'' THEN mt.in_hospital_cd_a1
            WHEN ''2'' THEN mt.in_hospital_cd_a2
            WHEN ''3'' THEN mt.in_hospital_cd_a3
            WHEN ''4'' THEN mt.in_hospital_cd_a4
          END
        WHEN mt.in_hosp_a_startdate < mt.in_hosp_b_startdate THEN
          CASE ini_value.hosp_get_cd
            WHEN ''1'' THEN mt.in_hospital_cd_b1
            WHEN ''2'' THEN mt.in_hospital_cd_b2
            WHEN ''3'' THEN mt.in_hospital_cd_b3
            WHEN ''4'' THEN mt.in_hospital_cd_b4
          END
      END
    -- 治療日よりAの利用日開始日以降の場合
    WHEN om.treat_date::TIMESTAMP >= mt.in_hosp_a_startdate THEN
      CASE ini_value.hosp_get_cd
        WHEN ''1'' THEN mt.in_hospital_cd_a1
        WHEN ''2'' THEN mt.in_hospital_cd_a2
        WHEN ''3'' THEN mt.in_hospital_cd_a3
        WHEN ''4'' THEN mt.in_hospital_cd_a4
      END
    -- 治療日よりBの利用日開始日以降の場合
    WHEN om.treat_date::TIMESTAMP >= mt.in_hosp_b_startdate THEN
      CASE ini_value.hosp_get_cd
        WHEN ''1'' THEN mt.in_hospital_cd_b1
        WHEN ''2'' THEN mt.in_hospital_cd_b2
        WHEN ''3'' THEN mt.in_hospital_cd_b3
        WHEN ''4'' THEN mt.in_hospital_cd_b4
      END
    ELSE NULL
  END AS cd,
  1 AS amount,
  CASE
    WHEN COALESCE(ini_value.unit, '''') = '''' THEN ''''
    ELSE ini_value.unit
  END AS unit
FROM
  ord_main om
INNER JOIN mst_treatment AS mt ON
  mt.treatment_cd = om.ind_treatment_cd
CROSS JOIN (
  SELECT
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_TREATMENT'') AS hosp_get_cd,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''TREAT_ITEM_UNIT'') AS unit
  ) AS ini_value
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
)
,
ind_dialyzer AS (
-- ダイアライザ
SELECT
  CASE
    ini_value.hosp_get_cd
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS cd,
  1 AS amount,
  CASE
    WHEN COALESCE(ini_value.unit, '''') = '''' THEN ''''
    ELSE ini_value.unit
  END AS unit
FROM
  ord_main om
INNER JOIN mst_dialyzer AS mst ON
  mst.dialyzer_cd::text = om.ind_cond_info->''5''->>''value''
CROSS JOIN (
  SELECT
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_DIALYZER'') AS hosp_get_cd,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''DIALYZER_UNIT'') AS unit
  ) AS ini_value
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
)
,
ind_adsorption AS (
-- 吸着カラム
SELECT
  CASE
    ini_value.hosp_get_cd
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS cd,
  1 AS amount,
  CASE
    WHEN mst.unit = ''個'' THEN ini_value.unit
    ELSE ''''
  END AS unit
FROM
  ord_main om
INNER JOIN mst_equipment AS mst ON
  mst.equipment_cd::text = om.ind_cond_info->''6''->>''value''
CROSS JOIN (
  SELECT
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_EQUIPMENT'') AS hosp_get_cd,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_CONV_UNIT_EQUIP'' AND key2 = ''個'') AS unit
  ) AS ini_value
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
)
,
ind_coagulant AS (
-- 抗凝固剤
SELECT
  CASE
    WHEN COALESCE(om.ind_cond_info->''25''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE om.ind_cond_info->''25''->>''medicine_type''
        WHEN ''1'' THEN 
          CASE ini_value.hosp_get_cd
            WHEN ''1'' THEN mst_medi.in_hospital_cd_1
            WHEN ''2'' THEN mst_medi.in_hospital_cd_2
            WHEN ''3'' THEN mst_medi.in_hospital_cd_3
            WHEN ''4'' THEN mst_medi.in_hospital_cd_4
            ELSE NULL
          END
        WHEN ''2'' THEN 
          CASE ini_value.hosp_get_cd
            WHEN ''1'' THEN mst_mix.in_hospital_cd_1
            WHEN ''2'' THEN mst_mix.in_hospital_cd_2
            WHEN ''3'' THEN mst_mix.in_hospital_cd_3
            WHEN ''4'' THEN mst_mix.in_hospital_cd_4
            ELSE NULL
        END
      END
  END AS cd,
  CASE
    WHEN COALESCE(om.ind_cond_info->''25''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE om.ind_cond_info->''25''->>''medicine_type''
        WHEN ''1'' THEN CAST(om.ind_cond_info->''26''->>''value'' AS NUMERIC) + CAST(om.ind_cond_info->''28''->>''value'' AS NUMERIC)
        WHEN ''2'' THEN 
          CASE mst_mix.solvent
            WHEN ''0'' THEN
              (CAST(om.ind_cond_info->''26''->>''value'' AS NUMERIC) + CAST(om.ind_cond_info->''28''->>''value'' AS NUMERIC)) * CAST(mst_mix.amount AS NUMERIC)
            WHEN ''1'' THEN CAST(mst_mix.amount AS NUMERIC)
          END
      END
  END AS amount,
  CASE
    WHEN COALESCE(om.ind_cond_info->''25''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE om.ind_cond_info->''25''->>''medicine_type''
        WHEN ''1'' THEN 
          CASE
            WHEN mst_medi.unit = ''ml'' THEN ini_value.unit
            ELSE ''''
          END
        WHEN ''2'' THEN 
          CASE
            WHEN mst_mix.unit = ''ml'' THEN ini_value.unit
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
LEFT JOIN mst_medi_mix AS mst_mix ON mst_mix.mix_cd::text = om.ind_cond_info->''25''->>''value''
  AND om.ind_cond_info->''25''->>''medicine_type''::text = ''2''
CROSS JOIN (
  SELECT
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_MEDICINE'') AS hosp_get_cd,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_CONV_UNIT_MEDI'' AND key2 = ''ml'') AS unit
  ) AS ini_value
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
)
,
ind_touseki AS (
-- 透析液
SELECT
  CASE
    WHEN COALESCE(om.ind_cond_info->''15''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE om.ind_cond_info->''15''->>''medicine_type''
      WHEN ''1'' THEN 
        CASE ini_value.hosp_get_cd
          WHEN ''1'' THEN mst_medi.in_hospital_cd_1
          WHEN ''2'' THEN mst_medi.in_hospital_cd_2
          WHEN ''3'' THEN mst_medi.in_hospital_cd_3
          WHEN ''4'' THEN mst_medi.in_hospital_cd_4
          ELSE NULL
        END
      WHEN ''2'' THEN 
        CASE ini_value.hosp_get_cd
          WHEN ''1'' THEN mst_mix.in_hospital_cd_1
          WHEN ''2'' THEN mst_mix.in_hospital_cd_2
          WHEN ''3'' THEN mst_mix.in_hospital_cd_3
          WHEN ''4'' THEN mst_mix.in_hospital_cd_4
          ELSE NULL
        END
      END
  END AS cd,
  CASE 
    WHEN COALESCE(om.ind_cond_info->''15''->>''value'', '''') = '''' THEN NULL
    ELSE
      CAST(om.ind_cond_info->''16''->>''value'' AS NUMERIC)
  END AS amount,
  CASE
    WHEN COALESCE(om.ind_cond_info->''15''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE om.ind_cond_info->''15''->>''medicine_type''
        WHEN ''1'' THEN 
          CASE
            WHEN mst_medi.unit = ''ml'' THEN ini_value.unit
          ELSE ''''
        END
        WHEN ''2'' THEN 
          CASE
            WHEN mst_mix.unit = ''ml'' THEN ini_value.unit
          ELSE ''''
      END
    END
  END AS unit
FROM
  ord_main om
LEFT JOIN mst_medicine AS mst_medi ON mst_medi.medicine_cd::text = om.ind_cond_info->''15''->>''value''
  AND mst_medi.is_shot = ''0''
  AND om.ind_cond_info->''15''->>''medicine_type''::text = ''1''
LEFT JOIN mst_medi_mix AS mst_mix ON mst_mix.mix_cd::text = om.ind_cond_info->''15''->>''value''
  AND om.ind_cond_info->''15''->>''medicine_type''::text = ''2''
CROSS JOIN (
  SELECT
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_MEDICINE'') AS hosp_get_cd,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_CONV_UNIT_MEDI'' AND key2 = ''ml'') AS unit
  ) AS ini_value
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
)
,
ind_hoeki AS (
-- 補液
SELECT
  CASE
    WHEN COALESCE(om.ind_cond_info->''19''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE om.ind_cond_info->''19''->>''medicine_type''
        WHEN ''1'' THEN 
          CASE ini_value.hosp_get_cd
            WHEN ''1'' THEN mst_medi.in_hospital_cd_1
            WHEN ''2'' THEN mst_medi.in_hospital_cd_2
            WHEN ''3'' THEN mst_medi.in_hospital_cd_3
            WHEN ''4'' THEN mst_medi.in_hospital_cd_4
            ELSE NULL
          END
        WHEN ''2'' THEN 
          CASE ini_value.hosp_get_cd
            WHEN ''1'' THEN mst_mix.in_hospital_cd_1
            WHEN ''2'' THEN mst_mix.in_hospital_cd_2
            WHEN ''3'' THEN mst_mix.in_hospital_cd_3
            WHEN ''4'' THEN mst_mix.in_hospital_cd_4
            ELSE NULL
          END
      END
  END AS cd,
  CASE 
    WHEN COALESCE(om.ind_cond_info->''19''->>''value'', '''') = '''' THEN NULL
    ELSE
      CAST(om.ind_cond_info->''22''->>''value'' AS NUMERIC)
  END AS amount,
  CASE
    WHEN COALESCE(om.ind_cond_info->''19''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE om.ind_cond_info->''19''->>''medicine_type''
        WHEN ''1'' THEN 
          CASE
            WHEN mst_medi.unit = ''ml'' THEN ini_value.unit
            ELSE ''''
          END
        WHEN ''2'' THEN 
          CASE
            WHEN mst_mix.unit = ''ml'' THEN ini_value.unit
          ELSE ''''
      END
    END
  END AS unit
FROM
  ord_main om
LEFT JOIN mst_medicine AS mst_medi ON mst_medi.medicine_cd::text = om.ind_cond_info->''19''->>''value''
  AND mst_medi.is_shot = ''0''
  AND om.ind_cond_info->''19''->>''medicine_type''::text = ''1''
LEFT JOIN mst_medi_mix AS mst_mix ON mst_mix.mix_cd::text = om.ind_cond_info->''19''->>''value''
  AND om.ind_cond_info->''19''->>''medicine_type''::text = ''2''
CROSS JOIN (
  SELECT
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_MEDICINE'') AS hosp_get_cd,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_CONV_UNIT_MEDI'' AND key2 = ''ml'') AS unit
  ) AS ini_value
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
)
,
ind_one_film AS (
-- 1次膜
SELECT
  CASE
    ini_value.hosp_get_cd
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS cd,
  1 AS amount,
  CASE
    WHEN mst.unit = ''個'' THEN ini_value.unit
    ELSE ''''
  END AS unit
FROM
  ord_main om
INNER JOIN mst_equipment AS mst ON mst.equipment_cd::text = om.ind_cond_info->''7''->>''value''
CROSS JOIN (
  SELECT
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_EQUIPMENT'') AS hosp_get_cd,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_CONV_UNIT_EQUIP'' AND key2 = ''個'') AS unit
  ) AS ini_value
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
)
,
ind_two_film AS (
-- 2次膜
SELECT
  CASE
    ini_value.hosp_get_cd
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS cd,
  1 AS amount,
  CASE
    WHEN mst.unit = ''個'' THEN ini_value.unit
    ELSE ''''
  END AS unit
FROM
  ord_main om
INNER JOIN mst_equipment AS mst ON
  mst.equipment_cd::text = om.ind_cond_info->''8''->>''value''
CROSS JOIN (
  SELECT
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_EQUIPMENT'') AS hosp_get_cd,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_CONV_UNIT_EQUIP'' AND key2 = ''個'') AS unit
  ) AS ini_value
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
)
,
ind_medi_info AS (
-- 投与薬剤情報->薬剤コード
SELECT
  CASE
    WHEN json_array_length(om.ind_medi_info::json) = 0 THEN NULL
    ELSE
      CASE medi_info ->> ''medicine_type''
        WHEN ''1'' THEN 
          CASE ini_value.hosp_get_cd
            WHEN ''1'' THEN mst_medi.in_hospital_cd_1
            WHEN ''2'' THEN mst_medi.in_hospital_cd_2
            WHEN ''3'' THEN mst_medi.in_hospital_cd_3
            WHEN ''4'' THEN mst_medi.in_hospital_cd_4
            ELSE NULL
          END
        WHEN ''2'' THEN 
          CASE ini_value.hosp_get_cd
            WHEN ''1'' THEN mst_mix.in_hospital_cd_1
            WHEN ''2'' THEN mst_mix.in_hospital_cd_2
            WHEN ''3'' THEN mst_mix.in_hospital_cd_3
            WHEN ''4'' THEN mst_mix.in_hospital_cd_4
            ELSE NULL
          END
      END
  END AS cd,
  CASE 
    WHEN json_array_length(om.ind_medi_info::json) = 0 THEN NULL
    ELSE
      CASE
      medi_info ->> ''medicine_type''
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
      CASE medi_info ->> ''medicine_type''
        WHEN ''1'' THEN 
          CASE
            WHEN mst_medi.unit = ''ml'' THEN ini_value.unit
        ELSE ''''
        END
      WHEN ''2'' THEN 
          CASE
            WHEN mst_mix.unit = ''ml'' THEN ini_value.unit
        ELSE ''''
        END
    END
  END AS unit
FROM
  ord_main om
CROSS JOIN LATERAL json_array_elements(om.ind_medi_info::json) medi_info
LEFT JOIN mst_medicine AS mst_medi ON mst_medi.medicine_cd::text = medi_info ->> ''cd''
    AND mst_medi.is_shot = ''0''
    AND medi_info ->> ''medicine_type''::text = ''1''
LEFT JOIN mst_medi_mix AS mst_mix ON mst_mix.mix_cd::text = medi_info ->> ''cd''
    AND medi_info ->> ''medicine_type''::text = ''2''
CROSS JOIN (
  SELECT
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_MEDICINE'') AS hosp_get_cd,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_CONV_UNIT_MEDI'' AND key2 = ''ml'') AS unit
) AS ini_value
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
ORDER BY
  CAST(medi_info ->> ''cd'' AS NUMERIC)
)
,
ind_procedure AS (
-- 手技コード
SELECT
  CASE
    -- 両方とも利用開始日以降の場合
    WHEN ((om.treat_date::TIMESTAMP >= mst.in_hosp_a_startdate)
      AND (om.treat_date::TIMESTAMP >= mst.in_hosp_b_startdate)) THEN
      CASE
        WHEN mst.in_hosp_a_startdate > mst.in_hosp_b_startdate THEN
          CASE ini_value.hosp_get_cd
            WHEN ''1'' THEN mst.in_hospital_cd_a1
            WHEN ''2'' THEN mst.in_hospital_cd_a2
          END
        WHEN mst.in_hosp_a_startdate < mst.in_hosp_b_startdate THEN
          CASE ini_value.hosp_get_cd
            WHEN ''1'' THEN mst.in_hospital_cd_b1
            WHEN ''2'' THEN mst.in_hospital_cd_b2
          END
      END
    -- 治療日よりAの利用日開始日以降の場合
    WHEN om.treat_date::TIMESTAMP >= mst.in_hosp_a_startdate THEN
      CASE ini_value.hosp_get_cd
        WHEN ''1'' THEN mst.in_hospital_cd_a1
        WHEN ''2'' THEN mst.in_hospital_cd_a2
      END
    -- 治療日よりBの利用日開始日以降の場合
    WHEN om.treat_date::TIMESTAMP >= mst.in_hosp_b_startdate THEN
      CASE ini_value.hosp_get_cd
        WHEN ''1'' THEN mst.in_hospital_cd_b1
        WHEN ''2'' THEN mst.in_hospital_cd_b2
      END
    ELSE NULL
  END AS cd,
  1 AS amount,
  CASE
    WHEN json_array_length(om.ind_medi_info::json) = 0 THEN NULL
    ELSE
      CASE medi_info ->> ''medicine_type''
        WHEN ''1'' THEN 
          CASE
            WHEN mst_medi.unit = ''ml'' THEN ini_value.unit
        ELSE ''''
        END
      WHEN ''2'' THEN 
          CASE
            WHEN mst_mix.unit = ''ml'' THEN ini_value.unit
        ELSE ''''
        END
    END
  END AS unit
FROM
  ord_main om
CROSS JOIN LATERAL json_array_elements(om.ind_medi_info::json) medi_info
INNER JOIN mst_procedure AS mst ON mst.procedure_cd::text = medi_info ->> ''procedure_cd''
LEFT JOIN mst_medicine AS mst_medi ON mst_medi.medicine_cd::text = medi_info ->> ''cd''
    AND mst_medi.is_shot = ''0''
    AND medi_info ->> ''medicine_type''::text = ''1''
LEFT JOIN mst_medi_mix AS mst_mix ON mst_mix.mix_cd::text = medi_info ->> ''cd''
    AND medi_info ->> ''medicine_type''::text = ''2''
CROSS JOIN (
  SELECT
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_PROCEDURE'') AS hosp_get_cd,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_CONV_UNIT_MEDI'' AND key2 = ''ml'') AS unit
  ) AS ini_value
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
)
,
ind_equip_info AS (
-- 医療材料コード
SELECT
  CASE ini_value.hosp_get_cd
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS cd,
  CAST(equip_info->>''amount'' AS NUMERIC) AS amount,
  CASE
    WHEN CAST(equip_info->>''unit'' AS TEXT) = ''個'' THEN ini_value.unit
    ELSE ''''
  END AS unit
FROM
  ord_main om
CROSS JOIN LATERAL json_array_elements(om.ind_equip_info::json) equip_info
INNER JOIN mst_equipment AS mst ON mst.equipment_cd::text = equip_info ->> ''cd''
CROSS JOIN (
  SELECT
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_EQUIPMENT'') AS hosp_get_cd,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_CONV_UNIT_EQUIP'' AND key2 = ''個'') AS unit
  ) AS ini_value
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
)
,
dial_diff_info AS (
-- 透析困難コード
SELECT
  CASE ini_value.hosp_get_cd
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
  END AS cd,
  1 AS amount,
  '''' AS unit
FROM
  auth_info ai
LEFT JOIN mst_dialysis_difficulty AS mst ON mst.dialysis_difficulty_cd::text = ai.dial_diff_cd
CROSS JOIN (
  SELECT
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_DIALYSIS_DIFFICULTY'') AS hosp_get_cd
  ) AS ini_value
)
,
union_table AS (
SELECT
  ''治療方法'' AS title,
  tre.cd AS cd,
  tre.amount AS amount,
  tre.unit AS unit
FROM 
  ind_treatment tre
UNION ALL
SELECT
  ''透析困難コード'' AS title,
  ddi.cd AS cd,
  ddi.amount AS amount,
  ddi.unit AS unit
FROM 
  dial_diff_info ddi
WHERE
  cd IS NOT NULL
UNION ALL
SELECT
  ''手技コード'' AS title,
  pro.cd AS cd,
  pro.amount AS amount,
  pro.unit AS unit
FROM 
  ind_procedure pro
WHERE
  cd IS NOT NULL
UNION ALL
SELECT
  ''ダイアライザ'' AS title,
  dia.cd AS cd,
  dia.amount AS amount,
  dia.unit AS unit
FROM 
  ind_dialyzer dia
WHERE
  cd IS NOT NULL
UNION ALL
SELECT
  ''吸着カラム'' AS title,
  ads.cd AS cd,
  ads.amount AS amount,
  ads.unit AS unit
FROM 
  ind_adsorption ads
WHERE
  cd IS NOT NULL
UNION ALL
SELECT
  ''1次膜'' AS title,
  one.cd AS cd,
  one.amount AS amount,
  one.unit AS unit
FROM 
  ind_one_film one
WHERE
  cd IS NOT NULL
UNION ALL
SELECT
  ''2次膜'' AS title,
  two.cd AS cd,
  two.amount AS amount,
  two.unit AS unit
FROM 
  ind_two_film two
WHERE
  cd IS NOT NULL
UNION ALL
SELECT
  ''医療材料'' AS title,
  equ.cd AS cd,
  equ.amount AS amount,
  equ.unit AS unit
FROM 
  ind_equip_info equ
WHERE
  cd IS NOT NULL
UNION ALL
SELECT
  ''抗凝固剤'' AS title,
  coa.cd AS cd,
  coa.amount AS amount,
  coa.unit AS unit
FROM 
  ind_coagulant coa
WHERE
  cd IS NOT NULL
UNION ALL
SELECT
  ''透析液'' AS title,
  tou.cd AS cd,
  tou.amount AS amount,
  tou.unit AS unit
FROM 
  ind_touseki tou
WHERE
  cd IS NOT NULL
UNION ALL
SELECT
  ''補液'' AS title,
  hoe.cd AS cd,
  hoe.amount AS amount,
  hoe.unit AS unit
FROM 
  ind_hoeki hoe
WHERE
  cd IS NOT NULL
UNION ALL
SELECT
  ''投与薬剤情報'' AS title,
  med.cd AS cd,
  med.amount AS amount,
  med.unit AS unit
FROM 
  ind_medi_info med
WHERE
  cd IS NOT NULL
)
,
union_num AS (
SELECT
  DISTINCT ON (un.cd) un.cd AS cd,
  un.r_num
FROM
  (SELECT
    ROW_NUMBER() OVER () AS r_num,
    ut.cd
  FROM
    union_table ut
) AS un
ORDER BY un.cd, un.r_num
)
,
final_t AS (
SELECT
  fin.cd AS cd,
  fin.amount AS amount,
  fin.unit AS unit
FROM
  (SELECT
    ut.cd,
    SUM(DISTINCT ut.amount) AS amount,
    ut.unit
  FROM
    union_table ut
  GROUP BY
    ut.cd,
    ut.unit
) AS fin
INNER JOIN union_num AS un ON un.cd = fin.cd
ORDER BY un.r_num
)
SELECT
  ((ROW_NUMBER() OVER () - 1) / 20) + 1 AS rp_no,
  (ROW_NUMBER() OVER () - 1) % 20 + 1 AS item_no,
  ft.cd AS cd,
  ft.amount AS amount,
  ft.unit AS unit
FROM
  final_t ft', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)セコムの透析指示_処置項目情報取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1102004, "field_name": "pat_personal_info", "replace_var": "@patPersonalInfo"}]'::jsonb);
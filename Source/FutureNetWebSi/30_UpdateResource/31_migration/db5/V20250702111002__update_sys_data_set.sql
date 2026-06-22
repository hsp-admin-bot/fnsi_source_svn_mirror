delete from ntss.sys_data_set
where sql_cd in (-1102015,-1100000);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1102015, 'WITH RECURSIVE coop_ini_info AS (
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
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''MEDICINE_SEND_TYPE'') AS medicine_send_type
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
  (t1.info ->> ''cd'')::integer AS medi_cd,
  mst.is_shot AS is_shot
FROM
  mst_medicine_mix mix
CROSS JOIN LATERAL json_array_elements(mix.mix_info ::json) WITH ORDINALITY AS t1(info, idx)
INNER JOIN mst_medicine AS mst ON mst.medicine_cd::text = info ->> ''cd''
    AND mst.is_shot = ''0''
WHERE
  mix.is_del = ''0''
  AND mix.facility_cd = @facilityCd
)
, ind_treatment AS (
-- 治療方法コード
SELECT
  mt.treatment_cd AS mst_cd
FROM
  ord_main om
INNER JOIN mst_treatment AS mt ON
  mt.treatment_cd = om.ind_treatment_cd
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
)
, ind_dialyzer AS (
-- ダイアライザ
SELECT
  mst.dialyzer_cd AS mst_cd
FROM
  ord_main om
INNER JOIN mst_dialyzer AS mst ON mst.dialyzer_cd::text = om.ind_cond_info->''5''->>''value''
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
)
, ind_adsorption AS (
-- 吸着カラム
SELECT
  COALESCE(mst.equipment_cd) AS mst_cd
FROM
  ord_main om
INNER JOIN mst_equipment AS mst ON mst.equipment_cd::text = om.ind_cond_info->''6''->>''value''
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
)
, ind_coagulant AS (
-- 抗凝固剤
SELECT
  CASE
    om.ind_cond_info->''25''->>''medicine_type''
    WHEN ''1'' THEN mst_medi.medicine_cd
    WHEN ''2'' THEN mst_mix.medi_cd
    ELSE NULL
  END AS mst_cd
FROM
  ord_main om
LEFT JOIN mst_medicine AS mst_medi ON mst_medi.medicine_cd::text = om.ind_cond_info->''25''->>''value''
  AND mst_medi.is_shot = ''0''
  AND om.ind_cond_info->''25''->>''medicine_type''::text = ''1''
LEFT JOIN mst_medi_mix AS mst_mix ON mst_mix.mix_cd::text = om.ind_cond_info->''25''->>''value''
  AND om.ind_cond_info->''25''->>''medicine_type''::text = ''2''
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
)
, ind_touseki AS (
-- 透析液
SELECT
  CASE
    om.ind_cond_info->''15''->>''medicine_type''
    WHEN ''1'' THEN mst_medi.medicine_cd
    WHEN ''2'' THEN mst_mix.medi_cd
    ELSE NULL
  END AS mst_cd
FROM
  ord_main om
LEFT JOIN mst_medicine AS mst_medi ON mst_medi.medicine_cd::text = om.ind_cond_info->''15''->>''value''
  AND mst_medi.is_shot = ''0''
  AND om.ind_cond_info->''15''->>''medicine_type''::text = ''1''
LEFT JOIN mst_medi_mix AS mst_mix ON mst_mix.mix_cd::text = om.ind_cond_info->''15''->>''value''
  AND om.ind_cond_info->''15''->>''medicine_type''::text = ''2''
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
)
, ind_hoeki AS (
-- 補液
SELECT
  CASE
    om.ind_cond_info->''19''->>''medicine_type''
    WHEN ''1'' THEN mst_medi.medicine_cd
    WHEN ''2'' THEN mst_mix.medi_cd
    ELSE NULL
  END AS mst_cd
FROM
  ord_main om
LEFT JOIN mst_medicine AS mst_medi ON mst_medi.medicine_cd::text = om.ind_cond_info->''19''->>''value''
  AND mst_medi.is_shot = ''0''
  AND om.ind_cond_info->''19''->>''medicine_type''::text = ''1''
LEFT JOIN mst_medi_mix AS mst_mix ON mst_mix.mix_cd::text = om.ind_cond_info->''19''->>''value''
  AND om.ind_cond_info->''19''->>''medicine_type''::text = ''2''
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
)
, ind_one_film AS (
-- 1次膜
SELECT
  COALESCE(mst.equipment_cd) AS mst_cd
FROM
  ord_main om
INNER JOIN mst_equipment AS mst ON
  mst.equipment_cd::text = om.ind_cond_info->''7''->>''value''
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
)
, ind_two_film AS (
-- 2次膜
SELECT
  COALESCE(mst.equipment_cd) AS mst_cd
FROM
  ord_main om
INNER JOIN mst_equipment AS mst ON mst.equipment_cd::text = om.ind_cond_info->''8''->>''value''
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
)
, medi_indo AS (
-- 投与薬剤情報
SELECT
  CASE
    t1.medi_info ->> ''medicine_type''
    WHEN ''1'' THEN mst_medi.medicine_cd
    WHEN ''2'' THEN mst_mix.mix_cd
    ELSE NULL
  END AS mst_cd,
  COALESCE((t1.medi_info ->> ''procedure_cd'')::integer) AS procedure_cd,
  CASE
    t1.medi_info ->> ''medicine_type''
    WHEN ''1'' THEN mst_medi.is_shot
    WHEN ''2'' THEN mst_mix.is_shot
    ELSE NULL
  END AS is_shot
FROM
  ord_main om
CROSS JOIN LATERAL json_array_elements(om.ind_medi_info::json) WITH ORDINALITY AS t1(medi_info, idx)
LEFT JOIN mst_medicine AS mst_medi ON mst_medi.medicine_cd::text = medi_info ->> ''cd''
  AND medi_info ->> ''medicine_type''::text = ''1''
LEFT JOIN mst_medi_mix AS mst_mix ON mst_mix.mix_cd::text = medi_info ->> ''cd''
  AND medi_info ->> ''medicine_type''::text = ''2''
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
)
, ind_equip_info AS (
-- 医療材料コード
SELECT
  COALESCE(mst.equipment_cd) AS mst_cd
FROM
  ord_main om
CROSS JOIN LATERAL json_array_elements(om.ind_equip_info ::json) WITH ORDINALITY AS t1(equip_info, idx)
INNER JOIN mst_equipment AS mst ON
  mst.equipment_cd::text = t1.equip_info ->> ''cd''
WHERE
  om.is_del = ''0''
  AND om.ord_no = @ordNo
  AND om.pat_id = @patId
)
, dial_diff_info AS (
-- 透析困難コード
SELECT
  COALESCE(mst.dialysis_difficulty_cd) AS mst_cd
FROM
  auth_info ai
LEFT JOIN mst_dialysis_difficulty AS mst ON mst.dialysis_difficulty_cd::text = ai.dial_diff_cd
  AND mst.is_del = ''0''
WHERE
  ai.is_dial_diff = ''1''
)
, medi_union_1 AS (
-- 薬剤情報（抗凝固剤、透析液、補液、投与薬剤情報(手技なし)）
SELECT
  title,
  mst_cd
FROM
  (SELECT
    ''抗凝固剤'' AS title,
    coa.mst_cd AS mst_cd
  FROM
    ind_coagulant coa
  WHERE
    coa.mst_cd IS NOT NULL
UNION ALL
  SELECT
    ''透析液'' AS title,
    tou.mst_cd AS mst_cd
  FROM
    ind_touseki tou
  WHERE
    tou.mst_cd IS NOT NULL
UNION ALL
  SELECT
    ''補液'' AS title,
    hoe.mst_cd AS mst_cd
  FROM
    ind_hoeki hoe
  WHERE
    hoe.mst_cd IS NOT NULL
UNION ALL
  SELECT
    ''投与薬剤情報(手技なし）'' AS title,
    imi.mst_cd AS mst_cd
  FROM
    medi_indo imi
  WHERE
    imi.mst_cd IS NOT NULL
    AND imi.is_shot = ''0''
    AND imi.procedure_cd IS NULL
) AS ind_medi_table
)
, medi_union_2 AS (
-- 薬剤情報（投与薬剤情報(手技あり)）
SELECT
  title,
  mst_cd,
  proc_cd
FROM
  (SELECT
    ''投与薬剤情報(薬剤）'' AS title,
    imi2.mst_cd AS mst_cd,
    mst.procedure_cd AS proc_cd
  FROM
    medi_indo imi2
  INNER JOIN mst_procedure AS mst ON mst.procedure_cd = imi2.procedure_cd
  WHERE
    imi2.mst_cd IS NOT NULL
    AND imi2.is_shot = ''0''
    AND imi2.procedure_cd IS NOT NULL
) AS ind_medi_table
)
, equip_union AS (
-- 医療材料情報（吸着カラム,1次膜,2次膜,医療材料情報）
SELECT
  title,
  mst_cd
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
)
, equip_sort_union AS (
-- 医療材料情報の合算とソート
SELECT
  ams.title,
  ams.mst_cd AS mst_cd,
  NULL AS proc_cd
FROM
  (SELECT
    STRING_AGG(DISTINCT title, ''-'') AS title,
    mst_cd
  FROM
    equip_union
  GROUP BY
    mst_cd
) AS ams
)
, union_table AS (
-- 全項目をUNION ALL
SELECT
  ''治療方法'' AS title,
  tre.mst_cd AS mst_cd,
  NULL AS proc_cd
FROM
  ind_treatment tre
UNION ALL
SELECT
  ''透析困難コード'' AS title,
  ddi.mst_cd AS mst_cd,
  NULL AS proc_cd
FROM
  dial_diff_info ddi
WHERE
  ddi.mst_cd IS NOT NULL
UNION ALL
SELECT
  ''ダイアライザ'' AS title,
  dia.mst_cd AS mst_cd,
  NULL AS proc_cd
FROM
  ind_dialyzer dia
WHERE
  dia.mst_cd IS NOT NULL
UNION ALL
SELECT
  eu.title AS title,
  eu.mst_cd AS mst_cd,
  NULL AS proc_cd
FROM
  equip_sort_union eu
WHERE
  eu.mst_cd IS NOT NULL
UNION ALL
SELECT
  mu1.title AS title,
  mu1.mst_cd AS mst_cd,
  NULL AS proc_cd
FROM
  medi_union_1 mu1
WHERE
  mu1.mst_cd IS NOT NULL
UNION ALL
SELECT
  mu2.title AS title,
  mu2.mst_cd AS mst_cd,
  mu2.proc_cd::text AS proc_cd
FROM
  medi_union_2 mu2
WHERE
  mu2.mst_cd IS NOT NULL
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
  n.mst_cd,
  n.proc_cd,
  1 AS RP,
  1 AS RpItem,
  NULL::text AS last_proc_cd,
  ARRAY[]::text[] AS proc_cd_list,
  FALSE AS need_procedure_insert,
  FALSE AS need_treatment_insert
FROM
  numbered n
WHERE
  n.rn = 1
UNION ALL
SELECT
  n.rn,
  n.title,
  n.mst_cd,
  n.proc_cd,
  CASE
    WHEN m.medicine_send_type::NUMERIC = 1
      AND n.proc_cd IS NOT NULL
      AND NOT (n.proc_cd = ANY(r.proc_cd_list))
          THEN r.RP + 1
    WHEN r.RpItem >= 10 OR (m.medicine_send_type::NUMERIC = 0
      AND n.proc_cd IS NOT NULL)
          THEN r.RP + 1
    ELSE r.RP
  END AS RP,
  CASE
    WHEN ((m.medicine_send_type::NUMERIC = 1 AND n.proc_cd IS NOT NULL
        AND NOT (n.proc_cd = ANY(r.proc_cd_list)))
      OR (r.RpItem >= 10 OR (m.medicine_send_type::NUMERIC = 0
        AND n.proc_cd IS NOT NULL))
        ) THEN 2
    ELSE r.RpItem + 1
  END AS RpItem,
  CASE
    WHEN n.proc_cd IS NOT NULL THEN n.proc_cd
    ELSE r.last_proc_cd
  END AS last_proc_cd,
  CASE
    WHEN n.proc_cd IS NOT NULL AND NOT (n.proc_cd = ANY(r.proc_cd_list))
          THEN r.proc_cd_list || n.proc_cd
    ELSE r.proc_cd_list
  END AS proc_cd_list,
  CASE
    WHEN((m.medicine_send_type::NUMERIC = 1 AND n.proc_cd IS NOT NULL
      AND NOT (n.proc_cd = ANY(r.proc_cd_list)))
      OR (m.medicine_send_type::NUMERIC = 0 AND n.proc_cd IS NOT NULL)
      OR r.RpItem >= 10 AND n.proc_cd IS NOT NULL
        ) THEN TRUE
    ELSE FALSE
  END AS need_procedure_insert,
  CASE
    WHEN r.RpItem >= 10 AND n.proc_cd IS NULL THEN TRUE
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
  last_proc_cd::integer AS mst_cd,
  NULL::text AS proc_cd
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
  tre.mst_cd AS mst_cd,
  NULL::text AS proc_cd
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
  mst_cd,
  proc_cd
FROM
  recursive_rp
)
, final_data AS (
SELECT
  RP,
  RpItem,
  title,
  mst_cd,
  proc_cd
FROM
  recursive_rp_with_sort
UNION ALL
SELECT
  RP,
  RpItem,
  title,
  mst_cd,
  proc_cd
FROM
  procedure_inserts
UNION ALL
SELECT
  RP,
  RpItem,
  title,
  mst_cd,
  proc_cd
FROM
  treatment_inserts
)
SELECT
  RP as rp_no,
  ''01'' as detail_id
FROM
  final_data
GROUP BY RP
ORDER BY RP', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)セコムの透析指示連携_処置依頼ファイル_処置単位のRP番号取得', '2025-06-26 17:23:48.129', CURRENT_TIMESTAMP, '[{"sql_cd": -1102004, "field_name": "pat_personal_info", "replace_var": "@patPersonalInfo"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1100000, 'WITH all_values AS (
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
    ''SCM_XRAY_ORDER_SEND'',
    ''SCM_CONV_UNIT_MEDI''
    )
)
, jounal AS (
SELECT
  to_char(reg_date, ''YYYY-MM-DD'') AS occur_date,
  to_char(reg_date, ''HH24:MI:SS'') AS occur_time
FROM
  sys_coop_journal
WHERE
  ctl_no = @ctlNo
)
SELECT
  ini_value.hospital_id AS hospital_id,
  ini_value.course_cd1 AS course_cd1,
  ini_value.course_cd2 AS course_cd2,
  ini_value.unit_medi AS unit_medi,
  ini_value.xx_type_code AS xx_type_code
FROM
  (SELECT
    (SELECT value FROM all_values WHERE key1 = ''SCM_COMMON'' AND key2 = ''HOSPITAL_ID'') AS hospital_id,
    (SELECT value FROM all_values WHERE key1 = ''SCM_COMMON'' AND key2 = ''COURSE_CD1'') AS course_cd1,
    (SELECT value FROM all_values WHERE key1 = ''SCM_COMMON'' AND key2 = ''COURSE_CD2'') AS course_cd2,
    (SELECT value FROM all_values WHERE key1 = ''SCM_CONV_UNIT_MEDI'' AND key2 = ''ml'') AS unit_medi,
    (SELECT value FROM all_values WHERE key1 = ''SCM_COMMON'' AND key2 = ''XX_TYPE_CODE'') AS xx_type_code
  ) AS ini_value
CROSS JOIN jounal', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Secom連携汎用_連携設定、検査日時、発生日取得', '2025-06-03 08:30:43.103', CURRENT_TIMESTAMP, NULL);
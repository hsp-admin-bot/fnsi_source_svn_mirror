DELETE FROM ntss.sys_data_set
WHERE sql_cd in (-1103004);


INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1103004, 'WITH RECURSIVE coop_ini_info AS (
--連携設定から取得
SELECT
  COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value,
  info ->> ''key1'' AS key1,
  info ->> ''key2'' AS key2
FROM
  mst_coop_ini AS ini
CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
WHERE
  ini.facility_cd = @facilityCd
  AND ini.is_del = ''0''
  AND COALESCE(info ->> ''key0'', '''') = @key0
  AND info ->> ''key1'' IN(
            ''SCM_CONV_UNIT_MEDI'',
            ''SCM_IN_HOSPITAL_CD'',
            ''SCM_COMMON''            
        )
)
, ini_unit AS (
    SELECT
        key2,
        value
    FROM
        coop_ini_info
    WHERE
        key1 = ''SCM_CONV_UNIT_MEDI''
)

, ini_value AS(
--連携設定取得値
SELECT
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_MEDICINE'') AS hosp_get_mst_medicine,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_PROCEDURE'') AS hosp_get_mst_procedure
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
  mst.in_hospital_cd_4 AS in_hospital_cd_4,
  mst.is_disp as is_disp,
  mst.is_del as is_del  
FROM
  mst_medicine_mix mix
CROSS JOIN LATERAL json_array_elements(mix.mix_info ::json) WITH ORDINALITY AS t1(info, idx)
INNER JOIN mst_medicine AS mst ON mst.medicine_cd::text = info ->> ''cd''
  AND mst.is_shot = ''1''
  AND mst.is_del = ''0''
  AND mst.is_disp = ''1''
WHERE
  mix.is_del = ''0''
  AND mix.facility_cd = @facilityCd
  AND mst.facility_cd = @facilityCd
)
, do_ord_main AS (
(SELECT
  res.del_date as up_date_switch,
  res.rst_medi_info AS rst_medi_info,
  res.treat_date::TIMESTAMP AS treat_date
FROM ord_main_restore as res
JOIN sys_coop_journal AS journal ON res.ord_no = journal.ord_no
WHERE res.ord_no = @ordNo
  AND res.facility_cd = @facilityCd
  AND journal.facility_cd = @facilityCd
  AND journal.ctl_no = @ctlNo
  --AND res.ord_no = journal.ord_no
  AND journal.reg_date >= res.del_date
ORDER BY res.del_date DESC LIMIT 1
)
UNION
(SELECT
  main.rst_edition_date as up_date_switch,
  main.rst_medi_info AS rst_medi_info,
  main.treat_date::TIMESTAMP AS treat_date
FROM ord_main AS main
  WHERE main.ord_no = @ordNo
  AND main.facility_cd = @facilityCd
)
ORDER BY
  up_date_switch DESC NULLS LAST
LIMIT 1
)
, medi_indo AS (
-- 投与薬剤情報
SELECT
  t1.idx as idx,
  t1.medi_info ->> ''cd'' AS mst_cd,
  CASE
    WHEN (om.treat_date >= mst_pro.in_hosp_a_startdate) 
      AND (om.treat_date >= mst_pro.in_hosp_b_startdate) THEN
      CASE
        WHEN mst_pro.in_hosp_a_startdate >= mst_pro.in_hosp_b_startdate THEN
          CASE ini_value.hosp_get_mst_procedure
            WHEN ''1'' THEN mst_pro.in_hospital_cd_a1
            WHEN ''2'' THEN mst_pro.in_hospital_cd_a2
          END
        WHEN mst_pro.in_hosp_a_startdate < mst_pro.in_hosp_b_startdate THEN
          CASE ini_value.hosp_get_mst_procedure
            WHEN ''1'' THEN mst_pro.in_hospital_cd_b1
            WHEN ''2'' THEN mst_pro.in_hospital_cd_b2
          END
      END
    WHEN om.treat_date >= mst_pro.in_hosp_a_startdate THEN
      CASE ini_value.hosp_get_mst_procedure
        WHEN ''1'' THEN mst_pro.in_hospital_cd_a1
        WHEN ''2'' THEN mst_pro.in_hospital_cd_a2
      END
    WHEN om.treat_date >= mst_pro.in_hosp_b_startdate THEN
      CASE ini_value.hosp_get_mst_procedure
        WHEN ''1'' THEN mst_pro.in_hospital_cd_b1
        WHEN ''2'' THEN mst_pro.in_hospital_cd_b2
      END
    ELSE NULL
  END AS pro_hosp_cd,
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
        WHEN ''1'' THEN (medi_info ->> ''amount'')::numeric
        WHEN ''2'' THEN
          CASE mst_mix.solvent
            WHEN ''0'' THEN
              (medi_info ->> ''amount'')::numeric * mst_mix.amount::numeric
            WHEN ''1'' THEN
              mst_mix.amount::numeric
          END
        ELSE 0
      END
  END AS amount,
  CASE
    WHEN json_array_length(om.rst_medi_info::json) = 0 THEN NULL
    ELSE
          CASE t1.medi_info ->> ''medicine_type''
            WHEN ''1'' THEN mst_medi.unit
            WHEN ''2'' THEN mst_mix.unit
          END
  END AS unit,
  CASE
    WHEN json_array_length(om.rst_medi_info::json) = 0 THEN NULL
    ELSE
      CASE t1.medi_info ->> ''medicine_type''
        WHEN ''1'' THEN mst_medi.is_shot
        WHEN ''2'' THEN mst_mix.is_shot
      END
  END AS is_shot,
  CASE t1.medi_info ->> ''medicine_type''
    WHEN ''1'' THEN mst_medi.is_disp 
    WHEN ''2'' THEN mst_mix.is_disp 
  END AS is_disp
FROM
  do_ord_main om
CROSS JOIN LATERAL json_array_elements(om.rst_medi_info::json) WITH ORDINALITY AS t1(medi_info, idx)
LEFT JOIN mst_medicine AS mst_medi ON mst_medi.medicine_cd::text = medi_info ->> ''cd''
  AND medi_info ->> ''medicine_type''::text = ''1'' AND mst_medi.facility_cd = @facilityCd
LEFT JOIN mst_medi_mix AS mst_mix ON mst_mix.mix_cd::text = medi_info ->> ''cd''
  AND medi_info ->> ''medicine_type''::text = ''2''
LEFT JOIN mst_procedure AS mst_pro ON mst_pro.procedure_cd::text = t1.medi_info ->> ''procedure_cd'' AND mst_pro.facility_cd = @facilityCd
CROSS JOIN ini_value
WHERE
  medi_info ->> ''effect_flg'' = ''1''

  AND (
    (medi_info ->> ''medicine_type''::text = ''1'' AND  mst_medi.is_del = ''0'')
    OR
    (medi_info ->> ''medicine_type''::text = ''2'' AND  mst_mix.is_del = ''0'')
  )
  
)
-- 送信履歴メモ.memoから取得
, memo_text AS (
SELECT
  save_2->>''memo'' AS memo
FROM
  pat_coop_detail
WHERE
  pat_id = @patId
  AND save_2->>''coop_cd'' = ''ind_dial''
  AND pat_coop_detail.facility_cd = @facilityCd
  AND save_2->>''ord_no'' = @ordNo::text
ORDER BY
  up_date DESC
LIMIT 1
)
, bounds AS (
SELECT
  memo,
  POSITION(''#I|'' IN memo) AS i_pos,
  POSITION(''#K'' IN memo) AS k_pos
FROM
  memo_text
)
, extracted AS (
SELECT
  substring(memo FROM i_pos + 3 FOR k_pos - (i_pos + 3)) AS i_segment
FROM
  bounds
)
, split_parts AS (
SELECT
  string_to_array(i_segment, ''|'') AS parts
FROM
  extracted
)
, item_info AS (
SELECT
  parts[i] AS item_value,
  i - 4 AS item_index
FROM
  split_parts,
  generate_series(5, CARDINALITY(parts)) AS i
)
, get_items AS (
SELECT
  item_index,
  item_value,
  substring(item_value FROM 1 FOR 2) AS rp_no,
  substring(item_value FROM 3 FOR 2) AS technique,
  substring(item_value FROM 5 FOR 2) AS med_no,
  substring(item_value FROM 7 FOR 6) AS med_code
FROM
  item_info
)
-- 同手技同薬剤コードは一つだけ出力
, get_items_total AS (
  SELECT DISTINCT ON (technique, med_code) *
    FROM get_items
    ORDER BY technique, med_code, item_index
)
-- コード桁数処理
, medi_indo_mi_cut AS (
  SELECT
    *,
    CASE
      WHEN octet_length(hosp_cd) <= 4 THEN hosp_cd
      ELSE (
        SELECT substring(hosp_cd FROM MIN(i))
        FROM generate_series(1, char_length(hosp_cd)) AS i
        WHERE octet_length(substring(hosp_cd FROM i)) <= 6
      )
    END AS hosp_cd_trimmed,
    RIGHT(pro_hosp_cd, 2) as pro_hosp_cd_trimmed    
  FROM medi_indo
),
 unit_choice AS (
  SELECT DISTINCT ON (hosp_cd_trimmed, pro_hosp_cd_trimmed)
    hosp_cd_trimmed,
    pro_hosp_cd,
    unit
  FROM medi_indo_mi_cut
  WHERE is_shot = ''1'' AND is_disp = ''1''
  ORDER BY hosp_cd_trimmed, pro_hosp_cd_trimmed, idx
)

,select_seq AS (
  select
  gi.rp_no::numeric AS rp_no,
  gi.med_no::numeric AS medi_no,
  mi.hosp_cd_trimmed AS medi_cd,
  LEAST(SUM(TRUNC(mi.amount, 2)::FLOAT8), 9999999.99)::text AS amount,
  MIN(ini_unit.value) AS unit,
  mi.pro_hosp_cd as pro_hosp_cd
FROM
  get_items_total gi
INNER JOIN medi_indo_mi_cut AS mi ON gi.med_code = LPAD(mi.hosp_cd_trimmed, 6,'' '')
  AND gi.technique = LPAD(pro_hosp_cd_trimmed, 2,'' '')
LEFT JOIN unit_choice uc
  ON mi.hosp_cd_trimmed = uc.hosp_cd_trimmed
  AND mi.pro_hosp_cd = uc.pro_hosp_cd
LEFT JOIN ini_unit
  ON uc.unit = ini_unit.key2
WHERE
  mi.is_shot = ''1'' and 
  mi.is_disp = ''1''
  
GROUP BY gi.rp_no, gi.med_no, mi.hosp_cd_trimmed, mi.pro_hosp_cd, ini_unit.value

ORDER BY rp_no, medi_no
)
SELECT DISTINCT
  ''01'' AS detail_id,
  rp_no
FROM
  select_seq
WHERE EXISTS (
  SELECT 1 FROM select_seq
)
ORDER BY
  rp_no', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)セコムの透析実績連携', '2025-07-16 14:50:48.578', CURRENT_TIMESTAMP, NULL);

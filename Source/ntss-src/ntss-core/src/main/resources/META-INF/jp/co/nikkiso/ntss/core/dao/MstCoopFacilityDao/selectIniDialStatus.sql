WITH common_setting AS (
  SELECT
    ((common_setting->>'coop_ope_cd') ::JSONB)->>'ope_cd_receive' AS ope_cd_receive
    , common_setting->>'coop_ord_cd' AS coop_ord_cd
  FROM
    mst_coop_facility
  WHERE
    is_del = '0'
    AND is_disp = '1'
    AND facility_cd = /*facilityCd*/null
)
, ini_dial_ope_cd AS (
  SELECT
    json_array_elements((info->>'ope_cd') ::JSON) AS ope_cd
  FROM
    common_setting
    CROSS JOIN LATERAL json_array_elements(coop_ord_cd ::json) AS info
  WHERE
    info->>'coop_cd' ::TEXT = 'ini_dial'
-- add 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
    AND (info->>'coop_version' IS NULL OR (info->>'coop_version' IS NOT NULL AND info->>'coop_version'::TEXT = /*coopVersion*/null))
-- add 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
)
SELECT
  info->>'status' AS status
FROM
  common_setting
  CROSS JOIN LATERAL json_array_elements(ope_cd_receive ::json) AS info
WHERE
  EXISTS (
    SELECT
      1
    FROM
      ini_dial_ope_cd AS T01
    WHERE
      info->>'ope_cd' = TRIM(T01.ope_cd ::TEXT, '"')
  )

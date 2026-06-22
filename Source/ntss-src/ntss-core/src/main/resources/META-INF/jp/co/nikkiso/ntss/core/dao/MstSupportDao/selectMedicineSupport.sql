SELECT
  medicine_support_cd,
  facility_cd,
  medicine_support_name,
  target_inspection,
  detail_info,
  is_disp,
  is_del
FROM
  mst_medicine_support A
-- ADD 7744 投与支援の並び順が適用されない 周安寧 START
LEFT OUTER JOIN (
SELECT
  row_number() over() as index,
  *
FROM
  jsonb_to_recordset((
    SELECT
      order_settings->'items'
    FROM
      mst_selector
    WHERE
      facility_cd = /*facilityCd*/'1'
    AND
      master_physical_name = 'mst_medicine_support'
  )) AS mb(code bigint, name text)
) AS sort_medicine_support
ON A.medicine_support_cd = sort_medicine_support.code
-- ADD 7744 投与支援の並び順が適用されない 周安寧 END
WHERE
  facility_cd = /*facilityCd*/'999999'
  AND is_del = '0'
ORDER BY
-- MOD 7744 投与支援の並び順が適用されない 周安寧 START
  --medicine_support_cd
  sort_medicine_support.index,A.medicine_support_cd
-- MOD 7744 投与支援の並び順が適用されない 周安寧 END
;

SELECT
  jsonb_array_elements ( ( detail_info ->> 'medicineAverage' ) :: jsonb ) ->> 'value' AS detail_info_value,
  jsonb_array_elements ( ( detail_info ->> 'medicineAverage' ) :: jsonb ) ->> 'type' AS detail_info_type,
  jsonb_array_elements ( ( detail_info ->> 'medicineAverage' ) :: jsonb ) ->> 'text' AS detail_info_text
FROM
  mst_medicine_support mms
WHERE
  mms.medicine_support_cd = /*cd*/'10'
  AND mms.is_del = '0'
  -- DEL 7744 投与支援の並び順が適用されない 周安寧 START
--ORDER BY
 -- detail_info_type
  -- DEL 7744 投与支援の並び順が適用されない 周安寧 END

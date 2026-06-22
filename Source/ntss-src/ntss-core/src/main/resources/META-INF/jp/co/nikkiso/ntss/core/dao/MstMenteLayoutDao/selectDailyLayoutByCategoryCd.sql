SELECT
  mml.mainte_layout_cd,
  mml.edition_no,
  mml.facility_cd,
  mml.layout_class,
  mml.layout_name,
  mml.detail_info_1,
  mml.is_disp,
  mml.is_del,
  mml.up_date,
  mml.reg_date,
  mml.layout_header
FROM
  mst_mainte_layout mml
WHERE
  mml.facility_cd = /* facilityCd */'000000'
  AND
  mml.layout_class = '1'
  AND
  mml.is_del = '0'
  AND
  mml.is_disp = '1'
  AND
  EXISTS (
    SELECT detail_info
    FROM
      jsonb_array_elements(mml.detail_info_1) as detail_info
    WHERE
      detail_info ->> 'isDisp' = 'true'
      AND
      (detail_info ->> 'cd')::bigint = /* mainteCategoryCd */0
  )
;

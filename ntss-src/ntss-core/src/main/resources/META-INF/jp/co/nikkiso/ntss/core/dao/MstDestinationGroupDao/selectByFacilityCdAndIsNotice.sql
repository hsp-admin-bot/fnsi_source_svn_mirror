SELECT
  destination_group_cd,
  facility_cd,
  destination_target
FROM
  mst_destination_group
WHERE
  facility_cd = /*facilityCd*/'1'
AND
  is_notice = '1'
AND
  is_disp = '1'
;
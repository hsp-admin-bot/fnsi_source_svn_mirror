SELECT
  /*%expand*/*
FROM
  mst_destination_group
WHERE
  facility_cd = /*facilityCd*/'1'
ORDER BY
  destination_group_cd
;

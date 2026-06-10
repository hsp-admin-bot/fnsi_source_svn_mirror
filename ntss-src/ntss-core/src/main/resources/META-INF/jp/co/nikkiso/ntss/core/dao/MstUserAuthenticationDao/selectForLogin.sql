SELECT
  /*%expand*/*
FROM
  mst_user_authentication
WHERE
  disp_user_id = /*dispUserId*/'1'
AND
  facility_cd = /*facilityCd*/'999999'
;

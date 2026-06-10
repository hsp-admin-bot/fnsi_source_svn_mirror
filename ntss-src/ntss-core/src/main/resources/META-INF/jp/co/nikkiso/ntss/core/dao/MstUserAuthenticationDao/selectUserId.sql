SELECT
  user_id
FROM
  mst_user_authentication
WHERE
  disp_user_id = /*dispUserId*/'1'
AND
  facility_cd = /*facilityCd*/null
;

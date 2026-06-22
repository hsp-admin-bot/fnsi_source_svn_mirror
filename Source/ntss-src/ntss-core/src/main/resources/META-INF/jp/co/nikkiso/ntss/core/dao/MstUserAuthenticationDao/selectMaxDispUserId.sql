SELECT
  COALESCE(Max(disp_user_id), '')
FROM
  mst_user_authentication
WHERE
  facility_cd = /*facilityCd*/'999999'
AND
  disp_user_id like /*dispUserIdDt*/'' || '%'
;

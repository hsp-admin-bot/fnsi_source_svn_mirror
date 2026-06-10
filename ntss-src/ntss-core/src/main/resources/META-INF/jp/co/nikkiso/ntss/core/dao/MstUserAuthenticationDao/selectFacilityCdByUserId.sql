SELECT
  distinct facility_cd
FROM
  mst_user_authentication
WHERE
  user_id in /* userIds */(1)
;

SELECT
  facility_setting_no,
  value
FROM
  mst_facility_setting
WHERE
  facility_setting_no IN ('3006', '3007')
--mod FNSI-7270 劉全航 start
AND
  facility_cd = /*facilityCd*/null
--mod FNSI-7270 劉全航 end
;

SELECT
   COALESCE(max(equip_info_no),-1)
FROM
  equipment_latest_no
WHERE
  facility_cd = /*facilityCd*/'1'
AND
  pat_id = /*patId*/'1'

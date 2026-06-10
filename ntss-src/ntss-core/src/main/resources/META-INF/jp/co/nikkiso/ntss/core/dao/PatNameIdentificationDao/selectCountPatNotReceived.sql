SELECT 
       count(a.pat_name_id) 
FROM pat_name_identification AS a
WHERE a.receive = '0'
  AND a.pat_id_dst IS NULL
  AND a.is_open = '0'
AND a.facility_cd_dst = /*facility_cd*/'0'

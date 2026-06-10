SELECT 
       count(a.pat_name_id) 
FROM pat_name_identification AS a
WHERE a.approve = '0'
  and a.facility_cd_src = /*facility_cd*/0
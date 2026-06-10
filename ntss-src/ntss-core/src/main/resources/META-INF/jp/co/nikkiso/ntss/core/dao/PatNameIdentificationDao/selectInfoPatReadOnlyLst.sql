SELECT a.pat_id_src AS pat_id
FROM pat_name_identification AS a
WHERE a.facility_cd_dst IN /*lstFacility_cd*/(null)
  AND a.approve = '1'
  AND a.is_open = '1'
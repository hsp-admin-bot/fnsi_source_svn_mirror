SELECT a.facility_cd_dst
FROM pat_name_identification AS a
WHERE a.approve = '1'
  AND a.pat_id_src = /*pat_id_src*/0
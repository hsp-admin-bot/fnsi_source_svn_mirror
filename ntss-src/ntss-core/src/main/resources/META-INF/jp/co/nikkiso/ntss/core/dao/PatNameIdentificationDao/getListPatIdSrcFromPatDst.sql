SELECT a.pat_id_src,a.facility_cd_src
FROM pat_name_identification AS a
WHERE a.approve = '1'
  AND a.receive = '1'
  AND a.is_open = '1'
  AND a.pat_id_dst = /*pat_id_dst*/0

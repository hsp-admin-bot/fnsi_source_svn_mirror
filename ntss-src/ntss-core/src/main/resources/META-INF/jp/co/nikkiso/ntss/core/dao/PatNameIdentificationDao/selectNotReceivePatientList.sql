SELECT a.pat_id_src,
       count(a.pat_id_src) AS not_yet
FROM pat_name_identification AS a
WHERE a.receive = '0'
  AND a.facility_cd_dst = /*loginFacilityCd*/null
  AND (a.pat_id_dst IS NULL OR a.pat_id_dst = 0)
  AND a.approve = '1'
GROUP BY a.pat_id_src
SELECT a.pat_id_src
FROM pat_name_identification AS a
WHERE a.approve = '1'
  AND a.receive = '1'
  AND a.is_open = '1'
  AND a.pat_id_dst in /*pat_id_dst*/(0)
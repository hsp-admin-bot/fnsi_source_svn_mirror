SELECT
   a.pat_name_id,
   a.pat_id_src as pat_id,
   a.facility_cd_src as facility_cd,
   a.receive,
   a.is_open,
   a.sign_up,
   b.facility_name
FROM
   pat_name_identification AS a
LEFT
JOIN mst_facility AS b
ON b.facility_cd = a.facility_cd_src
WHERE
   a.pat_id_src = /*pat_id_src*/0
AND
   a.facility_cd_dst = /* facility_cd_dst */null
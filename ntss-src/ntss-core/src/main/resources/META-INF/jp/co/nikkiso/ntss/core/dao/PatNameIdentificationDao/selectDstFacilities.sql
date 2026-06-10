SELECT
   a.pat_name_id,
   a.pat_id_dst as pat_id,
   a.facility_cd_dst as facility_cd,
   a.approve,
   a.is_open,
   a.doctor_in_charge,
   a.sign_up,
   b.facility_name
FROM
   pat_name_identification AS a
LEFT
JOIN mst_facility AS b
ON b.facility_cd = a.facility_cd_dst
WHERE
   a.pat_id_src = /* pat_id_src */0
AND
   a.facility_cd_src = /* facility_cd_src */null
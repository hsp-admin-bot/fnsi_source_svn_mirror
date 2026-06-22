SELECT
  /*%expand "A" */*
FROM
  mst_kur A
WHERE
  facility_cd = /* facilityCd */'0'
AND
  in_hospital_cd_1 = /* inHospitalCd1 */'0'
AND
  is_del = '0'
ORDER BY
  kur_start_time ASC
;

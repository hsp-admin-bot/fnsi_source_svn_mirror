SELECT
  dialysis_difficulty_cd
FROM
  mst_dialysis_difficulty
WHERE
  facility_cd = /*facilityCd*/null
AND
  in_hospital_cd_1 = /*inHospitalCd1*/null
AND
  is_disp = '1'
AND
  is_del = '0'

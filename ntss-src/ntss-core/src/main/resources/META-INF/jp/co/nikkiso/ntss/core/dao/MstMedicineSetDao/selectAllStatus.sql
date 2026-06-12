SELECT
  medicine_set_cd AS "medicineSetCd",
  CASE
    WHEN is_disp = '0' THEN '【削除済み含む】' || medicine_set_name
    ELSE medicine_set_name
  END AS "medicineSetName",
  set_info AS "setInfo",
  facility_cd AS "facilityCd",
  in_hospital_cd_1 AS "inHospitalCd_1",
  in_hospital_cd_2 AS "inHospitalCd_2",
  is_disp AS "isDisp",
  is_del AS "isDel"
FROM mst_medicine_set
WHERE facility_cd = /* params.get("facilityCd") */'0'
  AND is_del = '0'
ORDER BY medicine_set_cd;


SELECT
  facility_cd AS "facilityCd",
  medical_institution_cd AS "medicalInstitutionCd",
  facility_name AS "facilityName",
  prefectures_cd AS "prefecturesCd",
  '' AS "deleted"
FROM sys_facility
WHERE 1 = 1
  /*%if params.get("___noop") != null */
  AND 1 = 0
  /*%end*/
ORDER BY facility_cd;


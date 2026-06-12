SELECT
  facility_cd AS "facilityCd",
  facility_cd AS "medicalInstitutionCd",
  facility_name AS "facilityName",
  facility_name_kana AS "facilityNameKana",
  prefectures_cd AS "prefecturesCd",
  '' AS "deleted"
FROM mst_facility
WHERE 1 = 1
  /*%if params.get("___noop") != null */
  AND 1 = 0
  /*%end*/
ORDER BY facility_cd;


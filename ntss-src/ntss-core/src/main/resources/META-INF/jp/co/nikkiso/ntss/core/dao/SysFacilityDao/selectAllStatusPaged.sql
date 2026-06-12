SELECT
  A.facility_cd AS "facilityCd",
  A.medical_institution_cd AS "medicalInstitutionCd",
  A.facility_name AS "facilityName",
  A.prefectures_cd AS "prefecturesCd",
  '' AS "deleted"
FROM sys_facility A
WHERE A.is_del = '0'
  AND A.is_disp = '1'
  /*%if params.containsKey("prefecturesCd") && params.get("prefecturesCd") != null && !params.get("prefecturesCd").isEmpty() && !"0".equals(params.get("prefecturesCd")) */
  AND A.prefectures_cd = /*params.get("prefecturesCd")*/'0'
  /*%end*/
  /*%if params.containsKey("keyword") && params.get("keyword") != null && !params.get("keyword").isEmpty() */
  AND A.facility_name LIKE '%' || /*params.get("keyword")*/'' || '%'
  /*%end*/
ORDER BY A.medical_institution_cd
LIMIT /*params.get("composeLimit")*/100
OFFSET (CAST(/*params.get("composePage")*/'0' AS INTEGER) * CAST(/*params.get("composeLimit")*/'100' AS INTEGER))

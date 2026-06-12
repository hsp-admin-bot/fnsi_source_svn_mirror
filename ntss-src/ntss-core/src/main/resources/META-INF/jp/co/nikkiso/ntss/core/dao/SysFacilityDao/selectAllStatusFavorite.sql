SELECT
  A.facility_cd AS "facilityCd",
  A.medical_institution_cd AS "medicalInstitutionCd",
  A.facility_name AS "facilityName",
  A.prefectures_cd AS "prefecturesCd",
  '' AS "deleted"
FROM sys_facility A
INNER JOIN mst_favorite_facility F
  ON (
    (F.favorite_facility_cd = A.facility_cd)
    OR (
      F.favorite_facility_cd IS NULL
      AND F.medical_institution_cd = A.medical_institution_cd
    )
  )
WHERE A.is_del = '0'
  AND A.is_disp = '1'
  AND F.is_disp = '1'
  AND F.is_del = '0'
  AND F.facility_cd = /*params.get("favoriteOwnerFacilityCd")*/''
ORDER BY A.medical_institution_cd

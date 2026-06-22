SELECT
  A.va_cd        AS "vaCd",
  A.facility_cd  AS "facilityCd",
  A.fn_va_cd     AS "fnVaCd",
  A.va_name      AS "vaName",
  A.va_direct    AS "vaDirect",
  A.in_hospital_cd_1 AS "inHospitalCd1",
  A.in_hospital_cd_2 AS "inHospitalCd2",
  A.is_disp      AS "isDisp",
  A.is_del       AS "isDel",
  A.reg_date     AS "regDate",
  A.up_date      AS "upDate"
FROM mst_va A
WHERE A.va_cd IN /* codeList */(0)
ORDER BY A.va_cd
;


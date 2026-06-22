SELECT
  A.procedure_cd           AS "procedureCd",
  A.facility_cd            AS "facilityCd",
  A.fn_procedure_cd        AS "fnProcedureCd",
  A.pricedure_name         AS "pricedureName",
  A.in_hosp_a_startdate    AS "inHospAStartdate",
  A.in_hosp_b_startdate    AS "inHospBStartdate",
  A.in_hospital_cd_a1      AS "inHospitalCdA1",
  A.in_hospital_cd_a2      AS "inHospitalCdA2",
  A.in_hospital_cd_b1      AS "inHospitalCdB1",
  A.in_hospital_cd_b2      AS "inHospitalCdB2",
  A.is_disp                AS "isDisp",
  A.is_del                 AS "isDel",
  A.reg_date               AS "regDate",
  A.up_date                AS "upDate"
FROM mst_procedure A
WHERE A.procedure_cd IN /* codeList */(0)
ORDER BY A.procedure_cd
;


SELECT
  A.class_cd          AS "classCd",
  A.fn_class_cd       AS "fnClassCd",
  A.class_name        AS "className",
  A.class_type        AS "classType",
  A.in_hospital_cd_1  AS "inHospitalCd1",
  A.is_disp           AS "isDisp",
  A.is_del            AS "isDel",
  A.is_editable       AS "isEditable",
  A.reg_date          AS "regDate",
  A.up_date           AS "upDate"
FROM mst_medicine_class A
WHERE A.class_cd IN /* codeList */(0)
ORDER BY A.class_cd
;


SELECT
  A.equipment_cd          AS "equipmentCd",
  A.facility_cd           AS "facilityCd",
  A.fn_equipment_cd       AS "fnEquipmentCd",
  A.standard_equipment_cd AS "standardEquipmentCd",
  A.is_trial              AS "isTrial",
  A.equipment_name        AS "equipmentName",
  A.equipment_short_name  AS "equipmentShortName",
  A.class_cd              AS "classCd",
  A.unit                  AS "unit",
  A.use_start_date        AS "useStartDate",
  A.use_end_date          AS "useEndDate",
  A.in_hospital_cd_1      AS "inHospitalCd1",
  A.in_hospital_cd_2      AS "inHospitalCd2",
  A.in_hospital_cd_3      AS "inHospitalCd3",
  A.is_disp               AS "isDisp",
  A.is_del                AS "isDel",
  A.reg_date              AS "regDate",
  A.up_date               AS "upDate",
  A.in_hospital_cd_4      AS "inHospitalCd4"
FROM mst_equipment A
WHERE A.equipment_cd IN /* codeList */(0)
ORDER BY A.equipment_cd
;


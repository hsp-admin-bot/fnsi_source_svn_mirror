SELECT
  A.medicine_mix_cd         AS "medicineMixCd",
  A.facility_cd             AS "facilityCd",
  A.medicine_mix_name       AS "medicineMixName",
  A.medicine_mix_short_name AS "medicineMixShortName",
  A.class_cd                AS "classCd",
  A.unit                    AS "unit",
  A.amount_unit             AS "amountUnit",
  A.amount_ml               AS "amountMl",
  A.mix_info                AS "mixInfo",
  A.is_shot                 AS "isShot",
  A.is_medicated            AS "isMedicated",
  A.in_hospital_cd_1        AS "inHospitalCd1",
  A.in_hospital_cd_2        AS "inHospitalCd2",
  A.in_hospital_cd_3        AS "inHospitalCd3",
  A.is_disp                 AS "isDisp",
  A.is_del                  AS "isDel",
  A.reg_date                AS "regDate",
  A.up_date                 AS "upDate",
  A.medicate_timing_cd      AS "medicateTimingCd",
  A.procedure_cd            AS "procedureCd",
  A.unit_decimal_point      AS "unitDecimalPoint",
  A.fn_set_medicine_cd      AS "fnSetMedicineCd"
FROM mst_medicine_mix A
WHERE A.medicine_mix_cd IN /* codeList */(0)
ORDER BY A.medicine_mix_cd
;


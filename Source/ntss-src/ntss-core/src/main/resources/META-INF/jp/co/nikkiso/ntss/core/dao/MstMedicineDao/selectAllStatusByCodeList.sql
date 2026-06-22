SELECT
  A.medicine_cd                   AS "medicineCd",
  A.facility_cd                   AS "facilityCd",
  A.fn_medicine_cd                AS "fnMedicineCd",
  A.standard_medicine_cd          AS "standardMedicineCd",
  A.is_trial                      AS "isTrial",
  A.medicine_name                 AS "medicineName",
  A.medicine_short_name           AS "medicineShortName",
  A.unit                          AS "unit",
  A.unit_second                   AS "unitSecond",
  A.class_cd                      AS "classCd",
  A.is_shot                       AS "isShot",
  A.use_start_date                AS "useStartDate",
  A.use_end_date                  AS "useEndDate",
  A.is_medicated                  AS "isMedicated",
  A.unit_converted_amount         AS "unitConvertedAmount",
  A.unit_converted_amount_second  AS "unitConvertedAmountSecond",
  A.anticoagulant_original_quantity AS "anticoagulantOriginalQuantity",
  A.after_anticoagulant_quantity  AS "afterAnticoagulantQuantity",
  A.in_hospital_cd_1              AS "inHospitalCd1",
  A.in_hospital_cd_2              AS "inHospitalCd2",
  A.in_hospital_cd_3              AS "inHospitalCd3",
  A.in_hospital_cd_4              AS "inHospitalCd4",
  A.is_disp                       AS "isDisp",
  A.is_del                        AS "isDel",
  A.reg_date                      AS "regDate",
  A.up_date                       AS "upDate",
  A.is_exchange                   AS "isExchange",
  A.medicate_timing_cd            AS "medicateTimingCd",
  A.procedure_cd                  AS "procedureCd",
  A.unit_decimal_point            AS "unitDecimalPoint",
  A.unit_decimal_point_second     AS "unitDecimalPointSecond"
FROM mst_medicine A
WHERE A.medicine_cd IN /* codeList */(0)
ORDER BY A.medicine_cd
;


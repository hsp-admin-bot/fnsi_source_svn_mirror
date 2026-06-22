SELECT
  A.dialyzer_cd           AS "dialyzerCd",
  A.facility_cd           AS "facilityCd",
  A.fn_dialyzer_cd        AS "fnDialyzerCd",
  A.maker                 AS "maker",
  A.model_number          AS "modelNumber",
  A.dialyzer_type         AS "dialyzerType",
  A.function_class        AS "functionClass",
  A.area                  AS "area",
  A.ufr                   AS "ufr",
  A.koa                   AS "koa",
  A.material              AS "material",
  A.wetdry                AS "wetdry",
  A.sterilization         AS "sterilization",
  A.ufr_warning_max       AS "ufrWarningMax",
  A.ufr_warning_min       AS "ufrWarningMin",
  A.ufr_warning_reduction AS "ufrWarningReduction",
  A.bloodamt              AS "bloodamt",
  A.alqd_flood_vol        AS "alqdFloodVol",
  A.urea_clearance        AS "ureaClearance",
  A.gas_purge_time        AS "gasPurgeTime",
  A.substituent_wash_amt  AS "substituentWashAmt",
  A.membrane_wash         AS "membraneWash",
  A.in_number             AS "inNumber",
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
FROM mst_dialyzer A
WHERE A.dialyzer_cd IN /* codeList */(0)
ORDER BY A.dialyzer_cd
;


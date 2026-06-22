SELECT
  A.medicate_timing_cd     AS "medicateTimingCd",
  A.facility_cd            AS "facilityCd",
  A.fn_medicate_timing_cd  AS "fnMedicateTimingCd",
  A.medicate_timing_name   AS "medicateTimingName",
  A.dialysis_progress_cd   AS "dialysisProgressCd",
  A.alert_time             AS "alertTime",
  A.is_alert               AS "isAlert",
  A.is_disp                AS "isDisp",
  A.is_del                 AS "isDel",
  A.reg_date               AS "regDate",
  A.up_date                AS "upDate"
FROM mst_medicate_timing A
WHERE A.medicate_timing_cd IN /* codeList */(0)
ORDER BY A.medicate_timing_cd
;


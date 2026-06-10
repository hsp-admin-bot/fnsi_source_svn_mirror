SELECT
  detail_info ->> 'initialRangeExam' AS initialRangeExam,
  detail_info ->> 'initialRangeMedicine' AS initialRangeMedicine
FROM
  mst_medicine_support mms
WHERE
  mms.medicine_support_cd = /*cd*/'9'
;

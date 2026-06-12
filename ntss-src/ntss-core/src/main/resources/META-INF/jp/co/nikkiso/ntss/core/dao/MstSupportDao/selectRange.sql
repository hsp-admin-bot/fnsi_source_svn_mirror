SELECT
  detail_info ->> 'initialRangeExam' AS initialRangeExam,
  detail_info ->> 'initialRangeMedicine' AS initialRangeMedicine
FROM
  mst_medicine_support mms
WHERE
  mms.medicine_support_cd = /*cd*/'9'
-- #11205 -ペンテスト2－4認可制御の不備  add 20260416 start
AND mms.facility_cd = /*facilityCd*/'X'
-- #11205 -ペンテスト2－4認可制御の不備  add 20260416 end
;

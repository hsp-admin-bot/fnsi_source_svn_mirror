--  add #11276 キー日付に対するデータ引き当て仕様対応 高　start
SELECT
  ord_prescription_no
FROM
  ord_prescription
WHERE
    pat_id = /*patId*/0
  AND issue_date <= /*fromDate*/''
  AND facility_cd = /*facilityCd*/''
ORDER BY
  issue_date DESC,
  ord_prescription_no DESC
  LIMIT 1
--  add #11276 キー日付に対するデータ引き当て仕様対応 高　end

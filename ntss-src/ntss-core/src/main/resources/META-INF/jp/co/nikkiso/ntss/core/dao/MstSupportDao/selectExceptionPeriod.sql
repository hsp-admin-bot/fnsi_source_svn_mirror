SELECT
  exception_period_from as fromDate,
  exception_period_to as toDate
FROM
  ord_exception_period
WHERE
  facility_cd = /*facilityCd*/'1'
  AND pat_id = /*patId*/33

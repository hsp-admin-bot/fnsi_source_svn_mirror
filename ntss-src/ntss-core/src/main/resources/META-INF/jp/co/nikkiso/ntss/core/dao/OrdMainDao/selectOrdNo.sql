SELECT
  ord_no
FROM
  ord_main
WHERE
  pat_id = /*patId*/null
AND
  facility_cd = /*facilityCd*/null
AND
  treat_date = /*treatDate*/null
ORDER BY
  reg_date DESC,
  up_date DESC
;

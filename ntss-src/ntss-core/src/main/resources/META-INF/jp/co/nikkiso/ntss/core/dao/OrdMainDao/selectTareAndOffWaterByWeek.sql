SELECT
  ord_no as ord_no,
  treat_date,
  treat_week,
  ind_bed_name,
  ind_kur_name,
  rst_dialysis_state
FROM
  ord_main
WHERE
  pat_id = /*pat_id*/0
AND
  treat_date >= /*fromDate*/'20180226'
AND
  treat_date <= /*toDate*/'20180228'
AND
  rst_dialysis_state in ('3', '4', '5')
ORDER BY
  treat_date

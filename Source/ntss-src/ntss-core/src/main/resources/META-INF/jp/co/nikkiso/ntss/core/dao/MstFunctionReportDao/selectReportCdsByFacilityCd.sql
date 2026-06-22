SELECT
  DISTINCT report_cd
FROM
  mst_function_report
WHERE
  facility_cd = /*facilityCd*/null
AND
  is_disp = '1'
AND
  is_del = '0'
;

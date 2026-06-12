SELECT
  procedure_cd AS "procedureCd",
  facility_cd AS "facilityCd",
  pricedure_name AS "pricedureName",
  is_disp AS "isDisp",
  is_del AS "isDel"
FROM mst_procedure
WHERE facility_cd = /* params.get("facilityCd") */'0'
  AND is_del = '0'
ORDER BY procedure_cd;

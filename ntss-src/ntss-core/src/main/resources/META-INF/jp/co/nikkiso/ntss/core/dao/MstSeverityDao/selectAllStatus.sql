SELECT
  severity_cd AS "severityCd",
  severity_name AS "severityName",
  facility_cd AS "facilityCd",
  is_disp AS "isDisp",
  is_del AS "isDel",
  CASE
    WHEN is_disp = '0' OR is_del = '1' THEN '【削除済み】'
    ELSE ''
  END AS "deleted"
FROM mst_severity
WHERE facility_cd = /* params.get("facilityCd") */'0'
  AND (
    (is_disp <> '0' AND is_del <> '1')
    OR severity_cd = /* params.get("initSeverityCd") */0
  )
ORDER BY severity_cd;


SELECT
  ward_cd AS "wardCd",
  ward_name AS "wardName",
  facility_cd AS "facilityCd",
  is_disp AS "isDisp",
  is_del AS "isDel",
  CASE
    WHEN is_disp = '0' OR is_del = '1' THEN '【削除済み】'
    ELSE ''
  END AS "deleted"
FROM mst_ward
WHERE facility_cd = /* params.get("facilityCd") */'0'
  AND (
    (is_disp <> '0' AND is_del <> '1')
    /*%if params.get("initWardCd") != null */
    OR ward_cd = /* params.get("initWardCd") */0
    /*%end */
  )
ORDER BY ward_cd

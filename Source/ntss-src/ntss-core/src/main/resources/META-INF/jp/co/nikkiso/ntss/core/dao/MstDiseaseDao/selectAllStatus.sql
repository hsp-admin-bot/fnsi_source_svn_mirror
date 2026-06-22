SELECT
  disease_cd AS "diseaseCd",
  disease_name AS "diseaseName",
  facility_cd AS "facilityCd",
  is_disp AS "isDisp",
  is_del AS "isDel",
  CASE
    WHEN is_disp = '0' OR is_del = '1' THEN '【削除済み】'
    ELSE ''
  END AS "deleted"
FROM mst_disease
WHERE
  /*%if params.get("facilityCd") != null */
  facility_cd = /* params.get("facilityCd") */'0'
  AND
  /*%end */
  (
    (is_disp <> '0' AND is_del <> '1')
    OR disease_cd = /* params.get("initDiseaseCd") */0
  );


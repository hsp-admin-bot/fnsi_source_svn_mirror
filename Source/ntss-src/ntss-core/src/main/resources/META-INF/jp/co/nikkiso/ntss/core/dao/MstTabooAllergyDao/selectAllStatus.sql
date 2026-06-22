SELECT
  taboo_allergy_cd AS "tabooAllergyCd",
  content AS "content",
  facility_cd AS "facilityCd",
  is_disp AS "isDisp",
  is_del AS "isDel",
  CASE
    WHEN is_disp = '0' OR is_del = '1' THEN '【削除済み】'
    ELSE ''
  END AS "deleted"
FROM mst_taboo_allergy
WHERE facility_cd = /* params.get("facilityCd") */'0'
  AND (
    (is_disp <> '0' AND is_del <> '1')
    /*%if params.get("initTabooAllergyCd") != null && !params.get("initTabooAllergyCd").trim().isEmpty() */
    OR taboo_allergy_cd = /* params.get("initTabooAllergyCd") */''
    /*%end */
  )
ORDER BY taboo_allergy_cd

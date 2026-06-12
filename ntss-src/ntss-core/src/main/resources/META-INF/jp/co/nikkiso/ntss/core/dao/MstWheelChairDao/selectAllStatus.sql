SELECT
  wheel_chair_cd AS "wheelChairCd",
  wheel_chair_name AS "wheelChairName",
  wheel_chair_weight AS "wheelChairWeight",
  facility_cd AS "facilityCd",
  is_disp AS "isDisp",
  is_del AS "isDel",
  CASE
    WHEN is_disp = '0' OR is_del = '1' THEN '【削除済み】'
    ELSE ''
  END AS "deleted"
FROM mst_wheel_chair
WHERE facility_cd = /* params.get("facilityCd") */'0'
  AND (
    (is_disp <> '0' AND is_del <> '1')
    OR wheel_chair_cd = /* params.get("initWheelChairCd") */0
  )
ORDER BY wheel_chair_cd;

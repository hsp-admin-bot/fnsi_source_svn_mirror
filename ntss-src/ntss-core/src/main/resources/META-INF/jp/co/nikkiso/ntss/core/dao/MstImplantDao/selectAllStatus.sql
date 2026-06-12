WITH main AS (
  SELECT
    implant_cd AS "implantCd",
    implant_name AS "implantName",
    facility_cd AS "facilityCd",
    is_disp AS "isDisp",
    is_del AS "isDel",
    CASE
      WHEN is_disp = '0' OR is_del = '1' THEN '【削除済み】'
      ELSE ''
    END AS "deleted"
  FROM mst_implant
  WHERE facility_cd = /* params.get("facilityCd") */'1'
    AND (is_disp <> '0' AND is_del <> '1')
),
init AS (
  SELECT
    implant_cd AS "implantCd",
    implant_name AS "implantName",
    facility_cd AS "facilityCd",
    is_disp AS "isDisp",
    is_del AS "isDel",
    CASE
      WHEN is_disp = '0' OR is_del = '1' THEN '【削除済み】'
      ELSE ''
    END AS "deleted"
  FROM mst_implant
  WHERE facility_cd = /* params.get("facilityCd") */'1'
    AND implant_cd = /* params.get("initImplantCd") */0
)
SELECT * FROM main
UNION
SELECT * FROM init
ORDER BY "implantCd"

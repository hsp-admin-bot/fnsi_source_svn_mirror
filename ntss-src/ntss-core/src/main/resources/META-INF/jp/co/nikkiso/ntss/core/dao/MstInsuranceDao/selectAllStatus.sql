SELECT
  insu_cd AS "insuCd",
  insu_cd AS "code",
  name AS "name",
  insu_name_short AS "insuNameShort",
  futan_g AS "futanG",
  futan_n AS "futanN",
  insu_type AS "insuType",
  facility_cd AS "facilityCd",
  is_disp AS "isDisp",
  is_del AS "isDel",
  CASE
    WHEN is_disp = '0' OR is_del = '1' THEN '【削除済み】'
    ELSE ''
  END AS "deleted"
FROM mst_insurance
WHERE
  facility_cd = /* params.get("facilityCd") */'0'
  AND insu_type = /* params.get("insuType") */'0'
  AND (
    (is_disp <> '0' AND is_del <> '1')
    /*%if params.get("initInsuCd") != null && !params.get("initInsuCd").trim().isEmpty() */
    OR insu_cd = (/* params.get("initInsuCd") */0)::bigint
    /*%end*/
  );

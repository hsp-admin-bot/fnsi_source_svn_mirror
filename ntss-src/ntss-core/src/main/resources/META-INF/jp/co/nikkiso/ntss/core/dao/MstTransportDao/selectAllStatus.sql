SELECT
  transport_cd AS "transportCd",
  transport_name AS "transportName",
  facility_cd AS "facilityCd",
  is_disp AS "isDisp",
  is_del AS "isDel",
  CASE
    WHEN is_disp = '0' OR is_del = '1' THEN '【削除済み】'
    ELSE ''
  END AS "deleted"
FROM mst_transport
WHERE facility_cd = /* params.get("facilityCd") */'0'
  AND (
    (is_disp <> '0' AND is_del <> '1')
    OR transport_cd = /* params.get("initTransportCd") */0
  )
ORDER BY transport_cd;


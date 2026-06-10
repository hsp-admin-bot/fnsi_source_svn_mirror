WITH mss_weight AS (
  SELECT
    mss.facility_cd, ms.*, row_number() OVER() AS ord_index
  FROM
    mst_selector mss
    CROSS JOIN LATERAL jsonb_to_recordset(mss.order_settings->'items') AS ms
    (
      code bigint,
      name text
    )
  WHERE
    master_physical_name = 'mst_weight'
    AND facility_cd = /*facilityCd*/'999999'
)
SELECT
  /*%expand "A" */*
FROM
  mst_weight A
LEFT JOIN mss_weight msw ON A.weight_cd = msw.code
WHERE
  A.facility_cd = /*facilityCd*/'999999'
ORDER BY
  msw.ord_index 
;
WITH SEL AS (
  SELECT
    mss.facility_cd,
    ms.code,
    ms.name,
    ROW_NUMBER() OVER () AS index
  FROM
    mst_selector mss
    CROSS JOIN LATERAL jsonb_to_recordset(mss.order_settings -> 'items') AS ms (
      code BIGINT,
      name TEXT
    )
  WHERE
    /*%if params.get("facilityCd") != null */
    facility_cd = /* params.get("facilityCd") */'0'
    AND
    /*%end */
    master_physical_name = 'mst_va'
),
BASE AS (
  SELECT
    A.va_cd,
    A.facility_cd,
    A.fn_va_cd,
    A.va_name,
    A.va_direct,
    A.in_hospital_cd_1,
    A.in_hospital_cd_2,
    A.is_disp,
    A.is_del,
    A.reg_date,
    A.up_date,
    ms.index AS selector_index
  FROM
    mst_va A
    LEFT JOIN SEL ms
      ON A.facility_cd = ms.facility_cd
     AND A.va_cd = ms.code
  WHERE
    A.facility_cd = /* params.get("facilityCd") */'0'
),
MAIN AS (
  SELECT
    B.*,
    '' AS "deleted",
    '' AS "includeDeleted"
  FROM BASE B
  WHERE
    B.is_del = '0'
    AND B.is_disp = '1'
    AND B.selector_index IS NOT NULL
),
INIT AS (
  SELECT
    B.*,
    CASE
      WHEN B.is_disp = '0' OR B.is_del = '1'
        THEN '【削除済み】'
      ELSE ''
    END AS "deleted",
    '' AS "includeDeleted"
  FROM BASE B
  WHERE
    /*%if params.get("initVaCd") != null && !params.get("initVaCd").trim().isEmpty() */
    B.va_cd = (/* params.get("initVaCd") */0)::int
    /*%else */
    1 = 0
    /*%end */
)
SELECT *
FROM MAIN
UNION ALL
SELECT I.*
FROM INIT I
WHERE NOT EXISTS (
  SELECT 1
  FROM MAIN M
  WHERE M.va_cd = I.va_cd
)
ORDER BY
  selector_index NULLS LAST,
  va_cd
;

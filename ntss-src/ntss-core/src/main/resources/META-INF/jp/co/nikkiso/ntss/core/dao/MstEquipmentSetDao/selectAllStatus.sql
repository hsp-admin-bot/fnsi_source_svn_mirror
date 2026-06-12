WITH BASE AS (
  SELECT
    A.equipment_set_cd   AS "equipmentSetCd",
    A.facility_cd        AS "facilityCd",
    A.equipment_set_name AS "equipmentSetName",
    A.equipment_set_short_name AS "equipmentSetShortName",
    A.set_info::text     AS "setInfo",
    A.is_disp            AS "isDisp",
    A.is_del             AS "isDel",
    A.reg_date           AS "regDate",
    A.up_date            AS "upDate",
    CASE
      WHEN EXISTS (
        SELECT 1
        FROM jsonb_to_recordset(A.set_info::jsonb) AS si(cd int, equip_type int)
        LEFT JOIN mst_equipment e
          ON si.equip_type = 0
         AND e.facility_cd = A.facility_cd
         AND e.equipment_cd = si.cd
        LEFT JOIN mst_dialyzer d
          ON si.equip_type = 1
         AND d.facility_cd = A.facility_cd
         AND d.dialyzer_cd = si.cd
        WHERE
          (si.equip_type = 0 AND (e.is_disp = '0' OR e.is_del = '1'))
          OR
          (si.equip_type = 1 AND (d.is_disp = '0' OR d.is_del = '1'))
      )
        THEN '【削除済み含む】'
      ELSE ''
    END AS "includeDeleted"
  FROM
    mst_equipment_set A
  WHERE
    /*%if params.get("facilityCd") != null && !params.get("facilityCd").trim().isEmpty() */
    A.facility_cd = /* params.get("facilityCd") */'0'
    /*%end */
),
MAIN AS (
  SELECT
    B.*,
    '' AS "deleted",
    B."includeDeleted" AS "includeDeleted"
  FROM BASE B
  WHERE
    B."isDisp" = '1'
    AND B."isDel" = '0'
)
SELECT *
FROM MAIN
ORDER BY
  "equipmentSetCd"
;


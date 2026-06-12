SELECT
    A.class_cd          AS "classCd",
    A.facility_cd       AS "facilityCd",
    A.fn_class_cd       AS "fnClassCd",
    A.class_name        AS "className",
    A.class_type        AS "classType",
    A.in_hospital_cd_1  AS "inHospitalCd1",
    A.is_disp           AS "isDisp",
    A.is_del            AS "isDel",
    A.is_editable       AS "isEditable",
    A.reg_date          AS "regDate",
    A.up_date           AS "upDate",
    CASE
        WHEN ms.code IS NOT NULL THEN 0 ELSE 1
    END                      AS "sortGroup",
    ms.selector_index        AS "medicineMixSelectorIndex"
FROM
    mst_equipment_class A
    LEFT JOIN LATERAL (
        SELECT
            mss.facility_cd      AS facility_cd,
            ms.code              AS code,
            ms.name              AS name,
            ROW_NUMBER() OVER () AS selector_index
        FROM
            mst_selector mss
            CROSS JOIN LATERAL jsonb_to_recordset(
                mss.order_settings -> 'items'
            ) AS ms(code BIGINT, name TEXT)
        WHERE
            mss.master_physical_name = 'mst_equipment_class'
    ) ms
        ON A.facility_cd = ms.facility_cd
       AND A.class_cd = ms.code
WHERE
    A.facility_cd = /* params.get("facilityCd") */'0'
    AND A.is_disp = '1'
    AND A.is_del = '0'
    /*%if params.get("classType") != null */
    AND A.class_type = ANY(string_to_array(/* params.get("classType") */'0', ',')::int[])
    /*%end*/
ORDER BY
    "sortGroup" ASC,
    ms.selector_index NULLS LAST,
    A.class_cd;

WITH eOut AS (
	WITH e AS (
        SELECT
            mst_equipment.equipment_cd, mst_equipment.facility_cd, mst_equipment.equipment_name, mst_equipment.class_cd, mst_equipment.unit, mst_equipment.reg_date, mst_equipment.up_date
        FROM
            mst_equipment
        WHERE
            mst_equipment.facility_cd = /*facilityCd*/null
        /*%if is_disp != null*/
        AND
            mst_equipment.is_disp = /*is_disp*/null
        /*%end*/
        /*%if is_del != null*/
        AND
            mst_equipment.is_del = /*is_del*/null
        /*%end*/
    )
    (
        SELECT
            mst_equipment_class.class_cd class_type, mst_equipment_class.class_name, e.equipment_cd, e.equipment_name, e.reg_date, e.up_date
        FROM
            mst_equipment_class
        left outer join e on (mst_equipment_class.facility_cd = e.facility_cd and mst_equipment_class.class_cd = e.class_cd)
        WHERE
            mst_equipment_class.facility_cd = /*facilityCd*/null
        /*%if is_disp != null*/
        AND
            mst_equipment_class.is_disp = /*is_disp*/null
        /*%end*/
        /*%if is_del != null*/
        AND
            mst_equipment_class.is_del = /*is_del*/null
        /*%end*/
        order by mst_equipment_class.class_cd, mst_equipment_class.class_type, e.equipment_cd
    )
    UNION All
    (
        SELECT
            e.class_cd AS class_type,
            '未分類' AS class_name,
            e.equipment_cd,
            e.equipment_name,
            e.reg_date,
            e.up_date
        FROM
            e
        WHERE
            e.class_cd = '-1'
        AND e.facility_cd = /*facilityCd*/null
    )
)
SELECT * FROM eOut ORDER BY eOut.class_type, eOut.equipment_cd
;

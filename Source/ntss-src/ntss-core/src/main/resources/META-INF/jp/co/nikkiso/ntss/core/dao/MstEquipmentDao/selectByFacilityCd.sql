-- 5601 「投薬・医材でフィルタができない」 鄧シン start
WITH eOut AS (
-- 5601 「投薬・医材でフィルタができない」 鄧シン end
	WITH e AS (
    SELECT mst_equipment.equipment_cd, mst_equipment.facility_cd, mst_equipment.equipment_name, mst_equipment.class_cd, mst_equipment.unit, mst_equipment.reg_date, mst_equipment.up_date
    FROM mst_equipment
    where mst_equipment.facility_cd = /*facilityCd*/'009999' and mst_equipment.is_del = '0'
)
-- 5601 「投薬・医材でフィルタができない」 鄧シン start
(
-- 5601 「投薬・医材でフィルタができない」 鄧シン end
select mst_equipment_class.class_cd class_type, mst_equipment_class.class_name, e.equipment_cd, e.equipment_name, e.reg_date, e.up_date
from mst_equipment_class
left outer join e on (mst_equipment_class.facility_cd = e.facility_cd and mst_equipment_class.class_cd = e.class_cd)
where mst_equipment_class.facility_cd = /*facilityCd*/'009999' and mst_equipment_class.is_del = '0'
order by mst_equipment_class.class_cd, mst_equipment_class.class_type, e.equipment_cd
-- 5601 「投薬・医材でフィルタができない」 鄧シン start
) UNION All
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
    AND e.facility_cd = /*facilityCd*/'009999'
)
SELECT * FROM eOut ORDER BY eOut.class_type, eOut.equipment_cd
-- 5601 「投薬・医材でフィルタができない」 鄧シン end
;
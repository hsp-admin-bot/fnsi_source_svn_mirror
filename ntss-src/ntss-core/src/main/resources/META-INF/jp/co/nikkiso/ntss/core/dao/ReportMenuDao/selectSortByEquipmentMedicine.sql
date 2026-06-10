SELECT
-- mod FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 start
--pat_id
	 pat_id,(mst_equipment.equipment_name || mst_medicine.medicine_name) pat_name
-- mod FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 end
FROM
	ntss.ord_main as om
CROSS JOIN lateral json_array_elements (om.ind_medi_info :: json) medi_info
cross JOIN lateral json_array_elements (om.ind_equip_info :: json) equip_info
INNER JOIN ntss.mst_medicine
ON
(
	(medi_info ->> 'cd')::integer = mst_medicine.medicine_cd
)
INNER JOIN ntss.mst_equipment_class
ON
(
	(equip_info ->> 'cd')::integer = mst_equipment_class.class_cd
)
INNER JOIN ntss.mst_equipment
ON
	mst_equipment_class.class_cd=mst_equipment.class_cd
WHERE

	om.is_del = '0'
AND
	om.facility_cd = /*facilityCd*/''
AND
	om.pat_id in /*patId*/(null)
	GROUP BY om.pat_id , mst_equipment.equipment_name, mst_medicine.medicine_name
ORDER BY
/*%if "asc" != sortValue */
	mst_equipment.equipment_name, mst_medicine.medicine_name desc
/*%else*/
	mst_equipment.equipment_name, mst_medicine.medicine_name asc
/*%end*/

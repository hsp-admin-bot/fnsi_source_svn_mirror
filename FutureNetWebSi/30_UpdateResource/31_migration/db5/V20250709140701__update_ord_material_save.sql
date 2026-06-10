UPDATE ord_material_save oms
SET class_cd = me.class_cd
FROM mst_equipment me
WHERE oms.supplies_source_class = '2'
  AND oms.ind_rst_class = '1'
  AND oms.supplies_class = '11'
  AND oms.class_cd IS NULL
  AND oms.facility_cd = me.facility_cd
  AND oms.supplies_cd = me.equipment_cd::text;
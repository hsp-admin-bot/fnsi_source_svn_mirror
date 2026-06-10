SELECT
	ord_material_save.ord_material_save_no,
	ord_material_save.facility_cd,
	ord_material_save.pat_id,
	ord_material_save.supplies_base_date,
	ord_material_save.supplies_base_no,
	ord_material_save.supplies_source_class,
	ord_material_save.supplies_class,
	ord_material_save.supplies_cd,
	ord_material_save.medicine_mix_cd,
	ord_material_save.class_cd,
	ord_material_save.ind_rst_class,
	ord_material_save.ind_rst_value,
	ord_material_save.receipt_value,
	ord_material_save.is_confirm,
	ord_material_save.reg_date,
	ord_material_save.up_date,
  -- 10262 new columns has been added.
  ord_material_save.prescription_unit,
  ord_material_save.frequency_flg,
  ord_material_save.frequency_num
FROM
	ord_material_save
WHERE facility_cd = /*facilityCd*/null

AND pat_id = /*patId*/null

AND supplies_base_date >= /*suppliesBaseDateBegin*/null

AND supplies_base_date < /*suppliesBaseDateEnd*/null

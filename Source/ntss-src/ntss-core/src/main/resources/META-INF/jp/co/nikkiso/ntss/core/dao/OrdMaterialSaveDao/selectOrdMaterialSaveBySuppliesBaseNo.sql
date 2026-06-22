SELECT
	ord_material_save.ord_material_save_no,
	ord_material_save.facility_cd,
	ord_material_save.pat_id,
	ord_material_save.supplies_base_date,
	ord_material_save.supplies_base_no,
	ord_material_save.supplies_class,
	ord_material_save.supplies_source_class,
	ord_material_save.supplies_cd,
	ord_material_save.medicine_mix_cd,
	ord_material_save.class_cd,
	ord_material_save.ind_rst_class,
	ord_material_save.ind_rst_value,
	ord_material_save.receipt_value,
  -- add 10196 fix materialSave by Zhou.tao start
  ord_material_save.medicine_no,
  ord_material_save.is_confirm,
  ord_material_save.procedure_cd,
  ord_material_save.timing_cd,
  ord_material_save.receipt_conversion
  -- add 10196 fix materialSave by Zhou.tao end
FROM
	ord_material_save
where supplies_base_no = /*suppliesBaseNo*/null
-- add FNSI redmine 7150 劉祥霖 start
and facility_cd=/*facilityCd*/null
-- add FNSI redmine 7150 劉祥霖 end

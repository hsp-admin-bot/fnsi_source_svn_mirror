SELECT
	ord_material_save.ord_material_save_no ordMaterialSaveNo,
	ord_material_save.facility_cd facilityCd,
	ord_material_save.pat_id patId,
	ord_material_save.supplies_base_date suppliesBaseDate,
	ord_material_save.supplies_base_no suppliesBaseNo,
	ord_material_save.supplies_source_class suppliesSourceClass,
	ord_material_save.supplies_class suppliesClass,
	ord_material_save.supplies_cd suppliesCd,
	ord_material_save.medicine_mix_cd medicineMixCd,
	ord_material_save.class_cd classCd,
	ord_material_save.ind_rst_class indRstClass,
	ord_material_save.ind_rst_value indRstValue,
	ord_material_save.receipt_value receiptValue,
	ord_material_save.is_confirm isConfirm,
	ord_material_save.reg_date regDate,
	ord_material_save.up_date upDate,
  -- 10262 new columns has been added.
  ord_material_save.prescription_unit prescriptionUnit,
  ord_material_save.frequency_flg frequencyFlg,
  ord_material_save.frequency_num frequencyNum,
  mst_medicine.standard_medicine_cd standardMedicineCd
FROM
	ord_material_save
LEFT JOIN mst_medicine
  ON ord_material_save.facility_cd = mst_medicine.facility_cd
 AND ord_material_save.supplies_cd = mst_medicine.medicine_cd::text
 AND (ord_material_save.supplies_class = '12' or ord_material_save.supplies_class = '23' or ord_material_save.supplies_class = '24')

WHERE ord_material_save.facility_cd = /*facilityCd*/null

AND ord_material_save.pat_id = /*patId*/null

AND ord_material_save.supplies_base_date >= /*suppliesBaseDateBegin*/null

AND ord_material_save.supplies_base_date < /*suppliesBaseDateEnd*/null

UPDATE
  ord_material_save
SET
(
  facility_cd = /*conditions.facilityCd*/'1',
  pat_id = /*conditions.patId*/'1',
  supplies_base_date = /*conditions.suppliesBaseDate.toString()*/'29991231',
  supplies_base_no = /*conditions.suppliesBaseNo*/'1',
  supplies_source_class = /*conditions.suppliesSourceClass*/'1',
  supplies_class = /*conditions.suppliesClass*/'1',
  supplies_cd = /*conditions.suppliesCd*/'1',
  medicine_mix_cd = /*conditions.medicineMixCd*/'1',
  class_cd = /*conditions.classCd*/'1',
  ind_rst_class = /*conditions.indRstClass*/'1',
  ind_rst_value = /*conditions.indRstValue*/'1',
  receipt_value = /*conditions.receiptValue*/'1',
  is_confirm = /*conditions.isConfirm*/'1',
  reg_date = now(),
  up_date = now()
)
WHERE
  supplies_base_no = /*conditions.suppliesBaseNo*/'1'

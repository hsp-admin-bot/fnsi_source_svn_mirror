INSERT INTO
  ord_material_save
(
/*%if conditions.ordMaterialSaveNo != null */
ord_material_save_no,
/*%end*/
  facility_cd,
  pat_id,
  supplies_base_date,
  supplies_base_no,
  supplies_source_class,
  supplies_class,
  supplies_cd,
  medicine_mix_cd,
  class_cd,
  ind_rst_class,
  ind_rst_value,
  receipt_value,
  is_confirm,
  reg_date,
  up_date
)
VALUES
(
/*%if conditions.ordMaterialSaveNo != null */
 /*conditions.ordMaterialSaveNo*/'1',
/*%end*/
 /*conditions.facilityCd*/'1',
 /*conditions.patId*/'1',
 /*conditions.suppliesBaseDate */'29991231',
 /*conditions.suppliesBaseNo */29991231,
 /*conditions.suppliesSourceClass*/'1',
 /*conditions.suppliesClass*/'1',
 /*conditions.suppliesCd*/'1',
 /*conditions.medicineMixCd*/'1',
 /*conditions.classCd*/'1',
 /*conditions.indRstClass*/'1',
 /*conditions.indRstValue*/'1',
 /*conditions.receiptValue*/'1',
 /*conditions.isConfirm*/'1',
 current_timestamp,
 current_timestamp
)

INSERT INTO
  ord_material_save
(
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
  up_date,
  medicine_no,
  procedure_cd,
  timing_cd,
  prescription_unit,
  frequency_flg,
  frequency_num,
  receipt_conversion
  -- add 11491 by kangjie 20250210 start
  ,receipt_unit
  ,ind_unit
  -- add 11491 by kangjie 20250210 end
  -- add 11613 by shiyw 20250304 start
  ,effect_flg
  -- add 11613 by shiyw 20250304 start
)
VALUES
/*%for oms : omsList */
(
 /*oms.facilityCd*/'1',
 /*oms.patId*/'1',
 /*oms.suppliesBaseDate */'29991231',
 /*oms.suppliesBaseNo */29991231,
 /*oms.suppliesSourceClass*/'1',
 /*oms.suppliesClass*/'1',
 /*oms.suppliesCd*/'1',
 /*oms.medicineMixCd*/'1',
 /*oms.classCd*/'1',
 /*oms.indRstClass*/'1',
 /*oms.indRstValue*/'1',
 /*oms.receiptValue*/'1',
 /*oms.isConfirm*/'1',
 current_timestamp,
 current_timestamp,
 /*oms.medicineNo*/'1',
 /*oms.procedureCd*/'1',
 /*oms.timingCd*/'1',
 /*oms.prescriptionUnit*/'1',
 /*oms.frequencyFlg*/'1',
 /*oms.frequencyNum*/'1',
 /*oms.receiptConversion*/'1'
-- add 11491 by kangjie 20250210 start
,/*oms.receiptUnit*/'1'
,/*oms.indUnit*/'1'
-- add 11491 by kangjie 20250210 end
-- add 11613 by shiyw 20250304 start
,/*oms.effectFlg*/'1'
-- add 11613 by shiyw 20250304 start
)
    /*%if oms_has_next */
    /*# "," */
    /*%end */
/*%end*/

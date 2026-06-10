SELECT
  ord_material_save_no,
  facility_cd,
  pat_id,
  supplies_base_date,
  supplies_base_no,
  supplies_class,
  supplies_source_class,
  supplies_cd,
  medicine_mix_cd,
  class_cd,
  ind_rst_class,
  ind_rst_value,
  receipt_value,
  is_confirm,
  medicine_no,
  procedure_cd,
  timing_cd,
  -- add 11613 by shiyw 20250304 start
  effect_flg,
  -- add 11613 by shiyw 20250304 start
  receipt_conversion
FROM
  ord_material_save
where
  supplies_base_no in /*ordNoList*/()
  and facility_cd = /*facilityCd*/null

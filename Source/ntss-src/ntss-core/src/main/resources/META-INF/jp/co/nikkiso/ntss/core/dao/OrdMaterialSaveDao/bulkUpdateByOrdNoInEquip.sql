WITH ord_main_data AS (
  SELECT *
  from ord_main
  where ord_no in /*ordNoList*/('9967733')
)
,equip_data_ord AS (
  SELECT
    om.ord_no,
    om.facility_cd,
    om.pat_id,
    om.treat_date,
    om.reg_date,
    om.up_date,
    elem->>'equip_type' AS equip_type,
    elem->>'class_cd' AS class_cd,
    elem->>'no' as equip_no,
  elem->>'cd' as json_value,
  elem->>'amount' as amount,
  elem->>'unit' as unit
FROM ord_main_data om
  CROSS JOIN jsonb_array_elements(om.ind_equip_info) AS elem
)
,mst_equipment_equip as (
select *
from mst_equipment
where equipment_cd in (
  SELECT DISTINCT json_value::int
  from equip_data_ord
  where equip_type != '1'
  )
)
,equip_data_tmp AS (
SELECT
  0::int8 AS ord_material_save_no,
  edo.facility_cd,
  edo.pat_id,
  edo.treat_date AS supplies_base_date,
  edo.ord_no AS supplies_base_no,
  '2' AS supplies_source_class,
  CASE WHEN edo.equip_type = '1' THEN '01'
  ELSE '11'
  END AS supplies_class,
  edo.json_value AS supplies_cd,
  NULL AS medicine_mix_cd,
  me.class_cd::TEXT AS class_cd,
  edo.amount::TEXT AS ind_rst_value,
  edo.amount::TEXT AS receipt_value,
  '1' AS is_confirm,
  edo.reg_date,
  edo.up_date,
  CASE
    WHEN edo.equip_no IS NULL OR edo.equip_no = '' THEN NULL::json
    ELSE json_build_object('no', edo.equip_no::INT)
  END as medicine_no,
  NULL as procedure_cd,
  NULL as timing_cd,
  NULL::jsonb as receipt_conversion,
  NULL as prescription_unit,
  NULL as frequency_flg,
  NULL as frequency_num,
  CASE WHEN edo.equip_type = '1' THEN '本'
  ELSE me.unit
  END as receipt_unit,
  CASE WHEN edo.equip_type = '1' THEN '本'
  ELSE me.unit
  END as ind_unit,
  '1' as effect_flg

FROM equip_data_ord edo
  LEFT JOIN mst_equipment_equip me ON edo.json_value::int = me.equipment_cd and edo.equip_type != '1'
  )
  ,equip_data AS (
SELECT ed.ord_material_save_no,
  ed.facility_cd,
  ed.pat_id,
  ed.supplies_base_date,
  ed.supplies_base_no,
  ed.supplies_source_class,
  ed.supplies_class,
  ed.supplies_cd,
  ed.medicine_mix_cd,
  ed.class_cd,
  ed.ind_rst_value,
  ed.receipt_value,
  ed.is_confirm,
  ed.reg_date,
  ed.up_date,
  ed.medicine_no,
  ed.procedure_cd,
  ed.timing_cd,
  ed.receipt_conversion,
  ed.prescription_unit,
  ed.frequency_flg,
  ed.frequency_num,
  ed.receipt_unit,
  ed.ind_unit,
  ed.effect_flg
FROM equip_data_tmp ed
  )
,del AS (
  DELETE FROM ord_material_save
  WHERE supplies_base_no in /*ordNoList*/('9967733')
    AND supplies_source_class = '2' and ind_rst_class = '1'
)
INSERT INTO ord_material_save (
  facility_cd, pat_id, supplies_base_date, supplies_base_no, supplies_source_class, supplies_class, supplies_cd, medicine_mix_cd, class_cd, ind_rst_class,
  ind_rst_value, receipt_value, is_confirm, reg_date, up_date, medicine_no, procedure_cd, timing_cd, receipt_conversion, prescription_unit, frequency_flg, frequency_num,
  receipt_unit, ind_unit, effect_flg
)
select
  facility_cd,
  pat_id,
  supplies_base_date,
  supplies_base_no,
  supplies_source_class,
  supplies_class,
  supplies_cd,
  medicine_mix_cd,
  class_cd,
  '1',
  ind_rst_value,
  receipt_value,
  is_confirm,
  reg_date,
  up_date,
  medicine_no,
  procedure_cd,
  timing_cd,
  receipt_conversion,
  prescription_unit,
  frequency_flg,
  frequency_num,
  receipt_unit,
  ind_unit,
  effect_flg
from equip_data

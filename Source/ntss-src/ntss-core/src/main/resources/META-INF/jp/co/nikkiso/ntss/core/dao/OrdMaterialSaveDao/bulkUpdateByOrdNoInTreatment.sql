WITH ord_main_data AS (
  SELECT *
  from ord_main
  where ord_no = /*ordNo*/109598
)
,ord_material_save_data AS (
  SELECT oms.* from ord_material_save oms
    INNER JOIN ord_main_data omd on oms.supplies_base_no = omd.ord_no
  where oms.supplies_source_class = '3'
)
,treatment_data_ord AS (
  SELECT
    om.ord_no,
    om.facility_cd,
    om.pat_id,
    om.treat_date,
    '2' as ind_rst_class,
    om.reg_date,
    om.up_date,
    elem->>'medicine_type' AS medicine_type,
  jsonb_build_object(
  'ctl_no', (elem->>'ctl_no')::int,
  'row_no', (elem->>'row_no')::int
  ) as medicine_no,
  elem->>'treat_medicine_cd' as json_value,
  elem->>'procedure_cd' as procedure_cd,
  null as timing_cd,
  elem->>'amount' as amount,
  elem->>'unit' as unit,
  null as class_cd,
  elem->>'effect_flg' as effect_flg,
  om.rst_dialysis_state
FROM ord_main_data om
  CROSS JOIN jsonb_array_elements(om.rst_treatment_info) AS elem
where rst_dialysis_state != '0' and elem->>'treat_medicine_cd' is not null
)
,mst_medicine_medi as (
select * from mst_medicine
where medicine_cd in (
  SELECT DISTINCT json_value::int
  from treatment_data_ord
  where medicine_type = '1'
  )
)
,mst_medicine_mix_medi as (
select * from mst_medicine_mix
where medicine_mix_cd in (
  SELECT DISTINCT json_value::int
  from treatment_data_ord
  where medicine_type != '1'
  )
)
,treatment_data_tmp AS (
SELECT
  0::int8 AS ord_material_save_no,
  mdo.facility_cd,
  mdo.pat_id,
  mdo.treat_date AS supplies_base_date,
  mdo.ord_no AS supplies_base_no,
  '3' AS supplies_source_class,
  CASE WHEN mdo.medicine_type = '1' THEN '14' ELSE '15'
  END AS supplies_class,
  mdo.json_value AS supplies_cd,
  CASE WHEN mdo.medicine_type = '1' THEN NULL ELSE mdo.json_value
  END AS medicine_mix_cd,
  CASE WHEN mdo.medicine_type = '1' THEN mm.class_cd::TEXT ELSE mmm.class_cd::TEXT END AS class_cd,
  mdo.ind_rst_class,
  mdo.amount AS ind_rst_value,
  NULL AS receipt_value,
  CASE WHEN mdo.ind_rst_class = '1' THEN '1'
  ELSE
  CASE
  WHEN mdo.rst_dialysis_state = '6' THEN '1' ELSE '0'
  END
  END AS is_confirm,
  mdo.reg_date,
  mdo.up_date,
  mdo.medicine_no AS medicine_no,
  mdo.procedure_cd,
  mdo.timing_cd,
  CASE WHEN mdo.medicine_type = '1' THEN
  jsonb_build_object('is_exchange', mm.is_exchange::INT,
  'unit_decimal_point', mm.unit_decimal_point,
  'unit_converted_amount', mm.unit_converted_amount,
  'unit_decimal_point_second', mm.unit_decimal_point_second,
  'unit_converted_amount_second', mm.unit_converted_amount_second
  )
  ELSE mmm.mix_info
  END as receipt_conversion,
  NULL as prescription_unit,
  NULL as frequency_flg,
  NULL as frequency_num,
  mdo.medicine_type,
  CASE WHEN mdo.medicine_type = '1' THEN mm.unit_second
  WHEN mdo.medicine_type = '2' THEN mmm.unit_second
  ELSE NULL
  END as receipt_unit,
  CASE WHEN mdo.medicine_type = '1' THEN mm.unit
  ELSE mmm.unit
  END as ind_unit,
  '1' as effect_flg,
  mdo.rst_dialysis_state,
  CASE WHEN mdo.medicine_type = '2' THEN mmm.medicine_set_num
  ELSE NULL
  END as medicine_set_num
FROM treatment_data_ord mdo
  LEFT JOIN mst_medicine_medi mm ON mdo.json_value::int = mm.medicine_cd and mdo.medicine_type = '1'
  LEFT JOIN mst_medicine_mix_medi mmm ON mdo.json_value::int = mmm.medicine_mix_cd and mdo.medicine_type != '1'
)
,treatment_data_save AS (
SELECT md.ord_material_save_no,
  md.facility_cd,
  md.pat_id,
  md.supplies_base_date,
  md.supplies_base_no,
  md.supplies_source_class,
  md.supplies_class,
  md.supplies_cd,
  md.medicine_mix_cd,
  CASE WHEN oms.ord_material_save_no is not null THEN oms.class_cd
  ELSE md.class_cd
  END as class_cd,
  md.ind_rst_class,
  md.ind_rst_value,
  md.receipt_value,
  md.is_confirm,
  md.reg_date,
  md.up_date,
  md.medicine_no,
  md.procedure_cd,
  md.timing_cd,
  CASE WHEN oms.ord_material_save_no is not null THEN oms.receipt_conversion
  ELSE md.receipt_conversion
  END as receipt_conversion,
  md.prescription_unit,
  md.frequency_flg,
  md.frequency_num,
  CASE WHEN oms.ord_material_save_no is not null THEN oms.receipt_unit
  ELSE md.receipt_unit
  END as receipt_unit,
  CASE WHEN oms.ord_material_save_no is not null THEN oms.ind_unit
  ELSE md.ind_unit
  END as ind_unit,
  md.effect_flg,
  md.rst_dialysis_state,
  CASE WHEN oms.ord_material_save_no is not null THEN '1' ELSE '2' END as has_flg,
  md.medicine_set_num
FROM treatment_data_tmp md
  LEFT JOIN ord_material_save_data oms ON md.rst_dialysis_state != '0' AND md.facility_cd = oms.facility_cd and md.pat_id = oms.pat_id and oms.supplies_base_no = md.supplies_base_no
  and md.supplies_class = oms.supplies_class and oms.medicine_no->>'no' = md.medicine_no->>'no' and md.supplies_cd = oms.supplies_cd
  and md.ind_rst_class = oms.ind_rst_class and md.supplies_source_class = oms.supplies_source_class
)
,mst_medicine_mix_treatment_save as (
select * from mst_medicine_mix
where medicine_mix_cd in (
  SELECT DISTINCT medicine_mix_cd::int
  from treatment_data_save
  where supplies_class = '15' and has_flg = '2'
  )
)
,mst_medicine_treatment_save as (
select * from mst_medicine
where medicine_cd in (
  SELECT DISTINCT (elem->>'cd')::int
  from mst_medicine_mix_treatment_save mmm
  CROSS JOIN jsonb_array_elements(mmm.mix_info) AS elem
  )
)
,treatment_data_supplies as (
SELECT
  md.ord_material_save_no,
  md.facility_cd,
  md.pat_id,
  md.supplies_base_date,
  md.supplies_base_no,
  md.supplies_source_class,
  '20' as supplies_class,
  oms.supplies_cd,
  md.medicine_mix_cd,
  oms.class_cd,
  md.ind_rst_class,
  CASE WHEN elem->>'solvent' = '1' THEN ROUND((elem->>'amount')::numeric, COALESCE((oms.receipt_conversion->>'unit_decimal_point')::int, 0))::TEXT
  ELSE ROUND((elem->>'amount')::numeric * md.ind_rst_value::numeric, COALESCE((oms.receipt_conversion->>'unit_decimal_point')::int, 0))::TEXT
  END as ind_rst_value,
  NULL AS receipt_value,
  md.is_confirm,
  md.reg_date,
  md.up_date,
  md.medicine_no,
  md.procedure_cd,
  md.timing_cd,
  oms.receipt_conversion,
  NULL as prescription_unit,
  NULL as frequency_flg,
  NULL as frequency_num,
  oms.receipt_unit,
  oms.ind_unit,
  md.effect_flg,
  md.rst_dialysis_state,
  md.has_flg,
  NULL::int AS medicine_set_num
FROM treatment_data_save md
  CROSS JOIN jsonb_array_elements(md.receipt_conversion) AS elem
  INNER JOIN ord_material_save_data oms ON md.facility_cd = oms.facility_cd and md.pat_id = oms.pat_id and oms.supplies_base_no = md.supplies_base_no
  and oms.supplies_class = '21' and md.supplies_class = '15' and md.supplies_source_class = oms.supplies_source_class
  and md.ind_rst_class = oms.ind_rst_class and md.medicine_mix_cd = oms.medicine_mix_cd and elem->>'cd' = oms.supplies_cd
where md.has_flg = '1'
UNION ALL
SELECT
  md.ord_material_save_no,
  md.facility_cd,
  md.pat_id,
  md.supplies_base_date,
  md.supplies_base_no,
  md.supplies_source_class,
  '21' as supplies_class,
  elem->>'cd' as supplies_cd,
  md.medicine_mix_cd,
  mm.class_cd::TEXT,
  md.ind_rst_class,
  CASE WHEN elem->>'solvent' = '1' THEN ROUND((elem->>'amount')::numeric, COALESCE(mm.unit_decimal_point, 0))::TEXT
  ELSE ROUND((elem->>'amount')::numeric * md.ind_rst_value::numeric, COALESCE(mm.unit_decimal_point, 0))::TEXT
  END as ind_rst_value,
  NULL AS receipt_value,
  md.is_confirm,
  md.reg_date,
  md.up_date,
  md.medicine_no,
  md.procedure_cd,
  md.timing_cd,
  jsonb_build_object('is_exchange', mm.is_exchange::INT,
  'unit_decimal_point', mm.unit_decimal_point,
  'unit_converted_amount', mm.unit_converted_amount,
  'unit_decimal_point_second', mm.unit_decimal_point_second,
  'unit_converted_amount_second', mm.unit_converted_amount_second
  ) as receipt_conversion,
  NULL as prescription_unit,
  NULL as frequency_flg,
  NULL as frequency_num,
  mm.unit_second as receipt_unit,
  mm.unit as ind_unit,
  md.effect_flg,
  md.rst_dialysis_state,
  md.has_flg,
  NULL::int AS medicine_set_num
FROM treatment_data_save md
  LEFT JOIN mst_medicine_mix_treatment_save mmm ON md.supplies_class = '15' and md.medicine_mix_cd::int = mmm.medicine_mix_cd
  CROSS JOIN jsonb_array_elements(mmm.mix_info) AS elem
  LEFT JOIN mst_medicine_treatment_save mm ON (elem->>'cd')::int = mm.medicine_cd
where md.has_flg = '2'
UNION ALL
SELECT * FROM treatment_data_save
)
,treatment_data AS (
SELECT md.ord_material_save_no,
  md.facility_cd,
  md.pat_id,
  md.supplies_base_date,
  md.supplies_base_no,
  md.supplies_source_class,
  md.supplies_class,
  md.supplies_cd,
  md.medicine_mix_cd,
  md.class_cd,
  md.ind_rst_class,
  md.ind_rst_value,
  CASE WHEN receipt_conversion is not null THEN
  CASE WHEN receipt_conversion->>'is_exchange' = '0' THEN
  COALESCE(ROUND(md.ind_rst_value::numeric / NULLIF((receipt_conversion->>'unit_converted_amount')::numeric, 0) *
  (receipt_conversion->>'unit_converted_amount_second')::numeric, COALESCE((receipt_conversion->>'unit_decimal_point_second')::int, 0)),
  ROUND(0, COALESCE((receipt_conversion->>'unit_decimal_point_second')::int, 0)))::text
  WHEN receipt_conversion->>'is_exchange' = '1' THEN
  COALESCE(ROUND(CEIL(md.ind_rst_value::numeric / NULLIF((receipt_conversion->>'unit_converted_amount')::numeric, 0)) *
  (receipt_conversion->>'unit_converted_amount_second')::numeric, COALESCE((receipt_conversion->>'unit_decimal_point_second')::int, 0)),
  ROUND(0, COALESCE((receipt_conversion->>'unit_decimal_point_second')::int, 0)))::text
  WHEN receipt_conversion->>'is_exchange' = '2' THEN
  ROUND((receipt_conversion->>'unit_converted_amount_second')::numeric, COALESCE((receipt_conversion->>'unit_decimal_point_second')::int, 0))::text
  ELSE (md.ind_rst_value::numeric * md.medicine_set_num)::text
  END
  ELSE NULL
  END as receipt_value,
  md.is_confirm,
  md.reg_date,
  md.up_date,
  md.medicine_no,
  md.procedure_cd,
  md.timing_cd,
  md.receipt_conversion,
  md.prescription_unit,
  md.frequency_flg,
  md.frequency_num,
  md.receipt_unit,
  md.ind_unit,
  md.effect_flg,
  md.medicine_set_num
FROM treatment_data_supplies md
)
,del AS (
DELETE FROM ord_material_save
WHERE supplies_base_no = /*ordNo*/109598
  AND supplies_source_class = '3'
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
  ind_rst_class,
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
from treatment_data

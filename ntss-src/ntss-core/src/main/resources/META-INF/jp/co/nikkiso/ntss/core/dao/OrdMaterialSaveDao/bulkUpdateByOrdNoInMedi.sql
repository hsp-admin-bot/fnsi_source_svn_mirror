WITH ord_main_data AS (
  SELECT *
  from ord_main
  where ord_no in /*ordNoList*/('9967733')
)
,medi_data_ord AS (
  SELECT
    om.ord_no,
    om.facility_cd,
    om.pat_id,
    om.treat_date,
    om.reg_date,
    om.up_date,
    elem->>'medicine_type' AS medicine_type,
    elem->>'no' as medicine_no,
    elem->>'cd' as json_value,
    elem->>'procedure_cd' as procedure_cd,
    elem->>'timing_cd' as timing_cd,
    elem->>'amount' as amount,
    elem->>'unit' as unit,
    elem->>'class_cd' as class_cd,
    NULL AS effect_flg
FROM ord_main_data om
  CROSS JOIN jsonb_array_elements(om.ind_medi_info) AS elem
)
,mst_medicine_medi as (
select * from mst_medicine
where medicine_cd in (
  SELECT DISTINCT json_value::int
  from medi_data_ord
  where medicine_type = '1'
  )
)
,mst_medicine_mix_medi as (
select * from mst_medicine_mix
where medicine_mix_cd in (
  SELECT DISTINCT json_value::int
  from medi_data_ord
  where medicine_type != '1'
  )
)
,medi_data_tmp AS (
SELECT
  0::int8 AS ord_material_save_no,
  mdo.facility_cd,
  mdo.pat_id,
  mdo.treat_date AS supplies_base_date,
  mdo.ord_no AS supplies_base_no,
  '1' AS supplies_source_class,
  CASE WHEN mdo.medicine_type = '1' THEN '12' ELSE '13'
  END AS supplies_class,
  mdo.json_value AS supplies_cd,
  CASE WHEN mdo.medicine_type = '1' THEN NULL ELSE mdo.json_value
  END AS medicine_mix_cd,
  CASE WHEN mdo.medicine_type = '1' THEN mm.class_cd::TEXT ELSE mmm.class_cd::TEXT END AS class_cd,
  mdo.amount AS ind_rst_value,
  NULL AS receipt_value,
  '1' AS is_confirm,
  mdo.reg_date,
  mdo.up_date,
  json_build_object('no', mdo.medicine_no::INT) AS medicine_no,
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
  CASE WHEN mdo.medicine_type = '1' THEN mm.unit_second
  WHEN mdo.medicine_type = '2' THEN mmm.unit_second
  ELSE NULL
  END as receipt_unit,
  CASE WHEN mdo.medicine_type = '1' THEN mm.unit
  ELSE mmm.unit
  END as ind_unit,
  '0' as effect_flg,
  CASE WHEN mdo.medicine_type = '2' THEN mmm.medicine_set_num
  ELSE NULL
  END as medicine_set_num
FROM medi_data_ord mdo
  LEFT JOIN mst_medicine_medi mm ON mdo.json_value::int = mm.medicine_cd and mdo.medicine_type = '1'
  LEFT JOIN mst_medicine_mix_medi mmm ON mdo.json_value::int = mmm.medicine_mix_cd and mdo.medicine_type != '1'
)
,medi_data_save AS (
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
  md.ind_rst_value,
  md.receipt_value,
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
FROM medi_data_tmp md
)
,mst_medicine_mix_medi_save as (
select *
from mst_medicine_mix
where medicine_mix_cd in (
  SELECT DISTINCT medicine_mix_cd::int
  from medi_data_save
  where supplies_class = '13'
  )
)
,mst_medicine_medi_save as (
select *
from mst_medicine
where medicine_cd in (
  SELECT DISTINCT (elem->>'cd')::int
  from mst_medicine_mix_medi_save mmm
  CROSS JOIN jsonb_array_elements(mmm.mix_info) AS elem
  )
)
,medi_data_supplies as (
SELECT
  md.ord_material_save_no,
  md.facility_cd,
  md.pat_id,
  md.supplies_base_date,
  md.supplies_base_no,
  md.supplies_source_class,
  '20' as supplies_class,
  elem->>'cd' as supplies_cd,
  md.medicine_mix_cd,
  mm.class_cd::TEXT,
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
  NULL as medicine_set_num

FROM medi_data_save md
  LEFT JOIN mst_medicine_mix_medi_save mmm ON md.supplies_class = '13' and md.medicine_mix_cd::int = mmm.medicine_mix_cd
  CROSS JOIN jsonb_array_elements(mmm.mix_info) AS elem
  LEFT JOIN mst_medicine_medi_save mm ON (elem->>'cd')::int = mm.medicine_cd
UNION ALL
SELECT * FROM medi_data_save
)
,medi_data AS (
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
  ELSE (md.ind_rst_value::numeric * medicine_set_num)::text
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
FROM medi_data_supplies md
)
,del AS (
DELETE FROM ord_material_save
WHERE supplies_base_no in /*ordNoList*/('9967733')
  AND supplies_source_class = '1' and ind_rst_class = '1'
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
from medi_data

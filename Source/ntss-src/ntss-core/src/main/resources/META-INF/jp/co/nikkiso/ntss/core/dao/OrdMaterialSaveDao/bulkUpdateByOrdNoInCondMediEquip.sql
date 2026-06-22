WITH ord_main_data AS (
  SELECT *,
    (ind_cond_info -> '1' ->> 'value')::numeric AS v1,
    (ind_cond_info -> '16' ->> 'value')::numeric AS v16,
    (ind_cond_info -> '17' ->> 'value')::numeric AS v17,
    (ind_cond_info -> '20' ->> 'value')::numeric AS v20,
    (ind_cond_info -> '22' ->> 'value')::numeric AS v22,
    (ind_cond_info -> '26' ->> 'value')::numeric AS v26,
    (ind_cond_info -> '28' ->> 'value')::numeric AS v28,
    (rst_cond_info -> '1' ->> 'value')::numeric AS rv1,
    (rst_cond_info -> '16' ->> 'value')::numeric AS rv16,
    (rst_cond_info -> '17' ->> 'value')::numeric AS rv17,
    (rst_cond_info -> '20' ->> 'value')::numeric AS rv20,
    (rst_cond_info -> '22' ->> 'value')::numeric AS rv22,
    (rst_cond_info -> '26' ->> 'value')::numeric AS rv26,
    (rst_cond_info -> '28' ->> 'value')::numeric AS rv28
  from ord_main
  where ord_no in /*ordNoList*/('109598')
),
 ord_material_save_data AS (
   SELECT oms.* from ord_material_save oms INNER JOIN ord_main_data omd on oms.supplies_base_no = omd.ord_no
   where oms.supplies_source_class in ('0', '1', '2')
 )
,cond_data_ord AS (
   SELECT
    ord_no,
    facility_cd,
    pat_id,
    treat_date,
    '1' AS ind_rst_class,
    is_confirm,
    reg_date,
    up_date,
    v.key::int AS json_key,
    v.value->>'value' AS json_value,
    v.value->>'medicine_type' AS medicine_type,
    v.value->>'unit' as unit,
    rst_dialysis_state,
    CASE
    WHEN v.key::int IN (13,5,6,7,8,11,9,10) THEN '1'
    WHEN v.key::int = 15 THEN (v16 * v1 / 1000)::text
    WHEN v.key::int = 19 THEN v20::text
    WHEN v.key::int = 25 THEN (v26 + v28)::text
    ELSE NULL
    END AS amount,
    CASE
      WHEN v.key::int IN (13,5,6,7,8,11,9,10) THEN '1'
      WHEN v.key::int = 15 THEN v17::text
      WHEN v.key::int = 19 THEN v22::text
      WHEN v.key::int = 25 THEN NULL
      ELSE NULL
    END AS amount_second
  FROM ord_main_data
  CROSS JOIN LATERAL (
  VALUES
    ('13', ind_cond_info->'13'),
    ('5',  ind_cond_info->'5'),
    ('6',  ind_cond_info->'6'),
    ('7',  ind_cond_info->'7'),
    ('8',  ind_cond_info->'8'),
    ('11', ind_cond_info->'11'),
    ('9',  ind_cond_info->'9'),
    ('10', ind_cond_info->'10'),
    ('15', ind_cond_info->'15'),
    ('19', ind_cond_info->'19'),
    ('25', ind_cond_info->'25')
  ) AS v(key, value)
    WHERE v.value->>'value' IS NOT NULL
  UNION ALL
SELECT
  ord_no,
  facility_cd,
  pat_id,
  treat_date,
  '2' AS ind_rst_class,
  is_confirm,
  reg_date,
  up_date,
  v.key::int AS json_key,
  v.value->>'value' AS json_value,
  v.value->>'medicine_type' AS medicine_type,
  v.value->>'unit' as unit,
  rst_dialysis_state,
  CASE
  WHEN v.key::int IN (13,5,6,7,8,11,9,10) THEN '1'
  WHEN v.key = '15' THEN (rv16 * rv1 / 1000)::text
  WHEN v.key = '19' THEN rv20::text
  WHEN v.key = '25' THEN (rv26 + rv28)::text
  ELSE NULL
END AS amount,
    CASE
      WHEN v.key::int IN (13,5,6,7,8,11,9,10) THEN '1'
      WHEN v.key = '15' THEN rv17::text
      WHEN v.key = '19' THEN rv22::text
      WHEN v.key = '25' THEN NULL
      ELSE NULL
END AS amount_second
  FROM ord_main_data
  CROSS JOIN LATERAL (
  VALUES
    ('13', rst_cond_info->'13'),
    ('5',  rst_cond_info->'5'),
    ('6',  rst_cond_info->'6'),
    ('7',  rst_cond_info->'7'),
    ('8',  rst_cond_info->'8'),
    ('11', rst_cond_info->'11'),
    ('9',  rst_cond_info->'9'),
    ('10', rst_cond_info->'10'),
    ('15', rst_cond_info->'15'),
    ('19', rst_cond_info->'19'),
    ('25', rst_cond_info->'25')
) AS v(key, value)
    WHERE v.value->>'value' IS NOT NULL
),
mst_medicine_cond as (
  select *
  from mst_medicine
  where medicine_cd in (
    SELECT DISTINCT json_value::int
    from cond_data_ord
    where medicine_type = '1' and json_key in (15,19,25)
  )
),
mst_medicine_mix_cond as (
  select *
  from mst_medicine_mix
  where medicine_mix_cd in (
    SELECT DISTINCT json_value::int
    from cond_data_ord
    where medicine_type != '1' and json_key in (15,19,25)
  )
),
mst_equipment_cond as (
  select *
  from mst_equipment
  where equipment_cd in (
    SELECT DISTINCT json_value::int
    from cond_data_ord
    where json_key in (13,6,7,8,11,9,10)
  )
),
cond_data_tmp AS (
SELECT
  0::int8 AS ord_material_save_no,
  cdo.facility_cd,
  cdo.pat_id,
  cdo.treat_date AS supplies_base_date,
  cdo.ord_no AS supplies_base_no,
  '0' AS supplies_source_class,
  CASE
    WHEN cdo.json_key = 25 THEN
      CASE WHEN cdo.medicine_type = '1' THEN '10' ELSE '17' END
    ELSE
      CASE cdo.json_key
        WHEN 13 THEN '00'
        WHEN 5  THEN '01'
        WHEN 6  THEN '02'
        WHEN 7  THEN '03'
        WHEN 8  THEN '04'
        WHEN 11 THEN '05'
        WHEN 9  THEN '06'
        WHEN 10 THEN '07'
        WHEN 15 THEN '08'
        WHEN 19 THEN '09'
      END
  END AS supplies_class,
  cdo.medicine_type,
  cdo.json_value AS supplies_cd,
  CASE WHEN cdo.json_key in (15,19,25) THEN
         CASE WHEN cdo.medicine_type = '1' THEN NULL ELSE cdo.json_value END
  END AS medicine_mix_cd,
  CASE WHEN cdo.json_key in (15,19,25) THEN
   CASE WHEN cdo.medicine_type = '1' THEN mm.class_cd::TEXT ELSE mmm.class_cd::TEXT END
  ELSE me.class_cd::TEXT
  END AS class_cd,
  cdo.ind_rst_class,
  cdo.amount AS ind_rst_value,
  cdo.amount_second AS receipt_value,
  CASE WHEN cdo.ind_rst_class = '1' THEN '1'
       ELSE
         CASE
           WHEN cdo.rst_dialysis_state = '6' THEN '1' ELSE '0'
         END
  END AS is_confirm,
  cdo.reg_date,
  cdo.up_date,
  NULL::json as medicine_no,
  NULL as procedure_cd,
  NULL as timing_cd,
  CASE WHEN cdo.json_key in (15,19,25) and cdo.medicine_type = '1' THEN
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
  CASE WHEN cdo.json_key in (15,19,25) THEN
        CASE WHEN cdo.medicine_type = '1' THEN mm.unit_second
             WHEN cdo.medicine_type = '2' THEN mmm.unit_second
             ELSE null
        END
       ELSE
        CASE WHEN cdo.json_key = 5 THEN '本'
        ELSE me.unit
        END
  END as receipt_unit,
  CASE WHEN cdo.json_key in (15,19,25) THEN
        CASE WHEN cdo.medicine_type = '1' THEN mm.unit
             ELSE mmm.unit
        END
       ELSE
        CASE WHEN cdo.json_key = 5 THEN '本'
        ELSE me.unit
        END
  END as ind_unit,
  '1' as effect_flg,
  rst_dialysis_state,
  CASE WHEN cdo.json_key in (25) THEN
        CASE WHEN cdo.medicine_type = '2' THEN mmm.medicine_set_num
        ELSE NULL
       END
  END as medicine_set_num

FROM cond_data_ord cdo
       LEFT JOIN mst_medicine_cond mm ON cdo.json_value::int = mm.medicine_cd and cdo.medicine_type = '1' and cdo.json_key in (15,19,25)
       LEFT JOIN mst_medicine_mix_cond mmm ON cdo.json_value::int = mmm.medicine_mix_cd and cdo.medicine_type != '1' and cdo.json_key in (15,19,25)
       LEFT JOIN mst_equipment_cond me ON cdo.json_value::int = me.equipment_cd and cdo.json_key in (13,6,7,8,11,9,10)
),
cond_data_save AS (
SELECT cd.ord_material_save_no,
       cd.facility_cd,
       cd.pat_id,
       cd.supplies_base_date,
       cd.supplies_base_no,
       cd.supplies_source_class,
       cd.supplies_class,
       cd.supplies_cd,
       cd.medicine_mix_cd,
       CASE WHEN oms.ord_material_save_no is not null THEN oms.class_cd
            ELSE cd.class_cd
       END as class_cd,
       cd.ind_rst_class,
       cd.ind_rst_value,
       cd.receipt_value,
       cd.is_confirm,
       cd.reg_date,
       cd.up_date,
       cd.medicine_no,
       cd.procedure_cd,
       cd.timing_cd,
       CASE WHEN oms.ord_material_save_no is not null THEN oms.receipt_conversion
            ELSE cd.receipt_conversion
       END as receipt_conversion,
       cd.prescription_unit,
       cd.frequency_flg,
       cd.frequency_num,
       CASE WHEN oms.ord_material_save_no is not null AND cd.medicine_type = '1' THEN oms.receipt_unit
            ELSE cd.receipt_unit
       END as receipt_unit,
       CASE WHEN oms.ord_material_save_no is not null THEN oms.ind_unit
            ELSE cd.ind_unit
       END as ind_unit,
       cd.effect_flg,
       cd.rst_dialysis_state,
       CASE WHEN oms.ord_material_save_no is not null THEN '1' ELSE '2' END as has_flg,
       cd.medicine_set_num

FROM cond_data_tmp cd
       LEFT JOIN ord_material_save_data oms ON cd.rst_dialysis_state != '0' AND cd.facility_cd = oms.facility_cd and cd.pat_id = oms.pat_id and oms.supplies_base_no = cd.supplies_base_no
                                            and cd.supplies_class = oms.supplies_class and cd.supplies_cd = oms.supplies_cd
                                            and cd.ind_rst_class = oms.ind_rst_class and cd.supplies_source_class = oms.supplies_source_class
),
mst_medicine_mix_cond_save as (
  select *
  from mst_medicine_mix
  where medicine_mix_cd in (
    SELECT DISTINCT medicine_mix_cd::int
    from cond_data_save
    where supplies_class = '17' and has_flg = '2'
  )
),
mst_medicine_cond_save as (
  select *
  from mst_medicine
  where medicine_cd in (
    SELECT DISTINCT (elem->>'cd')::int
    from mst_medicine_mix_cond_save mmm
    CROSS JOIN jsonb_array_elements(mmm.mix_info) AS elem
  )
),
cond_data_supplies as (
SELECT
  cd.ord_material_save_no,
  cd.facility_cd,
  cd.pat_id,
  cd.supplies_base_date,
  cd.supplies_base_no,
  cd.supplies_source_class,
  '22' as supplies_class,
  oms.supplies_cd,
  cd.medicine_mix_cd,
  oms.class_cd,
  cd.ind_rst_class,
  CASE WHEN elem->>'solvent' = '1' THEN ROUND((elem->>'amount')::numeric, COALESCE((oms.receipt_conversion->>'unit_decimal_point')::int, 0))::TEXT
       ELSE ROUND((elem->>'amount')::numeric * cd.ind_rst_value::numeric, COALESCE((oms.receipt_conversion->>'unit_decimal_point')::int, 0))::TEXT
  END as ind_rst_value,
  NULL AS receipt_value,
  cd.is_confirm,
  cd.reg_date,
  cd.up_date,
  cd.medicine_no,
  cd.procedure_cd,
  cd.timing_cd,
  oms.receipt_conversion,
  NULL as prescription_unit,
  NULL as frequency_flg,
  NULL as frequency_num,
  oms.receipt_unit,
  oms.ind_unit,
  cd.effect_flg,
  cd.rst_dialysis_state,
  cd.has_flg,
  NULL::int AS medicine_set_num

FROM cond_data_save cd
       CROSS JOIN jsonb_array_elements(cd.receipt_conversion) AS elem
       INNER JOIN ord_material_save_data oms ON cd.facility_cd = oms.facility_cd and cd.pat_id = oms.pat_id and oms.supplies_base_no = cd.supplies_base_no
                                            and oms.supplies_class = '22' and cd.supplies_class = '17' and cd.supplies_source_class = oms.supplies_source_class
                                            and cd.ind_rst_class = oms.ind_rst_class and cd.medicine_mix_cd = oms.medicine_mix_cd and elem->>'cd' = oms.supplies_cd
 where cd.has_flg = '1'
  UNION ALL
SELECT
  cd.ord_material_save_no,
  cd.facility_cd,
  cd.pat_id,
  cd.supplies_base_date,
  cd.supplies_base_no,
  cd.supplies_source_class,
  '22' as supplies_class,
  elem->>'cd' as supplies_cd,
  cd.medicine_mix_cd,
  mm.class_cd::TEXT,
  cd.ind_rst_class,
  CASE WHEN elem->>'solvent' = '1' THEN ROUND((elem->>'amount')::numeric, COALESCE(mm.unit_decimal_point, 0))::TEXT
       ELSE ROUND((elem->>'amount')::numeric * cd.ind_rst_value::numeric, COALESCE(mm.unit_decimal_point, 0))::TEXT
  END as ind_rst_value,
  NULL AS receipt_value,
  cd.is_confirm,
  cd.reg_date,
  cd.up_date,
  cd.medicine_no,
  cd.procedure_cd,
  cd.timing_cd,
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
  cd.effect_flg,
  cd.rst_dialysis_state,
  cd.has_flg,
  NULL::int AS medicine_set_num

FROM cond_data_save cd
       LEFT JOIN mst_medicine_mix_cond_save mmm ON cd.supplies_class = '17' and cd.medicine_mix_cd::int = mmm.medicine_mix_cd
       CROSS JOIN jsonb_array_elements(mmm.mix_info) AS elem
       LEFT JOIN mst_medicine_cond_save mm ON (elem->>'cd')::int = mm.medicine_cd
 where cd.has_flg = '2'
  UNION ALL
SELECT * FROM cond_data_save
),
cond_data AS (
SELECT cd.ord_material_save_no,
       cd.facility_cd,
       cd.pat_id,
       cd.supplies_base_date,
       cd.supplies_base_no,
       cd.supplies_source_class,
       cd.supplies_class,
       cd.supplies_cd,
       cd.medicine_mix_cd,
       cd.class_cd,
       cd.ind_rst_class,
       CASE WHEN receipt_conversion is not null and supplies_class not in ('08','09','17') THEN
              ROUND(cd.ind_rst_value::numeric, COALESCE((receipt_conversion->>'unit_decimal_point')::int, 0))::text
            WHEN supplies_class = '08' THEN
              ROUND(cd.ind_rst_value::numeric, 2)::text
            WHEN supplies_class = '09' THEN
              ROUND(cd.ind_rst_value::numeric, 1)::text
            ELSE cd.ind_rst_value::text
       END as ind_rst_value,
       CASE WHEN receipt_conversion is not null THEN
              CASE WHEN supplies_class in ('10', '22') THEN
                    CASE WHEN receipt_conversion->>'is_exchange' = '0' THEN
                          COALESCE(ROUND(cd.ind_rst_value::numeric / NULLIF((receipt_conversion->>'unit_converted_amount')::numeric, 0) *
                           (receipt_conversion->>'unit_converted_amount_second')::numeric, COALESCE((receipt_conversion->>'unit_decimal_point_second')::int, 0)),
                           ROUND(0, COALESCE((receipt_conversion->>'unit_decimal_point_second')::int, 0)))::text
                         WHEN receipt_conversion->>'is_exchange' = '1' THEN
                          COALESCE(ROUND(CEIL(cd.ind_rst_value::numeric / NULLIF((receipt_conversion->>'unit_converted_amount')::numeric, 0)) *
                           (receipt_conversion->>'unit_converted_amount_second')::numeric, COALESCE((receipt_conversion->>'unit_decimal_point_second')::int, 0)),
                           ROUND(0, COALESCE((receipt_conversion->>'unit_decimal_point_second')::int, 0)))::text
                         WHEN receipt_conversion->>'is_exchange' = '2' THEN
                           ROUND((receipt_conversion->>'unit_converted_amount_second')::numeric, COALESCE((receipt_conversion->>'unit_decimal_point_second')::int, 0))::text
                    END
                   WHEN supplies_class in ('17') THEN (1 * cd.medicine_set_num)::text
                   ELSE ROUND(cd.receipt_value::numeric, COALESCE((receipt_conversion->>'unit_decimal_point_second')::int, 0))::text
              END
            ELSE cd.receipt_value::text
       END as receipt_value,
       cd.is_confirm,
       cd.reg_date,
       cd.up_date,
       cd.medicine_no,
       cd.procedure_cd,
       cd.timing_cd,
--        CASE WHEN cd.rst_dialysis_state = '0' THEN NULL::jsonb
--             ELSE cd.receipt_conversion
--        END AS receipt_conversion,
       receipt_conversion,
       cd.prescription_unit,
       cd.frequency_flg,
       cd.frequency_num,
       cd.receipt_unit,
       cd.ind_unit,
       cd.effect_flg,
       cd.medicine_set_num
FROM cond_data_supplies cd
),
medi_data_ord AS (
  SELECT
    om.ord_no,
    om.facility_cd,
    om.pat_id,
    om.treat_date,
    '1' as ind_rst_class,
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
    NULL AS effect_flg,
    om.rst_dialysis_state
  FROM ord_main_data om
  CROSS JOIN jsonb_array_elements(om.ind_medi_info) AS elem

  UNION ALL

  SELECT
    om.ord_no,
    om.facility_cd,
    om.pat_id,
    om.treat_date,
    '2' as ind_rst_class,
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
    elem->>'effect_flg' as effect_flg,
    om.rst_dialysis_state
  FROM ord_main_data om
  CROSS JOIN jsonb_array_elements(om.rst_medi_info) AS elem
  where rst_dialysis_state != '0'
),
mst_medicine_medi as (
  select *
  from mst_medicine
  where medicine_cd in (
    SELECT DISTINCT json_value::int
    from medi_data_ord
    where medicine_type = '1'
  )
),
mst_medicine_mix_medi as (
  select *
  from mst_medicine_mix
  where medicine_mix_cd in (
    SELECT DISTINCT json_value::int
    from medi_data_ord
    where medicine_type != '1'
  )
),
medi_data_tmp AS (
SELECT
  0::int8 AS ord_material_save_no,
  mdo.facility_cd,
  mdo.pat_id,
  mdo.treat_date AS supplies_base_date,
  mdo.ord_no AS supplies_base_no,
  '1' AS supplies_source_class,
  CASE WHEN mdo.medicine_type = '1' THEN '12' ELSE '13'
  END AS supplies_class,
  mdo.medicine_type,
  mdo.json_value AS supplies_cd,
  CASE WHEN mdo.medicine_type = '1' THEN NULL ELSE mdo.json_value
  END AS medicine_mix_cd,
  CASE WHEN mdo.rst_dialysis_state = '0' THEN
         CASE WHEN mdo.medicine_type = '1' THEN mm.class_cd::TEXT ELSE mmm.class_cd::TEXT END
       ELSE mdo.class_cd
  END AS class_cd,
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
  CASE WHEN mdo.ind_rst_class = '1' THEN '0'
       ELSE mdo.effect_flg
  END as effect_flg,
  mdo.rst_dialysis_state,
  CASE WHEN mdo.medicine_type = '2' THEN mmm.medicine_set_num
       ELSE NULL
  END as medicine_set_num

FROM medi_data_ord mdo
       LEFT JOIN mst_medicine_medi mm ON mdo.json_value::int = mm.medicine_cd and mdo.medicine_type = '1'
       LEFT JOIN mst_medicine_mix_medi mmm ON mdo.json_value::int = mmm.medicine_mix_cd and mdo.medicine_type != '1'
),
medi_data_save AS (
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
       CASE WHEN oms.ord_material_save_no is not null AND md.medicine_type = '1' THEN oms.receipt_unit
            ELSE md.receipt_unit
       END as receipt_unit,
       CASE WHEN oms.ord_material_save_no is not null THEN oms.ind_unit
            ELSE md.ind_unit
       END as ind_unit,
       md.effect_flg,
       md.rst_dialysis_state,
       CASE WHEN oms.ord_material_save_no is not null THEN '1' ELSE '2' END as has_flg,
       md.medicine_set_num
FROM medi_data_tmp md
       LEFT JOIN ord_material_save_data oms ON md.rst_dialysis_state != '0' AND md.facility_cd = oms.facility_cd and md.pat_id = oms.pat_id and oms.supplies_base_no = md.supplies_base_no
                                            and md.supplies_class = oms.supplies_class and oms.medicine_no->>'no' = md.medicine_no->>'no' and md.supplies_cd = oms.supplies_cd
                                            and md.ind_rst_class = oms.ind_rst_class and md.supplies_source_class = oms.supplies_source_class
),
mst_medicine_mix_medi_save as (
  select *
  from mst_medicine_mix
  where medicine_mix_cd in (
    SELECT DISTINCT medicine_mix_cd::int
    from medi_data_save
    where supplies_class = '13' and has_flg = '2'
  )
),
mst_medicine_medi_save as (
  select *
  from mst_medicine
  where medicine_cd in (
    SELECT DISTINCT (elem->>'cd')::int
    from mst_medicine_mix_medi_save mmm
    CROSS JOIN jsonb_array_elements(mmm.mix_info) AS elem
  )
),
medi_data_supplies as (
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

FROM medi_data_save md
       CROSS JOIN jsonb_array_elements(md.receipt_conversion) AS elem
       INNER JOIN ord_material_save_data oms ON md.facility_cd = oms.facility_cd and md.pat_id = oms.pat_id and oms.supplies_base_no = md.supplies_base_no
                                            and oms.supplies_class = '20' and md.supplies_class = '13' and md.supplies_source_class = oms.supplies_source_class
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
  '20' as supplies_class,
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

FROM medi_data_save md
       LEFT JOIN mst_medicine_mix_medi_save mmm ON md.supplies_class = '13' and md.medicine_mix_cd::int = mmm.medicine_mix_cd
       CROSS JOIN jsonb_array_elements(mmm.mix_info) AS elem
       LEFT JOIN mst_medicine_medi_save mm ON (elem->>'cd')::int = mm.medicine_cd
 where md.has_flg = '2'
  UNION ALL
SELECT * FROM medi_data_save
),
medi_data AS (
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
--        CASE WHEN md.rst_dialysis_state = '0' THEN NULL::jsonb
--             ELSE md.receipt_conversion
--        END AS receipt_conversion,
       md.receipt_conversion,
       md.prescription_unit,
       md.frequency_flg,
       md.frequency_num,
       md.receipt_unit,
       md.ind_unit,
       md.effect_flg,
       md.medicine_set_num
FROM medi_data_supplies md
),
equip_data_ord AS (
  SELECT
    om.ord_no,
    om.facility_cd,
    om.pat_id,
    om.treat_date,
    '1' as ind_rst_class,
    om.reg_date,
    om.up_date,
    elem->>'equip_type' AS equip_type,
    elem->>'class_cd' AS class_cd,
    elem->>'no' as equip_no,
    elem->>'cd' as json_value,
    elem->>'amount' as amount,
    elem->>'unit' as unit,
    om.rst_dialysis_state
  FROM ord_main_data om
  CROSS JOIN jsonb_array_elements(om.ind_equip_info) AS elem

  UNION ALL

  SELECT
    om.ord_no,
    om.facility_cd,
    om.pat_id,
    om.treat_date,
    '2' as ind_rst_class,
    om.reg_date,
    om.up_date,
    elem->>'equip_type' AS equip_type,
    elem->>'class_cd' AS class_cd,
    elem->>'no' as equip_no,
    elem->>'cd' as json_value,
    elem->>'amount' as amount,
    elem->>'unit' as unit,
    om.rst_dialysis_state
  FROM ord_main_data om
  CROSS JOIN jsonb_array_elements(om.rst_equip_info) AS elem
  where rst_dialysis_state != '0'
),
mst_equipment_equip as (
  select *
  from mst_equipment
  where equipment_cd in (
    SELECT DISTINCT json_value::int
    from equip_data_ord
    where equip_type != '1'
  )
),
equip_data_tmp AS (
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
  CASE WHEN edo.rst_dialysis_state = '0' THEN me.class_cd::TEXT
       ELSE edo.class_cd
  END AS class_cd,
  edo.ind_rst_class,
  edo.amount::TEXT AS ind_rst_value,
  edo.amount::TEXT AS receipt_value,
  CASE WHEN edo.ind_rst_class = '1' THEN '1'
       ELSE
         CASE
           WHEN edo.rst_dialysis_state = '6' THEN '1' ELSE '0'
         END
  END AS is_confirm,
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
  CASE WHEN edo.rst_dialysis_state = '0' THEN
        CASE WHEN edo.equip_type = '1' THEN '本'
             ELSE me.unit
       END
       ELSE edo.unit
  END as receipt_unit,
  CASE WHEN edo.rst_dialysis_state = '0' THEN
        CASE WHEN edo.equip_type = '1' THEN '本'
             ELSE me.unit
       END
       ELSE edo.unit
  END as ind_unit,
  '1' as effect_flg,
  edo.rst_dialysis_state

FROM equip_data_ord edo
  LEFT JOIN mst_equipment_equip me ON edo.json_value::int = me.equipment_cd and edo.equip_type != '1'
),
equip_data AS (
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
   ed.ind_rst_class,
   ed.ind_rst_value,
   ed.receipt_value,
   ed.is_confirm,
   ed.reg_date,
   ed.up_date,
   ed.medicine_no,
   ed.procedure_cd,
   ed.timing_cd,
   CASE WHEN oms.ord_material_save_no is not null THEN oms.receipt_conversion
        ELSE ed.receipt_conversion
   END as receipt_conversion,
   ed.prescription_unit,
   ed.frequency_flg,
   ed.frequency_num,
   CASE WHEN oms.ord_material_save_no is not null THEN oms.receipt_unit
        ELSE ed.receipt_unit
   END as receipt_unit,
   CASE WHEN oms.ord_material_save_no is not null THEN oms.ind_unit
        ELSE ed.ind_unit
   END as ind_unit,
   ed.effect_flg,
   NULL::int as medicine_set_num
  FROM equip_data_tmp ed
   LEFT JOIN ord_material_save_data oms ON ed.rst_dialysis_state != '0' AND ed.facility_cd = oms.facility_cd and ed.pat_id = oms.pat_id and oms.supplies_base_no = ed.supplies_base_no
    and ed.supplies_class = oms.supplies_class and ed.supplies_cd = oms.supplies_cd
    and ed.ind_rst_class = oms.ind_rst_class and ed.supplies_source_class = oms.supplies_source_class
)
,ord_data_all as (
SELECT * FROM cond_data
  UNION ALL
SELECT * FROM medi_data
  UNION ALL
SELECT * FROM equip_data
)
,del AS (
  DELETE FROM ord_material_save
  WHERE supplies_base_no in /*ordNoList*/('109598')
  AND supplies_source_class in ('0', '1', '2')
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
from ord_data_all

WITH ord_main_data AS (
  SELECT *,
    (ind_cond_info -> '1' ->> 'value')::numeric AS v1,
    (ind_cond_info -> '16' ->> 'value')::numeric AS v16,
    (ind_cond_info -> '17' ->> 'value')::numeric AS v17,
    (ind_cond_info -> '20' ->> 'value')::numeric AS v20,
    (ind_cond_info -> '22' ->> 'value')::numeric AS v22,
    (ind_cond_info -> '26' ->> 'value')::numeric AS v26,
    (ind_cond_info -> '28' ->> 'value')::numeric AS v28
  from ord_main
  where ord_no in /*ordNoList*/('9967733')
)
,cond_data_ord AS (
  SELECT
    ord_no,
    facility_cd,
    pat_id,
    treat_date,
    is_confirm,
    reg_date,
    up_date,
    v.key::int AS json_key,
    v.value->>'value' AS json_value,
    v.value->>'medicine_type' AS medicine_type,
    v.value->>'unit' as unit,
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
)
,mst_medicine_cond as (
    select * from mst_medicine
    where medicine_cd in (
    SELECT DISTINCT json_value::int
      from cond_data_ord
      where medicine_type = '1' and json_key in (15,19,25)
    )
)
,mst_medicine_mix_cond as (
    select * from mst_medicine_mix
    where medicine_mix_cd in (
      SELECT DISTINCT json_value::int
      from cond_data_ord

      where medicine_type != '1' and json_key in (15,19,25)
    )
)
,mst_equipment_cond as (
    select * from mst_equipment
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
    CASE WHEN cdo.json_key = 25 THEN
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
    cdo.json_value AS supplies_cd,
    CASE WHEN cdo.json_key in (15,19,25) THEN
           CASE WHEN cdo.medicine_type = '1' THEN NULL ELSE cdo.json_value END
    END AS medicine_mix_cd,
    CASE WHEN cdo.json_key in (15,19,25) THEN
             CASE WHEN cdo.medicine_type = '1' THEN mm.class_cd::TEXT ELSE mmm.class_cd::TEXT END
           ELSE me.class_cd::TEXT
           END AS class_cd,

    cdo.amount AS ind_rst_value,
    cdo.amount_second AS receipt_value,
    '1' AS is_confirm,
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
    CASE WHEN cdo.json_key in (25) THEN
		CASE WHEN cdo.medicine_type = '2' THEN mmm.medicine_set_num
        ELSE NULL
	END
  END as medicine_set_num

  FROM cond_data_ord cdo
         LEFT JOIN mst_medicine_cond mm ON cdo.json_value::int = mm.medicine_cd and cdo.medicine_type = '1' and cdo.json_key in (15,19,25)
         LEFT JOIN mst_medicine_mix_cond mmm ON cdo.json_value::int = mmm.medicine_mix_cd and cdo.medicine_type != '1' and cdo.json_key in (15,19,25)
         LEFT JOIN mst_equipment_cond me ON cdo.json_value::int = me.equipment_cd and cdo.json_key in (13,6,7,8,11,9,10)
  )
  ,cond_data_save AS (
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
       cd.ind_rst_value,
       cd.receipt_value,
       cd.is_confirm,
       cd.reg_date,
       cd.up_date,
       cd.medicine_no,
       cd.procedure_cd,
       cd.timing_cd,
       cd.receipt_conversion,
       cd.prescription_unit,
       cd.frequency_flg,
       cd.frequency_num,
       cd.receipt_unit,
       cd.ind_unit,
       cd.effect_flg,
       cd.medicine_set_num
  FROM cond_data_tmp cd
  )
  ,mst_medicine_mix_cond_save as (
    select *
    from mst_medicine_mix
    where medicine_mix_cd in (
      SELECT DISTINCT medicine_mix_cd::int
      from cond_data_save
      where supplies_class = '17'
    )
  )
  ,mst_medicine_cond_save as (
    select *
    from mst_medicine
    where medicine_cd in (
      SELECT DISTINCT (elem->>'cd')::int
      from mst_medicine_mix_cond_save mmm
      CROSS JOIN jsonb_array_elements(mmm.mix_info) AS elem
    )
  )
  ,cond_data_supplies as (
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
    NULL as medicine_set_num
  FROM cond_data_save cd
         LEFT JOIN mst_medicine_mix_cond_save mmm ON cd.supplies_class = '17' and cd.medicine_mix_cd::int = mmm.medicine_mix_cd
         CROSS JOIN jsonb_array_elements(mmm.mix_info) AS elem
         LEFT JOIN mst_medicine_cond_save mm ON (elem->>'cd')::int = mm.medicine_cd
    UNION ALL
  SELECT * FROM cond_data_save
  )
  ,cond_data AS (
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
       receipt_conversion,
       cd.prescription_unit,
       cd.frequency_flg,
       cd.frequency_num,
       cd.receipt_unit,
       cd.ind_unit,
       cd.effect_flg,
       cd.medicine_set_num
  FROM cond_data_supplies cd
)
,del AS MATERIALIZED (
  DELETE FROM ord_material_save
  WHERE supplies_base_no in /*ordNoList*/('9967733')
  AND supplies_source_class = '0' and ind_rst_class = '1'
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
from cond_data

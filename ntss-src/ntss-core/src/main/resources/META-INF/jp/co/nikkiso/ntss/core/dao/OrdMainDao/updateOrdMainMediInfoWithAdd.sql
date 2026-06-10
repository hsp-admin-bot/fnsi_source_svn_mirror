WITH raw_data as (
  SELECT
    elem ->> 'medicine_type' AS medicine_type
    ,(elem ->>'cd')::numeric AS cd
    ,(elem ->>'timing_cd')::numeric AS timing_cd
    ,(elem ->>'procedure_cd')::numeric AS procedure_cd
    ,elem - 'isAmountchg' - 'class_cd' - 'class_name' - 'class_type' - 'name' - 'short_name' - 'unit' - 'timing_name' - 'procedure_name'  AS elem
    ,ordinality
  FROM jsonb_array_elements(/*changeMediInfo*/''::jsonb) WITH ORDINALITY AS t(elem, ordinality)
)
,base_ord as (
  SELECT
    ord_no
    ,ind_medi_info
    ,rst_medi_info
    ,rst_dialysis_state
  FROM ord_main
  WHERE ord_no in /*ordNoList*/(10768848)
)
,mst_data AS (
  SELECT
    r.ordinality,
    r.cd,
    mm.class_cd,
    mm.medicine_name AS name,
    mm.medicine_name AS short_name,
    mm.unit,
    mm.is_medicated,
    mc.class_name,
    mc.class_type,
    mt.medicate_timing_name AS timing_name,
    mp.pricedure_name AS procedure_name
  FROM raw_data r
    JOIN mst_medicine mm
      ON r.cd = mm.medicine_cd
      AND r.medicine_type = '1'
      AND mm.is_del = '0'
    LEFT JOIN mst_medicine_class mc
      ON mm.class_cd IS NOT NULL
      AND mc.class_cd = mm.class_cd
      AND mc.is_del = '0'
    LEFT JOIN mst_medicate_timing mt
      ON r.timing_cd IS NOT NULL
      AND mt.medicate_timing_cd = r.timing_cd
      AND mt.is_del = '0'
    LEFT JOIN mst_procedure mp
      ON r.procedure_cd IS NOT NULL
      AND mp.procedure_cd = r.procedure_cd
      AND mp.is_del = '0'
  UNION ALL
  SELECT
    r.ordinality,
    r.cd,
    mmm.class_cd,
    mmm.medicine_mix_name AS name,
    mmm.medicine_mix_short_name AS short_name,
    mmm.unit,
    mmm.is_medicated,
    mc.class_name,
    mc.class_type,
    mt.medicate_timing_name AS timing_name,
    mp.pricedure_name AS procedure_name
  FROM raw_data r
    JOIN mst_medicine_mix mmm
      ON r.cd = mmm.medicine_mix_cd
      AND r.medicine_type = '2'
      AND mmm.is_del = '0'
      AND mmm.is_disp = '1'
    LEFT JOIN mst_medicine_class mc
      ON mmm.class_cd IS NOT NULL
      AND mc.class_cd = mmm.class_cd
      AND mc.is_del = '0'
    LEFT JOIN mst_medicate_timing mt
      ON r.timing_cd IS NOT NULL
      AND mt.medicate_timing_cd = r.timing_cd
      AND mt.is_del = '0'
    LEFT JOIN mst_procedure mp
      ON r.procedure_cd IS NOT NULL
      AND mp.procedure_cd = r.procedure_cd
      AND mp.is_del = '0'
)
,final_ord_append_data as (
  SELECT
    b.ord_no,
    CASE WHEN b.rst_dialysis_state <> '0' and m.ordinality IS NOT NULL
          THEN
            jsonb_build_object(
              'class_cd', m.class_cd,
              'name', m.name,
              'short_name', m.short_name,
              'unit', m.unit,
              'class_name', m.class_name,
              'class_type', m.class_type,
              'timing_name', m.timing_name,
              'procedure_name', m.procedure_name
            )
            || (r.elem-'effect_flg'-'effect_date'-'effect_user_id'-'effect_user_last_name'-'effect_user_first_name')
            ||
            CASE WHEN b.rst_dialysis_state = '3' AND m.is_medicated = '1'
              THEN jsonb_build_object(
                'effect_flg', 1,
                'effect_date', to_char(CURRENT_TIMESTAMP, 'YYYY-MM-DD"T"HH24:MI:SS'),
                'effect_user_id', r.elem->'effect_user_id',
                'effect_user_last_name', r.elem->'effect_user_last_name',
                'effect_user_first_name', r.elem->'effect_user_first_name'
              )
              ELSE '{}'::jsonb
            END
          ELSE '{}'::jsonb
        END || r.elem AS final_elem
  FROM raw_data r
    JOIN base_ord b ON true
    LEFT JOIN mst_data m
      ON r.ordinality = m.ordinality
)
,upd_data as (
SELECT
  b.ord_no,
  COALESCE(b.ind_medi_info, '[]'::jsonb)
  || jsonb_agg(f.final_elem- 'effect_flg'- 'effect_date'- 'effect_user_id'- 'effect_user_last_name'- 'effect_user_first_name') AS new_ind_medi_info,
  CASE WHEN b.rst_dialysis_state <> '0' AND /*isRstUpdate*/'false' = 'true'
    THEN COALESCE(b.rst_medi_info, '[]'::jsonb)
      || jsonb_agg(f.final_elem)
    ELSE b.rst_medi_info
   END AS new_rst_medi_info
FROM base_ord b
  LEFT JOIN final_ord_append_data f
    ON b.ord_no = f.ord_no
GROUP BY
  b.ord_no, b.ind_medi_info, b.rst_medi_info, b.rst_dialysis_state
)
update ord_main
set
  ind_medi_info = ud.new_ind_medi_info,
  rst_medi_info = ud.new_rst_medi_info,
  up_ind_user_id = /*upIndUserId*/null,
  up_user_id = /*upUserId*/null,
  /*%if "true" == isRstUpdate*/
  is_confirm = case when rst_dialysis_state = '6' then '0' else is_confirm end,
  /*%end*/
  up_date = CURRENT_TIMESTAMP
FROM upd_data ud
where
  ord_main.ord_no = ud.ord_no
  AND ord_main.ord_no in /*ordNoList*/(10768848)
RETURNING ord_main.*

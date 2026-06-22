WITH raw_data as (
  SELECT
    elem ->> 'medicine_type' AS medicine_type
    ,(elem ->>'cd')::numeric AS cd
    ,(elem ->>'timing_cd')::numeric AS timing_cd
    ,(elem ->>'procedure_cd')::numeric AS procedure_cd
    ,elem ->> 'isAmountchg' AS is_amount_chg
    ,CASE WHEN elem ?? 'amount' THEN jsonb_set(elem, '{amount}', to_jsonb(elem->>'amount')) ELSE elem END
        -'isAmountchg'
        -'class_cd'
        -'class_name'
        -'class_type'
        -'name'
        -'short_name'
        -'timing_name'
        -'procedure_name'
      AS elem
  FROM (select /*changeMediInfo*/''::jsonb as elem) as input_data
)
,base_ord as (
  SELECT
    ord_no
    ,pat_id
    ,treat_date
    ,treat_week
    ,ind_medi_info
    ,rst_medi_info
    ,rst_dialysis_state
  FROM ord_main
  WHERE ord_no in /*ordNoList*/(10768848)
)
,dual_ord as (
  SELECT
    ord_no
    ,treat_week
    ,ind_medi_info
    ,rst_medi_info
    ,rst_dialysis_state
    ,CASE WHEN /*isEditOtherAmount*/'false' = 'false' THEN 'change'
      WHEN /*isEditOtherAmount*/'false' = 'true' and treat_week IN /*weeksArray*/(1,3,5)
       AND treat_date IN /*treatDates*/('20260101') THEN 'del-add'
       ELSE 'del'
     END AS dual_flg
  FROM base_ord
)
,PAT_INFO AS (
  SELECT
    pat_main.pat_id,
    elem ->> 'category_class' AS category_class,
    elem ->> 'taboo_allergy_class' AS taboo_allergy_class,
    (elem ->> 'taboo_allergy_cd')::int AS taboo_allergy_cd
  FROM pat_main
  CROSS JOIN LATERAL jsonb_array_elements(COALESCE(pat_main.taboo_allergy_info, '[]'::jsonb)) elem
  WHERE pat_main.pat_id IN (SELECT DISTINCT bo.pat_id FROM base_ord bo WHERE bo.pat_id IS NOT NULL)
)
,TABOO_ALLERGY AS (
  SELECT
    pd.pat_id,
    elem ->> 'classCd' AS category_class,
    pd.taboo_allergy_class,
    (elem ->> 'cd')::int AS cd
  FROM PAT_INFO pd
  INNER JOIN mst_taboo_allergy mta
    ON pd.taboo_allergy_cd = mta.taboo_allergy_cd
    AND pd.category_class = '0'
  CROSS JOIN LATERAL jsonb_array_elements(COALESCE(mta.detail_info, '[]'::jsonb)) elem
  WHERE elem ->> 'classCd' IN ('1', '2', '3', '4')
)
,TABOO_ALLERGY_TMP AS (
  SELECT * FROM TABOO_ALLERGY
  UNION
  SELECT pat_id, category_class, taboo_allergy_class, taboo_allergy_cd AS cd
  FROM PAT_INFO
  WHERE category_class IN ('1', '2', '3', '4')
)
,TABOO_ALLERGY_medicine_mix_tmp AS (
  SELECT
    tat.pat_id,
    '2' AS category_class,
    tat.taboo_allergy_class,
    mmm.medicine_mix_cd AS cd
  FROM TABOO_ALLERGY_TMP tat
  INNER JOIN mst_medicine_mix mmm
    ON mmm.mix_info @> jsonb_build_array(jsonb_build_object('cd', tat.cd))
  WHERE tat.category_class = '1'
)
,TABOO_ALLERGY_data_pat AS (
  SELECT
    pat_id,
    category_class,
    cd,
    BOOL_OR(taboo_allergy_class = '1') AS is_taboo,
    BOOL_OR(taboo_allergy_class = '2') AS is_allergy
  FROM (
    SELECT * FROM TABOO_ALLERGY_medicine_mix_tmp
    UNION
    SELECT * FROM TABOO_ALLERGY_TMP
  ) t
  GROUP BY pat_id, category_class, cd
)
,mst_enriched AS (
  SELECT
    b.ord_no,
    r.cd,
    mm.class_cd,
    (
      CASE
        WHEN COALESCE(tat.is_taboo, false) AND COALESCE(tat.is_allergy, false) THEN '【禁忌・ｱﾚﾙｷﾞｰ】'
        WHEN COALESCE(tat.is_taboo, false) THEN '【禁忌】'
        WHEN COALESCE(tat.is_allergy, false) THEN '【ｱﾚﾙｷﾞｰ】'
        ELSE ''
      END
    ) || mm.medicine_name AS name,
    mm.medicine_short_name AS short_name,
    mm.unit,
    mm.is_medicated,
    mc.class_name,
    mc.class_type,
    mt.medicate_timing_name AS timing_name,
    mp.pricedure_name AS procedure_name
  FROM raw_data r
    JOIN base_ord b ON true
    JOIN mst_medicine mm
      ON r.cd = mm.medicine_cd
      AND r.medicine_type = '1'
      AND mm.is_del = '0'
    LEFT JOIN TABOO_ALLERGY_data_pat tat
      ON tat.pat_id = b.pat_id
      AND tat.category_class = '1'
      AND tat.cd = mm.medicine_cd
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
    b.ord_no,
    r.cd,
    mmm.class_cd,
    (
      CASE
        WHEN COALESCE(tat.is_taboo, false) AND COALESCE(tat.is_allergy, false) THEN '【禁忌・ｱﾚﾙｷﾞｰ】'
        WHEN COALESCE(tat.is_taboo, false) THEN '【禁忌】'
        WHEN COALESCE(tat.is_allergy, false) THEN '【ｱﾚﾙｷﾞｰ】'
        ELSE ''
      END
    ) || mmm.medicine_mix_name AS name,
    mmm.medicine_mix_short_name AS short_name,
    mmm.unit,
    mmm.is_medicated,
    mc.class_name,
    mc.class_type,
    mt.medicate_timing_name AS timing_name,
    mp.pricedure_name AS procedure_name
  FROM raw_data r
    JOIN base_ord b ON true
    JOIN mst_medicine_mix mmm
      ON r.cd = mmm.medicine_mix_cd
      AND r.medicine_type = '2'
      AND mmm.is_del = '0'
      AND mmm.is_disp = '1'
    LEFT JOIN TABOO_ALLERGY_data_pat tat
      ON tat.pat_id = b.pat_id
      AND tat.category_class = '2'
      AND tat.cd = mmm.medicine_mix_cd
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
    r.elem ->> 'amount' as amount,
    r.is_amount_chg,
    CASE WHEN b.rst_dialysis_state <> '0'
          THEN
            jsonb_build_object(
              'class_cd', m.class_cd,
              'name', m.name,                    -- 带禁忌前缀
              'short_name', m.short_name,
              'unit', m.unit,
              'class_name', m.class_name,
              'class_type', m.class_type,
              'timing_name', m.timing_name,
              'procedure_name', m.procedure_name
            )
            || (r.elem-'effect_flg'-'effect_date'-'effect_user_id'-'effect_user_last_name'-'effect_user_first_name')
            || CASE WHEN b.rst_dialysis_state = '3' AND m.is_medicated = '1'
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
    LEFT JOIN mst_enriched m 
      ON b.ord_no = m.ord_no 
     AND r.cd = m.cd
)
,final_ord_append_data_agg as (
  SELECT
    ord_no,
    MAX(amount) AS amount,
    MAX(is_amount_chg) AS is_amount_chg,
    (jsonb_agg(final_elem)->0) AS final_elem,
    MAX(final_elem->>'ind_user_id') AS ind_user_id,
    MAX(final_elem->>'ind_user_first_name') AS ind_user_first_name,
    MAX(final_elem->>'ind_user_last_name') AS ind_user_last_name
  FROM final_ord_append_data
  GROUP BY ord_no
)
,amount_rule as (
  SELECT
    d.ord_no,
    CASE
      WHEN COALESCE(f.is_amount_chg, 'false') = 'false' THEN
        COALESCE(
          NULLIF(f.amount, ''),
          (
            SELECT e->>'amount'
            FROM jsonb_array_elements(COALESCE(d.ind_medi_info, '[]'::jsonb)) e
            WHERE e->>'no' = /*oldMediNo*/'124'
              AND e->>'is_editable' = '1'
            LIMIT 1
          ),
          (
            SELECT e->>'amount'
            FROM jsonb_array_elements(COALESCE(d.rst_medi_info, '[]'::jsonb)) e
            WHERE e->>'no' = /*oldMediNo*/'124'
            LIMIT 1
          )
        )
      ELSE
        COALESCE(
          (
            SELECT e->>'amount'
            FROM jsonb_array_elements(COALESCE(d.ind_medi_info, '[]'::jsonb)) e
            WHERE e->>'no' = /*oldMediNo*/'124'
              AND e->>'is_editable' = '1'
            LIMIT 1
          ),
          (
            SELECT e->>'amount'
            FROM jsonb_array_elements(COALESCE(d.rst_medi_info, '[]'::jsonb)) e
            WHERE e->>'no' = /*oldMediNo*/'124'
            LIMIT 1
          )
        )
    END AS resolved_amount
  FROM dual_ord d
    LEFT JOIN final_ord_append_data_agg f
      ON d.ord_no = f.ord_no
)
,upd_data as (
SELECT
  ord.ord_no,
  CASE ord.dual_flg
    WHEN 'del' THEN (
      SELECT COALESCE(jsonb_agg(elem), '[]'::jsonb)
      FROM jsonb_array_elements(ord.ind_medi_info) elem
      WHERE NOT (
        elem->>'no' = /*oldMediNo*/'124'
        AND elem->>'is_editable' = '1'
      )
    )
    WHEN 'change' THEN (
      CASE
        WHEN EXISTS (
          SELECT 1 FROM jsonb_array_elements(COALESCE(ord.ind_medi_info, '[]'::jsonb)) e
          WHERE e->>'no' = /*oldMediNo*/'124' AND e->>'is_editable' = '1'
        )
        THEN (
          SELECT jsonb_agg(CASE WHEN elem->>'no' = /*oldMediNo*/'124' AND elem->>'is_editable' = '1'
            THEN elem || jsonb_build_object(
                     'amount', COALESCE(ar.resolved_amount, elem->>'amount'),
                     'unit', COALESCE(f.final_elem->>'unit', elem->>'unit'),
                     'ind_user_id', (f.final_elem->>'ind_user_id')::numeric,
                     'ind_user_first_name', (f.final_elem->>'ind_user_first_name'),
                     'ind_user_last_name',  (f.final_elem->>'ind_user_last_name')
                   )
            ELSE elem
            END
          )
          FROM jsonb_array_elements(COALESCE(ord.ind_medi_info, '[]'::jsonb)) elem
        )
        WHEN EXISTS (
          SELECT 1 FROM jsonb_array_elements(COALESCE(ord.rst_medi_info, '[]'::jsonb)) e
          WHERE e->>'no' = /*oldMediNo*/'124'
        )
        THEN (
          (SELECT COALESCE(jsonb_agg(elem), '[]'::jsonb)
           FROM jsonb_array_elements(COALESCE(ord.ind_medi_info, '[]'::jsonb)) elem)
          || jsonb_agg(
            f.final_elem
            - 'effect_flg'
            - 'effect_date'
            - 'effect_user_id'
            - 'effect_user_last_name'
            - 'effect_user_first_name'
          )
        )
        ELSE (
          SELECT COALESCE(jsonb_agg(elem), '[]'::jsonb)
          FROM jsonb_array_elements(COALESCE(ord.ind_medi_info, '[]'::jsonb)) elem
        )
      END
    )
    WHEN 'del-add' THEN (
      CASE
        WHEN exists (
          select 1
          from jsonb_array_elements(ord.ind_medi_info) e
          where e->>'no' = /*oldMediNo*/'124'
            and e->>'is_editable' = '1'
        )
        THEN
          (
            (
              select coalesce(jsonb_agg(elem), '[]'::jsonb)
              from jsonb_array_elements(ord.ind_medi_info) elem
              where not (
                elem->>'no' = /*oldMediNo*/'124'
                and elem->>'is_editable' = '1'
              )
            )
            || jsonb_agg(
              jsonb_set(
                f.final_elem,
                '{amount}',
                to_jsonb(COALESCE(ar.resolved_amount, f.final_elem->>'amount'))
              )
              - 'effect_flg'
              - 'effect_date'
              - 'effect_user_id'
              - 'effect_user_last_name'
              - 'effect_user_first_name'
            )
          )
        ELSE
          coalesce(ord.ind_medi_info, '[]'::jsonb)
            || jsonb_agg(
              jsonb_set(
                f.final_elem,
                '{amount}',
                to_jsonb(COALESCE(ar.resolved_amount, f.final_elem->>'amount'))
              )
              - 'effect_flg'
              - 'effect_date'
              - 'effect_user_id'
              - 'effect_user_last_name'
              - 'effect_user_first_name'
            )
      END
    )
    END AS new_ind_medi_info,
  CASE WHEN ord.rst_dialysis_state <> '0' AND /*isRstUpdate*/'false' = 'true' THEN
    CASE ord.dual_flg
      WHEN 'del' THEN (
        SELECT COALESCE(jsonb_agg(elem), '[]'::jsonb)
        FROM jsonb_array_elements(ord.rst_medi_info) elem
        WHERE elem->>'no' <> /*oldMediNo*/'124'
      )
      WHEN 'change' THEN (
        CASE
          WHEN EXISTS (
            SELECT 1 FROM jsonb_array_elements(COALESCE(ord.rst_medi_info, '[]'::jsonb)) e
            WHERE e->>'no' = /*oldMediNo*/'124'
          )
          THEN (
            SELECT jsonb_agg(CASE WHEN elem->>'no' = /*oldMediNo*/'124'
              THEN jsonb_set(
                jsonb_set(
                  elem,
                  '{amount}',
                  to_jsonb(
                    COALESCE(ar.resolved_amount, elem->>'amount')
                  )
                ),
                '{unit}',
                to_jsonb(
                  COALESCE(f.final_elem->>'unit', elem->>'unit')
                )
              )
              ELSE elem
              END
              )
            FROM jsonb_array_elements(COALESCE(ord.rst_medi_info, '[]'::jsonb)) elem
          )
          WHEN EXISTS (
            SELECT 1 FROM jsonb_array_elements(COALESCE(ord.ind_medi_info, '[]'::jsonb)) e
            WHERE e->>'no' = /*oldMediNo*/'124' AND e->>'is_editable' = '1'
          )
          THEN (
            (SELECT COALESCE(jsonb_agg(elem), '[]'::jsonb)
             FROM jsonb_array_elements(COALESCE(ord.rst_medi_info, '[]'::jsonb)) elem)
            || jsonb_agg(f.final_elem)
          )
          ELSE (
            SELECT COALESCE(jsonb_agg(elem), '[]'::jsonb)
            FROM jsonb_array_elements(COALESCE(ord.rst_medi_info, '[]'::jsonb)) elem
          )
        END
      )
      WHEN 'del-add' THEN (
        (
          SELECT COALESCE(jsonb_agg(elem), '[]'::jsonb)
          FROM jsonb_array_elements(ord.rst_medi_info) elem
          WHERE elem->>'no' <> /*oldMediNo*/'124'
        ) || jsonb_agg(
          jsonb_set(
            f.final_elem,
            '{amount}',
            to_jsonb(COALESCE(ar.resolved_amount, f.final_elem->>'amount'))
          )
        )
      )
      END
    ELSE ord.rst_medi_info
   END AS new_rst_medi_info
FROM dual_ord ord
  LEFT JOIN final_ord_append_data_agg f
    ON ord.ord_no = f.ord_no
  LEFT JOIN amount_rule ar
    ON ord.ord_no = ar.ord_no
GROUP BY
  ord.ord_no, ord.ind_medi_info, ord.rst_medi_info, ord.rst_dialysis_state, ord.dual_flg,
  f.final_elem, ar.resolved_amount
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

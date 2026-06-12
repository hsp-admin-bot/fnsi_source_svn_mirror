WITH raw_data AS (
  SELECT
    elem ->> 'equip_type' AS equip_type
    ,(elem ->>'cd')::numeric AS cd
    ,elem - 'class_cd' - 'class_name' - 'class_type' - 'name' - 'short_name' - 'needle_type' AS elem
  FROM jsonb_array_elements(/*changeEquipInfo*/'[{"cd":93,"auto_insert":"0","upd_user_first_name":"KM","amount":"2","upd_user_id":12397,"ind_user_first_name":"KM","cop_order_no":null,"input_class":1,"is_editable":"1","upd_user_last_name":"Z","ind_user_id":12397,"ind_user_last_name":"Z","equip_type":0}]'::jsonb) AS t(elem)
)
,base_ord AS (
  SELECT
    ord_no
    ,pat_id
    ,ind_equip_info
    ,rst_equip_info
    ,rst_dialysis_state
  FROM ord_main
  WHERE ord_no in /*ordNoList*/(11346460)
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
,TABOO_ALLERGY_data_pat AS (
  SELECT
    pat_id,
    category_class,
    cd,
    BOOL_OR(taboo_allergy_class = '1') AS is_taboo,
    BOOL_OR(taboo_allergy_class = '2') AS is_allergy
  FROM TABOO_ALLERGY_TMP t
  GROUP BY pat_id, category_class, cd
)
,mst_enriched AS (
  SELECT
    b.ord_no,
    r.cd,
    r.equip_type,
    me.class_cd,
    (
      CASE
        WHEN COALESCE(tat.is_taboo, false) AND COALESCE(tat.is_allergy, false) THEN '【禁忌・ｱﾚﾙｷﾞｰ】'
        WHEN COALESCE(tat.is_taboo, false) THEN '【禁忌】'
        WHEN COALESCE(tat.is_allergy, false) THEN '【ｱﾚﾙｷﾞｰ】'
        ELSE ''
      END
    ) || me.equipment_name AS name,
    me.equipment_short_name AS short_name,
    me.unit,
    mc.class_name,
    mc.class_type
  FROM raw_data r
  INNER JOIN base_ord b ON TRUE
  INNER JOIN mst_equipment me
    ON r.cd = me.equipment_cd
    AND r.equip_type = '0'
    AND me.is_del = '0'
  LEFT JOIN TABOO_ALLERGY_data_pat tat
    ON tat.pat_id = b.pat_id
    AND tat.category_class = '3'
    AND tat.cd = me.equipment_cd
  LEFT JOIN mst_equipment_class mc
    ON me.class_cd IS NOT NULL
    AND mc.class_cd = me.class_cd
    AND mc.is_del = '0'
  UNION ALL
  SELECT
    b.ord_no,
    r.cd,
    r.equip_type,
    null AS class_cd,
    (
      CASE
        WHEN COALESCE(tat.is_taboo, false) AND COALESCE(tat.is_allergy, false) THEN '【禁忌・ｱﾚﾙｷﾞｰ】'
        WHEN COALESCE(tat.is_taboo, false) THEN '【禁忌】'
        WHEN COALESCE(tat.is_allergy, false) THEN '【ｱﾚﾙｷﾞｰ】'
        ELSE ''
      END
    ) || md.model_number AS name,
    md.model_number AS short_name,
    '本' AS unit,
    null AS class_name,
    null AS class_type
  FROM raw_data r
  INNER JOIN base_ord b ON TRUE
  INNER JOIN mst_dialyzer md
    ON r.cd = md.dialyzer_cd
    AND r.equip_type = '1'
    AND md.is_del = '0'
  LEFT JOIN TABOO_ALLERGY_data_pat tat
    ON tat.pat_id = b.pat_id
    AND tat.category_class = '4'
    AND tat.cd = md.dialyzer_cd
)
,all_old AS (
  SELECT
    bo.ord_no,
    'ind' AS src,
    item
  FROM base_ord bo
    LEFT JOIN LATERAL jsonb_array_elements(bo.ind_equip_info) item ON TRUE
  UNION ALL
  SELECT
    bo.ord_no,
    'rst' AS src,
    item
  FROM base_ord bo
    LEFT JOIN LATERAL jsonb_array_elements(bo.rst_equip_info) item ON TRUE
  WHERE bo.rst_dialysis_state <> '0'
)
,old_map AS (
  SELECT
    ord_no
    ,src
    ,jsonb_object_agg((item->>'cd') || '_' || (item->>'equip_type'), item) AS map
  FROM all_old
  WHERE ITEM IS NOT NULL
  GROUP BY ord_no, src
)
,filtered_old AS (
  SELECT
    ord_no
    ,src
    ,CASE
      WHEN /*dualType*/'del_add' = 'del_add'
        AND EXISTS (SELECT 1 FROM raw_data r WHERE r.elem ?? 'amount')
        THEN (
          case when EXISTS (SELECT 1 FROM raw_data r WHERE r.elem->>'auto_insert' = '1') then
              (
                SELECT jsonb_object_agg(key, value)
                FROM jsonb_each(om.map)
                WHERE NOT (
                    EXISTS (SELECT 1 FROM jsonb_each(om.map) e2(k2,v2) WHERE k2 = /*updOldKey*/'93_0')
                    AND EXISTS (
                      SELECT 1 FROM raw_data r
                      WHERE (r.cd::text || '_' || r.equip_type::text) = (value->>'cd') || '_' || (value->>'equip_type')
                    )
                  )
              )
              else (
                SELECT jsonb_object_agg(key, value)
                FROM jsonb_each(om.map)
                WHERE key NOT IN (SELECT r_key FROM (SELECT r.cd::text || '_' || r.equip_type::text AS r_key FROM raw_data r) t)
              ) end
          )
      WHEN /*dualType*/'add' = 'del'
      THEN (
        SELECT jsonb_object_agg(key, value)
        FROM jsonb_each(om.map)
        WHERE key <> /*updOldKey*/'93_0'::text
      ) ELSE om.map
      END AS map
  FROM old_map om
)
,raw_with_mst AS (
  SELECT
    b.ord_no,
    r.*,
    m.class_cd,
    m.name,
    m.short_name,
    m.unit,
    m.class_name,
    m.class_type
  FROM base_ord b
    CROSS JOIN raw_data r
    LEFT JOIN mst_enriched m
      ON m.ord_no = b.ord_no
      AND m.cd = r.cd
      AND m.equip_type = r.equip_type
)
,old_amount AS (
  SELECT
    o.ord_no,
    o.src,
    e.key,
    CASE WHEN /*isRstUpdate*/'false' = 'true' AND o.src = 'rst' AND ei.value IS NOT NULL
      THEN (ei.value->>'amount')::numeric ELSE (e.value->>'amount')::numeric
      END AS amount
  FROM old_map o
    CROSS JOIN LATERAL jsonb_each(o.map) AS e(key, value)
    LEFT JOIN old_map oi
      ON oi.ord_no = o.ord_no AND oi.src = 'ind'
    LEFT JOIN LATERAL jsonb_each(oi.map) AS ei(key, value)
      ON ei.key = e.key
  WHERE e.key = /*updOldKey*/'93_0' or /*dualType*/'add' = 'add'
)
,final_ord_append_data AS (
  SELECT
    b.ord_no,
    src_pick.src AS src,
    CASE WHEN b.rst_dialysis_state <> '0'
      THEN jsonb_build_object(
          'class_cd', m.class_cd,
          'name', m.name,
          'short_name', m.short_name,
          'unit', m.unit,
          'class_name', m.class_name,
          'class_type', m.class_type
        ) ELSE '{}'::jsonb END
    || jsonb_set(
      CASE WHEN m.elem ?? 'amount' THEN m.elem
        ELSE
          jsonb_set(
              m.elem,
              '{amount}', to_jsonb(COALESCE(
                    CASE WHEN /*dualType*/'add' NOT IN ('add', 'del')
                        AND m.elem->>'auto_insert' = '0'
                        AND oa.ord_no IS NULL THEN /*autoInsertAmount*/'7'
                      ELSE oa.amount::text end
                  ,'0'))
            )
        END,
      '{no}',
      COALESCE(
        (
          SELECT NULLIF(ov.value -> 'no', 'null'::jsonb)
          FROM old_map oi
            CROSS JOIN LATERAL jsonb_each(oi.map) AS ov(key, value)
          WHERE oi.ord_no = b.ord_no
            AND oi.src = src_pick.src
            AND ov.key = (m.elem ->> 'cd') || '_' || (m.elem ->> 'equip_type')
          LIMIT 1
        ),
        m.elem -> 'no',
        'null'::jsonb
      )
    ) AS final_elem
  FROM base_ord b
    JOIN raw_with_mst m
      ON m.ord_no = b.ord_no
    LEFT JOIN old_amount oa on b.ord_no = oa.ord_no
    CROSS JOIN LATERAL (
      SELECT unnest(
        CASE
          WHEN /*isRstUpdate*/'false' = 'true'
            AND (
              (
                EXISTS (
                  SELECT 1 FROM old_map omr
                  WHERE omr.ord_no = b.ord_no AND omr.src = 'rst'
                    AND jsonb_exists(omr.map, /*updOldKey*/'93_0')
                )
                AND NOT EXISTS (
                  SELECT 1 FROM old_map omi
                  WHERE omi.ord_no = b.ord_no AND omi.src = 'ind'
                    AND jsonb_exists(omi.map, /*updOldKey*/'93_0')
                )
              )
              OR
              (
                EXISTS (
                  SELECT 1 FROM old_map omi
                  WHERE omi.ord_no = b.ord_no AND omi.src = 'ind'
                    AND jsonb_exists(omi.map, /*updOldKey*/'93_0')
                )
                AND NOT EXISTS (
                  SELECT 1 FROM old_map omr
                  WHERE omr.ord_no = b.ord_no AND omr.src = 'rst'
                    AND jsonb_exists(omr.map, /*updOldKey*/'93_0')
                )
              )
              OR
              (
                NOT EXISTS (
                  SELECT 1 FROM old_map omi
                  WHERE omi.ord_no = b.ord_no AND omi.src = 'ind'
                    AND jsonb_exists(omi.map, /*updOldKey*/'93_0')
                )
                AND NOT EXISTS (
                  SELECT 1 FROM old_map omr
                  WHERE omr.ord_no = b.ord_no AND omr.src = 'rst'
                    AND jsonb_exists(omr.map, /*updOldKey*/'93_0')
                )
              )
            )
          THEN ARRAY['ind', 'rst']::text[]
          ELSE ARRAY[
            CASE
              WHEN /*isRstUpdate*/'false' <> 'true' AND oa.src = 'rst' THEN 'ind'
              ELSE COALESCE(oa.src, 'ind')
            END
          ]::text[]
        END
      ) AS src
    ) AS src_pick(src)
)
,new_map AS (
  SELECT
    ord_no
    ,src
    ,CASE WHEN /*dualType*/'add' = 'del' THEN '{}'::jsonb
      ELSE jsonb_object_agg((final_elem->>'cd') || '_' || (final_elem->>'equip_type'), final_elem) END AS map
  FROM (
      SELECT ord_no, src, final_elem FROM final_ord_append_data where /*dualType*/'add' = 'add'
      UNION ALL
      SELECT f.ord_no, 'rst' AS src, f.final_elem
      FROM final_ord_append_data f
      WHERE /*dualType*/'add' = 'add'
        AND /*isRstUpdate*/'true' = 'true'
        AND NOT EXISTS (
          SELECT 1 FROM final_ord_append_data f2
          WHERE f2.ord_no = f.ord_no
            AND f2.src = 'rst'
            AND (f2.final_elem->>'cd') = (f.final_elem->>'cd')
            AND (f2.final_elem->>'equip_type') = (f.final_elem->>'equip_type')
        )
      UNION ALL
      select * from final_ord_append_data where /*dualType*/'add' <> 'add'
    ) t
  GROUP BY ord_no, src
)
,o_expanded AS (
  SELECT
    o.ord_no,
    o.src,
    e.key,
    e.value
  FROM filtered_old o
  LEFT JOIN LATERAL jsonb_each(COALESCE(o.map, '{}'::jsonb)) e ON TRUE
)
,n_expanded AS (
  SELECT
    n.ord_no,
    n.src,
--     CASE WHEN /*dualType*/'upd' in ('upd', 'del_add') and n.src = 'ind' THEN /*updOldKey*/'36268_0' ELSE e.key END AS key,
    CASE WHEN /*dualType*/'upd' in ('upd', 'del_add') THEN /*updOldKey*/'93_0' ELSE e.key END AS key,
    e.value
  FROM new_map n
  LEFT JOIN LATERAL jsonb_each(COALESCE(n.map, '{}'::jsonb)) e ON TRUE
)
,merged AS (
  SELECT
    COALESCE(o.ord_no, n.ord_no) AS ord_no
    ,COALESCE(o.src, n.src) AS src
    ,COALESCE(o.key, n.key) AS key
    ,CASE WHEN n.value->>'auto_insert' = '0'
      THEN (
        CASE
          WHEN o.value IS NULL AND n.value IS NOT NULL
            THEN (CASE WHEN /*dualType*/'del_add' in ('add', 'upd', 'del_add') THEN n.value ELSE o.value END)
          WHEN o.value IS NOT NULL AND n.value IS NULL THEN o.value
          ELSE (
            CASE WHEN /*dualType*/'del_add' in ('upd','del_add') THEN n.value
              WHEN /*dualType*/'del_add' = 'add'
                THEN jsonb_set(
                  o.value,
                  '{amount}',  to_jsonb((o.value->>'amount')::numeric + (n.value->>'amount')::numeric)
                )
              ELSE o.value END)
          END
      )
      ELSE (
        CASE
          WHEN o.value IS NULL AND n.value IS NOT NULL
            THEN (
              CASE
                WHEN /*dualType*/'del_add' in ('upd', 'del_add')
                  THEN (
                    CASE
                      -- isRstUpdate=true かつ rst 側に新規要素がある場合は rst へ反映する
                      WHEN n.src = 'rst'
                        AND /*isRstUpdate*/'false' = 'true'
                        THEN n.value
                      -- ind に無く rst にある医材は auto_insert に関係なく ind 側へ更新
                      WHEN n.src = 'ind'
                        AND EXISTS (
                          SELECT 1 FROM old_map omr
                          WHERE omr.ord_no = COALESCE(o.ord_no, n.ord_no) AND omr.src = 'rst'
                            AND jsonb_exists(omr.map, /*updOldKey*/'93_0')
                        )
                        AND NOT EXISTS (
                          SELECT 1 FROM old_map omi
                          WHERE omi.ord_no = COALESCE(o.ord_no, n.ord_no) AND omi.src = 'ind'
                            AND jsonb_exists(omi.map, /*updOldKey*/'93_0')
                        )
                        THEN n.value
                      ELSE NULL
                    END
                  )
                ELSE n.value
              END
            )
          WHEN o.value IS NOT NULL AND n.value IS NULL THEN o.value
          ELSE (CASE WHEN /*dualType*/'del_add' in ('upd', 'del_add') THEN n.value ELSE o.value END)
        END
      )
    END AS value
  FROM o_expanded o
    FULL JOIN n_expanded n ON o.ord_no = n.ord_no AND o.key = n.key AND o.src = n.src
    JOIN base_ord b ON COALESCE(o.ord_no, n.ord_no) = b.ord_no
  WHERE
    COALESCE(jsonb_array_length(b.ind_equip_info),0) > 0
    OR EXISTS (
      SELECT 1
      FROM old_map omr
      WHERE omr.ord_no = b.ord_no
        AND omr.src = 'rst'
        AND jsonb_exists(omr.map, /*updOldKey*/'93_0')
    )
)
,merged_group AS (
  SELECT
    ord_no,
    src,
    (value->>'cd') AS cd,
    (value->>'equip_type') AS equip_type,
    SUM(COALESCE((value->>'amount')::numeric,0)) AS total_amount
  FROM merged WHERE value IS NOT NULL
  GROUP BY ord_no, src, (value->>'cd'), (value->>'equip_type')
)
,new_base_value AS (
  SELECT DISTINCT ON (m.ord_no, m.src, m.cd, m.equip_type)
    m.ord_no,
    m.src,
    m.cd,
    m.equip_type,
    (mm.value - 'amount') AS base_value
  FROM merged_group m
    JOIN merged mm
      ON mm.ord_no = m.ord_no
        AND mm.src = m.src
        AND (mm.value->>'cd') = m.cd
        AND (mm.value->>'equip_type') = m.equip_type
  WHERE mm.value IS NOT NULL
  ORDER BY m.ord_no, m.src, m.cd, m.equip_type, CASE WHEN mm.value->>'auto_insert' = '0' THEN 0 ELSE 1 END
)
,final_map AS (
  SELECT
    g.ord_no,
    g.src,
    jsonb_object_agg(
      g.cd || '_' || g.equip_type,
      COALESCE(b.base_value, '{}'::jsonb) || jsonb_build_object('amount', g.total_amount::text)
    ) AS final_map
  FROM merged_group g
    LEFT JOIN new_base_value b
      ON b.ord_no = g.ord_no
        AND b.src = g.src
        AND b.cd = g.cd
        AND b.equip_type = g.equip_type
  GROUP BY g.ord_no, g.src
  UNION ALL
  SELECT
    n.ord_no,
    n.src,
    CASE
      WHEN /*dualType*/'del_add' = 'upd' THEN (
        SELECT COALESCE(jsonb_object_agg(e.key, e.value), '{}'::jsonb)
        FROM jsonb_each(n.map) AS e(key, value)
        WHERE e.value->>'auto_insert' = '0'
      )
      ELSE n.map
    END AS final_map
  FROM new_map n
    JOIN base_ord b USING (ord_no)
  WHERE (
      /*dualType*/'del_add' = 'add'
      OR (
        /*dualType*/'del_add' IN ('upd', 'del_add')
        AND EXISTS (
          SELECT 1
          FROM jsonb_each(n.map) AS e(key, value)
          WHERE e.value->>'auto_insert' = '0'
        )
      )
    )
    AND (b.ind_equip_info IS NULL OR b.ind_equip_info = '[]'::jsonb)
)
,upd_data AS (
  SELECT
    b.ord_no,
    (
      SELECT COALESCE(jsonb_agg(value - 'auto_insert'),'[]'::jsonb)
      FROM final_map m CROSS JOIN LATERAL jsonb_each(m.final_map)
      WHERE m.ord_no = b.ord_no AND m.src = 'ind'
    ) AS new_ind_equip_info,
    (
      SELECT COALESCE(jsonb_agg(value
        -'auto_insert'
        -'ind_user_id'
        -'upd_user_id'
        -'upd_user_first_name'
        -'ind_user_first_name'
        -'upd_user_last_name'
        -'ind_user_last_name'),'[]'::jsonb)
      FROM final_map m CROSS JOIN LATERAL jsonb_each(m.final_map)
      WHERE m.ord_no = b.ord_no AND m.src = 'rst'
    ) AS new_rst_equip_info
  FROM base_ord b
)
update ord_main
set
  ind_equip_info = ud.new_ind_equip_info,
  up_ind_user_id = /*upIndUserId*/null,
  up_user_id = /*upUserId*/null,
  /*%if "true" == isRstUpdate*/
  rst_equip_info = ud.new_rst_equip_info,
  is_confirm = CASE WHEN rst_dialysis_state = '6' THEN '0' ELSE is_confirm end,
  /*%end*/
  up_date = CURRENT_TIMESTAMP
  FROM upd_data ud
where
  ord_main.ord_no = ud.ord_no
  AND ord_main.ord_no in /*ordNoList*/(10768848)
  RETURNING ord_main.*

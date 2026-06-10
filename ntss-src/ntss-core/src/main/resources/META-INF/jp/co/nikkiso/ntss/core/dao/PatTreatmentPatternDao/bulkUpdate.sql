WITH base_ord as (
  SELECT
    pat_id
    ,ctl_no
    ,treat_week
    ,ind_sch_info
    ,ind_cond_info
    ,ind_medi_info
    ,ind_equip_info
    ,ind_ind_comment_info
    ,ind_device_set_info
  FROM pat_treatment_pattern
  WHERE
    facility_cd = /*facilityCd*/'NKKSBR'
    AND pat_id = /*patId*/'44683'
    /*%if 0 != weeks.get(0)*/
    AND treat_week in /*weeks*/(0)
    /*%end*/
    /*%if 0 != treats.size()*/
    AND ind_treatment_cd in /*treats*/(0)
    /*%end*/
    /*%if 0 != kurs.size()*/
    AND ind_kur_cd in /*kurs*/(0)
  /*%end*/
)
,raw_medi_data as (
  SELECT
    patch->>'is_medi_change' AS is_medi_change,
    patch->>'is_medi_stop' AS is_medi_stop,
    patch->>'old_medi_no' AS old_medi_no,
    patch->>'medi_week' AS medi_week,
    patch->>'is_edit_other_amount' AS is_edit_other_amount,
    (
      CASE WHEN ind_medi_info ?? 'amount'
        THEN jsonb_set(ind_medi_info, '{amount}', to_jsonb(ind_medi_info->>'amount'))
        ELSE ind_medi_info
       END
        - 'isAmountchg'
        - 'class_cd'
        - 'class_name'
        - 'class_type'
        - 'name'
        - 'short_name'
        - 'unit'
        - 'timing_name'
        - 'procedure_name'
    ) AS ind_medi_info
FROM (
  SELECT
    patch,
    (patch->>'ind_medi_info')::jsonb AS ind_medi_info
  FROM (
    SELECT /*dto.patchJson*/'{"old_medi_no":"152",
      "ind_medi_info":"{\"medicine_type\":1,\"no\":152,\"amount\":\"6\",\"isAmountchg\":false,\"class_cd\":1}",
      "is_medi_stop":"false",
      "is_medi_change":"true",
      "medi_week":"1,3,5",
      "is_edit_other_amount":"false"}'::jsonb AS patch
    ) t
  ) s
WHERE patch ?? 'ind_medi_info'
)
,medi_data as (
  select
    pat_id
    ,ctl_no
    ,old_medi_no
    ,bo.ind_medi_info
    ,rmd.ind_medi_info as edit_ind_medi_info
    ,CASE WHEN rmd.is_medi_change = 'true' THEN
        CASE WHEN rmd.is_medi_stop = 'true' THEN 'stop'
          WHEN rmd.is_edit_other_amount = 'false' THEN 'change'
          WHEN rmd.is_edit_other_amount = 'true' AND bo.treat_week = ANY (string_to_array(rmd.medi_week, ',')::int[]) THEN 'del-add'
          ELSE 'del' END
      ELSE '' END AS dual_flg
  from base_ord bo
    LEFT JOIN raw_medi_data rmd ON 1 = 1
  where rmd.is_medi_change = 'true'
)
,medi_upd_data as (
  SELECT
    md.pat_id,
    md.ctl_no,
    j.new_ind_medi_info
  FROM medi_data md
    LEFT JOIN LATERAL (
      SELECT
        CASE md.dual_flg WHEN 'stop' THEN
          COALESCE(
            jsonb_agg(elem) FILTER (
              WHERE NOT (
                elem->>'cd' = md.edit_ind_medi_info->>'cd'
                AND elem->>'medicine_type' = md.edit_ind_medi_info->>'medicine_type'
              )
            ), '[]'::jsonb
          )
        WHEN 'del' THEN
          COALESCE(
            jsonb_agg(elem) FILTER (
              WHERE NOT (
                elem->>'no' = md.old_medi_no
                AND elem->>'is_editable' = '1'
              )
            ), '[]'::jsonb
          )
        WHEN 'change' THEN
          jsonb_agg(
            CASE WHEN elem->>'no' = md.old_medi_no AND elem->>'is_editable' = '1'
              THEN elem || jsonb_build_object(
                  'amount', md.edit_ind_medi_info->>'amount',
                  'ind_user_id', (md.edit_ind_medi_info->>'ind_user_id')::numeric,
                  'ind_user_first_name', md.edit_ind_medi_info->>'ind_user_first_name',
                  'ind_user_last_name',  md.edit_ind_medi_info->>'ind_user_last_name'
                  )
              ELSE elem
            END
          )
        WHEN 'del-add' THEN
          CASE WHEN EXISTS (
            SELECT 1 FROM jsonb_array_elements(md.ind_medi_info) e
            WHERE e->>'no' = md.old_medi_no
              AND e->>'is_editable' = '1'
            )
            THEN (
              COALESCE(
                jsonb_agg(elem) FILTER (
                  WHERE NOT (
                    elem->>'no' = md.old_medi_no
                    AND elem->>'is_editable' = '1'
                  )
                ),
              '[]'::jsonb
              ) || jsonb_build_array(md.edit_ind_medi_info)
            )
          ELSE COALESCE(md.ind_medi_info, '[]'::jsonb) || jsonb_build_array(md.edit_ind_medi_info) END
        END AS new_ind_medi_info
      FROM jsonb_array_elements(md.ind_medi_info) elem
    ) j ON TRUE
)
,raw_equip_data as (
  SELECT
    patch->>'dual_type' AS dual_type,
    patch->>'upd_old_key' AS upd_old_key,
    patch->>'auto_insert_amount' AS auto_insert_amount,
    (
    CASE WHEN elem ?? 'amount'
    THEN jsonb_set(elem, '{amount}', to_jsonb(elem->>'amount'))
    ELSE elem
    END
    - 'class_cd'
    - 'class_name'
    - 'class_type'
    - 'name'
    - 'short_name'
    - 'unit'
    - 'needle_type'
    )::jsonb AS ind_equip_info
  FROM (
    SELECT
    patch,
    jsonb_array_elements((patch->>'ind_equip_info')::jsonb) elem
    FROM (
    SELECT /*dto.patchJson*/'{"dual_type":"add", "upd_old_key": "", "ind_equip_info":"[{\"cd\":414,\"amount\":\"3\",\"ind_user_first_name\":\"KM\",\"input_class\":1,\"is_editable\":\"1\",\"ind_user_id\":12397,\"upd_user_first_name\":\"KM\",\"upd_user_id\":12397,\"auto_insert\":\"0\",\"cop_order_no\":null,\"upd_user_last_name\":\"Z\",\"ind_user_last_name\":\"Z\",\"equip_type\":0}]"}'::jsonb AS patch
    ) t
    ) s
  WHERE patch ?? 'ind_equip_info'
)
,old_equip as (
  SELECT
    pat_id
    ,ctl_no
    ,jsonb_object_agg((item->>'cd') || '_' || (item->>'equip_type'), item) AS map
  FROM (
    SELECT
    bo.pat_id,
    bo.ctl_no,
    item
    FROM base_ord bo
    LEFT JOIN LATERAL jsonb_array_elements(bo.ind_equip_info) item ON TRUE
    ) t
  WHERE item IS NOT NULL
  GROUP BY pat_id, ctl_no
)
,filtered_old AS (
SELECT
  pat_id
  ,ctl_no
  ,CASE
      WHEN red.dual_type = 'del_add'
        AND EXISTS (SELECT 1 FROM raw_equip_data r WHERE r.ind_equip_info ?? 'amount')
        THEN (
          case when EXISTS (SELECT 1 FROM raw_equip_data r WHERE r.ind_equip_info->>'auto_insert' = '1') then
              (
                SELECT jsonb_object_agg(key, value)
                FROM jsonb_each(om.map)
                WHERE NOT (
                    EXISTS (SELECT 1 FROM jsonb_each(om.map) e2(k2,v2) WHERE k2 = red.upd_old_key)
                    AND EXISTS (
                      SELECT 1 FROM raw_equip_data r
                      WHERE r.ind_equip_info->>'cd' = value->>'cd' and r.ind_equip_info->>'equip_type' = value->>'equip_type'
                    )
                  )
              )
              else (
                SELECT jsonb_object_agg(key, value)
                FROM jsonb_each(om.map)
                WHERE key NOT IN (SELECT r_key FROM (SELECT (r.ind_equip_info->>'cd')::text || '_' || (r.ind_equip_info->>'equip_type')::text AS r_key FROM raw_equip_data r) t)
              ) end
          )
  WHEN red.dual_type = 'del'
  THEN (
  SELECT jsonb_object_agg(key, value)
  FROM jsonb_each(om.map)
  WHERE key <> red.upd_old_key
  ) ELSE om.map
  END AS map
FROM old_equip om
  left join raw_equip_data red on true
)
,old_amount AS (
  SELECT
    pat_id
    ,ctl_no
    ,e.key
    ,(e.value->>'amount')::numeric AS amount
  FROM old_equip o
    CROSS JOIN LATERAL jsonb_each(o.map) AS e(key, value)
    inner join raw_equip_data red on red.upd_old_key = e.key
)
,final_ord_append_data AS (
  SELECT
    b.pat_id
    ,b.ctl_no
    ,r.dual_type
    ,r.upd_old_key
    ,CASE WHEN r.ind_equip_info ?? 'amount' THEN r.ind_equip_info
      ELSE
        jsonb_set(
            r.ind_equip_info,
            '{amount}', to_jsonb(COALESCE(
                CASE WHEN r.dual_type NOT IN ('add', 'del')
                    AND r.ind_equip_info->>'auto_insert' = '0'
                    AND oa.pat_id IS NULL THEN r.auto_insert_amount::text
                  ELSE oa.amount::text END
              ,'0'))
          ) END AS final_elem
  FROM raw_equip_data r
    JOIN base_ord b ON true
    LEFT JOIN old_amount oa ON b.pat_id = oa.pat_id and b.ctl_no = oa.ctl_no
)
,new_map AS (
  SELECT
    pat_id
    ,ctl_no
    ,dual_type
    ,upd_old_key
    ,CASE WHEN dual_type = 'del' THEN '{}'::jsonb
    ELSE jsonb_object_agg((final_elem->>'cd') || '_' || (final_elem->>'equip_type'), final_elem) END AS map
  FROM final_ord_append_data
  GROUP BY pat_id, ctl_no, dual_type, upd_old_key
)
,o_expanded AS (
  SELECT distinct
    o.pat_id,
    o.ctl_no,
    e.key,
    e.value
  FROM filtered_old o
    LEFT JOIN LATERAL jsonb_each(COALESCE(o.map, '{}'::jsonb)) e ON TRUE
)
,n_expanded AS (
  SELECT distinct
    n.pat_id,
    n.ctl_no,
    n.dual_type,
    n.upd_old_key,
    CASE WHEN dual_type in ('upd', 'del_add') THEN upd_old_key ELSE e.key END AS key,
    e.value
  FROM new_map n
    LEFT JOIN LATERAL jsonb_each(COALESCE(n.map, '{}'::jsonb)) e ON TRUE
)
,merged AS (
  SELECT
    COALESCE(o.pat_id, n.pat_id) AS pat_id
    ,COALESCE(o.ctl_no, n.ctl_no) AS ctl_no
    ,COALESCE(o.key, n.key) AS key
    ,CASE WHEN n.value->>'auto_insert' = '0'
      THEN (
        CASE
          WHEN o.value IS NULL AND n.value IS NOT NULL
            THEN (CASE WHEN dual_type in ('add', 'upd', 'del_add') THEN n.value ELSE o.value END)
          WHEN o.value IS NOT NULL AND n.value IS NULL THEN o.value
          ELSE (
            CASE WHEN dual_type in ('upd','del_add') THEN n.value
              WHEN dual_type = 'add'
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
          THEN (CASE WHEN dual_type in ('upd', 'del_add') THEN o.value ELSE n.value END)
        WHEN o.value IS NOT NULL AND n.value IS NULL THEN o.value
        ELSE (CASE WHEN dual_type in ('upd', 'del_add') THEN n.value ELSE o.value END)
      END
    )
    END AS value
  FROM o_expanded o
    FULL JOIN n_expanded n ON o.pat_id = n.pat_id AND o.ctl_no = n.ctl_no AND o.key = n.key
    JOIN base_ord b ON COALESCE(o.pat_id, n.pat_id) = b.pat_id and COALESCE(o.ctl_no, n.ctl_no) = b.ctl_no
  WHERE COALESCE(jsonb_array_length(b.ind_equip_info),0) > 0
)
,merged_group AS (
  SELECT
    pat_id,
    ctl_no,
    (value->>'cd') AS cd,
    (value->>'equip_type') AS equip_type,
    SUM(COALESCE((value->>'amount')::numeric,0)) AS total_amount
  FROM merged WHERE value IS NOT NULL
  GROUP BY pat_id, ctl_no, (value->>'cd'), (value->>'equip_type')
)
,new_base_value AS (
  SELECT DISTINCT ON (m.pat_id, m.ctl_no, m.cd, m.equip_type)
    m.pat_id,
    m.ctl_no,
    m.cd,
    m.equip_type,
    (mm.value - 'amount') AS base_value
  FROM merged_group m
    JOIN merged mm
      ON mm.pat_id = m.pat_id
        and mm.ctl_no = m.ctl_no
        AND (mm.value->>'cd') = m.cd
        AND (mm.value->>'equip_type') = m.equip_type
  WHERE mm.value IS NOT NULL
  ORDER BY m.pat_id, m.ctl_no, m.cd, m.equip_type, CASE WHEN mm.value->>'auto_insert' = '0' THEN 0 ELSE 1 END
)
,final_map AS (
  SELECT
    g.pat_id,
    g.ctl_no,
    jsonb_object_agg(
    g.cd || '_' || g.equip_type,
    COALESCE(b.base_value, '{}'::jsonb) || jsonb_build_object('amount', g.total_amount::text)
    ) AS final_map
  FROM merged_group g
    LEFT JOIN new_base_value b
      ON b.pat_id = g.pat_id
        AND b.ctl_no = g.ctl_no
        AND b.cd = g.cd
        AND b.equip_type = g.equip_type
  GROUP BY g.pat_id, g.ctl_no
  UNION ALL
  SELECT
    n.pat_id,
    n.ctl_no,
    CASE
      WHEN n.dual_type = 'upd' THEN (
        SELECT COALESCE(jsonb_object_agg(e.key, e.value), '{}'::jsonb)
        FROM jsonb_each(n.map) AS e(key, value)
        WHERE e.value->>'auto_insert' = '0'
      )
      ELSE n.map
    END AS final_map
  FROM new_map n
    JOIN base_ord b USING (pat_id, ctl_no)
  WHERE (
      n.dual_type = 'add'
      OR (
        n.dual_type = 'upd'
        AND EXISTS (
          SELECT 1
          FROM jsonb_each(n.map) AS e(key, value)
          WHERE e.value->>'auto_insert' = '0'
        )
      )
    )
    AND (b.ind_equip_info IS NULL OR b.ind_equip_info = '[]'::jsonb)
)
,equip_upd_data as (
  SELECT
    b.pat_id,
    b.ctl_no,
    (
      SELECT COALESCE(jsonb_agg(value - 'auto_insert'),'[]'::jsonb)
      FROM final_map m CROSS JOIN LATERAL jsonb_each(m.final_map)
      WHERE m.pat_id = b.pat_id and m.ctl_no = b.ctl_no
    ) AS new_ind_equip_info
  FROM base_ord b
)
,upd_data AS (
  SELECT
    b.ctl_no
   ,CASE WHEN patch ?? 'ind_sch_info' THEN
      CASE WHEN /*dto.mode*/'OVERWRITE' = 'OVERWRITE' THEN (patch->>'ind_sch_info')::jsonb
        WHEN /*dto.mode*/'OVERWRITE' = 'MERGE' THEN COALESCE(ind_sch_info, '[]'::jsonb) || (patch->>'ind_sch_info')::jsonb
        END
     END AS new_ind_sch_info
   ,CASE WHEN patch ?? 'ind_cond_info' THEN
      CASE WHEN /*dto.mode*/'OVERWRITE' = 'OVERWRITE' THEN (patch->>'ind_cond_info')::jsonb
        WHEN /*dto.mode*/'OVERWRITE' = 'MERGE' THEN COALESCE(ind_cond_info, '[]'::jsonb) || (patch->>'ind_cond_info')::jsonb
        END
     END AS new_ind_cond_info
  ,CASE WHEN NOT (patch ?? 'ind_medi_info') THEN null
      WHEN /*dto.mode*/'OVERWRITE' = 'OVERWRITE' THEN (patch->>'ind_medi_info')::jsonb
      WHEN /*dto.mode*/'OVERWRITE' = 'MERGE' AND patch->>'is_medi_change' = 'true'
        THEN mud.new_ind_medi_info
      ELSE COALESCE(ind_medi_info, '[]'::jsonb) || (patch->>'ind_medi_info')::jsonb
     END AS new_ind_medi_info
  ,CASE WHEN patch ?? 'ind_equip_info' THEN
      CASE WHEN /*dto.mode*/'OVERWRITE' = 'OVERWRITE' THEN (patch->>'ind_equip_info')::jsonb
        WHEN /*dto.mode*/'OVERWRITE' = 'MERGE' THEN eud.new_ind_equip_info
        END
     END AS new_ind_equip_info
  ,CASE WHEN patch ?? 'ind_ind_comment_info' THEN
      CASE WHEN /*dto.mode*/'OVERWRITE' = 'OVERWRITE' THEN (patch->>'ind_ind_comment_info')::jsonb
        WHEN /*dto.mode*/'OVERWRITE' = 'MERGE' THEN COALESCE(ind_ind_comment_info, '[]'::jsonb) || (patch->>'ind_ind_comment_info')::jsonb
        END
     END AS new_ind_ind_comment_info
  ,CASE WHEN patch ?? 'ind_device_set_info' THEN
      CASE WHEN /*dto.mode*/'OVERWRITE' = 'OVERWRITE' THEN (patch->>'ind_device_set_info')::jsonb
        WHEN /*dto.mode*/'OVERWRITE' = 'MERGE' THEN COALESCE(ind_device_set_info, '[]'::jsonb) || (patch->>'ind_device_set_info')::jsonb
        END
    END AS new_ind_device_set_info
  ,CASE WHEN patch ?? 'ind_treatment_cd' THEN (patch->>'ind_treatment_cd')::int
    END AS new_ind_treatment_cd
  from base_ord b
    CROSS JOIN (SELECT /*dto.patchJson*/'{}'::jsonb AS patch) p
    LEFT JOIN medi_upd_data mud
      ON b.pat_id = mud.pat_id
      AND b.ctl_no = mud.ctl_no
    LEFT JOIN equip_upd_data eud
      ON b.pat_id = eud.pat_id
      AND b.ctl_no = eud.ctl_no
)
UPDATE pat_treatment_pattern ptp
  SET
      ind_treatment_cd = COALESCE(ud.new_ind_treatment_cd, ptp.ind_treatment_cd)
      ,ind_sch_info = COALESCE(ud.new_ind_sch_info, ptp.ind_sch_info)
      ,ind_cond_info = COALESCE(ud.new_ind_cond_info, ptp.ind_cond_info)
      ,ind_medi_info = COALESCE(ud.new_ind_medi_info, ptp.ind_medi_info)
      ,ind_equip_info = COALESCE(ud.new_ind_equip_info, ptp.ind_equip_info)
      ,ind_ind_comment_info = COALESCE(ud.new_ind_ind_comment_info, ptp.ind_ind_comment_info)
      ,ind_device_set_info = COALESCE(ud.new_ind_device_set_info, ptp.ind_device_set_info)
      ,up_date = CURRENT_TIMESTAMP
FROM upd_data ud
WHERE
  ud.ctl_no = ptp.ctl_no
  AND (
    ptp.ind_sch_info IS DISTINCT FROM COALESCE(ud.new_ind_sch_info, ptp.ind_sch_info)
     OR ptp.ind_cond_info IS DISTINCT FROM COALESCE(ud.new_ind_cond_info, ptp.ind_cond_info)
     OR ptp.ind_medi_info IS DISTINCT FROM COALESCE(ud.new_ind_medi_info, ptp.ind_medi_info)
     OR ptp.ind_equip_info IS DISTINCT FROM COALESCE(ud.new_ind_equip_info, ptp.ind_equip_info)
     OR ptp.ind_ind_comment_info IS DISTINCT FROM COALESCE(ud.new_ind_ind_comment_info, ptp.ind_ind_comment_info)
     OR ptp.ind_device_set_info IS DISTINCT FROM COALESCE(ud.new_ind_device_set_info, ptp.ind_device_set_info)
     OR ptp.ind_treatment_cd IS DISTINCT FROM COALESCE(ud.new_ind_treatment_cd, ptp.ind_treatment_cd)
  )
  AND ptp.facility_cd = /*facilityCd*/'NKKSBR'
  AND ptp.pat_id = /*patId*/'44683'
  /*%if 0 != weeks.get(0)*/
  AND ptp.treat_week in /*weeks*/(0)
  /*%end*/
  /*%if 0 != treats.size()*/
  AND ptp.ind_treatment_cd in /*treats*/(0)
  /*%end*/
  /*%if 0 != kurs.size()*/
  AND ptp.ind_kur_cd in /*kurs*/(0)
  /*%end*/
  RETURNING ptp.*

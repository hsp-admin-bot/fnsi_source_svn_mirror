SELECT
  /*%expand "A" */*
FROM mst_medicine_mix A
JOIN (
    SELECT DISTINCT val::INT AS medicine_mix_cd
    FROM ord_main o
    CROSS JOIN LATERAL (
        SELECT value->>'value' AS val
        FROM jsonb_each(o.ind_cond_info)
        WHERE key IN ('15','19','25')
          AND value->>'medicine_type' = '2'

        UNION ALL

        SELECT value->>'value'
        FROM jsonb_each(o.rst_cond_info)
        WHERE key IN ('15','19','25')
          AND value->>'medicine_type' = '2'

        UNION ALL

        SELECT elem->>'cd'
        FROM jsonb_array_elements(o.ind_medi_info) elem
        WHERE elem->>'medicine_type' = '2'

        UNION ALL

        SELECT elem->>'cd'
        FROM jsonb_array_elements(o.rst_medi_info) elem
        WHERE elem->>'medicine_type' = '2'
    ) s
    WHERE o.ord_no in /*ordNoList*/(null)
      AND val IS NOT NULL
) t
ON A.medicine_mix_cd = t.medicine_mix_cd;
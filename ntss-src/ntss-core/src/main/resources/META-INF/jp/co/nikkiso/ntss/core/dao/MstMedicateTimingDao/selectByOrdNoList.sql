SELECT
  /*%expand "A" */*
FROM mst_medicate_timing A
WHERE EXISTS (
    SELECT 1
    FROM ord_main t
    CROSS JOIN LATERAL jsonb_array_elements(
        COALESCE(t.ind_medi_info, '[]'::jsonb) ||
        COALESCE(t.rst_medi_info, '[]'::jsonb)
    ) AS elem
    WHERE t.ord_no in /*ordNoList*/(null)
      AND (elem->>'timing_cd')::int = A.medicate_timing_cd 
);
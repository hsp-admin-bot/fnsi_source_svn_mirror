WITH expanded_data AS (
    SELECT 
        op.ord_prescription_no, 
        elem.value AS original_elem,
        ROW_NUMBER() OVER (PARTITION BY op.ord_prescription_no ORDER BY op.ord_prescription_no) AS pos,  
        (elem.value ->> 'Rp') AS current_rp,
        (elem.value ->> 'type') AS elem_type,
        elem.value AS elem_json,
        elem.ordinality AS array_index
    FROM ord_prescription op,
    LATERAL jsonb_array_elements(op.prescription_detail) WITH ORDINALITY AS elem(value, ordinality)
), 
lag_data AS (
    SELECT *,
        LAG(current_rp) OVER (PARTITION BY ord_prescription_no ORDER BY pos) AS prev_rp,
        LAG(elem_type) OVER (PARTITION BY ord_prescription_no ORDER BY pos) AS prev_type
    FROM expanded_data
),
rp_groups AS (
    SELECT 
        *,
        SUM(CASE WHEN current_rp <> prev_rp OR prev_rp IS NULL THEN 1 ELSE 0 END) 
            OVER (PARTITION BY ord_prescription_no ORDER BY pos) AS rp_group_id
    FROM lag_data
),
type_increments AS (
    SELECT 
        *,
        CASE 
            WHEN elem_type = '1' 
                 AND prev_type IS DISTINCT FROM '1' 
                 AND prev_rp = current_rp 
            THEN 1 
            ELSE 0 
        END AS should_increment
    FROM rp_groups
),
sub_no_calculated AS (
    SELECT 
        *,
        CASE
            WHEN elem_type = 'E' THEN ''  
            ELSE 
                (COALESCE(SUM(should_increment) OVER (PARTITION BY ord_prescription_no, rp_group_id ORDER BY pos), 0) + 1)::TEXT
        END AS sub_no
    FROM type_increments
),
updated_json AS (
SELECT 
    ord_prescription_no,
    jsonb_agg(
      CASE 
        WHEN elem_type = 'E' THEN original_elem || '{"sub_no": ""}'::jsonb
        ELSE original_elem || jsonb_build_object('sub_no', sub_no)
      END
      ORDER BY array_index
    ) AS new_prescription_detail
FROM sub_no_calculated
GROUP BY ord_prescription_no
)
UPDATE ntss.ord_prescription op
SET prescription_detail = uj.new_prescription_detail
FROM updated_json uj
WHERE op.ord_prescription_no = uj.ord_prescription_no

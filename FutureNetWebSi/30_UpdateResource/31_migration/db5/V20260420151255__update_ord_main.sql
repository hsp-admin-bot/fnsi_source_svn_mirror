-- ind_medi_info
UPDATE ord_main
SET ind_medi_info = (
  SELECT jsonb_agg(
           jsonb_set(
             elem,
             '{amount}',
             to_jsonb(
               CASE
                 WHEN elem->>'amount' LIKE '%.%'
                      AND LENGTH(SPLIT_PART(elem->>'amount', '.', 2)) > 8
                 THEN TO_CHAR(ROUND((elem->>'amount')::numeric, 8), 'FM9999999990.00000000')
                 ELSE elem->>'amount'
               END
             ),
             false
           )
         )
  FROM jsonb_array_elements(ind_medi_info) AS elem
)
WHERE 
  EXISTS (
    SELECT 1
    FROM jsonb_array_elements(ind_medi_info) AS elem
    WHERE elem->>'amount' LIKE '%.%'
      AND LENGTH(SPLIT_PART(elem->>'amount', '.', 2)) > 8
  );

-- rst_medi_info
UPDATE ord_main
SET rst_medi_info = (
  SELECT jsonb_agg(
           jsonb_set(
             elem,
             '{amount}',
             to_jsonb(
               CASE
                 WHEN elem->>'amount' LIKE '%.%'
                      AND LENGTH(SPLIT_PART(elem->>'amount', '.', 2)) > 8
                 THEN TO_CHAR(ROUND((elem->>'amount')::numeric, 8), 'FM9999999990.00000000')
                 ELSE elem->>'amount'
               END
             ),
             false
           )
         )
  FROM jsonb_array_elements(rst_medi_info) AS elem
)
WHERE 
  EXISTS (
    SELECT 1
    FROM jsonb_array_elements(rst_medi_info) AS elem
    WHERE elem->>'amount' LIKE '%.%'
      AND LENGTH(SPLIT_PART(elem->>'amount', '.', 2)) > 8
  );

-- ind_cond_info 17,22,26,27,28
UPDATE ord_main
SET ind_cond_info = (
  SELECT jsonb_object_agg(key, 
           CASE
             WHEN jsonb_typeof(value) = 'object'
                  AND value ? 'value'
                  AND value->>'value' ~ '^[0-9.]+$'
                  AND value->>'value' LIKE '%.%'
                  AND LENGTH(SPLIT_PART(value->>'value', '.', 2)) > 8
             THEN jsonb_set(
                    value,
                    '{value}',
                    to_jsonb(
                      TO_CHAR(
                        ROUND((value->>'value')::numeric, 8),
                        'FM9999999990.00000000'
                      )
                    ),
                    false
                  )
             ELSE value
           END
         )
  FROM jsonb_each(ind_cond_info)
)
WHERE
  EXISTS (
    SELECT 1
    FROM jsonb_each(ind_cond_info)
    WHERE jsonb_typeof(value) = 'object'
      AND value ? 'value'
      AND value->>'value' ~ '^[0-9.]+$'
      AND value->>'value' LIKE '%.%'
      AND LENGTH(SPLIT_PART(value->>'value', '.', 2)) > 8
  );

-- rst_cond_info 17,22,26,27,28
UPDATE ord_main
SET rst_cond_info = (
  SELECT jsonb_object_agg(key, 
           CASE
             WHEN jsonb_typeof(value) = 'object'
                  AND value ? 'value'
                  AND value->>'value' ~ '^[0-9.]+$'
                  AND value->>'value' LIKE '%.%'
                  AND LENGTH(SPLIT_PART(value->>'value', '.', 2)) > 8
             THEN jsonb_set(
                    value,
                    '{value}',
                    to_jsonb(
                      TO_CHAR(
                        ROUND((value->>'value')::numeric, 8),
                        'FM9999999990.00000000'
                      )
                    ),
                    false
                  )
             ELSE value
           END
         )
  FROM jsonb_each(rst_cond_info)
)
WHERE
  EXISTS (
    SELECT 1
    FROM jsonb_each(rst_cond_info)
    WHERE jsonb_typeof(value) = 'object'
      AND value ? 'value'
      AND value->>'value' ~ '^[0-9.]+$'
      AND value->>'value' LIKE '%.%'
      AND LENGTH(SPLIT_PART(value->>'value', '.', 2)) > 8
  );

--rst_treatment_info
UPDATE ord_main
SET rst_treatment_info = (
  SELECT jsonb_agg(
           jsonb_set(
             elem,
             '{amount}',
             to_jsonb(
               CASE
                 WHEN elem->>'amount' LIKE '%.%'
                      AND LENGTH(SPLIT_PART(elem->>'amount', '.', 2)) > 8
                 THEN TO_CHAR(ROUND((elem->>'amount')::numeric, 8), 'FM9999999990.00000000')
                 ELSE elem->>'amount'
               END
             ),
             false
           )
         )
  FROM jsonb_array_elements(rst_treatment_info) AS elem
)
WHERE
  EXISTS (
    SELECT 1
    FROM jsonb_array_elements(rst_treatment_info) AS elem
    WHERE elem->>'amount' LIKE '%.%'
      AND LENGTH(SPLIT_PART(elem->>'amount', '.', 2)) > 8
  );
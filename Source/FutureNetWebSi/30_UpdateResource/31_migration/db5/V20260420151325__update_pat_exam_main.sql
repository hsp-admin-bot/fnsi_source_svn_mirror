UPDATE pat_exam_main
SET exam_result_info = (
  SELECT jsonb_agg(
    jsonb_set(
      jsonb_set(
        jsonb_set(elem,
          '{lower}',
          CASE
            WHEN jsonb_typeof(elem->'lower') = 'string'
                 AND LOWER(elem->>'lower') <> 'null'
                 AND elem->>'lower' <> ''
                 AND elem->>'lower' LIKE '%.%'
                 AND length(split_part(elem->>'lower', '.', 2)) > 8
            THEN to_jsonb(to_char(round((elem->>'lower')::numeric, 8), 'FM9999999990.00000000'))
            ELSE elem->'lower'
          END,
          true
        ),
        '{upper}',
        CASE
          WHEN jsonb_typeof(elem->'upper') = 'string'
               AND LOWER(elem->>'upper') <> 'null'
               AND elem->>'upper' <> ''
               AND elem->>'upper' LIKE '%.%'
               AND length(split_part(elem->>'upper', '.', 2)) > 8
          THEN to_jsonb(to_char(round((elem->>'upper')::numeric, 8), 'FM9999999990.00000000'))
          ELSE elem->'upper'
        END,
        true
      ),
      '{result}',
      CASE
        WHEN jsonb_typeof(elem->'result') = 'string'
             AND LOWER(elem->>'result') <> 'null'
             AND elem->>'result' <> ''
             AND elem->>'result' LIKE '%.%'
             AND length(split_part(elem->>'result', '.', 2)) > 8
        THEN to_jsonb(to_char(round((elem->>'result')::numeric, 8), 'FM9999999990.00000000'))
        ELSE elem->'result'
      END,
      true
    )
  )
  FROM jsonb_array_elements(exam_result_info) elem
)
WHERE exam_result_info is not null
  and EXISTS (
  SELECT 1
  FROM jsonb_array_elements(exam_result_info) AS elem
  WHERE
    (
      jsonb_typeof(elem->'lower') = 'string'
      AND LOWER(elem->>'lower') <> 'null'
      AND elem->>'lower' <> ''
      AND elem->>'lower' LIKE '%.%'
      AND length(split_part(elem->>'lower', '.', 2)) > 8
    )
    OR (
      jsonb_typeof(elem->'upper') = 'string'
      AND LOWER(elem->>'upper') <> 'null'
      AND elem->>'upper' <> ''
      AND elem->>'upper' LIKE '%.%'
      AND length(split_part(elem->>'upper', '.', 2)) > 8
    )
    OR (
      jsonb_typeof(elem->'result') = 'string'
      AND LOWER(elem->>'result') <> 'null'
      AND elem->>'result' <> ''
      AND elem->>'result' LIKE '%.%'
      AND length(split_part(elem->>'result', '.', 2)) > 8
    )
);
WITH updated_data AS (
  SELECT
    pat_event_cd,
    jsonb_agg(
      CASE
        WHEN elem->>'format_class' = '2'
        AND jsonb_typeof(elem->'result_value') = 'array' THEN
          jsonb_build_object(
            'va_name',
            COALESCE(
              (SELECT result->>'name'
               FROM jsonb_array_elements(elem->'result_value') AS result
               WHERE result->>'is_send_va' = '1'
                 AND result ? 'name'
               LIMIT 1
              ),
              (SELECT result->>'name'
               FROM jsonb_array_elements(elem->'result_value') AS result
               WHERE result ? 'name'
               LIMIT 1
              ),
              ''
            )
          )
          || (elem - 'result_value')
          || jsonb_build_object(
            'result_value',
            (SELECT jsonb_agg((result.value) - 'name' ORDER BY ordinality)
            FROM jsonb_array_elements(elem->'result_value') WITH ORDINALITY AS result)
          )
        ELSE
          elem
      END
      ORDER BY idx
    ) AS new_result_params
  FROM pat_event,
       LATERAL jsonb_array_elements(result_params) WITH ORDINALITY AS arr(elem, idx)
WHERE use_type = 1
GROUP BY pat_event_cd
  )
UPDATE pat_event
SET result_params = updated_data.new_result_params
  FROM updated_data
WHERE pat_event.pat_event_cd = updated_data.pat_event_cd;

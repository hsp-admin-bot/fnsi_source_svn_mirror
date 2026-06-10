SELECT
  visitJson
FROM
  pat_unique
  CROSS JOIN jsonb_array_elements(in_out_visit_history_info) visitJson
WHERE
  facility_cd = /* facilityCd */'0'
  AND pat_id = /* patId */0
  AND visitJson->>'period_start' <= /* targetDate */'19000101'
ORDER BY
	visitJson->>'period_start' DESC
LIMIT 1
;

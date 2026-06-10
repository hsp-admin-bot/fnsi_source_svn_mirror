SELECT DISTINCT pat_id
FROM pat_unique,
     jsonb_array_elements(in_out_visit_history_info) AS elem
WHERE elem ->> 'move_in_out' = /*moveInOutCd*/NULL
  AND elem ->> 'period_end' = /*date*/NULL
  AND elem ->> 'facility_cd' = /*facilityCd*/NULL
  AND is_del = '0'
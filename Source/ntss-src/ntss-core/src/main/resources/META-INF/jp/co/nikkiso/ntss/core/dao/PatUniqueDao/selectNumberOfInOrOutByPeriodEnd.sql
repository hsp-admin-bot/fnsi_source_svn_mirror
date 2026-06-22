SELECT elem ->> 'period_end' AS date,
                count(DISTINCT pat_id) AS number_of_pat
FROM pat_unique,
     jsonb_array_elements(in_out_visit_history_info) AS elem
WHERE elem ->> 'move_in_out' = /*moveInOutCd*/NULL
  AND elem ->> 'period_end' >= /*startDate*/NULL
  AND elem ->> 'period_end' <= /*endDate*/NULL
  AND elem ->> 'facility_cd' = /*facilityCd*/NULL
  AND is_del = '0'
GROUP BY elem ->> 'period_end'
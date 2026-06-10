-- modify by chamaojia 2023-11-07 [9717] move_in_out_cdを範囲検索に変更し、グループ化する   --start
SELECT elem ->> 'period_start' AS date,
    elem ->> 'move_in_out' AS move_in_out_cd,
    count(DISTINCT pat_id) AS number_of_pat
FROM pat_unique,
     jsonb_array_elements(in_out_visit_history_info) AS elem
WHERE elem ->> 'move_in_out' in /*moveInOutCdList*/(NULL)
  AND elem ->> 'period_start' >= /*startDate*/NULL
  AND elem ->> 'period_start' <= /*endDate*/NULL
  AND elem ->> 'facility_cd' = /*facilityCd*/NULL
  AND is_del = '0'
GROUP BY elem ->> 'period_start', elem ->> 'move_in_out'
-- modify by chamaojia 2023-11-07 [9717] move_in_out_cdを範囲検索に変更し、グループ化する   --end
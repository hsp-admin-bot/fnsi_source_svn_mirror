-- mod #12434 DB高負荷② zkm start
-- select
--   json_build_object(
--     'pat_id', B.pat_id,
--     'treat_date', json_agg(B.treat_date)
--   ) treat_date_list
-- from (
--   select distinct
--     A.pat_id,
--     A.treat_date
--   from
--     ord_main A
--   where
--     A.facility_cd = /*facilityCd*/1
--     and A.rst_dialysis_state in ('0', '1', '2', '3', '4', '5', '6')
--     and A.treat_date is not NULL
--     and A.is_del = '0'
--     /*%if patIdList.size() != 0 */
--     and A.pat_id in /* patIdList */(null)
--     /*%end*/
--   order by
--     A.pat_id,
--     A.treat_date
-- ) B
-- GROUP BY B.pat_id
-- ;
SELECT
  json_build_object(
    'pat_id', A.pat_id,
    'treat_date', json_agg(DISTINCT A.treat_date ORDER BY A.treat_date)
  ) AS treat_date_list
FROM ord_main A
WHERE A.facility_cd = /*facilityCd*/1
  AND A.rst_dialysis_state IN ('0','1','2','3','4','5','6')
  AND A.treat_date IS NOT NULL
  AND A.is_del = '0'
  /*%if patIdList.size() != 0 */
  and A.pat_id in /* patIdList */(null)
  /*%end*/
GROUP BY A.pat_id
ORDER BY A.pat_id
;
-- mod #12434 DB高負荷② zkm end

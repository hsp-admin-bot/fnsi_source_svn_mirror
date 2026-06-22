select
  json_build_object(
    'radSetCd', mrs.rad_set_cd,
    'patId', prm.pat_id,
    'regRadDate', to_char(max(prm.reg_rad_date),'YYYY/MM/DD')
  )
from
  mst_rad_set mrs, pat_rad_main prm
where
  prm.order_rad_set_info::jsonb @> ('[{"rad_set_cd":' || mrs.rad_set_cd || '}]')::jsonb
  /*%if patIdList.size() != 0 */
  and prm.pat_id in /* patIdList */(null)
  /*%end*/

--- startDateが空の場合、クエリ結果がおかしくなる問題を解決 炜 start
  /*%if !startDate.isEmpty()  */
  and prm.reg_rad_date < TO_TIMESTAMP(/* startDate */null, 'YYYY/MM/DD')::timestamp
  /*%end*/
--- startDateが空の場合、クエリ結果がおかしくなる問題を解決 炜 end

  and prm.is_del = '0'
group by mrs.rad_set_cd,prm.pat_id

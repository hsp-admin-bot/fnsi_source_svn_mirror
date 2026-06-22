-- 保持 add 10389 患者リストのソートが遅い gjn start
select
  pat_id,
  medical_hst_info
from
  pat_unique
where
  is_del = '0'
  and pat_id in /* patIdList */(null)
order by
  pat_id
;
-- 保持 add 10389 患者リストのソートが遅い gjn end

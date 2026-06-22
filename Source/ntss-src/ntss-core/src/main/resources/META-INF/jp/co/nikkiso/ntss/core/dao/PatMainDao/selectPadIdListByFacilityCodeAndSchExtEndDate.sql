select
  pat_id
from
  pat_main
where
  is_del = '0'
and
(
  facility_cd = /* facilityCode */null and
  -- #10378 日次処理、最終延長日更新ルール、最終延長日が存在且つ延長されていない　対応 朴 start
  --(sch_ext_end_date < /* sch_ext_end_date */null OR sch_ext_end_date is null)
  (sch_ext_end_date is not null AND sch_ext_end_date < /* sch_ext_end_date */null)
  -- #10378 日次処理、最終延長日更新ルール、最終延長日が存在且つ延長されていない　対応 朴 end
)
order by
  pat_id
;

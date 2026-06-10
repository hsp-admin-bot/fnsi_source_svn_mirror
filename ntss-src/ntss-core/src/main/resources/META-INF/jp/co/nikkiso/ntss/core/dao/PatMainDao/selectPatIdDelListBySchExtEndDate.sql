-- add 8008日次処理のスケジュール自動延長がされない患者が存在する。20221018 赵 start
select
  pat_id
from
  pat_main
where
  is_del = '1'
and
(
  sch_ext_end_date < /* sch_ext_end_date */null
  and
  sch_ext_end_date is not null
)
order by
  facility_cd,
  pat_id
;
-- add 8008日次処理のスケジュール自動延長がされない患者が存在する。20221018 赵 end

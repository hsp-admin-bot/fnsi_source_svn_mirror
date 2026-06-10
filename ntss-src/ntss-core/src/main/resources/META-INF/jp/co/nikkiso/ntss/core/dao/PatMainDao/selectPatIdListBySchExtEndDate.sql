select
  pat_id
from
  pat_main
where
  is_del = '0'
and
(
  sch_ext_end_date < /* sch_ext_end_date */null
)
order by
  facility_cd,
  pat_id
;

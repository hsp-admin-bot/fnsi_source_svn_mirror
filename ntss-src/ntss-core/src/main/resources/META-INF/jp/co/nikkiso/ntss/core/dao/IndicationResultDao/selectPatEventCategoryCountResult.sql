select
  p.event_start_date
  ,p.sub_category_cd
  ,max(p.category_cd) as category_cd
  ,max(p.category_name) as category_name
  ,max(p.sub_category_name) as sub_category_name
  ,count(p.sub_category_cd) as sub_category_count
from
  pat_event p
where
  p.pat_id = /*patId*/0
and
  p.facility_cd = /*facilityCd*/'000000'
and
  p.event_start_date between /*treatDateFrom*/'19000101' and /*treatDateTo*/'20991231'
and
  p.is_del = '0'
group by
  p.event_start_date
  ,p.sub_category_cd
;

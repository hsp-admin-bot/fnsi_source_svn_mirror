with pat_phy_info as (
  select
    cast(jsonb_array_elements(physical_info)->>'ctl_no' as int) as ctl_no,
    jsonb_array_elements(physical_info)->>'exam_date' as exam_date,
    jsonb_array_elements(physical_info)->>'indicator_cd' as indicator_cd,
    jsonb_array_elements(physical_info)->>'changer_cd' as changer_cd,
    jsonb_array_elements(physical_info)->>'dw' as dw
  from
    pat_unique
  where
    pat_id = /*patId*/0
  )
select
  ctl_no,
  indicator_cd,
  changer_cd,
  exam_date as start_date,
  lead(exam_date) over (order by exam_date, ctl_no) as end_date,
  dw
from
  pat_phy_info
where
  dw is not null
group by
  ctl_no,
  indicator_cd,
  changer_cd,
  exam_date,
  dw

select
  /*%expand */*
from
  pat_insurance
where
  pat_id = /*patId*/0
and
  facility_cd = /*facilityCd*/''
and
  is_del = '0'
and
  is_coop = '1'
order by
  ctl_no
;
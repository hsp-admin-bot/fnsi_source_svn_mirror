select
  /*%expand "A" */*
from
  mst_pat_event_data_template A
where
  facility_cd = /*facilityCd*/1
and
  is_del = '0'
-- or EXISTS (select template_cd from pat_event where facility_cd = /*facilityCd*/1 and template_cd = A.template_cd)
;

select
  /*%expand "A" */*
from
  mst_pat_event_data_template A
where
  facility_cd = /*facilityCd*/1
and
  is_disp = '1'
and
  is_del = '0'
;

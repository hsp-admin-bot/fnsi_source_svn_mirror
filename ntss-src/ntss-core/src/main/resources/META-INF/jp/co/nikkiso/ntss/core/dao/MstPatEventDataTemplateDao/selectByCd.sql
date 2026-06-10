select
  /*%expand "A" */*
from
  mst_pat_event_data_template A
where
  template_cd = /*templateCd*/1
and
  is_disp = '1'
and
  is_del = '0'
;


select
  /*%expand*/*
from
  mni_monitor
where
  ord_no = /*ordNo*/'1'
and
  data_type = /*dataType*/1
order by
  occur_date
;

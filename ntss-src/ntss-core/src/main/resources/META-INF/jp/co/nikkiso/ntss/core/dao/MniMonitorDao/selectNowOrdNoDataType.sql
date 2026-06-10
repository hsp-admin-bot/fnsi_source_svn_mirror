select
  /*%expand */*
from
  mni_monitor
where
  bio_moni_ctl_no =
  (select
    max(bio_moni_ctl_no)
  from
    mni_monitor
  where
    ord_no = /*ordNo*/'1'
  and
    data_type=/*dataType*/1
  and
    is_del = '0'
  )
;
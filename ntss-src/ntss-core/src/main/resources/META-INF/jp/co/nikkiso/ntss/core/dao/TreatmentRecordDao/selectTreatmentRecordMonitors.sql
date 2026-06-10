select
  bio_moni_ctl_no
  , monitor_data
  , occur_date
  , is_del
  , upd_staff_id
from
  mni_monitor
where
  ord_no = /*ordNo*/'1'
and
  data_type = 1
and
  is_del = '0'
order by
  occur_date
;

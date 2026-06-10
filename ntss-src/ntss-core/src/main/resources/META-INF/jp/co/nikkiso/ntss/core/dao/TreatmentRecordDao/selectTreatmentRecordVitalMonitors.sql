select
  bio_moni_ctl_no
  , data_type
  , monitor_data
  , occur_date
  , upd_staff_id
from
  mni_monitor
where
  facility_cd = /*facilityCd*/'000000'
and
  ord_no = /*ordNo*/'1'
and
  data_type in (2, 4, 5, 6)
and
  is_del = '0'
order by
  occur_date
;

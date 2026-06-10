select
  bio_moni_ctl_no, facility_cd, machine_type_cd, machine_serial, ord_no, pat_id, monitor_data, is_del, occur_date, reg_date, up_date
from
  mni_monitor
where
  facility_cd = /* facilityCd */'1'
  and
  ord_no = /* ordNo */0
  and
  pat_id = /* patId */0
  and
  data_type IN (2, 4, 5, 6)
  and
  is_del = '0'
order by occur_date DESC, up_date DESC
limit 1
;

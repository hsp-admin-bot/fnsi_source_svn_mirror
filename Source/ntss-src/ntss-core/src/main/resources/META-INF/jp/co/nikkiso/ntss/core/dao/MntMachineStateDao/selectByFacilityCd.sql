select
  machine_status,
  ord_no,
  next_ord_no,
  pat_id,
  next_patid,
  cond_send_date,
  cond_set_date,
  start_date,
  end_date
from
  mnt_machine_state
where
  facility_cd = /*facilityCd*/'1'
;
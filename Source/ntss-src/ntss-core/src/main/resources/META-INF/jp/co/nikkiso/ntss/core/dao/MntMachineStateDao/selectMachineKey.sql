select
  machine_status,
  ord_no,
  next_ord_no,
  pat_id,
  next_patid,
  start_plan_date,
  end_plan_date,
  cond_send_date,
  cond_set_date,
  is_pat_verified,
  start_date,
  end_date,
  tmp_device_set_info
from
  mnt_machine_state
where
  facility_cd = /*facilityCd*/'1'
and
  machine_type_cd = /*machineTypeCd*/'1'
and
  machine_serial = TRIM(/*machineSerial*/'1')
;

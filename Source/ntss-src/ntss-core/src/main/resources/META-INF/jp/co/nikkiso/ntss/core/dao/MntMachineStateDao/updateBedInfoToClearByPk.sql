-- add by chamaojia 2024-07-03 [10806] Add SQL for clearing bed related information --start
update mnt_machine_state
set
  bed_cd = null,
  bed_name = null,
  ord_no = null,
  next_ord_no = null,
  pat_id = null,
  next_patid = null,
  next_kur_cd = null,
  start_plan_date = null,
  end_plan_date = null,
  weigh_before_date = null,
  cond_send_date = null,
  cond_set_date = null,
  start_date = null,
  end_date = null,
  weigh_after_date = null,
  tmp_device_set_info = null,
  monitor_data = null,
  up_date = CURRENT_TIMESTAMP
where
  facility_cd = /*facilityCd*/null
and
  machine_type_cd = /*machineTypeCd*/null
and
  machine_serial = /*machineSerial*/null
;
-- add by chamaojia 2024-07-03 [10806] Add SQL for clearing bed related information --end

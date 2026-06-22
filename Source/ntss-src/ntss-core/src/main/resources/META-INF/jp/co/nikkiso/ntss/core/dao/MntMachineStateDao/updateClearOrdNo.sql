update
  mnt_machine_state
set
  ord_no = null,
  pat_id = null,
  weigh_before_date = null,
  -- modify 10196 by kangjie 20240411 start 状態が壊れており、インストール時間は00:00の欠陥です
  -- tmp_device_set_info = null,
  -- modify 10196 by kangjie 20240411 end 状態が壊れており、インストール時間は00:00の欠陥です
  cond_send_date = null,
  cond_set_date = null,
  is_pat_verified = '0',
  start_date = null,
  end_date = null,
  weigh_after_date = null,
  alarm_list = '{}'::JSONB,
  up_date = /*upDate*/null
where
  facility_cd = /*facilityCd*/'1'
  and
  machine_type_cd = /*machineTypeCd*/'1'
  and
  machine_serial = /*machineSerial*/'1'
  and
  ord_no = /*ordNo*/0

;

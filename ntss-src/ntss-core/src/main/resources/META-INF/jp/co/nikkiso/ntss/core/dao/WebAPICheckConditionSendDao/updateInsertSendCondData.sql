update mnt_machine_state
set 
  tmp_device_set_info = /*jsonCondData*/'{}'
  ,up_date = current_timestamp
where
    next_ord_no = /*ordNo*/0
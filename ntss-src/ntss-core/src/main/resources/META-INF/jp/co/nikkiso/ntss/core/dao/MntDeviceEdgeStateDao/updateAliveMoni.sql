update mnt_device_edge_state
set
  alive_moni_status = '01',
  alive_moni_status_change_date =
    case
      when alive_moni_status = '01'
        then alive_moni_status_change_date
      else
        CURRENT_TIMESTAMP
    end,
  last_moni_time = CURRENT_TIMESTAMP,
  up_date = CURRENT_TIMESTAMP
where
  facility_cd = /*param.facilityCd*/'999000' and
  device_edge_no = /*param.deviceEdgeNo*/1
;
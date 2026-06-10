update mnt_if_edge_healthmon
set healthmon_facility_conn = (healthmon_facility_conn
    /*%for item : delHFCItemList*/
      #- /* item */'{}'
    /*%end*/
    ),
    up_date = current_timestamp
where
  ctl_no = /* ctlNo */null
;
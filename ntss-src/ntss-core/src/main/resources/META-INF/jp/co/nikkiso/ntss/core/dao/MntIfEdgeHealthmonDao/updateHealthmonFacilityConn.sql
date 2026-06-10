update mnt_if_edge_healthmon
set
/*%if healthmon.healthmonServerConn != null */ -- null の場合は、更新しない
  healthmon_server_conn = /* healthmon.healthmonServerConn */'{}',
/*%end*/
  -- modify by chamaojia 2024-10-11 [11140] change to JSON merge --start
  healthmon_facility_conn = jsonb_merge_recursive( healthmon_facility_conn, /* healthmon.healthmonFacilityConn */'{}' ),
  -- modify by chamaojia 2024-10-11 [11140] change to JSON merge --end
  up_date = /* healthmon.upDate */null
where
  ctl_no = /* healthmon.ctlNo */null
;

-- add by chamaojia 2024-09-26 [10574] change to batch modification and return the dataset --start
update mnt_if_edge_healthmon
set
/*%if healthmonServerConn != null */ -- null の場合は、更新しない
  healthmon_server_conn = (
        case when healthmon_server_conn is null then
                 /* healthmonServerConn */'{}'
             else  healthmon_server_conn ||
                 /* healthmonServerConn */'{}'
            end),
/*%end*/
  healthmon_facility_conn=(
        case when healthmon_facility_conn is null then
         /* healthmonFacilityConn */'{}'
            -- modify by chamaojia 2024-10-11 [11140] change to using custom functions for JSON merging --start
            else jsonb_merge_recursive(healthmon_facility_conn, /* healthmonFacilityConn */'{}')
            -- modify by chamaojia 2024-10-11 [11140] change to using custom functions for JSON merging --end
            end),
  up_date = CURRENT_TIMESTAMP
where
  -- modify by chamaojia 2024-10-11 [11140] change to individual query --start
  ctl_no  = /*ctlNo*/null
  -- modify by chamaojia 2024-10-11 [11140] change to individual query --end
RETURNING *
;
-- add by chamaojia 2024-09-26 [10574] change to batch modification and return the dataset --end
update mnt_if_edge_healthmon
set
/*%if healthmon.healthmonServerConn != null */ -- null の場合は、更新しない
  healthmon_server_conn = /* healthmon.healthmonServerConn */'{}',
/*%end*/
healthmon_facility_conn=(
case when healthmon_facility_conn is null then
 /* healthmon.healthmonFacilityConn */'{}'
	else  healthmon_facility_conn ||
	/* healthmon.healthmonFacilityConn */'{}'
	end),
  up_date = /* healthmon.upDate */null
where
  ctl_no = /* healthmon.ctlNo */null
;
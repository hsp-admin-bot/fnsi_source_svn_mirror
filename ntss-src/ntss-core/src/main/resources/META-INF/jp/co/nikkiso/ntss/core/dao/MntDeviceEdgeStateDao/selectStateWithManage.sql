select
 state.facility_cd,
 state.device_edge_no,
 state.alive_moni_status,
 state.version_information,
 state.send_mail_status,
 state.manage_no,
 state.manage_plan_date,
 state.last_moni_time,
 manage.user_id,
 manage.order_class,
 manage.order_target_class,
 manage.response_status,
 manage.manage_info
from
 mnt_device_edge_state state
 left outer join mnt_device_edge_manage manage
 on state.manage_no = manage.manage_no
where
  state.facility_cd is not null
/*%if facilityCd != null && facilityCd.length() > 0*/
  and
  state.facility_cd = /*facilityCd*/''
  and
  state.device_edge_no = /*deviceEdgeNo*/0
/*%end */
order by
  state.facility_cd, state.device_edge_no
;
update
  mnt_device_edge_state
set
  manage_no = /* deviceEdgeState.manageNo */0,
  manage_plan_date = /* deviceEdgeState.managePlanDate */0,
  up_date = /* deviceEdgeState.upDate */null
WHERE
  facility_cd = /* deviceEdgeState.facilityCd */''
AND
  device_edge_no = /* deviceEdgeState.deviceEdgeNo */1
;
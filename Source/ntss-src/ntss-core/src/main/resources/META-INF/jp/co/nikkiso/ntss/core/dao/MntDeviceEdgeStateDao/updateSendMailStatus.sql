UPDATE
	mnt_device_edge_state
SET
	send_mail_status = /* deviceEdgeState.sendMailStatus */0,
	up_date = /* deviceEdgeState.upDate */null
WHERE
  facility_cd = /* deviceEdgeState.facilityCd */'000001'
AND
  device_edge_no = /* deviceEdgeState.deviceEdgeNo */1
;
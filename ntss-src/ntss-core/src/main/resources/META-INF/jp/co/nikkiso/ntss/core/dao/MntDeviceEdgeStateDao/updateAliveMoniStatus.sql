UPDATE
	mnt_device_edge_state
SET
	alive_moni_status = /* deviceEdgeState.aliveMoniStatus */'01',
  alive_moni_status_change_date =
    case
      when alive_moni_status = /* deviceEdgeState.aliveMoniStatus */'01'
        then alive_moni_status_change_date
      else
        CURRENT_TIMESTAMP
    end,
	last_moni_time = /* deviceEdgeState.lastMoniTime */null,
	up_date = /* deviceEdgeState.upDate */null
WHERE
	device_edge_no = /* deviceEdgeState.deviceEdgeNo */1
AND
	facility_cd = /* deviceEdgeState.facilityCd */'000001'
;
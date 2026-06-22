update mnt_machine_state
set
	pat_id = null,
	ord_no = null,
	weigh_before_date = null,
	cond_send_date = null,
	is_pat_verified = '0',
	start_date = null,
	end_date = null,
	weigh_after_date = null,
	alarm_list = '{}'::JSONB,
	up_date = /*upDate*/null
where
	facility_cd = /*facilityCd*/null
and
	machine_type_cd = /*machineTypeCd*/null
and
	machine_serial = trim(/*machineSerial*/null)
;

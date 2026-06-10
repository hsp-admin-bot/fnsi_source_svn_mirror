update mnt_machine_state
set
    m_notice_cnt = /*mNoticeCnt*/0
where
	facility_cd = /*facilityCd*/null
and
	machine_type_cd = /*machineTypeCd*/null
and
	machine_serial = trim(/*machineSerial*/null)
;

update mnt_machine_state
set
	pat_id = /*patId*/null,
	ord_no = /*ordNo*/null,
	up_date = /*upDate*/null
	/*%if nextFlag */
    ,next_ord_no = /*ordNo*/null
    ,next_patid = /*patId*/null
	/*%end*/
where
	facility_cd = /*facilityCd*/null
and
	machine_type_cd = /*machineTypeCd*/null
and
	machine_serial = trim(/*machineSerial*/null)
;

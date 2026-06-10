SELECT
blood_purify_type,
	machine_name,
	ip_address,
	port
FROM
	mst_machine
WHERE
	facility_cd = /*facilityCd*/null
	AND is_disable = '0'
	AND is_blood_purify_use = '0'
	AND is_disp = '1'
	AND is_del = '0'
order by blood_purify_type asc

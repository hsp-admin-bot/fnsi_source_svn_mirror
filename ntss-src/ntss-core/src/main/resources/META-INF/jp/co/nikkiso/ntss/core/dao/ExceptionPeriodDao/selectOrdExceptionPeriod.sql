SELECT
	exception_period_no,
	facility_cd,
	pat_id,
	exception_period_from,
	exception_period_to,
	reg_date,
	reg_staff_id,
	up_date,
	upd_staff_id
FROM
	ord_exception_period
WHERE
	facility_cd = /*facilityCd*/'009999'
AND pat_id = /*patId*/0
;

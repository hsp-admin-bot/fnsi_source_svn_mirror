UPDATE
	pat_insurance
SET
	is_del = /*patInsurance.is_del*/'0',
	up_date = to_timestamp(/*patInsurance.up_date*/NULL, 'YYYY-MM-DD HH24:MI:SS')
WHERE
    insurance_cd = /*patInsurance.insurance_cd*/NULL;

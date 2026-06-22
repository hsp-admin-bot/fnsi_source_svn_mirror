SELECT
	ord_prescription_no
FROM
	ord_prescription
WHERE
	issue_date = /* issueDate */''
AND pat_id IN /* patIdList */(0)
AND issue_state = '0'
AND is_del = '0'
AND is_disp = '1'
AND	facility_cd = /* facilityCd */null
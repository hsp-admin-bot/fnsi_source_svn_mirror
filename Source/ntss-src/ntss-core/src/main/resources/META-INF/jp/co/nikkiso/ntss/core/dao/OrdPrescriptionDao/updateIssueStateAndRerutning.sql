UPDATE ord_prescription
SET
	issue_state= '1',
	up_date= /*upDate*/null
WHERE
	ord_prescription_no IN /* ordPrescriptionNoList */(0)
AND is_del = '0'
AND is_disp = '1'
AND	facility_cd = /* facilityCd */null
RETURNING *;

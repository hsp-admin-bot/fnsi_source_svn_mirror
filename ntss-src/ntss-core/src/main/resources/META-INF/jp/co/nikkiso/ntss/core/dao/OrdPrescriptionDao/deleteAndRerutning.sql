UPDATE ord_prescription
SET
	is_del= '1',
	up_date= /*upDate*/null
WHERE
   ord_prescription_no = /*ordPrescriptionNo*/0
RETURNING *;

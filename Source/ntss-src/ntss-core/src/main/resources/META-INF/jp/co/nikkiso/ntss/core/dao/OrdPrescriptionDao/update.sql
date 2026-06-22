UPDATE ord_prescription
SET
	facility_cd= /*ordPrescription.facilityCd*/null,
	pat_id= /*ordPrescription.patId*/null,
	prescription_type= /*ordPrescription.prescriptionType*/'0',
	issue_date= replace(/*ordPrescription.issueDate*/null, '/', ''),
	issue_state= /*ordPrescription.issueState*/'0',
	expiration_date= replace(/*ordPrescription.expirationDate*/null, '/', ''),
	prescription_detail= /*ordPrescription.prescriptionDetail*/null,
	is_disp= /*ordPrescription.isDisp*/'1',
	is_del= '0',
	up_date= /*ordPrescription.upDate*/null
WHERE
  ord_prescription_no = /*ordPrescription.ordPrescriptionNo*/0;
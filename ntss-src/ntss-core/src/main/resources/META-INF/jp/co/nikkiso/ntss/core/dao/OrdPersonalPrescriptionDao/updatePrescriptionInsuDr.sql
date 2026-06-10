UPDATE ord_personal_prescription 
SET 
	insu_dr_id= /*insuDrId*/null,
	insu_dr_name=  personal_info_encrypt (/*insuDrName*/null),
	insu_dr_sign=  personal_info_encrypt (/*insuDrName*/null),
	up_date= /*upDate*/null
WHERE
	ord_prescription_no IN /* ordPrescriptionNoList */(0)
AND is_del = '0'
AND is_disp = '1'
AND	facility_cd = /* facilityCd */null
AND	CASE
	WHEN
		/*selectedPreDoctor*/null = '1' AND insu_dr_id is not null
	THEN
		false
	ELSE
		true
	END
	;
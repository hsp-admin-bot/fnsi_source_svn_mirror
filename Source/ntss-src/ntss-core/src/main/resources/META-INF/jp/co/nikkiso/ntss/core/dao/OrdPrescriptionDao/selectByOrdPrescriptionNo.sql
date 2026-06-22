select
	A.ord_prescription_no,
	A.facility_cd,
	A.pat_id,
	A.prescription_type,
	replace(substring(to_timestamp(A.issue_date, 'YYYYMMDD')::text, 1, 10), '-', '/') as issue_date,
	A.issue_state,
	replace(substring(to_timestamp(A.expiration_date, 'YYYYMMDD')::text, 1, 10), '-', '/') as expiration_date,
	A.prescription_detail,
	A.is_disp,
	A.is_del,
	A.reg_date,
	A.up_date
from
	ord_prescription A
where
	A.ord_prescription_no = /*ordPrescriptionNo*/0
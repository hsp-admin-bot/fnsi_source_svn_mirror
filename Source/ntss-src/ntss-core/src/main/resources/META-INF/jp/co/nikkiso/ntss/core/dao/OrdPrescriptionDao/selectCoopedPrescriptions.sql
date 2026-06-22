SELECT
	ord.reg_date,
	ord.up_date,
	ord.ord_prescription_no,
	ord.facility_cd,
	ord.pat_id,
	ord.prescription_type,
	ord.issue_date,
	ord.issue_state,
	ord.expiration_date,
	ord.prescription_detail,
	ord.is_disp,
	ord.is_del
FROM
	ord_prescription ord,
	ord_coop_no ocn
WHERE
    ord.ord_prescription_no::TEXT = ocn.coop_ord_no
    AND ord.facility_cd = ocn.facility_cd
    AND ord.is_disp = '1'
    AND ord.is_del = '0'
    AND ocn.is_disp = '1'
    AND ocn.is_del = '0'
    AND ord.facility_cd = /*facilityCd*/''

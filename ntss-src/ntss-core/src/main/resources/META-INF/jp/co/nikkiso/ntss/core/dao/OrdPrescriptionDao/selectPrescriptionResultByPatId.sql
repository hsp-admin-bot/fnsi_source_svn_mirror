-- add #11226 患者情報系historyの取得条件見直し② (複数患者帳票) 高　start
SELECT
	ord.reg_date,
	ord.up_date,
	ord.ord_prescription_no,
	ord.facility_cd,
	fac.facility_name,
	ord.pat_id,
	ord.prescription_type,
	ord.issue_date,
	ord.issue_state,
	ord.expiration_date,
	ord.prescription_detail,
	ord.is_disp,
	ord.is_del
FROM
	ord_prescription AS ord
	LEFT JOIN mst_facility AS fac ON fac.facility_cd = ord.facility_cd
WHERE
	ord.pat_id = /* patId */0
  /*%if fromDate == toDate */
  and ord.issue_date = /*fromDate*/''
  /*%else */
  and (ord.issue_date between /* fromDate */'' and /* toDate */'' or ord.expiration_date between /* fromDate */'' and /* toDate */'')
  /*%end */
    and ord.is_del = '0'
-- add #11226 患者情報系historyの取得条件見直し② (複数患者帳票) 高　end

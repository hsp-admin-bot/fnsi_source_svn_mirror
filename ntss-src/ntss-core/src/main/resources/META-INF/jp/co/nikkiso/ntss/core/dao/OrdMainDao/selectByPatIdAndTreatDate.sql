SELECT
	ord.ord_no,
	ord.rst_dialysis_state,
	ord.treat_date,
	ord.ind_kur_cd,
	ord.ind_treatment_cd,
	treat_week,
-- 	add FNSI-7216 治療開始時刻を変更してもsys_coop_journalにイベントが作成されない 劉全航 start
	ord.ind_bed_cd,
	ord.ind_treat_start_time
-- 	add FNSI-7216 治療開始時刻を変更してもsys_coop_journalにイベントが作成されない 劉全航 end
FROM
	ord_main AS ord
	LEFT JOIN mst_kur AS kur ON ord.ind_kur_cd = kur.kur_cd
WHERE
	ord.pat_id =/*pat_id*/0
	AND
		ord.facility_cd = /*facilityCd*/'000000'
/*%if null != fromDate && fromDate != "null" */
	AND
		ord.treat_date >= /*fromDate*/null
/*%end*/
/*%if null != toDate && toDate != "null" */
	AND
		ord.treat_date <= /*toDate*/null
/*%end*/
	AND ord.is_del = '0'
ORDER BY
	ord.treat_date

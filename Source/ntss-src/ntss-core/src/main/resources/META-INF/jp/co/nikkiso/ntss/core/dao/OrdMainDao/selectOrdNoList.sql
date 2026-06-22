SELECT
	ord_no,
	rst_dialysis_state,
	treat_date,
	kur_start_time,
	facility_cd
FROM
	(
		SELECT
			ord_no,
			rst_dialysis_state,
			treat_date,
			kur_start_time,
			ord.facility_cd,
			ROW_NUMBER () OVER (
				ORDER BY
					rst_dialysis_state ASC,
					treat_date DESC,
					rst_start_date DESC,
					rst_treatment_cd ASC,
					ord_no DESC
			) AS index
		FROM ord_main AS ord
		LEFT JOIN mst_kur AS kur
		ON ord.ind_kur_cd = kur.kur_cd
		WHERE
			/*%if pat_id != null */
				ord.pat_id =/*pat_id*/0
			/*%end*/

			AND ord.rst_dialysis_state in ('1','2','3', '4', '5', '6')
			AND ord.is_del = '0'
	) AS tmp
ORDER BY tmp.index ASC

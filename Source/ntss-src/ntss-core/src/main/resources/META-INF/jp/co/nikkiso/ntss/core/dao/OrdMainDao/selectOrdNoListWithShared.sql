SELECT
	ord_no,
	rst_dialysis_state,
	treat_date,
	kur_start_time,
	facility_cd,
	cur_edition_date
FROM
	(
		SELECT
			ord_no,
			rst_dialysis_state,
			treat_date,
			kur_start_time,
			ord.facility_cd,
			cur_edition_date,
			ROW_NUMBER () OVER (
				ORDER BY
					rst_dialysis_state DESC,
					treat_date DESC,
					--mod FNSI redmine 8379 ljx start
					--ind_kur_cd ASC,
					kur_start_time DESC,
					--mod FNSI redmine 8379 ljx end
					ord_no DESC
			) AS index
		FROM ord_main AS ord
		LEFT JOIN mst_kur AS kur
		ON ord.ind_kur_cd = kur.kur_cd
		WHERE
			ord.pat_id =/*pat_id*/0
			AND ord.rst_dialysis_state in /*states*/('1','2','3', '4', '5', '6')
			AND ord.is_del = '0'
	) AS tmp
ORDER BY tmp.index ASC

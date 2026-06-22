SELECT
	tem.DATE,
	COUNT ( DISTINCT tem.pat_id ) AS number_of_pat
FROM
	(
	SELECT
		pat_id,
		elem ->> 'period_start' AS DATE,
		ROW_NUMBER ( ) OVER ( PARTITION BY pat_id ORDER BY elem ->> 'ctl_no' ) AS n
	FROM
		pat_unique,
		jsonb_array_elements ( in_out_visit_history_info ) AS elem
	WHERE
		elem ->> 'move_in_out' = /*moveInOutCd*/NULL
		AND elem ->> 'period_start' >= /*startDate*/NULL
		AND elem ->> 'period_start' <= /*endDate*/NULL
		AND elem ->> 'facility_cd' = /*facilityCd*/NULL
		AND is_del = '0'
	) tem
WHERE
	n < 2
GROUP BY
	tem.DATE

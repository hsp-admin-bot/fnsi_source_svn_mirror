UPDATE pat_treatment_pattern A 
SET ind_sch_info = jsonb_set ( ind_sch_info, '{ind_treat_start_time}', concat ( concat ( '"', b.start_time ), '"' ) :: jsonb ) 
FROM
	(
	SELECT
		substr( ind_sch_info :: json ->> 'ind_treat_start_time' :: TEXT, 1, 4 ) :: TEXT AS start_time,
		pat_id,
		ctl_no 
	FROM
		pat_treatment_pattern 
	WHERE
		LENGTH ( ind_sch_info :: json ->> 'ind_treat_start_time' ) > 4 
	) b 
WHERE
	b.pat_id = A.pat_id 
	AND b.ctl_no = A.ctl_no 
	AND LENGTH ( A.ind_sch_info :: json ->> 'ind_treat_start_time' ) >4
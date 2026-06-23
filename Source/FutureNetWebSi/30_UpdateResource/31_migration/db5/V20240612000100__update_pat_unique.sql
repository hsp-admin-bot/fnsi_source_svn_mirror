WITH update_data AS (
	SELECT
		pat_id,
		facility_cd,
		jsonb_agg ( CASE WHEN info ->> 'course_is_free' IS NOT NULL THEN info ELSE info || jsonb_build_object ( 'course_is_free', '0' ) END ) AS updated_jsonb 
	FROM
		pat_unique,
		jsonb_array_elements ( in_out_visit_history_info ) AS info
	WHERE
		facility_cd = 'NKKSBR' 
	AND is_del = '0'
	GROUP BY
		pat_id,
		facility_cd 
	) 
UPDATE pat_unique 
	SET in_out_visit_history_info = update_data.updated_jsonb 
FROM
	update_data 
WHERE
	pat_unique.facility_cd = update_data.facility_cd 
	AND pat_unique.pat_id = update_data.pat_id 
	AND pat_unique.facility_cd = 'NKKSBR'
	AND is_del = '0'
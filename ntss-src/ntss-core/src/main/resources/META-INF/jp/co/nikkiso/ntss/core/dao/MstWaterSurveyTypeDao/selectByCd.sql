SELECT 
	survey_type_cd,
	survey_type_name,
	facility_cd,
	integer_digits,
	decimal_digits,
	unit,
	initial_value,
	initial_string,
	upper_threshold,
	lower_threshold,
	is_show_graph,
	graph_upper_limit,
	graph_lower_limit,
	is_disp,
	is_del,
	reg_date,
	up_date
FROM 
	mst_water_survey_type
WHERE 
	survey_type_cd = /*surveyTypeCd*/0
	AND 
	is_disp = '1'
	AND
	is_del = '0'
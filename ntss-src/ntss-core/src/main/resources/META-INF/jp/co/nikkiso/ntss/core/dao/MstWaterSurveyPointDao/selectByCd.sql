SELECT 
	ws.survey_point_cd, 
	ws.point_name, 
	ws.facility_cd, 
	ws.machine_no, 
	m.machine_name,
	t.survey_type_cd,
	t.survey_type_name,
	ws.is_disp, 
	ws.is_del,
	ws.reg_date,
	ws.up_date
FROM 
	mst_water_survey_point AS ws, 
	mst_machine AS m, mst_water_survey_type as t
WHERE 
	ws.machine_no = m.machine_no 
	AND 
	ws.survey_point_cd = /*surveyPointCd*/0
	AND
	ws.survey_type_cd = t.survey_type_cd
	AND 
	ws.is_disp = '1'
	AND
	ws.is_del = '0'
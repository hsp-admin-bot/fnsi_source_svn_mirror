UPDATE 
	mnt_water_survey 
SET 
	facility_cd = /*watSurvey.facilityCd*/null,
	inspection_date = to_timestamp(/*watSurvey.inspectionDate*/null, 'YYYY-MM-DD HH24:MI:SS'),
	survey_data = /*watSurvey.surveyData*/null,
	up_date = to_timestamp(/*watSurvey.upDate*/null, 'YYYY-MM-DD HH24:MI:SS'),
	is_disp=/*watSurvey.isDisp*/'1',
	is_del=/*watSurvey.isDel*/'0'
	
WHERE
	survey_record_no = /*watSurvey.surveyRecordNo*/null

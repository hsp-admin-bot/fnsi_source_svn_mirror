INSERT INTO mnt_water_survey(
	facility_cd,
	inspection_date,
	survey_data,
	up_date,
	reg_date
	)
VALUES
	(
	/*watSurvey.facilityCd*/NULL,
	to_timestamp(/*watSurvey.inspectionDate*/NULL, 'YYYY-MM-DD HH24:MI:SS'),
	/*watSurvey.surveyData*/NULL,
	to_timestamp(/*watSurvey.upDate*/null, 'YYYY-MM-DD HH24:MI:SS'),
	to_timestamp(/*watSurvey.regDate*/null, 'YYYY-MM-DD HH24:MI:SS')
	)

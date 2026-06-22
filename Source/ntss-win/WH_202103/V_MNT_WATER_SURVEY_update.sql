update V_MNT_WATER_SURVEY
set SURVEY_POINT_CD ='@surveyPointCd',
	SURVEY_POINT_NAME='@surveyPointName',
	UP_DATE=to_date('@upDate','yyyy-mm-dd hh24:mi:ss'),
	CHECK_DATE='@checkDate',
	RESULT='@result',
	UNIT='@unit',
	DETAIL='@detail'

 where PATID = @patid;
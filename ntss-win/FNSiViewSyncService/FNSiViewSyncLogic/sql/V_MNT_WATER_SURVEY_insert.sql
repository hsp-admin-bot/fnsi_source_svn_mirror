INSERT
	INTO
		V_MNT_WATER_SURVEY(
			SURVEY_POINT_CD,
			SURVEY_POINT_NAME,
			UP_DATE,
			CHECK_DATE,
			RESULT,
			UNIT,
			DETAIL,
			SURVEY_NO
		)
	SELECT
		CASE WHEN LENGTHB(surveypointcd) > 5 THEN SUBSTRB(surveypointcd, -5) ELSE surveypointcd END,
		CASE WHEN LENGTHB(surveypointname) > 64 THEN SUBSTRB(surveypointname, -64) ELSE surveypointname END,
		TO_DATE("update",'yyyy-mm-dd hh24:mi:ss'),
		CASE WHEN LENGTHB(checkdate) > 8 THEN SUBSTRB(checkdate, -8) ELSE checkdate END,
		result,
		CASE WHEN LENGTHB(unit) > 64 THEN SUBSTRB(unit, -64) ELSE unit END,
		blob_to_varchar2(detail, -2048),
		CASE WHEN LENGTHB(surveyno) > 20 THEN SUBSTRB(surveyno, -20) ELSE surveyno END
	FROM V_MNT_WATER_SURVEY_TEMP


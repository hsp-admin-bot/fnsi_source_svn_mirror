INSERT
	INTO
		V_PAT_EXAMIN_SCH(
			PATID,
			UP_DATE,
			EXAM_DATE,
			EXAM_TIME,
			EXAM_SET_CD,
			EXAM_SET_NAME,
			EXAM_DIVISION,
			EXAM_PROC_CD,
			DOCTOR_CODE,
			DOCTOR_NAME,
			ORDER_STAFF,
			ORDER_NAME,
			UPDATE_CODE,
			UPDATE_NAME,
			EXAM_NO
		)
	SELECT
		CASE WHEN LENGTHB(hosppatid) > 12 THEN SUBSTRB(hosppatid, -12) ELSE hosppatid END,
		TO_DATE("update",'yyyy-mm-dd hh24:mi:ss'),
		CASE WHEN LENGTHB(examdate) > 8 THEN SUBSTRB(examdate, -8) ELSE examdate END,
		CASE WHEN LENGTHB(examtime) > 4 THEN SUBSTRB(examtime, -4) ELSE examtime END,
		CASE WHEN LENGTHB(examsetcd) > 20 THEN SUBSTRB(examsetcd, -20) ELSE examsetcd END,
		CASE WHEN LENGTHB(examsetname) > 40 THEN SUBSTRB(examsetname, -40) ELSE examsetname END,
		CASE WHEN LENGTHB(examdivision) > 1 THEN SUBSTRB(examdivision, -1) ELSE examdivision END,
		CASE WHEN LENGTHB(examproccd) > 1 THEN SUBSTRB(examproccd, -1) ELSE examproccd END,
		CASE WHEN LENGTHB(doctorcode) > 10 THEN SUBSTRB(doctorcode, -10) ELSE doctorcode END,
		CASE WHEN LENGTHB(doctorname) > 20 THEN SUBSTRB(doctorname, -20) ELSE doctorname END,
		CASE WHEN LENGTHB(orderstaff) > 10 THEN SUBSTRB(orderstaff, -10) ELSE orderstaff END,
		CASE WHEN LENGTHB(ordername) > 20 THEN SUBSTRB(ordername, -20) ELSE ordername END,
		CASE WHEN LENGTHB(updatecode) > 10 THEN SUBSTRB(updatecode, -10) ELSE updatecode END,
		CASE WHEN LENGTHB(updatename) > 20 THEN SUBSTRB(updatename, -20) ELSE updatename END,
		CASE WHEN LENGTHB(examno) > 20 THEN SUBSTRB(examno, -20) ELSE examno END
	FROM V_PAT_EXAMIN_SCH2_TEMP


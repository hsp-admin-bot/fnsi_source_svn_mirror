INSERT
	INTO
		V_ONL_DIALYSIS_VITAL(
			PATID,
			START_DATE,
			OCCUR_DATE,
			BP_MAX,
			BP_MIN,
			BP_AVE,
			PULSE,
			TEMPERATURE,
			BLOOD_SUGAR_LEVEL,
			UP_DATE,
			DIALYSIS_NO,
			BP_CLASS
		)
	SELECT
		CASE WHEN LENGTHB(hosppatid) > 12 THEN SUBSTRB(hosppatid, -12) ELSE hosppatid END,
		TO_DATE(startdate, 'yyyy-mm-dd hh24:mi:ss'),
		TO_DATE(occurdate, 'yyyy-mm-dd hh24:mi:ss'),
		CASE WHEN LENGTHB(bpmax) > 5 THEN SUBSTRB(bpmax, -5) ELSE bpmax END,
		CASE WHEN LENGTHB(bpmin) > 5 THEN SUBSTRB(bpmin, -5) ELSE bpmin END,
		CASE WHEN LENGTHB(bpave) > 5 THEN SUBSTRB(bpave, -5) ELSE bpave END,
		CASE WHEN LENGTHB(pulse) > 5 THEN SUBSTRB(pulse, -5) ELSE pulse END,
		temperature,
		CASE WHEN LENGTHB(bloodsugarlevel) > 5 THEN SUBSTRB(bloodsugarlevel, -5) ELSE bloodsugarlevel END,
		TO_DATE("update", 'yyyy-mm-dd hh24:mi:ss'),
		CASE WHEN LENGTHB(dialysisno) > 12 THEN SUBSTRB(dialysisno, -12) ELSE dialysisno END,
		CASE WHEN LENGTHB(bpclass) > 1 THEN SUBSTRB(bpclass, -1) ELSE bpclass END
	FROM V_ONL_DIALYSIS_VITAL_TEMP


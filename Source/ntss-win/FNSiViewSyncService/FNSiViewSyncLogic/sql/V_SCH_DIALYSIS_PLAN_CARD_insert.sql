INSERT
	INTO
		V_SCH_DIALYSIS_PLAN_CARD(
		 PATID,
		 DIALYSIS_DATE,
		 BED_NO,
		 BED_NAME,
		 KUR_CD,
		 KUR_NAME,
		 PLURAL,
		 UP_DATE,
		 RESULT_DIALYSISNO,
		 OPE_IND_PLAN,
		 DUMMY_FLG,
		 START_TIME
		)SELECT
		CASE WHEN LENGTHB(hosppatid) > 12 THEN SUBSTRB(hosppatid, -12) ELSE hosppatid END,
		CASE WHEN LENGTHB(dialysisdate) > 8 THEN SUBSTRB(dialysisdate, -8) ELSE dialysisdate END,
		CASE WHEN REGEXP_LIKE(bedno, '^-?[0-9]+(\.[0-9]+)?$') THEN CASE WHEN LENGTHB(bedno) > 4 THEN SUBSTRB(bedno, -4) ELSE bedno END ELSE NULL END,
		CASE WHEN LENGTHB(bedname) > 40 THEN SUBSTRB(bedname, -40) ELSE bedname END,
		CASE WHEN REGEXP_LIKE(kurcd, '^-?[0-9]+(\.[0-9]+)?$') THEN CASE WHEN LENGTHB(kurcd) > 6 THEN SUBSTRB(kurcd, -6) ELSE kurcd END ELSE NULL END,
		CASE WHEN LENGTHB(kurname) > 40 THEN SUBSTRB(kurname, -40) ELSE kurname END,
		CASE WHEN LENGTHB(plural) > 1 THEN SUBSTRB(plural, -1) ELSE plural END,
		TO_DATE("update",'yyyy-mm-dd hh24:mi:ss'),
		CASE WHEN LENGTHB(resultdialysisno) > 12 THEN SUBSTRB(resultdialysisno, -12) ELSE resultdialysisno END,
		CASE WHEN LENGTHB(opeindplan) > 1 THEN SUBSTRB(opeindplan, -1) ELSE opeindplan END,
		CASE WHEN LENGTHB(dummyflg) > 1 THEN SUBSTRB(dummyflg, -1) ELSE dummyflg END,
		CASE WHEN LENGTHB(starttime) > 6 THEN SUBSTRB(starttime, -6) ELSE starttime END
		FROM V_SCH_DIALYSIS_PLAN_CARD_TEMP


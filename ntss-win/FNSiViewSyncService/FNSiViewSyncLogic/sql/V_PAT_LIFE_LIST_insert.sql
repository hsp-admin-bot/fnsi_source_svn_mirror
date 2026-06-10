INSERT
	INTO
		V_PAT_LIFE_LIST(
			PATID,
			UP_DATE,
			NAME,
			NAME_KANA,
			REG_DATE,
			REG_TIME,
			KIND_ID,
			KIND_NAME,
			STAFF_CD,
			STAFF_NAME,
			EDIT_CD,
			EDIT_NAME,
			DETAIL1,
			DETAIL2,
			DETAIL3,
			DETAIL4,
			DIALYSIS_NO
		)
	SELECT
		CASE WHEN LENGTHB(hosppatid) > 12 THEN SUBSTRB(hosppatid, -12) ELSE hosppatid END,
		TO_DATE("update", 'YYYY-MM-DD hh24:mi:ss'),
		CASE WHEN LENGTHB(name) > 40 THEN SUBSTRB(name, -40) ELSE name END,
		CASE WHEN LENGTHB(namekana) > 40 THEN SUBSTRB(namekana, -40) ELSE namekana END,
		CASE WHEN LENGTHB(regdate) > 8 THEN SUBSTRB(regdate, -8) ELSE regdate END,
		CASE WHEN LENGTHB(regtime) > 4 THEN SUBSTRB(regtime, -4) ELSE regtime END,
		CASE WHEN LENGTHB(kindid) > 3 THEN SUBSTRB(kindid, -3) ELSE kindid END,
		CASE WHEN LENGTHB(kindname) > 20 THEN SUBSTRB(kindname, -20) ELSE kindname END,
		CASE WHEN LENGTHB(staffcd) > 10 THEN SUBSTRB(staffcd, -10) ELSE staffcd END,
		CASE WHEN LENGTHB(staffname) > 20 THEN SUBSTRB(staffname, -20) ELSE staffname END,
		CASE WHEN LENGTHB(editcd) > 10 THEN SUBSTRB(editcd, -10) ELSE editcd END,
		CASE WHEN LENGTHB(editname) > 20 THEN SUBSTRB(editname, -20) ELSE editname END,
		blob_to_varchar2(detail1, -1000),
		blob_to_varchar2(detail2, -1000),
		blob_to_varchar2(detail3, -1000),
		blob_to_varchar2(detail4, -1000),
		CASE WHEN LENGTHB(dialysisno) > 12 THEN SUBSTRB(dialysisno, -12) ELSE dialysisno END
	FROM V_PAT_LIFE_LIST_TEMP


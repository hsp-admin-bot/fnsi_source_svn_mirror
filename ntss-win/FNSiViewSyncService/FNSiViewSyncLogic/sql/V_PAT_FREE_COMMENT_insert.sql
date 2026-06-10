INSERT
	INTO
		V_PAT_FREE_COMMENT(
		 PATID,
		 CTL_NO,
		 TITLE,
		 CONTENT
		)
	SELECT
		CASE WHEN LENGTHB(hosppatid) > 12 THEN SUBSTRB(hosppatid, -12) ELSE hosppatid END,
		CASE WHEN LENGTHB(ctlno) > 2 THEN SUBSTRB(ctlno, -2) ELSE ctlno END,
		CASE WHEN LENGTHB(title) > 80 THEN SUBSTRB(title, -80) ELSE title END,
		blob_to_varchar2(content, -3500)
	FROM V_PAT_FREE_COMMENT_TEMP


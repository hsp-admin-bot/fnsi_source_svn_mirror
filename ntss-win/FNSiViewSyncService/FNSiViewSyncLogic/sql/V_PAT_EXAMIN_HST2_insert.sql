INSERT
	INTO
		V_PAT_EXAMIN_HST(
		 PATID,
		 EXAM_DATE,
		 ORDER_CLASS,
		 ITEM_UP_DATE,
		 EXAM_ITEM_CODE,
		 EXAM_ITEM_CODE2,
		 EXAM_ITEM_CODE3,
		 EXAM_ITEM_NAME,
		 EXAM_RST,
		 EXAM_CLASS_RST,
		 COMMENTS
		)
	SELECT
		CASE WHEN LENGTHB(hosppatid) > 12 THEN SUBSTRB(hosppatid, -12) ELSE hosppatid END,
		TO_DATE(examdate,'yyyy-mm-dd hh24:mi:ss'),
		CASE WHEN LENGTHB(orderclass) > 6 THEN SUBSTRB(orderclass, -6) ELSE orderclass END,
		TO_DATE(itemupdate,'yyyy-mm-dd hh24:mi:ss'),
		CASE WHEN LENGTHB(examitemcode) > 20 THEN SUBSTRB(examitemcode, -20) ELSE examitemcode END,
		CASE WHEN LENGTHB(examitemcode2) > 20 THEN SUBSTRB(examitemcode2, -20) ELSE examitemcode2 END,
		CASE WHEN LENGTHB(examitemcode3) > 20 THEN SUBSTRB(examitemcode3, -20) ELSE examitemcode3 END,
		CASE WHEN LENGTHB(examitemname) > 40 THEN SUBSTRB(examitemname, -40) ELSE examitemname END,
		CASE WHEN LENGTHB(examrst) > 256 THEN SUBSTRB(examrst, -256) ELSE examrst END,
		CASE WHEN LENGTHB(examclassrst) > 256 THEN SUBSTRB(examclassrst, -256) ELSE examclassrst END,
		CASE WHEN LENGTHB(comments) > 512 THEN SUBSTRB(comments, -512) ELSE comments END
	FROM V_PAT_EXAMIN_HST2_TEMP


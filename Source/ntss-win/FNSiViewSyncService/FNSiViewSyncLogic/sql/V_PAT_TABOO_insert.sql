INSERT INTO V_PAT_TABOO(
	PATID,
	NAME,
	CTL_NO,
	UP_DATE,
	TABOO,
	MEMO
)SELECT 
	CASE WHEN LENGTHB(hosppatid) > 12 THEN SUBSTRB(hosppatid, -12) ELSE hosppatid END,
	CASE WHEN LENGTHB(name) > 40 THEN SUBSTRB(name, -40) ELSE name END,
	ctlno,
	TO_DATE("update",'yyyy-mm-dd hh24:mi:ss'),
	blob_to_varchar2(taboo, -512),
	blob_to_varchar2(memo, -512)
	FROM V_PAT_TABOO_TEMP


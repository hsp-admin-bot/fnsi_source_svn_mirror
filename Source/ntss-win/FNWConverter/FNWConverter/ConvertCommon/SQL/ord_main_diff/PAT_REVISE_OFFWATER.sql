SELECT
	b.IND_ID 
FROM
	(
	SELECT patid,day_of_week,UP_DATE from PAT_REVISE_OFFWATER 
	where {0}
	and up_date >  :CONVERT_DATETIME
	) a
LEFT OUTER JOIN SYNC_ORD_MAIN_SCH_PLAN b ON ( a.patid = b.patid  AND (TO_CHAR( TO_DATE( b.dialysis_date ), 'D' ) - 1 = a.day_of_week OR a.day_of_week = -1) )
AND b.DIALYSIS_DATE >= to_date(TO_CHAR(a.UP_DATE, 'yyyyMMdd'), 'yyyyMMdd')


SELECT
	b.IND_ID 
FROM
	(
	SELECT 	patid,day_of_week,to_char(REG_DATE, 'yyyymmdd' ) as REG_DATE from v_pat_device_set  
	where {0}
	and REG_DATE > :CONVERT_DATETIME 
	) a
LEFT OUTER JOIN SYNC_ORD_MAIN_SCH_PLAN b ON ( a.patid = b.patid  AND TO_CHAR(TO_DATE(b.dialysis_date), 'D') - 1 = a.day_of_week )
AND b.DIALYSIS_DATE >= a.REG_DATE
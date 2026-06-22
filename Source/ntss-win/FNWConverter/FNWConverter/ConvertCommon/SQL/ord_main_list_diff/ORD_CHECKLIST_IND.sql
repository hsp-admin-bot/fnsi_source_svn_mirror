WITH RST_CHECKLIST_TMP AS (
  select s.DIALYSIS_NO, s.PATID, s.DIALYSIS_DATE, s.BED_NO, s.KUR_CD, s.CODE, count(1) CHECK_CNT
  from ({0}) s
	inner join SYNC_ORD_CHECKLIST_HIST hist
		ON s.DIALYSIS_NO = - 1 
		AND hist.PATID = s.PATID 
		AND hist.DIALYSIS_DATE = s.DIALYSIS_DATE 
		AND hist.BED_NO = s.BED_NO 
		AND hist.KUR_CD = s.KUR_CD 
		AND hist.CODE = s.CODE 
	group by s.DIALYSIS_NO, s.PATID, s.DIALYSIS_DATE, s.BED_NO, s.KUR_CD, s.CODE
)
select
    DISTINCT PATID
from
    ({0}) s
where
    {1}
UNION
select
     DISTINCT hist.PATID
from
    SYNC_ORD_CHECKLIST_HIST hist
	left join RST_CHECKLIST_TMP s
		on s.DIALYSIS_NO = -1
		and hist.PATID = s.PATID
		and hist.DIALYSIS_DATE = s.DIALYSIS_DATE
		and hist.BED_NO = s.BED_NO
		and hist.KUR_CD = s.KUR_CD
		and hist.CODE = s.CODE
		and hist.RST_CHECK_COUNT  = s.CHECK_CNT
where
	hist.DIALYSIS_DATE >= TO_DATE(:START_DATE, 'yyyyMMdd')
	AND s.PATID is null
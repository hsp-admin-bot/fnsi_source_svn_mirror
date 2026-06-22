update V_IND_DIALYSIS_ADD
set PATID ='@patid',
		DIALYSIS_DATE ='@dialysisDate',
		PLURAL='@plural',
		CTL_NO='@ctlNo',
		UP_DATE=to_date('@upDate','yyyy-mm-dd hh24:mi:ss'),
		ADDITION='@addition',
		INDICATOR_CD='@indicatorCd',
		OPE_IND_PLAN='@opeIndPlan'
 where PATID = @patid;
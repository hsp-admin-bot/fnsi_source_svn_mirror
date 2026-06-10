update V_SCH_DIALYSIS_PLAN_CARD
set PATID ='@patid',
		DIALYSIS_DATE ='@dialysisDate',
		BED_NO='@bedNo',
		BED_NAME='@bedName',
		KUR_CD='@kurCd',
		KUR_NAME='@kurName',
		PLURAL='@plural',
		UP_DATE=to_date('@upDate','yyyy-mm-dd hh24:mi:ss'),
		RESULT_DIALYSISNO='@resultDialysisno',
		OPE_IND_PLAN='@opeIndPlan',
		DUMMY_FLG='@dummyFlg',
		START_TIME='@startTime'
 where PATID = @patid;
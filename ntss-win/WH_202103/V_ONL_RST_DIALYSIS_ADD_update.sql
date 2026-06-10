update V_ONL_RST_DIALYSIS_ADD
set PATID ='@patid',
		DIALYSIS_DATE ='@dialysisDate',
		DIALYSIS_NO='@dialysisNo',
		CTL_NO ='@ctlNo',
		UP_DATE =to_date('@upDate','yyyy-mm-dd hh24:mi:ss'),
		EFFECT_FLG='@effectFlg',
		EFFECT_DATE=to_date('@effectDate','yyyy-mm-dd hh24:mi:ss'),
		ADDITION='@addition',
		STAFF_CD='@staffCd',
		STAFF_NAME='@staffName'
 where PATID = @patid;

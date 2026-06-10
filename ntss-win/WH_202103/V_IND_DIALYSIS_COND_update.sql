update V_IND_DIALYSIS_COND
set PATID ='@patid',
		DIALYSIS_DATE ='@dialysisDate',
		PLURAL='@plural',
		CTL_NO='@ctlNo',
		UP_DATE=to_date('@upDate','yyyy-mm-dd hh24:mi:ss'),
		DIALYSIS_ITEM_NAME='@dialysisItemName',
		VALUE='@value',
		VALUE_NAME='@valueName',
		UNIT='@unit',
		VALUE_CD2='@valueCd2',
		INDICATOR_CD='@indicatorCd',
		OPE_IND_PLAN='@opeIndPlan'
 where PATID = @patid;
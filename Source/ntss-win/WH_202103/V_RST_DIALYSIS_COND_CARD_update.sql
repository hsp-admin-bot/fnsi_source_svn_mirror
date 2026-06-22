update V_RST_DIALYSIS_COND_CARD
set PATID ='@patid',
		DIALYSIS_DATE ='@dialysisDate',
		DIALYSIS_NO='@dialysisNo',
		CTL_NO ='@ctlNo',
		UP_DATE =to_date('@upDate','yyyy-mm-dd hh24:mi:ss'),
		DIALYSIS_ITEM_NAME ='@dialysisItemName',
		VALUE ='@value',
		VALUE_NAME='@valueName',
		MED_GENERAL_NAME='@medGeneralName',
		UNIT='@Unit',
		VALUE_CD1='@valueCd1'
 where PATID = @patid;
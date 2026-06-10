update V_RST_DIALYSIS_COND
   set DIALYSIS_DATE ='@dialysisDate',
		DIALYSIS_NO='@dialysisNo',
		CTL_NO ='@ctlNo',
		UP_DATE =to_date('@upDate','yyyy-mm-dd hh24:mi:ss'),
		DIALYSIS_ITEM_NAME ='@dialysisItemName',
		VALUE ='@value',
		VALUE_NAME='@valueName',
		UNIT='@Unit',
		VALUE_CD2='@valueCd2'
 where PATID = @patid;
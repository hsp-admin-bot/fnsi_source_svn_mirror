update V_IND_DIALYSIS_EQUIP
set PATID ='@patid',
		DIALYSIS_DATE ='@dialysisDate',
		PLURAL='@plural',
		CTL_NO='@ctlNo',
		UP_DATE=to_date('@upDate','yyyy-mm-dd hh24:mi:ss'),
		EQUIP_CD='@equipCd',
		EQUIP_CD2='@equipCd2',
		EQUIP_CLASS_NAME='@equipClassName',
		EQUIP_NAME='@equipName',
		PUNCTURE_CLASS='@punctureClass',
		AMOUNT='@amount',
		UNIT='@uint',
		COMMENTS='@comments',
		INDICATOR_CD='@indicatorCd',
		OPE_IND_PLAN='@opeIndPlan'
 where PATID = @patid;
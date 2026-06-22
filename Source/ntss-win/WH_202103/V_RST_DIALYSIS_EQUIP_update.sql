update V_RST_DIALYSIS_EQUIP
set PATID ='@patid',
		DIALYSIS_DATE ='@dialysisDate',
		DIALYSIS_NO='@dialysisNo',
		CTL_NO ='@ctlNo',
		UP_DATE =to_date('@upDate','yyyy-mm-dd hh24:mi:ss'),
		EQUIP_CD ='@equipCd',
		EQUIP_CD2='@equipCd2',
		EQUIP_NAME='@equipName',
		EQUIP_CLASS_NAME='@equipClassName',
		PUNCTURE_CLASS='@punctureClass',
		AMOUNT='@amount',
		UNIT='@Unit',
		COMMENTS='@comments'
 where PATID = @patid;


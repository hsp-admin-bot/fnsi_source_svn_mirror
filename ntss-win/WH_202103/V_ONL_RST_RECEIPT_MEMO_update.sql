update V_ONL_RST_RECEIPT_MEMO
set PATID ='@patid',
		DIALYSIS_DATE ='@dialysisDate',
		DIALYSIS_NO='@dialysisNo',
		CTL_NO ='@ctlNo',
		UP_DATE =to_date('@upDate','yyyy-mm-dd hh24:mi:ss'),
		DIVISION='@division',
		CODE='@code',
		CODE_UPDATE=null,
		ADD_FLG='@addFlg',
		ITEM_NAME='@itemName',
		MAIN_DIAL_DIFF='@mainDialDiff',
		IN_HOSPITAL_CD='@inHospitalCd',
		IN_HOSPITAL_CD2='@inHospitalCd2'
 where PATID = @patid;
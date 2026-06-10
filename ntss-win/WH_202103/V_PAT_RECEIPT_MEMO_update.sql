update V_PAT_RECEIPT_MEMO
   set PATID ='@patid',
		UP_DATE =null,
		DIVISION =null,
		CODE='@code',
		CODE_UPDATE=null,
		ADD_FLG='@addFlg',
		ITEM_NAME='@itemName',
		MAIN_DIAL_DIFF='@mainDialDiff',
		IN_HOSPITAL_CD='@inHospitalCd',
		IN_HOSPITAL_CD2='@inHospitalCd2'
		
 where PATID = @patid;
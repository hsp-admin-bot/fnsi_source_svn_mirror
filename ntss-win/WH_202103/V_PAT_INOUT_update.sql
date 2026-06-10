update V_PAT_INOUT
set PATID ='@patid',
		CTL_NO='@ctlNo',
		REG_DATE=to_date('@regDate','yyyy-mm-dd hh24:mi:ss'),
		INOUT_CD='@inoutCd',
		FACILITY_NAME='@facilityName',
		DR_NAME='@drName',
		MEMO='@memo',
		CODE_NAME='@codeName'

 where PATID = @patid;
update V_PAT_EXAMIN_SCH
set PATID ='@patid',
		UP_DATE=to_date('@upDate','yyyy-mm-dd hh24:mi:ss'),
		EXAM_DATE='@examDate',
		EXAM_TIME='@examTime',
		EXAM_SET_CD='@examSetCd',
		EXAM_SET_NAME='@examSetName',
		EXAM_DIVISION='@examDivision',
		EXAM_PROC_CD=null,
		DOCTOR_CODE='@doctorCode',
		DOCTOR_NAME='@doctorName',
		ORDER_STAFF='@orderStaff',
		ORDER_NAME='@orderName',
		UPDATE_CODE='@updateCode',
		UPDATE_NAME='@updatename'

 where PATID = @patid;
update V_PAT_LIFE_LIST
set PATID ='@patid',
		UP_DATE=to_date('@upDate', 'YYYY-MM-DD hh24:mi:ss'),
		NAME='@name',
		NAME_KANA='@nameKana',
		REG_DATE='@regDate',
		REG_TIME='@regTime',
		KIND_ID='@kindId',
		KIND_NAME='@kindName',
		STAFF_CD='@staffCd',
		STAFF_NAME='@staffName',
		EDIT_CD='@editCd',
		EDIT_NAME='@editName',
		DETAIL1='@detail1',
		DETAIL2='@detail2',
		DETAIL3='@detail3',
		DETAIL4='@detail4'

 where PATID = @patid;
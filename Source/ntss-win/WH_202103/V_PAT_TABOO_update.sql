update V_PAT_TABOO
   set PATID ='@patid',
		NAME ='@name',
		CTL_NO ='@ctlNo',
		UP_DATE =to_date('@upDate','yyyy-mm-dd hh24:mi:ss'),
		TABOO ='@taboo',
		MEMO ='@memo'

 where PATID = @patid;

update V_PAT_INFECT
   set PATID ='@patid',
		INFECTION_CD ='@infectionCd',
		INFECTION_NAME ='@infectionName',
		UP_DATE =to_date('@upDate','yyyy-mm-dd hh24:mi:ss'),
		INFECT ='@infect'

 where PATID = @patid;
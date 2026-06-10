update V_PAT_FREE_COMMENT
		set PATID ='@patid',
		CTL_NO='@ctlNo',
		TITLE='@title',
		CONTENT='@content'

 where PATID = @patid;
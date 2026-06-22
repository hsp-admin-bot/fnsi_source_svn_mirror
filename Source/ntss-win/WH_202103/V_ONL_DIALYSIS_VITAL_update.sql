update V_ONL_DIALYSIS_VITAL
set PATID ='@patid',
		START_DATE=to_date('@startDate','yyyy-mm-dd hh24:mi:ss'),
		OCCUR_DATE=to_date('@occurDate','yyyy-mm-dd hh24:mi:ss'),
		BP_MAX='@bpMax',
		BP_MIN='@bpMin',
		BP_AVE='@bpAve',
		PULSE='@pulse',
		TEMPERATURE='@temperature',
		BLOOD_SUGAR_LEVEL='@bloodSugarLevel',
		UP_DATE=to_date('@upDate','yyyy-mm-dd hh24:mi:ss'),
		DIADYSIS_NO='@diadysisNo',
		BP_CLASS='@bpClass'

 where PATID = @patid;
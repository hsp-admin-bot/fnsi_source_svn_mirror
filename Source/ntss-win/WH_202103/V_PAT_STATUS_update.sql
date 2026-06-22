update V_PAT_STATUS
set PATID ='@patid',
		DIALYSIS_DATE='@dialysisDate',
		DIALYSIS_TIME='@dialysisTime',
		START_PLAN_DATE='@startPlanDate',
		ENTER_FLG='@enterFlg',
		ENTER_DATE=to_date('@enterDate', 'YYYY-MM-DD hh24:mi:ss'),
		MACHINE_CHECK_FLG='@machineCheckFlg',
		MACHINE_CHECK_DATE=to_date('@machineCheckDate', 'YYYY-MM-DD hh24:mi:ss'),
		DIALSIS_START_FLG='@dialsisStartFlg',
		DIALSIS_START_DATE=to_date('@dialsisStartDate', 'YYYY-MM-DD hh24:mi:ss'),
		OFFWATER_FLG='@offwaterFlg',
		OFFWATER_DATE=to_date('@offwaterDate', 'YYYY-MM-DD hh24:mi:ss'),
		WASTE_FLUID_FLG='@wasteFluidFlg',
		WASTE_FLUID_DATE=to_date('@wasteFluidDate', 'YYYY-MM-DD hh24:mi:ss'),
		WEIGHT_AFTER_FLG='@weightAfterFlg',
		WEIGHT_AFTER_DATE=to_date('@wasteFluidDate', 'YYYY-MM-DD hh24:mi:ss'),
		RECOVERY_BTN_FLG='@recoveryBtnFlg',
		RECOVERY_BTN_DATE=to_date('@recoveryBtnDate', 'YYYY-MM-DD hh24:mi:ss'),
		UP_DATE=to_date('@upDate', 'YYYY-MM-DD hh24:mi:ss')

 where PATID = @patid;
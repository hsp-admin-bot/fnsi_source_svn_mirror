UPDATE "ntss"."sys_data_set" 
SET
  "sql" = 'UPDATE pat_unique 
SET
  physical_info = CASE ''@physicalInfoFlg'' 
    WHEN '''' THEN ''@physicalInfoValue'' 
    ELSE physical_info || (''[{"ctl_no":"@nextCtlNo1", "exam_date":"'' || TO_CHAR(TO_DATE(''@physicalInfo.examDate_Date'', ''yyyy-MM-dd hh24:mi:ss''), ''yyyy-MM-dd'') || ''", "order_class":"@physicalInfo.orderClass", "height":"@physicalInfo.height", "ctr_weight":"@physicalInfo.ctrWeight", "breast_dia":"@physicalInfo.breastDia", "chest_dia":"@physicalInfo.chestDia", "ctr":"@physicalInfo.ctr", "dw":"@physicalInfo.dw", "indicator_cd":"@physicalInfo.indicatorCd", "indicator_start_date":"@physicalInfo.indicatorStartDate", "memo":"@physicalInfo.memo", "pre_scale_upper":"@physicalInfo.preScaleUpper", "pre_scale_lower":"@physicalInfo.preScaleLower", "facility_cd": "@facilityCd", "target_weight": "@physicalInfo.targetWeight"}]'')
     ::jsonb 
    END 
WHERE
  pat_id = @patId 
  AND facility_cd = ''@facilityCd'' 
  AND is_del = ''0'''
  , "up_date" = CURRENT_TIMESTAMP 
WHERE
  "sql_cd" = 1703;

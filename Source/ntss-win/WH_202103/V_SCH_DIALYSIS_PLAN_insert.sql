INSERT INTO V_SCH_DIALYSIS_PLAN  VALUES (
'@patid',
'@dialysisDate',
'@bedNo',
'@bedName',
'@kurCd',
'@kurName',
'@plural',
to_date('@upDate','yyyy-mm-dd hh24:mi:ss'),
'@resultDialysisno',
'@opeIndPlan',
'@dummyFlg',
'@startTime'
);
INSERT INTO V_RST_DIALYSIS_ADD  VALUES (
'@patid',
'@dialysisDate',
'@dialysisNo',
'@ctlNo',
to_date('@upDate','yyyy-mm-dd hh24:mi:ss'),
'@effectFlg',
to_date('@effectDate','yyyy-mm-dd hh24:mi:ss'),
'@addition',
'@staffCd',
'@staffName'
);
INSERT INTO V_DIALYSIS_VITAL  VALUES (
'@patid',
to_date('@startDate','yyyy-mm-dd hh24:mi:ss'),
to_date('@occurDate','yyyy-mm-dd hh24:mi:ss'),
'@bpMax',
'@bpMin',
'@bpAve',
'@pulse',
'@temperature',
'@bloodSugarLevel',
to_date('@upDate','yyyy-mm-dd hh24:mi:ss'),
'@diadysisNo',
'@bpClass'
);
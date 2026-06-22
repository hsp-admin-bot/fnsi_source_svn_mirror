INSERT INTO V_DIALYSIS_COMP  VALUES (
'@patid',
to_date('@occurDate','yyyy-mm-dd hh24:mi:ss'),
'@measureclass',
'@reqcode',
'@complaint',
'@treatName',
'@medicineCd1',
'@medicineCd2',
'@medicineName',
'@amount',
'@unit',
'@procedureName',
'@procedureCd1',
'@procedureCd2',
'@treatPersonName',
to_date('@upDate','yyyy-mm-dd hh24:mi:ss')
);
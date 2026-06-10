SELECT 
 /*%expand "A" */*
FROM 
 sys_function A
WHERE 
 A.is_del = '0'
AND 
 A.is_disp = '1'
AND 
 A.is_nkk <> '1'
AND
 A.system_use_disp = '2'
;
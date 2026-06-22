SELECT  /*%expand "A" */*
FROM 
   sys_function A
WHERE 
   A.is_del = '0'
AND
   A.is_disp = '1'
AND
   function_cd = /*functionCd*/NULL
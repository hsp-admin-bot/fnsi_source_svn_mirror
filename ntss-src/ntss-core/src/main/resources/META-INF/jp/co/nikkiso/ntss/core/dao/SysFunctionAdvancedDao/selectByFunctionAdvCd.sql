SELECT  /*%expand "A" */*
FROM
  sys_function_advanced A
WHERE
  A.is_del = '0'
AND
  A.is_disp = '1'
AND
  A.function_adv_cd = /*functionAdvCd*/NULL
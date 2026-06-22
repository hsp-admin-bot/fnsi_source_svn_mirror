SELECT 
 /*%expand "A" */*
FROM 
 sys_function A
WHERE 
 A.is_del = /*isDel*/NULL
AND 
 A.is_disp = /*isDisp*/NULL
/*%if isNkkList != null && isNkkList.size() != 0 */
AND 
 A.is_nkk in /*isNkkList*/(NULL)
/*%end*/
/*%if systemUseDispList != null && systemUseDispList.size() != 0 */
AND
 A.system_use_disp in /*systemUseDispList*/(NULL)
/*%end*/
;
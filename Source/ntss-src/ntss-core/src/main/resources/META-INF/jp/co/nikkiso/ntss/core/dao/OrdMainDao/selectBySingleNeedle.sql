select
  ord_no
  FROM ord_main ord
 where
 1=1
 /*%if null != facilityCd */
  AND ord.facility_cd = /*facilityCd*/'000000'
/*%end*/
/*%if null != patId */
  AND ord.pat_id = /*patId*/'0'
/*%end*/
  AND TO_NUMBER (ind_cond_info->'12'->>'value','999999999999') = 1
   AND ord.rst_dialysis_state = '0'
AND ord.treat_date >= to_char(CURRENT_DATE, 'yyyymmdd')

;

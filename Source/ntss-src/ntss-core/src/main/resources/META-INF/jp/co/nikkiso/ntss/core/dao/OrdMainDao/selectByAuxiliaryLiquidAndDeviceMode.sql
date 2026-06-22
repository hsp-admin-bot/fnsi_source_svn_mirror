select
  ord_no
  FROM ord_main ord LEFT JOIN mst_treatment mst ON ord.ind_treatment_cd=mst.treatment_cd
 where
 ord.is_del = '0'
 /*%if null != facilityCd */
  AND ord.facility_cd = /*facilityCd*/'000000'
/*%end*/
/*%if null != patId */
  AND ord.pat_id = /*patId*/'0'
/*%end*/
/*%if null != deviceModeLiat */
  AND mst.device_mode in /*deviceModeLiat*/(null)
/*%end*/
  AND TO_NUMBER (ind_cond_info->'20'->>'value','999999999999.99999') > /*auxiliaryLiquid*/'0'
   AND ord.rst_dialysis_state = '0'
AND ord.treat_date >= to_char(CURRENT_DATE, 'yyyymmdd')

;

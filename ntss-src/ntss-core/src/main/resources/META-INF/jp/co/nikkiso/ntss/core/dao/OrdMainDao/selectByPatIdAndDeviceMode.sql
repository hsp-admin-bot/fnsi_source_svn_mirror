select
  ord_no
  FROM ord_main ord LEFT JOIN mst_treatment mst ON ord.ind_treatment_cd=mst.treatment_cd
 where
 1=1
 /*%if null != facilityCd */
  AND ord.facility_cd = /*facilityCd*/'000000'
/*%end*/
/*%if null != patId */
  AND ord.pat_id = /*patId*/'0'
/*%end*/
/*%if null != mode */
  AND mst.device_mode = /*mode*/'0'
/*%end*/
   AND ord.rst_dialysis_state = '0'
AND ord.treat_date >= to_char(CURRENT_DATE, 'yyyymmdd')

;

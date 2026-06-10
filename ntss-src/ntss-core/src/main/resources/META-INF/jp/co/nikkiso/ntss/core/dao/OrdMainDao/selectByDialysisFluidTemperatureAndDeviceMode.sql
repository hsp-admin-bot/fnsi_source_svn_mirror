select
    ord_no
FROM ord_main ord
where
    ord.is_del = '0'
    /*%if null != facilityCd */
  AND ord.facility_cd = /*facilityCd*/'000000'
/*%end*/
/*%if null != patId */
  AND ord.pat_id = /*patId*/'0'
/*%end*/
  AND (TO_NUMBER (ind_cond_info->'18'->>'value','999999999999.99999') > /*dstDialysisFluidTemperatureUp*/'0'
  OR TO_NUMBER (ind_cond_info->'18'->>'value','999999999999.99999') < /*dstDialysisFluidTemperatureDown*/'0')
  AND ord.rst_dialysis_state = '0'
  AND ord.treat_date >= to_char(CURRENT_DATE, 'yyyymmdd')

;

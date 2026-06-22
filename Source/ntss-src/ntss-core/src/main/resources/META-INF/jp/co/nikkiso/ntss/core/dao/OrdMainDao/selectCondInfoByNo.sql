select
  rst_cond_info #>> '{25,value_name_1}' as name,
  rst_cond_info #>> '{26,unit}' as unit,
  rst_cond_info #>> '{26,value}' as value1,
  rst_cond_info #>> '{27,value}' as value2,
  rst_cond_info #>> '{28,value}' as value3
from
  ord_main
where
  ord_no = /*ordNo*/11
;

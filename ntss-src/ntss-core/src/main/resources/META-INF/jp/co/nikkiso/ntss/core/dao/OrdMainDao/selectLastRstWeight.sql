select O.rst_weight_info
from ord_main O
  left outer join mst_treatment T on O.rst_treatment_cd = T.treatment_cd
where
  O.pat_id = /*patId*/0
/*%if currentOrdNo != null*/
  and
  O.ord_no <> /*currentOrdNo*/0
/*%end*/
  and
  O.rst_return_home_date < /*baseDate*/'2019/01/01 00:00:00'
  and
  O.is_del = '0'
/*%if tokushu != null*/
  -- 治療方法区別する
  and
  /*%if tokushu == 1*/
  -- 特殊浄化
  T.device_mode = 9
  /*%else*/
  -- 透析治療
  T.device_mode <> 9
  /*%end*/
/*%end*/
order by
  O.rst_return_home_date desc
limit 1
;
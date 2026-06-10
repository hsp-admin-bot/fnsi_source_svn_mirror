update ord_main
set ind_cond_info = (jsonb_set(ind_cond_info::jsonb,'{5,value}','null'::jsonb))
 where
/*%if null != ordNo */
  ord_no= /*ordNo*/0
/*%end*/
;

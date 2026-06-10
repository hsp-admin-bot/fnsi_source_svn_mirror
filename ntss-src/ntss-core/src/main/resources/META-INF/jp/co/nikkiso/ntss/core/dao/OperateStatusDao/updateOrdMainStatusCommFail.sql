update ord_main
set 
  /*%if "1" == status || "2" == status */
    rst_dialysis_state = case when rst_dialysis_state in ('0', '1') then /*status*/'' else rst_dialysis_state end
  /*%else */
    rst_dialysis_state = /*status*/''
  /*%end*/
  ,up_date = current_timestamp
where
 ord_no  = /*ord_no*/0

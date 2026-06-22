update ord_main
set 
  /*%if "1" == status || "2" == status */
    rst_dialysis_state = case when rst_dialysis_state in ('0', '1') then /*status*/'' else rst_dialysis_state end
  /*%else */
    rst_dialysis_state = /*status*/''
  /*%end*/
  /*%if updateDateFlag */
  ,
  rst_cond_send_date = query1.cond_send_date
  /*%end*/
  ,up_date = current_timestamp
from
  (
	  select
	    mst.cond_send_date as cond_send_date
	  from
	    mnt_machine_state mst,ord_main ord
	  where
	    mst.facility_cd = ord.facility_cd
	    and
	    mst.bed_cd = ord.ind_bed_cd
	    and
	    ord.ord_no = /*ord_no*/0
  ) query1
where
 ord_no  = /*ord_no*/0

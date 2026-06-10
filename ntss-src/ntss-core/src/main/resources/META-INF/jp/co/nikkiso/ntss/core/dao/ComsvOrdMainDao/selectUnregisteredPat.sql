select
  ord_no, pat_id
from
  ord_main
where
  facility_cd = /*param.facilityCd*/'000001' and
  rst_machine_no = /*param.rstMachineNo*/1 and
  rst_start_date = /*param.startDate*/'1970/01/01 00:00:00'
order by
  ord_no desc
limit 1
;

select
  ord_no, pat_id
from
  ord_main
where
  facility_cd = /*param.facilityCd*/'000001' and
  rst_machine_no = /*param.rstMachineNo*/1 and
  (pat_id = /*param.patId*/null or pat_id is null )
order by
  ord_no desc
limit 1
;

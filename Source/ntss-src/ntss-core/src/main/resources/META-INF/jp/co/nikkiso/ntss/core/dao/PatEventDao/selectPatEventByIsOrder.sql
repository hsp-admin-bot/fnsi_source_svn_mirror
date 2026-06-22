select
  om.ord_no,
  A.pat_event_cd as key,
  A.bbs_ctl_no as data
from pat_event A,
    (
      select facility_cd,
           ord_no,
           pat_id,
           treat_date
    from ord_main
    where facility_cd = /*facilityCd*/null
      and pat_id = /*pat_id*/1
      and treat_date >= /*dialysis_date_from*/'20180220'
      and treat_date <= /*dialysis_date_to*/'20180226'
      and is_del  = '0'
    ) om
where
  A.facility_cd = om.facility_cd
  and A.pat_id = om.pat_id
  and (A.event_start_date = om.treat_date
  or A.ord_no = om.ord_no)
  and A.is_del  = '0'
;

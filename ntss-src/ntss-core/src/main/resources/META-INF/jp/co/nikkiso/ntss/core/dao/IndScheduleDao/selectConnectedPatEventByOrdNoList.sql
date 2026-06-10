select
  om.ord_no,
  A.pat_event_cd as key,
  A.bbs_ctl_no as data
from pat_event A
inner join ord_main om
  on A.pat_id = om.pat_id
  and om.facility_cd = /*facilityCd*/null
  and om.ord_no in /*ordNoList*/(null)
  and om.is_del = '0'
where
   A.is_del = '0'
  and (
        A.event_start_date = om.treat_date
        or A.ord_no = om.ord_no
      )
;

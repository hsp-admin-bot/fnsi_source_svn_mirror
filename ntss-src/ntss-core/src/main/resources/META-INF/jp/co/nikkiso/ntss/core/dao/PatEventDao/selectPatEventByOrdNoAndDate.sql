select
	pe.pat_event_cd,
	pe.event_start_date,
	pe.event_end_date,
    pe.ord_no
from pat_event pe
where
    pe.facility_cd =/*facilityCd*/'999998'
  and pe.pat_id = /*patId*/1619
  and pe.event_start_date >= /*eventStartDate*/'20200404'
  and pe.event_start_date <= /*eventEndDate*/'20200404'
  and pe.is_del = '0'
  and pe.is_newest = '1'
UNION ALL
select
    pe.pat_event_cd,
    pe.event_start_date,
    pe.event_end_date,
    pe.ord_no
from pat_event pe
where
      pe.facility_cd =/*facilityCd*/'999998'
  and pe.pat_id = /*patId*/1619
  and pe.event_start_date < /*eventStartDate*/'20200404'
  and pe.event_start_date > /*eventEndDate*/'20200404'
  and pe.ord_no in /* ordNoList */(1,2,3)
  and pe.is_del = '0'
  and pe.is_newest = '1'

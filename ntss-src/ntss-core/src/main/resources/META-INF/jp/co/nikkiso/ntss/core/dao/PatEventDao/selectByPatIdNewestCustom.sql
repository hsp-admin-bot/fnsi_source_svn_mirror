select
    A.pat_event_cd
  , A.pat_id
  , A.facility_cd
  , A.fn_ctl_no
  , A.event_status
  , A.template_cd
  , A.template_name
  , A.category_cd
  , A.category_name
  , A.use_type
  , A.ord_no
  , A.input_params
  , substring(to_timestamp(A.event_start_date, 'YYYYMMDD')::text, 1, 10) as event_start_date
  , substring(to_timestamp(A.event_end_date, 'YYYYMMDD')::text, 1, 10) as event_end_date
  , replace(substring(to_timestamp(A.event_start_date, 'YYYYMMDD')::text, 1, 10), '-', '/') as str_event_date
  , A.sub_category_cd
  , A.sub_category_name
  , A.result_params
  , A.score_total
  , A.reg_staff_info
  , A.up_staff_info
  , A.bbs_ctl_no
  , A.is_newest
  , A.is_del
  , A.reg_date
  , A.up_date
from
  pat_event A
where
  A.pat_id = /*patId*/0
  /*%if startEventDate != null */
  and replace(event_start_date, '-', '/' ) >= /*startEventDate*/'1970/01/01'
  /*%end */
  /*%if endEventDate != null */
  and replace(event_start_date, '-', '/' ) <= /*endEventDate*/'2099/12/31'
  /*%end */
  and is_newest = '1'
  and is_del = '0'
order by
  event_start_date desc
;

select
  A.pat_event_cd,
  A.pat_id,
  A.facility_cd,
  A.fn_ctl_no,
  A.event_status,
  A.template_cd,
  A.template_name,
  A.category_cd,
  A.category_name,
  A.ord_no,
  A.input_params,
  substring(to_timestamp(A.event_start_date, 'YYYYMMDD')::text, 1, 10) as event_start_date,
  substring(to_timestamp(A.event_end_date, 'YYYYMMDD')::text, 1, 10) as event_end_date,
  CASE
    WHEN A.event_start_time is null THEN null
    WHEN 
      A.event_start_time is not null 
    THEN 
      concat(substring(A.event_start_time, 1, 2),':', substring(A.event_start_time, 3, 2)) 
  END as event_start_time,
  CASE
    WHEN A.event_end_time is null THEN null
    WHEN 
      A.event_end_time is not null 
    THEN 
      concat(substring(A.event_end_time, 1, 2),':', substring(A.event_end_time, 3, 2)) 
  END as event_end_time,
  A.sub_category_cd,
  A.sub_category_name,
  A.result_params,
  A.score_total,
  A.reg_staff_info,
  A.up_staff_info,
  A.bbs_ctl_no,
  A.is_newest,
  A.is_del,
  A.reg_date,
  A.up_date,
  A.letter_info
from
  pat_event A
where
  A.pat_event_cd = /*pat_event_cd*/0
;

SELECT * 
  FROM (select
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
    A.letter_info,
    A.report_url,
    A.report_date,
    B.facility_name,
    A.use_type
  from
    pat_event A
    left join mst_facility B on
    A.facility_cd = B.facility_cd
  where
    A.facility_cd = /*facilityCd*/'1'
    and A.pat_id = /*patId*/0
    and A.is_newest = '1'
    and A.is_del = '0'
    AND
    (
      (
        1=1
        /*%if startEventDate != null */
        AND to_timestamp(A.event_start_date, 'YYYYMMDD') >= /*startEventDate*/'1999/01/01 00:00:00'
        /*%end */
        /*%if endEventDate != null */
        AND to_timestamp(A.event_start_date, 'YYYYMMDD') <= /*endEventDate*/'2112/09/03 23:59:59'
        /*%end */
      )
      /*%if patEventCdList != null */
      or A.pat_event_cd in /* patEventCdList */(null)
      /*%end */
    )
  UNION ALL
  select
    C.pat_event_cd,
    C.pat_id,
    C.facility_cd,
    C.fn_ctl_no,
    C.event_status,
    C.template_cd,
    C.template_name,
    C.category_cd,
    C.category_name,
    C.ord_no,
    C.input_params,
    substring(to_timestamp(C.event_start_date, 'YYYYMMDD')::text, 1, 10) as event_start_date,
    substring(to_timestamp(C.event_end_date, 'YYYYMMDD')::text, 1, 10) as event_end_date,
    CASE
      WHEN C.event_start_time is null THEN null
      WHEN
        C.event_start_time is not null
      THEN
        concat(substring(C.event_start_time, 1, 2),':', substring(C.event_start_time, 3, 2))
    END as event_start_time,
    CASE
      WHEN C.event_end_time is null THEN null
      WHEN
        C.event_end_time is not null
      THEN
        concat(substring(C.event_end_time, 1, 2),':', substring(C.event_end_time, 3, 2))
    END as event_end_time,
    C.sub_category_cd,
    C.sub_category_name,
    C.result_params,
    C.score_total,
    C.reg_staff_info,
    C.up_staff_info,
    C.bbs_ctl_no,
    C.is_newest,
    C.is_del,
    C.reg_date,
    C.up_date,
    C.letter_info,
    C.report_url,
    C.report_date,
    D.facility_name,
    C.use_type
  from
    pat_event C
    left join mst_facility D on
    C.facility_cd = D.facility_cd
  where
    1 = 1
    /*%if !patEventList.isEmpty() */
    AND (C.facility_cd,C.pat_id) IN (
      /*%for condition:patEventList */
        (/* condition.facilityCd */NULL, /* condition.patId */NULL)
        /*%if condition_has_next */
          ,
        /*%end */
      /*%end */
    )
    /*%end */
    and C.is_newest = '1'
    and C.is_del = '0'
    AND
    (
      (
        1=1
        /*%if startEventDate != null */
        AND to_timestamp(C.event_start_date, 'YYYYMMDD') >= /*startEventDate*/'1999/01/01 00:00:00'
        /*%end */
        /*%if endEventDate != null */
        AND to_timestamp(C.event_start_date, 'YYYYMMDD') <= /*endEventDate*/'2112/09/03 23:59:59'
        /*%end */
      )
      /*%if patEventCdList != null */
      or C.pat_event_cd in /* patEventCdList */(null)
      /*%end */
    )
  ) AS combined
order by
  event_start_date desc,
  pat_event_cd desc,
  pat_id desc
;

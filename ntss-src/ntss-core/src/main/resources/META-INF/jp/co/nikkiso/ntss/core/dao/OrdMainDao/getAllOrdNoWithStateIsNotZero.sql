with max_ctl_no_data as (select *
                         from (select pat_id,
                                      ctl_no,
                                      exam_date,
                                      ROW_NUMBER() OVER (PARTITION BY pat_id ORDER BY ctl_no DESC nulls last) AS rn
                               from (select pat_id,
                                            (jsonb_array_elements(physical_info) ->> 'ctl_no')::int as ctl_no,
                                            jsonb_array_elements(physical_info) ->> 'exam_date'     as exam_date
                                     from pat_unique) t) t1
                         where t1.rn = '1' and pat_id in /*patIdList*/(null)),
     max_exam_date_list as (select *
                            from (select pat_id,
                                         exam_date,
                                         ROW_NUMBER() OVER (PARTITION BY pat_id ORDER BY exam_date DESC) AS rn
                                  from (select pat_id,
                                               jsonb_array_elements(physical_info) ->> 'exam_date' as exam_date
                                        from pat_unique) t) t1
                            where t1.rn = '1' and pat_id in /*patIdList*/(null)),
     get_pat_id_and_check_res as (select mc.pat_id, (mc.exam_date = me.exam_date) as check_res
                                  from max_ctl_no_data mc,
                                       max_exam_date_list me
                                  where mc.pat_id = me.pat_id)
SELECT ord_no, om.pat_id, treat_date, om.facility_cd as facility_cd
FROM ord_main om,
     get_pat_id_and_check_res gp
where om.pat_id = gp.pat_id
  and om.treat_date >= to_char(now(), 'YYYY-MM-DD')
  and om.ind_kur_cd <> '0'
  and gp.check_res

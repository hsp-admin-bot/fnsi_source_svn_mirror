select
  om.ord_no,
  A.exam_main_cd as key,
  to_timestamp(om.treat_date, 'YYYYMMDD') as treat_date
from pat_exam_main A
inner join ord_main om
  on A.facility_cd = om.facility_cd
 and A.pat_id = om.pat_id
 and om.facility_cd = /*facilityCd*/null
 and om.ord_no in /*ordNoList*/(null)
 and om.is_del = '0'
where
  A.is_del = '0'
  and A.is_order = '1'
  and A.reg_exam_date::date = to_timestamp(om.treat_date, 'YYYYMMDD')::date
  and not exists (
    select 1
    from pat_exam_main B
    where B.pat_id = A.pat_id
      and B.is_del = '0'
      and B.exam_result_info IS NOT NULL
      and B.exam_result_info != '[]'::jsonb
      and A.reg_exam_date::date = B.result_exam_date::date
  )
;

select
  om.ord_no,
  A.rad_result_cd as key,
  to_timestamp(om.treat_date, 'YYYYMMDD') as treat_date
from pat_rad_main A
inner join ord_main om
  on A.facility_cd = om.facility_cd
 and A.pat_id = om.pat_id
 and om.facility_cd = /*facilityCd*/null
 and om.ord_no in /*ordNoList*/(null)
 and om.is_del = '0'
where
  A.is_del = '0'
  and A.reg_rad_date::date = to_date(om.treat_date, 'YYYYMMDD')
  and not exists (
    select 1
    from pat_rad_main B
    where B.pat_id = A.pat_id
      and B.is_del = '0'
      and B.rad_status = '1'
      and B.reg_rad_date::date = A.reg_rad_date::date
  )
;

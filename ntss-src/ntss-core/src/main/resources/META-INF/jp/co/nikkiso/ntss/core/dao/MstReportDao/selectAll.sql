(select
  --/*%expand */*
  report_cd
,facility_cd
,report_name
,report_path
,report_class
,is_disp
,is_del
,reg_date
,up_date
,report_type
,extraction_condition
,default_printer
,additional_info
,disp_order
,report_hst_info
from
  mst_report
where
  facility_cd = /*facilityCd*/null
  and is_del = '0' and disp_order<>0
order by disp_order asc, report_class, report_name, is_del, is_disp desc, report_cd)
union all
(select
  --/*%expand */*
  report_cd
,facility_cd
,report_name
,report_path
,report_class
,is_disp
,is_del
,reg_date
,up_date
,report_type
,extraction_condition
,default_printer
,additional_info
,disp_order
,report_hst_info
from
  mst_report
where
  facility_cd = /*facilityCd*/null
  and is_del = '0' and disp_order = 0
order by disp_order asc, report_class, report_name, is_del, is_disp desc, report_cd)
;

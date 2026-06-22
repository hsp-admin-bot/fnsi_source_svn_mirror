/** 患者IDと治療日を指定して治療実績(確定)を収集 */
select
  /*%expand "om" */*
from
  ord_main as om
where
  om.pat_id = /* patId */21
  /*%if specifyDate != null */
  and om.treat_date = /* specifyDate */''
  /*%else */
  and om.treat_date between /* fromDate */'' and /* toDate */''
  /*%end */
  and rst_dialysis_state = '6'
  and om.is_del = '0'
order by
  om.treat_date desc, om.ind_treat_start_time desc NULLS LAST, om.rst_start_date desc NULLS LAST
;
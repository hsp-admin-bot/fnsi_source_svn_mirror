/** 患者IDと治療日から治療データを収集 */
select
  /*%expand "om" */*
from
  ord_main as om
where
  om.pat_id in /*patIds*/(null)
  /*%if specifyDate != null */
  and om.treat_date = /* specifyDate */''
  /*%else */
  and om.treat_date between /* fromDate */'' and /* toDate */''
  /*%end */
  and om.is_del = '0'
order by
  om.treat_date asc, om.ind_treat_start_time desc NULLS LAST, om.rst_start_date desc NULLS LAST
;

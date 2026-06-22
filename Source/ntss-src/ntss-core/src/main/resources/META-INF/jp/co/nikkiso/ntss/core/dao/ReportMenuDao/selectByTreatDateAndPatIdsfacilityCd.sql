-- mod 10546 複数集計出力時にサーバが高負荷になる gjn start
/** 日付を指定して治療実績(確定)+治療指示（治療日指定なし）を収集 */
select
    om.ord_no,
	om.pat_id,
	om.treat_date
from
  ord_main as om
where
  om.pat_id in /* patIds */(null)
  and om.facility_cd = /* facilityCd */null
  and om.is_del = '0'
  /*%if specifyDate != null */
  and om.treat_date = /* specifyDate */''
  /*%else */
  and om.treat_date between /* fromDate */'' and /* toDate */''
  /*%end */
-- order by
--  om.treat_date, om.ind_treat_start_time NULLS LAST, om.rst_start_date NULLS LAST
;
-- mod 10546 複数集計出力時にサーバが高負荷になる gjn end

select
  /*%expand "A" */*
from
  mst_dialyzer A
where
  /*%if dialyzerList.size() > 0 */
  dialyzer_cd in /* dialyzerList */(null)
  /*%end*/
  and is_del = '0'
order by
  dialyzer_cd
;

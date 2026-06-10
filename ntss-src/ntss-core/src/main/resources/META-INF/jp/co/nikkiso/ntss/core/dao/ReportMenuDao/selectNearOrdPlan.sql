-- 指定日からの直近1件の治療予定を取得する
select
  /*%expand "om" */*
from
  ord_main as om
where
  om.pat_id = /* patId */0
  and om.is_del = '0'
  and om.treat_date >= /*treatDate*/''
order by
  om.treat_date
  limit 1
;
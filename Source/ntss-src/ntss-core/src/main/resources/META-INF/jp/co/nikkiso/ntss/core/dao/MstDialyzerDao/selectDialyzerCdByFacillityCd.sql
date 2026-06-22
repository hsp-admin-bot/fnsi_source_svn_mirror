-- add 10546 複数集計出力時にサーバが高負荷になる gjn start
select
  A.dialyzer_cd
from
  mst_dialyzer A
where
  A.is_del = '0'
and
  A.facility_cd = /*facilityCd*/'009999'
;
-- add 10546 複数集計出力時にサーバが高負荷になる gjn end

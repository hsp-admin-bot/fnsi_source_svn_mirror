select
  /*%expand "A" */*
from
  mst_dialyzer A
where
    dialyzer_cd = /* dialyzerCd */0
and
    is_del = '0'

;

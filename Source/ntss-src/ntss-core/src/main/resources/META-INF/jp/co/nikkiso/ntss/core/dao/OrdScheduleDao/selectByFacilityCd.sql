select
  /*%expand "A"*/*
from
  ord_schedule as A
where
  is_dummy = '1'
  and facility_cd = /* facilityCd */null
  and bed_cd = /* bedCd */null
  and treat_date >= to_char(now(), 'YYYYMMDD');

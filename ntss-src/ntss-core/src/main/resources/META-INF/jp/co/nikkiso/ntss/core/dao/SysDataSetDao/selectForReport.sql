select
  /*%expand "A" */*
from
  sys_data_set A
where
  ((A.use_application -> 'applications' @> '[1]'::jsonb) = True) or (A.use_application is null)
order by
  A.sql_cd
;

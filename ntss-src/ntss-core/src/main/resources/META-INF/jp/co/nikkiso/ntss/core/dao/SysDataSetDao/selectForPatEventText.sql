select
  /*%expand "A" */*
from
  sys_data_set A
where
  ((A.use_application -> 'applications' @> '[3]'::jsonb) = True)
order by sql_cd
;

select
  /*%expand "A" */*
from
  sys_data_list_category A
where
  template_cd = /*templateCd*/0
;
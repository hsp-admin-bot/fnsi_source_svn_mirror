select
  /*%expand "A" */*
from
  sys_data_list_detail A
where
  data_list_detail_cd = /*sysDataListDetailCd*/0
;
select
  /*%expand  "A" */*
from
  mst_user A
where
  user_id in /* userIdList*/(0)
;

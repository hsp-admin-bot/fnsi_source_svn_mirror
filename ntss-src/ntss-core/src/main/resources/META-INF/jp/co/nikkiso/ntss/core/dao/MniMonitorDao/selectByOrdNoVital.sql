select
  /*%expand "A" */*
from
  mni_monitor as A
where
  bio_moni_ctl_no = (
    select
      max(bio_moni_ctl_no)
    from mni_monitor as B
    where A.data_type = B.data_type and occur_date = (
      select max(occur_date)
      from mni_monitor AS B
      where A.data_type = B.data_type
    )
  ) and
  A.ord_no = /*ordNo*/1 and
  is_del = '0' and
  (A.data_type = 5 or A.data_type = 6)
order by
  data_type
;

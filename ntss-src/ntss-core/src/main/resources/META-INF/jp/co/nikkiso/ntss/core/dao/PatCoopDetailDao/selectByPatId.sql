select
  /*%expand */*
from
  pat_coop_detail
where
  facility_cd = /*facilityCd*/''
-- add 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  and coop_version = /*coopVersion*/''
-- add 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
and
  pat_id = /*patId*/0
and
  is_del = '0'
order by up_date desc
limit 1
;

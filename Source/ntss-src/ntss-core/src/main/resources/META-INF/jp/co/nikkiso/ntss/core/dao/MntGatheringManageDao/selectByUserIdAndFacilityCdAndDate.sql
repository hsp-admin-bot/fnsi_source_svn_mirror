select
  gathering_status
from
  mnt_gathering_manage
where
  facility_cd = /*facilityCd*/'1'
and
  user_id = /*userId*/1
and
  to_char(up_date, 'yyyyMMdd') = /*targetDate*/'99999999'
order by up_date desc
limit 1
;

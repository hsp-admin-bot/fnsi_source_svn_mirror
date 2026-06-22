select
  /*%expand */*
from
  ord_main
WHERE
  facility_cd = /*facilityCd*/'999999'
AND is_del='0'
order by
-- mod 2021-11-12 #5896:SSI連携ができない(オーダ受け) 孫 start
--  reg_date DESC
  reg_date DESC NULLS LAST
-- mod 2021-11-12 #5896:SSI連携ができない(オーダ受け) 孫 end
limit 1
;

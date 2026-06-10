select
  scale_value
from
	ord_weight_scale
where
  pat_id = /*patId*/'000001'
and
  facility_cd = /*facilityCd*/'000001'
order by
  reg_date desc,
  up_date desc
limit 1
;

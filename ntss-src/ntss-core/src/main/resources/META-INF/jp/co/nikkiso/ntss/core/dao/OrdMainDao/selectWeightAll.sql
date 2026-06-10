select
  O.treat_date,
  O.rst_weight_info ->> 'ctr' as ctr,
  O.rst_weight_info ->> 'ctr_weight' as ctr_weight
from
  ord_main O
left outer join mst_treatment T on O.rst_treatment_cd = T.treatment_cd
where
  O.pat_id = /*patId*/1
and
  O.is_del = '0'
and
  T.device_mode <> 9
order by
  O.treat_date desc,
  O.ord_no desc
limit 100
;

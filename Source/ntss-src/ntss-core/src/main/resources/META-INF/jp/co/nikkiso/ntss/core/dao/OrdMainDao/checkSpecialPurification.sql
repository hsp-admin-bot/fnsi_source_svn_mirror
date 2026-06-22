select 
case
-- modify by chamaojia 2025-02-27 [11471] The value of 【rst】 does not need to be associated --start
--     when device_mode = '9'  then true
--     when device_mode != '9'  then false
    when rst_device_mode = '9'  then true
    when rst_device_mode != '9'  then false
end
from 
  ord_main om
-- inner join 
--   mst_treatment mt
-- on 
--   om.rst_treatment_cd = mt.treatment_cd
-- modify by chamaojia 2025-02-27 [11471] The value of 【rst】 does not need to be associated --end
where 
  om.ord_no = /*ordNo*/'0'
;
select
      /*%expand "A" */*
from
      client_cer_facility A
where
      A.facility_cd = /*facilityCd*/'a'
      and is_delete ='0'

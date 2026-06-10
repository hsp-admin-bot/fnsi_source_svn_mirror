select
  facility_cd
from
  mst_facility
where
  /*%if keyWord != null && searchFlag */
    facility_name  like /* keyWord */null
  /*%elseif keyWord != null && !searchFlag */
    facility_name  not like /* keyWord */null
  /*%end*/
order by
  facility_cd;

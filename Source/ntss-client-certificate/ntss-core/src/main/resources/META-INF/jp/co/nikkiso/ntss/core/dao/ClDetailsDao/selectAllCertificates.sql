select
  A.facility_cd,
  A.max_download,
  A.cur_download,
  A.latest_issued_user,
  A.expired_date,
  B.facility_count
from
  client_cer_detail A,
	(select
	   many_facility_cd,
	   count(1) as facility_count
   from
	   client_cer_detail
   where
	   is_delete ='0'
   group by
	   many_facility_cd) B
where A.is_delete ='0'
  and A.facility_cd = B.many_facility_cd

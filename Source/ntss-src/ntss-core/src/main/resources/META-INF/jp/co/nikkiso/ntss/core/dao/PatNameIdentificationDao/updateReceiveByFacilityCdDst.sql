update 
  pat_name_identification
set
  receive = /* updateData */null, 
  up_date = now()
where
/*%if facilityCdList != null && facilityCdList.size() != 0 */
  facility_cd_dst in /*facilityCdList*/('000001')
/*%end */
;
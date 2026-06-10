update 
  pat_name_identification
set
  approve = /* updateData */null, 
  up_date = now()
where
/*%if facilityCdList != null && facilityCdList.size() != 0 */
  facility_cd_src in /*facilityCdList*/('000001')
/*%end */
;
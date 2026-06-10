update
  mnt_if_edge_manage
set
  response_status = /*responseStatus*/null,
  up_date = CURRENT_TIMESTAMP
where
  facility_cd in /*facilityCdList*/('000001')
/*%if currentResponseStatus != null  */
  and response_status = /*currentResponseStatus*/null
/*%end */
;
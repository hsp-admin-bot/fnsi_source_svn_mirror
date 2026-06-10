update pat_rad_main
set
    is_del = '1',
    up_date = CURRENT_TIMESTAMP,
    up_staff = /* upStaff */null,
    ind_user_id = /* indUserId */null
where
    is_del = '0'
  and
    pat_id = /* patId */null
  and
    facility_cd = /* facilityCd */null
  and
    is_lock = '0'
  and
    rad_status = '0'
  and
    rad_result_cd in /* radResultCdList */(null)
;

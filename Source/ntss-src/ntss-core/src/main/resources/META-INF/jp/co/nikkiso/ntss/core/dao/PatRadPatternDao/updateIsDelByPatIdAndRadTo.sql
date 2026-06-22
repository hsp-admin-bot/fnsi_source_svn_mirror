update pat_rad_pattern
set
    is_del = '1',
    up_date = CURRENT_TIMESTAMP,
    up_staff = /* userId */null,
    ind_user_id = /* indUserId */null
where
    is_del = '0'
  and
    pat_id = /* patId */null
  and
    facility_cd = /* facilityCd */null
  and
    rad_to >= /* indStartDate */null
  and
    rad_to <= /* indEndDate */null
;

UPDATE pat_exam_main
set is_del = '1',
    up_date = CURRENT_TIMESTAMP,
    up_staff = /* upStaff */null,
    ind_user_id = /* indUserId */null
 where
        pat_id = /* patId */null
  and
        facility_cd = /* facilityCd */null
  and
        is_order = '1'
  and
        is_del = '0'
  and
        is_lock = '0'
  and
        exam_status = '0'
  and
        result_exam_date IS NULL
  and
        exam_main_cd in /* examMainCdList */(null)
;

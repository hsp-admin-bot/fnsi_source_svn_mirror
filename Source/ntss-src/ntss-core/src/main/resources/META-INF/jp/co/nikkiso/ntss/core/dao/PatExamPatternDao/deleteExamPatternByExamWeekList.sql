update pat_exam_pattern
set
    is_del = '1',
    up_date = CURRENT_TIMESTAMP,
    ind_user_id = /*indUserId*/0,
    up_staff = /*updUserId*/0
where
    facility_cd = /* facilityCd */null
  and
    pat_id = /* patId */null
  and
    exam_week IN /*examWeekList*/(null)
  and
    is_del = '0'
RETURNING pat_exam_pattern.*

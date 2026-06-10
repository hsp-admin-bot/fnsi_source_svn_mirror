update 
  mst_user 
set
  is_consent = 1,
  consent_date = CURRENT_TIMESTAMP(3)
where 
  user_id = /*userId*/0
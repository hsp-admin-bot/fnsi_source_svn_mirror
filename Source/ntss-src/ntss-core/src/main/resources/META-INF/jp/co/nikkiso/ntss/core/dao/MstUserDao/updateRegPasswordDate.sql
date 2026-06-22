update 
  mst_user 
set
  reg_password_date = CURRENT_TIMESTAMP(3)
where 
  user_id = /*userId*/0
update
  mst_personal_user
set
  user_last_name = personal_info_encrypt(/*mstPersonalUser.userLastName*/'1'),
  user_first_name = personal_info_encrypt(/*mstPersonalUser.userFirstName*/'1')
where
  user_id = /*mstPersonalUser.userId*/1
;

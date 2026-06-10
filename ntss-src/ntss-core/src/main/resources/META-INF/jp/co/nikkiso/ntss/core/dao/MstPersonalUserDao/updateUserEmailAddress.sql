update
  mst_personal_user
set
/*%if mstPersonalUser.userEmailAddress1 != null */
  user_email_address_1 = null
/*%else*/
  user_email_address_2 = null
/*%end*/
where
  user_id = /*mstPersonalUser.userId*/1
;

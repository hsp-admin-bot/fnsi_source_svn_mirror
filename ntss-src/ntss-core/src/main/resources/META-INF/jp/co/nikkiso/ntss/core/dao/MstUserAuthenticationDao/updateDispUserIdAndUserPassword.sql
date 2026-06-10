UPDATE
  mst_user_authentication
SET
   disp_user_id = /*mstUserAuthentication.dispUserId*/'1'
  ,up_date = /*mstUserAuthentication.upDate*/'2019-03-01 00:00:00'
/*%if mstUserAuthentication.userPassword != null */
  ,user_password = /*mstUserAuthentication.userPassword*/'password'
/*%end*/
/*%if mstUserAuthentication.userPasswordHistory != null */
  ,user_password_history = /*mstUserAuthentication.userPasswordHistory*/null
/*%end*/
WHERE
  user_id = /*mstUserAuthentication.userId*/'1'
;

select
  user_id,
  user_type,
  personal_info_decrypt(user_email_address_1) as user_email_address_1,
  personal_info_decrypt(user_email_address_2) as user_email_address_2
from
  mst_personal_user
where
  is_del = '0'
  /*%if addressList.size() > 0 */
  and
  user_email_address_1 in /* addressList */(null) or
  user_email_address_2 in /* addressList */(null)
  /*%end*/
;

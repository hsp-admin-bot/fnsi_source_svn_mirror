select
  personal_info_decrypt(user_last_name) || ' ' || personal_info_decrypt(user_first_name) AS user_name
from
  mst_personal_user
where
  user_id = /*userId*/1
;

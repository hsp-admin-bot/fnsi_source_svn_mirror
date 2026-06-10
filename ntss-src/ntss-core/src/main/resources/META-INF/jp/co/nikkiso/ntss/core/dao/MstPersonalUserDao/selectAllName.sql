select
  user_id,
  personal_info_decrypt(A.user_last_name) as user_last_name,
  personal_info_decrypt(A.user_first_name) as user_first_name
from
  mst_personal_user A
where
  A.user_id in /* patIds */(null)

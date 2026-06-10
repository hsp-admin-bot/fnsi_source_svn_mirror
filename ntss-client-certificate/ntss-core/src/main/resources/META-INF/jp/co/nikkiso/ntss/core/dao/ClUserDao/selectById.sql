SELECT user_name,
       user_id,
       user_role,
       user_pass,
       reg_date,
       up_date,
       is_delete,
       department_cd,
       num_login_attempt
FROM client_cer_user
WHERE is_delete = '0'
  AND user_id = /*userId*/'asd';
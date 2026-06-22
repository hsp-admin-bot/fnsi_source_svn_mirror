UPDATE client_cer_user
SET 
    num_login_attempt = /*numLoginAttempt*/NULL,
    up_date = CURRENT_TIMESTAMP
WHERE user_id = /*userId*/1;


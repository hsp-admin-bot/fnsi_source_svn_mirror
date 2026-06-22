insert into client_cer_user 
    (user_id, 
    user_name, 
    user_role, 
    department_cd, 
    reg_date, up_date, 
    is_delete, user_pass, 
    num_login_attempt)
values
    (/*userId*/NULL,
    /*userName*/NULL, 
    /*userRole*/null, 
    /*departmentCd*/null,
    TO_TIMESTAMP(/*regDate*/null, 'YYYY-MM-DD HH24:MI:SS'),
    TO_TIMESTAMP(/*upDate*/null, 'YYYY-MM-DD HH24:MI:SS'),   
    '0',
    /*userPass*/NULL,
    /*numLoginAttempt*/NULL)
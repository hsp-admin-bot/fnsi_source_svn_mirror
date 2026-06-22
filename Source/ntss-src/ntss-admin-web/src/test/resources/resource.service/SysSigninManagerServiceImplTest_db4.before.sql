DELETE FROM mst_user_authentication;
-- selectForLogin, selectDispUserId
INSERT INTO mst_user_authentication (user_id, facility_cd, disp_user_id, user_password, failure_cnt, reg_date, up_date)
VALUES
  (1, 'test', 'userAccount', 'password', 2, '2018-05-25 17:16:55', '2018-08-22 17:19:19.405'),
  (2, 'test', 'userAccount2', 'password', 0, '2018-05-25 17:16:55', '2018-08-22 17:19:19.405'),
  (9, 'test9', 'userAccount9', 'password9', 9, '2018-05-25 17:16:55', '2018-08-22 17:19:19.405');

DELETE FROM mst_user_authentication
WHERE user_id = 90302;

INSERT INTO mst_user_authentication(
user_id,
facility_cd,
disp_user_id,
user_password,
failure_cnt
) VALUES (
90302,
'F_h302',
'EGMAIN00',
'',
0
);

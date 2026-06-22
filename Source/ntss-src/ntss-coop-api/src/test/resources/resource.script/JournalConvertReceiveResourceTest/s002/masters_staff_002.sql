DELETE FROM mst_user_authentication
WHERE user_id = 90002;

INSERT INTO mst_user_authentication(
user_id,
facility_cd,
disp_user_id,
user_password,
failure_cnt
) VALUES (
90002,
'F_h002',
'EGMAIN00',
'',
0
);

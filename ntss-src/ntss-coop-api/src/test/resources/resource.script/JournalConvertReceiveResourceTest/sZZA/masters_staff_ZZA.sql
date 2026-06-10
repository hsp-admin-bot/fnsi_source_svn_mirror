DELETE FROM mst_user_authentication
WHERE user_id = 99000;

INSERT INTO mst_user_authentication(
user_id,
facility_cd,
disp_user_id,
user_password,
failure_cnt
) VALUES (
99000,
'F_hZZA',
'EGMAIN00',
'',
0
);

DELETE FROM mst_user_authentication
WHERE user_id > 30000;

INSERT INTO mst_user_authentication(
user_id,
facility_cd,
disp_user_id,
user_password,
failure_cnt
) VALUES (
700000,
'F_hN00',
'EGMAIN00',
'',
0
);

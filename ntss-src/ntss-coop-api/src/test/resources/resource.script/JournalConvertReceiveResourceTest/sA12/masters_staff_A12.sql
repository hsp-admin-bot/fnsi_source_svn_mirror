DELETE FROM mst_user_authentication
WHERE user_id = 98012;

INSERT INTO mst_user_authentication(
user_id,
facility_cd,
disp_user_id,
user_password,
failure_cnt
) VALUES (
98012,
'F_hA12',
'EGMAIN00',
'',
0
);

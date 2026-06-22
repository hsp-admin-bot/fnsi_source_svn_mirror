DELETE FROM mst_user_authentication
WHERE user_id > 30000;

INSERT INTO mst_user_authentication(
user_id,
facility_cd,
disp_user_id,
user_password,
failure_cnt
) VALUES (
700010,
'F_hN10',
'EGMAIN00',
'',
0
);

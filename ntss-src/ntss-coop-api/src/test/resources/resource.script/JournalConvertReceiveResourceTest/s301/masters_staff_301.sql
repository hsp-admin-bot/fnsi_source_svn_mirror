DELETE FROM mst_user_authentication
WHERE user_id = 90301;

INSERT INTO mst_user_authentication(
user_id,
facility_cd,
disp_user_id,
user_password,
failure_cnt
) VALUES (
90301,
'F_h301',
'EGMAIN00',
'',
0
);

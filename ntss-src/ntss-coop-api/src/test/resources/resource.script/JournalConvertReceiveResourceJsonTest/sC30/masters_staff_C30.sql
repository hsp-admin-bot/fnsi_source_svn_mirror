DELETE FROM mst_user_authentication
WHERE user_id = 93900;

INSERT INTO mst_user_authentication(
user_id,
facility_cd,
disp_user_id,
user_password,
failure_cnt
) VALUES (
93900,
'F_hC30',
'EGMAIN00',
'',
0
);

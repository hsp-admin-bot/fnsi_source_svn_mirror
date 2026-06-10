DELETE FROM mst_user_authentication
WHERE user_id = 90312;

INSERT INTO mst_user_authentication(
user_id,
facility_cd,
disp_user_id,
user_password,
failure_cnt
) VALUES (
90312,
'F_h312',
'EGMAIN00',
'',
0
);

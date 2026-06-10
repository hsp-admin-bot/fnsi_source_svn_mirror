DELETE FROM mst_user_authentication
WHERE user_id = 92800;

INSERT INTO mst_user_authentication(
user_id,
facility_cd,
disp_user_id,
user_password,
failure_cnt
) VALUES (
92800,
'F_hC10',
'EGMAIN00',
'',
0
);

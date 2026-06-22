DELETE FROM mst_user_authentication
WHERE user_id = 90500;

INSERT INTO mst_user_authentication(
user_id,
facility_cd,
disp_user_id,
user_password,
failure_cnt
) VALUES (
90500,
'F_h500',
'EGMAIN00',
'',
0
);

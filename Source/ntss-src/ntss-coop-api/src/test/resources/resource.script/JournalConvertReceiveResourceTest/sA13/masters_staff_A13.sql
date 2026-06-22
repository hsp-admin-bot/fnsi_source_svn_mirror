DELETE FROM mst_user_authentication
WHERE user_id = 98013;

INSERT INTO mst_user_authentication(
user_id,
facility_cd,
disp_user_id,
user_password,
failure_cnt
) VALUES (
98013,
'F_hA13',
'EGMAIN00',
'',
0
);

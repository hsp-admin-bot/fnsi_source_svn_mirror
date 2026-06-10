DELETE FROM mst_user_authentication
WHERE user_id = 98103;

INSERT INTO mst_user_authentication(
user_id,
facility_cd,
disp_user_id,
user_password,
failure_cnt
) VALUES (
98103,
'F_hB03',
'EGMAIN00',
'',
0
);

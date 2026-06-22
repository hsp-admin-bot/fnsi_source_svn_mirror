DELETE FROM mst_user_authentication
WHERE user_id = 98102;

INSERT INTO mst_user_authentication(
user_id,
facility_cd,
disp_user_id,
user_password,
failure_cnt
) VALUES (
98102,
'F_hB02',
'EGMAIN00',
'',
0
);

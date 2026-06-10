DELETE FROM mst_user_authentication
WHERE user_id = 90603;

INSERT INTO mst_user_authentication(
user_id,
facility_cd,
disp_user_id,
user_password,
failure_cnt
) VALUES (
90603,
'F_h603',
'EGMAIN00',
'',
0
);

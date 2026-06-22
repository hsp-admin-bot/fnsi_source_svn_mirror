DELETE FROM mst_user_authentication
WHERE user_id = 98001;

INSERT INTO mst_user_authentication(
user_id,
facility_cd,
disp_user_id,
user_password,
failure_cnt
) VALUES (
98001,
'F_hA01',
'EGMAIN00',
'',
0
);

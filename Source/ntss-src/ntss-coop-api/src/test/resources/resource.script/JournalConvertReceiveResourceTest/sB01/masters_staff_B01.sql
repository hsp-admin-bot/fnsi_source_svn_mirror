DELETE FROM mst_user_authentication
WHERE user_id = 98101;

INSERT INTO mst_user_authentication(
user_id,
facility_cd,
disp_user_id,
user_password,
failure_cnt
) VALUES (
98101,
'F_hB01',
'EGMAIN00',
'',
0
);

DELETE FROM mst_user_authentication
WHERE user_id = 98105;

INSERT INTO mst_user_authentication(
user_id,
facility_cd,
disp_user_id,
user_password,
failure_cnt
) VALUES (
98105,
'F_hB05',
'EGMAIN00',
'',
0
);

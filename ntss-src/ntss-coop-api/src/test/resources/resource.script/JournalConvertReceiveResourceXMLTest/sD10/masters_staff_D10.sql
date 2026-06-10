DELETE FROM mst_user_authentication
WHERE user_id BETWEEN 91900 AND 91999;

INSERT INTO mst_user_authentication(
user_id,
facility_cd,
disp_user_id,
user_password,
failure_cnt
) VALUES (
92900,
'F_hD10',
'12345678',
'',
0
);

INSERT INTO mst_user_authentication(
user_id,
facility_cd,
disp_user_id,
user_password,
failure_cnt
) VALUES (
92901,
'F_hD10',
'12341234',
'',
0
);

INSERT INTO mst_user_authentication(
user_id,
facility_cd,
disp_user_id,
user_password,
failure_cnt
) VALUES (
92902,
'F_hD10',
'53106812',
'',
0
);

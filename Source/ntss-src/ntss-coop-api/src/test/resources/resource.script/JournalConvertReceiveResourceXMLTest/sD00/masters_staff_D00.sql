DELETE FROM mst_user_authentication
WHERE user_id BETWEEN 91900 AND 91999;

INSERT INTO mst_user_authentication(
user_id,
facility_cd,
disp_user_id,
user_password,
failure_cnt
) VALUES (
91900,
'F_hD00',
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
91901,
'F_hD00',
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
91902,
'F_hD00',
'53106812',
'',
0
);

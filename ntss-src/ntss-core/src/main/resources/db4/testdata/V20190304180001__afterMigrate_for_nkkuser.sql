-- 利用者マスタ
INSERT INTO mst_user_authentication (user_id, facility_cd, disp_user_id, user_password, failure_cnt, reg_date, up_date) VALUES
	(24,'nkknkk','nkk24','$2a$10$C3pRasPhQANxqJysikH54uXRcAs6a/Mdz3NU9EMDk24UVSclIJf0y',0,null,'2018-11-12 13:58:50.302'),
	(25,'nkknkk','nkk25','$2a$10$C3pRasPhQANxqJysikH54uXRcAs6a/Mdz3NU9EMDk24UVSclIJf0y',0,null,'2018-11-12 14:03:06.582'),
	(26,'nkknkk','nkk36','$2a$10$C3pRasPhQANxqJysikH54uXRcAs6a/Mdz3NU9EMDk24UVSclIJf0y',0,null,'2018-11-19 16:51:53.367');

-- 施設マスタハッシュ
INSERT INTO mst_facility_hash (facility_cd, hash_value, reg_date, up_date) VALUES
	('nkknkk','nkknkk-test','2018-11-16 05:08:16.17','2018-11-16 05:08:16.17');

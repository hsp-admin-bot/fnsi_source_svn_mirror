-- 車いすマスタのデータ追加
SELECT setval('mst_wheel_chair_wheel_chair_cd_seq', 1, false);

INSERT INTO mst_wheel_chair (
	facility_cd,
	fn_wheel_chair_cd,
	wheel_chair_name,
	wheel_chair_weight,
	scale_date,
	scale_user_id,
	is_personal,
	pat_id,
	is_disp,
	is_del,
	reg_date,
	up_date
) VALUES
  ('009999','00000001','車いす01',8055,'2019/03/02 14:30:30.417',1,'0',null,'1','0','2019/03/02 14:30:30.417','2019/03/02 14:30:30.417'),
  ('009999','00000002','車いす02',null,null,null,'0',null,'1','0','2019/03/02 14:30:30.417','2019/03/02 14:30:30.417'),
  ('009999','00000003','車いす03',5000,'2019/03/02 14:30:30.417',1,'1',1,'1','0','2019/03/02 14:30:30.417','2019/03/02 14:30:30.417');

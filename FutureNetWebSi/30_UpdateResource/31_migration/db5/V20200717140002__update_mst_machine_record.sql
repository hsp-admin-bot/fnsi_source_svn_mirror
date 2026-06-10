----------------------------------------------------------------------------
-- mst_machine_recordの名称更新 2020.07.15
----------------------------------------------------------------------------
update mst_machine_record set machine_record_message = 'ΔＢＶがΔＢＶ低下警報点１を下回っています', up_date = now() where machine_record_cd = '5180';
update mst_machine_record set machine_record_message = 'ΔＢＶ除水速度制御中', up_date = now() where machine_record_cd = '5182';
update mst_machine_record set machine_record_message = 'ΔＢＶがΔＢＶ低下警報点２を上回りました。', up_date = now() where machine_record_cd = '5183';
update mst_machine_record set machine_record_message = 'ΔＢＶがΔＢＶ低下警報点２を下回っています', up_date = now() where machine_record_cd = '5184';
update mst_machine_record set machine_record_message = 'ΔBV除水速度が０で制御されています', up_date = now() where machine_record_cd = '5185';
update mst_machine_record set machine_record_message = 'ΔBVがリファレンスエリアから逸脱しています', up_date = now() where machine_record_cd = '5189';
update mst_machine_record set machine_record_message = '除水停止(ΔBV算出開始待ち)', up_date = now() where  machine_record_cd = '518B';
update mst_machine_record set machine_record_message = 'ΔＢＶ変化率警報', up_date = now() where machine_record_cd = '9C01';
update mst_machine_record set machine_record_message = 'ΔＢＶ低下警報１', up_date = now() where machine_record_cd = '9C04';
update mst_machine_record set machine_record_message = 'ΔＢＶ低下警報２', up_date = now() where machine_record_cd = '9C05';
update mst_machine_record set machine_record_message = 'ΔBV偏差警報（上限）', up_date = now() where machine_record_cd = '9C06';
update mst_machine_record set machine_record_message = 'ΔBV偏差警報（下限）', up_date = now() where machine_record_cd = '9C07';
update mst_machine_record set machine_record_message = 'ΔＢＶ初期化', up_date = now() where machine_record_cd = 'F5B4';
update mst_machine_record set machine_record_message = 'ΔBVリファレンスエリア監視スイッチ「切」', up_date = now() where machine_record_cd = 'F5C0';
update mst_machine_record set machine_record_message = 'ΔBVリファレンスエリア監視スイッチ「入」', up_date = now() where machine_record_cd = 'F5C1';

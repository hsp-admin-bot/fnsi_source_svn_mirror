DELETE FROM "ntss"."sys_data_set" where sql_cd in (263);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (263, 'with
machine_option_tbl as (
	SELECT
		key as option_key, 
		name as option_name
	FROM 
		jsonb_to_recordset(''[{"key": "opt_1_1", "name": "HDF/HF"}, {"key": "opt_1_2", "name": "サンプリングポート"}, {"key": "opt_1_3", "name": "透析液フィルタ種類"}, {"key": "opt_1_4", "name": "レベル調整ポンプ"}, {"key": "opt_1_6", "name": "血圧計"}, {"key": "opt_1_8", "name": "ブラッドボリューム計"}, {"key": "opt_1_9", "name": "透析量モニタ"}, {"key": "opt_1_10", "name": "BVplus"}, {"key": "opt_1_11", "name": "通信"}, {"key": "opt_1_12", "name": "自動プライミング"}, {"key": "opt_1_13", "name": "血液ポンプ（右回転）"}, {"key": "opt_1_14", "name": "クリップ式気泡検出器"}, {"key": "opt_1_15", "name": "ダイアライザ入口圧"}, {"key": "opt_2_0", "name": "シングルポンプシングルニードル"}, {"key": "opt_2_1", "name": "熱交換器"}, {"key": "opt_2_2", "name": "循環電磁弁"}, {"key": "opt_2_3", "name": "ＣＦ使用選択"}, {"key": "opt_2_5", "name": "ＣＦ２"}, {"key": "opt_2_7", "name": "補液ポンプ"}, {"key": "opt_2_8", "name": "増設補液ハンガー"}, {"key": "opt_2_9", "name": "熱湯薬液消毒補助ヒータユニット"}, {"key": "opt_2_10", "name": "CFカード"}, {"key": "opt_2_11", "name": "オンライン補充液（透析液）"}, {"key": "opt_2_12", "name": "透析量プログラム"}, {"key": "opt_2_13", "name": "D-FAS"}, {"key": "opt_2_14", "name": "アクセス再循環"}, {"key": "opt_3_1", "name": "Ｂ原液ノズル洗浄ユニット"}, {"key": "opt_3_4", "name": "Ａ原液ノズル洗浄"}, {"key": "opt_3_5", "name": "Ｎａ注入"}, {"key": "opt_3_6", "name": "ΔSO2使用選択"}, {"key": "opt_3_7", "name": "BV除水制御"}]'') AS ms (key text, name text)
)
, machine_tbl as (
  SELECT
		mm.*,
		bed.bed_name,
		mmt.machine_type,
		dev.device_name as device_edge_name,
		(
			SELECT string_agg(opt.option_name, '', '') FROM jsonb_each_text(machine_option::jsonb)
			LEFT JOIN machine_option_tbl opt ON opt.option_key = key
			WHERE value = ''1'' AND key IS NOT NULL
		) as machine_option_select_info
  FROM
    mst_machine as mm
	LEFT JOIN mst_bed as bed on mm.machine_no = bed.machine_no and mm.facility_cd = bed.facility_cd
	LEFT JOIN mst_machine_type as mmt on mm.machine_type_cd = mmt.machine_type_cd
	LEFT JOIN mst_device_edge as dev on mm.device_edge_no = dev.device_edge_no and mm.facility_cd = dev.facility_cd
  WHERE
    mm.machine_no in ( @machineNos )
  AND
    mm.facility_cd = @facilityCd
  AND
    mm.is_disp =''1''
  AND
    mm.is_del = ''0''
)

select a.* from (
	SELECT
		facility_cd,
		machine_type_cd,
		machine_type,
		machine_serial,
		machine_name,
		machine_no,
		bed_name,
		ip_address,
		port,
		com_format_cd,
		com_type,
		device_edge_no,
		device_edge_name,
		is_ftp,
		is_va,
		is_blood_purify_use,
		CASE
			WHEN is_blood_purify_use = ''1'' THEN ''0''
			ELSE blood_purify_type
		END AS blood_purify_type,
		setting_date,
		in_hospital_cd_1,
		in_hospital_cd_2,
		version,
		machine_option,
		machine_option_select_info,
		memo
	FROM
		machine_tbl as mt
) a ORDER BY ARRAY_POSITION(ARRAY[@machineNos], a.machine_no)
', 2, '[{"preview":"DCS-100NX_113","can_calc":"0","data_code":"machine_name","data_name":"装置名","data_type":"string","conv_table":[],"data_class":"基本設定","field_name":"machine_name","disp_format":"","data_category":"装置情報","facility_table":"","facility_filter_type":"0"},{"preview":"BED-01","can_calc":"0","data_code":"bed_name","data_name":"ベッド名","data_type":"string","conv_table":[],"data_class":"基本設定","field_name":"bed_name","disp_format":"","data_category":"装置情報","facility_table":"","facility_filter_type":"0"},{"preview":"I7012104","can_calc":"0","data_code":"machine_serial","data_name":"製造番号","data_type":"string","conv_table":[],"data_class":"基本設定","field_name":"machine_serial","disp_format":"","data_category":"装置情報","facility_table":"","facility_filter_type":"0"},{"preview":"DCS3","can_calc":"0","data_code":"machine_type","data_name":"型式","data_type":"string","conv_table":[],"data_class":"基本設定","field_name":"machine_type","disp_format":"","data_category":"装置情報","facility_table":"","facility_filter_type":"0"},{"preview":"DCS3","can_calc":"0","data_code":"version","data_name":"バージョン","data_type":"string","conv_table":[],"data_class":"基本設定","field_name":"version","disp_format":"","data_category":"装置情報","facility_table":"","facility_filter_type":"0"},{"preview":"オフライン運用","can_calc":"0","data_code":"com_type","data_name":"通信種別","data_type":"string","conv_table":[{"code":"0","disp":"オフライン運用","item":"オフライン運用"},{"code":"1","disp":"新通信","item":"新通信"},{"code":"3","disp":"透析通信共通プロトコル","item":"透析通信共通プロトコル"}],"data_class":"基本設定","field_name":"com_type","disp_format":"","data_category":"装置情報","facility_table":"","facility_filter_type":"0"},{"preview":"P","can_calc":"0","data_code":"com_format_cd","data_name":"通信フォーマット","data_type":"string","conv_table":[],"data_class":"基本設定","field_name":"com_format_cd","disp_format":"","data_category":"装置情報","facility_table":"","facility_filter_type":"0"},{"preview":"127.0.0.1","can_calc":"0","data_code":"ip_address","data_name":"IPアドレス","data_type":"string","conv_table":[],"data_class":"基本設定","field_name":"ip_address","disp_format":"","data_category":"装置情報","facility_table":"","facility_filter_type":"0"},{"preview":"1401","can_calc":"0","data_code":"port","data_name":"ポート番号","data_type":"string","conv_table":[],"data_class":"基本設定","field_name":"port","disp_format":"","data_category":"装置情報","facility_table":"","facility_filter_type":"0"},{"preview":"DeviceEdge_1","can_calc":"0","data_code":"device_edge_name","data_name":"デバイスエッジ","data_type":"string","conv_table":[],"data_class":"基本設定","field_name":"device_edge_name","disp_format":"","data_category":"装置情報","facility_table":"","facility_filter_type":"0"},{"preview":"データ収集しない","can_calc":"0","data_code":"is_ftp","data_name":"データ収集実績","data_type":"string","conv_table":[{"code":"0","disp":"データ収集しない","item":"データ収集しない"},{"code":"1","disp":"データ収集する","item":"データ収集する"}],"data_class":"基本設定","field_name":"is_ftp","disp_format":"","data_category":"装置情報","facility_table":"","facility_filter_type":"0"},{"preview":"使用しない","can_calc":"0","data_code":"is_va","data_name":"装置ビューア使用","data_type":"string","conv_table":[{"code":"0","disp":"使用しない","item":"使用しない"},{"code":"1","disp":"使用する","item":"使用する"}],"data_class":"基本設定","field_name":"is_va","disp_format":"","data_category":"装置情報","facility_table":"","facility_filter_type":"0"},{"preview":"使用しない","can_calc":"0","data_code":"is_blood_purify_use","data_name":"特殊浄化通信アプリで使用","data_type":"string","conv_table":[{"code":"0","disp":"使用する","item":"使用する"},{"code":"1","disp":"使用しない","item":"使用しない"}],"data_class":"基本設定","field_name":"is_blood_purify_use","disp_format":"","data_category":"装置情報","facility_table":"","facility_filter_type":"0"},{"preview":"日機装透析装置","can_calc":"0","data_code":"blood_purify_type","data_name":"特殊浄化アプリ名","data_type":"string","conv_table":[{"code":"0","disp":"","item":""},{"code":"1","disp":"ACH-Σ","item":"ACH-Σ"},{"code":"2","disp":"KM-8900","item":"KM-8900"},{"code":"3","disp":"プラソートiQ21","item":"プラソートiQ21"},{"code":"4","disp":"KM-9000","item":"KM-9000"},{"code":"5","disp":"日機装透析装置","item":"日機装透析装置"}],"data_class":"基本設定","field_name":"blood_purify_type","disp_format":"","data_category":"装置情報","facility_table":"","facility_filter_type":"0"},{"preview":"2026/02/28","can_calc":"0","data_code":"setting_date","data_name":"設置日","data_type":"DateTime","conv_table":[],"data_class":"基本設定","field_name":"setting_date","disp_format":"yyyy/mm/dd","data_category":"装置情報","facility_table":"","facility_filter_type":"0"},{"preview":"1","can_calc":"0","data_code":"in_hospital_cd_1","data_name":"連携コード1","data_type":"string","conv_table":[],"data_class":"基本設定","field_name":"in_hospital_cd_1","disp_format":"","data_category":"装置情報","facility_table":"","facility_filter_type":"0"},{"preview":"2","can_calc":"0","data_code":"in_hospital_cd_2","data_name":"連携コード2","data_type":"string","conv_table":[],"data_class":"基本設定","field_name":"in_hospital_cd_2","disp_format":"","data_category":"装置情報","facility_table":"","facility_filter_type":"0"},{"preview":"メモ","can_calc":"0","data_code":"memo","data_name":"メモ","data_type":"string","conv_table":[],"data_class":"基本設定","field_name":"memo","disp_format":"","data_category":"装置情報","facility_table":"","facility_filter_type":"0"},{"preview":"HDF/HF","can_calc":"0","data_code":"machine_option_select_info","data_name":"有効オプション","data_type":"string","conv_table":[],"data_class":"オプション","field_name":"machine_option_select_info","disp_format":"","data_category":"装置情報","facility_table":"","facility_filter_type":"0"}]', '1', '{"applications": [1]}', '{"classes": [7, 11]}', '装置情報 @machineNos @facilityCd使用', '2026-03-18 22:50:32.722', CURRENT_TIMESTAMP, NULL);
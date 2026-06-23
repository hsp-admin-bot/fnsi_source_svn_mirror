DELETE FROM sys_data_set a WHERE a.sql_cd in (-2090,-2091);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2090, 'WITH ntss_db5_mst_b AS (
	SELECT
		om.ord_no AS ord_no
		,ntss_db5_mst_b.in_hospital_cd_1 AS in_hospital_cd_1
		,ntss_db5_mst_b.bed_name AS bed_name
	FROM ord_main om
	LEFT JOIN mst_bed ntss_db5_mst_b
	ON om.rst_bed_cd = ntss_db5_mst_b.bed_cd
	WHERE ntss_db5_mst_b.facility_cd = @facilityCd
),
ntss_db5_mst_k AS (
	SELECT 
		om.ord_no AS ord_no
		,ntss_db5_mst_k.in_hospital_cd_1 AS in_hospital_cd_1
	FROM ord_main om
	LEFT JOIN mst_kur ntss_db5_mst_k
	ON om.rst_kur_cd = ntss_db5_mst_k.kur_cd
	WHERE ntss_db5_mst_k.facility_cd = @facilityCd
),
rst_vital_info_1 AS (
	SELECT 
		om.ord_no AS ord_no
		,om_rvi_json ->> ''bp_max'' AS bp_max
		,om_rvi_json ->> ''bp_min'' AS bp_min
		,om_rvi_json ->> ''bp_ave'' AS bp_ave
		,om_rvi_json ->> ''pulse'' AS pulse
	FROM ord_main om
	CROSS JOIN LATERAL json_array_elements(om.rst_vital_info ::json) om_rvi_json
	WHERE cast(om_rvi_json ->> ''bp_class'' AS char(20)) = ''1''
		AND om.facility_cd = @facilityCd
),
rst_vital_info_2 AS (
	SELECT 
		om.ord_no AS ord_no
		,om_rvi_json ->> ''bp_max'' AS bp_max
		,om_rvi_json ->> ''bp_min'' AS bp_min
		,om_rvi_json ->> ''bp_ave'' AS bp_ave
		,om_rvi_json ->> ''pulse'' AS pulse
	FROM ord_main om
	CROSS JOIN LATERAL json_array_elements(om.rst_vital_info ::json) om_rvi_json
	WHERE cast(om_rvi_json ->> ''bp_class'' AS char(20)) = ''2''
		AND om.facility_cd = @facilityCd
)
SELECT
	'''' AS hosppatid --患者ID
	,ntss_db5_om.pat_id AS patid
	,'''' AS names --氏名
	,ntss_db5_os.treat_date AS dialysisdate --透析日
	,ntss_db5_om.ord_no AS dialysisno --透析番号
	,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
	,ntss_db5_mst_b.in_hospital_cd_1 AS bedno --ベッド番号
	,ntss_db5_mst_b.bed_name AS bedname --ベッド名
	,ntss_db5_om.rst_machine_no AS deviceno --装置番号
	,ntss_db5_om.rst_machine_name AS devicename --装置名
	,ntss_db5_mst_k.in_hospital_cd_1 AS kurcd --クール
	,ntss_db5_om.rst_kur_name AS kurname --クール名
	,to_char(ntss_db5_om.rst_start_date, ''YYYY-MM-DD hh24:mi:ss'') AS startdate --透析開始日時
	,to_char(ntss_db5_om.rst_end_date, ''YYYY-MM-DD hh24:mi:ss'') AS enddate --透析終了日時
	,round(date_part(''epoch'',ntss_db5_om.rst_end_date - ntss_db5_om.rst_start_date)::NUMERIC / 60) AS dialysistime --透析時間
	,ntss_db5_om.rst_cond_info ::json #>> ''{1,value}'' AS plandialysistime --予定透析時間
	,ntss_db5_om.rst_dialysis_cnt AS dialysisnum --透析回数
	,'''' AS lastweight --前回体重
	,ntss_db5_om.rst_weight_info #>> ''{weight_before}'' AS weightbefore --前体重
	,ntss_db5_om.rst_weight_info #>> ''{weight_before}'' AS weightafter --後体重
	,ntss_db5_om.rst_weight_info #>> ''{weight_before}'' AS weightafter --後体重
	,rst_vital_info_1.bp_max AS bpbeforemax --透析前最高血圧
	,rst_vital_info_1.bp_min AS bpbeforemin --透析前最低血圧
	,rst_vital_info_1.bp_ave AS bpbeforeave --透析前平均血圧
	,rst_vital_info_2.bp_max AS bpaftermax --透析後最高血圧
	,rst_vital_info_2.bp_min AS bpaftermin --透析後最低血圧
	,rst_vital_info_2.bp_ave AS bpafterave --透析後平均血圧
	,ntss_db5_om.rst_weight_info #>> ''{water_removal_target}'' AS waterremovaltarget --目標除水量
	,ntss_db5_om.rst_off_water_info #>> ''{name_1}'' AS revisename1 --除水補正項目１
	,ntss_db5_om.rst_off_water_info #>> ''{weight_1}'' AS reviseweight1 --除水補正値１
	,ntss_db5_om.rst_off_water_info #>> ''{name_2}'' AS revisename2 --除水補正項目２
	,ntss_db5_om.rst_off_water_info #>> ''{weight_2}'' AS reviseweight2 --除水補正値２
	,ntss_db5_om.rst_off_water_info #>> ''{name_3}'' AS revisename3 --除水補正項目３
	,ntss_db5_om.rst_off_water_info #>> ''{weight_3}'' AS reviseweight3 --除水補正値３
	,ntss_db5_om.rst_off_water_info #>> ''{name_4}'' AS revisename4 --除水補正項目４
	,ntss_db5_om.rst_off_water_info #>> ''{weight_4}'' AS reviseweight4 --除水補正値４
	,ntss_db5_om.rst_off_water_info #>> ''{name_5}'' AS revisename5 --除水補正項目５
	,ntss_db5_om.rst_off_water_info #>> ''{weight_5}'' AS reviseweight5 --除水補正値５
	,rst_vital_info_1.pulse AS pulsebefore --透析前脈拍
	,rst_vital_info_2.pulse AS pulseafter --透析後脈拍
	,cast(ntss_db5_om.rst_charge_user_info #>> ''{user_last_name_1}'' AS char(20))
	  || cast(ntss_db5_om.rst_charge_user_info #>> ''{user_first_name_1}'' AS char(20)) AS charge1name --担当者１
	,cast(ntss_db5_om.rst_charge_user_info #>> ''{user_last_name_2}'' AS char(20))
	  || cast(ntss_db5_om.rst_charge_user_info #>> ''{user_first_name_2}'' AS char(20)) AS charge2name --担当者２
	,ntss_db5_om.rst_charge_user_info #>> ''{date_1}'' AS chargedate1 --担当日時１
	,ntss_db5_om.rst_charge_user_info #>> ''{date_2}'' AS chargedate2 --担当日時２
	,cast(ntss_db5_om.rst_puncture_user_info #>> ''{user_last_name_1}'' AS char(20))
	  || cast(ntss_db5_om.rst_puncture_user_info #>> ''{user_first_name_1}'' AS char(20)) AS puncture1name --穿刺者１
	,cast(ntss_db5_om.rst_puncture_user_info #>> ''{user_last_name_2}'' AS char(20))
	  || cast(ntss_db5_om.rst_puncture_user_info #>> ''{user_first_name_2}'' AS char(20)) AS puncture2name --穿刺者２
	,ntss_db5_om.rst_puncture_user_info #>> ''{date_1}'' AS puncturedate1 --穿刺日時１
	,ntss_db5_om.rst_puncture_user_info #>> ''{date_2}'' AS puncturedate2 --穿刺日時２
	,cast(ntss_db5_om.rst_return_user_info #>> ''{user_last_name_1}'' AS char(20))
	  || cast(ntss_db5_om.rst_return_user_info #>> ''{user_first_name_1}'' AS char(20)) AS collect1name --回収者１
	,cast(ntss_db5_om.rst_return_user_info #>> ''{user_last_name_2}'' AS char(20))
	  || cast(ntss_db5_om.rst_return_user_info #>> ''{user_first_name_2}'' AS char(20)) AS collect2name --回収者２
	,ntss_db5_om.rst_return_user_info #>> ''{date_1}'' AS collectdate1 --回収日時１
	,ntss_db5_om.rst_return_user_info #>> ''{date_2}'' AS collectdate2 --回収日時２
	,ntss_db5_om.rst_in_out_class AS inoutflg --入外
	,ntss_db5_om.rst_kt_v AS ktvmeasure --Kt/v測定値
	,ntss_db5_om.rst_weight_info #>> ''{urr}'' AS urr --URR
	,ntss_db5_om.rst_weight_info #>> ''{recrcl_rt}'' AS relooprate --再循環率
	,'''' AS pullleaveamount --I-HDF引き残し量
	,'''' AS addtotl --除水積算値
	,'''' AS staticvenouspressure --静的静脈圧
	,'''' AS venousaccesspressureratio --IAP ratio
FROM
	ord_main ntss_db5_om
	LEFT JOIN ord_schedule ntss_db5_os
	ON ntss_db5_om.ord_no = ntss_db5_om.ord_no
	AND ntss_db5_os.facility_cd = @facilityCd
	LEFT JOIN ntss_db5_mst_b
	ON ntss_db5_mst_b.ord_no = ntss_db5_om.ord_no
	LEFT JOIN ntss_db5_mst_k
	ON ntss_db5_mst_k.ord_no = ntss_db5_om.ord_no
	LEFT JOIN rst_vital_info_1
	ON rst_vital_info_1.ord_no = ntss_db5_om.ord_no
	LEFT JOIN rst_vital_info_2
	ON rst_vital_info_2.ord_no = ntss_db5_om.ord_no
WHERE
	ntss_db5_om.is_del = ''0''
	AND ntss_db5_om.facility_cd = @facilityCd
	AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
 	AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
	AND ntss_db5_om.pat_id IS NOT NULL;', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2091, 'SELECT
	ntss_db6_ppm.pat_id AS patid
	,personal_info_decrypt(ntss_db6_ppm.pat_last_name)|| '' '' ||personal_info_decrypt(ntss_db6_ppm.pat_first_name) AS names --氏名
FROM
	pat_personal_main ntss_db6_ppm
WHERE ntss_db6_ppm.facility_cd = @facilityCd;', 3, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);

DELETE FROM sys_data_set a WHERE a.sql_cd in (-2150,-2151);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2150, 'SELECT
	'''' AS hosppatid --患者ID
	,ntss_db5_om.pat_id AS patid
	,ntss_db5_os.treat_date AS dialysisdate --透析日
	,ntss_db5_om.ord_no AS dialysisno --透析番号
	,row_number() over(ORDER BY ntss_db5_om.treat_date DESC) AS ctlno --項目番号
	,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
	,''0'' AS effectflg --実施フラグ
	,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS effectdate --実施日時
	,ntss_db5_om_iic_json ->> ''content'' AS addition --補足指示内容
	,'''' AS hosppatid --実施者コード
	,cast(ntss_db5_om_iic_json ->> ''upd_user_last_name'' AS char(20))
	 || cast(ntss_db5_om_iic_json ->> ''upd_user_first_name'' AS char(20)) AS staffname --実施者名
FROM
	ord_main ntss_db5_om
	LEFT JOIN ord_schedule ntss_db5_os
	ON ntss_db5_om.ord_no = ntss_db5_os.ord_no
	AND ntss_db5_os.facility_cd = @facilityCd
	CROSS JOIN LATERAL json_array_elements(ntss_db5_om.ind_ind_comment_info ::json) ntss_db5_om_iic_json
WHERE
	ntss_db5_om.is_del = ''0''
	AND ntss_db5_om.facility_cd = @facilityCd
	AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
 	AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
	AND ntss_db5_om.pat_id IS NOT NULL;', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);

DELETE FROM sys_data_set a WHERE a.sql_cd in (-2100,-2101);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2100, 'WITH ntss_db5_om_key AS (
	SELECT
		ntss_db5_om.ord_no AS ord_no
		,json_object_keys(ntss_db5_om.rst_cond_info::json) AS keys
		,ntss_db5_om_value_json.value::json ->> ''value'' AS value
		,ntss_db5_om_value_json.value::json ->> ''value_name_1'' AS value_name_1
		,ntss_db5_om_value_json.value::json ->> ''unit'' AS unit
	FROM
		ord_main ntss_db5_om
		INNER JOIN json_each_text(ntss_db5_om.rst_cond_info::json) ntss_db5_om_value_json ON TRUE
	WHERE ntss_db5_om.rst_cond_info IS NOT NULL
	AND ntss_db5_om.facility_cd = @facilityCd
),
ntss_db5_mst_m as (
	SELECT
		ntss_db5_mst_m.*
	FROM
		mst_medicine ntss_db5_mst_m
	WHERE 
		ntss_db5_mst_m.is_del = ''0''
		AND ntss_db5_mst_m.is_disp = ''1''
		AND ntss_db5_mst_m.facility_cd = @facilityCd
),
ntss_db5_om_mst_list AS (
	SELECT
		om.ord_no AS ord_no
		,ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
	FROM
		ord_main om
		LEFT JOIN ntss_db5_om_key
		ON om.ord_no = ntss_db5_om_key.ord_no
		LEFT JOIN mst_equipment ntss_db5_mst_e
		ON cast(ntss_db5_om_key.keys as integer) = ntss_db5_mst_e.equipment_cd
	WHERE ntss_db5_mst_e.facility_cd = @facilityCd
		AND ntss_db5_mst_e.is_del = ''0''
	UNION ALL
	SELECT
		om.ord_no AS ord_no
		,ntss_db5_mst_m.in_hospital_cd_2 AS in_hospital_cd_2
	FROM
		ord_main om
		LEFT JOIN ntss_db5_om_key
		ON om.ord_no = ntss_db5_om_key.ord_no
		LEFT JOIN mst_medicine ntss_db5_mst_m
		ON cast(ntss_db5_om_key.keys as integer) = ntss_db5_mst_m.medicine_cd
	WHERE ntss_db5_mst_m.facility_cd = @facilityCd
		AND om.is_del = ''0''
)
SELECT
	'''' AS hosppatid --患者ID
	,ntss_db5_om.pat_id AS patid
	,ntss_db5_os.treat_date AS dialysisdate --透析日
	,ntss_db5_om.ord_no AS dialysisno --透析番号
	,CASE
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''1'' THEN ''002'' --治療時間
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''2'' THEN ''003'' --VA
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''3'' THEN ''005'' --目標体重
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''4'' THEN ''007'' --除水量制限
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''5'' THEN ''008'' --ダイアライザ
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''6'' THEN ''009'' --吸着カラム
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''7'' THEN ''039'' --1次膜
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''8'' THEN ''040'' --2次膜
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''9'' THEN '''' --穿刺針(A針)
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''10'' THEN '''' --穿刺針(V針)
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''11'' THEN '''' --穿刺針(SN)
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''12'' THEN ''029'' --シングルニードル使用
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''13'' THEN '''' --血液回路
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''14'' THEN ''010'' --血流量
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''15'' THEN ''018'' --透析液
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''16'' THEN ''019'' --透析液流量
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''17'' THEN ''020'' --透析液量
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''18'' THEN ''021'' --透析液温度
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''19'' THEN ''022'' --補液
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''20'' THEN ''023'' --補液量
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''21'' THEN ''024'' --補液選択
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''22'' THEN ''030'' --補液使用数
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''23'' THEN ''025'' --補液温度
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''24'' THEN ''038'' --補液速度
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''25'' THEN ''011'' --抗凝固剤
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''26'' THEN ''012'' --抗凝固剤ワンショット量
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''27'' THEN ''013'' --抗凝固剤持続速度
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''28'' THEN ''014'' --抗凝固剤持続総量
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''29'' THEN ''015'' --IP使用選択
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''30'' THEN ''031'' --IPスタート
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''31'' THEN ''016'' --IPワンショット量
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''32'' THEN ''017'' --IP速度
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''33'' THEN ''037'' --IP速度最大値
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''34'' THEN ''032'' --自動ワンショット
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''35'' THEN ''033'' --IP電源自動切り
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''36'' THEN ''034'' --IP電源自動切り時間
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''37'' THEN ''035'' --IP電源OKモニタ切り
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''38'' THEN ''036'' --IP電源OKモニタ切り時間
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''39'' THEN ''004'' --DW
	END AS ctlno --透析条件項目コード
	,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
	,CASE
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''1'' THEN ''透析時間'' --治療時間
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''2'' THEN ''VA'' --VA
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''3'' THEN ''目標体重'' --目標体重
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''4'' THEN ''除水量制限'' --除水量制限
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''5'' THEN ''ダイアライザ'' --ダイアライザ
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''6'' THEN ''吸着カラム'' --吸着カラム
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''7'' THEN ''1次膜'' --1次膜
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''8'' THEN ''2次膜'' --2次膜
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''9'' THEN '''' --穿刺針(A針)
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''10'' THEN '''' --穿刺針(V針)
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''11'' THEN '''' --穿刺針(SN)
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''12'' THEN ''シングルニードル使用'' --シングルニードル使用
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''13'' THEN '''' --血液回路
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''14'' THEN ''血流量'' --血流量
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''15'' THEN ''透析液'' --透析液
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''16'' THEN ''透析液流量'' --透析液流量
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''17'' THEN ''透析液量'' --透析液量
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''18'' THEN ''透析液温度'' --透析液温度
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''19'' THEN ''補液'' --補液
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''20'' THEN ''補液量'' --補液量
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''21'' THEN ''補液選択'' --補液選択
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''22'' THEN ''補液使用数'' --補液使用数
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''23'' THEN ''補液温度'' --補液温度
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''24'' THEN ''補液速度'' --補液速度
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''25'' THEN ''抗凝固剤'' --抗凝固剤
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''26'' THEN ''抗凝固剤ワンショット量'' --抗凝固剤ワンショット量
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''27'' THEN ''抗凝固剤持続速度'' --抗凝固剤持続速度
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''28'' THEN ''抗凝固剤持続総量'' --抗凝固剤持続総量
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''29'' THEN ''IP使用選択'' --IP使用選択
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''30'' THEN ''IPスタート'' --IPスタート
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''31'' THEN ''IPワンショット量'' --IPワンショット量
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''32'' THEN ''IP速度'' --IP速度
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''33'' THEN ''IP速度最大値'' --IP速度最大値
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''34'' THEN ''自動ワンショット'' --自動ワンショット
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''35'' THEN ''IP電源自動切り'' --IP電源自動切り
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''36'' THEN ''IP電源自動切り時間'' --IP電源自動切り時間
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''37'' THEN ''IP電源OKモニタ切り'' --IP電源OKモニタ切り
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''38'' THEN ''IP電源OKモニタ切り時間'' --IP電源OKモニタ切り時間
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''39'' THEN ''DW'' --DW
	END AS dialysisitemname --透析条件項目名
	,ntss_db5_om_key.value AS value --設定値
	,ntss_db5_om_key.value_name_1 AS valuename --設定値
	,ntss_db5_om_key.unit AS unit --単位
	,ntss_db5_om_mst_list.in_hospital_cd_2 AS valuecd2 --院内コード2
FROM
	ord_main ntss_db5_om
	LEFT JOIN ord_schedule ntss_db5_os
	ON ntss_db5_om.ord_no = ntss_db5_os.ord_no
	AND ntss_db5_os.facility_cd = @facilityCd
	LEFT JOIN ntss_db5_om_key
	ON  ntss_db5_om.ord_no = ntss_db5_om_key.ord_no
	LEFT JOIN ntss_db5_om_mst_list
	ON  ntss_db5_om.ord_no = ntss_db5_om_key.ord_no
WHERE
	ntss_db5_om.is_del = ''0''
	AND ntss_db5_om.facility_cd = @facilityCd
	AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
 	AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
	AND ntss_db5_om.pat_id IS NOT NULL;', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);

DELETE FROM sys_data_set a WHERE a.sql_cd in (-2120,-2121);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2120, 'WITH ntss_db5_mst_e AS (
	SELECT
		ntss_db5_om.ord_no AS ord_no
		,ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1
		,ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
	FROM ord_main ntss_db5_om
		CROSS JOIN LATERAL json_array_elements(ntss_db5_om.rst_equip_info ::json) ntss_db5_om_eqi_json
		LEFT JOIN mst_equipment ntss_db5_mst_e
		ON cast(ntss_db5_mst_e.equipment_cd as char(10)) = cast(ntss_db5_om_eqi_json ->> ''cd'' as char(10))
	WHERE ntss_db5_om.facility_cd = @facilityCd
)
SELECT
	'''' AS hosppatid --患者ID
	,ntss_db5_om.pat_id AS patid
	,ntss_db5_os.treat_date AS dialysisdate --透析日
	,ntss_db5_om.ord_no AS dialysisno --透析番号
	,row_number() over(ORDER BY ntss_db5_om.treat_date DESC) AS ctlno --項目番号
	,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
	,ntss_db5_mst_e.in_hospital_cd_1 AS equipcd --医療材料コード(院内コード1)
	,ntss_db5_mst_e.in_hospital_cd_2 AS equipcd2 --医療材料コード(院内コード2)
	,ntss_db5_om_rqi_json ->> ''name'' AS equipname --医療材料名
	,ntss_db5_om_rqi_json ->> ''class_name'' AS equipclassname --医療材料分類名
	,ntss_db5_om_rqi_json ->> ''needle_type'' AS punctureclass --穿刺針区分
	,ntss_db5_om_rqi_json ->> ''amount'' AS amount --数量
	,ntss_db5_om_rqi_json ->> ''unit'' AS unit --単位
	,ntss_db5_om_rqi_json ->> ''comment'' AS comments --コメント
FROM
	ord_main ntss_db5_om
	LEFT JOIN ord_schedule ntss_db5_os
	ON ntss_db5_om.ord_no = ntss_db5_os.ord_no
	INNER JOIN ntss_db5_mst_e
	ON ntss_db5_mst_e.ord_no = ntss_db5_om.ord_no
	CROSS JOIN LATERAL json_array_elements(ntss_db5_om.rst_equip_info::json) ntss_db5_om_rqi_json
WHERE
	ntss_db5_om.is_del = ''0''
	AND ntss_db5_om.facility_cd = @facilityCd
	AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
 	AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
	AND ntss_db5_om.pat_id IS NOT NULL;', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
DELETE FROM sys_data_set a WHERE a.sql_cd in (-2130,-2131);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2130, 'WITH ntss_db5_om_value AS (
	SELECT
		ntss_db5_om.ord_no AS ord_no
		,ntss_db5_om_rci_json.value::json #>> ''{value}'' AS value
	FROM
		ord_main ntss_db5_om
		LEFT JOIN json_each_text(ntss_db5_om.rst_cond_info::json) ntss_db5_om_rci_json ON TRUE
	WHERE ntss_db5_om.facility_cd = @facilityCd
	AND ntss_db5_om_rci_json.value::json #>> ''{value}'' IS NOT NULL
),
ntss_db5_mst_m AS (
	SELECT
		ntss_db5_om_value.ord_no AS ord_no
		,ntss_db5_mst_m.in_hospital_cd_1 AS in_hospital_cd_1
		,ntss_db5_mst_m.in_hospital_cd_2 AS in_hospital_cd_2
	FROM ntss_db5_om_value
		LEFT JOIN mst_medicine ntss_db5_mst_m
		ON cast(ntss_db5_mst_m.medicine_cd as char(10)) = ntss_db5_om_value.value
	WHERE ntss_db5_mst_m.facility_cd = @facilityCd
),
ntss_db5_mst_p AS (
	SELECT
		ntss_db5_om.ord_no AS ord_no
		,ntss_db5_mst_p.in_hospital_cd_a1 AS in_hospital_cd_1
		,ntss_db5_mst_p.in_hospital_cd_a2 AS in_hospital_cd_2
	FROM ord_main ntss_db5_om
		CROSS JOIN LATERAL json_array_elements(ntss_db5_om.rst_medi_info ::json) ntss_db5_om_rmi_json
		LEFT JOIN mst_procedure ntss_db5_mst_p
		ON cast(ntss_db5_mst_p.procedure_cd as char(10)) = cast(ntss_db5_om_rmi_json ->> ''procedure_cd'' as char(10))
	WHERE ntss_db5_om.facility_cd = @facilityCd
)
SELECT
	'''' AS hosppatid --患者ID
	,ntss_db5_om.pat_id AS patid
	,ntss_db5_os.treat_date AS dialysisdate --透析日
	,ntss_db5_om.ord_no AS dialysisno --透析番号
	,row_number() over(ORDER BY ntss_db5_om.treat_date DESC) AS ctlno --項目番号
	,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
	,ntss_db5_mst_m.in_hospital_cd_1 AS medicinecd --薬剤コード(院内コード1)
	,ntss_db5_mst_m.in_hospital_cd_2 AS medicinecd2 --薬剤コード(院内コード2)
	,ntss_db5_om_rmi_json ->> ''name'' AS medicinename --薬剤名
	,ntss_db5_om_rmi_json ->> ''class_name'' AS medicineclassname --薬剤分類名
	,ntss_db5_om_rmi_json ->> ''amount'' AS amount --数量
	,ntss_db5_om_rmi_json ->> ''unit'' AS unit --単位
	,ntss_db5_om_rmi_json ->> ''effect_flg'' AS effectflg --実施フラグ
	,CASE
		WHEN POSITION(''T'' IN cast(ntss_db5_om_rmi_json ->> ''effect_date'' AS char(20))) != 0
		THEN to_char(to_timestamp(ntss_db5_om_rmi_json ->> ''effect_date'', ''YYYY-MM-DDThh24:mi:ss''), ''YYYY-MM-DD hh24:mi:ss'')
		ELSE ''''
	END AS effectdate --実施日時
	,ntss_db5_om_rmi_json ->> ''timing_name'' AS timingname --投与時間帯名
	,ntss_db5_mst_p.in_hospital_cd_1 AS procedurecd --手技コード(院内コード1)
	,ntss_db5_mst_p.in_hospital_cd_2 AS procedurecd2 --手技コード(院内コード2)
	,ntss_db5_om_rmi_json ->> ''procedure_name'' AS procedurename --手技名
	,'''' AS indicatorcd --実施者コード
	,ntss_db5_om_rmi_json ->> ''effect_user_id'' AS userid
	,cast(ntss_db5_om_rmi_json ->> ''effect_user_last_name'' AS char(20))
	 || cast(ntss_db5_om_rmi_json ->> ''effect_user_first_name'' AS char(20)) AS staffname --実施者名
	,ntss_db5_om_rmi_json ->> ''comment'' AS comments --コメント
FROM
	ord_main ntss_db5_om
	LEFT JOIN ord_schedule ntss_db5_os
	ON ntss_db5_om.ord_no = ntss_db5_os.ord_no
	LEFT JOIN ntss_db5_mst_m
	ON ntss_db5_mst_m.ord_no = ntss_db5_om.ord_no
	LEFT JOIN ntss_db5_mst_p
	ON ntss_db5_mst_p.ord_no = ntss_db5_om.ord_no
	CROSS JOIN LATERAL json_array_elements(ntss_db5_om.rst_medi_info ::json) ntss_db5_om_rmi_json
WHERE
	ntss_db5_om.is_del = ''0''
	AND ntss_db5_om.facility_cd = @facilityCd
	AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
 	AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
	AND ntss_db5_om.pat_id IS NOT NULL;', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid,userid"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);

DELETE FROM sys_data_set a WHERE a.sql_cd in (-2110,-2111);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2110, 'WITH ntss_db5_om_key AS (
	SELECT
		ntss_db5_om.ord_no AS ord_no
		,json_object_keys(ntss_db5_om.rst_cond_info::json) AS keys
		,ntss_db5_om_value_json.value::json ->> ''value'' AS value
		,ntss_db5_om_value_json.value::json ->> ''value_name_1'' AS value_name_1
		,ntss_db5_om_value_json.value::json ->> ''unit'' AS unit
	FROM
		ord_main ntss_db5_om
		INNER JOIN json_each_text(ntss_db5_om.rst_cond_info::json) ntss_db5_om_value_json ON TRUE
	WHERE ntss_db5_om.rst_cond_info IS NOT NULL
	AND ntss_db5_om.facility_cd = @facilityCd
),
ntss_db5_mst_m as (
	SELECT
		ntss_db5_mst_m.*
	FROM
		mst_medicine ntss_db5_mst_m
	WHERE 
		ntss_db5_mst_m.is_del = ''0''
		AND ntss_db5_mst_m.is_disp = ''1''
		AND ntss_db5_mst_m.facility_cd = @facilityCd
),
ntss_db5_om_mst_list AS (
	SELECT
		om.ord_no AS ord_no
		,ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1
	FROM
		ord_main om
		LEFT JOIN ntss_db5_om_key
		ON om.ord_no = ntss_db5_om_key.ord_no
		LEFT JOIN mst_equipment ntss_db5_mst_e
		ON cast(ntss_db5_om_key.keys as integer) = ntss_db5_mst_e.equipment_cd
	WHERE ntss_db5_mst_e.facility_cd = @facilityCd
		AND ntss_db5_mst_e.is_del = ''0''
	UNION ALL
	SELECT
		om.ord_no AS ord_no
		,ntss_db5_mst_m.in_hospital_cd_1 AS in_hospital_cd_1
	FROM
		ord_main om
		LEFT JOIN ntss_db5_om_key
		ON om.ord_no = ntss_db5_om_key.ord_no
		LEFT JOIN mst_medicine ntss_db5_mst_m
		ON cast(ntss_db5_om_key.keys as integer) = ntss_db5_mst_m.medicine_cd
	WHERE ntss_db5_mst_m.facility_cd = @facilityCd
		AND om.is_del = ''0''
)
SELECT
	'''' AS hosppatid --患者ID
	,ntss_db5_om.pat_id AS patid
	,ntss_db5_os.treat_date AS dialysisdate --透析日
	,ntss_db5_om.ord_no AS dialysisno --透析番号
	,CASE
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''1'' THEN ''002'' --治療時間
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''2'' THEN ''003'' --VA
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''3'' THEN ''005'' --目標体重
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''4'' THEN ''007'' --除水量制限
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''5'' THEN ''008'' --ダイアライザ
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''6'' THEN ''009'' --吸着カラム
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''7'' THEN ''039'' --1次膜
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''8'' THEN ''040'' --2次膜
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''9'' THEN '''' --穿刺針(A針)
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''10'' THEN '''' --穿刺針(V針)
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''11'' THEN '''' --穿刺針(SN)
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''12'' THEN ''029'' --シングルニードル使用
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''13'' THEN '''' --血液回路
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''14'' THEN ''010'' --血流量
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''15'' THEN ''018'' --透析液
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''16'' THEN ''019'' --透析液流量
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''17'' THEN ''020'' --透析液量
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''18'' THEN ''021'' --透析液温度
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''19'' THEN ''022'' --補液
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''20'' THEN ''023'' --補液量
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''21'' THEN ''024'' --補液選択
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''22'' THEN ''030'' --補液使用数
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''23'' THEN ''025'' --補液温度
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''24'' THEN ''038'' --補液速度
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''25'' THEN ''011'' --抗凝固剤
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''26'' THEN ''012'' --抗凝固剤ワンショット量
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''27'' THEN ''013'' --抗凝固剤持続速度
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''28'' THEN ''014'' --抗凝固剤持続総量
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''29'' THEN ''015'' --IP使用選択
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''30'' THEN ''031'' --IPスタート
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''31'' THEN ''016'' --IPワンショット量
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''32'' THEN ''017'' --IP速度
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''33'' THEN ''037'' --IP速度最大値
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''34'' THEN ''032'' --自動ワンショット
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''35'' THEN ''033'' --IP電源自動切り
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''36'' THEN ''034'' --IP電源自動切り時間
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''37'' THEN ''035'' --IP電源OKモニタ切り
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''38'' THEN ''036'' --IP電源OKモニタ切り時間
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''39'' THEN ''004'' --DW
	END AS ctlno --透析条件項目コード
	,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
	,CASE
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''1'' THEN ''透析時間'' --治療時間
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''2'' THEN ''VA'' --VA
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''3'' THEN ''目標体重'' --目標体重
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''4'' THEN ''除水量制限'' --除水量制限
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''5'' THEN ''ダイアライザ'' --ダイアライザ
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''6'' THEN ''吸着カラム'' --吸着カラム
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''7'' THEN ''1次膜'' --1次膜
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''8'' THEN ''2次膜'' --2次膜
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''9'' THEN '''' --穿刺針(A針)
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''10'' THEN '''' --穿刺針(V針)
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''11'' THEN '''' --穿刺針(SN)
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''12'' THEN ''シングルニードル使用'' --シングルニードル使用
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''13'' THEN '''' --血液回路
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''14'' THEN ''血流量'' --血流量
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''15'' THEN ''透析液'' --透析液
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''16'' THEN ''透析液流量'' --透析液流量
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''17'' THEN ''透析液量'' --透析液量
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''18'' THEN ''透析液温度'' --透析液温度
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''19'' THEN ''補液'' --補液
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''20'' THEN ''補液量'' --補液量
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''21'' THEN ''補液選択'' --補液選択
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''22'' THEN ''補液使用数'' --補液使用数
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''23'' THEN ''補液温度'' --補液温度
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''24'' THEN ''補液速度'' --補液速度
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''25'' THEN ''抗凝固剤'' --抗凝固剤
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''26'' THEN ''抗凝固剤ワンショット量'' --抗凝固剤ワンショット量
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''27'' THEN ''抗凝固剤持続速度'' --抗凝固剤持続速度
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''28'' THEN ''抗凝固剤持続総量'' --抗凝固剤持続総量
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''29'' THEN ''IP使用選択'' --IP使用選択
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''30'' THEN ''IPスタート'' --IPスタート
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''31'' THEN ''IPワンショット量'' --IPワンショット量
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''32'' THEN ''IP速度'' --IP速度
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''33'' THEN ''IP速度最大値'' --IP速度最大値
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''34'' THEN ''自動ワンショット'' --自動ワンショット
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''35'' THEN ''IP電源自動切り'' --IP電源自動切り
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''36'' THEN ''IP電源自動切り時間'' --IP電源自動切り時間
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''37'' THEN ''IP電源OKモニタ切り'' --IP電源OKモニタ切り
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''38'' THEN ''IP電源OKモニタ切り時間'' --IP電源OKモニタ切り時間
		WHEN cast(ntss_db5_om_key.keys as char(10)) = ''39'' THEN ''DW'' --DW
	END AS dialysisitemname --透析条件項目名
	,ntss_db5_om_key.value AS value --設定値
	,ntss_db5_om_key.value_name_1 AS valuename --名称
	,'''' AS medgeneralname --薬剤一般名称
	,ntss_db5_om_key.unit AS unit --単位
	,ntss_db5_om_mst_list.in_hospital_cd_1 AS valuecd1 --院内コード1
FROM
	ord_main ntss_db5_om
	LEFT JOIN ord_schedule ntss_db5_os
	ON ntss_db5_om.ord_no = ntss_db5_os.ord_no
	AND ntss_db5_os.facility_cd = @facilityCd
	LEFT JOIN ntss_db5_om_key
	ON  ntss_db5_om.ord_no = ntss_db5_om_key.ord_no
	LEFT JOIN ntss_db5_om_mst_list
	ON  ntss_db5_om.ord_no = ntss_db5_om_key.ord_no
WHERE
	ntss_db5_om.is_del = ''0''
	AND ntss_db5_om.facility_cd = @facilityCd
	AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
 	AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
	AND ntss_db5_om.pat_id IS NOT NULL;', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);

DELETE FROM sys_data_set a WHERE a.sql_cd in (-2320,-2321);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2320, 'SELECT
	'''' AS hosppatid --患者ID
	,ntss_db5_pm.pat_id AS patid
	,ntss_db5_om_pmi_json ->> ''ctl_no'' AS ctlno
	,ntss_db5_om_pmi_json ->> ''title'' AS title
	,ntss_db5_om_pmi_json ->> ''content'' AS content
FROM
	pat_main ntss_db5_pm
	CROSS JOIN LATERAL json_array_elements(ntss_db5_pm.pat_memo_info ::json) ntss_db5_om_pmi_json
WHERE
	ntss_db5_pm.is_del = ''0''
	AND ntss_db5_pm.facility_cd = @facilityCd
	AND ntss_db5_pm.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' ) 
 	AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
	AND ntss_db5_pm.pat_id IS NOT NULL;', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
DELETE FROM sys_data_set a WHERE a.sql_cd in (-2160);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2160, 'WITH ntss_db5_list1 AS (
	SELECT
		ntss_db5_om_ddci_json1 ->> ''dial_diff_cd'' AS dial_diff_cd
		,ntss_db6_ppm1.pat_id AS pat_id
	FROM
		pat_personal_main ntss_db6_ppm1
		CROSS JOIN LATERAL json_array_elements(ntss_db6_ppm1.dial_diff_com_info ::json) ntss_db5_om_ddci_json1
	WHERE ntss_db5_om_ddci_json1 ->> ''dial_diff_cd'' = ''1''
	AND ntss_db6_ppm1.dial_diff_com_info IS NOT NULL
	AND ntss_db6_ppm1.dial_diff_com_info <> ''[]''
	AND ntss_db6_ppm1.facility_cd = @facilityCd
),
ntss_db5_list2 AS (
	SELECT
		ntss_db5_om_ddci_json2 ->> ''dial_diff_cd'' AS dial_diff_cd
		,ntss_db6_ppm2.pat_id AS pat_id
	FROM
		pat_personal_main ntss_db6_ppm2
		CROSS JOIN LATERAL json_array_elements(ntss_db6_ppm2.dial_diff_com_info ::json) ntss_db5_om_ddci_json2
	WHERE ntss_db5_om_ddci_json2 ->> ''dial_diff_cd'' = ''1''
	AND ntss_db5_om_ddci_json2 ->> ''is_main'' = ''1''
	AND ntss_db6_ppm2.dial_diff_com_info IS NOT NULL
	AND ntss_db6_ppm2.dial_diff_com_info <> ''[]''
	AND ntss_db6_ppm2.facility_cd = @facilityCd
)
SELECT
	ntss_db6_ppm.hosp_pat_id AS hosppatid --患者ID
	,ntss_db6_ppm.pat_id AS patid
	,'''' AS dialysisdate --透析日
	,'''' AS dialysisno --透析番号
	,'''' AS ctlno --項目番号
	,'''' AS updates --更新日時
	,ntss_db5_list1.dial_diff_cd AS dialdiffcd
	,''0'' AS division --レセプトメモ区分
	,'''' AS codes --コード
	,'''' AS codeupdate --コード更新日時
	,''0'' AS addflg --加算有無
	,'''' AS itemname --項目名称
	,ntss_db5_list2.dial_diff_cd AS dialdiffcd2
	,'''' AS maindialdiff --主たる透析困難
	,'''' AS inhospitalcd --院内コード
	,'''' AS inhospitalcd2 --院内コード２
FROM
	pat_personal_main ntss_db6_ppm
	LEFT JOIN ntss_db5_list1
	ON ntss_db5_list1.pat_id = ntss_db6_ppm.pat_id
	LEFT JOIN ntss_db5_list2
	ON ntss_db5_list2.pat_id = ntss_db6_ppm.pat_id
WHERE ntss_db6_ppm.is_del = ''0''
	AND ntss_db6_ppm.facility_cd = @facilityCd
	AND ntss_db6_ppm.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
 	AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
	AND ntss_db6_ppm.pat_id IS NOT NULL;', 3, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid,dialdiffcd,dialdiffcd2"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2161, 'SELECT
	ntss_db5_mdd.dialysis_difficulty_cd AS dialdiffcd
	,ntss_db5_mdd.in_hospital_cd_1 AS codes --コード
	,ntss_db5_mdd.up_date AS code_update --コード更新日時
	,ntss_db5_mdd.dialysis_difficulty_name AS itemname --項目名称
	,ntss_db5_mdd.in_hospital_cd_1 AS inhospitalcd --院内コード
	,ntss_db5_mdd.in_hospital_cd_2 AS inhospitalcd2 --院内コード
FROM
	mst_dialysis_difficulty ntss_db5_mdd
WHERE  ntss_db5_mdd.is_del=''0''
	AND ntss_db5_mdd.facility_cd = @facilityCd;', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["dialdiffcd"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2162, 'SELECT
	ntss_db5_mdd.dialysis_difficulty_cd AS dialdiffcd2
	,ntss_db5_mdd.up_date AS maindialdiff --主たる透析困難
FROM
	mst_dialysis_difficulty ntss_db5_mdd
WHERE ntss_db5_mdd.is_del=''0''
	AND ntss_db5_mdd.facility_cd = @facilityCd;', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["dialdiffcd2"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2163, 'SELECT
	ntss_db5_om.pat_id AS patid
	,ntss_db5_os.treat_date AS dialysisdate --透析日
	,ntss_db5_om.ord_no AS dialysisno --透析番号
	,row_number() over(ORDER BY ntss_db5_om.treat_date DESC) AS ctlno --項目番号
	,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
FROM
	ord_main ntss_db5_om
	LEFT JOIN ord_schedule ntss_db5_os
	ON ntss_db5_om.ord_no = ntss_db5_os.ord_no
WHERE
	ntss_db5_om.is_del = ''0''
	AND ntss_db5_om.facility_cd = @facilityCd
	AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
 	AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
	AND ntss_db5_om.pat_id IS NOT NULL;', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2164, 'WITH ntss_db5_list1 AS (
	SELECT
		ntss_db5_om.ord_no AS ord_no
		,ntss_db5_mst_a.in_hospital_cd_1 AS in_hospital_cd_1
		,ntss_db5_mst_a.up_date AS up_date
		,ntss_db5_mst_a.addition_name AS addition_name
		,ntss_db5_mst_a.in_hospital_cd_2 AS in_hospital_cd_2
	FROM
		ord_main ntss_db5_om
		CROSS JOIN LATERAL json_array_elements(ntss_db5_om.addition_info::json) ntss_db5_om_di_json1
		LEFT JOIN mst_addition ntss_db5_mst_a
		ON cast(ntss_db5_mst_a.addition_cd AS char(20)) = cast(ntss_db5_om_di_json1 ->> ''cd'' AS char(20))
	WHERE ntss_db5_om.is_del = ''0''
	AND ntss_db5_om.facility_cd = @facilityCd
	AND ntss_db5_om.addition_info IS NOT NULL
	AND ntss_db5_om.addition_info <> ''[]''
)
SELECT
	 '''' AS hosppatid --患者ID
	,ntss_db5_om.pat_id AS patid
	,ntss_db5_os.treat_date AS dialysisdate --透析日
	,ntss_db5_om.ord_no AS dialysisno --透析番号
	,row_number() over(ORDER BY ntss_db5_om.treat_date DESC) AS ctlno --項目番号
	,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
	,''1'' AS division --レセプトメモ区分
	,ntss_db5_list1.in_hospital_cd_1 AS codes --コード
	,ntss_db5_list1.up_date AS codeupdate --コード更新日時
	,''1'' AS addflg --加算有無
	,ntss_db5_list1.addition_name AS itemname --項目名称
	,'''' AS maindialdiff --主たる透析困難
	,ntss_db5_list1.in_hospital_cd_1 AS inhospitalcd --院内コード
	,ntss_db5_list1.in_hospital_cd_2 AS inhospitalcd2 --院内コード２
FROM
	ord_main ntss_db5_om
	LEFT JOIN ord_schedule ntss_db5_os
	ON ntss_db5_os.ord_no = ntss_db5_om.ord_no
	LEFT JOIN ntss_db5_list1
	ON ntss_db5_list1.ord_no = ntss_db5_om.ord_no
WHERE
	ntss_db5_om.is_del = ''0''
	AND ntss_db5_om.facility_cd = @facilityCd
	AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
 	AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
	AND ntss_db5_om.pat_id IS NOT NULL;', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["dialdiffcd2"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
DELETE FROM sys_data_set a WHERE a.sql_cd in (-2140,-2141);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2140, 'WITH ord AS (
    SELECT
        ord_no,
        facility_cd,
        json_idx,
        medi,
        is_del
    FROM
        ord_main
    CROSS JOIN LATERAL jsonb_array_elements (rst_medi_info) WITH ORDINALITY AS tmp (medi, json_idx)
    WHERE
        is_del = ''0''
    AND rst_dialysis_state <> ''0''
    AND facility_cd = @facilityCd
),
medicine_mix_temp AS (
	SELECT
	    mix.facility_cd
	    , mix.medicine_mix_cd
	    , medimix ->> ''cd'' as medi_cd
	    , medimix ->> ''amount'' as amount
	FROM
	    mst_medicine_mix mix
	    CROSS JOIN LATERAL jsonb_array_elements(mix_info) WITH ORDINALITY AS tmp(medimix, json_idx)
	WHERE
	    mix.facility_cd  = (select facility_cd from ord limit 1)
	    AND mix.is_del = ''0''
	    AND mix.is_disp = ''1''
	    AND mix.facility_cd = @facilityCd
),
ntss_db5_mst_m AS (
	SELECT
       ord.ord_no
       ,mstMedic.in_hospital_cd_1 as in_hospital_cd_1
     FROM
        ord
        LEFT JOIN mst_medicine mstMedic
        ON (ord.medi ->> ''cd'' = mstMedic.medicine_cd :: text AND mstMedic.is_del = ''0'' AND mstMedic.is_disp = ''1'' AND mstMedic.facility_cd = ord.facility_cd )
     WHERE
      ord.medi->>''medicine_type'' = ''1''
      AND ord.facility_cd = @facilityCd
    union  
    SELECT
      ord.ord_no
      ,mstMedic.in_hospital_cd_1 as in_hospital_cd_1
     FROM
        ord
        INNER JOIN medicine_mix_temp mixtemp
        ON (mixtemp.medicine_mix_cd ::text= medi ->> ''cd'' )
        LEFT JOIN mst_medicine mstMedic
        ON (mstMedic.medicine_cd ::text = mixtemp.medi_cd AND mstMedic.is_del = ''0'' AND mstMedic.is_disp = ''1'' AND mstMedic.facility_cd = ord.facility_cd )
     WHERE
      ord.medi->>''medicine_type'' = ''2''
      AND ord.facility_cd = @facilityCd
),
ntss_db5_mst_p AS (
	SELECT
		ntss_db5_om.ord_no AS ord_no
		,ntss_db5_mst_p.in_hospital_cd_a1 AS in_hospital_cd_1
		,ntss_db5_mst_p.in_hospital_cd_a2 AS in_hospital_cd_2
	FROM ord_main ntss_db5_om
		CROSS JOIN LATERAL json_array_elements(ntss_db5_om.rst_medi_info ::json) ntss_db5_om_rmi_json
		LEFT JOIN mst_procedure ntss_db5_mst_p
		ON cast(ntss_db5_mst_p.procedure_cd as char(10)) = cast(ntss_db5_om_rmi_json ->> ''procedure_cd'' as char(10))
	WHERE ntss_db5_om.facility_cd = @facilityCd
)
SELECT
	'''' AS hosppatid --患者ID
	,ntss_db5_om.pat_id AS patid
	,ntss_db5_os.treat_date AS dialysisdate --透析日
	,ntss_db5_om.ord_no AS dialysisno --透析番号
	,row_number() over(ORDER BY ntss_db5_om.treat_date DESC) AS ctlno --項目番号
	,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
	,ntss_db5_om_rmi_json1 ->> ''cd'' AS medicinecd --薬剤コード
	,ntss_db5_mst_m.in_hospital_cd_1 AS medicinecd2 --薬剤コード(院内コード1)
	,ntss_db5_om_rmi_json1 ->> ''name'' AS medicinename --薬剤名
	,'''' AS medgeneralname --一般名
	,ntss_db5_om_rmi_json1 ->> ''class_name'' AS medicineclassname --薬剤分類名
	,ntss_db5_om_rmi_json1 ->> ''amount'' AS amount --数量
	,ntss_db5_om_rmi_json1 ->> ''unit'' AS unit --単位
	,ntss_db5_om_rmi_json1 ->> ''effect_flg'' AS effectflg --実施フラグ
	,CASE
		WHEN POSITION(''T'' IN cast(ntss_db5_om_rmi_json1 ->> ''effect_date'' AS char(20))) != 0
		THEN to_char(to_timestamp(ntss_db5_om_rmi_json1 ->> ''effect_date'', ''YYYY-MM-DDThh24:mi:ss''), ''YYYY-MM-DD hh24:mi:ss'')
		ELSE ''''
	 END AS effectdate --実施日時
	,ntss_db5_om_rmi_json1 ->> ''timing_name'' AS timingname --投与時間帯名
	,ntss_db5_mst_p.in_hospital_cd_1 AS procedurecd --手技コード(院内コード1)
	,ntss_db5_mst_p.in_hospital_cd_2 AS procedurecd2 --手技コード(院内コード2)
	,ntss_db5_om_rmi_json1 ->> ''procedure_name'' AS procedurename --手技名
	,ntss_db5_om_rmi_json1 ->> ''effect_user_id'' AS userid
	,'''' AS indicatorcd --実施者コード
	,cast(ntss_db5_om_rmi_json1 ->> ''effect_user_last_name'' AS char(20))
	 || cast(ntss_db5_om_rmi_json1 ->> ''effect_user_first_name'' AS char(20)) AS staffname --実施者名
	,ntss_db5_om_rmi_json1 ->> ''comment'' AS comments --コメント
FROM
	ord_main ntss_db5_om
	LEFT JOIN ord_schedule ntss_db5_os
	ON ntss_db5_os.ord_no = ntss_db5_om.ord_no
	CROSS JOIN LATERAL json_array_elements(ntss_db5_om.rst_medi_info::json) ntss_db5_om_rmi_json1
	LEFT JOIN ntss_db5_mst_m
	ON ntss_db5_mst_m.ord_no = ntss_db5_om.ord_no
	LEFT JOIN ntss_db5_mst_p
	ON ntss_db5_mst_p.ord_no = ntss_db5_om.ord_no
WHERE
	ntss_db5_om.is_del = ''0''
	AND ntss_db5_om.facility_cd = @facilityCd
	AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
 	AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
	AND ntss_db5_om.pat_id IS NOT NULL;', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid,userid"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
DELETE FROM sys_data_set a WHERE a.sql_cd in (-2180,-2181);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2180, 'with ntss_db5_om_1 as (
	SELECT
		ntss_db5_om_1.ord_no AS ord_no
		,ntss_db5_om_1.pat_id
		,ntss_db5_om_1.treat_date AS treat_date
		,COUNT( ntss_db5_om_1.treat_date ) AS treat_date_count
	FROM
		ord_main ntss_db5_om_1
	WHERE 1=1
		AND ntss_db5_om_1.facility_cd = @facilityCd
	GROUP BY
		ntss_db5_om_1.ord_no,
		ntss_db5_om_1.pat_id,
		ntss_db5_om_1.treat_date
)
SELECT
	'''' AS hosppatid --患者ID
	,ntss_db5_om.pat_id AS patid
	,ntss_db5_os.treat_date AS dialysisdate --透析日
	,ntss_db5_mst_b.in_hospital_cd_1 AS bedno --ベッド番号
	,ntss_db5_mst_b.bed_name AS bedname --ベッド名
	,ntss_db5_mst_k.in_hospital_cd_1 AS kurcd --クールコード
	,ntss_db5_mst_k.kur_name AS kurname --クール名
	,CASE
		WHEN ntss_db5_om_1.treat_date_count > 1
		THEN 1
		ELSE 0
	 END AS plural --同日複数回
	,to_char(ntss_db5_os.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
	,ntss_db5_os.ord_no AS resultdialysisno --実績透析番号
	,CASE
		WHEN ntss_db5_om.treat_type = 0
		THEN ''1''
		ELSE ''0''
	END AS opeindplan --予定作成区分
	,ntss_db5_os.is_dummy AS dummyflg --ダミーフラグ
	,ntss_db5_om.ind_treat_start_time AS starttime --透析開始時刻
FROM
	ord_main ntss_db5_om
	LEFT JOIN ord_schedule ntss_db5_os
	ON ntss_db5_os.ord_no = ntss_db5_om.ord_no
	LEFT JOIN mst_bed ntss_db5_mst_b
	ON ntss_db5_mst_b.bed_cd = ntss_db5_os.bed_cd
	LEFT JOIN mst_kur ntss_db5_mst_k
	ON ntss_db5_mst_k.kur_cd = ntss_db5_os.kur_cd
	LEFT JOIN ntss_db5_om_1
	ON ntss_db5_om_1.ord_no = ntss_db5_om.ord_no
WHERE
	ntss_db5_om.is_del = ''0''
	AND ntss_db5_om.facility_cd = @facilityCd
	AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
 	AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
	AND ntss_db5_om.pat_id IS NOT NULL;', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
DELETE FROM sys_data_set a WHERE a.sql_cd in (-2291);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2291, 'SELECT
	ntss_db5_om_sd_json ->> ''point_cd'' AS surveypointcd --調査箇所コード
	,ntss_db5_mnt_wsp.point_name AS surveypointname --調査箇所名
	,to_char(ntss_db5_mnt_wsp.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
	,ntss_db5_mnt_ws.inspection_date AS checkdate --調査日
	,ntss_db5_om_sd_json ->> ''value'' AS results --調査結果値
	,ntss_db5_om_sd_json ->> ''unit'' AS unit --単位
	,'''' AS detail --調査結果詳細
FROM
	mnt_water_survey ntss_db5_mnt_ws
	CROSS JOIN LATERAL json_array_elements(ntss_db5_mnt_ws.survey_data ::json) ntss_db5_om_sd_json
	LEFT JOIN mst_water_survey_point ntss_db5_mnt_wsp
	ON cast(ntss_db5_mnt_ws.survey_record_no as char(10)) = cast(ntss_db5_om_sd_json ->> ''point_cd'' as char(10))
WHERE
	ntss_db5_mnt_ws.is_del = ''0''
	AND ntss_db5_mnt_ws.facility_cd = @facilityCd
	AND ntss_db5_mnt_ws.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
 	AND to_date( @toDate, ''YYYYMMDDHH24MISS'' );', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": [""]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
DELETE FROM sys_data_set a WHERE a.sql_cd in (-2270,-2271);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2270, 'SELECT
	'''' AS hosppatid --患者ID
	,ntss_db5_pxm.pat_id AS patid
	,to_char(ntss_db5_pxm.result_exam_date, ''YYYY-MM-DD hh24:mi:ss'') AS examdate --検査日時
	,ntss_db5_pxm.reg_order_class AS orderclass --検査区分
	,to_char(ntss_db5_pxm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS itemupdate --検査結果更新日時
	,ntss_db5_mst_e.in_hospital_cd1 AS examitemcode --検査項目コード(院内コード1)
	,ntss_db5_mst_e.in_hospital_cd2 AS examitemcode2 --検査項目コード(院内コード2)
	,ntss_db5_mst_e.in_hospital_cd3 AS examitemcode3 --検査項目コード(院内コード3)
	,ntss_db5_om_eri_json ->> ''exam_item_name'' AS examitemname --検査項目名
	,ntss_db5_om_eri_json ->> ''exam_result'' AS examrst --検査結果値
	,ntss_db5_om_eri_json ->> ''hi'' AS examclassrst --検査結果形態
	,ntss_db5_om_eri_json ->> ''freememo'' AS comments --コメント
FROM
	pat_exam_main ntss_db5_pxm
	CROSS JOIN LATERAL json_array_elements(ntss_db5_pxm.exam_result_info::json) ntss_db5_om_eri_json
	LEFT JOIN mst_exam_item ntss_db5_mst_e
	ON cast(ntss_db5_mst_e.exam_item_cd AS char(20)) = cast(ntss_db5_om_eri_json ->> ''item_cd'' AS char(20))
WHERE
	ntss_db5_pxm.is_del = ''0''
	AND ntss_db5_pxm.facility_cd = @facilityCd
	AND ntss_db5_pxm.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
 	AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
 	AND ntss_db5_pxm.exam_result_info IS NOT NULL;', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
DELETE FROM sys_data_set a WHERE a.sql_cd in (-2040,-2041);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2040, 'SELECT
	'''' AS hosppatid --患者ID
	,ntss_db5_pu.pat_id AS patid
	,ntss_db5_pu_mhi_json ->> ''disp_order'' AS ctlno --管理番号
	,to_char(ntss_db5_pu.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
	,ntss_db5_pu_mhi_json ->> ''disease_cd'' AS diseasecd --病名コード
	,ntss_db5_pu_mst_d.disease_name AS diseasename --病名
	,to_char(to_timestamp(ntss_db5_pu_mhi_json ->> ''disease_date'', ''YYYYMMDD''), ''YYYY-MM-DD hh24:mi:ss'') AS diseasedate --発症日
	,to_char(to_timestamp(ntss_db5_pu_mhi_json ->> ''out_come_date'', ''YYYYMMDD''), ''YYYY-MM-DD hh24:mi:ss'') AS recoverdate --治癒日
	,ntss_db5_pu_mhi_json ->> ''is_main_disease'' AS maindisease --主病名
	,ntss_db5_pu_mhi_json ->> ''out_come'' AS status --転帰
	,ntss_db5_pu_mhi_json ->> ''is_notice'' AS noticeflg --告知有無
	,ntss_db5_pu_mhi_json ->> ''diagnostician_cd'' AS doctorname --診断医
	,ntss_db5_pu_mhi_json ->> ''memo'' AS memo --メモ
FROM
	pat_unique ntss_db5_pu
	CROSS JOIN LATERAL json_array_elements(ntss_db5_pu.medical_hst_info::json) ntss_db5_pu_mhi_json
	LEFT JOIN mst_disease ntss_db5_pu_mst_d
	ON cast(ntss_db5_pu_mst_d.disease_cd AS char(20)) = cast(ntss_db5_pu_mhi_json ->> ''disease_cd'' AS char(20))
WHERE
	ntss_db5_pu.is_del = ''0''
	AND ntss_db5_pu.facility_cd = @facilityCd
	AND ntss_db5_pu.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' ) 
	AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
	AND ntss_db5_pu.medical_hst_info IS NOT NULL
	AND ntss_db5_pu.medical_hst_info <> ''[]''
	AND ntss_db5_pu_mhi_json ->> ''course_is_free'' = ''1'';', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', '2021-08-31 17:51:54.726', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2041, 'SELECT
	'''' AS hosppatid --患者ID
	,ntss_db5_pu.pat_id AS patid
	,ntss_db5_pu_mhi_json ->> ''disp_order'' AS ctlno --管理番号
	,to_char(ntss_db5_pu.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
	,ntss_db5_pu_mhi_json ->> ''disease_cd'' AS diseasecd --病名コード
	,ntss_db5_pu_mst_d.disease_name AS diseasename --病名
	,to_char(to_timestamp(ntss_db5_pu_mhi_json ->> ''disease_date'', ''YYYYMMDD''), ''YYYY-MM-DD hh24:mi:ss'') AS diseasedate --発症日
	,to_char(to_timestamp(ntss_db5_pu_mhi_json ->> ''out_come_date'', ''YYYYMMDD''), ''YYYY-MM-DD hh24:mi:ss'') AS recoverdate --治癒日
	,ntss_db5_pu_mhi_json ->> ''is_main_disease'' AS maindisease --主病名
	,ntss_db5_pu_mhi_json ->> ''out_come'' AS status --転帰
	,ntss_db5_pu_mhi_json ->> ''is_notice'' AS noticeflg --告知有無
	,'''' AS doctorname --診断医
	,ntss_db5_pu_mhi_json ->> ''disease_cd'' AS diseasecd
	,cast(ntss_db5_pu_mhi_json ->> ''disease_cd'' AS integer) AS userid
	,ntss_db5_pu_mhi_json ->> ''memo'' AS memo --メモ
FROM
	pat_unique ntss_db5_pu
	CROSS JOIN LATERAL json_array_elements(ntss_db5_pu.medical_hst_info::json) ntss_db5_pu_mhi_json
	LEFT JOIN mst_disease ntss_db5_pu_mst_d
	ON cast(ntss_db5_pu_mst_d.disease_cd AS char(20)) = cast(ntss_db5_pu_mhi_json ->> ''disease_cd'' AS char(20))
WHERE
	ntss_db5_pu.is_del = ''0''
	AND ntss_db5_pu.facility_cd = @facilityCd
	AND ntss_db5_pu.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
	AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
	AND ntss_db5_pu.medical_hst_info IS NOT NULL
	AND ntss_db5_pu.medical_hst_info <> ''[]''
	AND ntss_db5_pu_mhi_json ->> ''course_is_free'' = ''0'';', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid,userid"]}', '2021-02-26 17:51:54.726', '2021-08-31 17:51:54.726', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2042, 'SELECT
	ntss_db5_mst_p.user_id AS userid
	,personal_info_decrypt(ntss_db5_mst_p.user_last_name) || '' ''  || personal_info_decrypt(ntss_db5_mst_p.user_first_name) AS doctorname --診断医
FROM
	mst_personal_user ntss_db5_mst_p
WHERE 
	ntss_db5_mst_p.is_del = ''0''
	AND ntss_db5_mst_p.facility_cd = ''998998'';', 3, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["userid"]}', '2021-02-26 17:51:54.726', '2021-08-31 17:51:54.726', NULL);
DELETE FROM sys_data_set a WHERE a.sql_cd in (-2280,-2281);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2280, 'SELECT
	'''' AS hosppatid --患者ID
	,ntss_db5_pem.pat_id AS patid
	,to_char(ntss_db5_pem.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
	,to_char(ntss_db5_pem.reg_exam_date, ''YYYYMMDD'') AS examdate --検査予定日
	,to_char(ntss_db5_pem.reg_exam_date, ''hh24mi'') AS examtime --検査予定時刻
	,ntss_db5_pem_mst_ei.in_hospital_cd1 AS examsetcd --検査セットNo(院内コード)
	,ntss_db5_pem_oesi_json ->> ''set_name'' AS examsetname --検査セット名称
	,ntss_db5_pem.reg_order_class AS examdivision --検査予定区分
	,ntss_db5_pem.exam_status AS examproccd --検査実施予定コード
	,'''' AS doctorcode --指示者
	,ntss_db5_pem.ind_user_id AS userid
	,'''' AS doctorname --指示者名
	,'''' AS doctorcode --オーダー入力者
	,ntss_db5_pem.up_staff AS userid
	,'''' AS doctorname --オーダ入力者名
	,'''' AS doctorcode --更新者
	,'''' AS doctorname --更新者名
FROM
	pat_exam_main ntss_db5_pem
	CROSS JOIN LATERAL json_array_elements(ntss_db5_pem.order_exam_set_info::json) ntss_db5_pem_oesi_json
	LEFT JOIN mst_exam_item ntss_db5_pem_mst_ei
	ON ntss_db5_pem_mst_ei.exam_item_cd = cast(ntss_db5_pem_oesi_json ->> ''set_cd'' AS integer)
WHERE
	ntss_db5_pem.is_del = ''0''
	AND ntss_db5_pem.facility_cd = @facilityCd
	AND ntss_db5_pem.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
	AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
	AND ntss_db5_pem.order_exam_set_info IS NOT NULL
	AND ntss_db5_pem.order_exam_set_info <> ''[]'';', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid,userid"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2281, 'SELECT
	ntss_db4_mst_ua.user_id AS userid
	,ntss_db4_mst_ua.disp_user_id AS doctorcode
FROM
	mst_user_authentication ntss_db4_mst_ua
WHERE ntss_db4_mst_ua.facility_cd = @facilityCd;', 1, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["userid"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
DELETE FROM sys_data_set a WHERE a.sql_cd in (-2230,-2231);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2230, 'WITH ntss_db5_op_pd_json_1 AS (
	SELECT
		ntss_db5_op.ord_prescription_no AS ord_prescription_no
		,ntss_db5_op_pd_json ->> ''F1'' AS F1
		,ntss_db5_op_pd_json ->> ''F5'' AS F5
		,ntss_db5_op_pd_json ->> ''F6'' AS F6
	FROM
		ord_prescription ntss_db5_op
		CROSS JOIN LATERAL json_array_elements(ntss_db5_op.prescription_detail::json) ntss_db5_op_pd_json
	WHERE ntss_db5_op_pd_json ->> ''type'' = ''1''
		AND ntss_db5_op.facility_cd =  @facilityCd
),
ntss_db5_op_pd_json_2 AS (
	SELECT
		ntss_db5_op.ord_prescription_no AS ord_prescription_no
		,ntss_db5_op_mst_m.in_hospital_cd_1 AS medicine_cd1
		,ntss_db5_op_mst_m.in_hospital_cd_2 AS medicine_cd2
	FROM
		ord_prescription ntss_db5_op
		CROSS JOIN LATERAL json_array_elements(ntss_db5_op.prescription_detail::json) ntss_db5_op_pd_json
		LEFT JOIN mst_medicine ntss_db5_op_mst_m
		ON ntss_db5_op_mst_m.medicine_cd = cast(ntss_db5_op_pd_json ->> ''medicine_cd'' AS integer)
	WHERE ntss_db5_op_pd_json ->> ''type'' = ''1''
		AND  ntss_db5_op_pd_json ->> ''medicine_type'' = ''1''
		AND ntss_db5_op.facility_cd =  @facilityCd
),
ntss_db5_op_pd_json_3 AS (
	SELECT
		ntss_db5_op.ord_prescription_no AS ord_prescription_no
		,ntss_db5_op_pd_json ->> ''F5'' AS F5
		,ntss_db5_op_pd_json ->> ''F2'' AS F2
	FROM
		ord_prescription ntss_db5_op
		CROSS JOIN LATERAL json_array_elements(ntss_db5_op.prescription_detail::json) ntss_db5_op_pd_json
		LEFT JOIN mst_medicine ntss_db5_op_mst_m
		ON ntss_db5_op_mst_m.medicine_cd = cast(ntss_db5_op_pd_json ->> ''medicine_cd'' AS integer)
	WHERE ntss_db5_op_pd_json ->> ''type'' IN (''2'',''3'',''4'',''5'')
		AND ntss_db5_op.facility_cd =  @facilityCd
),
ntss_db5_op_pd_json_4 AS (
	SELECT
		ntss_db5_op.ord_prescription_no AS ord_prescription_no
		,ntss_db5_op_pd_json ->> ''F5'' AS F5
	FROM
		ord_prescription ntss_db5_op
		CROSS JOIN LATERAL json_array_elements(ntss_db5_op.prescription_detail::json) ntss_db5_op_pd_json
	WHERE ntss_db5_op_pd_json ->> ''type'' = ''2''
		AND ntss_db5_op.facility_cd =  @facilityCd
)
SELECT
	'''' AS hosppatid --患者ID
	,ntss_db5_op.pat_id AS patid
	,ntss_db5_op.ord_prescription_no AS prescriptno --処方番号
	,to_char(ntss_db5_op.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
	,ntss_db5_op.issue_date AS executedate --交付日
	,ntss_db5_op_pd_json ->> ''Rp'' AS ctlno --項目番号
	,ntss_db5_op_pd_json_1.F1 AS medicinename --薬剤名
	,ntss_db5_op_pd_json_2.medicine_cd1 AS medicinecd --薬剤コード(院内コード1)
	,ntss_db5_op_pd_json_2.medicine_cd2 AS medicinecd2 --薬剤コード(院内コード2)
	,ntss_db5_op_pd_json_1.F5 AS quantity --分量
	,ntss_db5_op_pd_json_1.F6 AS unit --単位
	,ntss_db5_op_pd_json_3.F5 AS dosage --用量
	,ntss_db5_op_mst_tm.take_medicine_cd AS takemedicinecd --用法コード
	,ntss_db5_op_pd_json_3.F2 AS takemedicinename --用法名
	,ntss_db5_op_pd_json_4.F5 AS daycount --調剤日数
	,'''' AS prescriptercd --処方者コード
	,'''' AS prescriptername --処方者名
	,'''' AS note --備考
FROM
	ord_prescription ntss_db5_op
	CROSS JOIN LATERAL json_array_elements(ntss_db5_op.prescription_detail::json) ntss_db5_op_pd_json
	LEFT JOIN ntss_db5_op_pd_json_1
	ON ntss_db5_op_pd_json_1.ord_prescription_no = ntss_db5_op.ord_prescription_no
	LEFT JOIN ntss_db5_op_pd_json_2
	ON ntss_db5_op_pd_json_2.ord_prescription_no = ntss_db5_op.ord_prescription_no
	LEFT JOIN ntss_db5_op_pd_json_3
	ON ntss_db5_op_pd_json_3.ord_prescription_no = ntss_db5_op.ord_prescription_no
	LEFT JOIN mst_take_medicine ntss_db5_op_mst_tm
	ON cast(ntss_db5_op_mst_tm.take_medicine_cd AS varchar(10)) = cast(ntss_db5_op_pd_json_3.F2 AS varchar(10))
	LEFT JOIN ntss_db5_op_pd_json_4
	ON ntss_db5_op_pd_json_4.ord_prescription_no = ntss_db5_op.ord_prescription_no
WHERE
	ntss_db5_op.is_del = ''0''
	AND ntss_db5_op.facility_cd = @facilityCd
	AND ntss_db5_op.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
	AND to_date( @toDate, ''YYYYMMDDHH24MISS'' );', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2231, 'SELECT
	ntss_db5_mst_opp.insu_dr_id AS userid
	,ntss_db5_mst_opp.pat_id AS patid
	,ntss_db5_mst_opp,insu_dr_name AS prescriptername
	,ntss_db5_mst_opp.remarks AS note
	,'''' AS prescriptercd
FROM
	ord_personal_prescription ntss_db5_mst_opp
WHERE 
	ntss_db5_mst_opp.is_del = ''0''
	AND ntss_db5_mst_opp.facility_cd = @facilityCd;', 3, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["userid,patid"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2232, 'SELECT
	ntss_db4_mst_ua.user_id AS userid
	,ntss_db4_mst_ua.disp_user_id AS prescriptercd --処方者コード
FROM
	mst_user_authentication ntss_db4_mst_ua
WHERE ntss_db4_mst_ua.facility_cd = @facilityCd;', 1, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["userid"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
DELETE FROM sys_data_set a WHERE a.sql_cd in (-2070,-2071);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2070, 'SELECT
	'''' AS hosppatid --患者ID
	,ntss_db5_pm.pat_id AS patid
	,'''' AS names --氏名
	,1 as ctlno --管理番号
	,to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時(当日)
	,CASE
		WHEN extract(DOW FROM now()) = 1 THEN ntss_db5_pm.off_water_info #>> ''{1,name_1}''
		WHEN extract(DOW FROM now()) = 2 THEN ntss_db5_pm.off_water_info #>> ''{2,name_1}''
		WHEN extract(DOW FROM now()) = 3 THEN ntss_db5_pm.off_water_info #>> ''{3,name_1}''
		WHEN extract(DOW FROM now()) = 4 THEN ntss_db5_pm.off_water_info #>> ''{4,name_1}''
		WHEN extract(DOW FROM now()) = 5 THEN ntss_db5_pm.off_water_info #>> ''{5,name_1}''
		WHEN extract(DOW FROM now()) = 6 THEN ntss_db5_pm.off_water_info #>> ''{6,name_1}''
		WHEN extract(DOW FROM now()) = 7 THEN ntss_db5_pm.off_water_info #>> ''{7,name_1}''
	  END AS revisename --除水補正名(当日)
	 ,CASE
		WHEN extract(DOW FROM now()) = 1 THEN ntss_db5_pm.off_water_info #>> ''{1,weight_1}''
		WHEN extract(DOW FROM now()) = 2 THEN ntss_db5_pm.off_water_info #>> ''{2,weight_1}''
		WHEN extract(DOW FROM now()) = 3 THEN ntss_db5_pm.off_water_info #>> ''{3,weight_1}''
		WHEN extract(DOW FROM now()) = 4 THEN ntss_db5_pm.off_water_info #>> ''{4,weight_1}''
		WHEN extract(DOW FROM now()) = 5 THEN ntss_db5_pm.off_water_info #>> ''{5,weight_1}''
		WHEN extract(DOW FROM now()) = 6 THEN ntss_db5_pm.off_water_info #>> ''{6,weight_1}''
		WHEN extract(DOW FROM now()) = 7 THEN ntss_db5_pm.off_water_info #>> ''{7,weight_1}''
	  END AS reviseweight --除水補正名(当日)
	 ,to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS monupdate --更新日時(月曜日)
	 ,ntss_db5_pm.off_water_info #>> ''{1,name_1}'' AS monrevisename --除水補正名(月曜日)
	 ,ntss_db5_pm.off_water_info #>> ''{1,weight_1}'' AS monreviseweight --重量(月曜日)
	 ,to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS tueupdate --更新日時(火曜日)
	 ,ntss_db5_pm.off_water_info #>> ''{2,name_1}'' AS tuerevisename --除水補正名(火曜日)
	 ,ntss_db5_pm.off_water_info #>> ''{2,weight_1}'' AS tuereviseweight --重量(火曜日)
	 ,to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS wedupdate --更新日時(水曜日)
	 ,ntss_db5_pm.off_water_info #>> ''{3,name_1}'' AS wedrevisename --除水補正名(水曜日)
	 ,ntss_db5_pm.off_water_info #>> ''{3,weight_1}'' AS wedreviseweight --重量(水曜日)
	 ,to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS thuupdate --更新日時(木曜日)
	 ,ntss_db5_pm.off_water_info #>> ''{4,name_1}'' AS thurevisename --除水補正名(木曜日)
	 ,ntss_db5_pm.off_water_info #>> ''{4,weight_1}'' AS thureviseweight --重量(木曜日)
	 ,to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS friupdate --更新日時(金曜日)
	 ,ntss_db5_pm.off_water_info #>> ''{5,name_1}'' AS frirevisename --除水補正名(金曜日)
	 ,ntss_db5_pm.off_water_info #>> ''{5,weight_1}'' AS frireviseweight --重量(金曜日)
	 ,to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS satupdate --更新日時(土曜日)
	 ,ntss_db5_pm.off_water_info #>> ''{6,name_1}'' AS satrevisename --除水補正名(土曜日)
	 ,ntss_db5_pm.off_water_info #>> ''{6,weight_1}'' AS satreviseweight --重量(土曜日)
	 ,to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS sunupdate --更新日時(日曜日)
	 ,ntss_db5_pm.off_water_info #>> ''{7,name_1}'' AS sunrevisename --除水補正名(日曜日)
	 ,ntss_db5_pm.off_water_info #>> ''{7,weight_1}'' AS sunreviseweight --重量(日曜日)
FROM
	pat_main ntss_db5_pm
WHERE
	ntss_db5_pm.is_del = ''0''
	AND ntss_db5_pm.facility_cd = @facilityCd
	AND ntss_db5_pm.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
 	AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
	AND ntss_db5_pm.off_water_info IS NOT NULL
	AND ntss_db5_pm.off_water_info <> ''[]'';', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2071, 'SELECT
	ntss_db6_ppm.hosp_pat_id AS hosppatid
	,ntss_db6_ppm.pat_id AS patid
	,personal_info_decrypt(ntss_db6_ppm.pat_last_name) || '' '' || personal_info_decrypt(ntss_db6_ppm.pat_first_name) AS names
FROM
	pat_personal_main ntss_db6_ppm
WHERE ntss_db6_ppm.is_del = ''0''
	AND ntss_db6_ppm.facility_cd = @facilityCd;', 3, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
DELETE FROM sys_data_set a WHERE a.sql_cd in (-2080,-2081);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2080, 'WITH ntss_db5_pm_mst_wc1 AS (
	SELECT 
		ntss_db5_pm_mst_wc.pat_id AS pat_id
		,ntss_db5_pm_mst_wc.wheel_chair_cd AS wheel_chair_cd
		,ntss_db5_pm_mst_wc.wheel_chair_name AS wheel_chair_name
	FROM mst_wheel_chair ntss_db5_pm_mst_wc
	WHERE ntss_db5_pm_mst_wc.is_personal = ''1''
		AND ntss_db5_pm_mst_wc.facility_cd = @facilityCd
)
SELECT
	'''' AS hosppatid --患者ID
	,ntss_db5_pm.pat_id AS patid
	,'''' AS names --氏名
	,1 as ctlno --管理番号
	,to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時(当日)
	,CASE
		WHEN extract(DOW FROM now()) = 1 THEN ntss_db5_pm.tare_info #>> ''{1,name_1}''
		WHEN extract(DOW FROM now()) = 2 THEN ntss_db5_pm.tare_info #>> ''{2,name_1}''
		WHEN extract(DOW FROM now()) = 3 THEN ntss_db5_pm.tare_info #>> ''{3,name_1}''
		WHEN extract(DOW FROM now()) = 4 THEN ntss_db5_pm.tare_info #>> ''{4,name_1}''
		WHEN extract(DOW FROM now()) = 5 THEN ntss_db5_pm.tare_info #>> ''{5,name_1}''
		WHEN extract(DOW FROM now()) = 6 THEN ntss_db5_pm.tare_info #>> ''{6,name_1}''
		WHEN extract(DOW FROM now()) = 7 THEN ntss_db5_pm.tare_info #>> ''{7,name_1}''
	  END AS revisename --風袋補正名(当日)
	 ,CASE
		WHEN extract(DOW FROM now()) = 1 THEN ntss_db5_pm.tare_info #>> ''{1,weight_1}''
		WHEN extract(DOW FROM now()) = 2 THEN ntss_db5_pm.tare_info #>> ''{2,weight_1}''
		WHEN extract(DOW FROM now()) = 3 THEN ntss_db5_pm.tare_info #>> ''{3,weight_1}''
		WHEN extract(DOW FROM now()) = 4 THEN ntss_db5_pm.tare_info #>> ''{4,weight_1}''
		WHEN extract(DOW FROM now()) = 5 THEN ntss_db5_pm.tare_info #>> ''{5,weight_1}''
		WHEN extract(DOW FROM now()) = 6 THEN ntss_db5_pm.tare_info #>> ''{6,weight_1}''
		WHEN extract(DOW FROM now()) = 7 THEN ntss_db5_pm.tare_info #>> ''{7,weight_1}''
	  END AS reviseweight --重量(当日)
	  ,ntss_db5_pm_mst_wc.wheel_chair_cd AS hospwheelchaircd --車椅子コード(当日)
	  ,ntss_db5_pm_mst_wc.wheel_chair_name AS wheelchairname --車椅子名(当日)
	 ,to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS monupdate --更新日時(月曜日)
	 ,ntss_db5_pm.off_water_info #>> ''{1,name_1}'' AS monrevisename --風袋補正名(月曜日)
	 ,ntss_db5_pm.off_water_info #>> ''{1,weight_1}'' AS monreviseweight --重量(月曜日)
	 ,ntss_db5_pm_mst_wc1.wheel_chair_cd AS monhospwheelchaircd --車椅子コード(月曜日)
	 ,ntss_db5_pm_mst_wc1.wheel_chair_name AS monwheelchairname --車椅子名(月曜日)
	 ,to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS tueupdate --更新日時(火曜日)
	 ,ntss_db5_pm.off_water_info #>> ''{2,name_1}'' AS tuerevisename --風袋補正名(火曜日)
	 ,ntss_db5_pm.off_water_info #>> ''{2,weight_1}'' AS tuereviseweight --重量(火曜日)
	 ,ntss_db5_pm_mst_wc1.wheel_chair_cd AS tuehospwheelchaircd --車椅子コード(火曜日)
	 ,ntss_db5_pm_mst_wc1.wheel_chair_name AS tuewheelchairname --車椅子名(火曜日)
	 ,to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS wedupdate --更新日時(水曜日)
	 ,ntss_db5_pm.off_water_info #>> ''{3,name_1}'' AS wedrevisename --除水補正名(水曜日)
	 ,ntss_db5_pm.off_water_info #>> ''{3,weight_1}'' AS wedreviseweight --重量(水曜日)
	 ,ntss_db5_pm_mst_wc1.wheel_chair_cd AS wedhospwheelchaircd --車椅子コード(水曜日)
	 ,ntss_db5_pm_mst_wc1.wheel_chair_name AS wedwheelchairname --車椅子名(水曜日)
	 ,to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS thuupdate --更新日時(木曜日)
	 ,ntss_db5_pm.off_water_info #>> ''{4,name_1}'' AS thurevisename --除水補正名(木曜日)
	 ,ntss_db5_pm.off_water_info #>> ''{4,weight_1}'' AS thureviseweight --重量(木曜日)
	 ,ntss_db5_pm_mst_wc1.wheel_chair_cd AS thuhospwheelchaircd --車椅子コード(木曜日)
	 ,ntss_db5_pm_mst_wc1.wheel_chair_name AS thuwheelchairname --車椅子名(木曜日)
	 ,to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS friupdate --更新日時(金曜日)
	 ,ntss_db5_pm.off_water_info #>> ''{5,name_1}'' AS frirevisename --除水補正名(金曜日)
	 ,ntss_db5_pm.off_water_info #>> ''{5,weight_1}'' AS frireviseweight --重量(金曜日)
	 ,ntss_db5_pm_mst_wc1.wheel_chair_cd AS frihospwheelchaircd --車椅子コード(金曜日)
	 ,ntss_db5_pm_mst_wc1.wheel_chair_name AS friwheelchairname --車椅子名(金曜日)
	 ,to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS satupdate --更新日時(土曜日)
	 ,ntss_db5_pm.off_water_info #>> ''{6,name_1}'' AS satrevisename --除水補正名(土曜日)
	 ,ntss_db5_pm.off_water_info #>> ''{6,weight_1}'' AS satreviseweight --重量(土曜日)
	 ,ntss_db5_pm_mst_wc1.wheel_chair_cd AS sathospwheelchaircd --車椅子コード(土曜日)
	 ,ntss_db5_pm_mst_wc1.wheel_chair_name AS satwheelchairname --車椅子名(土曜日)
	 ,to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS sunupdate --更新日時(日曜日)
	 ,ntss_db5_pm.off_water_info #>> ''{7,name_1}'' AS sunrevisename --除水補正名(日曜日)
	 ,ntss_db5_pm.off_water_info #>> ''{7,weight_1}'' AS sunreviseweight --重量(日曜日)
	 ,ntss_db5_pm_mst_wc1.wheel_chair_cd AS sunhospwheelchaircd --車椅子コード(日曜日)
	 ,ntss_db5_pm_mst_wc1.wheel_chair_name AS sunwheelchairname --車椅子名(日曜日)
FROM
	pat_main ntss_db5_pm
	LEFT JOIN mst_wheel_chair ntss_db5_pm_mst_wc
	ON ntss_db5_pm_mst_wc.pat_id = ntss_db5_pm.pat_id
	LEFT JOIN mst_wheel_chair ntss_db5_pm_mst_wc1
	ON ntss_db5_pm_mst_wc1.pat_id = ntss_db5_pm.pat_id
WHERE
	ntss_db5_pm.is_del = ''0''
	AND ntss_db5_pm.facility_cd = @facilityCd
	AND ntss_db5_pm.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
 	AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
	AND ntss_db5_pm.off_water_info IS NOT NULL
	AND ntss_db5_pm.off_water_info <> ''[]'';', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
DELETE FROM sys_data_set a WHERE a.sql_cd in (-2300,-2301);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2300, 'WITH ntss_db5_om_mnt_mr AS (
	SELECT 
		ntss_db5_om.pat_id AS pat_id
		,ntss_db5_om_mnt_mr.event_reg_date AS event_reg_date
	FROM 
		ord_main ntss_db5_om
		LEFT JOIN mnt_motion_record ntss_db5_om_mnt_mr
	 	ON ntss_db5_om_mnt_mr.motion_record_no = ntss_db5_om.rst_machine_no
	 	AND ntss_db5_om_mnt_mr.machine_record_cd = ''F407''
	 WHERE ntss_db5_om.facility_cd = @facilityCd
),
ntss_db5_om_mnt_mr2 AS (
	SELECT 
		ntss_db5_om.pat_id AS pat_id
		,ntss_db5_om_mnt_mr.event_reg_date AS event_reg_date
	FROM 
		ord_main ntss_db5_om
		LEFT JOIN mnt_motion_record ntss_db5_om_mnt_mr
	 	ON ntss_db5_om_mnt_mr.motion_record_no = ntss_db5_om.rst_machine_no
	 	AND ntss_db5_om_mnt_mr.machine_record_cd = ''4000''
	 WHERE ntss_db5_om.facility_cd = @facilityCd
)
SELECT
	'''' AS hosppatid --患者ID
	,ntss_db5_om.pat_id AS patid
	,ntss_db5_om.treat_date AS dialysisdate --透析日
	,ntss_db5_om.rst_start_date AS dialysistime --透析開始時刻
	,CASE
		WHEN ntss_db5_om.rst_dialysis_state IN (''0'',''1'',''2'') THEN ntss_db5_om.ind_treat_start_time
		WHEN ntss_db5_om.rst_dialysis_state IN (''3'',''4'',''5'',''6'') THEN to_char(ntss_db5_om.rec_set_date, ''YYYY-MM-DD hh24:mi:ss'')
	 END AS startplandate --予定開始日時
	,CASE
		WHEN ntss_db5_om.rst_cond_send_date = NULL THEN ''0''
		ELSE ''1''
	 END AS enterflg --入室フラグ（前体重測定）
	 ,ntss_db5_om.rst_cond_send_date AS enterdate --初回入室日時
	 ,CASE
		WHEN ntss_db5_om_mnt_mr.event_reg_date = NULL THEN ''0''
		ELSE ''1''
	 END AS machinecheckflg --透析装置確認フラグ
	 ,ntss_db5_om_mnt_mr.event_reg_date AS machinecheckdate --透析装置確認日時
	 ,CASE
		WHEN ntss_db5_om.rst_start_date = NULL THEN ''0''
		ELSE ''1''
	 END AS dialsisstartflg --透析運転開始フラグ
	 ,ntss_db5_om.rst_start_date AS dialsissstartdate--透析運転開始日時
	 ,CASE
		WHEN ntss_db5_om_mnt_mr2.event_reg_date = NULL THEN ''0''
		ELSE ''1''
	 END AS offwaterflg --除水完了フラグ
	 ,ntss_db5_om_mnt_mr2.event_reg_date AS offwaterdate --除水完了日時
	 ,CASE
		WHEN ntss_db5_om.rst_end_date = NULL THEN ''0''
		ELSE ''1''
	 END AS wastefluidflg --排液フラグ
	 ,ntss_db5_om.rst_end_date AS wastefluiddate --排液日時
	 ,CASE
		WHEN ntss_db5_om.rst_weight_info #>> ''{weight_after_date}'' = NULL THEN ''0''
		ELSE ''1''
	 END AS weightafterflg --後体重測定
	 ,ntss_db5_om.rst_weight_info #>> ''{weight_after_date}'' AS weightafterdate --後体重測定日時
	 ,CASE
		WHEN ntss_db5_om.rec_set_date = NULL THEN ''0''
		ELSE ''1''
	 END AS recoverybtnflg --準備回収確認ボタンフラグ
	 ,to_char(ntss_db5_om.rec_set_date, ''YYYY-MM-DD hh24:mi:ss'') AS recoverybtndate --準備回収確認ボタン日時
	 ,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --最終更新日時
FROM
	ord_main ntss_db5_om
	LEFT JOIN ntss_db5_om_mnt_mr
	ON ntss_db5_om_mnt_mr.pat_id = ntss_db5_om.pat_id
	LEFT JOIN ntss_db5_om_mnt_mr2
	ON ntss_db5_om_mnt_mr2.pat_id = ntss_db5_om.pat_id
WHERE
	ntss_db5_om.is_del = ''0''
	AND ntss_db5_om.facility_cd = @facilityCd
	AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
 	AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
	AND ntss_db5_om.rst_weight_info IS NOT NULL;', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
DELETE FROM sys_data_set a WHERE a.sql_cd in (-2260,-2261);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2260, 'SELECT
	'''' AS hosppatid,
	pu.pat_id AS patid,
	ROW_NUMBER ( ) OVER ( ORDER BY io ->> ''disp_order'', io ->> ''ctl_no'' ) AS ctlno,
	io ->> ''period_start'' AS regdate,
	io ->> ''move_in_out'' AS inoutcd,
CASE
		WHEN io ->> ''move_in_out'' = ''2'' THEN
		io ->> ''from_facility'' 
		WHEN io ->> ''move_in_out'' = ''3'' THEN
		io ->> ''to_facility'' ELSE'''' 
	END AS facilityname,
CASE
		WHEN io ->> ''move_in_out'' = ''2'' THEN
		io ->> ''from_doctot'' 
		WHEN io ->> ''move_in_out'' = ''3'' THEN
		io ->> ''to_doctot'' ELSE'''' 
	END AS drname,
	io ->> ''comment'' AS memo,
	io ->> ''reason'' AS codename 
FROM
	pat_unique pu,
	jsonb_array_elements ( pu.in_out_visit_history_info ) AS io 
WHERE
	pu.is_del = ''0'' 
	AND pu.facility_cd = @facilityCd 
	AND pu.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' ) 
	AND to_date( @toDate, ''YYYYMMDDHH24MISS'' );', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
DELETE FROM sys_data_set a WHERE a.sql_cd in (-2170,-2171);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2170, 'with ntss_db5_om_1 as (
	SELECT
		ntss_db5_om_1.ord_no AS ord_no
		,ntss_db5_om_1.pat_id
		,ntss_db5_om_1.treat_date AS treat_date
		,COUNT( ntss_db5_om_1.treat_date ) AS treat_date_count
	FROM
		ord_main ntss_db5_om_1
	WHERE 1=1
		AND ntss_db5_om_1.facility_cd = @facilityCd
	GROUP BY
		ntss_db5_om_1.ord_no,
		ntss_db5_om_1.pat_id,
		ntss_db5_om_1.treat_date
)
SELECT
	'''' AS hosppatid --患者ID
	,ntss_db5_om.pat_id AS patid
	,ntss_db5_os.treat_date AS dialysisdate --透析日
	,ntss_db5_os.ord_no AS bedno --ベッド番号
	,ntss_db5_om_mst_b.bed_name AS bedname --ベッド名
	,ntss_db5_om_mst_k AS kurcd --クールコード
	,ntss_db5_om.rst_kur_name AS kurname --クール名
	,CASE
		WHEN ntss_db5_om_1.treat_date_count > 1
		THEN 1
		ELSE 0
	 END AS plural --同日複数回
	 ,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
	 ,ntss_db5_om.ord_no AS resultdialysisno --実績透析番号
	 ,CASE
		WHEN ntss_db5_om.treat_type = 0
		THEN 1
		ELSE 0
	 END AS opeindplan --予定作成区分
	 ,ntss_db5_os.is_dummy AS dummyflg --ダミーフラグ
	 ,ntss_db5_om.rst_start_date AS starttime --透析開始時刻
FROM
	ord_main ntss_db5_om
	LEFT JOIN ord_schedule ntss_db5_os
	ON ntss_db5_os.pat_id = ntss_db5_om.pat_id
	LEFT JOIN mst_bed ntss_db5_om_mst_b
	ON ntss_db5_om_mst_b.bed_cd = ntss_db5_os.bed_cd
	LEFT JOIN mst_kur ntss_db5_om_mst_k
	ON ntss_db5_om_mst_k.kur_cd = ntss_db5_om.rst_kur_cd
	LEFT JOIN ntss_db5_om_1
    ON ntss_db5_om_1.ord_no = ntss_db5_om.ord_no
WHERE
	ntss_db5_om.is_del = ''0''
	AND ntss_db5_om.facility_cd = @facilityCd
	AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
 	AND to_date( @toDate, ''YYYYMMDDHH24MISS'' );', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);
DELETE FROM sys_data_set a WHERE a.sql_cd in (-2310,-2311);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2310, 'SELECT
	'''' AS hosppatid --患者ID
	,ntss_db5_pe.pat_id AS patid
	,to_char(ntss_db5_pe.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
	,'''' AS names --氏名
	,'''' AS namekana --患者名(かな）
	,to_char(ntss_db5_pe.reg_date, ''YYYYMMDD'') AS regdate --起票日
	,to_char(ntss_db5_pe.reg_date, ''hh24mi'') AS regtime --起票時刻
	,CASE
		WHEN ntss_db5_mst_pesc.in_hospital_cd_a1 != NULL
		THEN ntss_db5_mst_pesc.in_hospital_cd_a1
		ELSE ntss_db5_mst_pesc.in_hospital_cd_b1
	 END AS kindid --種別ID
	 ,ntss_db5_pe.sub_category_name AS kindname --種別名
	 ,'''' AS staffcd --起票者ID
	 ,ntss_db5_pe.reg_staff_info #>> ''{reg_staff_cd}'' AS userid
	 ,ntss_db5_pe.reg_staff_info #>> ''{reg_staff_name}'' AS staffname --起票者名
	 ,'''' AS staffcd --編集者id
	 ,ntss_db5_pe.reg_staff_info #>> ''{reg_staff_name}'' AS editname --編集者名
	 ,ntss_db5_pe_rp_json #>> ''{result_value}'' AS detail1 --内容1
	 ,ntss_db5_pe_rp_json #>> ''{result_value}'' AS detail2 --内容2
	 ,ntss_db5_pe_rp_json #>> ''{result_value}'' AS detail3 --内容3
	 ,ntss_db5_pe_rp_json #>> ''{result_value}'' AS detail4 --内容4
FROM
	pat_event ntss_db5_pe
	LEFT JOIN mst_pat_event_sub_category ntss_db5_mst_pesc
	ON ntss_db5_mst_pesc.sub_category_cd = ntss_db5_pe.sub_category_cd
	CROSS JOIN LATERAL json_array_elements(ntss_db5_pe.result_params::json) ntss_db5_pe_rp_json
WHERE
	ntss_db5_pe.is_del = ''0''
	AND ntss_db5_pe.facility_cd = @facilityCd
	AND ntss_db5_pe.use_type = ''2''
	AND cast(ntss_db5_pe_rp_json #>> ''{format_class}'' AS integer) = 0
	AND  ntss_db5_pe.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
 	AND to_date( @toDate, ''YYYYMMDDHH24MISS'' );', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid,userid"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2311, 'SELECT
	ntss_db6_ppm.hosp_pat_id AS hosppatid
	,ntss_db6_ppm.pat_id AS patid
	,personal_info_decrypt(ntss_db6_ppm.pat_last_name) || '' '' || personal_info_decrypt(ntss_db6_ppm.pat_first_name) AS names
	,personal_info_decrypt(ntss_db6_ppm.pat_last_name_kana) || '' '' || personal_info_decrypt(ntss_db6_ppm.pat_first_name_kana) AS namekana
FROM
	pat_personal_main ntss_db6_ppm
WHERE ntss_db6_ppm.is_del = ''0''
	AND ntss_db6_ppm.facility_cd = @facilityCd;', 3, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2312, 'SELECT
	ntss_db4_mst_ua.disp_user_id AS staffcd
	,ntss_db4_mst_ua.user_id AS userid
FROM
	mst_user_authentication ntss_db4_mst_ua
WHERE ntss_db4_mst_ua.facility_cd = @facilityCd;', 1, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["userid"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);

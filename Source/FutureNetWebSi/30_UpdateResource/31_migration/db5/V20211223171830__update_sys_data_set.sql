-- V_PAT_TABOO
UPDATE sys_data_set
SET "sql"= 
		'SELECT
			ntss_db6_ppm.hosp_pat_id AS hosppatid --患者ID
			,personal_info_decrypt(ntss_db6_ppm.pat_last_name)|| '' '' || personal_info_decrypt(ntss_db6_ppm.pat_first_name) AS names --氏名
			,ntss_db6_ppm.pat_id AS patid ----patid 外部キー
		FROM
			pat_personal_main ntss_db6_ppm
		WHERE ntss_db6_ppm.is_del=''0''
			AND ntss_db6_ppm.facility_cd= @facilityCd
			AND ntss_db6_ppm.up_date 
				BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
				AND to_date( @toDate, ''YYYYMMDDHH24MISS'' );'
WHERE sql_cd = '-2021';


-- V_PAT_CONTACT
UPDATE sys_data_set
SET "sql"=
		'SELECT
			ntss_db6_ppm.hosp_pat_id AS patid --患者ID
			,REPLACE(personal_info_decrypt(ntss_db6_ppm.pat_last_name)|| '' '' ||personal_info_decrypt(ntss_db6_ppm.pat_first_name), ''"'','''') AS name --氏名
			,ntss_db6_ppm_json ->> ''ctl_no'' AS ctlno --管理番号
			,to_char(ntss_db6_ppm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
			,to_char(ntss_db6_ppm.reg_date, ''YYYY-MM-DD hh24:mi:ss'') AS regdate --登録日時
			,REPLACE(personal_info_decrypt(ntss_db6_ppm_json ->> ''relation_name''), ''"'','''') AS relationname --続柄
			,REPLACE(personal_info_decrypt(ntss_db6_ppm_json ->> ''last_name'')|| '' '' || personal_info_decrypt(ntss_db6_ppm_json ->> ''first_name''), ''"'','''') AS rname --連絡先氏名
			,SUBSTR(REPLACE(personal_info_decrypt(ntss_db6_ppm_json ->> ''zip_cd''), ''"'', ''''), 0, 9) AS zipcode --郵便番号
			,REPLACE(personal_info_decrypt(ntss_db6_ppm_json ->> ''address''), ''"'','''') AS address --住所(市町村）
			,'''' AS addressdetail --住所(番地アパート）
			,REPLACE(personal_info_decrypt(ntss_db6_ppm_json ->> ''tel1''), ''"'','''') AS telno1 --電話番号１
			,REPLACE(personal_info_decrypt(ntss_db6_ppm_json ->> ''tel2''), ''"'','''') AS telno2 --電話番号２
			,REPLACE(personal_info_decrypt(ntss_db6_ppm_json ->> ''memo1'')|| '' '' || personal_info_decrypt(ntss_db6_ppm_json ->> ''memo2''), ''"'','''') AS memo --メモ
		FROM
			pat_personal_main ntss_db6_ppm
			CROSS JOIN LATERAL json_array_elements(ntss_db6_ppm.other_contact_info ::json) ntss_db6_ppm_json
		WHERE 
			ntss_db6_ppm_json ->> ''ctl_no'' = ''1''
			AND ntss_db6_ppm.is_del = ''0''
			AND ntss_db6_ppm.facility_cd = @facilityCd
			AND ntss_db6_ppm.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
		AND to_date( @toDate , ''YYYYMMDDHH24MISS'' );'
WHERE sql_cd = '-2030';


-- V_PAT_MEDICAL_HST_0
UPDATE sys_data_set
SET "sql"= 
		'SELECT
			ntss_db5_mst_p.user_id AS userid
			,REPLACE(personal_info_decrypt(ntss_db5_mst_p.user_last_name) || '' ''  || personal_info_decrypt(ntss_db5_mst_p.user_first_name), ''"'', '''')  AS doctorname --診断医
		FROM
			mst_personal_user ntss_db5_mst_p
		WHERE 
			ntss_db5_mst_p.is_del = ''0''
			AND ntss_db5_mst_p.facility_cd = @facilityCd
			AND ntss_db5_mst_p.up_date 
				BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
				AND to_date( @toDate, ''YYYYMMDDHH24MISS'' );'
WHERE sql_cd = '-2042';


-- V_PAT_INFECT
UPDATE sys_data_set
SET "sql"= 
		'with ntss_db5_mst_mi as (
			SELECT
				ntss_db5_mst_infection.in_hospital_cd_1 AS inhospitalcd1
				,ntss_db5_mst_infection.infection_cd AS infectioncd
				,ntss_db5_mst_infection.infection_name AS infectionname
			FROM mst_infection ntss_db5_mst_infection
			WHERE ntss_db5_mst_infection.facility_cd=@facilityCd
			AND ntss_db5_mst_infection.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
			AND to_date( @toDate , ''YYYYMMDDHH24MISS'' )
		)
		SELECT
			'''' AS hosppatid --患者ID
			,ntss_db5_mst_mi.inhospitalcd1 AS infectioncd --感染症コード
			,ntss_db5_mst_mi.infectionname AS infectionname --感染症名
			,to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
			,ntss_db5_pm_json ->> ''infect'' AS infect --結果コード
			,ntss_db5_pm.pat_id AS patid
		FROM
			pat_main ntss_db5_pm
			CROSS JOIN LATERAL json_array_elements(ntss_db5_pm.infect_info ::json) ntss_db5_pm_json
			LEFT JOIN ntss_db5_mst_mi
			ON CAST(ntss_db5_mst_mi.infectioncd as varchar(4)) = ntss_db5_pm_json ->> ''infection_cd''
		WHERE 
			ntss_db5_pm.is_del = ''0''
			AND ntss_db5_pm.facility_cd = @facilityCd
			AND ntss_db5_pm.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
			AND to_date( @toDate , ''YYYYMMDDHH24MISS'' );'
WHERE sql_cd = '-2050';


-- V_PAT_RECEIPT_MEMO
UPDATE sys_data_set
SET "sql"=
		'with ntss_db5_mst_add as (
			SELECT
				ntss_db5_mst_addition.addition_cd AS additioncd
				,ntss_db5_mst_addition.addition_class AS additionclass
				,ntss_db5_mst_addition.up_date AS addupdate
				,ntss_db5_mst_addition.in_hospital_cd_1 AS inhospitalcd1
				,ntss_db5_mst_addition.in_hospital_cd_2 AS inhospitalcd2
			FROM mst_addition ntss_db5_mst_addition
			WHERE ntss_db5_mst_addition.facility_cd = @facilityCd
			AND ntss_db5_mst_addition.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
					AND to_date( @toDate , ''YYYYMMDDHH24MISS'' )
		)
		SELECT
			'''' AS hosppatid --患者ID
			,to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
			,CASE
				WHEN ntss_db5_mst_add.additionclass = ''2''
				THEN ''1''
				ELSE ''0''
			 END AS division --レセプトメモ区分
			,ntss_db5_pm_json ->> ''cd'' AS codes --コード
			,to_char(ntss_db5_mst_add.addupdate, ''YYYY-MM-DD hh24:mi:ss'') AS codeupdate --コード更新日時
			,CASE
				WHEN jsonb_array_length(ntss_db5_pm.addition_info) > 0
				THEN ''1''
				ELSE ''0''
			 END AS addflg --レセプトメモ区分
			 ,ntss_db5_pm_json ->> ''name'' AS itemname --項目名称
			 ,CASE
				WHEN ntss_db5_mst_add.additionclass = ''2''
				THEN ''1''
				ELSE ''0''
			 END AS maindialdiff --主たる透析困難
			 ,ntss_db5_mst_add.inhospitalcd1 AS inhospitalcd --院内コード
			 ,ntss_db5_mst_add.inhospitalcd2 AS inhospitalcd2 --院内コード２
			 ,ntss_db5_pm.pat_id AS patid
		FROM
			pat_main ntss_db5_pm
			CROSS JOIN LATERAL json_array_elements(ntss_db5_pm.addition_info ::json) ntss_db5_pm_json
			LEFT JOIN ntss_db5_mst_add
			ON CAST(ntss_db5_mst_add.additioncd as varchar(4)) = ntss_db5_pm_json ->> ''cd''
		WHERE 
			ntss_db5_pm.is_del = ''0''
			AND ntss_db5_pm.facility_cd = @facilityCd
			AND ntss_db5_pm.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
			AND to_date( @toDate , ''YYYYMMDDHH24MISS'' );'
WHERE sql_cd = '-2060';


-- V_PAT_REVISE_TARE
UPDATE sys_data_set
SET "sql"=
		'WITH ntss_db5_pm_mst_wc1 AS (
			SELECT
				ntss_db5_pm_mst_wc.pat_id AS pat_id
				,ntss_db5_pm_mst_wc.wheel_chair_cd AS wheel_chair_cd
				,ntss_db5_pm_mst_wc.wheel_chair_name AS wheel_chair_name
			FROM mst_wheel_chair ntss_db5_pm_mst_wc
			WHERE ntss_db5_pm_mst_wc.is_personal = ''1''
				AND ntss_db5_pm_mst_wc.facility_cd = @facilityCd
				AND ntss_db5_pm_mst_wc.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
				AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
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
			AND ntss_db5_pm.off_water_info <> ''[]'';'
WHERE sql_cd = '-2080';


-- V_RST_DIALYSIS
UPDATE sys_data_set
SET "sql"=
		'SELECT
			ntss_db6_ppm.pat_id AS patid
			,ntss_db6_ppm.hosp_pat_id AS hosppatid
			,REPLACE(personal_info_decrypt(ntss_db6_ppm.pat_last_name)|| '' '' ||personal_info_decrypt(ntss_db6_ppm.pat_first_name), ''"'', '''') AS names --氏名
		FROM
			pat_personal_main ntss_db6_ppm
		WHERE
			ntss_db6_ppm.is_del = ''0''
			AND ntss_db6_ppm.facility_cd = @facilityCd'
WHERE sql_cd = '-2091';

UPDATE sys_data_set
SET "sql"=
		'WITH ntss_db5_mst_b AS (
			SELECT
				om.ord_no AS ord_no
				,ntss_db5_mst_b.in_hospital_cd_1 AS in_hospital_cd_1
				,ntss_db5_mst_b.bed_name AS bed_name
			FROM ord_main om
			LEFT JOIN mst_bed ntss_db5_mst_b
			ON om.rst_bed_cd = ntss_db5_mst_b.bed_cd
			WHERE ntss_db5_mst_b.facility_cd = @facilityCd
			AND ntss_db5_mst_b.up_date
					BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
					AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
		),
		ntss_db5_mst_k AS (
			SELECT 
				om.ord_no AS ord_no
				,ntss_db5_mst_k.in_hospital_cd_1 AS in_hospital_cd_1
			FROM ord_main om
			LEFT JOIN mst_kur ntss_db5_mst_k
			ON om.rst_kur_cd = ntss_db5_mst_k.kur_cd
			WHERE ntss_db5_mst_k.facility_cd = @facilityCd
			AND ntss_db5_mst_k.up_date 
					BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
					AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
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
				AND om.rst_vital_info IS NOT NULL
				AND om.facility_cd = @facilityCd
				AND om.up_date 
					BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
					AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
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
				AND om.rst_vital_info IS NOT NULL
				AND om.facility_cd = @facilityCd
				AND om.up_date
					BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
					AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
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
			,((((ntss_db5_om.rst_weight_info #>> ''{recrcl_rt}'')::json #>> ''{1}'')::json)::json) #>> ''{rate}'' AS relooprate --再循環率
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
			INNER JOIN rst_vital_info_1
			ON rst_vital_info_1.ord_no = ntss_db5_om.ord_no
			INNER JOIN rst_vital_info_2
			ON rst_vital_info_2.ord_no = ntss_db5_om.ord_no
		WHERE
			ntss_db5_om.is_del = ''0''
			AND ntss_db5_om.facility_cd = @facilityCd
			AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
			AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
			AND ntss_db5_om.pat_id IS NOT NULL;'
WHERE sql_cd = '-2090';


-- V_RST_DIALYSIS_COND
UPDATE sys_data_set
SET "sql"=
		'WITH ntss_db5_om_key AS(
			SELECT
				ntss_db5_om.ord_no AS ord_no,
				ntss_db5_om_value_json.KEY AS keys,
				ntss_db5_om_value_json.value::JSON ->> ''value'' AS value,
				ntss_db5_om_value_json.value::JSON ->> ''value_name_1'' AS value_name_1,
				ntss_db5_om_value_json.value::JSON ->> ''unit'' AS unit
			FROM
				ord_main ntss_db5_om CROSS
			JOIN LATERAL json_object_keys(
					ntss_db5_om.rst_cond_info::JSON
				) rst_ci_keys_json
			INNER JOIN json_each_text(
					ntss_db5_om.rst_cond_info::JSON
				) ntss_db5_om_value_json ON
				ntss_db5_om_value_json.KEY = rst_ci_keys_json
			WHERE
				ntss_db5_om.rst_cond_info IS NOT NULL
				AND ntss_db5_om.facility_cd = @facilityCd
				AND ntss_db5_om.up_date BETWEEN to_date(
					@fromDate,
					''YYYYMMDDHH24MISS''
				) AND to_date(
					@toDate,
					''YYYYMMDDHH24MISS''
				)
		),
		ntss_db5_mst_m AS(
			SELECT
				ntss_db5_mst_m.*
			FROM
				mst_medicine ntss_db5_mst_m
			WHERE
				ntss_db5_mst_m.is_del = ''0''
				AND ntss_db5_mst_m.is_disp = ''1''
				AND ntss_db5_mst_m.facility_cd = @facilityCd
				AND ntss_db5_mst_m.up_date BETWEEN to_date(
					@fromDate,
					''YYYYMMDDHH24MISS''
				) AND to_date(
					@toDate,
					''YYYYMMDDHH24MISS''
				)
		),
		ntss_db5_om_mst_list AS(
			SELECT
				om.ord_no AS ord_no,
				ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2,
				ntss_db5_mst_e.equipment_cd AS equipment_cd_keys
			FROM
				ord_main om
			INNER JOIN ntss_db5_om_key ON
				om.ord_no = ntss_db5_om_key.ord_no
			LEFT JOIN mst_equipment ntss_db5_mst_e ON
				CAST(
					ntss_db5_om_key.keys AS INTEGER
				)= ntss_db5_mst_e.equipment_cd
			WHERE
				ntss_db5_mst_e.facility_cd = @facilityCd
				AND ntss_db5_mst_e.is_del = ''0''
				AND ntss_db5_mst_e.up_date BETWEEN to_date(
					@fromDate,
					''YYYYMMDDHH24MISS''
				) AND to_date(
					@toDate,
					''YYYYMMDDHH24MISS''
				)
		UNION ALL SELECT
				om.ord_no AS ord_no,
				ntss_db5_mst_m.in_hospital_cd_2 AS in_hospital_cd_2,
				ntss_db5_mst_m.medicine_cd AS equipment_cd_keys
			FROM
				ord_main om
			INNER JOIN ntss_db5_om_key ON
				om.ord_no = ntss_db5_om_key.ord_no
			LEFT JOIN mst_medicine ntss_db5_mst_m ON
				CAST(
					ntss_db5_om_key.keys AS INTEGER
				)= ntss_db5_mst_m.medicine_cd
			WHERE
				ntss_db5_mst_m.facility_cd = @facilityCd
				AND om.is_del = ''0''
				AND om.up_date BETWEEN to_date(
					@fromDate,
					''YYYYMMDDHH24MISS''
				) AND to_date(
					@toDate,
					''YYYYMMDDHH24MISS''
				)
		) SELECT
			'''' AS hosppatid --患者ID
		,
			ntss_db5_om.pat_id AS patid,
			ntss_db5_os.treat_date AS dialysisdate --透析日
		,
			ntss_db5_om.ord_no AS dialysisno --透析番号
		,
			CASE
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''1'' THEN ''002'' --治療時間
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''2'' THEN ''003'' --VA
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''3'' THEN ''005'' --目標体重
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''4'' THEN ''007'' --除水量制限
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''5'' THEN ''008'' --ダイアライザ
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''6'' THEN ''009'' --吸着カラム
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''7'' THEN ''039'' --1次膜
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''8'' THEN ''040'' --2次膜
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''9'' THEN '''' --穿刺針(A針)
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''10'' THEN '''' --穿刺針(V針)
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''11'' THEN '''' --穿刺針(SN)
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''12'' THEN ''029'' --シングルニードル使用
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''13'' THEN '''' --血液回路
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''14'' THEN ''010'' --血流量
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''15'' THEN ''018'' --透析液
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''16'' THEN ''019'' --透析液流量
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''17'' THEN ''020'' --透析液量
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''18'' THEN ''021'' --透析液温度
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''19'' THEN ''022'' --補液
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''20'' THEN ''023'' --補液量
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''21'' THEN ''024'' --補液選択
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''22'' THEN ''030'' --補液使用数
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''23'' THEN ''025'' --補液温度
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''24'' THEN ''038'' --補液速度
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''25'' THEN ''011'' --抗凝固剤
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''26'' THEN ''012'' --抗凝固剤ワンショット量
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''27'' THEN ''013'' --抗凝固剤持続速度
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''28'' THEN ''014'' --抗凝固剤持続総量
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''29'' THEN ''015'' --IP使用選択
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''30'' THEN ''031'' --IPスタート
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''31'' THEN ''016'' --IPワンショット量
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''32'' THEN ''017'' --IP速度
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''33'' THEN ''037'' --IP速度最大値
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''34'' THEN ''032'' --自動ワンショット
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''35'' THEN ''033'' --IP電源自動切り
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''36'' THEN ''034'' --IP電源自動切り時間
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''37'' THEN ''035'' --IP電源OKモニタ切り
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''38'' THEN ''036'' --IP電源OKモニタ切り時間
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''39'' THEN ''004'' --DW
			END AS ctlno --透析条件項目コード
			,
			to_char(
				ntss_db5_om.up_date,
				''YYYY-MM-DD hh24:mi:ss''
			) AS updates --更新日時
			,
			CASE
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''1'' THEN ''透析時間'' --治療時間
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''2'' THEN ''VA'' --VA
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''3'' THEN ''目標体重'' --目標体重
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''4'' THEN ''除水量制限'' --除水量制限
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''5'' THEN ''ダイアライザ'' --ダイアライザ
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''6'' THEN ''吸着カラム'' --吸着カラム
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''7'' THEN ''1次膜'' --1次膜
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''8'' THEN ''2次膜'' --2次膜
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''9'' THEN '''' --穿刺針(A針)
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''10'' THEN '''' --穿刺針(V針)
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''11'' THEN '''' --穿刺針(SN)
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''12'' THEN ''シングルニードル使用'' --シングルニードル使用
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''13'' THEN '''' --血液回路
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''14'' THEN ''血流量'' --血流量
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''15'' THEN ''透析液'' --透析液
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''16'' THEN ''透析液流量'' --透析液流量
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''17'' THEN ''透析液量'' --透析液量
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''18'' THEN ''透析液温度'' --透析液温度
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''19'' THEN ''補液'' --補液
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''20'' THEN ''補液量'' --補液量
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''21'' THEN ''補液選択'' --補液選択
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''22'' THEN ''補液使用数'' --補液使用数
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''23'' THEN ''補液温度'' --補液温度
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''24'' THEN ''補液速度'' --補液速度
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''25'' THEN ''抗凝固剤'' --抗凝固剤
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''26'' THEN ''抗凝固剤ワンショット量'' --抗凝固剤ワンショット量
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''27'' THEN ''抗凝固剤持続速度'' --抗凝固剤持続速度
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''28'' THEN ''抗凝固剤持続総量'' --抗凝固剤持続総量
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''29'' THEN ''IP使用選択'' --IP使用選択
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''30'' THEN ''IPスタート'' --IPスタート
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''31'' THEN ''IPワンショット量'' --IPワンショット量
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''32'' THEN ''IP速度'' --IP速度
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''33'' THEN ''IP速度最大値'' --IP速度最大値
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''34'' THEN ''自動ワンショット'' --自動ワンショット
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''35'' THEN ''IP電源自動切り'' --IP電源自動切り
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''36'' THEN ''IP電源自動切り時間'' --IP電源自動切り時間
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''37'' THEN ''IP電源OKモニタ切り'' --IP電源OKモニタ切り
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''38'' THEN ''IP電源OKモニタ切り時間'' --IP電源OKモニタ切り時間
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''39'' THEN ''DW'' --DW
			END AS dialysisitemname --透析条件項目名
		,
			ntss_db5_om_key.value AS value --設定値
		,
			ntss_db5_om_key.value_name_1 AS valuename --設定値
		,
			ntss_db5_om_key.unit AS unit --単位
		,
			SUBSTR(ntss_db5_om_mst_list.in_hospital_cd_2, 0, 20) AS valuecd2 --院内コード2
		FROM
			ord_main ntss_db5_om
		LEFT JOIN ord_schedule ntss_db5_os ON
			ntss_db5_om.ord_no = ntss_db5_os.ord_no
			AND ntss_db5_os.facility_cd = @facilityCd
		INNER JOIN ntss_db5_om_key ON
			ntss_db5_om.ord_no = ntss_db5_om_key.ord_no
		LEFT JOIN ntss_db5_om_mst_list ON
			ntss_db5_om_mst_list.ord_no = ntss_db5_om_key.ord_no
			AND ntss_db5_om_mst_list.equipment_cd_keys = CAST(
				ntss_db5_om_key.keys AS INTEGER
			)
		WHERE
			ntss_db5_om.is_del = ''0''
			AND ntss_db5_om.facility_cd = @facilityCd
			AND ntss_db5_om.up_date BETWEEN to_date(
				@fromDate,
				''YYYYMMDDHH24MISS''
			) AND to_date(
				@toDate,
				''YYYYMMDDHH24MISS''
			)
			AND ntss_db5_om.pat_id IS NOT NULL;'
WHERE sql_cd = '-2100';


-- V_RST_DIALYSIS_COND_CARD
UPDATE sys_data_set
SET "sql"=
		'WITH ntss_db5_om_key AS(
			SELECT
				ntss_db5_om.ord_no AS ord_no,
				ntss_db5_om_value_json.KEY AS keys,
				ntss_db5_om_value_json.value::JSON ->> ''value'' AS value,
				ntss_db5_om_value_json.value::JSON ->> ''value_name_1'' AS value_name_1,
				ntss_db5_om_value_json.value::JSON ->> ''unit'' AS unit
			FROM
				ord_main ntss_db5_om CROSS
			JOIN LATERAL json_object_keys(
					ntss_db5_om.rst_cond_info::JSON
				) rst_ci_keys_json
			INNER JOIN json_each_text(
					ntss_db5_om.rst_cond_info::JSON
				) ntss_db5_om_value_json ON
				ntss_db5_om_value_json.KEY = rst_ci_keys_json
			WHERE
				ntss_db5_om.rst_cond_info IS NOT NULL
				AND ntss_db5_om.facility_cd = @facilityCd
				AND ntss_db5_om.up_date BETWEEN to_date(
					@fromDate,
					''YYYYMMDDHH24MISS''
				) AND to_date(
					@toDate,
					''YYYYMMDDHH24MISS''
				)
		),
		ntss_db5_mst_m AS(
			SELECT
				ntss_db5_mst_m.*
			FROM
				mst_medicine ntss_db5_mst_m
			WHERE
				ntss_db5_mst_m.is_del = ''0''
				AND ntss_db5_mst_m.is_disp = ''1''
				AND ntss_db5_mst_m.facility_cd = @facilityCd
				AND ntss_db5_mst_m.up_date BETWEEN to_date(
					@fromDate,
					''YYYYMMDDHH24MISS''
				) AND to_date(
					@toDate,
					''YYYYMMDDHH24MISS''
				)
		),
		ntss_db5_om_mst_list AS(
			SELECT
				om.ord_no AS ord_no,
				ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1,
				ntss_db5_mst_e.equipment_cd AS equipment_cd_keys
			FROM
				ord_main om
			INNER JOIN ntss_db5_om_key ON
				om.ord_no = ntss_db5_om_key.ord_no
			LEFT JOIN mst_equipment ntss_db5_mst_e ON
				CAST(
					ntss_db5_om_key.keys AS INTEGER
				)= ntss_db5_mst_e.equipment_cd
			WHERE
				ntss_db5_mst_e.facility_cd = @facilityCd
				AND ntss_db5_mst_e.is_del = ''0''
				AND ntss_db5_mst_e.up_date BETWEEN to_date(
					@fromDate,
					''YYYYMMDDHH24MISS''
				) AND to_date(
					@toDate,
					''YYYYMMDDHH24MISS''
				)
		UNION ALL SELECT
				om.ord_no AS ord_no,
				ntss_db5_mst_m.in_hospital_cd_1 AS in_hospital_cd_1,
				ntss_db5_mst_m.medicine_cd AS equipment_cd_keys
			FROM
				ord_main om
			INNER JOIN ntss_db5_om_key ON
				om.ord_no = ntss_db5_om_key.ord_no
			LEFT JOIN mst_medicine ntss_db5_mst_m ON
				CAST(
					ntss_db5_om_key.keys AS INTEGER
				)= ntss_db5_mst_m.medicine_cd
			WHERE
				ntss_db5_mst_m.facility_cd = @facilityCd
				AND om.is_del = ''0''
				AND om.up_date BETWEEN to_date(
					@fromDate,
					''YYYYMMDDHH24MISS''
				) AND to_date(
					@toDate,
					''YYYYMMDDHH24MISS''
				)
		) SELECT
			'''' AS hosppatid --患者ID
		,
			ntss_db5_om.pat_id AS patid,
			ntss_db5_os.treat_date AS dialysisdate --透析日
		,
			ntss_db5_om.ord_no AS dialysisno --透析番号
		,
			CASE
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''1'' THEN ''002'' --治療時間
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''2'' THEN ''003'' --VA
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''3'' THEN ''005'' --目標体重
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''4'' THEN ''007'' --除水量制限
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''5'' THEN ''008'' --ダイアライザ
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''6'' THEN ''009'' --吸着カラム
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''7'' THEN ''039'' --1次膜
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''8'' THEN ''040'' --2次膜
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''9'' THEN '''' --穿刺針(A針)
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''10'' THEN '''' --穿刺針(V針)
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''11'' THEN '''' --穿刺針(SN)
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''12'' THEN ''029'' --シングルニードル使用
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''13'' THEN '''' --血液回路
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''14'' THEN ''010'' --血流量
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''15'' THEN ''018'' --透析液
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''16'' THEN ''019'' --透析液流量
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''17'' THEN ''020'' --透析液量
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''18'' THEN ''021'' --透析液温度
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''19'' THEN ''022'' --補液
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''20'' THEN ''023'' --補液量
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''21'' THEN ''024'' --補液選択
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''22'' THEN ''030'' --補液使用数
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''23'' THEN ''025'' --補液温度
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''24'' THEN ''038'' --補液速度
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''25'' THEN ''011'' --抗凝固剤
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''26'' THEN ''012'' --抗凝固剤ワンショット量
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''27'' THEN ''013'' --抗凝固剤持続速度
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''28'' THEN ''014'' --抗凝固剤持続総量
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''29'' THEN ''015'' --IP使用選択
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''30'' THEN ''031'' --IPスタート
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''31'' THEN ''016'' --IPワンショット量
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''32'' THEN ''017'' --IP速度
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''33'' THEN ''037'' --IP速度最大値
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''34'' THEN ''032'' --自動ワンショット
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''35'' THEN ''033'' --IP電源自動切り
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''36'' THEN ''034'' --IP電源自動切り時間
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''37'' THEN ''035'' --IP電源OKモニタ切り
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''38'' THEN ''036'' --IP電源OKモニタ切り時間
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''39'' THEN ''004'' --DW
			END AS ctlno --透析条件項目コード
			,
			to_char(
				ntss_db5_om.up_date,
				''YYYY-MM-DD hh24:mi:ss''
			) AS updates --更新日時
			,
			CASE
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''1'' THEN ''透析時間'' --治療時間
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''2'' THEN ''VA'' --VA
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''3'' THEN ''目標体重'' --目標体重
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''4'' THEN ''除水量制限'' --除水量制限
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''5'' THEN ''ダイアライザ'' --ダイアライザ
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''6'' THEN ''吸着カラム'' --吸着カラム
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''7'' THEN ''1次膜'' --1次膜
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''8'' THEN ''2次膜'' --2次膜
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''9'' THEN '''' --穿刺針(A針)
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''10'' THEN '''' --穿刺針(V針)
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''11'' THEN '''' --穿刺針(SN)
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''12'' THEN ''シングルニードル使用'' --シングルニードル使用
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''13'' THEN '''' --血液回路
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''14'' THEN ''血流量'' --血流量
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''15'' THEN ''透析液'' --透析液
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''16'' THEN ''透析液流量'' --透析液流量
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''17'' THEN ''透析液量'' --透析液量
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''18'' THEN ''透析液温度'' --透析液温度
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''19'' THEN ''補液'' --補液
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''20'' THEN ''補液量'' --補液量
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''21'' THEN ''補液選択'' --補液選択
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''22'' THEN ''補液使用数'' --補液使用数
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''23'' THEN ''補液温度'' --補液温度
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''24'' THEN ''補液速度'' --補液速度
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''25'' THEN ''抗凝固剤'' --抗凝固剤
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''26'' THEN ''抗凝固剤ワンショット量'' --抗凝固剤ワンショット量
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''27'' THEN ''抗凝固剤持続速度'' --抗凝固剤持続速度
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''28'' THEN ''抗凝固剤持続総量'' --抗凝固剤持続総量
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''29'' THEN ''IP使用選択'' --IP使用選択
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''30'' THEN ''IPスタート'' --IPスタート
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''31'' THEN ''IPワンショット量'' --IPワンショット量
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''32'' THEN ''IP速度'' --IP速度
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''33'' THEN ''IP速度最大値'' --IP速度最大値
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''34'' THEN ''自動ワンショット'' --自動ワンショット
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''35'' THEN ''IP電源自動切り'' --IP電源自動切り
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''36'' THEN ''IP電源自動切り時間'' --IP電源自動切り時間
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''37'' THEN ''IP電源OKモニタ切り'' --IP電源OKモニタ切り
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''38'' THEN ''IP電源OKモニタ切り時間'' --IP電源OKモニタ切り時間
				WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''39'' THEN ''DW'' --DW
			END AS dialysisitemname --透析条件項目名
		,
			ntss_db5_om_key.value AS value --設定値
		,
			ntss_db5_om_key.value_name_1 AS valuename --設定値
		,
			ntss_db5_om_key.unit AS unit --単位
		,
			SUBSTR(ntss_db5_om_mst_list.in_hospital_cd_1, 0, 20) AS valuecd1 --院内コード1
		FROM
			ord_main ntss_db5_om
		LEFT JOIN ord_schedule ntss_db5_os ON
			ntss_db5_om.ord_no = ntss_db5_os.ord_no
			AND ntss_db5_os.facility_cd = @facilityCd
		INNER JOIN ntss_db5_om_key ON
			ntss_db5_om.ord_no = ntss_db5_om_key.ord_no
		LEFT JOIN ntss_db5_om_mst_list ON
			ntss_db5_om_mst_list.ord_no = ntss_db5_om_key.ord_no
			AND ntss_db5_om_mst_list.equipment_cd_keys = CAST(
				ntss_db5_om_key.keys AS INTEGER
			)
		WHERE
			ntss_db5_om.is_del = ''0''
			AND ntss_db5_om.facility_cd = @facilityCd
			AND ntss_db5_om.up_date BETWEEN to_date(
				@fromDate,
				''YYYYMMDDHH24MISS''
			) AND to_date(
				@toDate,
				''YYYYMMDDHH24MISS''
			)
			AND ntss_db5_om.pat_id IS NOT NULL;'
WHERE sql_cd = '-2110';


-- V_RST_DIALYSIS_EQUIP
UPDATE sys_data_set
SET "sql"=
		'WITH ntss_db5_mst_e AS (
			SELECT
				ntss_db5_om.ord_no AS ord_no
				,ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1
				,ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
			FROM ord_main ntss_db5_om
				CROSS JOIN LATERAL json_array_elements(ntss_db5_om.rst_equip_info ::json) ntss_db5_om_eqi_json
				LEFT JOIN mst_equipment ntss_db5_mst_e
				ON cast(ntss_db5_mst_e.equipment_cd as char(10)) = cast(ntss_db5_om_eqi_json ->> ''cd'' as char(10))
			WHERE ntss_db5_om.facility_cd = @facilityCd
			AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
			AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
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
			AND ntss_db5_om.pat_id IS NOT NULL;'
WHERE sql_cd = '-2120';


-- V_RST_DIALYSIS_MEDI
UPDATE sys_data_set
SET "sql"=
		'WITH ntss_db5_om_value AS (
			SELECT
				ntss_db5_om.ord_no AS ord_no
				,ntss_db5_om_rci_json.value::json #>> ''{value}'' AS value
			FROM
				ord_main ntss_db5_om
				LEFT JOIN json_each_text(ntss_db5_om.rst_cond_info::json) ntss_db5_om_rci_json ON TRUE
			WHERE ntss_db5_om.facility_cd = @facilityCd
			AND ntss_db5_om_rci_json.value::json #>> ''{value}'' IS NOT NULL
			AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
			AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
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
			AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
			AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
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
			AND ntss_db5_om.pat_id IS NOT NULL;'
WHERE sql_cd = '-2130';


-- V_RST_DIALYSIS_MEDI_CARD
UPDATE sys_data_set
SET "sql"=
		'WITH ord AS (
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
			AND up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
			AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
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
				AND mix.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
				AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
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
			AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
			AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
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
			AND ntss_db5_om.pat_id IS NOT NULL;'
WHERE sql_cd = '-2140';


-- V_RST_RECEIPT_MEMO_DIALYSIS
UPDATE sys_data_set
SET "sql"=
		'WITH ntss_db5_list1 AS (
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
			AND ntss_db6_ppm1.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
			AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
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
			AND ntss_db6_ppm2.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
			AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
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
			AND ntss_db6_ppm.pat_id IS NOT NULL;'
WHERE sql_cd = '-2160';

UPDATE sys_data_set
SET "sql"=
		'SELECT
			ntss_db5_mdd.dialysis_difficulty_cd AS dialdiffcd
			,ntss_db5_mdd.in_hospital_cd_1 AS codes --コード
			,ntss_db5_mdd.up_date AS code_update --コード更新日時
			,ntss_db5_mdd.dialysis_difficulty_name AS itemname --項目名称
			,ntss_db5_mdd.in_hospital_cd_1 AS inhospitalcd --院内コード
			,ntss_db5_mdd.in_hospital_cd_2 AS inhospitalcd2 --院内コード
		FROM
			mst_dialysis_difficulty ntss_db5_mdd
		WHERE  ntss_db5_mdd.is_del=''0''
			AND ntss_db5_mdd.facility_cd = @facilityCd
			AND ntss_db5_mdd.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
			AND to_date( @toDate, ''YYYYMMDDHH24MISS'' );'
WHERE sql_cd = '-2161';

UPDATE sys_data_set
SET "sql"=
		'SELECT
			ntss_db5_mdd.dialysis_difficulty_cd AS dialdiffcd2
			,ntss_db5_mdd.up_date AS maindialdiff --主たる透析困難
		FROM
			mst_dialysis_difficulty ntss_db5_mdd
		WHERE ntss_db5_mdd.is_del=''0''
			AND ntss_db5_mdd.facility_cd = @facilityCd
			AND ntss_db5_mdd.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
			AND to_date( @toDate, ''YYYYMMDDHH24MISS'' );'
WHERE sql_cd = '-2162';


-- V_RST_RECEIPT_MEMO_ADDITION
UPDATE sys_data_set
SET "sql"=
		'WITH ntss_db5_list1 AS (
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
			AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
			AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
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
			AND ntss_db5_om.pat_id IS NOT NULL;'
WHERE sql_cd = '-2164';


-- V_SCH_DIALYSIS_PLAN
UPDATE sys_data_set
SET "sql"=
		'with ntss_db5_om_1 as (
			SELECT
				ntss_db5_om_1.ord_no AS ord_no
				,ntss_db5_om_1.pat_id
				,ntss_db5_om_1.treat_date AS treat_date
				,COUNT( ntss_db5_om_1.treat_date ) AS treat_date_count
			FROM
				ord_main ntss_db5_om_1
			WHERE 1=1
				AND ntss_db5_om_1.facility_cd = @facilityCd
				AND ntss_db5_om_1.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
				AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
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
			AND to_date( @toDate, ''YYYYMMDDHH24MISS'' );'
WHERE sql_cd = '-2170';


-- V_SCH_DIALYSIS_PLAN_CARD
UPDATE sys_data_set
SET "sql"=
		'with ntss_db5_om_1 as (
			SELECT
				ntss_db5_om_1.ord_no AS ord_no
				,ntss_db5_om_1.pat_id
				,ntss_db5_om_1.treat_date AS treat_date
				,COUNT( ntss_db5_om_1.treat_date ) AS treat_date_count
			FROM
				ord_main ntss_db5_om_1
			WHERE 1=1
				AND ntss_db5_om_1.facility_cd = @facilityCd
				AND ntss_db5_om_1.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
				AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
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
			AND ntss_db5_om.pat_id IS NOT NULL;'
WHERE sql_cd = '-2180';


-- V_IND_DIALYSIS_COND
UPDATE sys_data_set
SET "sql"= 
		'with ntss_db5_mst_v as (
			SELECT
				ntss_db5_mst_v.*
			FROM
				mst_va ntss_db5_mst_v
			WHERE 
				ntss_db5_mst_v.is_del = ''0''
				AND ntss_db5_mst_v.is_disp = ''1''
				AND ntss_db5_mst_v.facility_cd = @facilityCd
				AND ntss_db5_mst_v.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
				AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
				
		),
		ntss_db5_mst_d as (
			SELECT
				ntss_db5_mst_d.*
			FROM
				mst_dialyzer ntss_db5_mst_d
			WHERE 
				ntss_db5_mst_d.is_del = ''0''
				AND ntss_db5_mst_d.is_disp = ''1''
				AND ntss_db5_mst_d.facility_cd = @facilityCd
				AND ntss_db5_mst_d.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
				AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
		),
		ntss_db5_mst_e as (
			SELECT
				ntss_db5_mst_e.*
			FROM
				mst_equipment ntss_db5_mst_e
			WHERE 
				ntss_db5_mst_e.is_del = ''0''
				AND ntss_db5_mst_e.is_disp = ''1''
				AND ntss_db5_mst_e.facility_cd = @facilityCd
				AND ntss_db5_mst_e.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
				AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
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
				AND ntss_db5_mst_m.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
				AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
		),
		ntss_db5_mst_t as (
			SELECT
				ntss_db5_mst_t.*
			FROM
				mst_treatment ntss_db5_mst_t
			WHERE 
				ntss_db5_mst_t.is_del = ''0''
				AND ntss_db5_mst_t.is_disp = ''1''
				AND ntss_db5_mst_t.facility_cd = @facilityCd
				AND ntss_db5_mst_t.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
				AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
		),
		ntss_db5_mst_list as (
			--VA
			SELECT
				''003'' AS fnw_code
				,''VA'' AS fnw_name
				,om.ind_cond_info::json #>> ''{2,value}'' AS value
				,om.ind_cond_info::json #>> ''{2,value_name_1}'' AS value_name_1
				,om.ind_cond_info::json #>> ''{2,unit}'' AS unit
				,om.ord_no AS ord_no
				,ntss_db5_mst_v.in_hospital_cd_2 AS in_hospital_cd_2
			FROM
				ord_main om
			LEFT JOIN ntss_db5_mst_v
				ON TO_NUMBER( om.ind_cond_info::json #>> ''{2,value}'', ''99999999'' ) = ntss_db5_mst_v.va_cd
			WHERE ntss_db5_mst_v.facility_cd = @facilityCd
				AND om.ind_cond_info::json #>> ''{2,value}'' IS NOT NULL
				AND om.is_del = ''0''
				AND om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
				AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
			UNION ALL
			--ダイアライザ
			SELECT
				''008'' AS fnw_code
				,''ダイアライザ'' AS fnw_name
				,om.ind_cond_info::json #>> ''{5,value}'' AS value
				,om.ind_cond_info::json #>> ''{5,value_name_1}'' AS value_name_1
				,om.ind_cond_info::json #>> ''{5,unit}'' AS unit
				,om.ord_no AS ord_no
				,ntss_db5_mst_d.in_hospital_cd_2 AS in_hospital_cd_2
			FROM
				ord_main om
			LEFT JOIN ntss_db5_mst_d
				ON TO_NUMBER( om.ind_cond_info::json #>> ''{5,value}'', ''99999999'' ) = ntss_db5_mst_d.dialyzer_cd
			WHERE ntss_db5_mst_d.facility_cd = @facilityCd
				AND om.ind_cond_info::json #>> ''{5,value}'' IS NOT NULL
				AND om.is_del = ''0''
				AND om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
				AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
			UNION ALL
			--吸着カラム
			SELECT
				''009'' AS fnw_code
				,''吸着カラム'' AS fnw_name
				,om.ind_cond_info::json #>> ''{6,value}'' AS value
				,om.ind_cond_info::json #>> ''{6,value_name_1}'' AS value_name_1
				,om.ind_cond_info::json #>> ''{6,unit}'' AS unit
				,om.ord_no AS ord_no
				,ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
			FROM
				ord_main om
			LEFT JOIN ntss_db5_mst_e
				ON TO_NUMBER( om.ind_cond_info::json #>> ''{6,value}'', ''99999999'' ) = ntss_db5_mst_e.equipment_cd
			WHERE ntss_db5_mst_e.facility_cd = @facilityCd
				AND om.ind_cond_info::json #>> ''{6,value}'' IS NOT NULL
				AND om.is_del = ''0''
				AND om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
				AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
			UNION ALL
			--1次膜
			SELECT
				''039'' AS fnw_code
				,''1次膜'' AS fnw_name
				,om.ind_cond_info::json #>> ''{7,value}'' AS value
				,om.ind_cond_info::json #>> ''{7,value_name_1}'' AS value_name_1
				,om.ind_cond_info::json #>> ''{7,unit}'' AS unit
				,om.ord_no AS ord_no
				,ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
			FROM
				ord_main om
			LEFT JOIN ntss_db5_mst_e
				ON TO_NUMBER( om.ind_cond_info::json #>> ''{7,value}'', ''99999999'' ) = ntss_db5_mst_e.equipment_cd
			WHERE ntss_db5_mst_e.facility_cd = @facilityCd
				AND om.ind_cond_info::json #>> ''{7,value}'' IS NOT NULL
				AND om.is_del = ''0''
				AND om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
				AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
			UNION ALL
			--2次膜
			SELECT
				''040'' AS fnw_code
				,''2次膜'' AS fnw_name
				,om.ind_cond_info::json #>> ''{8,value}'' AS value
				,om.ind_cond_info::json #>> ''{8,value_name_1}'' AS value_name_1
				,om.ind_cond_info::json #>> ''{8,unit}'' AS unit
				,om.ord_no AS ord_no
				,ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
			FROM
				ord_main om
			LEFT JOIN ntss_db5_mst_e
				ON TO_NUMBER( om.ind_cond_info::json #>> ''{8,value}'', ''99999999'' ) = ntss_db5_mst_e.equipment_cd
			WHERE ntss_db5_mst_e.facility_cd = @facilityCd
				AND om.ind_cond_info::json #>> ''{8,value}'' IS NOT NULL
				AND om.is_del = ''0''
				AND om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
				AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
			UNION ALL
			--穿刺針(A針)
			SELECT
				'''' AS fnw_code
				,''穿刺針(A針)'' AS fnw_name
				,om.ind_cond_info::json #>> ''{9,value}'' AS value
				,om.ind_cond_info::json #>> ''{9,value_name_1}'' AS value_name_1
				,om.ind_cond_info::json #>> ''{9,unit}'' AS unit
				,om.ord_no AS ord_no
				,ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
			FROM
				ord_main om
			LEFT JOIN ntss_db5_mst_e
				ON TO_NUMBER( om.ind_cond_info::json #>> ''{9,value}'', ''99999999'' ) = ntss_db5_mst_e.equipment_cd
			WHERE ntss_db5_mst_e.facility_cd = @facilityCd
				AND om.ind_cond_info::json #>> ''{9,value}'' IS NOT NULL
				AND om.is_del = ''0''
				AND om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
				AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
			UNION ALL
			--穿刺針(V針)
			SELECT
				'''' AS fnw_code
				,''穿刺針(V針)'' AS fnw_name
				,om.ind_cond_info::json #>> ''{10,value}'' AS value
				,om.ind_cond_info::json #>> ''{10,value_name_1}'' AS value_name_1
				,om.ind_cond_info::json #>> ''{10,unit}'' AS unit
				,om.ord_no AS ord_no
				,ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
			FROM
				ord_main om
			LEFT JOIN ntss_db5_mst_e
				ON TO_NUMBER( om.ind_cond_info::json #>> ''{10,value}'', ''99999999'' ) = ntss_db5_mst_e.equipment_cd
			WHERE ntss_db5_mst_e.facility_cd = @facilityCd
				AND om.ind_cond_info::json #>> ''{10,value}'' IS NOT NULL
				AND om.is_del = ''0''
				AND om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
				AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
			UNION ALL
			--穿刺針(SN)
			SELECT
				'''' AS fnw_code
				,''穿刺針(SN)'' AS fnw_name
				,om.ind_cond_info::json #>> ''{11,value}'' AS value
				,om.ind_cond_info::json #>> ''{11,value_name_1}'' AS value_name_1
				,om.ind_cond_info::json #>> ''{11,unit}'' AS unit
				,om.ord_no AS ord_no
				,ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
			FROM
				ord_main om
			LEFT JOIN ntss_db5_mst_e
				ON TO_NUMBER( om.ind_cond_info::json #>> ''{11,value}'', ''99999999'' ) = ntss_db5_mst_e.equipment_cd
			WHERE ntss_db5_mst_e.facility_cd = @facilityCd
				AND om.ind_cond_info::json #>> ''{11,value}'' IS NOT NULL
				AND om.is_del = ''0''
				AND om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
				AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
			UNION ALL
			--血液回路
			SELECT
				'''' AS fnw_code
				,''血液回路'' AS fnw_name
				,om.ind_cond_info::json #>> ''{13,value}'' AS value
				,om.ind_cond_info::json #>> ''{13,value_name_1}'' AS value_name_1
				,om.ind_cond_info::json #>> ''{13,unit}'' AS unit
				,om.ord_no AS ord_no
				,ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
			FROM
				ord_main om
			LEFT JOIN ntss_db5_mst_e
				ON TO_NUMBER( om.ind_cond_info::json #>> ''{13,value}'', ''99999999'' ) = ntss_db5_mst_e.equipment_cd
			WHERE ntss_db5_mst_e.facility_cd = @facilityCd
				AND om.ind_cond_info::json #>> ''{13,value}'' IS NOT NULL
				AND om.is_del = ''0''
				AND om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
				AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
			UNION ALL
			--透析液
			SELECT
				''018'' AS fnw_code
				,''透析液'' AS fnw_name
				,om.ind_cond_info::json #>> ''{15,value}'' AS value
				,om.ind_cond_info::json #>> ''{15,value_name_1}'' AS value_name_1
				,om.ind_cond_info::json #>> ''{15,unit}'' AS unit
				,om.ord_no AS ord_no
				,ntss_db5_mst_m.in_hospital_cd_2 AS in_hospital_cd_2
			FROM
				ord_main om
			LEFT JOIN ntss_db5_mst_m
				ON TO_NUMBER( om.ind_cond_info::json #>> ''{15,value}'', ''99999999'' ) = ntss_db5_mst_m.medicine_cd
			WHERE ntss_db5_mst_m.facility_cd = @facilityCd
				AND om.ind_cond_info::json #>> ''{15,value}'' IS NOT NULL
				AND om.is_del = ''0''
				AND om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
				AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
			UNION ALL
			--補液
			SELECT
				''022'' AS fnw_code
				,''補液'' AS fnw_name
				,om.ind_cond_info::json #>> ''{19,value}'' AS value
				,om.ind_cond_info::json #>> ''{19,value_name_1}'' AS value_name_1
				,om.ind_cond_info::json #>> ''{19,unit}'' AS unit
				,om.ord_no AS ord_no
				,ntss_db5_mst_m.in_hospital_cd_2 AS in_hospital_cd_2
			FROM
				ord_main om
			LEFT JOIN ntss_db5_mst_m
				ON TO_NUMBER( om.ind_cond_info::json #>> ''{19,value}'', ''99999999'' ) = ntss_db5_mst_m.medicine_cd
			WHERE ntss_db5_mst_m.facility_cd = @facilityCd
				AND om.ind_cond_info::json #>> ''{19,value}'' IS NOT NULL
				AND om.is_del = ''0''
				AND om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
				AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
			UNION ALL
			--抗凝固剤ワンショット量
			SELECT
				''012'' AS fnw_code
				,''抗凝固剤ワンショット量'' AS fnw_name
				,om.ind_cond_info::json #>> ''{26,value}'' AS value
				,om.ind_cond_info::json #>> ''{26,value_name_1}'' AS value_name_1
				,om.ind_cond_info::json #>> ''{26,unit}'' AS unit
				,om.ord_no AS ord_no
				,ntss_db5_mst_m.in_hospital_cd_2 AS in_hospital_cd_2
			FROM
				ord_main om
			LEFT JOIN ntss_db5_mst_m
				ON TO_NUMBER( om.ind_cond_info::json #>> ''{26,value}'', ''99999999'' ) = ntss_db5_mst_m.medicine_cd
			WHERE ntss_db5_mst_m.facility_cd = @facilityCd
				AND om.ind_cond_info::json #>> ''{26,value}'' IS NOT NULL
				AND om.is_del = ''0''
				AND om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
				AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
		),
		ntss_db5_om_1 as (
			SELECT
				ntss_db5_om_1.ord_no AS ord_no
				,ntss_db5_om_1.pat_id
				,ntss_db5_om_1.treat_date AS treat_date
				,COUNT( ntss_db5_om_1.treat_date ) AS treat_date_count
			FROM
				ord_main ntss_db5_om_1
			WHERE 1=1
				AND ntss_db5_om_1.facility_cd = @facilityCd
				AND ntss_db5_om_1.treat_date IS NOT NULL 
				AND ntss_db5_om_1.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
				AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
			GROUP BY
				ntss_db5_om_1.ord_no,
				ntss_db5_om_1.pat_id,
				ntss_db5_om_1.treat_date
		)
		SELECT
			'''' AS hosppatid --患者ID
			,ntss_db5_om.pat_id AS patid
			,ntss_db5_om.treat_date AS dialysisdate --透析日
			,CASE
				WHEN ntss_db5_om_1.treat_date_count > 1
				THEN 1
				ELSE 0
			 END AS plural --同日複数回
			,ntss_db5_mst_list.fnw_code AS ctlno --透析条件項目コード
			,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
			,ntss_db5_mst_list.fnw_name AS dialysisitemname --透析条件項目名
			,ntss_db5_mst_list.value AS value --設定値
			,ntss_db5_mst_list.value_name_1 AS valuename --名称
			,ntss_db5_mst_list.unit AS unit --単位
			,ntss_db5_mst_list.in_hospital_cd_2 AS valuecd2 --院内コード2
			,'''' AS indicatorcd --指示者
			,ntss_db5_om_iic_json ->> ''ind_user_id''	 AS userid
			,CASE
				WHEN ntss_db5_om.treat_type = 0
				THEN ''1''
				ELSE ''0''
			 END AS opeindplan --予定作成区分
		FROM
			ord_main ntss_db5_om
			INNER JOIN ntss_db5_mst_list
			ON ntss_db5_mst_list.ord_no = ntss_db5_om.ord_no
			INNER JOIN ntss_db5_om_1
			ON ntss_db5_om_1.ord_no = ntss_db5_om.ord_no
			CROSS JOIN LATERAL json_array_elements(ntss_db5_om.ind_ind_comment_info ::json) ntss_db5_om_iic_json
		WHERE ntss_db5_om.is_del = ''0''
			AND ntss_db5_om.facility_cd = @facilityCd
			AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
			AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
			AND ntss_db5_om.pat_id IS NOT NULL;'
WHERE sql_cd = '-2190';


-- V_IND_DIALYSIS_EQUIP
UPDATE sys_data_set
SET "sql"=
		'WITH ntss_db5_om_1 AS (
			SELECT
				ntss_db5_om_1.ord_no AS ord_no
				,ntss_db5_om_1.pat_id
				,ntss_db5_om_1.treat_date AS treat_date
				,COUNT( ntss_db5_om_1.treat_date ) AS treat_date_count
			FROM
				ord_main ntss_db5_om_1
			WHERE 1=1
				AND ntss_db5_om_1.facility_cd = @facilityCd
				AND ntss_db5_om_1.treat_date IS NOT NULL
				AND ntss_db5_om_1.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
				AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
			GROUP BY
				ntss_db5_om_1.ord_no,
				ntss_db5_om_1.pat_id,
				ntss_db5_om_1.treat_date
		),
		ntss_db5_mst_e AS (
			SELECT
				ntss_db5_mst_e.*
			FROM
				mst_equipment ntss_db5_mst_e
			WHERE 
				ntss_db5_mst_e.is_del = ''0''
				AND ntss_db5_mst_e.is_disp = ''1''
				AND ntss_db5_mst_e.facility_cd = @facilityCd
				AND ntss_db5_mst_e.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
				AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
		),
		ntss_db5_mst_list AS (
			SELECT
				ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1
				,''0'' AS puncture_class
				,ntss_db5_mst_e.in_hospital_cd_1 || cast(ntss_db5_om_rei_json ->> ''class_name'' as char(20)) AS class_name
				,ntss_db5_mst_e.equipment_name || cast(ntss_db5_om_rei_json ->> ''name'' as char(20)) AS names
				,ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
				,om.ord_no AS ord_no
				,ntss_db5_om_rei_json ->> ''amount'' AS amount
				,ntss_db5_om_iei_json ->> ''unit'' AS unit
				,ntss_db5_om_iei_json ->> ''comment'' AS comments
			FROM
				ord_main om
				LEFT JOIN ntss_db5_mst_e
				ON TO_NUMBER( om.ind_cond_info::json #>> ''{6,value}'', ''99999999'' ) = ntss_db5_mst_e.equipment_cd
				CROSS JOIN LATERAL json_array_elements(om.rst_equip_info ::json) ntss_db5_om_rei_json
				CROSS JOIN LATERAL json_array_elements(om.ind_equip_info ::json) ntss_db5_om_iei_json
			WHERE ntss_db5_mst_e.facility_cd = @facilityCd
				AND om.ind_cond_info::json #>> ''{6,value}'' IS NOT NULL
				AND om.is_del = ''0''
				AND om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
				AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
			UNION ALL
			SELECT
				ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1
				,''0'' AS puncture_class
				,ntss_db5_mst_e.in_hospital_cd_1 || cast(ntss_db5_om_rei_json ->> ''class_name'' as char(20)) AS class_name
				,ntss_db5_mst_e.equipment_name || cast(ntss_db5_om_rei_json ->> ''name'' as char(20)) AS names
				,ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
				,om.ord_no AS ord_no
				,ntss_db5_om_rei_json ->> ''amount'' AS amount
				,ntss_db5_om_iei_json ->> ''unit'' AS unit
				,ntss_db5_om_iei_json ->> ''comment'' AS comments
			FROM
				ord_main om
				LEFT JOIN ntss_db5_mst_e
				ON TO_NUMBER( om.ind_cond_info::json #>> ''{7,value}'', ''99999999'' ) = ntss_db5_mst_e.equipment_cd
				CROSS JOIN LATERAL json_array_elements(om.rst_equip_info ::json) ntss_db5_om_rei_json
				CROSS JOIN LATERAL json_array_elements(om.ind_equip_info ::json) ntss_db5_om_iei_json
			WHERE ntss_db5_mst_e.facility_cd = @facilityCd
				AND om.ind_cond_info::json #>> ''{7,value}'' IS NOT NULL
				AND om.is_del = ''0''
				AND om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
				AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
			UNION ALL
			SELECT
				ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1
				,''0'' AS puncture_class
				,ntss_db5_mst_e.in_hospital_cd_1 || cast(ntss_db5_om_rei_json ->> ''class_name'' as char(20)) AS class_name
				,ntss_db5_mst_e.equipment_name || cast(ntss_db5_om_rei_json ->> ''name'' as char(20)) AS names
				,ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
				,om.ord_no AS ord_no
				,ntss_db5_om_rei_json ->> ''amount'' AS amount
				,ntss_db5_om_iei_json ->> ''unit'' AS unit
				,ntss_db5_om_iei_json ->> ''comment'' AS comments
			FROM
				ord_main om
				LEFT JOIN ntss_db5_mst_e
				ON TO_NUMBER( om.ind_cond_info::json #>> ''{8,value}'', ''99999999'' ) = ntss_db5_mst_e.equipment_cd
				CROSS JOIN LATERAL json_array_elements(om.rst_equip_info ::json) ntss_db5_om_rei_json
				CROSS JOIN LATERAL json_array_elements(om.ind_equip_info ::json) ntss_db5_om_iei_json
			WHERE ntss_db5_mst_e.facility_cd = @facilityCd
				AND om.ind_cond_info::json #>> ''{8,value}'' IS NOT NULL
				AND om.is_del = ''0''
				AND om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
				AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
			UNION ALL
			SELECT
				ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1
				,''1'' AS puncture_class
				,ntss_db5_mst_e.in_hospital_cd_1 || cast(ntss_db5_om_rei_json ->> ''class_name'' as char(20)) AS class_name
				,ntss_db5_mst_e.equipment_name || cast(ntss_db5_om_rei_json ->> ''name'' as char(20)) AS names
				,ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
				,om.ord_no AS ord_no
				,ntss_db5_om_rei_json ->> ''amount'' AS amount
				,ntss_db5_om_iei_json ->> ''unit'' AS unit
				,ntss_db5_om_iei_json ->> ''comment'' AS comments
			FROM
				ord_main om
				LEFT JOIN ntss_db5_mst_e
				ON TO_NUMBER( om.ind_cond_info::json #>> ''{9,value}'', ''99999999'' ) = ntss_db5_mst_e.equipment_cd
				CROSS JOIN LATERAL json_array_elements(om.rst_equip_info ::json) ntss_db5_om_rei_json
				CROSS JOIN LATERAL json_array_elements(om.ind_equip_info ::json) ntss_db5_om_iei_json
			WHERE ntss_db5_mst_e.facility_cd = @facilityCd
				AND om.ind_cond_info::json #>> ''{9,value}'' IS NOT NULL
				AND om.is_del = ''0''
				AND om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
				AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
			UNION ALL
			SELECT
				ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1
				,''2'' AS puncture_class
				,ntss_db5_mst_e.in_hospital_cd_1 || cast(ntss_db5_om_rei_json ->> ''class_name'' as char(20)) AS class_name
				,ntss_db5_mst_e.equipment_name || cast(ntss_db5_om_rei_json ->> ''name'' as char(20)) AS names
				,ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
				,om.ord_no AS ord_no
				,ntss_db5_om_rei_json ->> ''amount'' AS amount
				,ntss_db5_om_iei_json ->> ''unit'' AS unit
				,ntss_db5_om_iei_json ->> ''comment'' AS comments
			FROM
				ord_main om
				LEFT JOIN ntss_db5_mst_e
				ON TO_NUMBER( om.ind_cond_info::json #>> ''{10,value}'', ''99999999'' ) = ntss_db5_mst_e.equipment_cd
				CROSS JOIN LATERAL json_array_elements(om.rst_equip_info ::json) ntss_db5_om_rei_json
				CROSS JOIN LATERAL json_array_elements(om.ind_equip_info ::json) ntss_db5_om_iei_json
			WHERE ntss_db5_mst_e.facility_cd = @facilityCd
				AND om.ind_cond_info::json #>> ''{10,value}'' IS NOT NULL
				AND om.is_del = ''0''
				AND om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
				AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
			UNION ALL
			SELECT
				ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1
				,''3'' AS puncture_class
				,ntss_db5_mst_e.in_hospital_cd_1 || cast(ntss_db5_om_rei_json ->> ''class_name'' as char(20)) AS class_name
				,ntss_db5_mst_e.equipment_name || cast(ntss_db5_om_rei_json ->> ''name'' as char(20)) AS names
				,ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
				,om.ord_no AS ord_no
				,ntss_db5_om_rei_json ->> ''amount'' AS amount
				,ntss_db5_om_iei_json ->> ''unit'' AS unit
				,ntss_db5_om_iei_json ->> ''comment'' AS comments
			FROM
				ord_main om
				LEFT JOIN ntss_db5_mst_e
				ON TO_NUMBER( om.ind_cond_info::json #>> ''{11,value}'', ''99999999'' ) = ntss_db5_mst_e.equipment_cd
				CROSS JOIN LATERAL json_array_elements(om.rst_equip_info ::json) ntss_db5_om_rei_json
				CROSS JOIN LATERAL json_array_elements(om.ind_equip_info ::json) ntss_db5_om_iei_json
			WHERE ntss_db5_mst_e.facility_cd = @facilityCd
				AND om.ind_cond_info::json #>> ''{11,value}'' IS NOT NULL
				AND om.is_del = ''0''
				AND om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
				AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
			UNION ALL
			SELECT
				ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1
				,''0'' AS puncture_class
				,ntss_db5_mst_e.in_hospital_cd_1 || cast(ntss_db5_om_rei_json ->> ''class_name'' as char(20)) AS class_name
				,ntss_db5_mst_e.equipment_name || cast(ntss_db5_om_rei_json ->> ''name'' as char(20)) AS names
				,ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
				,om.ord_no AS ord_no
				,ntss_db5_om_rei_json ->> ''amount'' AS amount
				,ntss_db5_om_iei_json ->> ''unit'' AS unit
				,ntss_db5_om_iei_json ->> ''comment'' AS comments
			FROM
				ord_main om
				LEFT JOIN ntss_db5_mst_e
				ON TO_NUMBER( om.ind_cond_info::json #>> ''{12,value}'', ''99999999'' ) = ntss_db5_mst_e.equipment_cd
				CROSS JOIN LATERAL json_array_elements(om.rst_equip_info ::json) ntss_db5_om_rei_json
				CROSS JOIN LATERAL json_array_elements(om.ind_equip_info ::json) ntss_db5_om_iei_json
			WHERE ntss_db5_mst_e.facility_cd = @facilityCd
				AND om.ind_cond_info::json #>> ''{12,value}'' IS NOT NULL
				AND om.is_del = ''0''
				AND om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
				AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
			UNION ALL
			SELECT
				ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1
				,''0'' AS puncture_class
				,ntss_db5_mst_e.in_hospital_cd_1 || cast(ntss_db5_om_rei_json ->> ''class_name'' as char(20)) AS class_name
				,ntss_db5_mst_e.equipment_name || cast(ntss_db5_om_rei_json ->> ''name'' as char(20)) AS names
				,ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
				,om.ord_no AS ord_no
				,ntss_db5_om_rei_json ->> ''amount'' AS amount
				,ntss_db5_om_iei_json ->> ''unit'' AS unit
				,ntss_db5_om_iei_json ->> ''comment'' AS comments
			FROM
				ord_main om
				LEFT JOIN ntss_db5_mst_e
				ON TO_NUMBER( om.ind_cond_info::json #>> ''{13,value}'', ''99999999'' ) = ntss_db5_mst_e.equipment_cd
				CROSS JOIN LATERAL json_array_elements(om.rst_equip_info ::json) ntss_db5_om_rei_json
				CROSS JOIN LATERAL json_array_elements(om.ind_equip_info ::json) ntss_db5_om_iei_json
			WHERE ntss_db5_mst_e.facility_cd = @facilityCd
				AND om.ind_cond_info::json #>> ''{13,value}'' IS NOT NULL
				AND om.is_del = ''0''
				AND om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
				AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
			UNION ALL
			SELECT
				ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1
				,'''' AS puncture_class
				,'''' AS class_name
				,'''' AS names
				,ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
				,om.ord_no AS ord_no
				,'''' AS amount
				,'''' AS unit
				,'''' AS comments
			FROM
				ord_main om
				CROSS JOIN LATERAL json_array_elements(om.rst_equip_info ::json) ntss_db5_om_rei_json
				LEFT JOIN ntss_db5_mst_e
				ON ntss_db5_om_rei_json ->> ''cd'' = cast(ntss_db5_mst_e.equipment_cd as char(4))
			WHERE ntss_db5_mst_e.facility_cd = @facilityCd
				AND om.is_del = ''0''
				AND om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
				AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
		)
		SELECT
			'''' AS hosppatid --患者ID
			,ntss_db5_om.pat_id AS patid
			,ntss_db5_om.treat_date AS dialysisdate --透析日
			,CASE
				WHEN ntss_db5_om_1.treat_date_count > 1
				THEN 1
				ELSE 0
			 END AS plural --同日複数回
			,row_number() over(ORDER BY ntss_db5_om.treat_date DESC) AS ctlno --項目番号
			,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
			,ntss_db5_mst_list.in_hospital_cd_1 AS equipcd --医療材料コード(院内コード1)
			,ntss_db5_mst_list.in_hospital_cd_2 AS equipcd2 --医療材料コード(院内コード2)
			,ntss_db5_mst_list.class_name AS equipclassname --医療材料分類名
			,SUBSTR(ntss_db5_mst_list.names, 0, 14) AS equipname --医療材料名
			,ntss_db5_mst_list.puncture_class AS punctureclass --医療材料名
			,ntss_db5_mst_list.amount AS amount --数量
			,ntss_db5_mst_list.unit AS unit --数量
			,ntss_db5_mst_list.comments AS comments --コメント
			,'''' AS indicatorcd --指示者
			,ntss_db5_om_iic_json ->> ''ind_user_id''	 AS userid
			,CASE
				WHEN ntss_db5_om.treat_type = 0
				THEN ''1''
				ELSE ''0''
			 END AS opeindplan --予定作成区分
		FROM
			ord_main ntss_db5_om
			INNER JOIN ntss_db5_om_1
			ON ntss_db5_om_1.ord_no = ntss_db5_om.ord_no
			INNER JOIN ntss_db5_mst_list
			ON ntss_db5_mst_list.ord_no = ntss_db5_om.ord_no
			CROSS JOIN LATERAL json_array_elements(ntss_db5_om.ind_ind_comment_info ::json) ntss_db5_om_iic_json
		WHERE ntss_db5_om.is_del = ''0''
			AND ntss_db5_om.facility_cd = @facilityCd
			AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
			AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
			AND ntss_db5_om.pat_id IS NOT NULL;'
WHERE sql_cd = '-2200';


-- V_IND_DIALYSIS_MEDI
UPDATE sys_data_set
SET "sql"= 
		'WITH ntss_db5_om_1 AS (
			SELECT
				ntss_db5_om_1.ord_no AS ord_no
				,ntss_db5_om_1.pat_id
				,ntss_db5_om_1.treat_date AS treat_date
				,COUNT( ntss_db5_om_1.treat_date ) AS treat_date_count
			FROM
				ord_main ntss_db5_om_1
			WHERE 1=1
				AND ntss_db5_om_1.facility_cd = @facilityCd
				AND ntss_db5_om_1.treat_date IS NOT NULL
				AND ntss_db5_om_1.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
				AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
			GROUP BY
				ntss_db5_om_1.ord_no,
				ntss_db5_om_1.pat_id,
				ntss_db5_om_1.treat_date
		),
		ntss_db5_mst_m AS (
			SELECT
				ntss_db5_om.ord_no AS ord_no
				,ntss_db5_mst_m.in_hospital_cd_1 AS in_hospital_cd_1
				,ntss_db5_mst_m.in_hospital_cd_2 AS in_hospital_cd_2
			FROM ord_main ntss_db5_om
				CROSS JOIN LATERAL json_array_elements(ntss_db5_om.ind_medi_info ::json) ntss_db5_om_imi_json
				LEFT JOIN mst_medicine ntss_db5_mst_m
				ON cast(ntss_db5_mst_m.medicine_cd as char(10)) = cast(ntss_db5_om_imi_json ->> ''cd'' as char(10))
			WHERE ntss_db5_om.facility_cd = @facilityCd
			AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
			AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
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
			AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
			AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
		)
		SELECT
			'''' AS hosppatid --患者ID
			,ntss_db5_om.pat_id AS patid
			,ntss_db5_om.treat_date AS dialysisdate --透析日
			,CASE
				WHEN ntss_db5_om_1.treat_date_count > 1
				THEN 1
				ELSE 0
			 END AS plural --同日複数回
			,row_number() over(ORDER BY ntss_db5_om.treat_date DESC) AS ctlno --項目番号
			,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
			,ntss_db5_mst_m.in_hospital_cd_1 AS medicinecd --薬剤コード(院内コード1)
			,ntss_db5_mst_m.in_hospital_cd_2 AS medicinecd2 --薬剤コード(院内コード2)
			,ntss_db5_om_imi_json ->> ''name'' AS medicinename --薬剤名
			,ntss_db5_om_imi_json ->> ''class_name'' AS mediclassname --薬剤分類名
			,ntss_db5_om_imi_json ->> ''amount'' AS amount --数量
			,ntss_db5_om_imi_json ->> ''unit'' AS unit --単位
			,ntss_db5_om_imi_json ->> ''timing_name'' AS timingname --投与時間帯名
			,ntss_db5_mst_p.in_hospital_cd_1 AS procedurecd --手技コード(院内コード1)
			,ntss_db5_mst_p.in_hospital_cd_2 AS procedurecd2 --手技コード(院内コード2)
			,ntss_db5_om_imi_json ->> ''procedure_name'' AS procedurename --手技名
			,ntss_db5_om_imi_json ->> ''comment'' AS comments --コメント
			,'''' AS indicatorcd --指示者
			,ntss_db5_om_iic_json ->> ''ind_user_id'' AS userid
			,CASE
				WHEN ntss_db5_om.treat_type = 0
				THEN ''1''
				ELSE ''0''
			 END AS opeindplan --予定作成区分
		FROM
			ord_main ntss_db5_om
			INNER JOIN ntss_db5_om_1
			ON ntss_db5_om_1.ord_no = ntss_db5_om.ord_no
			INNER JOIN ntss_db5_mst_m
			ON ntss_db5_mst_m.ord_no = ntss_db5_om.ord_no
			INNER JOIN ntss_db5_mst_p
			ON ntss_db5_mst_p.ord_no = ntss_db5_om.ord_no
			CROSS JOIN LATERAL json_array_elements(ntss_db5_om.ind_ind_comment_info ::json) ntss_db5_om_iic_json
			CROSS JOIN LATERAL json_array_elements(ntss_db5_om.ind_medi_info ::json) ntss_db5_om_imi_json
		WHERE ntss_db5_om.is_del = ''0''
			AND ntss_db5_om.facility_cd = @facilityCd
			AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
			AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
			AND ntss_db5_om.pat_id IS NOT NULL;'
WHERE sql_cd = '-2210';


-- V_IND_DIALYSIS_ADD
UPDATE sys_data_set
SET "sql"= 
		'with ntss_db5_om_1 as (
			SELECT
				ntss_db5_om_1.ord_no AS ord_no
				,ntss_db5_om_1.pat_id
				,ntss_db5_om_1.treat_date AS treat_date
				,COUNT( ntss_db5_om_1.treat_date ) AS treat_date_count
			FROM
				ord_main ntss_db5_om_1
			WHERE 1=1
				AND ntss_db5_om_1.facility_cd = @facilityCd
				AND ntss_db5_om_1.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
			AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
			GROUP BY
				ntss_db5_om_1.ord_no,
				ntss_db5_om_1.pat_id,
				ntss_db5_om_1.treat_date
		)
		SELECT
			'''' AS hosppatid --患者ID
			,ntss_db5_om.pat_id AS patid
			,ntss_db5_om.treat_date AS dialysisdate --透析日
			,CASE
				WHEN ntss_db5_om_1.treat_date_count > 1
				THEN 1
				ELSE 0
			 END AS plural --同日複数回
			 ,row_number() over(ORDER BY ntss_db5_om.treat_date DESC) AS ctlno --項目番号
			 ,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update --更新日時
			 ,ntss_db5_om_iic_json ->> ''content'' AS addition --指示簿指示
			 ,'''' AS indicatorcd --指示者
			 ,ntss_db5_om_iic_json ->> ''ind_user_id'' AS userid
			 ,CASE
				WHEN ntss_db5_om.treat_type = 0
				THEN ''1''
				ELSE ''0''
			 END AS opeindplan --予定作成区分
		FROM
			ord_main ntss_db5_om
			INNER JOIN ntss_db5_om_1
			ON ntss_db5_om_1.ord_no = ntss_db5_om.ord_no
			cross join lateral json_array_elements(ntss_db5_om.ind_ind_comment_info ::json) ntss_db5_om_iic_json
		WHERE ntss_db5_om.is_del = ''0''
			AND ntss_db5_om.facility_cd = @facilityCd
			AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
			AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
			AND ntss_db5_om.pat_id IS NOT NULL
			AND ntss_db5_om_1.treat_date IS NOT NULL;'
WHERE sql_cd = '-2220';


-- V_PAT_RECIPE
UPDATE sys_data_set
SET "sql"=
		'WITH ntss_db5_op_pd_json_1 AS (
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
				AND ntss_db5_op.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
				AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
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
				ON cast(ntss_db5_op_mst_m.medicine_cd AS varchar(10)) = ntss_db5_op_pd_json ->> ''medicine_cd''
			WHERE ntss_db5_op_pd_json ->> ''type'' = ''1''
				AND  ntss_db5_op_pd_json ->> ''medicine_type'' = ''1''
				AND ntss_db5_op.facility_cd =  @facilityCd
				AND ntss_db5_op.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
				AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
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
				ON cast(ntss_db5_op_mst_m.medicine_cd AS varchar(10)) = ntss_db5_op_pd_json ->> ''medicine_cd''
			WHERE ntss_db5_op_pd_json ->> ''type'' IN (''2'',''3'',''4'',''5'')
				AND ntss_db5_op.facility_cd =  @facilityCd
				AND ntss_db5_op.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
				AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
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
				AND ntss_db5_op.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
				AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
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
			AND to_date( @toDate, ''YYYYMMDDHH24MISS'' );'
WHERE sql_cd = '-2230';

UPDATE sys_data_set
SET "sql"= 
		'SELECT
			ntss_db5_mst_opp.insu_dr_id AS userid
			,ntss_db5_mst_opp.pat_id AS patid
			,personal_info_decrypt(ntss_db5_mst_opp.insu_dr_name) AS prescriptername
			,ntss_db5_mst_opp.remarks AS note
			,'''' AS prescriptercd
		FROM
			ord_personal_prescription ntss_db5_mst_opp
		WHERE 
			ntss_db5_mst_opp.is_del = ''0''
		AND ntss_db5_mst_opp.facility_cd = @facilityCd
		AND ntss_db5_mst_opp.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
		AND to_date( @toDate, ''YYYYMMDDHH24MISS'' );'
WHERE sql_cd = '-2231';


-- V_DIALYSIS_VITAL
UPDATE sys_data_set
SET "sql"=
		'with ntss_db5_mm_1 as (
			SELECT
				ntss_db5_mm_1.facility_cd
				,ntss_db5_mm_1.ord_no AS ord_no
				,ntss_db5_mm_1.data_type AS data_type
				,ntss_db5_mm_1.monitor_data AS monitor_data
				,min(ntss_db5_mm_1.occur_date) AS occur_date
				,min(ntss_db5_mm_1.up_date) AS up_date
			FROM
				mni_monitor ntss_db5_mm_1
			WHERE
				ntss_db5_mm_1.ord_no IS NOT NULL
				AND ntss_db5_mm_1.data_type IN(''2'',''4'',''5'',''6'',''-1'')
				AND ntss_db5_mm_1.facility_cd = @facilityCd
				AND ntss_db5_mm_1.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
				AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
			GROUP BY
				ntss_db5_mm_1.facility_cd,
				ntss_db5_mm_1.ord_no,
				ntss_db5_mm_1.data_type,
				ntss_db5_mm_1.monitor_data
		)
		SELECT
			'''' AS hosppatid --患者ID
			,ntss_db5_om.pat_id AS patid
			,to_char(ntss_db5_om.rst_start_date, ''YYYY-MM-DD hh24:mi:ss'') AS startdate --開始日時
			,to_char(ntss_db5_mm_1.occur_date, ''YYYY-MM-DD hh24:mi:ss'') AS occurdate --発生日時
			,CASE
				WHEN ntss_db5_mm_1.data_type IN (''2'',''4'',''5'',''6'') THEN ntss_db5_mm_1.monitor_data ->> ''90''
			 END AS bpmax --最高血圧
			,CASE
				WHEN ntss_db5_mm_1.data_type IN (''2'',''4'',''5'',''6'') THEN ntss_db5_mm_1.monitor_data ->> ''91''
			 END AS bpmin --最低血圧
			,CASE
				WHEN ntss_db5_mm_1.data_type IN (''2'',''4'',''5'',''6'') THEN ntss_db5_mm_1.monitor_data ->> ''92''
			 END AS bpave --平均血圧
			,CASE
				WHEN ntss_db5_mm_1.data_type IN (''2'',''4'',''5'',''6'') THEN ntss_db5_mm_1.monitor_data ->> ''93''
			 END AS pulse --脈拍
			,CASE
				WHEN ntss_db5_mm_1.data_type IN (''2'',''4'',''5'',''6'') THEN ntss_db5_mm_1.monitor_data ->> ''93''
			 END AS temperature --体温
			,CASE
				WHEN ntss_db5_mm_1.data_type IN (''2'',''4'',''5'',''6'') THEN ntss_db5_mm_1.monitor_data ->> ''-1''
			 END AS bloodsugarlevel --血糖値
			,to_char(ntss_db5_mm_1.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update --更新日時
			,ntss_db5_mm_1.ord_no AS diadysisno --透析番号
			,ntss_db5_mm_1.data_type AS bpclass --血圧区分
		FROM
			ord_main ntss_db5_om
			INNER JOIN ntss_db5_mm_1
			ON ntss_db5_mm_1.ord_no = ntss_db5_om.ord_no
		WHERE ntss_db5_om.is_del = ''0''
			AND ntss_db5_om.facility_cd = @facilityCd
			AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
			AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
			AND ntss_db5_om.pat_id IS NOT NULL;'
WHERE sql_cd = '-2240';



-- V_DIALYSIS_COMP
UPDATE sys_data_set
SET "sql"= 
		'WITH ntss_db5_mst_mm AS (
			SELECT
				ntss_db5_medicine_mix.medicine_mix_cd AS medicinemixcd
				,ntss_db5_medicine_mix.in_hospital_cd_1 AS inhospitalcd1
				,ntss_db5_medicine_mix.in_hospital_cd_2 AS inhospitalcd2
			FROM mst_medicine_mix ntss_db5_medicine_mix
			WHERE ntss_db5_medicine_mix.facility_cd = @facilityCd
			AND ntss_db5_medicine_mix.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' ) 
			AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
		),
		ntss_db5_mst_m AS (
			SELECT
				ntss_db5_medicine.medicine_cd AS medicinecd
				,ntss_db5_medicine.in_hospital_cd_1 AS inhospitalcd1
				,ntss_db5_medicine.in_hospital_cd_2 AS inhospitalcd2
			FROM mst_medicine ntss_db5_medicine
			WHERE ntss_db5_medicine.facility_cd = @facilityCd
			AND ntss_db5_medicine.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' ) 
			AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
		),
		ntss_db5_mst_p AS (
			SELECT
				ntss_db5_procedure.procedure_cd AS procedurecd
				,ntss_db5_procedure.in_hospital_cd_a1 AS inhospitalcda1
				,ntss_db5_procedure.in_hospital_cd_a2 AS inhospitalcda2
			FROM mst_procedure ntss_db5_procedure
			WHERE ntss_db5_procedure.facility_cd = @facilityCd
			AND ntss_db5_procedure.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' ) 
			AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
		)
		SELECT
			'''' AS hosppatid --患者ID
			,ntss_db5_om.pat_id AS patid
			,COALESCE(to_char(to_timestamp(ntss_db5_om_rci_json ->> ''occur_date'', ''YYYY-MM-DD hh24:mi:ss''), ''YYYY-MM-DD hh24:mi:ss''),
					to_char(to_timestamp(ntss_db5_om_rti_json ->> ''occur_date'', ''YYYY-MM-DD hh24:mi:ss''), ''YYYY-MM-DD hh24:mi:ss'')) AS occurdate --発生日時
			,CASE
				WHEN ntss_db5_om_rti_json ->> ''medicine_type'' = ''2'' THEN ''0''
				WHEN ntss_db5_om_rti_json ->> ''medicine_type'' = ''1'' THEN ''1''
				WHEN ntss_db5_om_rti_json ->> ''medicine_type'' IS NULL THEN ''2''
				WHEN ntss_db5_om_rti_json ->> ''medicine_type'' = ''3'' THEN ''3''
			 END AS measureclass --区分
			,ntss_db5_om_rci_json ->> ''comp_cd'' AS reqcode --愁訴コード
			,ntss_db5_om_rci_json ->> ''complaint'' AS complaint --愁訴内容
			,ntss_db5_om_rti_json ->> ''treat_name'' AS treatname --処置名
			,CASE
				WHEN ntss_db5_om_rci_json ->> ''medicine_type'' = ''2'' THEN ntss_db5_mst_mm.inhospitalcd1
				WHEN ntss_db5_om_rti_json ->> ''medicine_type'' = ''1'' THEN ntss_db5_mst_m.inhospitalcd1
			 END AS medicinecd1 --薬剤コード1
			 ,CASE
				WHEN ntss_db5_om_rci_json ->> ''medicine_type'' = ''2'' THEN ntss_db5_mst_mm.inhospitalcd2
				WHEN ntss_db5_om_rti_json ->> ''medicine_type'' = ''1'' THEN ntss_db5_mst_m.inhospitalcd2
			 END AS medicinecd2 --薬剤コード2
			 ,ntss_db5_om_rti_json ->> ''medicine_name'' AS medicinename --薬剤名称
			 ,ntss_db5_om_rti_json ->> ''amount'' AS amount --数量
			 ,ntss_db5_om_rti_json ->> ''unit'' AS unit --単位
			 ,ntss_db5_om_rti_json ->> ''procedure_name'' AS procedurename --手技名
			 ,ntss_db5_mst_p.inhospitalcda1 AS procedurecd1 --手技コード1
			 ,ntss_db5_mst_p.inhospitalcda2 AS procedurecd2 --手技コード2
			 ,SUBSTR(ntss_db5_om_tsi_json ->> ''treat_staff_name'', 0, 10) treatpersonname --処置者名
			 ,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
		FROM
			ord_main ntss_db5_om
			cross join lateral json_array_elements(ntss_db5_om.rst_complaint_info ::json) ntss_db5_om_rci_json
			cross join lateral json_array_elements(ntss_db5_om.rst_treatment_info ::json) ntss_db5_om_rti_json
			LEFT JOIN ntss_db5_mst_mm
			ON cast(ntss_db5_mst_mm.medicinemixcd AS char(4)) = ntss_db5_om_rti_json ->> ''treat_medicine_cd''
			LEFT JOIN ntss_db5_mst_m
			ON cast(ntss_db5_mst_m.medicinecd AS char(4)) = ntss_db5_om_rti_json ->> ''treat_medicine_cd''
			LEFT JOIN ntss_db5_mst_p
			ON cast(ntss_db5_mst_p.procedurecd AS char(4)) = ntss_db5_om_rti_json ->> ''procedure_cd''
			cross join lateral json_array_elements(ntss_db5_om.rst_treat_staff_info ::json) ntss_db5_om_tsi_json
		WHERE ntss_db5_om.is_del = ''0''
			AND ntss_db5_om.facility_cd = @facilityCd 
			AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' ) 
			AND to_date( @toDate, ''YYYYMMDDHH24MISS'' );'
WHERE sql_cd = '-2250';


-- V_MNT_WATER_SURVEY
UPDATE sys_data_set
SET "sql"= 
		'SELECT
			ntss_db5_om_sd_json ->> ''point_cd'' AS surveypointcd --調査箇所コード
			,ntss_db5_mnt_wsp.point_name AS surveypointname --調査箇所名
			,to_char(ntss_db5_mnt_wsp.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
			,to_char(ntss_db5_mnt_ws.inspection_date, ''YYYYMMDD'') AS checkdate --調査日
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
			AND to_date( @toDate, ''YYYYMMDDHH24MISS'' );'
WHERE sql_cd = '-2291';


-- V_PAT_STATUS
UPDATE sys_data_set
SET "sql"= 
		'WITH ntss_db5_om_mnt_mr AS (
			SELECT 
				ntss_db5_om.pat_id AS pat_id
				,ntss_db5_om_mnt_mr.event_reg_date AS event_reg_date
			FROM 
				ord_main ntss_db5_om
				LEFT JOIN mnt_motion_record ntss_db5_om_mnt_mr
				ON ntss_db5_om_mnt_mr.motion_record_no = ntss_db5_om.rst_machine_no
				AND ntss_db5_om_mnt_mr.machine_record_cd = ''F407''
			 WHERE ntss_db5_om.facility_cd = @facilityCd
			 AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
			 AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
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
			 AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
			 AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
		)
		SELECT
			'''' AS hosppatid --患者ID
			,ntss_db5_om.pat_id AS patid
			,ntss_db5_om.treat_date AS dialysisdate --透析日
			,to_char(ntss_db5_om.rst_start_date, ''HH24MISS'') AS dialysistime --透析開始時刻
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
			AND ntss_db5_om.rst_weight_info IS NOT NULL;'
WHERE sql_cd = '-2300';


-- V_PAT_LIFE_LIST
UPDATE sys_data_set
SET "sql"= 
		'SELECT
			ntss_db6_ppm.hosp_pat_id AS hosppatid
			,ntss_db6_ppm.pat_id AS patid
			,SUBSTR(personal_info_decrypt(ntss_db6_ppm.pat_last_name) || '' '' || personal_info_decrypt(ntss_db6_ppm.pat_first_name), 0, 20) AS names
			,SUBSTR(personal_info_decrypt(ntss_db6_ppm.pat_last_name_kana) || '' '' || personal_info_decrypt(ntss_db6_ppm.pat_first_name_kana), 0, 20) AS namekana
		FROM
			pat_personal_main ntss_db6_ppm
		WHERE ntss_db6_ppm.is_del = ''0''
			AND ntss_db6_ppm.facility_cd = @facilityCd;'
WHERE sql_cd = '-2311';


-- V_DIALYSIS_MONI
UPDATE sys_data_set
SET "sql"=
		'WITH ntss_db5_mm AS (
			SELECT
				ntss_db5_om.ord_no AS ord_no
				,ntss_db5_mm.occur_date AS occur_date
				,ntss_db5_mm.monitor_data AS monitor_data
				,ntss_db5_mm.up_date AS up_date
			FROM
				ord_main ntss_db5_om
				LEFT JOIN mni_monitor ntss_db5_mm
				ON ntss_db5_mm.ord_no = ntss_db5_om.ord_no
			WHERE ntss_db5_mm.facility_cd = @facilityCd
				AND ntss_db5_mm.data_type = ''1''
				AND ntss_db5_mm.is_del = ''0''
				AND ntss_db5_mm.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
				AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
		)
		SELECT
			ntss_db5_mst_b.in_hospital_cd_1 AS bedno --ベッド番号
			,ntss_db5_mst_m.machine_serial AS deviceno --装置番号
			,to_char(ntss_db5_mm.occur_date, ''YYYY-MM-DD hh24:mi:ss'') AS occurdate --発生日時
			,'''' AS hosppatid --患者ID
			,ntss_db5_om.pat_id AS patid
			,''1'' AS moniname1 --モニタ項目名1
			,ntss_db5_mm.monitor_data #>> ''{1}'' AS moniitem1 --モニタ項目値1
			,''2'' AS moniname2 --モニタ項目名2
			,ntss_db5_mm.monitor_data #>> ''{2}'' AS moniitem2 --モニタ項目値2
			,''3'' AS moniname3 --モニタ項目名3
			,ntss_db5_mm.monitor_data #>> ''{3}'' AS moniitem3 --モニタ項目値3
			,''4'' AS moniname4 --モニタ項目名4
			,ntss_db5_mm.monitor_data #>> ''{4}'' AS moniitem4 --モニタ項目値4
			,''5'' AS moniname5 --モニタ項目名5
			,ntss_db5_mm.monitor_data #>> ''{5}'' AS moniitem5 --モニタ項目値5
			,''6'' AS moniname6 --モニタ項目名6
			,ntss_db5_mm.monitor_data #>> ''{6}'' AS moniitem6 --モニタ項目値6
			,''7'' AS moniname7 --モニタ項目名7
			,ntss_db5_mm.monitor_data #>> ''{7}'' AS moniitem7 --モニタ項目値7
			,''8'' AS moniname8 --モニタ項目名8
			,ntss_db5_mm.monitor_data #>> ''{8}'' AS moniitem8 --モニタ項目値8
			,''9'' AS moniname9 --モニタ項目名9
			,ntss_db5_mm.monitor_data #>> ''{9}'' AS moniitem9 --モニタ項目値9
			,''10'' AS moniname10 --モニタ項目名10
			,ntss_db5_mm.monitor_data #>> ''{10}'' AS moniitem10 --モニタ項目値10
			,''11'' AS moniname11 --モニタ項目名11
			,ntss_db5_mm.monitor_data #>> ''{11}'' AS moniitem11 --モニタ項目値11
			,''12'' AS moniname12 --モニタ項目名12
			,ntss_db5_mm.monitor_data #>> ''{12}'' AS moniitem12 --モニタ項目値12
			,''13'' AS moniname13 --モニタ項目名13
			,ntss_db5_mm.monitor_data #>> ''{13}'' AS moniitem13 --モニタ項目値13
			,''14'' AS moniname14 --モニタ項目名14
			,ntss_db5_mm.monitor_data #>> ''{14}'' AS moniitem14 --モニタ項目値14
			,''15'' AS moniname15 --モニタ項目名15
			,ntss_db5_mm.monitor_data #>> ''{15}'' AS moniitem15 --モニタ項目値15
			,''16'' AS moniname16 --モニタ項目名16
			,ntss_db5_mm.monitor_data #>> ''{16}'' AS moniitem16 --モニタ項目値16
			,''17'' AS moniname17 --モニタ項目名17
			,ntss_db5_mm.monitor_data #>> ''{17}'' AS moniitem17 --モニタ項目値17
			,''18'' AS moniname18 --モニタ項目名18
			,ntss_db5_mm.monitor_data #>> ''{18}'' AS moniitem18 --モニタ項目値18
			,''19'' AS moniname19 --モニタ項目名19
			,ntss_db5_mm.monitor_data #>> ''{19}'' AS moniitem19 --モニタ項目値19
			,''20'' AS moniname20 --モニタ項目名20
			,ntss_db5_mm.monitor_data #>> ''{20}'' AS moniitem20 --モニタ項目値20
			,''21'' AS moniname21 --モニタ項目名21
			,ntss_db5_mm.monitor_data #>> ''{21}'' AS moniitem21 --モニタ項目値21
			,''22'' AS moniname22 --モニタ項目名22
			,ntss_db5_mm.monitor_data #>> ''{22}'' AS moniitem22 --モニタ項目値22
			,''23'' AS moniname23 --モニタ項目名23
			,ntss_db5_mm.monitor_data #>> ''{23}'' AS moniitem23 --モニタ項目値23
			,''24'' AS moniname24 --モニタ項目名24
			,ntss_db5_mm.monitor_data #>> ''{24}'' AS moniitem24 --モニタ項目値24
			,''25'' AS moniname25 --モニタ項目名25
			,ntss_db5_mm.monitor_data #>> ''{25}'' AS moniitem25 --モニタ項目値25
			,''26'' AS moniname26 --モニタ項目名26
			,ntss_db5_mm.monitor_data #>> ''{26}'' AS moniitem26 --モニタ項目値26
			,''27'' AS moniname27 --モニタ項目名27
			,ntss_db5_mm.monitor_data #>> ''{27}'' AS moniitem27 --モニタ項目値27
			,''28'' AS moniname28 --モニタ項目名28
			,ntss_db5_mm.monitor_data #>> ''{28}'' AS moniitem28 --モニタ項目値28
			,''29'' AS moniname29 --モニタ項目名29
			,ntss_db5_mm.monitor_data #>> ''{29}'' AS moniitem29 --モニタ項目値29
			,''30'' AS moniname30 --モニタ項目名30
			,ntss_db5_mm.monitor_data #>> ''{30}'' AS moniitem30 --モニタ項目値30
			,''31'' AS moniname31 --モニタ項目名31
			,ntss_db5_mm.monitor_data #>> ''{31}'' AS moniitem31 --モニタ項目値31
			,''32'' AS moniname32 --モニタ項目名32
			,ntss_db5_mm.monitor_data #>> ''{32}'' AS moniitem32 --モニタ項目値32
			,''33'' AS moniname33 --モニタ項目名33
			,ntss_db5_mm.monitor_data #>> ''{33}'' AS moniitem33 --モニタ項目値33
			,''34'' AS moniname34 --モニタ項目名34
			,ntss_db5_mm.monitor_data #>> ''{34}'' AS moniitem34 --モニタ項目値34
			,''35'' AS moniname35 --モニタ項目名35
			,ntss_db5_mm.monitor_data #>> ''{35}'' AS moniitem35 --モニタ項目値35
			,''36'' AS moniname36 --モニタ項目名36
			,ntss_db5_mm.monitor_data #>> ''{36}'' AS moniitem36 --モニタ項目値36
			,''37'' AS moniname37 --モニタ項目名37
			,ntss_db5_mm.monitor_data #>> ''{37}'' AS moniitem37 --モニタ項目値37
			,''38'' AS moniname38 --モニタ項目名38
			,ntss_db5_mm.monitor_data #>> ''{38}'' AS moniitem38 --モニタ項目値38
			,''39'' AS moniname39 --モニタ項目名39
			,ntss_db5_mm.monitor_data #>> ''{39}'' AS moniitem39 --モニタ項目値39
			,''40'' AS moniname40 --モニタ項目名40
			,ntss_db5_mm.monitor_data #>> ''{40}'' AS moniitem40 --モニタ項目値40
			,''41'' AS moniname41 --モニタ項目名41
			,ntss_db5_mm.monitor_data #>> ''{41}'' AS moniitem41 --モニタ項目値41
			,''42'' AS moniname42 --モニタ項目名42
			,ntss_db5_mm.monitor_data #>> ''{42}'' AS moniitem42 --モニタ項目値42
			,''43'' AS moniname43 --モニタ項目名43
			,ntss_db5_mm.monitor_data #>> ''{43}'' AS moniitem43 --モニタ項目値43
			,''44'' AS moniname44 --モニタ項目名44
			,ntss_db5_mm.monitor_data #>> ''{44}'' AS moniitem44 --モニタ項目値44
			,''45'' AS moniname45 --モニタ項目名45
			,ntss_db5_mm.monitor_data #>> ''{45}'' AS moniitem45 --モニタ項目値45
			,''46'' AS moniname46 --モニタ項目名46
			,ntss_db5_mm.monitor_data #>> ''{46}'' AS moniitem46 --モニタ項目値46
			,''47'' AS moniname47 --モニタ項目名47
			,ntss_db5_mm.monitor_data #>> ''{47}'' AS moniitem47 --モニタ項目値47
			,''48'' AS moniname48 --モニタ項目名48
			,ntss_db5_mm.monitor_data #>> ''{48}'' AS moniitem48 --モニタ項目値48
			,''49'' AS moniname49 --モニタ項目名49
			,ntss_db5_mm.monitor_data #>> ''{49}'' AS moniitem49 --モニタ項目値49
			,''50'' AS moniname50 --モニタ項目名50
			,ntss_db5_mm.monitor_data #>> ''{50}'' AS moniitem50 --モニタ項目値50
			,''51'' AS moniname51 --モニタ項目名51
			,ntss_db5_mm.monitor_data #>> ''{51}'' AS moniitem51 --モニタ項目値51
			,''52'' AS moniname52 --モニタ項目名52
			,ntss_db5_mm.monitor_data #>> ''{52}'' AS moniitem52 --モニタ項目値52
			,''53'' AS moniname53 --モニタ項目名53
			,ntss_db5_mm.monitor_data #>> ''{53}'' AS moniitem53 --モニタ項目値53
			,''54'' AS moniname54 --モニタ項目名54
			,ntss_db5_mm.monitor_data #>> ''{54}'' AS moniitem54 --モニタ項目値54
			,''55'' AS moniname55 --モニタ項目名55
			,ntss_db5_mm.monitor_data #>> ''{55}'' AS moniitem55 --モニタ項目値55
			,''56'' AS moniname56 --モニタ項目名56
			,ntss_db5_mm.monitor_data #>> ''{56}'' AS moniitem56 --モニタ項目値56
			,''57'' AS moniname57 --モニタ項目名57
			,ntss_db5_mm.monitor_data #>> ''{57}'' AS moniitem57 --モニタ項目値57
			,''58'' AS moniname58 --モニタ項目名58
			,ntss_db5_mm.monitor_data #>> ''{58}'' AS moniitem58 --モニタ項目値58
			,''59'' AS moniname59 --モニタ項目名59
			,ntss_db5_mm.monitor_data #>> ''{59}'' AS moniitem59 --モニタ項目値59
			,''60'' AS moniname60 --モニタ項目名60
			,ntss_db5_mm.monitor_data #>> ''{60}'' AS moniitem60 --モニタ項目値60
			,''61'' AS moniname61 --モニタ項目名61
			,ntss_db5_mm.monitor_data #>> ''{61}'' AS moniitem61 --モニタ項目値61
			,''62'' AS moniname62 --モニタ項目名62
			,ntss_db5_mm.monitor_data #>> ''{62}'' AS moniitem62 --モニタ項目値62
			,''63'' AS moniname63 --モニタ項目名63
			,ntss_db5_mm.monitor_data #>> ''{63}'' AS moniitem63 --モニタ項目値63
			,''64'' AS moniname64 --モニタ項目名64
			,ntss_db5_mm.monitor_data #>> ''{64}'' AS moniitem64 --モニタ項目値64
			,''65'' AS moniname65 --モニタ項目名65
			,ntss_db5_mm.monitor_data #>> ''{65}'' AS moniitem65 --モニタ項目値65
			,''66'' AS moniname66 --モニタ項目名66
			,ntss_db5_mm.monitor_data #>> ''{66}'' AS moniitem66 --モニタ項目値66
			,''67'' AS moniname67 --モニタ項目名67
			,ntss_db5_mm.monitor_data #>> ''{67}'' AS moniitem67 --モニタ項目値67
			,''68'' AS moniname68 --モニタ項目名68
			,ntss_db5_mm.monitor_data #>> ''{68}'' AS moniitem68 --モニタ項目値68
			,''69'' AS moniname69 --モニタ項目名69
			,ntss_db5_mm.monitor_data #>> ''{69}'' AS moniitem69 --モニタ項目値69
			,''70'' AS moniname70 --モニタ項目名70
			,ntss_db5_mm.monitor_data #>> ''{70}'' AS moniitem70 --モニタ項目値70
			,''71'' AS moniname71 --モニタ項目名71
			,ntss_db5_mm.monitor_data #>> ''{71}'' AS moniitem71 --モニタ項目値71
			,''72'' AS moniname72 --モニタ項目名72
			,ntss_db5_mm.monitor_data #>> ''{72}'' AS moniitem72 --モニタ項目値72
			,''73'' AS moniname73 --モニタ項目名73
			,ntss_db5_mm.monitor_data #>> ''{73}'' AS moniitem73 --モニタ項目値73
			,''74'' AS moniname74 --モニタ項目名74
			,ntss_db5_mm.monitor_data #>> ''{74}'' AS moniitem74 --モニタ項目値74
			,''75'' AS moniname75 --モニタ項目名75
			,ntss_db5_mm.monitor_data #>> ''{75}'' AS moniitem75 --モニタ項目値75
			,''76'' AS moniname76 --モニタ項目名76
			,ntss_db5_mm.monitor_data #>> ''{76}'' AS moniitem76 --モニタ項目値76
			,''77'' AS moniname77 --モニタ項目名77
			,ntss_db5_mm.monitor_data #>> ''{77}'' AS moniitem77 --モニタ項目値77
			,''78'' AS moniname78 --モニタ項目名78
			,ntss_db5_mm.monitor_data #>> ''{78}'' AS moniitem78 --モニタ項目値78
			,''79'' AS moniname79 --モニタ項目名79
			,ntss_db5_mm.monitor_data #>> ''{79}'' AS moniitem79 --モニタ項目値79
			,''80'' AS moniname80 --モニタ項目名80
			,ntss_db5_mm.monitor_data #>> ''{80}'' AS moniitem80 --モニタ項目値80
			,''81'' AS moniname81 --モニタ項目名81
			,ntss_db5_mm.monitor_data #>> ''{81}'' AS moniitem81 --モニタ項目値81
			,''82'' AS moniname82 --モニタ項目名82
			,ntss_db5_mm.monitor_data #>> ''{82}'' AS moniitem82 --モニタ項目値82
			,''83'' AS moniname83 --モニタ項目名83
			,ntss_db5_mm.monitor_data #>> ''{83}'' AS moniitem83 --モニタ項目値83
			,''84'' AS moniname84 --モニタ項目名84
			,ntss_db5_mm.monitor_data #>> ''{84}'' AS moniitem84 --モニタ項目値84
			,''85'' AS moniname85 --モニタ項目名85
			,ntss_db5_mm.monitor_data #>> ''{85}'' AS moniitem85 --モニタ項目値85
			,''86'' AS moniname86 --モニタ項目名86
			,ntss_db5_mm.monitor_data #>> ''{86}'' AS moniitem86 --モニタ項目値86
			,''87'' AS moniname87 --モニタ項目名87
			,ntss_db5_mm.monitor_data #>> ''{87}'' AS moniitem87 --モニタ項目値87
			,''88'' AS moniname88 --モニタ項目名88
			,ntss_db5_mm.monitor_data #>> ''{88}'' AS moniitem88 --モニタ項目値88
			,''89'' AS moniname89 --モニタ項目名89
			,ntss_db5_mm.monitor_data #>> ''{89}'' AS moniitem89 --モニタ項目値89
			,''90'' AS moniname90 --モニタ項目名90
			,ntss_db5_mm.monitor_data #>> ''{90}'' AS moniitem90 --モニタ項目値90
			,''91'' AS moniname91 --モニタ項目名91
			,ntss_db5_mm.monitor_data #>> ''{91}'' AS moniitem91 --モニタ項目値91
			,''92'' AS moniname92 --モニタ項目名92
			,ntss_db5_mm.monitor_data #>> ''{92}'' AS moniitem92 --モニタ項目値92
			,''93'' AS moniname93 --モニタ項目名93
			,ntss_db5_mm.monitor_data #>> ''{93}'' AS moniitem93 --モニタ項目値93
			,''94'' AS moniname94 --モニタ項目名94
			,ntss_db5_mm.monitor_data #>> ''{94}'' AS moniitem94 --モニタ項目値94
			,''95'' AS moniname95 --モニタ項目名95
			,ntss_db5_mm.monitor_data #>> ''{95}'' AS moniitem95 --モニタ項目値95
			,''96'' AS moniname96 --モニタ項目名96
			,ntss_db5_mm.monitor_data #>> ''{96}'' AS moniitem96 --モニタ項目値96
			,''97'' AS moniname97 --モニタ項目名97
			,ntss_db5_mm.monitor_data #>> ''{97}'' AS moniitem97 --モニタ項目値97
			,''98'' AS moniname98 --モニタ項目名98
			,ntss_db5_mm.monitor_data #>> ''{98}'' AS moniitem98 --モニタ項目値98
			,''99'' AS moniname99 --モニタ項目名99
			,ntss_db5_mm.monitor_data #>> ''{99}'' AS moniitem99 --モニタ項目値99
			,''100'' AS moniname100 --モニタ項目名100
			,ntss_db5_mm.monitor_data #>> ''{100}'' AS moniitem100 --モニタ項目値100
			,to_char(ntss_db5_mm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --発生日時
		FROM
			ord_main ntss_db5_om
			LEFT JOIN mst_bed ntss_db5_mst_b
			ON ntss_db5_mst_b.bed_cd = ntss_db5_om.rst_bed_cd
			LEFT JOIN mst_machine ntss_db5_mst_m
			ON cast(ntss_db5_mst_m.machine_type_cd AS integer) = ntss_db5_om.rst_machine_no
			INNER JOIN ntss_db5_mm
			ON ntss_db5_mm.ord_no = ntss_db5_om.ord_no
		WHERE ntss_db5_om.is_del = ''0''
			AND ntss_db5_om.facility_cd = @facilityCd
			AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
			AND to_date( @toDate, ''YYYYMMDDHH24MISS'' );'
WHERE sql_cd = '-2420';


-- V_ONL_DIALYSIS_MONI
UPDATE sys_data_set
SET "sql"=
		'WITH ntss_db5_mm AS (
			SELECT
				ntss_db5_om.ord_no AS ord_no
				,ntss_db5_mm.occur_date AS occur_date
				,ntss_db5_mm.monitor_data AS monitor_data
				,ntss_db5_mm.up_date AS up_date
			FROM
				ord_main ntss_db5_om
				LEFT JOIN mni_monitor ntss_db5_mm
				ON ntss_db5_mm.ord_no = ntss_db5_om.ord_no
			WHERE ntss_db5_mm.facility_cd = @facilityCd
				AND ntss_db5_mm.data_type = ''1''
				AND ntss_db5_mm.is_del = ''0''
				AND cast(ntss_db5_om.rst_dialysis_state AS integer) > 0
				AND ntss_db5_mm.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
				AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
		)
		SELECT
			ntss_db5_mst_b.in_hospital_cd_1 AS bedno --ベッド番号
			,ntss_db5_mst_m.machine_serial AS deviceno --装置番号
			,to_char(ntss_db5_mm.occur_date, ''YYYY-MM-DD hh24:mi:ss'') AS occurdate --発生日時
			,'''' AS hosppatid --患者ID
			,ntss_db5_om.pat_id AS patid
			,''1'' AS moniname1 --モニタ項目名1
			,ntss_db5_mm.monitor_data #>> ''{1}'' AS moniitem1 --モニタ項目値1
			,''2'' AS moniname2 --モニタ項目名2
			,ntss_db5_mm.monitor_data #>> ''{2}'' AS moniitem2 --モニタ項目値2
			,''3'' AS moniname3 --モニタ項目名3
			,ntss_db5_mm.monitor_data #>> ''{3}'' AS moniitem3 --モニタ項目値3
			,''4'' AS moniname4 --モニタ項目名4
			,ntss_db5_mm.monitor_data #>> ''{4}'' AS moniitem4 --モニタ項目値4
			,''5'' AS moniname5 --モニタ項目名5
			,ntss_db5_mm.monitor_data #>> ''{5}'' AS moniitem5 --モニタ項目値5
			,''6'' AS moniname6 --モニタ項目名6
			,ntss_db5_mm.monitor_data #>> ''{6}'' AS moniitem6 --モニタ項目値6
			,''7'' AS moniname7 --モニタ項目名7
			,ntss_db5_mm.monitor_data #>> ''{7}'' AS moniitem7 --モニタ項目値7
			,''8'' AS moniname8 --モニタ項目名8
			,ntss_db5_mm.monitor_data #>> ''{8}'' AS moniitem8 --モニタ項目値8
			,''9'' AS moniname9 --モニタ項目名9
			,ntss_db5_mm.monitor_data #>> ''{9}'' AS moniitem9 --モニタ項目値9
			,''10'' AS moniname10 --モニタ項目名10
			,ntss_db5_mm.monitor_data #>> ''{10}'' AS moniitem10 --モニタ項目値10
			,''11'' AS moniname11 --モニタ項目名11
			,ntss_db5_mm.monitor_data #>> ''{11}'' AS moniitem11 --モニタ項目値11
			,''12'' AS moniname12 --モニタ項目名12
			,ntss_db5_mm.monitor_data #>> ''{12}'' AS moniitem12 --モニタ項目値12
			,''13'' AS moniname13 --モニタ項目名13
			,ntss_db5_mm.monitor_data #>> ''{13}'' AS moniitem13 --モニタ項目値13
			,''14'' AS moniname14 --モニタ項目名14
			,ntss_db5_mm.monitor_data #>> ''{14}'' AS moniitem14 --モニタ項目値14
			,''15'' AS moniname15 --モニタ項目名15
			,ntss_db5_mm.monitor_data #>> ''{15}'' AS moniitem15 --モニタ項目値15
			,''16'' AS moniname16 --モニタ項目名16
			,ntss_db5_mm.monitor_data #>> ''{16}'' AS moniitem16 --モニタ項目値16
			,''17'' AS moniname17 --モニタ項目名17
			,ntss_db5_mm.monitor_data #>> ''{17}'' AS moniitem17 --モニタ項目値17
			,''18'' AS moniname18 --モニタ項目名18
			,ntss_db5_mm.monitor_data #>> ''{18}'' AS moniitem18 --モニタ項目値18
			,''19'' AS moniname19 --モニタ項目名19
			,ntss_db5_mm.monitor_data #>> ''{19}'' AS moniitem19 --モニタ項目値19
			,''20'' AS moniname20 --モニタ項目名20
			,ntss_db5_mm.monitor_data #>> ''{20}'' AS moniitem20 --モニタ項目値20
			,''21'' AS moniname21 --モニタ項目名21
			,ntss_db5_mm.monitor_data #>> ''{21}'' AS moniitem21 --モニタ項目値21
			,''22'' AS moniname22 --モニタ項目名22
			,ntss_db5_mm.monitor_data #>> ''{22}'' AS moniitem22 --モニタ項目値22
			,''23'' AS moniname23 --モニタ項目名23
			,ntss_db5_mm.monitor_data #>> ''{23}'' AS moniitem23 --モニタ項目値23
			,''24'' AS moniname24 --モニタ項目名24
			,ntss_db5_mm.monitor_data #>> ''{24}'' AS moniitem24 --モニタ項目値24
			,''25'' AS moniname25 --モニタ項目名25
			,ntss_db5_mm.monitor_data #>> ''{25}'' AS moniitem25 --モニタ項目値25
			,''26'' AS moniname26 --モニタ項目名26
			,ntss_db5_mm.monitor_data #>> ''{26}'' AS moniitem26 --モニタ項目値26
			,''27'' AS moniname27 --モニタ項目名27
			,ntss_db5_mm.monitor_data #>> ''{27}'' AS moniitem27 --モニタ項目値27
			,''28'' AS moniname28 --モニタ項目名28
			,ntss_db5_mm.monitor_data #>> ''{28}'' AS moniitem28 --モニタ項目値28
			,''29'' AS moniname29 --モニタ項目名29
			,ntss_db5_mm.monitor_data #>> ''{29}'' AS moniitem29 --モニタ項目値29
			,''30'' AS moniname30 --モニタ項目名30
			,ntss_db5_mm.monitor_data #>> ''{30}'' AS moniitem30 --モニタ項目値30
			,''31'' AS moniname31 --モニタ項目名31
			,ntss_db5_mm.monitor_data #>> ''{31}'' AS moniitem31 --モニタ項目値31
			,''32'' AS moniname32 --モニタ項目名32
			,ntss_db5_mm.monitor_data #>> ''{32}'' AS moniitem32 --モニタ項目値32
			,''33'' AS moniname33 --モニタ項目名33
			,ntss_db5_mm.monitor_data #>> ''{33}'' AS moniitem33 --モニタ項目値33
			,''34'' AS moniname34 --モニタ項目名34
			,ntss_db5_mm.monitor_data #>> ''{34}'' AS moniitem34 --モニタ項目値34
			,''35'' AS moniname35 --モニタ項目名35
			,ntss_db5_mm.monitor_data #>> ''{35}'' AS moniitem35 --モニタ項目値35
			,''36'' AS moniname36 --モニタ項目名36
			,ntss_db5_mm.monitor_data #>> ''{36}'' AS moniitem36 --モニタ項目値36
			,''37'' AS moniname37 --モニタ項目名37
			,ntss_db5_mm.monitor_data #>> ''{37}'' AS moniitem37 --モニタ項目値37
			,''38'' AS moniname38 --モニタ項目名38
			,ntss_db5_mm.monitor_data #>> ''{38}'' AS moniitem38 --モニタ項目値38
			,''39'' AS moniname39 --モニタ項目名39
			,ntss_db5_mm.monitor_data #>> ''{39}'' AS moniitem39 --モニタ項目値39
			,''40'' AS moniname40 --モニタ項目名40
			,ntss_db5_mm.monitor_data #>> ''{40}'' AS moniitem40 --モニタ項目値40
			,''41'' AS moniname41 --モニタ項目名41
			,ntss_db5_mm.monitor_data #>> ''{41}'' AS moniitem41 --モニタ項目値41
			,''42'' AS moniname42 --モニタ項目名42
			,ntss_db5_mm.monitor_data #>> ''{42}'' AS moniitem42 --モニタ項目値42
			,''43'' AS moniname43 --モニタ項目名43
			,ntss_db5_mm.monitor_data #>> ''{43}'' AS moniitem43 --モニタ項目値43
			,''44'' AS moniname44 --モニタ項目名44
			,ntss_db5_mm.monitor_data #>> ''{44}'' AS moniitem44 --モニタ項目値44
			,''45'' AS moniname45 --モニタ項目名45
			,ntss_db5_mm.monitor_data #>> ''{45}'' AS moniitem45 --モニタ項目値45
			,''46'' AS moniname46 --モニタ項目名46
			,ntss_db5_mm.monitor_data #>> ''{46}'' AS moniitem46 --モニタ項目値46
			,''47'' AS moniname47 --モニタ項目名47
			,ntss_db5_mm.monitor_data #>> ''{47}'' AS moniitem47 --モニタ項目値47
			,''48'' AS moniname48 --モニタ項目名48
			,ntss_db5_mm.monitor_data #>> ''{48}'' AS moniitem48 --モニタ項目値48
			,''49'' AS moniname49 --モニタ項目名49
			,ntss_db5_mm.monitor_data #>> ''{49}'' AS moniitem49 --モニタ項目値49
			,''50'' AS moniname50 --モニタ項目名50
			,ntss_db5_mm.monitor_data #>> ''{50}'' AS moniitem50 --モニタ項目値50
			,''51'' AS moniname51 --モニタ項目名51
			,ntss_db5_mm.monitor_data #>> ''{51}'' AS moniitem51 --モニタ項目値51
			,''52'' AS moniname52 --モニタ項目名52
			,ntss_db5_mm.monitor_data #>> ''{52}'' AS moniitem52 --モニタ項目値52
			,''53'' AS moniname53 --モニタ項目名53
			,ntss_db5_mm.monitor_data #>> ''{53}'' AS moniitem53 --モニタ項目値53
			,''54'' AS moniname54 --モニタ項目名54
			,ntss_db5_mm.monitor_data #>> ''{54}'' AS moniitem54 --モニタ項目値54
			,''55'' AS moniname55 --モニタ項目名55
			,ntss_db5_mm.monitor_data #>> ''{55}'' AS moniitem55 --モニタ項目値55
			,''56'' AS moniname56 --モニタ項目名56
			,ntss_db5_mm.monitor_data #>> ''{56}'' AS moniitem56 --モニタ項目値56
			,''57'' AS moniname57 --モニタ項目名57
			,ntss_db5_mm.monitor_data #>> ''{57}'' AS moniitem57 --モニタ項目値57
			,''58'' AS moniname58 --モニタ項目名58
			,ntss_db5_mm.monitor_data #>> ''{58}'' AS moniitem58 --モニタ項目値58
			,''59'' AS moniname59 --モニタ項目名59
			,ntss_db5_mm.monitor_data #>> ''{59}'' AS moniitem59 --モニタ項目値59
			,''60'' AS moniname60 --モニタ項目名60
			,ntss_db5_mm.monitor_data #>> ''{60}'' AS moniitem60 --モニタ項目値60
			,''61'' AS moniname61 --モニタ項目名61
			,ntss_db5_mm.monitor_data #>> ''{61}'' AS moniitem61 --モニタ項目値61
			,''62'' AS moniname62 --モニタ項目名62
			,ntss_db5_mm.monitor_data #>> ''{62}'' AS moniitem62 --モニタ項目値62
			,''63'' AS moniname63 --モニタ項目名63
			,ntss_db5_mm.monitor_data #>> ''{63}'' AS moniitem63 --モニタ項目値63
			,''64'' AS moniname64 --モニタ項目名64
			,ntss_db5_mm.monitor_data #>> ''{64}'' AS moniitem64 --モニタ項目値64
			,''65'' AS moniname65 --モニタ項目名65
			,ntss_db5_mm.monitor_data #>> ''{65}'' AS moniitem65 --モニタ項目値65
			,''66'' AS moniname66 --モニタ項目名66
			,ntss_db5_mm.monitor_data #>> ''{66}'' AS moniitem66 --モニタ項目値66
			,''67'' AS moniname67 --モニタ項目名67
			,ntss_db5_mm.monitor_data #>> ''{67}'' AS moniitem67 --モニタ項目値67
			,''68'' AS moniname68 --モニタ項目名68
			,ntss_db5_mm.monitor_data #>> ''{68}'' AS moniitem68 --モニタ項目値68
			,''69'' AS moniname69 --モニタ項目名69
			,ntss_db5_mm.monitor_data #>> ''{69}'' AS moniitem69 --モニタ項目値69
			,''70'' AS moniname70 --モニタ項目名70
			,ntss_db5_mm.monitor_data #>> ''{70}'' AS moniitem70 --モニタ項目値70
			,''71'' AS moniname71 --モニタ項目名71
			,ntss_db5_mm.monitor_data #>> ''{71}'' AS moniitem71 --モニタ項目値71
			,''72'' AS moniname72 --モニタ項目名72
			,ntss_db5_mm.monitor_data #>> ''{72}'' AS moniitem72 --モニタ項目値72
			,''73'' AS moniname73 --モニタ項目名73
			,ntss_db5_mm.monitor_data #>> ''{73}'' AS moniitem73 --モニタ項目値73
			,''74'' AS moniname74 --モニタ項目名74
			,ntss_db5_mm.monitor_data #>> ''{74}'' AS moniitem74 --モニタ項目値74
			,''75'' AS moniname75 --モニタ項目名75
			,ntss_db5_mm.monitor_data #>> ''{75}'' AS moniitem75 --モニタ項目値75
			,''76'' AS moniname76 --モニタ項目名76
			,ntss_db5_mm.monitor_data #>> ''{76}'' AS moniitem76 --モニタ項目値76
			,''77'' AS moniname77 --モニタ項目名77
			,ntss_db5_mm.monitor_data #>> ''{77}'' AS moniitem77 --モニタ項目値77
			,''78'' AS moniname78 --モニタ項目名78
			,ntss_db5_mm.monitor_data #>> ''{78}'' AS moniitem78 --モニタ項目値78
			,''79'' AS moniname79 --モニタ項目名79
			,ntss_db5_mm.monitor_data #>> ''{79}'' AS moniitem79 --モニタ項目値79
			,''80'' AS moniname80 --モニタ項目名80
			,ntss_db5_mm.monitor_data #>> ''{80}'' AS moniitem80 --モニタ項目値80
			,''81'' AS moniname81 --モニタ項目名81
			,ntss_db5_mm.monitor_data #>> ''{81}'' AS moniitem81 --モニタ項目値81
			,''82'' AS moniname82 --モニタ項目名82
			,ntss_db5_mm.monitor_data #>> ''{82}'' AS moniitem82 --モニタ項目値82
			,''83'' AS moniname83 --モニタ項目名83
			,ntss_db5_mm.monitor_data #>> ''{83}'' AS moniitem83 --モニタ項目値83
			,''84'' AS moniname84 --モニタ項目名84
			,ntss_db5_mm.monitor_data #>> ''{84}'' AS moniitem84 --モニタ項目値84
			,''85'' AS moniname85 --モニタ項目名85
			,ntss_db5_mm.monitor_data #>> ''{85}'' AS moniitem85 --モニタ項目値85
			,''86'' AS moniname86 --モニタ項目名86
			,ntss_db5_mm.monitor_data #>> ''{86}'' AS moniitem86 --モニタ項目値86
			,''87'' AS moniname87 --モニタ項目名87
			,ntss_db5_mm.monitor_data #>> ''{87}'' AS moniitem87 --モニタ項目値87
			,''88'' AS moniname88 --モニタ項目名88
			,ntss_db5_mm.monitor_data #>> ''{88}'' AS moniitem88 --モニタ項目値88
			,''89'' AS moniname89 --モニタ項目名89
			,ntss_db5_mm.monitor_data #>> ''{89}'' AS moniitem89 --モニタ項目値89
			,''90'' AS moniname90 --モニタ項目名90
			,ntss_db5_mm.monitor_data #>> ''{90}'' AS moniitem90 --モニタ項目値90
			,''91'' AS moniname91 --モニタ項目名91
			,ntss_db5_mm.monitor_data #>> ''{91}'' AS moniitem91 --モニタ項目値91
			,''92'' AS moniname92 --モニタ項目名92
			,ntss_db5_mm.monitor_data #>> ''{92}'' AS moniitem92 --モニタ項目値92
			,''93'' AS moniname93 --モニタ項目名93
			,ntss_db5_mm.monitor_data #>> ''{93}'' AS moniitem93 --モニタ項目値93
			,''94'' AS moniname94 --モニタ項目名94
			,ntss_db5_mm.monitor_data #>> ''{94}'' AS moniitem94 --モニタ項目値94
			,''95'' AS moniname95 --モニタ項目名95
			,ntss_db5_mm.monitor_data #>> ''{95}'' AS moniitem95 --モニタ項目値95
			,''96'' AS moniname96 --モニタ項目名96
			,ntss_db5_mm.monitor_data #>> ''{96}'' AS moniitem96 --モニタ項目値96
			,''97'' AS moniname97 --モニタ項目名97
			,ntss_db5_mm.monitor_data #>> ''{97}'' AS moniitem97 --モニタ項目値97
			,''98'' AS moniname98 --モニタ項目名98
			,ntss_db5_mm.monitor_data #>> ''{98}'' AS moniitem98 --モニタ項目値98
			,''99'' AS moniname99 --モニタ項目名99
			,ntss_db5_mm.monitor_data #>> ''{99}'' AS moniitem99 --モニタ項目値99
			,''100'' AS moniname100 --モニタ項目名100
			,ntss_db5_mm.monitor_data #>> ''{100}'' AS moniitem100 --モニタ項目値100
			,to_char(ntss_db5_mm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --発生日時
		FROM
			ord_main ntss_db5_om
			LEFT JOIN mst_bed ntss_db5_mst_b
			ON ntss_db5_mst_b.bed_cd = ntss_db5_om.rst_bed_cd
			LEFT JOIN mst_machine ntss_db5_mst_m
			ON cast(ntss_db5_mst_m.machine_type_cd AS integer) = ntss_db5_om.rst_machine_no
			INNER JOIN ntss_db5_mm
			ON ntss_db5_mm.ord_no = ntss_db5_om.ord_no
		WHERE ntss_db5_om.is_del = ''0''
			AND ntss_db5_om.facility_cd = @facilityCd
			AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
			AND to_date( @toDate, ''YYYYMMDDHH24MISS'' );'
WHERE sql_cd = '-2430';


-- V_LOG_DEV_MENTE
UPDATE sys_data_set
SET "sql"= 
		'WITH ntss_db5_mst_mr1 AS (
			SELECT
				ntss_db5_mst_mr.event_reg_date AS event_reg_date
				,ntss_db5_mst_m.machine_serial AS machine_serial
			FROM
				mst_machine ntss_db5_mst_m
				LEFT JOIN mnt_motion_record ntss_db5_mst_mr
				ON ntss_db5_mst_mr.machine_serial = ntss_db5_mst_m.machine_serial
			WHERE ntss_db5_mst_m.facility_cd = @facilityCd
				AND ntss_db5_mst_mr.test_type = ''1''
				AND ntss_db5_mst_mr.contents #>> ''{47}'' IS NOT NULL
				AND ntss_db5_mst_mr.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' ) 
				AND to_date( @toDate , ''YYYYMMDDHH24MISS'' )
		),
		ntss_db5_mst_mr2 AS (
			SELECT
				ntss_db5_mst_mr.contents #>> ''{47}'' AS contents_47
				,ntss_db5_mst_mr.contents #>> ''{43}'' AS contents_43
				,ntss_db5_mst_mr.contents #>> ''{44}'' AS contents_44
				,ntss_db5_mst_mr.contents #>> ''{48}'' AS contents_48
				,ntss_db5_mst_mr.contents #>> ''{46}'' AS contents_46
				,ntss_db5_mst_mr.contents #>> ''{45}'' AS contents_45
				,ntss_db5_mst_mr.contents #>> ''{49}'' AS contents_49
				,ntss_db5_mst_m.machine_serial AS machine_serial
			FROM
				mst_machine ntss_db5_mst_m
				LEFT JOIN mnt_motion_record ntss_db5_mst_mr
				ON ntss_db5_mst_mr.machine_serial = ntss_db5_mst_m.machine_serial
			WHERE ntss_db5_mst_m.facility_cd = @facilityCd
				AND ntss_db5_mst_mr.test_type = ''1''
				AND ntss_db5_mst_mr.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' ) 
				AND to_date( @toDate , ''YYYYMMDDHH24MISS'' )
		)
		SELECT
			ntss_db5_mst_m.machine_no AS deviceno --装置番号
			,ntss_db5_mst_m.machine_name AS devicename --装置名称
			,ntss_db5_mst_m.machine_serial AS deviceserial --製造番号
			,to_char(ntss_db5_mst_mr1.event_reg_date, ''YYYYMMDD'') AS meintedate --測定日付
			,to_char(ntss_db5_mst_mr1.event_reg_date, ''hh24mi'') AS meintetime --測定時刻
			,ntss_db5_mst_mr2.contents_47 AS meinteresult --配管自己診断結果
			,ntss_db5_mst_mr2.contents_47 AS meintegen --減圧テスト
			,ntss_db5_mst_mr2.contents_43 AS meintemore --配管系漏れ（陰圧)
			,ntss_db5_mst_mr2.contents_44 AS meinteymore --配管系漏れ（陽圧）
			,ntss_db5_mst_mr2.contents_48 AS meintejyo --除水テスト
			,ntss_db5_mst_mr2.contents_46 AS meintebara --バランステスト
			,ntss_db5_mst_mr2.contents_45 AS meinteetcf --ＣＦフィルタ漏れ
			,ntss_db5_mst_mr2.contents_49 AS meinteetcf2 --ＣＦ２フィルタ漏れ
		FROM
			mst_machine ntss_db5_mst_m
			LEFT JOIN mnt_motion_record ntss_db5_mst_mr
			ON ntss_db5_mst_mr.machine_serial = ntss_db5_mst_m.machine_serial
			LEFT JOIN ntss_db5_mst_mr1
			ON ntss_db5_mst_mr1.machine_serial = ntss_db5_mst_m.machine_serial
			LEFT JOIN ntss_db5_mst_mr2
			ON ntss_db5_mst_mr2.machine_serial = ntss_db5_mst_m.machine_serial
		WHERE ntss_db5_mst_m.is_del = ''0''
			AND ntss_db5_mst_m.facility_cd = @facilityCd
			AND ntss_db5_mst_m.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' ) 
			AND to_date( @toDate , ''YYYYMMDDHH24MISS'' )'
WHERE sql_cd = '-2440';


-- V_PAT_DEVICE_SET
UPDATE sys_data_set
SET "sql"= 
		'WITH ntss_db5_pm_dsi AS (
			SELECT
				ntss_db5_pm.pat_id AS pat_id
				,value_3.key AS value_2
				,value_3.value AS value_4
			FROM
				pat_main ntss_db5_pm
				JOIN json_each_text(ntss_db5_pm.device_set_info ::json) AS keysandvalue ON TRUE
				JOIN json_each_text((keysandvalue.value::json #>> ''{dev,A}'')::json) AS value_3 ON TRUE
			WHERE ntss_db5_pm.is_del = ''0''
				AND ntss_db5_pm.facility_cd = @facilityCd
				AND ntss_db5_pm.device_set_info IS NOT NULL
				AND ntss_db5_pm.device_set_info <> ''[]''
				AND value_3.key IS NOT NULL
				AND ntss_db5_pm.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
				AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
		)
		SELECT
			'''' AS hosppatid --患者ID
			,ntss_db5_pm.pat_id AS patid
			,'''' AS name
			,ntss_db5_pm_dsi.value_2
			,CASE
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0100'' THEN ''1''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0101'' THEN ''2''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0102'' THEN ''3''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0103'' THEN ''4''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0104'' THEN ''5''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0105'' THEN ''6''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0106'' THEN ''7''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0107'' THEN ''8''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0108'' THEN ''9''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0109'' THEN ''10''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0110'' THEN ''11''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0111'' THEN ''12''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0112'' THEN ''13''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0113'' THEN ''14''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0114'' THEN ''15''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0115'' THEN ''16''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0116'' THEN ''17''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0117'' THEN ''18''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0118'' THEN ''19''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0119'' THEN ''20''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0120'' THEN ''21''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0121'' THEN ''22''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0122'' THEN ''23''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0123'' THEN ''24''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0124'' THEN ''25''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0125'' THEN ''26''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0126'' THEN ''27''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0127'' THEN ''28''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0128'' THEN ''29''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0129'' THEN ''30''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0130'' THEN ''31''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0131'' THEN ''32''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0132'' THEN ''33''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0133'' THEN ''34''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0134'' THEN ''35''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0135'' THEN ''36''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0136'' THEN ''37''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0137'' THEN ''38''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0138'' THEN ''39''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0139'' THEN ''40''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0140'' THEN ''41''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0141'' THEN ''42''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0142'' THEN ''43''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0143'' THEN ''44''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0144'' THEN ''45''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0145'' THEN ''46''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0146'' THEN ''47''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0147'' THEN ''48''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0148'' THEN ''49''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0149'' THEN ''50''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0150'' THEN ''51''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0151'' THEN ''52''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0152'' THEN ''53''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0153'' THEN ''54''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0154'' THEN ''55''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0155'' THEN ''56''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0156'' THEN ''57''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0157'' THEN ''58''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0158'' THEN ''59''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0159'' THEN ''60''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0160'' THEN ''61''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0161'' THEN ''62''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0162'' THEN ''63''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0163'' THEN ''64''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0164'' THEN ''65''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0165'' THEN ''66''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0166'' THEN ''67''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0167'' THEN ''68''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0168'' THEN ''69''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0169'' THEN ''70''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0170'' THEN ''71''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0171'' THEN ''72''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0172'' THEN ''73''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0173'' THEN ''74''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0174'' THEN ''75''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0175'' THEN ''76''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0176'' THEN ''77''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0177'' THEN ''78''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0178'' THEN ''79''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0179'' THEN ''80''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0180'' THEN ''81''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0181'' THEN ''82''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0182'' THEN ''83''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0183'' THEN ''84''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0184'' THEN ''85''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0185'' THEN ''86''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0186'' THEN ''87''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0190'' THEN ''88''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0191'' THEN ''89''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0192'' THEN ''90''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0193'' THEN ''91''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0194'' THEN ''92''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0211'' THEN ''93''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0212'' THEN ''94''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0213'' THEN ''95''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0214'' THEN ''96''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0215'' THEN ''97''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0216'' THEN ''98''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0217'' THEN ''99''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0218'' THEN ''100''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0219'' THEN ''101''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0220'' THEN ''102''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0221'' THEN ''103''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0222'' THEN ''104''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0223'' THEN ''105''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0224'' THEN ''106''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0225'' THEN ''107''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0226'' THEN ''108''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0227'' THEN ''109''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0228'' THEN ''110''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0229'' THEN ''111''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0230'' THEN ''112''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0231'' THEN ''113''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0232'' THEN ''114''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0233'' THEN ''115''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0234'' THEN ''116''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0235'' THEN ''117''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0236'' THEN ''118''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0237'' THEN ''119''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0238'' THEN ''120''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0239'' THEN ''121''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0240'' THEN ''122''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0241'' THEN ''123''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0242'' THEN ''124''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0243'' THEN ''125''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0244'' THEN ''126''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0245'' THEN ''127''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0246'' THEN ''128''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0247'' THEN ''129''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0250'' THEN ''130''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0251'' THEN ''131''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0252'' THEN ''132''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0253'' THEN ''133''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0254'' THEN ''134''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0255'' THEN ''135''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0256'' THEN ''136''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0257'' THEN ''137''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0258'' THEN ''138''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0259'' THEN ''139''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0260'' THEN ''140''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0261'' THEN ''141''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0262'' THEN ''142''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0267'' THEN ''143''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0277'' THEN ''144''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0278'' THEN ''145''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0281'' THEN ''146''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0282'' THEN ''147''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0283'' THEN ''148''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0284'' THEN ''149''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0285'' THEN ''150''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0286'' THEN ''151''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0287'' THEN ''152''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0288'' THEN ''153''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0290'' THEN ''154''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0301'' THEN ''155''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0302'' THEN ''156''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0303'' THEN ''157''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0304'' THEN ''158''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0305'' THEN ''159''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0306'' THEN ''160''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0307'' THEN ''161''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0308'' THEN ''162''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0309'' THEN ''163''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0310'' THEN ''164''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0311'' THEN ''165''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0312'' THEN ''166''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0313'' THEN ''167''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0314'' THEN ''168''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0315'' THEN ''169''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0316'' THEN ''170''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0317'' THEN ''171''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0318'' THEN ''172''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0319'' THEN ''173''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0320'' THEN ''174''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0321'' THEN ''175''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0322'' THEN ''176''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0323'' THEN ''177''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0324'' THEN ''178''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0325'' THEN ''179''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0326'' THEN ''180''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0327'' THEN ''181''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0328'' THEN ''182''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0329'' THEN ''183''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0330'' THEN ''184''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0331'' THEN ''185''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0332'' THEN ''186''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0333'' THEN ''187''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0334'' THEN ''188''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0335'' THEN ''189''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0336'' THEN ''190''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0337'' THEN ''191''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0338'' THEN ''192''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0339'' THEN ''193''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0340'' THEN ''194''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0341'' THEN ''195''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0342'' THEN ''196''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0343'' THEN ''197''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0344'' THEN ''198''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0345'' THEN ''199''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0346'' THEN ''200''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0347'' THEN ''201''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0348'' THEN ''202''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0349'' THEN ''203''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0350'' THEN ''204''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0351'' THEN ''205''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0352'' THEN ''206''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0353'' THEN ''207''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0354'' THEN ''208''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0355'' THEN ''209''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0356'' THEN ''210''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0357'' THEN ''211''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0358'' THEN ''212''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0359'' THEN ''213''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0360'' THEN ''214''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0361'' THEN ''215''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0362'' THEN ''216''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0363'' THEN ''217''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0364'' THEN ''218''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0365'' THEN ''219''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0366'' THEN ''220''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0367'' THEN ''221''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0368'' THEN ''222''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0370'' THEN ''223''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0371'' THEN ''224''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0372'' THEN ''225''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0373'' THEN ''226''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0374'' THEN ''227''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0376'' THEN ''228''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0377'' THEN ''229''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0378'' THEN ''230''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0380'' THEN ''231''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0381'' THEN ''232''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0382'' THEN ''233''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0383'' THEN ''234''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0384'' THEN ''235''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0385'' THEN ''236''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0386'' THEN ''237''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0387'' THEN ''238''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0388'' THEN ''239''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0389'' THEN ''240''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0390'' THEN ''241''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0391'' THEN ''242''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0392'' THEN ''243''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0393'' THEN ''244''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0394'' THEN ''245''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0395'' THEN ''246''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0396'' THEN ''247''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0397'' THEN ''248''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0398'' THEN ''249''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0000'' THEN ''250''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0001'' THEN ''251''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0002'' THEN ''252''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0003'' THEN ''253''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0004'' THEN ''254''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0005'' THEN ''255''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0006'' THEN ''256''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0007'' THEN ''257''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0008'' THEN ''258''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0009'' THEN ''259''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0010'' THEN ''260''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0011'' THEN ''261''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0012'' THEN ''262''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0013'' THEN ''263''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0014'' THEN ''264''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0015'' THEN ''265''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0016'' THEN ''266''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0017'' THEN ''267''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0018'' THEN ''268''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0019'' THEN ''269''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0020'' THEN ''270''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0021'' THEN ''271''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0022'' THEN ''272''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0023'' THEN ''273''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0024'' THEN ''274''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0025'' THEN ''275''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0026'' THEN ''276''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0027'' THEN ''277''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0028'' THEN ''278''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0029'' THEN ''279''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0030'' THEN ''280''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0031'' THEN ''281''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0032'' THEN ''282''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0033'' THEN ''283''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0034'' THEN ''284''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0035'' THEN ''285''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0036'' THEN ''286''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0037'' THEN ''287''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0038'' THEN ''288''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0000'' THEN ''289''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0001'' THEN ''290''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0002'' THEN ''291''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0003'' THEN ''292''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0004'' THEN ''293''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0005'' THEN ''294''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0006'' THEN ''295''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0007'' THEN ''296''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0008'' THEN ''297''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0009'' THEN ''298''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0010'' THEN ''299''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0011'' THEN ''300''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0012'' THEN ''301''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0013'' THEN ''302''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0014'' THEN ''303''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0015'' THEN ''304''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0016'' THEN ''305''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0017'' THEN ''306''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0018'' THEN ''307''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0019'' THEN ''308''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0000'' THEN ''309''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0001'' THEN ''310''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0005'' THEN ''311''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0007'' THEN ''312''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0008'' THEN ''313''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0009'' THEN ''314''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0010'' THEN ''315''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0011'' THEN ''316''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0030'' THEN ''317''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0031'' THEN ''318''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0032'' THEN ''319''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0033'' THEN ''320''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0034'' THEN ''321''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0051'' THEN ''322''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0052'' THEN ''323''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0053'' THEN ''324''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0054'' THEN ''325''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0055'' THEN ''326''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0056'' THEN ''327''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0057'' THEN ''328''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0058'' THEN ''329''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0059'' THEN ''330''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0369'' THEN ''331''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0379'' THEN ''332''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0039'' THEN ''333''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0263'' THEN ''334''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0264'' THEN ''335''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0265'' THEN ''336''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0266'' THEN ''337''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0039'' THEN ''338''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0270'' THEN ''339''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0200'' THEN ''340''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0201'' THEN ''341''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0202'' THEN ''342''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0203'' THEN ''343''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0204'' THEN ''344''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0205'' THEN ''345''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0090'' THEN ''346''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0091'' THEN ''347''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0092'' THEN ''348''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0195'' THEN ''349''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0040'' THEN ''350''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0196'' THEN ''351''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0197'' THEN ''352''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0198'' THEN ''353''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0199'' THEN ''354''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0206'' THEN ''355''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0207'' THEN ''356''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0208'' THEN ''357''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0209'' THEN ''358''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0210'' THEN ''359''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0248'' THEN ''360''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0249'' THEN ''361''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0268'' THEN ''362''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0269'' THEN ''363''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0271'' THEN ''364''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0272'' THEN ''365''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0273'' THEN ''366''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0274'' THEN ''367''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0275'' THEN ''368''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0400'' THEN ''369''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0401'' THEN ''370''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0402'' THEN ''371''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0403'' THEN ''372''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0404'' THEN ''373''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0405'' THEN ''374''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0406'' THEN ''375''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0407'' THEN ''376''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0408'' THEN ''377''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0409'' THEN ''378''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0410'' THEN ''379''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0411'' THEN ''380''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0412'' THEN ''381''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0413'' THEN ''382''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0414'' THEN ''383''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0415'' THEN ''384''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0416'' THEN ''385''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0417'' THEN ''386''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0418'' THEN ''387''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0419'' THEN ''388''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0420'' THEN ''389''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0421'' THEN ''390''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0422'' THEN ''391''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0423'' THEN ''392''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0424'' THEN ''393''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0425'' THEN ''394''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0426'' THEN ''395''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0427'' THEN ''396''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0428'' THEN ''397''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0429'' THEN ''398''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0430'' THEN ''399''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0431'' THEN ''400''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0432'' THEN ''401''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0433'' THEN ''402''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0434'' THEN ''403''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0435'' THEN ''404''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0436'' THEN ''405''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0437'' THEN ''406''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0438'' THEN ''407''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0439'' THEN ''408''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0440'' THEN ''409''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0441'' THEN ''410''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0442'' THEN ''411''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0443'' THEN ''412''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0444'' THEN ''413''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0445'' THEN ''414''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0446'' THEN ''415''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0447'' THEN ''416''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0448'' THEN ''417''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0449'' THEN ''418''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0450'' THEN ''419''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0451'' THEN ''420''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0452'' THEN ''421''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0453'' THEN ''422''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0454'' THEN ''423''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0455'' THEN ''424''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0456'' THEN ''425''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0457'' THEN ''426''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0458'' THEN ''427''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0459'' THEN ''428''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0460'' THEN ''429''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0461'' THEN ''430''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0462'' THEN ''431''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0463'' THEN ''432''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0464'' THEN ''433''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0465'' THEN ''434''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0466'' THEN ''435''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0468'' THEN ''436''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0469'' THEN ''437''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0470'' THEN ''438''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0471'' THEN ''439''
				ELSE ntss_db5_pm_dsi.value_2
			 END AS ctlno --管理番号
			,SUBSTR(CASE
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0100'' THEN ''静脈圧自動設定警報幅上限HD/ECUM''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0101'' THEN ''静脈圧自動設定警報幅下限HD/ECUM''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0102'' THEN ''静脈圧自動設定警報限界上限''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0103'' THEN ''静脈圧自動設定警報限界下限''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0104'' THEN ''静脈圧固定警報上限''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0105'' THEN ''静脈圧固定警報下限''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0106'' THEN ''静脈圧自動設定警報幅上限HDF/HF''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0107'' THEN ''静脈圧自動設定警報幅下限HDF/HF''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0108'' THEN ''静脈圧固定警報上限準備回収''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0109'' THEN ''静脈圧固定警報下限準備回収''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0110'' THEN ''静脈圧固定警報上限ＳＮ''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0111'' THEN ''静脈圧固定警報下限ＳＮ''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0112'' THEN ''液圧自動設定警報幅上限HD/ECUM''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0113'' THEN ''液圧自動設定警報幅下限HD/ECUM''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0114'' THEN ''液圧自動設定警報限界上限''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0115'' THEN ''液圧自動設定警報限界下限''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0116'' THEN ''液圧固定警報上限''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0117'' THEN ''液圧固定警報下限''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0118'' THEN ''液圧自動設定警報幅上限HDF/HF''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0119'' THEN ''液圧自動設定警報幅下限HDF/HF''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0120'' THEN ''液圧自動設定警報幅上限ＳＮ''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0121'' THEN ''液圧自動設定警報幅下限ＳＮ''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0122'' THEN ''液圧自動設定警報限界上限ＳＮ''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0123'' THEN ''液圧自動設定警報限界下限ＳＮ''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0124'' THEN ''液圧固定警報上限ＳＮ''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0125'' THEN ''液圧固定警報下限ＳＮ''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0126'' THEN ''ＴＭＰ自動追従警報幅上限HD/ECUM''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0127'' THEN ''ＴＭＰ自動追従警報幅下限HD/ECUM''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0128'' THEN ''ＴＭＰ自動設定警報幅上限HD/ECUM''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0129'' THEN ''ＴＭＰ自動設定警報幅下限HD/ECUM''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0130'' THEN ''ＴＭＰ自動設定警報限界上限''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0131'' THEN ''ＴＭＰ自動設定警報限界下限''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0132'' THEN ''ＴＭＰ固定警報上限''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0133'' THEN ''ＴＭＰ固定警報下限''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0134'' THEN ''ＴＭＰ自動追従警報幅上限HDF/HF''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0135'' THEN ''ＴＭＰ自動追従警報幅下限HDF/HF''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0136'' THEN ''ＴＭＰ自動設定警報幅上限HDF/HF''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0137'' THEN ''ＴＭＰ自動設定警報幅下限HDF/HF''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0138'' THEN ''ＴＭＰ自動追従警報幅上限ＳＮ''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0139'' THEN ''ＴＭＰ自動追従警報幅下限ＳＮ''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0140'' THEN ''ＴＭＰ自動設定警報幅上限ＳＮ''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0141'' THEN ''ＴＭＰ自動設定警報幅下限ＳＮ''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0142'' THEN ''ＴＭＰ自動設定警報限界上限ＳＮ''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0143'' THEN ''ＴＭＰ自動設定警報限界下限ＳＮ''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0144'' THEN ''ＴＭＰ固定警報上限ＳＮ''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0145'' THEN ''ＴＭＰ固定警報下限ＳＮ''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0146'' THEN ''ダイアライザー差圧自動設定警報幅上限HD/ECUM''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0147'' THEN ''ダイアライザー差圧自動設定警報幅下限HD/ECUM''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0148'' THEN ''ダイアライザー差圧固定警報上限''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0149'' THEN ''ダイアライザー差圧固定警報下限''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0150'' THEN ''ダイアライザー差圧自動設定警報幅上限HDF/HF''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0151'' THEN ''ダイアライザー差圧自動設定警報幅下限HDF/HF''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0152'' THEN ''ダイアライザー入口圧自動設定警報幅上限HD/ECUM''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0153'' THEN ''ダイアライザー入口圧自動設定警報幅下限HD/ECUM''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0154'' THEN ''ダイアライザー入口圧自動設定警報限界上限''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0155'' THEN ''ダイアライザー入口圧自動設定警報限界下限''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0156'' THEN ''ダイアライザー入口圧固定警報上限''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0157'' THEN ''ダイアライザー入口圧固定警報下限''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0158'' THEN ''ダイアライザー入口圧自動設定警報幅上限HDF/HF''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0159'' THEN ''ダイアライザー入口圧自動設定警報幅下限HDF/HF''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0160'' THEN ''ダイアライザー入口圧固定警報上限準備回収''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0161'' THEN ''ダイアライザー入口圧固定警報下限準備回収''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0162'' THEN ''ダイアライザー入口圧固定警報上限ＳＮ''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0163'' THEN ''ダイアライザー入口圧固定警報下限ＳＮ''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0164'' THEN ''初期ＵＦＲ警報上限''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0165'' THEN ''初期ＵＦＲ警報下限''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0166'' THEN ''ＵＦＲ低下警報点''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0167'' THEN ''ＴＭＰゼロ補正警報中点HD''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0168'' THEN ''ＴＭＰゼロ補正警報上限HD''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0169'' THEN ''ＴＭＰゼロ補正警報下限HD''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0170'' THEN ''ＴＭＰゼロ補正警報中点ECUM''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0171'' THEN ''ＴＭＰゼロ補正警報上限ECUM''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0172'' THEN ''ＴＭＰゼロ補正警報下限ECUM''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0173'' THEN ''ＴＭＰゼロ補正警報中点HDF''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0174'' THEN ''ＴＭＰゼロ補正警報上限HDF''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0175'' THEN ''ＴＭＰゼロ補正警報下限HDF''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0176'' THEN ''ＴＭＰゼロ補正警報中点HF''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0177'' THEN ''ＴＭＰゼロ補正警報上限HF''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0178'' THEN ''ＴＭＰゼロ補正警報下限HF''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0179'' THEN ''血流量操作範囲上限''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0180'' THEN ''ＩＰ速度操作範囲上限''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0181'' THEN ''除水速度操作範囲上限''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0182'' THEN ''透析液温度操作範囲上限''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0183'' THEN ''透析液温度操作範囲下限''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0184'' THEN ''Ｎａ注入濃度操作範囲上限''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0185'' THEN ''前補液 補液速度操作範囲上限(HDF)''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0186'' THEN ''前補液 補液速度操作範囲上限(HF)''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0190'' THEN ''血圧自動測定間隔''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0191'' THEN ''血圧ｶﾌ選択''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0192'' THEN ''昇圧値''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0193'' THEN ''昇圧方法選択''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0194'' THEN ''血圧連続測定動作選択''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0211'' THEN ''最高血圧上限''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0212'' THEN ''最高血圧下限''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0213'' THEN ''最低血圧上限''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0214'' THEN ''最低血圧下限''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0215'' THEN ''平均血圧上限''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0216'' THEN ''平均血圧下限''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0217'' THEN ''脈拍数上限''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0218'' THEN ''脈拍数下限''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0219'' THEN ''最高血圧上限警報 BP 動作選択''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0220'' THEN ''最高血圧下限警報 BP 動作選択''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0221'' THEN ''最高血圧上限警報 除水 動作選択''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0222'' THEN ''最高血圧下限警報 除水 動作選択''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0223'' THEN ''最高血圧上限警報 Na注入 動作選択''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0224'' THEN ''最高血圧下限警報 Na注入 動作選択''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0225'' THEN ''最高血圧上限警報 補液 動作選択''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0226'' THEN ''最高血圧下限警報 補液 動作選択''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0227'' THEN ''最高血圧上限警報 BP 速度''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0228'' THEN ''最高血圧下限警報 BP 速度''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0229'' THEN ''最高血圧上限警報 除水 速度''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0230'' THEN ''最高血圧下限警報 除水 速度''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0231'' THEN ''最高血圧上限警報 Na注入 速度''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0232'' THEN ''最高血圧下限警報 Na注入 速度''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0233'' THEN ''最高血圧上限警報 補液 速度''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0234'' THEN ''最高血圧下限警報 補液 速度''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0235'' THEN ''警報連動測定開始時刻''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0236'' THEN ''治療条件連動測定時刻''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0237'' THEN ''血圧測定自動停止(警報発生)''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0238'' THEN ''血圧測定自動停止(条件変更)''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0239'' THEN ''高速測定選択''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0240'' THEN ''ＴＭＰ監視モード''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0241'' THEN ''ＴＭＰゼロ補正の選択''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0242'' THEN ''静脈圧自動設定警報監視有無''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0243'' THEN ''ダイアライザー血液入口圧自動設定警報監視有無''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0244'' THEN ''透析液圧自動設定警報監視有無''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0245'' THEN ''ＴＭＰ自動設定警報監視有無''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0246'' THEN ''差圧自動設定警報監視有無''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0247'' THEN ''Ｎａ濃度自動設定警報監視有無''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0250'' THEN ''透析液濃度プログラム自動設定警報幅上限''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0251'' THEN ''透析液濃度プログラム自動設定警報幅下限''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0252'' THEN ''Ｂ液濃度プログラム自動設定警報幅上限''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0253'' THEN ''Ｂ液濃度プログラム自動設定警報幅下限''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0254'' THEN ''Ｎａ濃度自動設定警報幅上限''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0255'' THEN ''Ｎａ濃度自動設定警報幅下限''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0256'' THEN ''Ｎａ濃度固定警報上限''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0257'' THEN ''Ｎａ濃度固定警報下限''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0258'' THEN ''アクセス再循環測定使用選択''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0259'' THEN ''自動測定1''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0260'' THEN ''⊿ＢＶ低下警報点１''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0261'' THEN ''⊿ＢＶ低下警報点２''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0262'' THEN ''⊿BV変化率警報点''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0267'' THEN ''ブラッドボリューム計使用の選択''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0277'' THEN ''⊿ＢＶ除水低下速度''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0278'' THEN ''⊿ＢＶ除水低下遅延時間''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0281'' THEN ''再循環率報知''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0282'' THEN ''透析量プログラム使用選択''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0283'' THEN ''体液量計算時後体重''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0284'' THEN ''体液量+補正値''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0285'' THEN ''目標後体重''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0286'' THEN ''標準血流量''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0287'' THEN ''KoA''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0288'' THEN ''目標Kt/V''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0290'' THEN ''ＵＦＲプログラム電源ＳＷ''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0301'' THEN ''ＵＦＲプログラム指数１''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0302'' THEN ''ＵＦＲプログラム指数２''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0303'' THEN ''ＵＦＲプログラム指数３''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0304'' THEN ''ＵＦＲプログラム指数４''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0305'' THEN ''ＵＦＲプログラム指数５''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0306'' THEN ''ＵＦＲプログラム指数６''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0307'' THEN ''ＵＦＲプログラム指数７''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0308'' THEN ''ＵＦＲプログラム指数８''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0309'' THEN ''ＵＦＲプログラム指数９''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0310'' THEN ''ＵＦＲプログラム指数１０''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0311'' THEN ''ＵＦＲプログラム最終位置''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0312'' THEN ''ＵＦＲプログラムコース''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0313'' THEN ''ＵＦＲプログラム開始数値''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0314'' THEN ''ＵＦＲプログラム終了数値''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0315'' THEN ''Ｎａ注入プログラム電源ＳＷ''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0316'' THEN ''Ｎａ注入プログラム設定１''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0317'' THEN ''Ｎａ注入プログラム設定２''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0318'' THEN ''Ｎａ注入プログラム設定３''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0319'' THEN ''Ｎａ注入プログラム設定４''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0320'' THEN ''Ｎａ注入プログラム設定５''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0321'' THEN ''Ｎａ注入プログラム設定６''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0322'' THEN ''Ｎａ注入プログラム設定７''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0323'' THEN ''Ｎａ注入プログラム設定８''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0324'' THEN ''Ｎａ注入プログラム設定９''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0325'' THEN ''Ｎａ注入プログラム設定１０''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0326'' THEN ''Ｎａ注入プログラム切替時間''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0327'' THEN ''Ｎａ注入プログラム ＵＦＲプロとの連動選択''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0328'' THEN ''Ｎａ注入プログラムコース''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0329'' THEN ''Ｎａ注入プログラム開始数値''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0330'' THEN ''Ｎａ注入プログラム終了数値''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0331'' THEN ''同時脱血 脱血量''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0332'' THEN ''片側脱血への切替え透析液圧''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0333'' THEN ''脱血速度''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0334'' THEN ''片側脱血(除水なし) 脱血量''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0335'' THEN ''治療開始時 血液ポンプ速度''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0336'' THEN ''補液速度''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0337'' THEN ''補液量''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0338'' THEN ''片側脱血(除水あり) 脱血量''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0339'' THEN ''脱血方法選択''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0340'' THEN ''濃度プログラム電源ＳＷ''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0341'' THEN ''透析液濃度プログラム設定１''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0342'' THEN ''透析液濃度プログラム設定２''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0343'' THEN ''透析液濃度プログラム設定３''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0344'' THEN ''透析液濃度プログラム設定４''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0345'' THEN ''透析液濃度プログラム設定５''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0346'' THEN ''透析液濃度プログラム設定６''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0347'' THEN ''透析液濃度プログラム設定７''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0348'' THEN ''透析液濃度プログラム設定８''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0349'' THEN ''透析液濃度プログラム設定９''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0350'' THEN ''透析液濃度プログラム設定１０''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0351'' THEN ''Ｂ液濃度プログラム設定１''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0352'' THEN ''Ｂ液濃度プログラム設定２''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0353'' THEN ''Ｂ液濃度プログラム設定３''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0354'' THEN ''Ｂ液濃度プログラム設定４''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0355'' THEN ''Ｂ液濃度プログラム設定５''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0356'' THEN ''Ｂ液濃度プログラム設定６''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0357'' THEN ''Ｂ液濃度プログラム設定７''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0358'' THEN ''Ｂ液濃度プログラム設定８''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0359'' THEN ''Ｂ液濃度プログラム設定９''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0360'' THEN ''Ｂ液濃度プログラム設定１０''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0361'' THEN ''透析液濃度プログラムステップ切替無し コース''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0362'' THEN ''透析液濃度プログラム開始数値''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0363'' THEN ''透析液濃度プログラム終了数値''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0364'' THEN ''Ｂ液濃度プログラムステップ切替無し コース''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0365'' THEN ''Ｂ液濃度プログラム開始数値''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0366'' THEN ''Ｂ液濃度プログラム終了数値''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0367'' THEN ''濃度プログラム切替時間''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0368'' THEN ''濃度プログラム ＵＦＲプロとの連動選択''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0370'' THEN ''自動回収 使用液量''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0371'' THEN ''自動回収 流速''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0372'' THEN ''自動回収 血液判別器による終了選択''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0373'' THEN ''静脈側返血速度''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0374'' THEN ''静脈側最大返血量''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0376'' THEN ''動脈側最大返血量''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0377'' THEN ''静脈側返血 血液判別器使用選択''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0378'' THEN ''動脈側返血 血液判別器使用選択''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0380'' THEN ''補液速度''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0381'' THEN ''補液温度設定値''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0382'' THEN ''補液量設定値''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0383'' THEN ''補液量設定値制限(OHDF・OHF用)''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0384'' THEN ''AFBF 補液比率使用選択''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0385'' THEN ''AFBF 補液比率''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0386'' THEN ''補液速度設定範囲上限(AFBF)''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0387'' THEN ''補液速度設定範囲下限(AFBF)''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0388'' THEN ''補液選択(前・後)''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0389'' THEN ''OHDF/OHF補液計算優先項目選択''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0390'' THEN ''ＴＭＰゼロ補正警報中点OHDF''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0391'' THEN ''ＴＭＰゼロ補正警報上限OHDF''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0392'' THEN ''ＴＭＰゼロ補正警報下限OHDF''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0393'' THEN ''ＴＭＰゼロ補正警報中点OHF''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0394'' THEN ''ＴＭＰゼロ補正警報上限OHF''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0395'' THEN ''ＴＭＰゼロ補正警報下限OHF''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0396'' THEN ''前補液 補液速度操作範囲上限(OHDF)''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0397'' THEN ''前補液 補液速度操作範囲上限(OHF)''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0398'' THEN ''補液開始遅延時間''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0000'' THEN ''UFRプログラム工程1の指数''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0001'' THEN ''UFRプログラム工程2の指数''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0002'' THEN ''UFRプログラム工程3の指数''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0003'' THEN ''UFRプログラム工程4の指数''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0004'' THEN ''UFRプログラム工程5の指数''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0005'' THEN ''UFRプログラム工程6の指数''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0006'' THEN ''UFRプログラム工程7の指数''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0007'' THEN ''UFRプログラム工程8の指数''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0008'' THEN ''UFRプログラム工程9の指数''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0009'' THEN ''UFRプログラム工程10の指数''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0010'' THEN ''B液濃度プログラム工程1のB液濃度''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0011'' THEN ''B液濃度プログラム工程2のB液濃度''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0012'' THEN ''B液濃度プログラム工程3のB液濃度''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0013'' THEN ''B液濃度プログラム工程4のB液濃度''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0014'' THEN ''B液濃度プログラム工程5のB液濃度''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0015'' THEN ''B液濃度プログラム工程6のB液濃度''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0016'' THEN ''B液濃度プログラム工程7のB液濃度''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0017'' THEN ''B液濃度プログラム工程8のB液濃度''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0018'' THEN ''B液濃度プログラム工程9のB液濃度''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0019'' THEN ''B液濃度プログラム工程10のB液濃度''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0020'' THEN ''A液濃度プログラム工程1のA液濃度''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0021'' THEN ''A液濃度プログラム工程2のA液濃度''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0022'' THEN ''A液濃度プログラム工程3のA液濃度''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0023'' THEN ''A液濃度プログラム工程4のA液濃度''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0024'' THEN ''A液濃度プログラム工程5のA液濃度''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0025'' THEN ''A液濃度プログラム工程6のA液濃度''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0026'' THEN ''A液濃度プログラム工程7のA液濃度''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0027'' THEN ''A液濃度プログラム工程8のA液濃度''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0028'' THEN ''A液濃度プログラム工程9のA液濃度''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0029'' THEN ''A液濃度プログラム工程10のA液濃度''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0030'' THEN ''前補液 補液速度操作範囲上限(HD+補液)''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0031'' THEN ''後補液 補液速度操作範囲上限(HDF)''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0032'' THEN ''後補液 補液速度操作範囲上限(HF)''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0033'' THEN ''後補液 補液速度操作範囲上限(HD+補液)''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0034'' THEN ''後補液 補液速度操作範囲上限(OHDF)''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0035'' THEN ''後補液 補液速度操作範囲上限(OHF)''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0036'' THEN ''治療開始時血流量使用有無''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0037'' THEN ''ＴＭＰゼロ補正警報上限(HD+補液)''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0038'' THEN ''ＴＭＰゼロ補正警報下限(HD+補液)''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0000'' THEN ''プライミング補助動脈充填液量''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0001'' THEN ''プライミング補助動脈充填流速''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0002'' THEN ''プライミング補助静脈充填液量''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0003'' THEN ''プライミング補助静脈充填流速''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0004'' THEN ''プライミング補助気泡抜き液量''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0005'' THEN ''プライミング補助気泡抜き流速''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0006'' THEN ''プライミング補助動脈充填後継続の有無''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0007'' THEN ''プライミング補助静脈充填後継続の有無''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0008'' THEN ''プライミング補助気泡抜き間欠動作選択''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0009'' THEN ''プライミング補助液交換量''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0010'' THEN ''プライミング補助間欠動作動作時間''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0011'' THEN ''プライミング補助間欠動作停止時間''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0012'' THEN ''自動プライミング開始時間''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0013'' THEN ''自動プライミング落差時間''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0014'' THEN ''自動プライミング送液液量''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0015'' THEN ''自動プライミング送液流速1回目''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0016'' THEN ''自動プライミング送液流速2回目以降''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0017'' THEN ''自動プライミング循環流速''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0018'' THEN ''自動プライミング循環時間''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0019'' THEN ''自動プライミング総量''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0000'' THEN ''ダイアライザ選択''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0001'' THEN ''IPラインプライミング使用選択''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0005'' THEN ''中空糸 プライミング時のBP速度''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0007'' THEN ''中空糸 送液最大時間''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0008'' THEN ''中空糸 回路内洗浄送液量''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0009'' THEN ''中空糸 気泡抜き動作実行回数''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0010'' THEN ''中空糸 気泡抜き圧力上限''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0011'' THEN ''中空糸 除水ポンプ速度''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0030'' THEN ''補液選択''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0031'' THEN ''前補液 ダイアライザー気泡抜き時間''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0032'' THEN ''前補液 動脈チャンバ液面作成時間''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0033'' THEN ''前補液 循環洗浄時間''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0034'' THEN ''治療モード''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0051'' THEN ''後補液 ダイアライザー気泡抜き時間''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0052'' THEN ''後補液 動脈チャンバ液面作成時間''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0053'' THEN ''後補液 循環洗浄時間''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0054'' THEN ''積層 送液最大時間''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0055'' THEN ''積層 回路内洗浄送液量''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0056'' THEN ''積層 気泡抜き動作実行回数''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0057'' THEN ''積層 気泡抜き圧力上限''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0058'' THEN ''積層 除水ポンプ速度''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0059'' THEN ''積層 プライミング時のBP速度''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0369'' THEN ''DP=Qd+Qs(補液速度加算)''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0379'' THEN ''前補液　OHDF/OHF　補液速度比率''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0039'' THEN ''後補液　OHDF/OHF　補液速度比率''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0263'' THEN ''自動測定2''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0264'' THEN ''自動測定3''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0265'' THEN ''自動測定4''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0266'' THEN ''自動測定5''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0039'' THEN ''除水開始遅延時間''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0270'' THEN ''動脈側返血使用選択''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0200'' THEN ''I-HDF　補液量設定''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0201'' THEN ''I-HDF　補液速度''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0202'' THEN ''I-HDF　補液周期''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0203'' THEN ''I-HDF　補液開始時間''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0204'' THEN ''I-HDF　除水再開時間''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0205'' THEN ''I-HDF　総補液量上限''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0090'' THEN ''濾過率（前補液）''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0091'' THEN ''ヘマトクリット（Ht）''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0092'' THEN ''総タンパク（TP）''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0195'' THEN ''血圧測定方法選択''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''B-0040'' THEN ''濾過率（後補液）''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0196'' THEN ''BV-UFC使用選択''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0197'' THEN ''UFC期間除水速度上限''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0198'' THEN ''UFC期間除水速度下限''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0199'' THEN ''開始期間 時間''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0206'' THEN ''開始期間 除水速度倍率''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0207'' THEN ''固定倍率除水期間 時間''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0208'' THEN ''固定倍率除水期間 除水速度倍率''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0209'' THEN ''固定倍率除水終了条件　最高血圧''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0210'' THEN ''固定倍率除水終了条件　脈拍''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0248'' THEN ''固定倍率除水終了条件　ΔBV''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0249'' THEN ''終了前期間 時間''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0268'' THEN ''透析液流量　設定方法''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0269'' THEN ''透析液流量　比率設定''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0271'' THEN ''開始時ΔBV基準値''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0272'' THEN ''ΔBV基準線　指数1''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0273'' THEN ''ΔBV基準線　指数2''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0274'' THEN ''ΔBV基準線　指数3''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0275'' THEN ''終了時ΔBV基準値''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0400'' THEN ''QBプログラム血流量1''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0401'' THEN ''QBプログラム血流量2''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0402'' THEN ''QBプログラム血流量3''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0403'' THEN ''QBプログラム血流量4''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0404'' THEN ''QBプログラム血流量5''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0405'' THEN ''QBプログラム血流量6''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0406'' THEN ''QBプログラム血流量7''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0407'' THEN ''QBプログラム血流量8''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0408'' THEN ''QBプログラム血流量9''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0409'' THEN ''QBプログラム血流量10''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0410'' THEN ''QDプログラム透析液流量1''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0411'' THEN ''QDプログラム透析液流量2''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0412'' THEN ''QDプログラム透析液流量3''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0413'' THEN ''QDプログラム透析液流量4''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0414'' THEN ''QDプログラム透析液流量5''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0415'' THEN ''QDプログラム透析液流量6''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0416'' THEN ''QDプログラム透析液流量7''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0417'' THEN ''QDプログラム透析液流量8''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0418'' THEN ''QDプログラム透析液流量9''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0419'' THEN ''QDプログラム透析液流量10''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0420'' THEN ''QB、QDプログラム切替時間1''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0421'' THEN ''QB、QDプログラム切替時間2''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0422'' THEN ''QB、QDプログラム切替時間3''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0423'' THEN ''QB、QDプログラム切替時間4''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0424'' THEN ''QB、QDプログラム切替時間5''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0425'' THEN ''QB、QDプログラム切替時間6''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0426'' THEN ''QB、QDプログラム切替時間7''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0427'' THEN ''QB、QDプログラム切替時間8''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0428'' THEN ''QB、QDプログラム切替時間9''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0429'' THEN ''QB、QDプログラム最大ステップ数''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0430'' THEN ''QBプログラム電源''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0431'' THEN ''QDプログラム電源''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0432'' THEN ''I-HDFプログラム使用選択''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0433'' THEN ''予定補液回数''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0434'' THEN ''補液バランス制限''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0435'' THEN ''補液量01''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0436'' THEN ''補液量02''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0437'' THEN ''補液量03''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0438'' THEN ''補液量04''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0439'' THEN ''補液量05''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0440'' THEN ''補液量06''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0441'' THEN ''補液量07''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0442'' THEN ''補液量08''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0443'' THEN ''補液量09''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0444'' THEN ''補液量10''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0445'' THEN ''補液量11''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0446'' THEN ''補液量12''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0447'' THEN ''補液量13''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0448'' THEN ''補液量14''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0449'' THEN ''補液量15''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0450'' THEN ''補液量16''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0451'' THEN ''回収量01''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0452'' THEN ''回収量02''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0453'' THEN ''回収量03''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0454'' THEN ''回収量04''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0455'' THEN ''回収量05''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0456'' THEN ''回収量06''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0457'' THEN ''回収量07''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0458'' THEN ''回収量08''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0459'' THEN ''回収量09''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0460'' THEN ''回収量10''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0461'' THEN ''回収量11''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0462'' THEN ''回収量12''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0463'' THEN ''回収量13''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0464'' THEN ''回収量14''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0465'' THEN ''回収量15''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0466'' THEN ''回収量16''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0468'' THEN ''VA確認報知基準値(静的静脈圧)''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0469'' THEN ''VA確認報知基準値(IAP ratio)''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0470'' THEN ''静的静脈圧記録 自動実施選択''
				WHEN ''A-0'' || ntss_db5_pm_dsi.value_2 = ''A-0471'' THEN ''血圧測定 自動実施選択''
			 END, 0, 17) AS setname --項目名
			 ,ntss_db5_pm_dsi.value_4 AS value --設定値(当日)
			 ,to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時(当日)
			 ,ntss_db5_pm_dsi.value_4 AS monvalue --設定値(月曜日)
			 ,to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS monupdate --更新日時(月曜日)
			 ,ntss_db5_pm_dsi.value_4 AS tuevalue --設定値(火曜日)
			 ,to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS tueupdate --更新日時(火曜日)
			 ,ntss_db5_pm_dsi.value_4 AS wedvalue --設定値(水曜日)
			 ,to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS wedupdate --更新日時(水曜日)
			 ,ntss_db5_pm_dsi.value_4 AS thuvalue --設定値(木曜日)
			 ,to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS thuupdate --更新日時(木曜日)
			 ,ntss_db5_pm_dsi.value_4 AS frivalue --設定値(金曜日)
			 ,to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS friupdate --更新日時(金曜日)
			 ,ntss_db5_pm_dsi.value_4 AS satvalue --設定値(土曜日)
			 ,to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS satupdate --更新日時(土曜日)
			 ,ntss_db5_pm_dsi.value_4 AS sunvalue --設定値(日曜日)
			 ,to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS sunupdate --更新日時(日曜日)
		FROM
			pat_main ntss_db5_pm
			INNER JOIN ntss_db5_pm_dsi
			ON ntss_db5_pm_dsi.pat_id = ntss_db5_pm.pat_id
			AND cast(ntss_db5_pm_dsi.value_2 AS integer) > 100
		WHERE ntss_db5_pm.is_del = ''0''
			AND ntss_db5_pm.facility_cd = @facilityCd
			AND ntss_db5_pm.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
			AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
			AND ntss_db5_pm.device_set_info IS NOT NULL
			AND ntss_db5_pm.device_set_info <> ''[]'';'
WHERE sql_cd = '-2450';


-- V_PAT_MEDICAL_HST
UPDATE sys_data_set
SET "sql"= 
		'SELECT
			'''' AS hosppatid --患者ID
			,ntss_db5_pu.pat_id AS patid
			,ntss_db5_pu_mhi_json ->> ''disp_order'' AS ctlno --管理番号
			,to_char(ntss_db5_pu.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
			,ntss_db5_pu_mhi_json ->> ''disease_cd'' AS diseasecd --病名コード
			,ntss_db5_pu_mst_d.disease_name AS diseasename --病名
			,to_char(to_timestamp(ntss_db5_pu_mhi_json ->> ''disease_date'', ''YYYYMMDD''), ''YYYY-MM-DD hh24:mi:ss'') AS diseasedate --発症日
			,to_char(to_timestamp(ntss_db5_pu_mhi_json ->> ''out_come_date'', ''YYYYMMDD''), ''YYYY-MM-DD hh24:mi:ss'') AS recoverdate --治癒日
			,ntss_db5_pu_mhi_json ->> ''is_main_disease'' AS maindisease --主病名
			,SUBSTR(ntss_db5_pu_mhi_json ->> ''out_come'', 0, 1) AS status --転帰
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
			AND ntss_db5_pu_mhi_json ->> ''course_is_free'' = ''1'';'
WHERE sql_cd = '-2040';

UPDATE sys_data_set
SET "sql"= 
		'SELECT
			'''' AS hosppatid --患者ID
			,ntss_db5_pu.pat_id AS patid
			,ntss_db5_pu_mhi_json ->> ''disp_order'' AS ctlno --管理番号
			,to_char(ntss_db5_pu.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
			,ntss_db5_pu_mhi_json ->> ''disease_cd'' AS diseasecd --病名コード
			,ntss_db5_pu_mst_d.disease_name AS diseasename --病名
			,to_char(to_timestamp(ntss_db5_pu_mhi_json ->> ''disease_date'', ''YYYYMMDD''), ''YYYY-MM-DD hh24:mi:ss'') AS diseasedate --発症日
			,to_char(to_timestamp(ntss_db5_pu_mhi_json ->> ''out_come_date'', ''YYYYMMDD''), ''YYYY-MM-DD hh24:mi:ss'') AS recoverdate --治癒日
			,ntss_db5_pu_mhi_json ->> ''is_main_disease'' AS maindisease --主病名
			,SUBSTR(ntss_db5_pu_mhi_json ->> ''out_come'', 0, 1) AS status --転帰
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
			AND ntss_db5_pu_mhi_json ->> ''course_is_free'' = ''0'';'
WHERE sql_cd = '-2041';
DELETE FROM "ntss"."sys_data_set" where "sql_cd" IN (-505,-506,-507,-508,-509);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-505, 'WITH ord_main_restore_info AS (
  SELECT * FROM ord_main_restore as ord_i
  WHERE ord_i.ord_no = @ordNo AND ord_i.facility_cd = @facilityCd
  ORDER BY del_date DESC LIMIT 1
)
SELECT
  ord.ord_no AS ord_no,
  ord.treat_date AS treat_date,--透析日
  COALESCE(mkr.in_hospital_cd_1, '''') AS kur_cd1,--クール
  COALESCE(ord.rst_kur_name, '''') AS kur_name,--クール名
  COALESCE(ord.rst_dialysis_cnt, 0) AS dialysis_cnt,--透析回数
  COALESCE(ord.rst_machine_no, 0) AS machine_no,--装置番号
  COALESCE(ord.rst_machine_name, '''') AS machine_name,--装置名
  COALESCE(ord.rst_course_name, '''') AS course_name,--診療科名
  COALESCE(mcs.in_hospital_cd_1, '''') AS course_cd,--診療科コード１
  COALESCE(ord.rst_ward_name, '''') AS ward_name,--病棟名
  COALESCE(mwd.in_hospital_cd_1, '''') AS ward_cd,--病棟コード１
  COALESCE(ord.rst_treatment_name, '''') AS treatment_name,--治療項目
  COALESCE(mtt.in_hospital_cd_a1, '''') AS treatment_cd,--治療項目コード１
  (CASE  mtt.device_mode 
    WHEN ''0'' THEN
      ''HD'' 
    WHEN ''1'' THEN
      ''ECUM'' 
    WHEN ''2'' THEN
      ''HDF'' 
    WHEN ''3'' THEN
      ''HF'' 
    WHEN ''4'' THEN
      ''HD+補液'' 
    WHEN ''5'' THEN
      ''ECUM+補液'' 
    WHEN ''6'' THEN
      ''AFBF'' 
    WHEN ''7'' THEN
      ''OHDF'' 
    WHEN ''8'' THEN
      ''OHF'' 
    WHEN ''9'' THEN
      ''特殊浄化'' 
    WHEN ''10'' THEN
      ''i-HDF'' ELSE''不明'' 
    END) AS device_mode,--装置モード
  COALESCE(ord.rst_dw, 0) AS dw,--dw
--mbd.bed_cd as bed_cd,--ベッドコード
  COALESCE(mbd.in_hospital_cd_1, '''') AS bed_cd1,
  COALESCE(mbd.bed_name, '''') AS bed_name,--ベッド名
  COALESCE(( CASE mbd.shunt_position WHEN ''0'' THEN ''両方'' WHEN ''1'' THEN ''左'' WHEN ''2'' THEN ''右'' WHEN ''3'' THEN ''なし'' ELSE''不明'' END ), '''') AS shunt_position,--シャント位置名称
  COALESCE(( CASE mbd.is_infection WHEN ''0'' THEN ''感染症無'' WHEN ''1'' THEN ''感染症対応'' ELSE''不明'' END ), '''') AS is_infection,--感染症フラグ
  COALESCE(( CASE mbd.emergency_class WHEN ''0'' THEN ''通常ベッド'' WHEN ''1'' THEN ''救急ベッド'' ELSE''不明'' END ), '''') AS emergency_class,--救急対応
  ord.rst_accept_date AS accept_date,--受付日時
  ord.rst_start_date AS start_date,--透析開始日時
  COALESCE(TO_CHAR( ord.rst_start_date, ''YYYYMMDDHH24MISS'' ), '''') AS start_date14,
  ord.rst_end_date AS end_date,--透析終了日時
  COALESCE(TO_CHAR( ord.rst_end_date, ''YYYYMMDDHH24MISS'' ), '''') AS end_date14,
  ord.rst_return_home_date AS return_home_date,--帰宅時刻
  ord.rst_in_out_class AS in_out_class,--入外コード
  COALESCE(( CASE ord.rst_in_out_class WHEN ''0'' THEN ''外来'' WHEN ''1'' THEN ''入院'' ELSE NULL END ), '''') AS in_out_name,--入外区分
  COALESCE(( CASE ord.rst_in_out_class WHEN ''0'' THEN ''1'' WHEN ''1'' THEN ''2'' ELSE NULL END ), '''') AS in_out_f,--入外区分（F)
  COALESCE(( CASE ord.rst_in_out_class WHEN ''0'' THEN ''1'' WHEN ''1'' THEN ''3'' ELSE NULL END ), '''') AS in_out_s,--入外区分（S)
  COALESCE(RIGHT ( ''00'' || TRUNC( TO_NUMBER( ord.rst_cond_info -> ''1'' ->> ''value'', ''FM999999'' ) / 60, 0 ), 2 ) || '':'' || RIGHT ( ''00'' || MOD ( TO_NUMBER( ord.rst_cond_info -> ''1'' ->> ''value'', ''FM999999'' ), 60 ), 2 ), '''') AS treatment_time,
  COALESCE(ord.rst_cond_info -> ''1'' ->> ''value'', '''') AS treatment_time_m,
  COALESCE(ord.rst_cond_info -> ''2'' ->> ''value_name_1'', '''') AS va,--シャント
  COALESCE(mva.in_hospital_cd_1, '''') AS va_cd1,--シャントコード１
  COALESCE(( CASE mva.va_direct WHEN ''0'' THEN ''両方'' WHEN ''1'' THEN ''左'' WHEN ''2'' THEN ''右'' WHEN ''3'' THEN ''なし'' ELSE''不明'' END ), '''') AS va_direct,--シャント方向
  COALESCE(ord.rst_cond_info -> ''3'' ->> ''value'', '''') AS target_weight,
  COALESCE(( CASE WHEN ord.rst_cond_info -> ''3'' ->> ''value'' = ''-1'' THEN ''DWと同じ'' ELSE''目標体重指定'' END ), '''') AS target_mode,--目標体重指定設定
  COALESCE(TO_CHAR( TO_NUMBER( ord.rst_cond_info -> ''4'' ->> ''value'', ''FM99.99'' ), ''FM90.99'' ), '''') AS water_removal_amount_limit,
  COALESCE(ord.rst_cond_info -> ''5'' ->> ''value_name_1'', '''') AS dialyzer,
  COALESCE(TRIM ( mdr.in_hospital_cd_1 ), '''') AS dialyzer_cd1,--ダイアライザコード１
  COALESCE(mdr.maker, '''') AS dialyzer_maker,--ダイアライザメーカ
  COALESCE(mdr.function_class, '''') AS function_class,--ダイアライザ機能分類
  COALESCE(mdr.area, 0) AS dialyzer_area,--ダイアライザ面積
  COALESCE(mdr.ufr, 0) AS dialyzer_ufr,--ダイアライザUFR
  COALESCE(mdr.koa, 0) AS dialyzer_KoA,--ダイアライザKoA
  COALESCE(mdr.material, '''') AS dialyzer_material,--ダイアライザ材質
  COALESCE(( CASE mdr.membrane_wash WHEN ''0'' THEN ''使用しない'' WHEN ''1'' THEN ''使用する'' ELSE''不明'' END ), '''') AS membrane_wash,--膜洗浄（中空糸）
  COALESCE(( CASE mdr.wetdry WHEN ''0'' THEN ''不明'' WHEN ''1'' THEN ''WET'' WHEN ''2'' THEN ''DRY'' ELSE''不明'' END ), '''') AS dialyzer_wetdry,--WET/DRY
  COALESCE(mdr.substituent_wash_amt, 0) AS substituent_wash_amt,--置換洗浄量（透析液）
  COALESCE(mdr.gas_purge_time, 0) AS gas_purge_time,--ガスパージ時間
  COALESCE(mdr.urea_clearance, 0) AS urea_clearance,--尿素クリアランス
  COALESCE(mdr.alqd_flood_vol, 0) AS alqd_flood_vol,--透析液流量
  COALESCE(mdr.bloodamt, 0) AS dialyzer_bloodamt,--血流量
  COALESCE(mdr.sterilization, '''') AS sterilization,--滅菌
  COALESCE(ord.rst_cond_info -> ''6'' ->> ''value_name_1'', '''') AS adsorption_column,
  COALESCE(meqad.in_hospital_cd_1, '''') AS ad_cd1,--吸着器コード１
  COALESCE(ord.rst_cond_info -> ''7'' ->> ''value_name_1'', '''') AS primary_film,
  COALESCE(meqpr.in_hospital_cd_1, '''') AS pr_cd1,--1次膜コード１
  COALESCE(ord.rst_cond_info -> ''8'' ->> ''value_name_1'', '''') AS secondary_film,
  COALESCE(meqse.in_hospital_cd_1, '''') AS se_cd1,--2次膜コード１
  COALESCE(ord.rst_cond_info -> ''9'' ->> ''value_name_1'', '''') AS puncture_needle_a,
  COALESCE(meqa.in_hospital_cd_1, '''') AS a_cd1,--穿刺針Aコード１
  COALESCE(ord.rst_cond_info -> ''10'' ->> ''value_name_1'', '''') AS puncture_needle_v,
  COALESCE(meqv.in_hospital_cd_1, '''') AS v_cd1,--穿刺針Vコード１
  COALESCE(ord.rst_cond_info -> ''11'' ->> ''value_name_1'', '''') AS puncture_needle_sn,
  COALESCE(meqsn.in_hospital_cd_1, '''') AS sn_cd1,--穿刺針SNコード１
  COALESCE(( CASE ord.rst_cond_info -> ''12'' ->> ''value'' WHEN ''1'' THEN ''有り'' WHEN ''0'' THEN ''無し'' ELSE NULL END ), '''') AS single_needle,
  COALESCE(ord.rst_cond_info -> ''13'' ->> ''value'', '''') AS blood_circuit,
  COALESCE(meqbc.in_hospital_cd_1, '''') AS bc_cd1,--血液回路コード１
  COALESCE(ord.rst_cond_info -> ''14'' ->> ''value'', '''') AS blood_flow,--血流量
  COALESCE(ord.rst_cond_info -> ''15'' ->> ''value_name_1'', '''') AS dialysate,
  COALESCE(( CASE ord.rst_cond_info -> ''15'' ->> ''medicine_type'' WHEN ''1'' THEN med15.in_hospital_cd_1 WHEN ''2'' THEN mmmx.in_hospital_cd_1 END ), '''') AS ds_cd,
  COALESCE(ord.rst_cond_info -> ''16'' ->> ''value'', '''') AS dialysate_flow_rate,
  COALESCE(ord.rst_cond_info -> ''17'' ->> ''value'', '''') AS dialysate_amount,
  COALESCE(ord.rst_cond_info -> ''17'' ->> ''unit'', '''') AS dialysate_amount_unit,
  COALESCE(ord.rst_cond_info -> ''18'' ->> ''value'', '''') AS dialysate_temperature,
  COALESCE(ord.rst_cond_info -> ''19'' ->> ''value_name_1'', '''') AS fluid_replacement,
  COALESCE(( CASE ord.rst_cond_info -> ''19'' ->> ''medicine_type'' WHEN ''1'' THEN med19.in_hospital_cd_1 WHEN ''2'' THEN mmmmx.in_hospital_cd_1 END ), '''') AS ds_cd2,--補液コード１
  COALESCE(ord.rst_cond_info -> ''20'' ->> ''value'', '''') AS fluid_replacement_amount,
  COALESCE(( CASE ord.rst_cond_info -> ''21'' ->> ''value'' WHEN ''1'' THEN ''前補液'' WHEN ''0'' THEN ''後補液'' ELSE NULL END ), '''') AS fluid_replacement_timing,
  COALESCE(ord.rst_cond_info -> ''21'' ->> ''value'', '''') AS fluid_replacement_timing_ssi,
  COALESCE(ord.rst_cond_info -> ''22'' ->> ''value'', '''') AS fluid_replacement_use_count,
  COALESCE(ord.rst_cond_info -> ''22'' ->> ''unit'', '''') AS fluid_replacement_use_count_unit,
  COALESCE(ord.rst_cond_info -> ''23'' ->> ''value'', '''') AS fluid_replacement_temperature,
  COALESCE(ord.rst_cond_info -> ''24'' ->> ''value'', '''') AS fluid_replacement_speed,
  COALESCE(ord.rst_cond_info -> ''25'' ->> ''value_name_1'', '''') AS anti_coagulant,
  COALESCE(( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''1'' THEN med25.in_hospital_cd_1 WHEN ''2'' THEN mmx.in_hospital_cd_1 END ), '''') AS ds_cd1,--抗凝固剤コード１
  COALESCE(ord.rst_cond_info -> ''26'' ->> ''value'', '''') AS anti_coagulant_one_shot_amount,
  COALESCE(ord.rst_cond_info -> ''26'' ->> ''unit'', '''') AS anti_coagulant_one_shot_amount_unit,
  COALESCE(ord.rst_cond_info -> ''27'' ->> ''value'', '''') AS anti_coagulant_sustained_speed,
  COALESCE(ord.rst_cond_info -> ''27'' ->> ''unit'', '''') AS anti_coagulant_sustained_speed_unit,
  COALESCE(ord.rst_cond_info -> ''28'' ->> ''value'', '''') AS anti_coagulant_sustained_amount,
  COALESCE(ord.rst_cond_info -> ''28'' ->> ''unit'', '''') AS anti_coagulant_sustained_amount_unit,
  COALESCE(TO_NUMBER( ord.rst_cond_info -> ''26'' ->> ''value'', ''FM999999999999'' ) + TO_NUMBER( ord.rst_cond_info -> ''28'' ->> ''value'', ''FM999999999999'' ), 0) AS anti_coagulant_total_amount,--抗凝固剤総量
  COALESCE(( CASE ord.rst_cond_info -> ''29'' ->> ''value'' WHEN ''1'' THEN ''使用する'' WHEN ''0'' THEN ''使用しない'' ELSE NULL END ), '''') AS ip,
  COALESCE(( CASE ord.rst_cond_info -> ''30'' ->> ''value'' WHEN ''0'' THEN ''手動'' WHEN ''1'' THEN ''自動'' ELSE NULL END ), '''') AS ip_start,
  COALESCE(ord.rst_cond_info -> ''30'' ->> ''value'', '''') AS ip_start_ssi,
  COALESCE(ord.rst_cond_info -> ''31'' ->> ''value'', '''') AS ip_one_short_amount,
  COALESCE(ord.rst_cond_info -> ''32'' ->> ''value'', '''') AS ip_speed,
  COALESCE(ord.rst_cond_info -> ''33'' ->> ''value'', '''') AS ip_speed_max,
  COALESCE(( CASE ord.rst_cond_info -> ''34'' ->> ''value'' WHEN ''1'' THEN ''使用する'' WHEN ''0'' THEN ''使用しない'' ELSE NULL END ), '''') AS auto_one_shot,
  COALESCE(ord.rst_cond_info -> ''34'' ->> ''value'', '''') AS auto_one_shot_ssi,
  COALESCE(( CASE ord.rst_cond_info -> ''35'' ->> ''value'' WHEN ''1'' THEN ''入'' WHEN ''0'' THEN ''切'' ELSE NULL END ), '''') AS ip_auto_off,
  COALESCE(ord.rst_cond_info -> ''35'' ->> ''value'', '''') AS ip_auto_off_ssi,
  COALESCE(ord.rst_cond_info -> ''36'' ->> ''value'', '''') AS ip_auto_off_time,
  COALESCE(( CASE ord.rst_cond_info -> ''37'' ->> ''value'' WHEN ''1'' THEN ''入'' WHEN ''0'' THEN ''切'' ELSE NULL END ), '''') AS ip_monitor_auto_off,
  COALESCE(ord.rst_cond_info -> ''37'' ->> ''value'', '''') AS ip_monitor_auto_off_ssi,
  COALESCE(ord.rst_cond_info -> ''38'' ->> ''value'', '''') AS ip_monitor_auto_off_time,
  ord.rst_puncture_user_info -> ''date'' AS puncture_date,--穿刺時刻
  ord.rst_puncture_user_info -> ''user_id_1'' AS puncture1_id,--穿刺者１ID
  COALESCE(concat ( ord.rst_puncture_user_info ->> ''user_last_name_1'', ord.rst_puncture_user_info ->> ''user_first_name_1'' ), '''') AS puncture1_name,--穿刺者1
  ord.rst_puncture_user_info -> ''date_1''AS puncture1_date,--穿刺時刻1
  ord.rst_puncture_user_info -> ''user_id_2'' AS puncture2_id,--穿刺者２ID
  COALESCE(concat ( ord.rst_puncture_user_info ->> ''user_last_name_2'', ord.rst_puncture_user_info ->> ''user_first_name_2'' ), '''') AS puncture2_name,--穿刺者2
  ord.rst_puncture_user_info -> ''date_2'' AS puncture2_date,--穿刺時刻2
  ord.rst_return_user_info -> ''date'' AS return_date,--回収時刻
  ord.rst_return_user_info -> ''user_id_1'' AS return1_id,--回収者１ID
  COALESCE(concat ( ord.rst_return_user_info ->> ''user_last_name_1'', ord.rst_return_user_info ->> ''user_first_name_1'' ), '''') AS return1_name,--回収者1
  ord.rst_return_user_info -> ''date_1'' AS return1_date,--回収時刻1
  ord.rst_return_user_info -> ''user_id_2'' AS return2_id,--回収者２ID
  COALESCE(concat ( ord.rst_return_user_info ->> ''user_last_name_2'', ord.rst_return_user_info ->> ''user_first_name_2'' ), '''') AS return2_name,--回収者2
  ord.rst_return_user_info -> ''date_2'' AS return2_date,--回収時刻2
  ord.rst_charge_user_info -> ''user_id_1'' AS charge1_id,--担当者１ID
  COALESCE(concat ( ord.rst_charge_user_info ->> ''user_last_name_1'', ord.rst_charge_user_info ->> ''user_first_name_1'' ), '''') AS charge1_name,--担当者1
  ord.rst_charge_user_info -> ''date_1'' AS charge1_date,--担当時刻1
  ord.rst_charge_user_info -> ''user_id_2'' AS charge2_id,--担当者２ID
  COALESCE(concat ( ord.rst_charge_user_info ->> ''user_last_name_2'', ord.rst_charge_user_info ->> ''user_first_name_2'' ), '''') AS charge2_name,--担当者2
  ord.rst_charge_user_info -> ''date_2'' AS charge2_date,--担当時刻2
  ord.rst_running_time AS running_time,--透析運転時間
  TRIM((to_char((to_number(substring(to_char(ord.rst_end_date-ord.rst_start_date,''HH24MI''),1,2),''99'') * 60 + to_number(substring(to_char(ord.rst_end_date-ord.rst_start_date,''HH24MI''),3,2),''99'')),''999999999''))) AS running_time_cal,--透析運転時間_計算
  COALESCE(ord.pull_leave_amount, 0) AS pull_leave_amount,--引き残し量
  COALESCE(TO_CHAR( TO_NUMBER( ord.rst_weight_info ->> ''weight_before'', ''FM999.99'' ), ''FM990.99'' ), '''') AS weight_before,
  COALESCE(TO_CHAR( TO_NUMBER( ord.rst_weight_info ->> ''weight_after'', ''FM999.99'' ), ''FM990.99'' ), '''') AS weight_after,
	CASE WHEN LENGTH(TO_CHAR(ord.ord_no, ''FM9999999999999999999'')) >= 12 THEN TO_CHAR(ord.ord_no, ''FM9999999999999999999'') ELSE LPAD(TO_CHAR(ord.ord_no, ''FM9999999999999999999''), 12, ''0'') END AS ord_no12,
  COALESCE(TO_CHAR( ord.up_date, ''YYYYMMDDHH24MISS'' ), '''') AS up_date14,
  COALESCE(ord.ind_schedule_user_info ->> ''ind_user_id'', '''') AS ind_user_id,
  COALESCE(TO_CHAR( ord.up_date, ''YYYYMMDD'' ), '''') AS up_date8,
  COALESCE(TO_CHAR( ord.up_date, ''HH24MISS'' ), '''') AS up_date6 
  FROM
    ord_main_restore_info AS ord
    LEFT OUTER JOIN mst_equipment AS meqa ON meqa.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''9'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_equipment AS meqv ON meqv.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''10'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_equipment AS meqsn ON meqsn.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''11'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_equipment AS meqad ON meqad.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''6'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_equipment AS meqpr ON meqpr.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''7'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_equipment AS meqbc ON meqbc.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''13'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_equipment AS meqse ON meqse.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''8'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_medicine AS med15 ON med15.medicine_cd = TO_NUMBER( ord.rst_cond_info -> ''15'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_medicine AS med19 ON med19.medicine_cd = TO_NUMBER( ord.rst_cond_info -> ''19'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_medicine AS med25 ON med25.medicine_cd = TO_NUMBER( ord.rst_cond_info -> ''25'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_treatment AS mtt ON mtt.treatment_cd = ord.rst_treatment_cd
    LEFT OUTER JOIN mst_dialyzer AS mdr ON mdr.dialyzer_cd = TO_NUMBER( ord.rst_cond_info -> ''5'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_va AS mva ON mva.va_cd = TO_NUMBER( ord.rst_cond_info -> ''2'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_bed AS mbd ON mbd.bed_cd = ord.rst_bed_cd
    LEFT OUTER JOIN mst_course AS mcs ON mcs.course_cd = ord.rst_course_cd
    LEFT OUTER JOIN mst_ward AS mwd ON mwd.ward_cd = ord.rst_ward_cd
    LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( ord.rst_cond_info -> ''25'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_medicine_mix AS mmmx ON mmmx.medicine_mix_cd = TO_NUMBER( ord.rst_cond_info -> ''15'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_medicine_mix AS mmmmx ON mmmmx.medicine_mix_cd = TO_NUMBER( ord.rst_cond_info -> ''19'' ->> ''value'', ''FM999999999999'' )
    LEFT OUTER JOIN mst_kur AS mkr ON mkr.kur_cd = ord.rst_kur_cd 
WHERE
  ord.ord_no =  @ordNo', 2, '[{}]', '0', '{"applications": [4]}', NULL, 'NKK)  実績）透析条件（削除）', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-506, 'WITH ord_main_restore_info AS (
  SELECT * FROM ord_main_restore as ord_i
  WHERE ord_i.ord_no = @ordNo AND ord_i.facility_cd = @facilityCd
  ORDER BY del_date DESC LIMIT 1
)
select
  to_char(ord.rst_start_date,''YYYYMMDDHH24MISS'') as start_date14,--透析開始日時
  to_char(ord.rst_start_date,''YYYY/MM/DD HH24:MI:SS'') as start_date14a,--透析開始日時
  to_char(ord.rst_start_date,''YYYYMMDD'') as start_date8,--透析開始日時
  to_char(ord.rst_start_date,''YYYY/MM/DD'') as start_date8a,--透析開始日時
  to_char(ord.rst_start_date,''HH24MISS'') as start_date6,--透析開始日時
  to_char(ord.rst_start_date,''HH24:MI:SS'') as start_date6a,--透析開始日時
  to_char(ord.rst_end_date,''YYYYMMDDHH24MISS'') as end_date14,--透析終了日時
  to_char(ord.rst_end_date,''YYYYMMDD'') as end_date8,--透析終了日時
  to_char(ord.rst_end_date,''HH24MISS'') as end_date6,--透析終了日時
  to_char(ord.rst_end_date,''YYYY/MM/DD HH24:MI:SS'') as end_date14a,--透析終了日時
  to_char(ord.rst_end_date,''YYYY/MM/DD'') as end_date8a,--透析終了日時
  to_char(ord.rst_end_date,''HH24:MI:SS'') as end_date6a,--透析終了日時
  to_char(ord.rst_start_date,''HH24MI'') as start_time4,--透析開始時刻
  to_char(ord.rst_end_date,''HH24MI'') as end_time4,--透析終了時刻
  ord.rst_running_time as running_time,
	--(case when ord.rst_start_date is not null and ord.rst_end_date is not null then(case when date_part(''''day'''', ord.rst_end_date - ord.rst_start_date) * 24 * 60 + date_part(''''hour'''', ord.rst_end_date - ord.rst_start_date)* 60 + date_part(''''minute'''', ord.rst_end_date - ord.rst_start_date)<=999 then date_part(''''day'''', ord.rst_end_date - ord.rst_start_date) * 24 * 60 + date_part(''''hour'''', ord.rst_end_date - ord.rst_start_date)* 60 + date_part(''''minute'''', ord.rst_end_date - ord.rst_start_date) else null end ) else null  end)::TEXT as running_time_str,
	(case when ord.rst_start_date is not null and ord.rst_end_date is not null then(case when date_part(''day'', ord.rst_end_date - ord.rst_start_date) * 24 * 60 + date_part(''hour'', ord.rst_end_date - ord.rst_start_date)* 60 + date_part(''minute'', ord.rst_end_date - ord.rst_start_date)<=999 then date_part(''day'', ord.rst_end_date - ord.rst_start_date) * 24 * 60 + date_part(''hour'', ord.rst_end_date - ord.rst_start_date)* 60 + date_part(''minute'', ord.rst_end_date - ord.rst_start_date) else null end ) else null  end)::TEXT as running_time_str,
  RIGHT(''00''||TRUNC(TO_NUMBER(ord.rst_cond_info->''1''->>''value'',''999999'')/60,0),2)||'':''||RIGHT(''00''||MOD(TO_NUMBER(ord.rst_cond_info->''1''->>''value'',''999999''),60),2) as treatment_time,
  to_char(timestamp ''now'',''YYYYMMDDHH24MISS'') as nowtime14,
  ord.treat_date as treat_date,
  ord.ind_treat_start_time || ''00'' as ind_treat_start_time
from
  ord_main_restore_info as ord
where
  ord.ord_no = @ordNo', 2, '[{}]', '0', '{"applications": [4]}', NULL, 'NKK)  実績）透析開始終了日時変換（削除）', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-507, 'WITH 
	ord_main_restore_info AS (
		SELECT * FROM ord_main_restore as ord_i
		WHERE ord_i.ord_no = @ordNo AND ord_i.facility_cd = @facilityCd
		ORDER BY del_date DESC LIMIT 1
	),
	A AS ( 
	SELECT (((rst_cond_info -> ''26'' ->> ''value'' )::FLOAT + (rst_cond_info -> ''28'' ->> ''value'')::FLOAT))::TEXT AS anti_coagulant_amount
	FROM ord_main_restore_info 
	WHERE ord_no = @ordNo
	),
 B AS (
SELECT COALESCE
	( NULLIF( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS default_setting 
FROM
	mst_coop_ini AS ini
	CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
WHERE
	facility_cd = @facilityCd
 
	AND is_del = ''0'' 
	AND info ->> ''key1'' = ''DIALYSISSEND'' 
	AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'' 
	) 
SELECT B.default_setting,
(CASE A.anti_coagulant_amount::FLOAT >= 1
	WHEN true THEN
		LPAD(split_part((A.anti_coagulant_amount::FLOAT*100)::TEXT, ''.'', 1), 8, '' '')
	ELSE
		(
		CASE B.default_setting
	WHEN ''0'' THEN
		LPAD(split_part((A.anti_coagulant_amount::FLOAT*100)::TEXT, ''.'', 1), 8, '' '')
	WHEN ''1'' THEN
		LPAD(LPAD(split_part((A.anti_coagulant_amount::FLOAT*100)::TEXT, ''.'', 1), 3, ''0''), 8, '' '')
  END
	)
END
) AS calculate_one_shot_amount
FROM A,B', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'NKK)  透析実績：抗凝固剤総量（単体薬剤）（削除）', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-508, 'WITH ord_main_restore_info AS (
		SELECT * FROM ord_main_restore as ord_i
		WHERE ord_i.ord_no = @ordNo AND ord_i.facility_cd = @facilityCd
		ORDER BY del_date DESC LIMIT 1
),
dialysateSql AS (
SELECT COALESCE
	(info ->> ''value'', info ->> ''default_v'')::int as dialysateTransCd
FROM
	mst_coop_ini AS ini
	CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info
WHERE
	facility_cd = @facilityCd

	AND is_del = ''0''
	AND info ->> ''key1'' = ''DIALYSISSEND''
	AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'')
SELECT
	CASE when (ord.rst_cond_info -> ''17'' ->> ''value'') ISNULL
	THEN (case dialysateSql.dialysateTransCd
	   WHEN 0 THEN ''0''
	   WHEN 1 THEN ''000'' END)
  WHEN
  (ord.rst_cond_info -> ''17'' ->> ''value'')::numeric >= 1
	THEN (case when strpos((ord.rst_cond_info -> ''17'' ->> ''value''), ''.'') <= 0 then
	     trim(to_char(((ord.rst_cond_info -> ''17'' ->> ''value'')::numeric)*100,''999999''))
	     else trim(to_char((SUBSTR(trim((ord.rst_cond_info -> ''17'' ->> ''value'')),0,strpos((ord.rst_cond_info -> ''17'' ->> ''value''), ''.'')+3)::numeric)*100,''999999'')) end )
	ELSE (case dialysateSql.dialysateTransCd
	WHEN 0 THEN trim(to_char((SUBSTR(trim((ord.rst_cond_info -> ''17'' ->> ''value'')),0,5)::numeric)*100,''99''))
	WHEN 1 THEN trim(to_char((SUBSTR(trim((ord.rst_cond_info -> ''17'' ->> ''value'')),0,5)::numeric)*100,''000''))
  END )
	END AS dialysate_amount
	from ord_main_restore_info ord,dialysateSql
WHERE
  ord.ord_no =  @ordNo', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(送信用)日機装)rst_dial連携:透析液使用量（単体薬剤）（削除）', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-509, 'WITH ord_main_restore_info AS (
		SELECT * FROM ord_main_restore as ord_i
		WHERE ord_i.ord_no = @ordNo AND ord_i.facility_cd = @facilityCd
		ORDER BY del_date DESC LIMIT 1
),
query0 AS (--酸素吸入用薬剤コード
SELECT COALESCE
	(info ->> ''value'', info ->> ''default_v'')::text as oxygen_medi_cd
FROM
	mst_coop_ini AS ini
	CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info
WHERE
	facility_cd = @facilityCd
	AND is_del = ''0''
	AND info ->> ''key1'' = ''DIALYSISSEND''
	AND info ->> ''key2'' = ''OXYGEN_CODE''),
query1 AS (--酸素吸入量
	SELECT SUM
		( to_number( COALESCE ( NULLIF ( T.result_value, '''' ), ''0'' ), ''9999999.99'' ) ) sumResultValue1
	FROM
		( SELECT jsonb_array_elements ( ord.rst_treatment_info :: jsonb ) ->> ''oxygen_amount'' AS result_value FROM ord_main_restore_info ord WHERE ord.ord_no = @ordNo
 ) T
	),
query2 AS (--愁訴処置の酸素吸入用薬剤量
		SELECT SUM
		( to_number( COALESCE ( NULLIF ( T.result_value, '''' ), ''0'' ), ''9999999.99'' ) ) sumResultValue2
	FROM
		(
		SELECT A
			.result_value
		FROM
			(
			SELECT
				jsonb_array_elements ( ord.rst_treatment_info :: jsonb ) ->> ''amount'' AS result_value,
				jsonb_array_elements ( ord.rst_treatment_info :: jsonb ) ->> ''treat_medicine_cd'' AS treat_medicine_cd
			FROM
				ord_main_restore_info ord
			WHERE
				ord.ord_no =@ordNo
			) A ,mst_medicine mme ,query0
			WHERE A.treat_medicine_cd = mme.medicine_cd::text
      and 
			mme.in_hospital_cd_1 = query0.oxygen_medi_cd
		) T
	) ,
query3 AS (--投与薬剤の酸素吸入用薬剤量
		SELECT SUM
		( to_number( COALESCE ( NULLIF ( T.result_value, '''' ), ''0'' ), ''9999999.99'' ) ) sumResultValue3
	FROM
		(
		SELECT A
			.result_value
		FROM
			(
			SELECT
				jsonb_array_elements ( ord.rst_medi_info :: jsonb ) ->> ''amount'' AS result_value,
				jsonb_array_elements ( ord.rst_medi_info :: jsonb ) ->> ''cd'' AS medicine_cd
			FROM
				ord_main_restore_info ord
			WHERE
				ord.ord_no =@ordNo
			) A ,mst_medicine mme,query0
			WHERE A.medicine_cd = mme.medicine_cd::text
      and 
			mme.in_hospital_cd_1 = query0.oxygen_medi_cd
		) T
	),
query4 AS (--合算値
SELECT
(COALESCE(query1.sumResultValue1,0)+ COALESCE(query2.sumResultValue2,0)+COALESCE(query3.sumResultValue3,0))  AS oxygen_amount
FROM
	query1,
	query2,
	query3)
SELECT
	trim(to_char((query4.oxygen_amount)*100,''999999'')) AS oxygen_amount
	from query4', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(送信用)日機装)rst_dial連携:酸素吸入量（削除）', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

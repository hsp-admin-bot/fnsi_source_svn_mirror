DELETE FROM sys_data_set
WHERE sql_cd IN (-437);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-437, '-- 【SQL_CD=-437】
 SELECT
   ''条件指示'' AS detail_id,
   split_part( cond_arr.cond_row, ''-@-'', 1 ) AS item_cd,
   split_part( cond_arr.cond_row, ''-@-'', 2 ) AS item_name,
   split_part( cond_arr.cond_row, ''-@-'', 3 ) AS item_value,
   split_part( cond_arr.cond_row, ''-@-'', 4 ) AS item_value_name,
   split_part( cond_arr.cond_row, ''-@-'', 5 ) AS item_value_unit, 
   split_part( cond_arr.cond_row, ''-@-'', 6 ) AS ind_user_id, 
   split_part( cond_arr.cond_row, ''-@-'', 7 ) AS upd_user_id, 
   split_part( cond_arr.cond_row, ''-@-'', 8 ) AS up_date, 
   split_part( cond_arr.cond_row, ''-@-'', 9 ) AS add_item  
 FROM
   (
   SELECT
     regexp_split_to_table(
       array_to_string(
         ARRAY [ concat ( ''001-@-透析開始時刻-@-'', ord.ind_treat_start_time, ''-@--@-'', ''-@--@-'' ),
         concat ( ''002-@-透析時間-@-'', ord.ind_cond_info -> ''1'' ->> ''value'', ''-@--@-分'', ''-@-'', ord.ind_cond_info -> ''1'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''1'' ->> ''upd_user_id'' ),
         concat ( ''003-@-VA-@-'', TRIM ( mva.in_hospital_cd_1 ), ''-@-'', ord.ind_cond_info -> ''2'' ->> ''value_name_1'', ''-@-'', ''-@-'', ord.ind_cond_info -> ''2'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''2'' ->> ''upd_user_id'' ),
         concat ( ''004-@-DW-@-'', physical ->> ''dw'', ''-@-'', ''-@-'', ''kg'', ''-@--@-'' ),
         concat ( ''005-@-目標体重-@-'', ord.ind_cond_info -> ''3'' ->> ''value'', ''-@-'', ''-@-'', ''kg'', ''-@-'', ord.ind_cond_info -> ''3'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''3'' ->> ''upd_user_id'' ),
         concat ( ''006-@-治療方法-@-'', mtt.in_hospital_cd_a1, ''-@-'', mtt.treatment_name, ''-@-'', ''-@--@--@--@-'', mtt.device_mode ),
         concat ( ''007-@-除水量制限-@-'', to_char( to_number( ord.ind_cond_info -> ''4'' ->> ''value'', ''99.99'' ), ''FM90.99'' ), ''-@-'', ''-@-'', ''L'', ''-@-'', ord.ind_cond_info -> ''4'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''4'' ->> ''upd_user_id'' ),
         concat ( ''008-@-ダイアライザー-@-'', TRIM ( mdr.in_hospital_cd_1 ), ''-@-'', ord.ind_cond_info -> ''5'' ->> ''value_name_1'', ''-@-'', ''-@-'', ord.ind_cond_info -> ''5'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''5'' ->> ''upd_user_id'' ),
         concat ( ''009-@-吸着カラム-@-'', TRIM ( meqad.in_hospital_cd_1 ), ''-@-'', ord.ind_cond_info -> ''6'' ->> ''value_name_1'', ''-@-'', ''-@-'', ord.ind_cond_info -> ''6'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''6'' ->> ''upd_user_id'' ),
         concat ( ''010-@-血流量-@-'', ord.ind_cond_info -> ''14'' ->> ''value'', ''-@-'', ''-@-'', ''mL/min'', ''-@-'', ord.ind_cond_info -> ''14'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''14'' ->> ''upd_user_id'' ),
         concat (
           ''011-@-抗凝固剤-@-'',
           ( CASE ord.ind_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''1'' THEN med25.in_hospital_cd_1 WHEN ''2'' THEN mmx.in_hospital_cd_1 END ),
           ''-@-'',
           ord.ind_cond_info -> ''25'' ->> ''value_name_1'',
           ''-@-'', 
           ''-@-'', ord.ind_cond_info -> ''25'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''25'' ->> ''upd_user_id'' ),
         concat ( ''012-@-抗凝固剤ワンショット量-@-'', ord.ind_cond_info -> ''26'' ->> ''value'', ''-@-'', ''-@-'', ord.ind_cond_info -> ''26'' ->> ''unit'', ''-@-'', ord.ind_cond_info -> ''26'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''26'' ->> ''upd_user_id'' ),
         concat ( ''013-@-抗凝固剤持続速度-@-'', ord.ind_cond_info -> ''27'' ->> ''value'', ''-@-'', ''-@-'', ord.ind_cond_info -> ''27'' ->> ''unit'', ''-@-'', ord.ind_cond_info -> ''27'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''27'' ->> ''upd_user_id'' ),
         concat ( ''014-@-抗凝固剤持続総量-@-'', ord.ind_cond_info -> ''28'' ->> ''value'', ''-@-'', ''-@-'', ord.ind_cond_info -> ''28'' ->> ''unit'', ''-@-'', ord.ind_cond_info -> ''28'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''28'' ->> ''upd_user_id'' ),
         concat (
           ''015-@-IP使用選択-@-'',
           ord.ind_cond_info -> ''29'' ->> ''value'',
           ''-@-'',
           ( CASE ord.ind_cond_info -> ''29'' ->> ''value'' WHEN ''1'' THEN ''使用する'' WHEN ''0'' THEN ''使用しない'' ELSE NULL END ),
           ''-@-'', 
           ''-@-'', ord.ind_cond_info -> ''29'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''29'' ->> ''upd_user_id'' ),
         concat ( ''016-@-IPワンショット量-@-'', ord.ind_cond_info -> ''31'' ->> ''value'', ''-@-'', ''-@-'', ''mL'', ''-@-'', ord.ind_cond_info -> ''31'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''31'' ->> ''upd_user_id'' ),
         concat ( ''017-@-IP速度-@-'', ord.ind_cond_info -> ''32'' ->> ''value'', ''-@-'', ''-@-'', ''“mL/h'', ''-@-'', ord.ind_cond_info -> ''32'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''32'' ->> ''upd_user_id'' ),
         concat (
           ''018-@-透析液-@-'',
           (
           CASE
               ord.ind_cond_info -> ''15'' ->> ''medicine_type'' 
               WHEN ''1'' THEN
               TRIM ( med15.in_hospital_cd_1 ) 
               WHEN ''2'' THEN
               TRIM ( mmmx.in_hospital_cd_1 ) 
             END 
             ),
             ''-@-'',
             ord.ind_cond_info -> ''15'' ->> ''value_name_1'',
             ''-@-'', 
             ''-@-'', ord.ind_cond_info -> ''15'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''15'' ->> ''upd_user_id'' ),
           concat ( ''019-@-透析液流量-@-'', ord.ind_cond_info -> ''16'' ->> ''value'', ''-@-'', ''-@-'', ''mL/min'', ''-@-'', ord.ind_cond_info -> ''16'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''16'' ->> ''upd_user_id'' ),
           concat ( ''020-@-透析液量-@-'', ord.ind_cond_info -> ''17'' ->> ''value'', ''-@-'', ''-@-'', ord.ind_cond_info -> ''17'' ->> ''unit'', ''-@-'', ord.ind_cond_info -> ''17'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''17'' ->> ''upd_user_id'' ),
           concat ( ''021-@-透析液温度-@-'', ord.ind_cond_info -> ''18'' ->> ''value'', ''-@-'', ''-@-'', ''℃'', ''-@-'', ord.ind_cond_info -> ''18'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''18'' ->> ''upd_user_id'' ),
           concat (
             ''022-@-補液-@-'',
             ( CASE ord.ind_cond_info -> ''19'' ->> ''medicine_type'' WHEN ''1'' THEN med19.in_hospital_cd_1 WHEN ''2'' THEN mmmmx.in_hospital_cd_1 END ),
             ''-@-'',
             ord.ind_cond_info -> ''19'' ->> ''value_name_1'',
             ''-@-'', 
             ''-@-'', ord.ind_cond_info -> ''19'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''19'' ->> ''upd_user_id'' ),
           concat ( ''023-@-補液量-@-'', ord.ind_cond_info -> ''20'' ->> ''value'', ''-@-'', ''-@-'', ''L'', ''-@--@-'' ),
           concat (
             ''024-@-補液選択-@-'',
             ord.ind_cond_info -> ''21'' ->> ''value'',
             ''-@-'',
             ( CASE ord.ind_cond_info -> ''21'' ->> ''value'' WHEN ''1'' THEN ''前補液'' WHEN ''0'' THEN ''後補液'' ELSE NULL END ),
             ''-@-'', 
             ''-@-'', ord.ind_cond_info -> ''21'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''21'' ->> ''upd_user_id'' ),
           concat ( ''025-@-補液温度-@-'', ord.ind_cond_info -> ''23'' ->> ''value'', ''-@-'', ''-@-'', ''℃'', ''-@-'', ord.ind_cond_info -> ''23'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''23'' ->> ''upd_user_id'' ),
           concat (
             ''029-@-シングルニードル電源-@-'',
             ord.ind_cond_info -> ''12'' ->> ''value'',
             ''-@-'',
             ( CASE ord.ind_cond_info -> ''12'' ->> ''value'' WHEN ''1'' THEN ''使用する'' WHEN ''0'' THEN ''使用しない'' ELSE NULL END ),
             ''-@-'', 
             ''-@-'', ord.ind_cond_info -> ''12'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''12'' ->> ''upd_user_id'' ),
           concat ( ''030-@-補液使用数-@-'', ord.ind_cond_info -> ''22'' ->> ''value'', ''-@-'', ''-@-'', ord.ind_cond_info -> ''22'' ->> ''unit'', ''-@-'', ord.ind_cond_info -> ''22'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''22'' ->> ''upd_user_id'' ),
           concat (
             ''031-@-IPスタート-@-'',
             ord.ind_cond_info -> ''30'' ->> ''value'',
             ''-@-'',
             ( CASE ord.ind_cond_info -> ''30'' ->> ''value'' WHEN ''0'' THEN ''手動'' WHEN ''1'' THEN ''自動'' ELSE NULL END ),
             ''-@-'', 
             ''-@-'', ord.ind_cond_info -> ''30'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''30'' ->> ''upd_user_id'' ),
           concat (
             ''032-@-自動ワンショット-@-'',
             ord.ind_cond_info -> ''34'' ->> ''value'',
             ''-@-'',
             ( CASE ord.ind_cond_info -> ''34'' ->> ''value'' WHEN ''1'' THEN ''使用する'' WHEN ''0'' THEN ''使用しない'' ELSE NULL END ),
             ''-@-'', 
             ''-@-'', ord.ind_cond_info -> ''34'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''34'' ->> ''upd_user_id'' ),
           concat (
             ''033-@-IP電源自動切り-@-'',
             ord.ind_cond_info -> ''35'' ->> ''value'',
             ''-@-'',
             ( CASE ord.ind_cond_info -> ''35'' ->> ''value'' WHEN ''1'' THEN ''入り'' WHEN ''0'' THEN ''切り'' ELSE NULL END ),
             ''-@-'', 
             ''-@-'', ord.ind_cond_info -> ''35'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''35'' ->> ''upd_user_id'' ),
           concat ( ''034-@-IP電源自動切り時間-@-'', ord.ind_cond_info -> ''36'' ->> ''value'', ''-@-'', ''-@-'', ''分'', ''-@-'', ord.ind_cond_info -> ''36'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''36'' ->> ''upd_user_id'' ),
           concat (
             ''035-@-IP電源OKモニタ切り-@-'',
             ord.ind_cond_info -> ''37'' ->> ''value'',
             ''-@-'',
             ( CASE ord.ind_cond_info -> ''37'' ->> ''value'' WHEN ''1'' THEN ''入り'' WHEN ''0'' THEN ''切り'' ELSE NULL END ),
             ''-@-'', 
             ''-@-'', ord.ind_cond_info -> ''37'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''37'' ->> ''upd_user_id'' ),
           concat ( ''036-@-IP電源OKモニタ切り時間-@-'', ord.ind_cond_info -> ''38'' ->> ''value'', ''-@-'', ''-@-'', ''分'', ''-@-'', ord.ind_cond_info -> ''38'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''1'' ->> ''upd_user_id'' ),
           concat ( ''037-@-IP速度最大値-@-'', ord.ind_cond_info -> ''33'' ->> ''value'', ''-@-'', ''-@-'', ''mL/h'', ''-@-'', ord.ind_cond_info -> ''33'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''33'' ->> ''upd_user_id'' ),
           concat ( ''038-@-補液速度-@-'', ord.ind_cond_info -> ''24'' ->> ''value'', ''-@-'', ''-@-'', ''L/h'', ''-@-'', ord.ind_cond_info -> ''24'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''24'' ->> ''upd_user_id'' ),
           concat ( ''039-@-1次膜-@-'', meqpr.in_hospital_cd_1, ''-@-'', ord.ind_cond_info -> ''7'' ->> ''value_name_1'', ''-@-'', ''-@-'', ord.ind_cond_info -> ''7'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''7'' ->> ''upd_user_id'' ),
           concat ( ''040-@-2次膜-@-'', meqse.in_hospital_cd_1, ''-@-'', ord.ind_cond_info -> ''8'' ->> ''value_name_1'', ''-@-'', ''-@-'', ord.ind_cond_info -> ''8'' ->> ''ind_user_id'', ''-@-'', ord.ind_cond_info -> ''8'' ->> ''upd_user_id'' ) ],
           ''-@@-'' 
         ),
         ''-@@-'' 
       ) AS cond_row 
     FROM
       ord_main AS ord
       LEFT OUTER JOIN mst_equipment AS meqad ON meqad.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''6'' ->> ''value'', ''999999999999'' )
       LEFT OUTER JOIN mst_equipment AS meqpr ON meqpr.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''7'' ->> ''value'', ''999999999999'' )
       LEFT OUTER JOIN mst_equipment AS meqse ON meqse.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''8'' ->> ''value'', ''999999999999'' )
       LEFT OUTER JOIN mst_medicine AS med15 ON med15.medicine_cd = TO_NUMBER( ord.ind_cond_info -> ''15'' ->> ''value'', ''999999999999'' )
       LEFT OUTER JOIN mst_medicine AS med19 ON med19.medicine_cd = TO_NUMBER( ord.ind_cond_info -> ''19'' ->> ''value'', ''999999999999'' )
       LEFT OUTER JOIN mst_medicine AS med25 ON med25.medicine_cd = TO_NUMBER( ord.ind_cond_info -> ''25'' ->> ''value'', ''999999999999'' )
       LEFT OUTER JOIN mst_treatment AS mtt ON mtt.treatment_cd = ord.ind_treatment_cd
       LEFT OUTER JOIN mst_dialyzer AS mdr ON mdr.dialyzer_cd = TO_NUMBER( ord.ind_cond_info -> ''5'' ->> ''value'', ''999999999999'' )
       LEFT OUTER JOIN mst_va AS mva ON mva.va_cd = TO_NUMBER( ord.ind_cond_info -> ''2'' ->> ''value'', ''999999999999'' )
       LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( ord.ind_cond_info -> ''25'' ->> ''value'', ''999999999999'' )
       LEFT OUTER JOIN mst_medicine_mix AS mmmx ON mmmx.medicine_mix_cd = TO_NUMBER( ord.ind_cond_info -> ''15'' ->> ''value'', ''999999999999'' )
       LEFT OUTER JOIN mst_medicine_mix AS mmmmx ON mmmmx.medicine_mix_cd = TO_NUMBER( ord.ind_cond_info -> ''19'' ->> ''value'', ''999999999999'' )
       LEFT OUTER JOIN pat_unique AS puq ON puq.pat_id = ord.pat_id
       CROSS JOIN LATERAL json_array_elements ( puq.physical_info :: json ) physical 
     WHERE
       physical ->> ''exam_date'' = (
       SELECT MAX
         ( physical2 ->> ''exam_date'' ) 
       FROM
         pat_unique puq2
         CROSS JOIN LATERAL json_array_elements ( puq2.physical_info :: json ) physical2 
       WHERE
         physical2 ->> ''exam_date'' <= ord.treat_date 
         AND COALESCE ( physical2 ->> ''dw'', ''ZERO'' ) <> ''ZERO'' 
         AND puq2.pat_id = ord.pat_id 
       ) 
       AND ord.ord_no = @ordNo
     ) cond_arr 
 WHERE
   (LENGTH ( split_part( cond_arr.cond_row, ''-@-'', 3 ) ) > 0 OR LENGTH ( split_part( cond_arr.cond_row, ''-@-'', 9 ) ) > 0) 
 AND split_part( cond_arr.cond_row, ''-@-'', 1 ) IN (''001'', ''002'', ''003'', ''004'', ''005'', ''006'')', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析予約(連携電文の条件詳細)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
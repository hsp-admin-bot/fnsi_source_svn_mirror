delete from "sys_data_set" where "sql_cd" in (-99991,-99990,-11, -494,-495,-496);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-99991, 'SELECT
  ''DIAJSK-'' || 
  TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDDHH24MISS'') ||
  ''.dat'' AS filename
FROM
  sys_coop_journal AS journal 
WHERE
  journal.ctl_no = @ctlNo', 2, '[]', '0', '{"applications": [4]}', NULL, '日機装 透析実績[送信]ファイル名取得(標準)', '2021-04-20 09:19:08.001', '2021-04-20 09:19:12', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-99990, 'WITH journal AS ( 
  SELECT
    COUNT(1) AS CNT 
  FROM
    sys_coop_journal AS coop1 
  WHERE
    EXISTS ( 
      SELECT
        1 
      FROM
        sys_coop_journal AS coop2 
      WHERE
        coop2.ctl_no = @ctlNo
        AND TO_CHAR(coop2.reg_date, ''YYYYMMDD'') = TO_CHAR(coop1.reg_date, ''YYYYMMDD'') 
        AND coop2.coop_cd = coop1.coop_cd
    )
) 
SELECT ''Dialysis'' || to_char(CURRENT_TIMESTAMP, ''YYYYMMDDHH24MISS'') || TO_CHAR((journal.CNT - 1)%1000, ''FM099'') || ''.txt'' AS filename FROM journal', 2, '[]', '0', '{"applications": [4]}', NULL, '日機装 透析実績[送信]ファイル名取得(拡張)', '2021-04-20 09:19:08.001', '2021-04-20 09:19:12', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-496, 'WITH total_info AS (
  SELECT
    COUNT(1) AS total_cnt
  FROM
    (
      SELECT--投与薬剤情報(通常)
      ''投与薬剤'' AS detail_id,
      mmd.in_hospital_cd_1 AS e01,
      medi ->> ''name'' AS e02,
      medi ->> ''class_name'' AS e03,
      to_char( to_number( medi ->> ''amount'', ''99999.99'' ), ''FM99990.00'' ) AS e04,
      medi ->> ''unit'' AS e05,
      mp.in_hospital_cd_a1 AS e06,
      medi ->> ''procedure_name'' AS e07 
    FROM
      ord_main AS ord
      CROSS JOIN LATERAL json_array_elements ( ord.rst_medi_info :: json ) medi
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' ) 
    WHERE
      medi ->> ''effect_flg'' = ''1'' 
      AND medi ->> ''medicine_type'' = ''1'' 
      AND COALESCE ( mmd.in_hospital_cd_2, ''ZERO'' ) <> ''ZERO'' 
      AND ord.ord_no = @ordNo 
    UNION
      SELECT--投与薬剤情報(調製)
      ''投与薬剤'' AS detail_id,
      mmd.in_hospital_cd_1 AS e1,
      mmd.medicine_name AS e2,
      mmdc.class_name AS e03,
      COALESCE (
        (
        CASE
            mmxd ->> ''solvent'' 
            WHEN ''1'' THEN
              to_char( to_number( mmxd ->> ''amount'', ''99999.99'' ), ''FM99990.00'' ) 
            ELSE
              CASE WHEN mmx2.amount_unit IS NULL OR  mmxd ->> ''amount'' IS NULL OR (mmx2.amount_unit * to_number( mmxd ->> ''amount'', ''99999.99'' )) = 0 
              THEN ''0.00'' 
              ELSE to_char( to_number( medi ->> ''amount'', ''99999.99'' ) / mmx2.amount_unit * to_number( mmxd ->> ''amount'', ''99999.99'' ), ''FM99990.00'' ) 
              END 
          END 
          ),
          ''0.00'' 
        ) AS e04,
        COALESCE ( mmd.unit_second, mmd.unit ) AS e05,
        mp.in_hospital_cd_a1 AS e06,
        medi ->> ''procedure_name'' AS e07 
      FROM
        ord_main AS ord
        CROSS JOIN LATERAL json_array_elements ( ord.rst_medi_info :: json ) medi
        LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
        LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' ),
        mst_medicine_mix AS mmx2
        CROSS JOIN LATERAL json_array_elements ( mmx2.mix_info :: json ) mmxd
        LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( mmxd ->> ''cd'', ''999999999999'' )
        LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd 
      WHERE
        medi ->> ''effect_flg'' = ''1'' 
        AND medi ->> ''medicine_type'' = ''2'' 
        AND ord.ord_no = @ordNo 
    UNION
        SELECT--処置薬剤情報
        ''処置薬剤'' AS detail_id,
        mmd.in_hospital_cd_1 AS e01,
        tmedi ->> ''treat_medicine_name'' AS e02,
        mmdc.class_name AS e03,
        to_char( to_number( tmedi ->> ''amount'', ''99999.99'' ), ''FM99990.00'' ) AS e04,
        tmedi ->> ''unit'' AS e05,
        mp.in_hospital_cd_a1 AS e06,
        tmedi ->> ''procedure_name'' AS e07 
      FROM
        ord_main AS ord
        CROSS JOIN LATERAL json_array_elements ( ord.rst_treatment_info :: json ) tmedi
        LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( tmedi ->> ''treat_medicine_cd'', ''999999999999'' )
        LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd
        LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( tmedi ->> ''procedure_cd'', ''999999999999'' ) 
      WHERE
        ord.ord_no = @ordNo 
      ) all_cost 
  WHERE
    all_cost.e01 IS NOT NULL
)
SELECT (total_cnt/15 + CASE WHEN (total_cnt%15) > 0 THEN 1 ELSE 0 END)  AS total_cnt FROM total_info', 2, '[{}]', '1', '{"applications": [4]}', NULL, '日機装)実績）薬剤繰り返し部の総ページ', '2020-05-22 12:43:46', '2020-05-22 12:43:50.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-495, 'SELECT
  ''薬剤'' AS detail_id,
  all_cost.e01 AS item_cd,
  COALESCE(all_cost.e02, '''') AS name,
  COALESCE(all_cost.e03, '''') AS class_name,
  all_cost.e04 AS amount,
  COALESCE(all_cost.e05, '''') AS unit,
  COALESCE(all_cost.e06, '''') AS item_cd2,
  COALESCE(all_cost.e07, '''') AS procedure_name
FROM
  (
    SELECT--投与薬剤情報(通常)
    ''投与薬剤'' AS detail_id,
    mmd.in_hospital_cd_1 AS e01,
    medi ->> ''name'' AS e02,
    medi ->> ''class_name'' AS e03,
    to_char( to_number( medi ->> ''amount'', ''99999.99'' ), ''FM99990.00'' ) AS e04,
    medi ->> ''unit'' AS e05,
    mp.in_hospital_cd_a1 AS e06,
    medi ->> ''procedure_name'' AS e07 
  FROM
    ord_main AS ord
    CROSS JOIN LATERAL json_array_elements ( ord.rst_medi_info :: json ) medi
    LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
    LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' ) 
  WHERE
    medi ->> ''effect_flg'' = ''1'' 
    AND medi ->> ''medicine_type'' = ''1'' 
    AND COALESCE ( mmd.in_hospital_cd_2, ''ZERO'' ) <> ''ZERO'' 
    AND ord.ord_no = @ordNo 
  UNION
    SELECT--投与薬剤情報(調製)
    ''投与薬剤'' AS detail_id,
    mmd.in_hospital_cd_1 AS e1,
    mmd.medicine_name AS e2,
    mmdc.class_name AS e03,
    COALESCE (
      (
      CASE
          mmxd ->> ''solvent'' 
          WHEN ''1'' THEN
            to_char( to_number( mmxd ->> ''amount'', ''99999.99'' ), ''FM99990.00'' ) 
          ELSE
            CASE WHEN mmx2.amount_unit IS NULL OR  mmxd ->> ''amount'' IS NULL OR (mmx2.amount_unit * to_number( mmxd ->> ''amount'', ''99999.99'' )) = 0 
            THEN ''0.00'' 
            ELSE to_char( to_number( medi ->> ''amount'', ''99999.99'' ) / mmx2.amount_unit * to_number( mmxd ->> ''amount'', ''99999.99'' ), ''FM99990.00'' ) 
            END 
        END 
        ),
        ''0.00'' 
      ) AS e04,
      COALESCE ( mmd.unit_second, mmd.unit ) AS e05,
      mp.in_hospital_cd_a1 AS e06,
      medi ->> ''procedure_name'' AS e07 
    FROM
      ord_main AS ord
      CROSS JOIN LATERAL json_array_elements ( ord.rst_medi_info :: json ) medi
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' ),
      mst_medicine_mix AS mmx2
      CROSS JOIN LATERAL json_array_elements ( mmx2.mix_info :: json ) mmxd
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( mmxd ->> ''cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd 
    WHERE
      medi ->> ''effect_flg'' = ''1'' 
      AND medi ->> ''medicine_type'' = ''2'' 
      AND ord.ord_no = @ordNo 
  UNION
      SELECT--処置薬剤情報
      ''処置薬剤'' AS detail_id,
      mmd.in_hospital_cd_1 AS e01,
      tmedi ->> ''treat_medicine_name'' AS e02,
      mmdc.class_name AS e03,
      to_char( to_number( tmedi ->> ''amount'', ''99999.99'' ), ''FM99990.00'' ) AS e04,
      tmedi ->> ''unit'' AS e05,
      mp.in_hospital_cd_a1 AS e06,
      tmedi ->> ''procedure_name'' AS e07 
    FROM
      ord_main AS ord
      CROSS JOIN LATERAL json_array_elements ( ord.rst_treatment_info :: json ) tmedi
      LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( tmedi ->> ''treat_medicine_cd'', ''999999999999'' )
      LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd
      LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( tmedi ->> ''procedure_cd'', ''999999999999'' ) 
    WHERE
      ord.ord_no = @ordNo 
    ) all_cost 
WHERE
  all_cost.e01 IS NOT NULL
ORDER BY all_cost.e01 ', 2, '[{}]', '1', '{"applications": [4]}', NULL, '日機装)実績）薬剤繰り返し部(※このSQLを修正した場合、「-496」を修正してください。)', '2020-05-22 12:43:46', '2020-05-22 12:43:50.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-494, 'SELECT
  ''医材'' AS detail_id,
  TRIM (all_cost.e01) AS item_cd,
  all_cost.e02 AS name,
  all_cost.e03 AS type_name,
  all_cost.e04 AS class_name,
  COALESCE(all_cost.e05, ''0'') AS amount,
  COALESCE(all_cost.e06, '''') AS unit 
FROM
  (
    SELECT--血液回路情報
    ''血液回路'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''血液回路'' AS e03,
    ''0'' AS e04,
    ''1'' AS e05,
    meq.unit AS e06 
  FROM
    ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''13'' ->> ''value'', ''999999999999'' ) 
  WHERE
    ord.ord_no = @ordNo 
  UNION
    SELECT--A針情報
    ''穿刺針'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''A針'' AS e03,
    ''1'' AS e04,
    ''1'' AS e05,
    meq.unit AS e06 
  FROM
    ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''9'' ->> ''value'', ''999999999999'' ) 
  WHERE
    ord.ord_no = @ordNo 
  UNION
    SELECT--V針情報
    ''穿刺針'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''V針'' AS e03,
    ''2'' AS e04,
    ''1'' AS e05,
    meq.unit AS e06 
  FROM
    ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''10'' ->> ''value'', ''999999999999'' ) 
  WHERE
    ord.ord_no = @ordNo 
  UNION
    SELECT--SN針情報
    ''穿刺針'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''SN針'' AS e03,
    ''3'' AS e04,
    ''1'' AS e05,
    meq.unit AS e06 
  FROM
    ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''11'' ->> ''value'', ''999999999999'' ) 
  WHERE
    ord.ord_no = @ordNo 
  UNION
    SELECT--医材内穿刺針情報
    ''穿刺針'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''穿刺針'' AS e03,
    ''0'' AS e04,
    equip ->> ''amount'' AS e05,
    equip ->> ''unit'' AS e06 
  FROM
    ord_main ord
    CROSS JOIN LATERAL json_array_elements ( ord.rst_equip_info :: json ) equip
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( equip ->> ''cd'', ''999999999999'' ) 
  WHERE
    equip ->> ''class_type'' IN ( ''2'', ''3'' ) 
    AND ord.ord_no = @ordNo 
  UNION
    SELECT--医材情報
    ''医材'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''医材'' AS e03,
    ''0'' AS e04,
    equip ->> ''amount'' AS e05,
    equip ->> ''unit'' AS e6 
  FROM
    ord_main ord
    CROSS JOIN LATERAL json_array_elements ( ord.rst_equip_info :: json ) equip
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( equip ->> ''cd'', ''999999999999'' ) 
  WHERE
    equip ->> ''equip_type'' = ''0'' 
    AND equip ->> ''class_type'' NOT IN ( ''2'', ''3'' ) 
    AND ord.ord_no = @ordNo 
  UNION
    SELECT--1次膜情報
    ''医材'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''1次膜'' AS e03,
    ''0'' AS e04,
    ''1'' AS e05,
    meq.unit AS e06 
  FROM
    ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''7'' ->> ''value'', ''999999999999'' ) 
  WHERE
    ord.ord_no = @ordNo 
  UNION
    SELECT--2次膜情報
    ''医材'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''2次膜'' AS e03,
    ''0'' AS e04,
    ''1'' AS e05,
    meq.unit AS e06 
  FROM
    ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''8'' ->> ''value'', ''999999999999'' ) 
  WHERE
    ord.ord_no = @ordNo 
  UNION
    SELECT--吸着カラム情報
    ''医材'' AS detail_id,
    meq.in_hospital_cd_1 AS e01,
    meq.equipment_name AS e02,
    ''吸着カラム'' AS e03,
    ''0'' AS e04,
    ''1'' AS e05,
    meq.unit AS e06 
  FROM
    ord_main ord
    LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''6'' ->> ''value'', ''999999999999'' ) 
  WHERE
    ord.ord_no = @ordNo 
  ) all_cost 
WHERE
  all_cost.e01 IS NOT NULL 
ORDER BY
  all_cost.e01', 2, '[{}]', '1', '{"applications": [4]}', NULL, '日機装)実績）医材繰り返し部', '2020-05-22 11:43:49.001', '2020-05-22 11:43:53.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-11, 'SELECT
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
  COALESCE(to_char( ord.rst_start_date, ''YYYYMMDDHH24MISS'' ), '''') AS start_date14,
  ord.rst_end_date AS end_date,--透析終了日時
  COALESCE(to_char( ord.rst_end_date, ''YYYYMMDDHH24MISS'' ), '''') AS end_date14,
  ord.rst_return_home_date AS return_home_date,--帰宅時刻
  ord.rst_in_out_class AS in_out_class,--入外コード
  COALESCE(( CASE ord.rst_in_out_class WHEN ''0'' THEN ''外来'' WHEN ''1'' THEN ''入院'' ELSE NULL END ), '''') AS in_out_name,--入外区分
  COALESCE(( CASE ord.rst_in_out_class WHEN ''0'' THEN ''1'' WHEN ''1'' THEN ''2'' ELSE NULL END ), '''') AS in_out_f,--入外区分（F)
  COALESCE(( CASE ord.rst_in_out_class WHEN ''0'' THEN ''1'' WHEN ''1'' THEN ''3'' ELSE NULL END ), '''') AS in_out_s,--入外区分（S)
  COALESCE(RIGHT ( ''00'' || TRUNC( TO_NUMBER( ord.rst_cond_info -> ''1'' ->> ''value'', ''999999'' ) / 60, 0 ), 2 ) || '':'' || RIGHT ( ''00'' || MOD ( TO_NUMBER( ord.rst_cond_info -> ''1'' ->> ''value'', ''999999'' ), 60 ), 2 ), '''') AS treatment_time,
  COALESCE(ord.rst_cond_info -> ''1'' ->> ''value'', '''') AS treatment_time_m,
  COALESCE(ord.rst_cond_info -> ''2'' ->> ''value_name_1'', '''') AS va,--シャント
  COALESCE(mva.in_hospital_cd_1, '''') AS va_cd1,--シャントコード１
  COALESCE(( CASE mva.va_direct WHEN ''0'' THEN ''両方'' WHEN ''1'' THEN ''左'' WHEN ''2'' THEN ''右'' WHEN ''3'' THEN ''なし'' ELSE''不明'' END ), '''') AS va_direct,--シャント方向
  COALESCE(ord.rst_cond_info -> ''3'' ->> ''value'', '''') AS target_weight,
  COALESCE(( CASE WHEN ord.rst_cond_info -> ''3'' ->> ''value'' = ''-1'' THEN ''DWと同じ'' ELSE''目標体重指定'' END ), '''') AS target_mode,--目標体重指定設定
  COALESCE(to_char( to_number( ord.rst_cond_info -> ''4'' ->> ''value'', ''99.99'' ), ''90.99'' ), '''') AS water_removal_amount_limit,
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
  COALESCE(( CASE ord.rst_cond_info -> ''19'' ->> ''medicine_type'' WHEN ''1'' THEN med19.in_hospital_cd_1 WHEN ''2'' THEN mmmmx.in_hospital_cd_1 END ), '''') AS ds_cd1,--補液コード１
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
  COALESCE(TO_NUMBER( ord.rst_cond_info -> ''26'' ->> ''value'', ''999999999999'' ) + TO_NUMBER( ord.rst_cond_info -> ''28'' ->> ''value'', ''999999999999'' ), 0) AS anti_coagulant_total_amount,--抗凝固剤総量
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
  COALESCE(ord.pull_leave_amount, 0) AS pull_leave_amount,--引き残し量
  COALESCE(to_char( to_number( ord.rst_weight_info ->> ''weight_before'', ''999.99'' ), ''990.99'' ), '''') AS weight_before,
  COALESCE(to_char( to_number( ord.rst_weight_info ->> ''weight_after'', ''999.99'' ), ''990.99'' ), '''') AS weight_after,
  COALESCE(to_char( ord.ord_no, ''000000000000'' ), '''') AS ord_no12,
  COALESCE(to_char( ord.up_date, ''YYYYMMDDHH24MISS'' ), '''') AS up_date14,
  COALESCE(ord.ind_schedule_user_info ->> ''ind_user_id'', '''') AS ind_user_id,
  COALESCE(to_char( ord.up_date, ''YYYYMMDD'' ), '''') AS up_date8,
  COALESCE(to_char( ord.up_date, ''HH24MISS'' ), '''') AS up_date6 
  FROM
    ord_main AS ord
    LEFT OUTER JOIN mst_equipment AS meqa ON meqa.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''9'' ->> ''value'', ''999999999999'' )
    LEFT OUTER JOIN mst_equipment AS meqv ON meqv.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''10'' ->> ''value'', ''999999999999'' )
    LEFT OUTER JOIN mst_equipment AS meqsn ON meqsn.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''11'' ->> ''value'', ''999999999999'' )
    LEFT OUTER JOIN mst_equipment AS meqad ON meqad.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''6'' ->> ''value'', ''999999999999'' )
    LEFT OUTER JOIN mst_equipment AS meqpr ON meqpr.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''7'' ->> ''value'', ''999999999999'' )
    LEFT OUTER JOIN mst_equipment AS meqbc ON meqbc.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''13'' ->> ''value'', ''999999999999'' )
    LEFT OUTER JOIN mst_equipment AS meqse ON meqse.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''8'' ->> ''value'', ''999999999999'' )
    LEFT OUTER JOIN mst_medicine AS med15 ON med15.medicine_cd = TO_NUMBER( ord.rst_cond_info -> ''15'' ->> ''value'', ''999999999999'' )
    LEFT OUTER JOIN mst_medicine AS med19 ON med19.medicine_cd = TO_NUMBER( ord.rst_cond_info -> ''19'' ->> ''value'', ''999999999999'' )
    LEFT OUTER JOIN mst_medicine AS med25 ON med25.medicine_cd = TO_NUMBER( ord.rst_cond_info -> ''25'' ->> ''value'', ''999999999999'' )
    LEFT OUTER JOIN mst_treatment AS mtt ON mtt.treatment_cd = ord.rst_treatment_cd
    LEFT OUTER JOIN mst_dialyzer AS mdr ON mdr.dialyzer_cd = TO_NUMBER( ord.rst_cond_info -> ''5'' ->> ''value'', ''999999999999'' )
    LEFT OUTER JOIN mst_va AS mva ON mva.va_cd = TO_NUMBER( ord.rst_cond_info -> ''2'' ->> ''value'', ''999999999999'' )
    LEFT OUTER JOIN mst_bed AS mbd ON mbd.bed_cd = ord.rst_bed_cd
    LEFT OUTER JOIN mst_course AS mcs ON mcs.course_cd = ord.rst_course_cd
    LEFT OUTER JOIN mst_ward AS mwd ON mwd.ward_cd = ord.rst_ward_cd
    LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( ord.rst_cond_info -> ''25'' ->> ''value'', ''999999999999'' )
    LEFT OUTER JOIN mst_medicine_mix AS mmmx ON mmmx.medicine_mix_cd = TO_NUMBER( ord.rst_cond_info -> ''15'' ->> ''value'', ''999999999999'' )
    LEFT OUTER JOIN mst_medicine_mix AS mmmmx ON mmmmx.medicine_mix_cd = TO_NUMBER( ord.rst_cond_info -> ''19'' ->> ''value'', ''999999999999'' )
    LEFT OUTER JOIN mst_kur AS mkr ON mkr.kur_cd = ord.rst_kur_cd 
WHERE
  ord.ord_no = @ordNo', 2, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）実績）透析条件', '2020-03-17 15:42:41', '2020-03-17 15:42:46', NULL);

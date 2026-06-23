DELETE FROM "ntss"."sys_data_set" where sql_cd in (-65, 100, 170);

INSERT INTO ntss.sys_data_set (sql_cd, "sql",db_class,detail,can_repeat,use_application,report_class,memo,reg_date,up_date,pre_sql_info) VALUES
	 (-65, 'WITH staff_cd_info AS(
  --指示者
  --条件指示
  SELECT
    1 AS order_no
    , COALESCE(info ->> ''ind_user_id'', '''') AS staff_cd 
  FROM
    (SELECT
      ord.rst_cond_info -> jsonb_object_keys(ord.rst_cond_info) AS info 
    FROM
      ord_main AS ord 
    WHERE
      ord.ord_no = @ordNo AND 
      ord.facility_cd = @facilityCd AND 
      ord.is_del = ''0'' 
    LIMIT 1 ) AS T
  UNION 
  --投薬指示
  SELECT
    2 AS order_no
    , COALESCE(info ->> ''ind_user_id'', '''') AS staff_cd 
  FROM
    ord_main AS ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) info 
  WHERE
    ord.ord_no = @ordNo AND 
    ord.facility_cd = @facilityCd AND 
    ord.is_del = ''0'' 
  UNION 
  --医材指示
  SELECT
    3 AS order_no
    , COALESCE(info ->> ''ind_user_id'', '''') AS staff_cd
  FROM
    ord_main AS ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_equip_info ::json) info 
  WHERE
    ord.ord_no = @ordNo AND 
    ord.facility_cd = @facilityCd AND 
    ord.is_del = ''0'' 
  UNION 
  --指示簿指示
  SELECT
    4 AS order_no
    , COALESCE(info ->> ''ind_user_id'', '''') AS staff_cd
  FROM
    ord_main AS ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_ind_comment_info ::json) info 
  WHERE
    ord.ord_no = @ordNo AND 
    ord.facility_cd = @facilityCd AND 
    ord.is_del = ''0'' 
  ORDER BY order_no ASC LIMIT 1 
)
, rst_vital_info_before AS(
  --前血圧
  SELECT
    null AS bp_max, 
    null AS bp_min, 
    null AS bp_ave, 
    null AS pulse, 
    null AS occur_date 
  FROM 
    ord_main ord
  WHERE 
    ord.ord_no = @ordNo AND
    ord.facility_cd = @facilityCd AND 
    ord.is_del = ''0'' 
)
, rst_vital_info_after AS(
  --後血圧
  SELECT
    null AS bp_max, 
    null AS bp_min, 
    null AS bp_ave, 
    null AS pulse, 
    null AS occur_date, 
    null AS temperature 
  FROM 
    ord_main ord
  WHERE 
    ord.ord_no = @ordNo AND
    ord.facility_cd = @facilityCd AND 
    ord.is_del = ''0'' 
)
, ord_main_info AS (
  SELECT 
    ord.pat_id AS pat_id, 
    ord.treat_date AS treat_date, 
    ord.ind_treat_start_time AS ind_treat_start_time
  FROM 
    ord_main ord
  WHERE
    ord.ord_no = @ordNo AND 
    ord.facility_cd = @facilityCd AND 
    ord.is_del = ''0'' 
)
--前回後体重
, pre_weight_after_info AS (
  SELECT
    rst_weight_info ->> ''weight_after'' AS weight_after 
  FROM 
    ord_main
  WHERE 
    pat_id = (SELECT pat_id FROM ord_main_info) AND 
    rst_dialysis_state >= ''5'' AND 
    (cast(treat_date as date) ||'' ''|| cast(ind_treat_start_time as time))::TIMESTAMP < (cast((SELECT treat_date FROM ord_main_info) as date) ||'' ''|| cast((SELECT ind_treat_start_time FROM ord_main_info) as time))::TIMESTAMP AND 
    facility_cd = @facilityCd AND 
    is_del = ''0'' 
    ORDER BY (cast(treat_date as date) ||'' ''|| cast(ind_treat_start_time as time))::TIMESTAMP 
    LIMIT 1
)
, equipment_info AS (
  --医療材料
  SELECT
    COALESCE(meq.equipment_name, '''') || ''　'' || COALESCE((info ->> ''amount''), ''0'') || COALESCE((info ->> ''unit''), '''') AS equipment
  FROM 
    ord_main ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_equip_info ::json) info
  LEFT OUTER JOIN
    mst_equipment meq
  ON
    meq.equipment_cd = TO_NUMBER(info->>''cd'',''999999999999'')
  WHERE 
    ord.ord_no = @ordNo AND 
    ord.facility_cd = @facilityCd AND 
    ord.is_del = ''0'' 
)
, comment_info AS (
  --指示簿指示
  SELECT
    COALESCE((info ->> ''content''), '''') AS comment
  FROM 
    ord_main ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_ind_comment_info ::json) info
  WHERE 
    ord.ord_no = @ordNo AND 
    ord.facility_cd = @facilityCd AND 
    ord.is_del = ''0'' 
)
, medi_info AS (
  --投与薬剤
  SELECT
    COALESCE((CASE info ->> ''medicine_type'' WHEN ''2'' THEN mmx.medicine_mix_name ELSE mmd.medicine_name END), '''') || ''　'' || 
    COALESCE(info ->> ''amount'', ''0'') || COALESCE(info ->> ''unit'', '''') || ''　'' || COALESCE(mp.pricedure_name, '''') || ''　'' || 
    COALESCE(info ->> ''ind_user_first_name'', '''') || '' '' || COALESCE(info ->> ''ind_user_last_name'', '''') medi
  FROM 
    ord_main ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) info
  LEFT OUTER JOIN
    mst_medicine_mix mmx
  ON
    mmx.medicine_mix_cd = TO_NUMBER(info ->> ''cd'',''999999999999'')
  LEFT OUTER JOIN
    mst_medicine mmd
  ON
    mmd.medicine_cd = TO_NUMBER(info ->> ''cd'',''999999999999'')
  LEFT OUTER JOIN
    mst_procedure mp
  ON
    mp.procedure_cd = TO_NUMBER(info ->> ''procedure_cd'',''999999999999'')
  WHERE 
    ord.ord_no = @ordNo AND 
    ord.facility_cd = @facilityCd AND 
    ord.is_del = ''0'' 
)
, complaint_info AS (
  --愁訴情報
  SELECT
    TO_CHAR((info ->> ''occur_date'') :: DATE, ''YYYY/MM/DD HH24:MI'') || ''　'' || COALESCE((info ->> ''complaint''), '''') AS complaint
  FROM 
    ord_main ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_complaint_info ::json) info
  WHERE 
    ord.ord_no = @ordNo AND 
    ord.facility_cd = @facilityCd AND 
    ord.is_del = ''0'' 
)
, treatment_info AS (
  --愁訴処置情報
  SELECT
    COALESCE((info ->> ''treat_name''), '''') || ''　'' || COALESCE((info ->> ''treat_medicine_name''), '''') || ''　'' || 
    COALESCE((info ->> ''amount''), '''') || COALESCE((info ->> ''unit''), '''') || ''　'' || 
    COALESCE((info ->> ''procedure_name''), '''') AS treatment 
  FROM 
    ord_main ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) info
  WHERE 
    ord.ord_no = @ordNo AND 
    ord.facility_cd = @facilityCd AND 
    ord.is_del = ''0'' 
)
, treat_staff_info AS (
  --愁訴処置者情報
  SELECT
    COALESCE((info ->> ''treat_staff_name''), '''') AS treat_staff_name
  FROM 
    ord_main ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_treat_staff_info ::json) info
  WHERE 
    ord.ord_no = @ordNo AND 
    ord.facility_cd = @facilityCd AND 
    ord.is_del = ''0'' 
)
, rounds_info AS (
  --観察記録
  SELECT
    TO_CHAR((ord.rst_rounds_info ->> ''updated_at'') :: DATE, ''YYYY/MM/DD HH24:MI'') || ''　'' || 
    ''SOAP　S：'' || (por.obs_rec_info ->> ''detail1'') || ''　O：'' || (por.obs_rec_info ->> ''detail2'') || 
    ''　A：'' || (por.obs_rec_info ->> ''detail3'') || ''　P：'' || (por.obs_rec_info ->> ''detail4'') ||
    (ord.rst_rounds_info ->> ''reg_user_first_name'') || '' '' || (ord.rst_rounds_info ->> ''reg_user_last_name'') AS rounds
  FROM 
    ord_main ord
  LEFT OUTER JOIN
    pat_obs_rec por
  ON
    ord.pat_id = por.pat_id
  WHERE 
    ord.ord_no = @ordNo AND 
    ord.facility_cd = @facilityCd AND 
    ord.is_del = ''0'' 
  ORDER BY
    ord.rst_rounds_info ->> ''reg_date_time'' ASC
)
SELECT
  Tmp.values AS values
FROM
(
SELECT 
  split_part(cond_arr.cond_row,''-@-'',1) :: INTEGER AS order_no, 
  split_part(cond_arr.cond_row,''-@-'',2) || 
  split_part(cond_arr.cond_row,''-@-'',3) || 
  CASE WHEN split_part(cond_arr.cond_row,''-@-'',3) IS NULL OR split_part(cond_arr.cond_row,''-@-'',3) = ''''
    THEN ''''
    ELSE  split_part(cond_arr.cond_row,''-@-'',4)
  END || E''\n'' AS values
FROM 
  (SELECT
    regexp_split_to_table(array_to_string(array[
    concat(''1-@-表示用患者ID:-@-'', (@hospPatId) :: TEXT), 
    concat(''2-@-患者名:-@-'', (@patName) :: TEXT), 
    concat(''3-@-指示者:-@-'', (SELECT staff_cd FROM staff_cd_info)),
    concat(''4-@-透析日:-@-'', 
    COALESCE(SUBSTRING(ord.treat_date, 1, 4) || ''年'' ||
       SUBSTRING(ord.treat_date, 5, 2) || ''月'' || 
       SUBSTRING(ord.treat_date, 7, 2) || ''日'', '''') || 
      ''('' ||
      CASE extract(DOW FROM cast(ord.treat_date as TIMESTAMP))
        WHEN 0 THEN ''日曜日''
        WHEN 1 THEN ''月曜日''
        WHEN 2 THEN ''火曜日''
        WHEN 3 THEN ''水曜日''
        WHEN 4 THEN ''木曜日''
        WHEN 5 THEN ''金曜日''
        WHEN 6 THEN ''土曜日''
        ELSE '''' 
      END || '')''
    ),
    concat(''5-@-予定透析時間:-@-'', ord.rst_cond_info -> ''1'' ->> ''value'', ''-@-分''),
    concat(''6-@-予定透析時間:-@-'', RIGHT(''00'' || TRUNC(TO_NUMBER(ord.rst_cond_info -> ''1'' ->> ''value'', ''9999'')/60, 0), 2) || '':'' ||
          RIGHT(''00'' || MOD(TO_NUMBER(ord.rst_cond_info -> ''1'' ->> ''value'', ''9999''), 60), 2)),
    concat(''7-@-入外区分:-@-'', CASE ord.rst_in_out_class WHEN ''0'' THEN ''1'' WHEN ''1'' THEN ''3'' ELSE ''1'' END),
    concat(''8-@-透析回数:-@-'', ord.rst_dialysis_cnt, ''-@-回''),
    concat(''9-@-透析時間:-@-'', RIGHT(''00'' || TRUNC(COALESCE(ord.rst_running_time, ''0'')/60, 0), 2) || '':'' ||
          RIGHT(''00'' || MOD(COALESCE(ord.rst_running_time, ''0''), 60), 2)),
    concat(''10-@-透析開始時刻:-@-'', TO_CHAR(ord.rst_start_date, ''YYYY/MM/DD HH24:MI'')),
    concat(''11-@-透析終了時刻:-@-'', TO_CHAR(ord.rst_end_date, ''YYYY/MM/DD HH24:MI'')),
    concat(''12-@-クール:-@-'', COALESCE(ord.rst_kur_name, '''')),
    concat(''13-@-ベッド:-@-'', COALESCE(ord.rst_bed_name, '''')),
    concat(''14-@-病棟名:-@-'', COALESCE(ord.rst_ward_name, '''')),
    concat(''15-@-診療科:-@-'', COALESCE(ord.rst_course_name, '''')),
    concat(''16-@-担当者１:-@-'', COALESCE(ord.rst_charge_user_info ->> ''user_last_name_1'', '''') || ''　'' || COALESCE(ord.rst_charge_user_info ->> ''user_first_name_1'', '''')),
    concat(''17-@-担当者２:-@-'', COALESCE(ord.rst_charge_user_info ->> ''user_last_name_2'', '''') || ''　'' || COALESCE(ord.rst_charge_user_info ->> ''user_first_name_2'', '''')),
    concat(''18-@-穿刺者１:-@-'', COALESCE(ord.rst_puncture_user_info ->> ''user_last_name_1'', '''') || ''　'' || COALESCE(ord.rst_puncture_user_info ->> ''user_first_name_1'', '''')),
    concat(''19-@-穿刺時刻１:-@-'', TO_CHAR((ord.rst_puncture_user_info ->> ''date_1'') :: DATE, ''YYYY/MM/DD HH24:MI'')),
    concat(''20-@-穿刺者２:-@-'', COALESCE(ord.rst_puncture_user_info ->> ''user_last_name_2'', '''') || ''　'' || COALESCE(ord.rst_puncture_user_info ->> ''user_first_name_2'', '''')),
    concat(''21-@-穿刺時刻２:-@-'', TO_CHAR((ord.rst_puncture_user_info ->> ''date_2'') :: DATE, ''YYYY/MM/DD HH24:MI'')),
    concat(''22-@-回収者１:-@-'', COALESCE(ord.rst_return_user_info ->> ''user_last_name_1'', '''') || ''　'' || COALESCE(ord.rst_return_user_info ->> ''user_first_name_1'', '''')),
    concat(''23-@-回収時刻１:-@-'', TO_CHAR((ord.rst_return_user_info ->> ''date_1'') :: DATE, ''YYYY/MM/DD HH24:MI'')),
    concat(''24-@-回収者２:-@-'', COALESCE(ord.rst_return_user_info ->> ''user_last_name_2'', '''') || ''　'' || COALESCE(ord.rst_return_user_info ->> ''user_first_name_2'', '''')),
    concat(''25-@-回収時刻２:-@-'', TO_CHAR((ord.rst_return_user_info ->> ''date_2'') :: DATE, ''YYYY/MM/DD HH24:MI'')),
    concat(''26-@-前回後体重:-@-'', (SELECT weight_after FROM pre_weight_after_info), ''-@-kg''),
    concat(''27-@-透析前体重:-@-'', ord.rst_weight_info ->> ''weight_before'', ''-@-kg''),
    concat(''28-@-透析前体重測定日時:-@-'', TO_CHAR((ord.rst_weight_info ->> ''weight_before_date'') :: DATE, ''YYYY/MM/DD HH24:MI'')),
    concat(''29-@-ＣＴＲ:-@-'', ord.rst_weight_info ->> ''ctr'', ''-@-%''),
    concat(''30-@-ＣＴＲ測定時体重:-@-'', ord.rst_weight_info ->> ''ctr_weight'', ''-@-kg''),
    concat(''31-@-ＣＴＲ測定日:-@-'', TO_CHAR((ord.rst_weight_info ->> ''ctr_measure_date'') :: DATE, ''YYYY/MM/DD'')),
    concat(''32-@-目標体重:-@-'', ord.rst_cond_info -> ''3'' ->> ''value'', ''-@-kg''),
    concat(''33-@-目標除水量:-@-'', ord.rst_weight_info ->> ''water_removal_target'', ''-@-L''),
    concat(''34-@-除水実績:-@-'', ord.rst_weight_info ->> ''water_removal_rst'', ''-@-L''),
    concat(''35-@-Ｋｔ／Ｖ測定値:-@-'', COALESCE(ord.rst_weight_info ->> ''kt_v_measure'', '''')),
    concat(''36-@-ＵＲＲ:-@-'', ord.rst_weight_info ->> ''urr'', ''-@-%''),
    concat(''37-@-再循環率:-@-'', ord.rst_weight_info ->> ''recrcl_rt'', ''-@-%''),
    concat(''38-@-透析後体重:-@-'', ord.rst_weight_info ->> ''weight_after'', ''-@-kg''),
    concat(''39-@-透析後体重測定日時:-@-'', TO_CHAR((ord.rst_weight_info ->> ''weight_after_date'') :: DATE, ''YYYY/MM/DD'')),
    concat(''40-@-減少量:-@-'', TO_NUMBER(ord.rst_weight_info ->> ''weight_before'', ''999999999'') - TO_NUMBER(ord.rst_weight_info ->> ''weight_after'', ''999999999''), ''-@-kg''),
    concat(''41-@-前血圧(最高):-@-'', COALESCE((SELECT bp_max FROM rst_vital_info_before), '''')),
    concat(''42-@-前血圧(最低):-@-'', COALESCE((SELECT bp_min FROM rst_vital_info_before), '''')),
    concat(''43-@-前血圧(平均):-@-'', COALESCE((SELECT bp_min FROM rst_vital_info_before), '''')),
    concat(''44-@-前脈拍:-@-'', COALESCE((SELECT pulse FROM rst_vital_info_before), '''')),
    concat(''45-@-前血圧測定日時:-@-'', TO_CHAR((SELECT occur_date FROM rst_vital_info_before) :: DATE, ''YYYY/MM/DD HH24:MI'')),
    concat(''46-@-後血圧(最高):-@-'', COALESCE((SELECT bp_max FROM rst_vital_info_after), '''')),
    concat(''47-@-後血圧(最低):-@-'', COALESCE((SELECT bp_min FROM rst_vital_info_after), '''')),
    concat(''48-@-後血圧(平均):-@-'', COALESCE((SELECT bp_ave FROM rst_vital_info_after), '''')),
    concat(''49-@-後脈拍:-@-'', COALESCE((SELECT pulse FROM rst_vital_info_after), '''')),
    concat(''50-@-後血圧測定日時:-@-'', TO_CHAR((SELECT occur_date FROM rst_vital_info_after) :: DATE, ''YYYY/MM/DD HH24:MI'')),
    concat(''51-@-体温:-@-'', (SELECT temperature FROM rst_vital_info_after), ''-@-℃''),
    concat(''52-@-透析条件：-@-'', (SELECT temperature FROM rst_vital_info_after), ''-@-℃''),
    concat(''53-@-透析開始時刻:-@-'', SUBSTRING(ord.ind_treat_start_time,1,2) || '':'' || SUBSTRING(ord.ind_treat_start_time,3,2)), 
    concat(''54-@-透析予定時間:-@-'', ord.rst_cond_info -> ''1'' ->> ''value'', ''-@-分''), 
    concat(''55-@-透析予定時間:-@-'', RIGHT(''00'' || TRUNC(TO_NUMBER(ord.rst_cond_info -> ''1'' ->> ''value'', ''9999'')/60, 0), 2) || '':'' ||
           RIGHT(''00'' || MOD(TO_NUMBER(ord.rst_cond_info -> ''1'' ->> ''value'', ''9999''), 60), 2), ''-@-mL/min''),
    concat(''56-@-VA:-@-'', COALESCE(mva.va_name, '''')),
    concat(''57-@-目標体重:-@-'', ord.rst_cond_info -> ''3'' ->> ''value'', ''-@-kg''),
    concat(''58-@-治療方法:-@-'', COALESCE(mtt.treatment_name , '''')),
    concat(''59-@-除水量制限:-@-'', ord.rst_cond_info -> ''4'' ->> ''value'', ''-@-L''),
    concat(''60-@-ダイアライザ:-@-'', COALESCE(mdz.model_number, '''')),
    concat(''61-@-吸着カラム:-@-'', COALESCE(meq.equipment_name, '''')),
    concat(''62-@-血流量:-@-'', ord.rst_cond_info -> ''14'' ->> ''value'', ''-@-mL/min''),
    concat(''63-@-抗凝固剤:-@-'', COALESCE(mmd25.medicine_name, '''')),
    concat(''64-@-抗凝固剤ワンショット量:-@-'', COALESCE((CASE ord.rst_cond_info -> ''26'' ->> ''medicine_type'' WHEN ''2'' THEN mmx26.unit ELSE mmd26.unit END), '''')),
    concat(''65-@-抗凝固剤持続速度:-@-'', COALESCE((CASE ord.rst_cond_info -> ''27'' ->> ''medicine_type'' WHEN ''2'' THEN mmx27.unit ELSE mmd27.unit END), ''''), ''-@-/h''),
    concat(''66-@-抗凝固剤持続総量:-@-'', COALESCE((CASE ord.rst_cond_info -> ''28'' ->> ''medicine_type'' WHEN ''2'' THEN mmx28.unit ELSE mmd28.unit END), '''')),
    concat(''67-@-IP使用選択:-@-'', CASE ord.rst_cond_info -> ''29'' ->> ''value'' WHEN ''0'' THEN ''使用しない'' WHEN ''1'' THEN ''使用する'' ELSE '''' END),
    concat(''68-@-IPワンショット量:-@-'', ord.rst_cond_info -> ''31'' ->> ''value'', ''-@-mL''),
    concat(''69-@-IP速度:-@-'', ord.rst_cond_info -> ''32'' ->> ''value'', ''-@-mL/h''),
    concat(''70-@-透析液:-@-'', COALESCE(mmd15.medicine_name, '''')),
    concat(''71-@-透析液流量:-@-'', ord.rst_cond_info -> ''16'' ->> ''value'', ''-@-mL/min''),
    concat(''72-@-透析液量:-@-'', COALESCE((CASE ord.rst_cond_info -> ''17'' ->> ''medicine_type'' WHEN ''2'' THEN mmx17.unit ELSE mmd17.unit END), '''')),
    concat(''73-@-透析液温度:-@-'', ord.rst_cond_info -> ''18'' ->> ''value'', ''-@-℃''),
    concat(''74-@-補液:-@-'', COALESCE(mmd19.medicine_name, '''')),
    concat(''75-@-補液量:-@-'', ord.rst_cond_info -> ''20'' ->> ''value'', ''-@-L''),
    concat(''76-@-補液選択:-@-'', CASE ord.rst_cond_info -> ''21'' ->> ''value'' WHEN ''0'' THEN ''後補液'' WHEN ''1'' THEN ''前補液'' ELSE '''' END),
    concat(''77-@-補液温度:-@-'', ord.rst_cond_info -> ''23'' ->> ''value'', ''-@-℃''),
    concat(''78-@-シングルニードル使用:-@-'', CASE ord.rst_cond_info -> ''12'' ->> ''value'' WHEN ''0'' THEN ''無し'' WHEN ''1'' THEN ''有り'' ELSE '''' END),
    concat(''79-@-補液使用数:-@-'', COALESCE((CASE ord.rst_cond_info -> ''22'' ->> ''medicine_type'' WHEN ''2'' THEN mmx22.unit ELSE mmd22.unit END), '''')),
    concat(''80-@-IPスタート:-@-'', CASE ord.rst_cond_info -> ''30'' ->> ''value'' WHEN ''0'' THEN ''手動'' WHEN ''1'' THEN ''自動'' ELSE '''' END),
    concat(''81-@-自動ワンショット:-@-'', CASE ord.rst_cond_info -> ''34'' ->> ''value'' WHEN ''0'' THEN ''使用しない'' WHEN ''1'' THEN ''使用する'' ELSE '''' END),
    concat(''82-@-IP電源自動切り:-@-'', CASE ord.rst_cond_info -> ''35'' ->> ''value'' WHEN ''0'' THEN ''切'' WHEN ''1'' THEN ''入'' ELSE '''' END),
    concat(''83-@-IP電源自動切り時間:-@-'', COALESCE(ord.rst_cond_info -> ''36'' ->> ''value'', '''')),
    concat(''84-@-IP電源OKモニタ切り:-@-'', CASE ord.rst_cond_info -> ''37'' ->> ''value'' WHEN ''0'' THEN ''切'' WHEN ''1'' THEN ''入'' ELSE '''' END),
    concat(''85-@-IP電源OKモニタ切り時間:-@-'', COALESCE(ord.rst_cond_info -> ''38'' ->> ''value'', '''')),
    concat(''86-@-IP速度最大値:-@-'', ord.rst_cond_info -> ''33'' ->> ''value'', ''-@-mL/h''),
    concat(''87-@-IP補液速度:-@-'', ord.rst_cond_info -> ''24'' ->> ''value'', ''-@-L/h''),
    concat(''88-@-1次膜:-@-'', COALESCE(meq1.equipment_name, '''')),
    concat(''89-@-2次膜:-@-'', COALESCE(meq2.equipment_name, ''''))
    ],''-@@-''),''-@@-'') AS cond_row
  FROM
    ord_main ord 
  LEFT OUTER JOIN
    mst_va mva
  ON
    mva.va_cd = TO_NUMBER(ord.rst_cond_info -> ''2'' ->> ''value'', ''999999999999'')
  LEFT OUTER JOIN
    mst_dialyzer mdz
  ON
    mdz.dialyzer_cd = TO_NUMBER(ord.rst_cond_info -> ''5'' ->> ''value'', ''999999999999'')
  LEFT OUTER JOIN
    mst_equipment meq
  ON
    meq.equipment_cd = TO_NUMBER(ord.rst_cond_info -> ''6'' ->> ''value'', ''999999999999'')
  LEFT OUTER JOIN
    mst_equipment meq1
  ON
    meq1.equipment_cd = TO_NUMBER(ord.rst_cond_info -> ''7'' ->> ''value'', ''999999999999'')
  LEFT OUTER JOIN
    mst_equipment meq2
  ON
    meq2.equipment_cd = TO_NUMBER(ord.rst_cond_info -> ''8'' ->> ''value'', ''999999999999'')
  LEFT OUTER JOIN
    mst_medicine mmd15
  ON
    mmd15.medicine_cd = TO_NUMBER(ord.rst_cond_info -> ''15'' ->> ''value'', ''999999999999'')
  LEFT OUTER JOIN
    mst_medicine mmd19
  ON
    mmd19.medicine_cd = TO_NUMBER(ord.rst_cond_info -> ''19'' ->> ''value'', ''999999999999'')
  LEFT OUTER JOIN
    mst_medicine mmd17
  ON
    mmd17.medicine_cd = TO_NUMBER(ord.rst_cond_info -> ''17'' ->> ''value'', ''999999999999'')
  LEFT OUTER JOIN
    mst_medicine_mix mmx17
  ON
    mmx17.medicine_mix_cd = TO_NUMBER(ord.rst_cond_info -> ''17'' ->> ''value'', ''999999999999'')
  LEFT OUTER JOIN
    mst_medicine mmd22
  ON
    mmd22.medicine_cd = TO_NUMBER(ord.rst_cond_info -> ''22'' ->> ''value'', ''999999999999'')
  LEFT OUTER JOIN
    mst_medicine_mix mmx22
  ON
    mmx22.medicine_mix_cd = TO_NUMBER(ord.rst_cond_info -> ''22'' ->> ''value'', ''999999999999'')
  LEFT OUTER JOIN
    mst_medicine mmd25
  ON
    mmd25.medicine_cd = TO_NUMBER(ord.rst_cond_info -> ''25'' ->> ''value'', ''999999999999'')
  LEFT OUTER JOIN
    mst_medicine mmd26
  ON
    mmd26.medicine_cd = TO_NUMBER(ord.rst_cond_info -> ''26'' ->> ''value'', ''999999999999'')
  LEFT OUTER JOIN
    mst_medicine_mix mmx26
  ON
    mmx26.medicine_mix_cd = TO_NUMBER(ord.rst_cond_info -> ''26'' ->> ''value'', ''999999999999'')
  LEFT OUTER JOIN
    mst_medicine mmd27
  ON
    mmd27.medicine_cd = TO_NUMBER(ord.rst_cond_info -> ''27'' ->> ''value'', ''999999999999'')
  LEFT OUTER JOIN
    mst_medicine_mix mmx27
  ON
    mmx27.medicine_mix_cd = TO_NUMBER(ord.rst_cond_info -> ''27'' ->> ''value'', ''999999999999'')
  LEFT OUTER JOIN
    mst_medicine mmd28
  ON
    mmd28.medicine_cd = TO_NUMBER(ord.rst_cond_info -> ''28'' ->> ''value'', ''999999999999'')
  LEFT OUTER JOIN
    mst_medicine_mix mmx28
  ON
    mmx28.medicine_mix_cd = TO_NUMBER(ord.rst_cond_info -> ''28'' ->> ''value'', ''999999999999'')
  LEFT OUTER JOIN
    mst_treatment mtt
  ON
    mtt.treatment_cd = ord.ind_treatment_cd
  WHERE
    ord.ord_no = @ordNo AND 
    ord.facility_cd = @facilityCd AND 
    ord.is_del = ''0'' 
) cond_arr
--医療材料
UNION 
(SELECT 
  99 AS order_no, 
  ''医療材料：'' || E''\n'' AS values)
UNION
(SELECT 
  100 AS order_no, 
  equipment || E''\n'' AS values
FROM 
  equipment_info)
--指示簿指示
UNION
(SELECT 
  101 AS order_no, 
  ''指示簿指示：'' || E''\n'' AS values)
UNION
(SELECT 
  102 AS order_no, 
  comment || E''\n'' AS values
FROM 
  comment_info)
--投与薬剤
UNION
(SELECT 
  103 AS order_no, 
  ''投与薬剤：'' || E''\n'' AS values)
UNION
(SELECT 
  104 AS order_no, 
  medi || E''\n'' AS values
FROM 
  medi_info)
--愁訴処置
UNION
(SELECT 
  105 AS order_no, 
  ''愁訴処置：'' || E''\n'' AS values) 
UNION
SELECT 
  106 AS order_no,
  (SELECT complaint FROM complaint_info) || ''　'' || 
  (SELECT treatment FROM treatment_info) || ''　'' || 
  (SELECT treat_staff_name FROM treat_staff_info) || E''\n'' AS values 
--観察記録
UNION
(SELECT 
  107 AS order_no,
  ''観察記録：'' || E''\n'' AS values)
UNION
(SELECT 
  108 AS order_no, 
  rounds || E''\n'' AS values 
FROM 
  rounds_info)
ORDER BY order_no ASC
) Tmp',2,'[]'::jsonb,'0','{"applications": [4]}'::jsonb,NULL,'SSI）カルテ記載連携：内容取得','2023-05-18 19:22:02.414',CURRENT_TIMESTAMP,'[{"sql_cd": -1, "field_name": "hosp_pat_id", "replace_var": "@hospPatId"}, {"sql_cd": -1, "field_name": "pat_name", "replace_var": "@patName"}]'::jsonb);

INSERT INTO ntss.sys_data_set (sql_cd, "sql",db_class,detail,can_repeat,use_application,report_class,memo,reg_date,up_date,pre_sql_info) VALUES
	 (100, 'WITH DATA AS (



with latest_otc as(
  select * from ord_treat_condition where (ord_no, up_date) in (select ord_no, max(up_date) from ord_treat_condition where ord_no = @ordNo and is_del = ''0'' and is_disp = ''1'' group by ord_no)
)
, dialyzer_record as(
  select gas_purge_time, substituent_wash_amt, membrane_wash
  from
    ord_main
    inner join (select * from mst_dialyzer where is_del = ''0'' and is_disp = ''1'') as mst_dialyzer
      on (ord_main.rst_cond_info#>>''{5, value}'')::text = mst_dialyzer.dialyzer_cd::text
  where
    ord_no = @ordNo and ord_main.is_del = ''0''
    and ord_main.rst_dialysis_state <>''0''
)

select
  null as ope_dev_a_0179 -- 血流量設定最大値
  ,null as ope_dev_a_0181 -- 除水速度制限
  ,null as ope_dev_a_0038 -- 動脈側気泡検出器
  ,null as ope_dev_a_0021 -- 除水計算時間
  ,null as ope_dev_a_0022 -- 除水計算優先項目
  ,null as ope_dev_a_0039 -- 除水開始遅延時間
  ,null as ope_dev_a_0182 -- 透析液温度操作範囲上限
  ,null as ope_dev_a_0183 -- 透析液温度操作範囲下限
  ,null as ope_dev_a_0024 -- シングルニードル切替圧上限
  ,null as ope_dev_a_0025 -- シングルニードル切替圧下限
  ,null as ope_dev_a_0241 -- TMPゼロ補正
  ,null as ope_dev_a_0168 -- HD補正警報上限値
  ,null as ope_dev_a_0169 -- HD補正警報下限値
  ,null as ope_dev_a_0171 -- ECUM補正警報上限値
  ,null as ope_dev_a_0172 -- ECUM補正警報下限値
  ,null as ope_dev_a_0174 -- HDF補正警報上限値
  ,null as ope_dev_a_0175 -- HDF補正警報下限値
  ,null as ope_dev_a_0177 -- HF補正警報上限値
  ,null as ope_dev_a_0178 -- HF補正警報下限値
  ,null as ope_dev_b_0037 -- HD+補液補正警報上限値
  ,null as ope_dev_b_0038 -- HD+補液補正警報下限値
  ,null as ope_dev_a_0391 -- OHDF補正警報上限値
  ,null as ope_dev_a_0392 -- OHDF補正警報下限値
  ,null as ope_dev_a_0394 -- OHF補正警報上限値
  ,null as ope_dev_a_0395 -- OHF補正警報下限値
  ,null as ope_dev_a_0383 -- 補液量制限
  ,null as ope_dev_a_0389 -- 補液計算優先項目
  ,null as ope_dev_a_0379 -- 補液比率（前補液）
  ,null as ope_dev_b_0039 -- 補液比率（後補液）
  ,null as ope_dev_a_0398 -- 補液開始遅延時間
  ,null as ope_dev_a_0369 -- DP=Qd+Qs(補液速度加算)
  ,null as ope_dev_a_0090 -- 濾過率（前補液）
  ,null as ope_dev_b_0040 -- 濾過率（後補液）
  ,null as ope_dev_a_0091 -- ヘマトクリット（Ht）
  ,null as ope_dev_a_0092 -- 総タンパク（TP）
  ,null as ope_dev_a_0336 -- 緊急補液速度
  ,null as ope_dev_a_0337 -- 緊急補液量
  ,null as ope_dev_a_0185 -- HDF速度操作範囲上限前補液
  ,null as ope_dev_b_0031 -- HDF速度操作範囲上限後補液
  ,null as ope_dev_a_0186 -- HF速度操作範囲上限前補液
  ,null as ope_dev_b_0032 -- HF速度操作範囲上限後補液
  ,null as ope_dev_b_0030 -- HD+補液速度操作範囲上限前補液
  ,null as ope_dev_b_0033 -- HD+補液速度操作範囲上限後補液
  ,null as ope_dev_a_0396 -- OHDF速度操作範囲上限前補液
  ,null as ope_dev_b_0034 -- OHDF速度操作範囲上限後補液
  ,null as ope_dev_a_0397 -- OHF速度操作範囲上限前補液
  ,null as ope_dev_b_0035 -- OHF速度操作範囲上限後補液
  ,null as ope_dev_a_0384 -- AFBF補液比率使用選択
  ,null as ope_dev_a_0385 -- AFBF補液比率
  ,null as ope_dev_a_0386 -- AFBF速度操作範囲上限
  ,null as ope_dev_a_0387 -- AFBF速度操作範囲下限
  ,null as ihdf_dev_a_0200 -- I-HDF_補液量設定
  ,null as ihdf_dev_a_0201 -- I-HDF_補液速度
  ,null as ihdf_dev_a_0202 -- I-HDF_補液周期
  ,null as ihdf_dev_a_0203 -- I-HDF_補液開始時間
  ,null as ihdf_dev_a_0204 -- I-HDF_除水再開時間
  ,null as ihdf_dev_a_0205 -- I-HDF_総補液量上限
  ,null as blood_flow_judge --ホスト監視血流量監視フラグ
  ,null as blood_flow_upper --ホスト監視血流量上限
  ,null as blood_flow_lower --ホスト監視血流量下限
  ,null as ip_speed_judge --ホスト監視IP速度監視フラグ
  ,null as ip_speed_upper --ホスト監視IP速度上限
  ,null as ip_speed_lower --ホスト監視IP速度下限
  ,null as ufr_judge --ホスト監視除水速度監視フラグ
  ,null as ufr_upper --ホスト監視除水速度上限
  ,null as ufr_lower --ホスト監視除水速度下限
  ,null as bp_max_judge --ホスト監視最高血圧監視フラグ
  ,null as bp_max_upper --ホスト監視最高血圧上限
  ,null as bp_max_lower --ホスト監視最高血圧下限
  ,null as bp_min_judge --ホスト監視最低血圧監視フラグ
  ,null as bp_min_upper --ホスト監視最低血圧上限
  ,null as bp_min_lower --ホスト監視最低血圧下限
  ,null as bp_ave_judge --ホスト監視平均血圧監視フラグ
  ,null as bp_ave_upper --ホスト監視平均血圧上限
  ,null as bp_ave_lower --ホスト監視平均血圧下限
  ,null as pulse_judge --ホスト監視脈拍監視フラグ
  ,null as pulse_upper --ホスト監視脈拍上限
  ,null as pulse_lower --ホスト監視脈拍下限
  ,null as vp_judge --ホスト監視静脈圧監視フラグ
  ,null as vp_upper --ホスト監視静脈圧上限
  ,null as vp_lower --ホスト監視静脈圧下限
  ,null as rst_ap_judge --ホスト監視動脈圧監視フラグ
  ,null as rst_ap_upper --ホスト監視動脈圧上限
  ,null as rst_ap_lower --ホスト監視動脈圧下限
  ,null as na_conc_judge --ホスト監視Na濃度監視フラグ
  ,null as na_conc_upper --ホスト監視Na濃度上限
  ,null as na_conc_lower --ホスト監視Na濃度下限
  ,null as dialys_temp_judge --ホスト監視透析液温度監視フラグ
  ,null as dialys_temp_upper --ホスト監視透析液温度上限
  ,null as dialys_temp_lower --ホスト監視透析液温度下限
  ,null as care_i_judge --ホスト監視血圧未測定時報知監視フラグ
  ,null as care_i_interval --ホスト監視ケア報知
  ,null as war_dev_a_0240 -- TMP監視モード
  ,null as war_dev_a_0100 -- HD/ECUM静脈圧自動設定警報幅上限
  ,null as war_dev_a_0101 -- HD/ECUM静脈圧自動設定警報幅下限
  ,null as war_dev_a_0102 -- HD/ECUM静脈圧自動設定警報限界上限
  ,null as war_dev_a_0103 -- HD/ECUM静脈圧自動設定警報限界下限
  ,null as war_dev_a_0104 -- HD/ECUM静脈圧固定警報上限
  ,null as war_dev_a_0105 -- HD/ECUM静脈圧固定警報下限
  ,null as war_dev_a_0152 -- HD/ECUMダイアライザ入口圧自動設定警報幅上限
  ,null as war_dev_a_0153 -- HD/ECUMダイアライザ入口圧自動設定警報幅下限
  ,null as war_dev_a_0154 -- HD/ECUMダイアライザ入口圧自動設定警報限界上限
  ,null as war_dev_a_0155 -- HD/ECUMダイアライザ入口圧自動設定警報限界下限
  ,null as war_dev_a_0156 -- HD/ECUMダイアライザ入口圧固定警報上限
  ,null as war_dev_a_0157 -- HD/ECUMダイアライザ入口圧固定警報下限
  ,null as war_dev_a_0112 -- HD/ECUM液圧自動設定警報幅上限
  ,null as war_dev_a_0113 -- HD/ECUM液圧自動設定警報幅下限
  ,null as war_dev_a_0114 -- HD/ECUM液圧自動設定警報限界上限
  ,null as war_dev_a_0115 -- HD/ECUM液圧自動設定警報限界下限
  ,null as war_dev_a_0116 -- HD/ECUM液圧固定警報上限
  ,null as war_dev_a_0117 -- HD/ECUM液圧固定警報下限
  ,null as war_dev_a_0128 -- HD/ECUMTMP自動設定警報幅上限
  ,null as war_dev_a_0129 -- HD/ECUMTMP自動設定警報幅下限
  ,null as war_dev_a_0130 -- HD/ECUMTMP自動設定警報限界上限
  ,null as war_dev_a_0131 -- HD/ECUMTMP自動設定警報限界下限
  ,null as war_dev_a_0132 -- HD/ECUMTMP固定警報上限
  ,null as war_dev_a_0133 -- HD/ECUMTMP固定警報下限
  ,null as war_dev_a_0126 -- HD/ECUMTMP自動追従警報幅上限
  ,null as war_dev_a_0127 -- HD/ECUMTMP自動追従警報幅下限
  ,null as war_dev_a_0146 -- HD/ECUMダイアライザ差圧自動設定警報幅上限
  ,null as war_dev_a_0147 -- HD/ECUMダイアライザ差圧自動設定警報幅下限
  ,null as war_dev_a_0148 -- HD/ECUMダイアライザ差圧固定警報上限
  ,null as war_dev_a_0149 -- HD/ECUMダイアライザ差圧固定警報下限
  ,null as war_dev_a_0106 -- HDF/HF静脈圧自動設定警報幅上限
  ,null as war_dev_a_0107 -- HDF/HF静脈圧自動設定警報幅下限
  ,null as war_dev_a_0158 -- HDF/HFダイアライザ入口圧自動設定警報幅上限
  ,null as war_dev_a_0159 -- HDF/HFダイアライザ入口圧自動設定警報幅下限
  ,null as war_dev_a_0118 -- HDF/HF液圧自動設定警報幅上限
  ,null as war_dev_a_0119 -- HDF/HF液圧自動設定警報幅下限
  ,null as war_dev_a_0136 -- HDF/HFTMP自動設定警報幅上限
  ,null as war_dev_a_0137 -- HDF/HFTMP自動設定警報幅下限
  ,null as war_dev_a_0134 -- HDF/HFTMP自動追従警報幅上限
  ,null as war_dev_a_0135 -- HDF/HFTMP自動追従警報幅下限
  ,null as war_dev_a_0150 -- HDF/HFダイアライザ差圧自動設定警報幅上限
  ,null as war_dev_a_0151 -- HDF/HFダイアライザ差圧自動設定警報幅下限
  ,null as war_dev_a_0110 -- SN静脈圧固定警報上限
  ,null as war_dev_a_0111 -- SN静脈圧固定警報下限
  ,null as war_dev_a_0162 -- SNダイアライザ入口圧固定警報上限
  ,null as war_dev_a_0163 -- SNダイアライザ入口圧固定警報下限
  ,null as war_dev_a_0120 -- SN液圧自動設定警報幅上限
  ,null as war_dev_a_0121 -- SN液圧自動設定警報幅下限
  ,null as war_dev_a_0122 -- SN液圧自動設定警報限界上限
  ,null as war_dev_a_0123 -- SN液圧自動設定警報限界下限
  ,null as war_dev_a_0124 -- SN液圧固定警報上限
  ,null as war_dev_a_0125 -- SN液圧固定警報下限
  ,null as war_dev_a_0140 -- SNTMP自動設定警報幅上限
  ,null as war_dev_a_0141 -- SNTMP自動設定警報幅下限
  ,null as war_dev_a_0142 -- SNTMP自動設定警報限界上限
  ,null as war_dev_a_0143 -- SNTMP自動設定警報限界下限
  ,null as war_dev_a_0144 -- SNTMP固定警報上限
  ,null as war_dev_a_0145 -- SNTMP固定警報下限
  ,null as war_dev_a_0138 -- SNTMP自動追従警報幅上限
  ,null as war_dev_a_0139 -- SNTMP自動追従警報幅下限
  ,null as war_dev_a_0108 -- 準備回収静脈圧固定警報上限
  ,null as war_dev_a_0109 -- 準備回収静脈圧固定警報下限
  ,null as war_dev_a_0160 -- 準備回収ダイアライザ入口圧固定警報上限
  ,null as war_dev_a_0161 -- 準備回収ダイアライザ入口圧固定警報下限
  ,null as war_dev_a_0254 -- Na濃度自動警報幅上限値
  ,null as war_dev_a_0255 -- Na濃度自動警報幅下限値
  ,null as war_dev_a_0256 -- Na濃度固定警報幅上限値
  ,null as war_dev_a_0257 -- Na濃度固定警報幅下限値
  ,null as bp_dev_a_0211 -- 血圧警報点最高血圧上限
  ,null as bp_dev_a_0212 -- 血圧警報点最高血圧下限
  ,null as bp_dev_a_0213 -- 血圧警報点最低血圧上限
  ,null as bp_dev_a_0214 -- 血圧警報点最低血圧下限
  ,null as bp_dev_a_0215 -- 血圧警報点平均血圧上限
  ,null as bp_dev_a_0216 -- 血圧警報点平均血圧下限
  ,null as bp_dev_a_0217 -- 血圧警報点脈拍数上限
  ,null as bp_dev_a_0218 -- 血圧警報点脈拍数下限
  ,null as bp_dev_a_0219 -- 最高血圧上限警報_血液ポンプ_動作選択
  ,null as bp_dev_a_0227 -- 最高血圧上限警報_血液ポンプ_速度
  ,null as bp_dev_a_0220 -- 最高血圧下限警報_血液ポンプ_動作選択
  ,null as bp_dev_a_0228 -- 最高血圧下限警報_血液ポンプ_速度
  ,null as bp_dev_a_0221 -- 最高血圧上限警報_除水ポンプ_動作選択
  ,null as bp_dev_a_0229 -- 最高血圧上限警報_除水ポンプ_速度
  ,null as bp_dev_a_0222 -- 最高血圧下限警報_除水ポンプ_動作選択
  ,null as bp_dev_a_0230 -- 最高血圧下限警報_除水ポンプ_速度
  ,null as bp_dev_a_0223 -- 最高血圧上限警報_Na注入ポンプ_動作選択
  ,null as bp_dev_a_0231 -- 最高血圧上限警報_Na注入ポンプ_速度
  ,null as bp_dev_a_0224 -- 最高血圧下限警報_Na注入ポンプ_動作選択
  ,null as bp_dev_a_0232 -- 最高血圧下限警報_Na注入ポンプ_速度
  ,null as bp_dev_a_0225 -- 最高血圧上限警報_補液ポンプ_動作選択
  ,null as bp_dev_a_0233 -- 最高血圧上限警報_補液ポンプ_速度
  ,null as bp_dev_a_0226 -- 最高血圧下限警報_補液ポンプ_動作選択
  ,null as bp_dev_a_0234 -- 最高血圧下限警報_補液ポンプ_速度
  ,null as bp_dev_a_0191 -- 血圧カフ選択
  ,null as bp_dev_a_0190 -- 血圧自動測定間隔
  ,null as bp_dev_a_0192 -- 昇圧値
  ,null as bp_dev_a_0193 -- 昇圧方法選択
  ,null as bp_dev_a_0195 -- 血圧測定方法選択
  ,null as bp_dev_a_0239 -- 高速測定選択
  ,null as bp_dev_a_0194 -- 血圧連続測定動作選択
  ,null as bp_dev_a_0235 -- 警報連動測定開始時間
  ,null as bp_dev_a_0236 -- 治療条件連動測定時間
  ,null as bp_dev_a_0237 -- 静脈圧警報発生時の血圧測定
  ,null as bp_dev_a_0238 -- 血流量または除水速度変更時の血圧測定
  ,null as bv_dev_a_0267 -- BV計使用選択
  ,null as bv_dev_a_0260 -- ⊿BV低下警報点1
  ,null as bv_dev_a_0261 -- ⊿BV低下警報点2
  ,null as bv_dev_a_0262 -- ⊿BV変化率警報点
  ,null as bv_dev_a_0277 -- ⊿BV除水低下速度
  ,null as bv_dev_a_0278 -- ⊿BV除水低下遅延時間
  ,null as bv_dev_a_0258 -- アクセス再循環測定使用選択
  ,null as bv_dev_a_0259 -- アクセス再循環自動測定1
  ,null as bv_dev_a_0263 -- アクセス再循環自動測定2
  ,null as bv_dev_a_0264 -- アクセス再循環自動測定3
  ,null as bv_dev_a_0265 -- アクセス再循環自動測定4
  ,null as bv_dev_a_0266 -- アクセス再循環自動測定5
  ,null as dfas_dev_a_0270 -- 動脈側返血使用選択
  ,null as bv_dev_a_0281 -- アクセス再循環再循環率報知
  ,null as pri_pat_a_0219 -- プライミング補助動脈充填液量
  ,null as pri_pat_a_0220 -- プライミング補助動脈充填流速
  ,null as pri_pat_a_0225 -- プライミング補助動脈充填後継続の有無
  ,null as pri_pat_a_0221 -- プライミング補助静脈充填液量
  ,null as pri_pat_a_0222 -- プライミング補助静脈充填流速
  ,null as pri_pat_a_0226 -- プライミング補助静脈充填後継続の有無
  ,null as pri_pat_a_0223 -- プライミング補助気泡抜き液量
  ,null as pri_pat_a_0224 -- プライミング補助気泡抜き流速
  ,null as pri_pat_a_0227 -- プライミング補助気泡抜き間欠動作選択
  ,null as pri_pat_a_0228 -- プライミング補助液交換量
  ,null as pri_pat_a_0229 -- プライミング補助間欠動作動作時間
  ,null as pri_pat_a_0230 -- プライミング補助間欠動作停止時間
  ,null as pri_pat_a_0232 -- 自動プライミング落差時間
  ,null as pri_pat_a_0238 -- 自動プライミング総量
  ,null as pri_pat_a_0231 -- 自動プライミング開始時間
  ,null as pri_pat_a_0233 -- 自動プライミング送液液量
  ,null as pri_pat_a_0234 -- 自動プライミング送液流速1回目
  ,null as pri_pat_a_0235 -- 自動プライミング送液流速2回目以降
  ,null as pri_pat_a_0236 -- 自動プライミング循環流速
  ,null as pri_pat_a_0237 -- 自動プライミング循環時間
  ,null as pri_dev_a_0370 -- 自動回収_使用液量
  ,null as pri_dev_a_0371 -- 自動回収_流速
  ,null as pri_dev_a_0372 -- 自動回収_血液判別器による終了選択
  ,null as pri_pat_b_0051 -- オンラインプライミング_ダイアライザ気泡抜き時間_後補液
  ,null as pri_pat_b_0032 -- オンラインプライミング_動脈チャンバ液面作成時間_前補液
  ,null as pri_pat_b_0052 -- オンラインプライミング_動脈チャンバ液面作成時間_後補液
  ,null as pri_pat_b_0033 -- オンラインプライミング_循環洗浄時間_前補液
  ,null as pri_pat_b_0053 -- オンラインプライミング_循環洗浄時間_後補液
  ,null as ufr_dev_a_0290 -- UFRプログラム使用選択
  ,null as na_dev_a_0315 -- Na注入プログラム使用選択
  ,null as na_dev_a_0184 -- Na注入濃度最大値
  ,null as dc_dev_a_0340 -- 透析液濃度プログラム使用選択
  ,null as ecum_dev_a_0016 -- ECUM選択
  ,null as ecum_dev_a_0017 -- ECUM量
  ,null as ecum_dev_a_0018 -- ECUM時間
  ,null as ecum_dev_a_0019 -- ECUM時間カウント選択
  ,null as cpro_dev_a_0252 -- Ｂ液濃度プログラム自動設定警報幅上限
  ,null as cpro_dev_a_0253 -- Ｂ液濃度プログラム自動設定警報幅下限
  ,null as cpro_dev_a_0250 -- 透析液濃度プログラム自動設定警報幅上限
  ,null as cpro_dev_a_0251 -- 透析液濃度プログラム自動設定警報幅下限
  ,null as dfas_pat_b_0001 -- IPラインプライミング使用選択
  ,dialyzer_record.gas_purge_time -- ガスパージ時間
  ,dialyzer_record.substituent_wash_amt-- 置換洗浄量（透析液）
  ,dialyzer_record.membrane_wash -- 膜洗浄（中空糸）
  ,null as dfas_pat_b_0005 -- 中空糸_プライミング時のBP速度
  ,null as dfas_pat_b_0007 -- 中空糸_送液最大時間
  ,null as dfas_pat_b_0008 -- 中空糸_回路内洗浄送液量
  ,null as dfas_pat_b_0009 -- 中空糸_気泡抜き動作実行回数
  ,null as dfas_pat_b_0010 -- 中空糸_気泡抜き圧力上限
  ,null as dfas_pat_b_0059 -- 積層_プライミング時のBP速度
  ,null as dfas_pat_b_0054 -- 積層_送液最大時間
  ,null as dfas_pat_b_0055 -- 積層_回路内洗浄送液量
  ,null as dfas_pat_b_0056 -- 積層_気泡抜き動作実行回数
  ,null as dfas_pat_b_0057 -- 積層_気泡抜き圧力上限
  ,null as dfas_pat_b_0058 -- 積層_除水ポンプ速度
  ,null as dfas_dev_a_0339 -- 脱血方法選択
  ,null as dfas_dev_a_0333 -- 脱血速度
  ,null as dfas_dev_a_0331 -- 同時脱血_脱血量
  ,null as dfas_dev_a_0334 -- 片側脱血(除水なし)_脱血量
  ,null as dfas_dev_a_0338 -- 片側脱血（除水あり）_脱血量
  ,null as dfas_dev_a_0332 -- 片側脱血への切替え透析液圧
  ,treat_condition->>''335'' as ord_treat_condition_335 -- 治療開始時_血液ポンプ速度
  ,null as dfas_dev_a_0373 -- 静脈側返血速度
  ,null as dfas_dev_a_0374 -- 静脈側最大返血量
  ,null as dfas_dev_a_0377 -- 静脈側返血_血液判別器使用選択
  ,null as dfas_dev_a_0376 -- 動脈側最大返血量
  ,null as dfas_dev_a_0378 -- 動脈側返血_血液判別器使用選択
  ,null as dia_dev_a_0282 -- 透析量プログラム使用選択
  ,treat_condition->>''283'' as ord_treat_condition_283 -- 体液量計算時後体重
  ,treat_condition->>''284'' as ord_treat_condition_284 -- 体液量+補正値
  ,treat_condition->>''285'' as ord_treat_condition_285 -- 目標後体重
  ,treat_condition->>''286'' as ord_treat_condition_286 -- 標準血流量
  ,treat_condition->>''287'' as ord_treat_condition_287 -- KoA
  ,null as dia_dev_a_0288 -- 目標Kt/V
  ,treat_condition->>''187'' as ord_treat_condition_187 -- ダイアライザ 尿素クリアランス
  ,treat_condition->>''188'' as ord_treat_condition_188 -- ダイアライザ 血流量
  ,treat_condition->>''189'' as ord_treat_condition_189 -- ダイアライザ 透析液流量
  ,null as bvufc_dev_a_0196 -- BV-UFC使用選択
  ,null as bvufc_dev_a_0197 -- UFC期間除水速度上限
  ,null as bvufc_dev_a_0198 -- UFC期間除水速度下限
  ,null as bvufc_dev_a_0199 -- 開始期間 時間
  ,null as bvufc_dev_a_0206 -- 開始期間 除水速度倍率
  ,null as bvufc_dev_a_0207 -- 固定倍率除水期間 時間
  ,null as bvufc_dev_a_0208 -- 固定倍率除水期間 除水速度倍率
  ,null as bvufc_dev_a_0209 -- 固定倍率除水終了条件　最高血圧
  ,null as bvufc_dev_a_0210 -- 固定倍率除水終了条件　脈拍
  ,null as bvufc_dev_a_0248 -- 固定倍率除水終了条件　ΔBV
  ,null as bvufc_dev_a_0249 -- 終了前期間 時間
  ,null as ope_dev_a_0268 -- 透析液流量　設定方法
  ,null as ope_dev_a_0269 -- 透析液流量　比率設定
  ,null as bvufc_dev_a_0271 -- 開始時ΔBV基準値
  ,null as bvufc_dev_a_0272 -- ΔBV基準線　指数1
  ,null as bvufc_dev_a_0273 -- ΔBV基準線　指数2
  ,null as bvufc_dev_a_0274 -- ΔBV基準線　指数3
  ,null as bvufc_dev_a_0275 -- 終了時ΔBV基準値
  ,null as qbqd_dev_a_0400 -- QBプログラム血流量1
  ,null as qbqd_dev_a_0401 -- QBプログラム血流量2
  ,null as qbqd_dev_a_0402 -- QBプログラム血流量3
  ,null as qbqd_dev_a_0403 -- QBプログラム血流量4
  ,null as qbqd_dev_a_0404 -- QBプログラム血流量5
  ,null as qbqd_dev_a_0405 -- QBプログラム血流量6
  ,null as qbqd_dev_a_0406 -- QBプログラム血流量7
  ,null as qbqd_dev_a_0407 -- QBプログラム血流量8
  ,null as qbqd_dev_a_0408 -- QBプログラム血流量9
  ,null as qbqd_dev_a_0409 -- QBプログラム血流量10
  ,null as qbqd_dev_a_0410 -- QDプログラム透析液流量1
  ,null as qbqd_dev_a_0411 -- QDプログラム透析液流量2
  ,null as qbqd_dev_a_0412 -- QDプログラム透析液流量3
  ,null as qbqd_dev_a_0413 -- QDプログラム透析液流量4
  ,null as qbqd_dev_a_0414 -- QDプログラム透析液流量5
  ,null as qbqd_dev_a_0415 -- QDプログラム透析液流量6
  ,null as qbqd_dev_a_0416 -- QDプログラム透析液流量7
  ,null as qbqd_dev_a_0417 -- QDプログラム透析液流量8
  ,null as qbqd_dev_a_0418 -- QDプログラム透析液流量9
  ,null as qbqd_dev_a_0419 -- QDプログラム透析液流量10
  ,null as qbqd_dev_a_0420 -- QB、QDプログラム切替時間1
  ,null as qbqd_dev_a_0421 -- QB、QDプログラム切替時間2
  ,null as qbqd_dev_a_0422 -- QB、QDプログラム切替時間3
  ,null as qbqd_dev_a_0423 -- QB、QDプログラム切替時間4
  ,null as qbqd_dev_a_0424 -- QB、QDプログラム切替時間5
  ,null as qbqd_dev_a_0425 -- QB、QDプログラム切替時間6
  ,null as qbqd_dev_a_0426 -- QB、QDプログラム切替時間7
  ,null as qbqd_dev_a_0427 -- QB、QDプログラム切替時間8
  ,null as qbqd_dev_a_0428 -- QB、QDプログラム切替時間9
  ,null as qbqd_dev_a_0429 -- QB、QDプログラム最大ステップ数
  ,null as qbqd_dev_a_0430 -- QBプログラム電源
  ,null as qbqd_dev_a_0431 -- QDプログラム電源
  ,null as ihdf_dev_a_0432 -- I-HDFプログラム使用選択
  ,null as ihdf_dev_a_0433 -- 予定補液回数
  ,null as ihdf_dev_a_0434 -- 補液バランス制限
  ,null as ihdf_dev_a_0435 -- 補液量01
  ,null as ihdf_dev_a_0436 -- 補液量02
  ,null as ihdf_dev_a_0437 -- 補液量03
  ,null as ihdf_dev_a_0438 -- 補液量04
  ,null as ihdf_dev_a_0439 -- 補液量05
  ,null as ihdf_dev_a_0440 -- 補液量06
  ,null as ihdf_dev_a_0441 -- 補液量07
  ,null as ihdf_dev_a_0442 -- 補液量08
  ,null as ihdf_dev_a_0443 -- 補液量09
  ,null as ihdf_dev_a_0444 -- 補液量10
  ,null as ihdf_dev_a_0445 -- 補液量11
  ,null as ihdf_dev_a_0446 -- 補液量12
  ,null as ihdf_dev_a_0447 -- 補液量13
  ,null as ihdf_dev_a_0448 -- 補液量14
  ,null as ihdf_dev_a_0449 -- 補液量15
  ,null as ihdf_dev_a_0450 -- 補液量16
  ,null as ihdf_dev_a_0451 -- 回収量01
  ,null as ihdf_dev_a_0452 -- 回収量02
  ,null as ihdf_dev_a_0453 -- 回収量03
  ,null as ihdf_dev_a_0454 -- 回収量04
  ,null as ihdf_dev_a_0455 -- 回収量05
  ,null as ihdf_dev_a_0456 -- 回収量06
  ,null as ihdf_dev_a_0457 -- 回収量07
  ,null as ihdf_dev_a_0458 -- 回収量08
  ,null as ihdf_dev_a_0459 -- 回収量09
  ,null as ihdf_dev_a_0460 -- 回収量10
  ,null as ihdf_dev_a_0461 -- 回収量11
  ,null as ihdf_dev_a_0462 -- 回収量12
  ,null as ihdf_dev_a_0463 -- 回収量13
  ,null as ihdf_dev_a_0464 -- 回収量14
  ,null as ihdf_dev_a_0465 -- 回収量15
  ,null as ihdf_dev_a_0466 -- 回収量16
	,ord_main.ord_no as ord_no_t
from
  ord_main
  inner join latest_otc on ord_main.ord_no = latest_otc.ord_no
  cross join dialyzer_record
where ord_main.ord_no = @ordNo and ord_main.is_del = ''0''
 and ord_main.rst_dialysis_state <>''0''


	),
time_info AS (
	WITH b AS (
    select ord_main.* from ord_main
     where rst_dialysis_state between ''1'' and ''5''
     and
			 ord_no = @ordNo
     and
       is_del = ''0''
	), d AS (
    select b.ord_no
    , data_type
    , MAX(bio_moni_ctl_no) AS bio_moni_ctl_no
    from b inner join mni_monitor on (b.ord_no = mni_monitor.ord_no)
    group by b.ord_no
    , mni_monitor.data_type
	), e AS (
    select mni_monitor.*,
    to_number(mni_monitor.monitor_data::json->>''1'', ''9999'') AS 経過時間
    , to_number(mni_monitor.monitor_data::json->>''3'', ''9999'') AS 残り時間_除水完了
    , to_number(mni_monitor.monitor_data::json->>''4'', ''9999'') AS 残り時間_透析完了
    from d
    inner join mni_monitor on (d.bio_moni_ctl_no = mni_monitor.bio_moni_ctl_no)
    where d.data_type = 1
	), f AS (
    select e.*
    , e.経過時間 + e.残り時間_除水完了 AS 予測時間_除水
    , e.経過時間 + e.残り時間_透析完了 AS 予測時間_透析
    from e
	)
	select
	b.ord_no,
	-- 終了予定
	b.rst_start_date + e.経過時間  * interval ''1 minute'' AS  ind_end_date,
	-- 終了予測
	CASE WHEN b.rst_dialysis_state < ''3'' THEN null
       WHEN f.残り時間_除水完了 > f.残り時間_透析完了 THEN b.rst_start_date + f.予測時間_除水 * interval ''1 minute''
       ELSE b.rst_start_date + f.予測時間_透析 * interval ''1 minute''
	END AS ind_end_date_time
	-- 透析開始
	, b.rst_start_date
	-- 透析終了
	, b.rst_end_date
	from  b left JOIN e on b.ord_no=e.ord_no left JOIN f on b.ord_no=f.ord_no
)
SELECT
DATA.ord_no_t as ord_no,
	*
FROM
	DATA
	LEFT JOIN
	time_info
	on
	DATA.ord_no_t = time_info.ord_no',2,'[{"preview": "220", "can_calc": "1", "data_code": "ope_dev_a_0179", "data_name": "血流量設定最大値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0179", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4.00", "can_calc": "1", "data_code": "ope_dev_a_0181", "data_name": "除水速度制限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0181", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "0", "data_code": "ope_dev_a_0038", "data_name": "動脈側気泡検出器", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用する", "item": "使用する"}, {"code": "1", "disp": "使用しない", "item": "使用しない"}], "data_class": "装置設定", "field_name": "ope_dev_a_0038", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析時間", "can_calc": "0", "data_code": "ope_dev_a_0021", "data_name": "除水計算時間", "data_type": "string", "conv_table": [{"code": "0", "disp": "透析時間", "item": "透析時間"}, {"code": "1", "disp": "設定時間", "item": "設定時間"}], "data_class": "装置設定", "field_name": "ope_dev_a_0021", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "除水速度算出", "can_calc": "0", "data_code": "ope_dev_a_0022", "data_name": "除水計算優先項目", "data_type": "string", "conv_table": [{"code": "0", "disp": "除水速度算出", "item": "除水速度算出"}, {"code": "1", "disp": "除水量設定算出", "item": "除水量設定算出"}], "data_class": "装置設定", "field_name": "ope_dev_a_0022", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "ope_dev_a_0039", "data_name": "除水開始遅延時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0039", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "40.0", "can_calc": "1", "data_code": "ope_dev_a_0182", "data_name": "透析液温度操作範囲上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0182", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "33.0", "can_calc": "1", "data_code": "ope_dev_a_0183", "data_name": "透析液温度操作範囲下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0183", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "ope_dev_a_0024", "data_name": "シングルニードル切替圧上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0024", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "ope_dev_a_0025", "data_name": "シングルニードル切替圧下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0025", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "あり", "can_calc": "0", "data_code": "ope_dev_a_0241", "data_name": "TMPゼロ補正", "data_type": "string", "conv_table": [{"code": "0", "disp": "あり", "item": "あり"}, {"code": "1", "disp": "なし", "item": "なし"}], "data_class": "装置設定", "field_name": "ope_dev_a_0241", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "ope_dev_a_0168", "data_name": "HD補正警報上限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0168", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "ope_dev_a_0169", "data_name": "HD補正警報下限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0169", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "ope_dev_a_0171", "data_name": "ECUM補正警報上限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0171", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "ope_dev_a_0172", "data_name": "ECUM補正警報下限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0172", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "ope_dev_a_0174", "data_name": "HDF補正警報上限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0174", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "ope_dev_a_0175", "data_name": "HDF補正警報下限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0175", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "ope_dev_a_0177", "data_name": "HF補正警報上限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0177", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "ope_dev_a_0178", "data_name": "HF補正警報下限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0178", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "ope_dev_b_0037", "data_name": "HD+補液補正警報上限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0037", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "ope_dev_b_0038", "data_name": "HD+補液補正警報下限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0038", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "ope_dev_a_0391", "data_name": "OHDF補正警報上限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0391", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "ope_dev_a_0392", "data_name": "OHDF補正警報下限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0392", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "ope_dev_a_0394", "data_name": "OHF補正警報上限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0394", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "ope_dev_a_0395", "data_name": "OHF補正警報下限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0395", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4.0", "can_calc": "1", "data_code": "ope_dev_a_0383", "data_name": "補液量制限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0383", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "補液速度算出", "can_calc": "0", "data_code": "ope_dev_a_0389", "data_name": "補液計算優先項目", "data_type": "string", "conv_table": [{"code": "0", "disp": "補液速度算出", "item": "補液速度算出"}, {"code": "1", "disp": "補液量設定算出", "item": "補液量設定算出"}, {"code": "2", "disp": "補液比率", "item": "補液比率"}, {"code": "3", "disp": "濾過率から算出", "item": "濾過率から算出"}], "data_class": "装置設定", "field_name": "ope_dev_a_0389", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20", "can_calc": "1", "data_code": "ope_dev_a_0379", "data_name": "補液比率（前補液）", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0379", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20", "can_calc": "1", "data_code": "ope_dev_b_0039", "data_name": "補液比率（後補液）", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0039", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ope_dev_a_0398", "data_name": "補液開始遅延時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0398", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "0", "data_code": "ope_dev_a_0369", "data_name": "DP=Qd+Qs(補液速度加算)", "data_type": "string", "conv_table": [{"code": "1", "disp": "使用しない", "item": "使用しない"}, {"code": "2", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "ope_dev_a_0369", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "52", "can_calc": "1", "data_code": "ope_dev_a_0090", "data_name": "濾過率（前補液）", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0090", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "42", "can_calc": "1", "data_code": "ope_dev_b_0040", "data_name": "濾過率（後補液）", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0040", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "35", "can_calc": "1", "data_code": "ope_dev_a_0091", "data_name": "ヘマトクリット（Ht）", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0091", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.7", "can_calc": "1", "data_code": "ope_dev_a_0092", "data_name": "総タンパク（TP）", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0092", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "ope_dev_a_0336", "data_name": "緊急補液速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0336", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "ope_dev_a_0337", "data_name": "緊急補液量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0337", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.00", "can_calc": "1", "data_code": "ope_dev_a_0185", "data_name": "HDF速度操作範囲上限前補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0185", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.00", "can_calc": "1", "data_code": "ope_dev_b_0031", "data_name": "HDF速度操作範囲上限後補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0031", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.00", "can_calc": "1", "data_code": "ope_dev_a_0186", "data_name": "HF速度操作範囲上限前補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0186", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.00", "can_calc": "1", "data_code": "ope_dev_b_0032", "data_name": "HF速度操作範囲上限後補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0032", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12.00", "can_calc": "1", "data_code": "ope_dev_b_0030", "data_name": "HD+補液速度操作範囲上限前補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0030", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.00", "can_calc": "1", "data_code": "ope_dev_b_0033", "data_name": "HD+補液速度操作範囲上限後補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0033", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12.00", "can_calc": "1", "data_code": "ope_dev_a_0396", "data_name": "OHDF速度操作範囲上限前補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0396", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.00", "can_calc": "1", "data_code": "ope_dev_b_0034", "data_name": "OHDF速度操作範囲上限後補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0034", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12.00", "can_calc": "1", "data_code": "ope_dev_a_0397", "data_name": "OHF速度操作範囲上限前補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0397", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.00", "can_calc": "1", "data_code": "ope_dev_b_0035", "data_name": "OHF速度操作範囲上限後補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0035", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "0", "data_code": "ope_dev_a_0384", "data_name": "AFBF補液比率使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "ope_dev_a_0384", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "13.00", "can_calc": "1", "data_code": "ope_dev_a_0385", "data_name": "AFBF補液比率", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0385", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.50", "can_calc": "1", "data_code": "ope_dev_a_0386", "data_name": "AFBF速度操作範囲上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0386", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.00", "can_calc": "1", "data_code": "ope_dev_a_0387", "data_name": "AFBF速度操作範囲下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0387", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "ihdf_dev_a_0200", "data_name": "I-HDF_補液量設定", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0200", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "ihdf_dev_a_0201", "data_name": "I-HDF_補液速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0201", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30", "can_calc": "1", "data_code": "ihdf_dev_a_0202", "data_name": "I-HDF_補液周期", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0202", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30", "can_calc": "1", "data_code": "ihdf_dev_a_0203", "data_name": "I-HDF_補液開始時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0203", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0204", "data_name": "I-HDF_除水再開時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0204", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.50", "can_calc": "1", "data_code": "ihdf_dev_a_0205", "data_name": "I-HDF_総補液量上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0205", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析液圧", "can_calc": "0", "data_code": "war_dev_a_0240", "data_name": "TMP監視モード", "data_type": "string", "conv_table": [{"code": "0", "disp": "TMP自動追従", "item": "TMP自動追従"}, {"code": "1", "disp": "TMP自動設定", "item": "TMP自動設定"}, {"code": "2", "disp": "透析液圧", "item": "透析液圧"}], "data_class": "装置設定", "field_name": "war_dev_a_0240", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "war_dev_a_0100", "data_name": "HD/ECUM静脈圧自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0100", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-30", "can_calc": "1", "data_code": "war_dev_a_0101", "data_name": "HD/ECUM静脈圧自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0101", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "war_dev_a_0102", "data_name": "HD/ECUM静脈圧自動設定警報限界上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0102", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "1", "data_code": "war_dev_a_0103", "data_name": "HD/ECUM静脈圧自動設定警報限界下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0103", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "war_dev_a_0104", "data_name": "HD/ECUM静脈圧固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0104", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0105", "data_name": "HD/ECUM静脈圧固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0105", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "war_dev_a_0152", "data_name": "HD/ECUMダイアライザ入口圧自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0152", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0153", "data_name": "HD/ECUMダイアライザ入口圧自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0153", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "war_dev_a_0154", "data_name": "HD/ECUMダイアライザ入口圧自動設定警報限界上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0154", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "war_dev_a_0155", "data_name": "HD/ECUMダイアライザ入口圧自動設定警報限界下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0155", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "war_dev_a_0156", "data_name": "HD/ECUMダイアライザ入口圧固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0156", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0157", "data_name": "HD/ECUMダイアライザ入口圧固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0157", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "war_dev_a_0112", "data_name": "HD/ECUM液圧自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0112", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0113", "data_name": "HD/ECUM液圧自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0113", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "war_dev_a_0114", "data_name": "HD/ECUM液圧自動設定警報限界上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0114", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-300", "can_calc": "1", "data_code": "war_dev_a_0115", "data_name": "HD/ECUM液圧自動設定警報限界下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0115", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "war_dev_a_0116", "data_name": "HD/ECUM液圧固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0116", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-300", "can_calc": "1", "data_code": "war_dev_a_0117", "data_name": "HD/ECUM液圧固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0117", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "war_dev_a_0128", "data_name": "HD/ECUMTMP自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0128", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0129", "data_name": "HD/ECUMTMP自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0129", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "war_dev_a_0130", "data_name": "HD/ECUMTMP自動設定警報限界上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0130", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-30", "can_calc": "1", "data_code": "war_dev_a_0131", "data_name": "HD/ECUMTMP自動設定警報限界下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0131", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "war_dev_a_0132", "data_name": "HD/ECUMTMP固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0132", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-30", "can_calc": "1", "data_code": "war_dev_a_0133", "data_name": "HD/ECUMTMP固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0133", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20", "can_calc": "1", "data_code": "war_dev_a_0126", "data_name": "HD/ECUMTMP自動追従警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0126", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-20", "can_calc": "1", "data_code": "war_dev_a_0127", "data_name": "HD/ECUMTMP自動追従警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0127", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20", "can_calc": "1", "data_code": "war_dev_a_0146", "data_name": "HD/ECUMダイアライザ差圧自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0146", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-20", "can_calc": "1", "data_code": "war_dev_a_0147", "data_name": "HD/ECUMダイアライザ差圧自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0147", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "80", "can_calc": "1", "data_code": "war_dev_a_0148", "data_name": "HD/ECUMダイアライザ差圧固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0148", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "war_dev_a_0149", "data_name": "HD/ECUMダイアライザ差圧固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0149", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70", "can_calc": "1", "data_code": "war_dev_a_0106", "data_name": "HDF/HF静脈圧自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0106", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-70", "can_calc": "1", "data_code": "war_dev_a_0107", "data_name": "HDF/HF静脈圧自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0107", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70", "can_calc": "1", "data_code": "war_dev_a_0158", "data_name": "HDF/HFダイアライザ入口圧自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0158", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-70", "can_calc": "1", "data_code": "war_dev_a_0159", "data_name": "HDF/HFダイアライザ入口圧自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0159", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70", "can_calc": "1", "data_code": "war_dev_a_0118", "data_name": "HDF/HF液圧自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0118", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-70", "can_calc": "1", "data_code": "war_dev_a_0119", "data_name": "HDF/HF液圧自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0119", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "war_dev_a_0136", "data_name": "HDF/HFTMP自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0136", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0137", "data_name": "HDF/HFTMP自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0137", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70", "can_calc": "1", "data_code": "war_dev_a_0134", "data_name": "HDF/HFTMP自動追従警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0134", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-70", "can_calc": "1", "data_code": "war_dev_a_0135", "data_name": "HDF/HFTMP自動追従警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0135", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "war_dev_a_0150", "data_name": "HDF/HFダイアライザ差圧自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0150", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0151", "data_name": "HDF/HFダイアライザ差圧自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0151", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "400", "can_calc": "1", "data_code": "war_dev_a_0110", "data_name": "SN静脈圧固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0110", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0111", "data_name": "SN静脈圧固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0111", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5000", "can_calc": "1", "data_code": "war_dev_a_0162", "data_name": "SNダイアライザ入口圧固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0162", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0163", "data_name": "SNダイアライザ入口圧固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0163", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70", "can_calc": "1", "data_code": "war_dev_a_0120", "data_name": "SN液圧自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0120", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-70", "can_calc": "1", "data_code": "war_dev_a_0121", "data_name": "SN液圧自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0121", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "war_dev_a_0122", "data_name": "SN液圧自動設定警報限界上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0122", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-300", "can_calc": "1", "data_code": "war_dev_a_0123", "data_name": "SN液圧自動設定警報限界下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0123", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "war_dev_a_0124", "data_name": "SN液圧固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0124", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-300", "can_calc": "1", "data_code": "war_dev_a_0125", "data_name": "SN液圧固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0125", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "war_dev_a_0140", "data_name": "SNTMP自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0140", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-30", "can_calc": "1", "data_code": "war_dev_a_0141", "data_name": "SNTMP自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0141", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "war_dev_a_0142", "data_name": "SNTMP自動設定警報限界上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0142", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-30", "can_calc": "1", "data_code": "war_dev_a_0143", "data_name": "SNTMP自動設定警報限界下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0143", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "war_dev_a_0144", "data_name": "SNTMP固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0144", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0145", "data_name": "SNTMP固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0145", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70", "can_calc": "1", "data_code": "war_dev_a_0138", "data_name": "SNTMP自動追従警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0138", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-70", "can_calc": "1", "data_code": "war_dev_a_0139", "data_name": "SNTMP自動追従警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0139", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "400", "can_calc": "1", "data_code": "war_dev_a_0108", "data_name": "準備回収静脈圧固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0108", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-200", "can_calc": "1", "data_code": "war_dev_a_0109", "data_name": "準備回収静脈圧固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0109", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "war_dev_a_0160", "data_name": "準備回収ダイアライザ入口圧固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0160", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-200", "can_calc": "1", "data_code": "war_dev_a_0161", "data_name": "準備回収ダイアライザ入口圧固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0161", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5", "can_calc": "1", "data_code": "war_dev_a_0254", "data_name": "Na濃度自動警報幅上限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0254", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-5", "can_calc": "1", "data_code": "war_dev_a_0255", "data_name": "Na濃度自動警報幅下限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0255", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "190", "can_calc": "1", "data_code": "war_dev_a_0256", "data_name": "Na濃度固定警報幅上限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0256", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120", "can_calc": "1", "data_code": "war_dev_a_0257", "data_name": "Na濃度固定警報幅下限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0257", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "bp_dev_a_0211", "data_name": "血圧警報点最高血圧上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0211", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "80", "can_calc": "1", "data_code": "bp_dev_a_0212", "data_name": "血圧警報点最高血圧下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0212", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "160", "can_calc": "1", "data_code": "bp_dev_a_0213", "data_name": "血圧警報点最低血圧上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0213", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "bp_dev_a_0214", "data_name": "血圧警報点最低血圧下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0214", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "180", "can_calc": "1", "data_code": "bp_dev_a_0215", "data_name": "血圧警報点平均血圧上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0215", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "bp_dev_a_0216", "data_name": "血圧警報点平均血圧下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0216", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "170", "can_calc": "1", "data_code": "bp_dev_a_0217", "data_name": "血圧警報点脈拍数上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0217", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "bp_dev_a_0218", "data_name": "血圧警報点脈拍数下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0218", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■動作", "can_calc": "0", "data_code": "bp_dev_a_0219", "data_name": "最高血圧上限警報_血液ポンプ_動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "□動作", "item": "□動作"}, {"code": "1", "disp": "■動作", "item": "■動作"}], "data_class": "装置設定", "field_name": "bp_dev_a_0219", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "bp_dev_a_0227", "data_name": "最高血圧上限警報_血液ポンプ_速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0227", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■動作", "can_calc": "0", "data_code": "bp_dev_a_0220", "data_name": "最高血圧下限警報_血液ポンプ_動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "□動作", "item": "□動作"}, {"code": "1", "disp": "■動作", "item": "■動作"}], "data_class": "装置設定", "field_name": "bp_dev_a_0220", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "bp_dev_a_0228", "data_name": "最高血圧下限警報_血液ポンプ_速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0228", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■動作", "can_calc": "0", "data_code": "bp_dev_a_0221", "data_name": "最高血圧上限警報_除水ポンプ_動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "□動作", "item": "□動作"}, {"code": "1", "disp": "■動作", "item": "■動作"}], "data_class": "装置設定", "field_name": "bp_dev_a_0221", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.10", "can_calc": "1", "data_code": "bp_dev_a_0229", "data_name": "最高血圧上限警報_除水ポンプ_速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0229", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■動作", "can_calc": "0", "data_code": "bp_dev_a_0222", "data_name": "最高血圧下限警報_除水ポンプ_動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "□動作", "item": "□動作"}, {"code": "1", "disp": "■動作", "item": "■動作"}], "data_class": "装置設定", "field_name": "bp_dev_a_0222", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.10", "can_calc": "1", "data_code": "bp_dev_a_0230", "data_name": "最高血圧下限警報_除水ポンプ_速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0230", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■動作", "can_calc": "0", "data_code": "bp_dev_a_0223", "data_name": "最高血圧上限警報_Na注入ポンプ_動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "□動作", "item": "□動作"}, {"code": "1", "disp": "■動作", "item": "■動作"}], "data_class": "装置設定", "field_name": "bp_dev_a_0223", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.30", "can_calc": "1", "data_code": "bp_dev_a_0231", "data_name": "最高血圧上限警報_Na注入ポンプ_速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0231", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■動作", "can_calc": "0", "data_code": "bp_dev_a_0224", "data_name": "最高血圧下限警報_Na注入ポンプ_動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "□動作", "item": "□動作"}, {"code": "1", "disp": "■動作", "item": "■動作"}], "data_class": "装置設定", "field_name": "bp_dev_a_0224", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.30", "can_calc": "1", "data_code": "bp_dev_a_0232", "data_name": "最高血圧下限警報_Na注入ポンプ_速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0232", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■動作", "can_calc": "0", "data_code": "bp_dev_a_0225", "data_name": "最高血圧上限警報_補液ポンプ_動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "□動作", "item": "□動作"}, {"code": "1", "disp": "■動作", "item": "■動作"}], "data_class": "装置設定", "field_name": "bp_dev_a_0225", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.00", "can_calc": "1", "data_code": "bp_dev_a_0233", "data_name": "最高血圧上限警報_補液ポンプ_速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0233", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■動作", "can_calc": "0", "data_code": "bp_dev_a_0226", "data_name": "最高血圧下限警報_補液ポンプ_動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "□動作", "item": "□動作"}, {"code": "1", "disp": "■動作", "item": "■動作"}], "data_class": "装置設定", "field_name": "bp_dev_a_0226", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.00", "can_calc": "1", "data_code": "bp_dev_a_0234", "data_name": "最高血圧下限警報_補液ポンプ_速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0234", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "成人", "can_calc": "0", "data_code": "bp_dev_a_0191", "data_name": "血圧カフ選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "成人", "item": "成人"}, {"code": "1", "disp": "幼児", "item": "幼児"}], "data_class": "装置設定", "field_name": "bp_dev_a_0191", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30", "can_calc": "1", "data_code": "bp_dev_a_0190", "data_name": "血圧自動測定間隔", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0190", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "180", "can_calc": "1", "data_code": "bp_dev_a_0192", "data_name": "昇圧値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0192", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "手動", "can_calc": "0", "data_code": "bp_dev_a_0193", "data_name": "昇圧方法選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "手動", "item": "手動"}, {"code": "1", "disp": "自動", "item": "自動"}, {"code": "2", "disp": "スマート昇圧", "item": "スマート昇圧"}], "data_class": "装置設定", "field_name": "bp_dev_a_0193", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "降圧設定", "can_calc": "0", "data_code": "bp_dev_a_0195", "data_name": "血圧測定方法選択", "data_type": "string", "conv_table": [{"code": "1", "disp": "降圧測定", "item": "降圧測定"}, {"code": "2", "disp": "昇圧測定", "item": "昇圧測定"}], "data_class": "装置設定", "field_name": "bp_dev_a_0195", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "なし", "can_calc": "0", "data_code": "bp_dev_a_0239", "data_name": "高速測定選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "なし", "item": "なし"}, {"code": "1", "disp": "あり", "item": "あり"}], "data_class": "装置設定", "field_name": "bp_dev_a_0239", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12分", "can_calc": "0", "data_code": "bp_dev_a_0194", "data_name": "血圧連続測定動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "12分", "item": "12分"}, {"code": "1", "disp": "5分", "item": "5分"}], "data_class": "装置設定", "field_name": "bp_dev_a_0194", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2:34", "can_calc": "0", "data_code": "bp_dev_a_0235", "data_name": "警報連動測定開始時間", "data_type": "DateTime", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0235", "disp_format": "[h]:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3:45", "can_calc": "0", "data_code": "bp_dev_a_0236", "data_name": "治療条件連動測定時間", "data_type": "DateTime", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0236", "disp_format": "[h]:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "継続", "can_calc": "0", "data_code": "bp_dev_a_0237", "data_name": "静脈圧警報発生時の血圧測定", "data_type": "string", "conv_table": [{"code": "0", "disp": "継続", "item": "継続"}, {"code": "1", "disp": "中断・終了", "item": "中断・終了"}], "data_class": "装置設定", "field_name": "bp_dev_a_0237", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "継続", "can_calc": "0", "data_code": "bp_dev_a_0238", "data_name": "血流量または除水速度変更時の血圧測定", "data_type": "string", "conv_table": [{"code": "0", "disp": "継続", "item": "継続"}, {"code": "1", "disp": "中断・終了", "item": "中断・終了"}], "data_class": "装置設定", "field_name": "bp_dev_a_0238", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "する", "can_calc": "0", "data_code": "bv_dev_a_0267", "data_name": "BV計使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "しない", "item": "しない"}, {"code": "1", "disp": "する", "item": "する"}], "data_class": "装置設定", "field_name": "bv_dev_a_0267", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-20.0", "can_calc": "1", "data_code": "bv_dev_a_0260", "data_name": "⊿BV低下警報点1", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0260", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-40.0", "can_calc": "1", "data_code": "bv_dev_a_0261", "data_name": "⊿BV低下警報点2", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0261", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-10.0", "can_calc": "1", "data_code": "bv_dev_a_0262", "data_name": "⊿BV変化率警報点", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0262", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.00", "can_calc": "1", "data_code": "bv_dev_a_0277", "data_name": "⊿BV除水低下速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0277", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5", "can_calc": "1", "data_code": "bv_dev_a_0278", "data_name": "⊿BV除水低下遅延時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0278", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "する", "can_calc": "0", "data_code": "bv_dev_a_0258", "data_name": "アクセス再循環測定使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "しない", "item": "しない"}, {"code": "1", "disp": "する", "item": "する"}], "data_class": "装置設定", "field_name": "bv_dev_a_0258", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10:01", "can_calc": "1", "data_code": "bv_dev_a_0259", "data_name": "アクセス再循環自動測定1", "data_type": "DateTime", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0259", "disp_format": "HH:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10:02", "can_calc": "1", "data_code": "bv_dev_a_0263", "data_name": "アクセス再循環自動測定2", "data_type": "DateTime", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0263", "disp_format": "HH:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10:03", "can_calc": "1", "data_code": "bv_dev_a_0264", "data_name": "アクセス再循環自動測定3", "data_type": "DateTime", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0264", "disp_format": "HH:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10:04", "can_calc": "1", "data_code": "bv_dev_a_0265", "data_name": "アクセス再循環自動測定4", "data_type": "DateTime", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0265", "disp_format": "HH:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10:05", "can_calc": "1", "data_code": "bv_dev_a_0266", "data_name": "アクセス再循環自動測定5", "data_type": "DateTime", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0266", "disp_format": "HH:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用する", "can_calc": "0", "data_code": "dfas_dev_a_0270", "data_name": "動脈側返血使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "dfas_dev_a_0270", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30", "can_calc": "1", "data_code": "bv_dev_a_0281", "data_name": "アクセス再循環再循環率報知", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0281", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "pri_pat_a_0219", "data_name": "プライミング補助動脈充填液量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0219", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "pri_pat_a_0220", "data_name": "プライミング補助動脈充填流速", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0220", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "しない", "can_calc": "0", "data_code": "pri_pat_a_0225", "data_name": "プライミング補助動脈充填後継続の有無", "data_type": "string", "conv_table": [{"code": "0", "disp": "しない", "item": "しない"}, {"code": "1", "disp": "する", "item": "する"}], "data_class": "装置設定", "field_name": "pri_pat_a_0225", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "pri_pat_a_0221", "data_name": "プライミング補助静脈充填液量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0221", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "pri_pat_a_0222", "data_name": "プライミング補助静脈充填流速", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0222", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "しない", "can_calc": "0", "data_code": "pri_pat_a_0226", "data_name": "プライミング補助静脈充填後継続の有無", "data_type": "string", "conv_table": [{"code": "0", "disp": "しない", "item": "しない"}, {"code": "1", "disp": "する", "item": "する"}], "data_class": "装置設定", "field_name": "pri_pat_a_0226", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "400", "can_calc": "1", "data_code": "pri_pat_a_0223", "data_name": "プライミング補助気泡抜き液量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0223", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "pri_pat_a_0224", "data_name": "プライミング補助気泡抜き流速", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0224", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "連続", "can_calc": "0", "data_code": "pri_pat_a_0227", "data_name": "プライミング補助気泡抜き間欠動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "連続", "item": "連続"}, {"code": "1", "disp": "間欠", "item": "間欠"}], "data_class": "装置設定", "field_name": "pri_pat_a_0227", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "800", "can_calc": "1", "data_code": "pri_pat_a_0228", "data_name": "プライミング補助液交換量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0228", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.0", "can_calc": "1", "data_code": "pri_pat_a_0229", "data_name": "プライミング補助間欠動作動作時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0229", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.0", "can_calc": "1", "data_code": "pri_pat_a_0230", "data_name": "プライミング補助間欠動作停止時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0230", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "40", "can_calc": "1", "data_code": "pri_pat_a_0232", "data_name": "自動プライミング落差時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0232", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "pri_pat_a_0238", "data_name": "自動プライミング総量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0238", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "420", "can_calc": "1", "data_code": "pri_pat_a_0231", "data_name": "自動プライミング開始時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0231", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "250", "can_calc": "1", "data_code": "pri_pat_a_0233", "data_name": "自動プライミング送液液量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0233", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "250", "can_calc": "1", "data_code": "pri_pat_a_0234", "data_name": "自動プライミング送液流速1回目", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0234", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "250", "can_calc": "1", "data_code": "pri_pat_a_0235", "data_name": "自動プライミング送液流速2回目以降", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0235", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "400", "can_calc": "1", "data_code": "pri_pat_a_0236", "data_name": "自動プライミング循環流速", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0236", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "pri_pat_a_0237", "data_name": "自動プライミング循環時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0237", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "pri_dev_a_0370", "data_name": "自動回収_使用液量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_dev_a_0370", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "pri_dev_a_0371", "data_name": "自動回収_流速", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_dev_a_0371", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "OFF", "can_calc": "0", "data_code": "pri_dev_a_0372", "data_name": "自動回収_血液判別器による終了選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "OFF", "item": "OFF"}, {"code": "1", "disp": "ON", "item": "ON"}], "data_class": "装置設定", "field_name": "pri_dev_a_0372", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2", "can_calc": "1", "data_code": "pri_pat_b_0051", "data_name": "オンラインプライミング_ダイアライザ気泡抜き時間_後補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_b_0051", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "90", "can_calc": "1", "data_code": "pri_pat_b_0032", "data_name": "オンラインプライミング_動脈チャンバ液面作成時間_前補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_b_0032", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "pri_pat_b_0052", "data_name": "オンラインプライミング_動脈チャンバ液面作成時間_後補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_b_0052", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3", "can_calc": "1", "data_code": "pri_pat_b_0033", "data_name": "オンラインプライミング_循環洗浄時間_前補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_b_0033", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3", "can_calc": "1", "data_code": "pri_pat_b_0053", "data_name": "オンラインプライミング_循環洗浄時間_後補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_b_0053", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "切り", "can_calc": "0", "data_code": "ufr_dev_a_0290", "data_name": "UFRプログラム使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "切り", "item": "切り"}, {"code": "1", "disp": "入り[ステップ]", "item": "入り[ステップ]"}, {"code": "2", "disp": "入り[コース]", "item": "入り[コース]"}], "data_class": "装置設定", "field_name": "ufr_dev_a_0290", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "切り", "can_calc": "0", "data_code": "na_dev_a_0315", "data_name": "Na注入プログラム使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "切り", "item": "切り"}, {"code": "1", "disp": "入り[ステップ]", "item": "入り[ステップ]"}, {"code": "2", "disp": "入り[コース]", "item": "入り[コース]"}], "data_class": "装置設定", "field_name": "na_dev_a_0315", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "na_dev_a_0184", "data_name": "Na注入濃度最大値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "na_dev_a_0184", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "切り", "can_calc": "0", "data_code": "dc_dev_a_0340", "data_name": "透析液濃度プログラム使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "切り", "item": "切り"}, {"code": "1", "disp": "入り[B,A共通ステップ]", "item": "入り[B,A共通ステップ]"}, {"code": "2", "disp": "入り[B,A別ステップ]", "item": "入り[B,A別ステップ]"}, {"code": "3", "disp": "入り[B,A別コース]", "item": "入り[B,A別コース]"}], "data_class": "装置設定", "field_name": "dc_dev_a_0340", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "HD", "can_calc": "0", "data_code": "ecum_dev_a_0016", "data_name": "ECUM選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "HD", "item": "HD"}, {"code": "1", "disp": "ECUM", "item": "ECUM"}], "data_class": "装置設定", "field_name": "ecum_dev_a_0016", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.00", "can_calc": "1", "data_code": "ecum_dev_a_0017", "data_name": "ECUM量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ecum_dev_a_0017", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "07:59", "can_calc": "1", "data_code": "ecum_dev_a_0018", "data_name": "ECUM時間", "data_type": "DateTime", "conv_table": [], "data_class": "装置設定", "field_name": "ecum_dev_a_0018", "disp_format": "HH:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "HD", "can_calc": "0", "data_code": "ecum_dev_a_0019", "data_name": "ECUM時間カウント選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "透析時間に含まない", "item": "透析時間に含まない"}, {"code": "1", "disp": "透析時間に含む", "item": "透析時間に含む"}], "data_class": "装置設定", "field_name": "ecum_dev_a_0019", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.0", "can_calc": "1", "data_code": "cpro_dev_a_0252", "data_name": "Ｂ液濃度プログラム自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "cpro_dev_a_0252", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-5.0", "can_calc": "1", "data_code": "cpro_dev_a_0253", "data_name": "Ｂ液濃度プログラム自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "cpro_dev_a_0253", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.0", "can_calc": "1", "data_code": "cpro_dev_a_0250", "data_name": "透析液濃度プログラム自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "cpro_dev_a_0250", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-5.0", "can_calc": "1", "data_code": "cpro_dev_a_0251", "data_name": "透析液濃度プログラム自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "cpro_dev_a_0251", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "0", "data_code": "dfas_pat_b_0001", "data_name": "IPラインプライミング使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "dfas_pat_b_0001", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5", "can_calc": "1", "data_code": "gas_purge_time", "data_name": "ガスパージ時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "gas_purge_time", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1000", "can_calc": "1", "data_code": "substituent_wash_amt", "data_name": "置換洗浄量（透析液）", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "substituent_wash_amt", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "0", "data_code": "membrane_wash", "data_name": "膜洗浄（中空糸）", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "membrane_wash", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "dfas_pat_b_0005", "data_name": "中空糸_プライミング時のBP速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0005", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "dfas_pat_b_0007", "data_name": "中空糸_送液最大時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0007", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "dfas_pat_b_0008", "data_name": "中空糸_回路内洗浄送液量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0008", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "dfas_pat_b_0009", "data_name": "中空糸_気泡抜き動作実行回数", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0009", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "150", "can_calc": "1", "data_code": "dfas_pat_b_0010", "data_name": "中空糸_気泡抜き圧力上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0010", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "150", "can_calc": "1", "data_code": "dfas_pat_b_0059", "data_name": "積層_プライミング時のBP速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0059", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "dfas_pat_b_0054", "data_name": "積層_送液最大時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0054", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "dfas_pat_b_0055", "data_name": "積層_回路内洗浄送液量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0055", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "dfas_pat_b_0056", "data_name": "積層_気泡抜き動作実行回数", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0056", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "150", "can_calc": "1", "data_code": "dfas_pat_b_0057", "data_name": "積層_気泡抜き圧力上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0057", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.20", "can_calc": "1", "data_code": "dfas_pat_b_0058", "data_name": "積層_除水ポンプ速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0058", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "片側脱血（除水なし）", "can_calc": "0", "data_code": "dfas_dev_a_0339", "data_name": "脱血方法選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "同時脱血", "item": "同時脱血"}, {"code": "1", "disp": "片側脱血（除水あり）", "item": "片側脱血（除水あり）"}, {"code": "2", "disp": "片側脱血（除水なし）", "item": "片側脱血（除水なし）"}], "data_class": "装置設定", "field_name": "dfas_dev_a_0339", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "dfas_dev_a_0333", "data_name": "脱血速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_dev_a_0333", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "150", "can_calc": "1", "data_code": "dfas_dev_a_0331", "data_name": "同時脱血_脱血量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_dev_a_0331", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "150", "can_calc": "1", "data_code": "dfas_dev_a_0334", "data_name": "片側脱血(除水なし)_脱血量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_dev_a_0334", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "dfas_dev_a_0338", "data_name": "片側脱血（除水あり）_脱血量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_dev_a_0338", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-200", "can_calc": "1", "data_code": "dfas_dev_a_0332", "data_name": "片側脱血への切替え透析液圧", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_dev_a_0332", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "ord_treat_condition_335", "data_name": "治療開始時_血液ポンプ速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ord_treat_condition_335", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "dfas_dev_a_0373", "data_name": "静脈側返血速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_dev_a_0373", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "250", "can_calc": "1", "data_code": "dfas_dev_a_0374", "data_name": "静脈側最大返血量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_dev_a_0374", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "0", "data_code": "dfas_dev_a_0377", "data_name": "静脈側返血_血液判別器使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "dfas_dev_a_0377", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30", "can_calc": "1", "data_code": "dfas_dev_a_0376", "data_name": "動脈側最大返血量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_dev_a_0376", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "0", "data_code": "dfas_dev_a_0378", "data_name": "動脈側返血_血液判別器使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "dfas_dev_a_0378", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "ord_treat_condition_287", "data_name": "KoA", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ord_treat_condition_287", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.1", "can_calc": "1", "data_code": "dia_dev_a_0288", "data_name": "目標Kt/V", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dia_dev_a_0288", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "190", "can_calc": "1", "data_code": "ord_treat_condition_187", "data_name": "ダイアライザ 尿素クリアランス", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ord_treat_condition_187", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "ord_treat_condition_188", "data_name": "ダイアライザ 血流量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ord_treat_condition_188", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "ord_treat_condition_189", "data_name": "ダイアライザ 透析液流量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ord_treat_condition_189", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用する", "can_calc": "0", "data_code": "bvufc_dev_a_0196", "data_name": "BV-UFC使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "bvufc_dev_a_0196", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.00", "can_calc": "1", "data_code": "bvufc_dev_a_0197", "data_name": "UFC期間除水速度上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0197", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.00", "can_calc": "1", "data_code": "bvufc_dev_a_0198", "data_name": "UFC期間除水速度下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0198", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "1", "data_code": "bvufc_dev_a_0199", "data_name": "開始期間 時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0199", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.00", "can_calc": "1", "data_code": "bvufc_dev_a_0206", "data_name": "開始期間 除水速度倍率", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0206", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "bvufc_dev_a_0207", "data_name": "固定倍率除水期間 時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0207", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.30", "can_calc": "1", "data_code": "bvufc_dev_a_0208", "data_name": "固定倍率除水期間 除水速度倍率", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0208", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "bvufc_dev_a_0209", "data_name": "固定倍率除水終了条件　最高血圧", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0209", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "bvufc_dev_a_0210", "data_name": "固定倍率除水終了条件　脈拍", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0210", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.0", "can_calc": "1", "data_code": "bvufc_dev_a_0248", "data_name": "固定倍率除水終了条件　ΔBV", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0248", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20", "can_calc": "1", "data_code": "bvufc_dev_a_0249", "data_name": "終了前期間 時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0249", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "流量設定", "can_calc": "0", "data_code": "ope_dev_a_0268", "data_name": "透析液流量　設定方法", "data_type": "string", "conv_table": [{"code": "1", "disp": "流量設定", "item": "流量設定"}, {"code": "2", "disp": "比率設定", "item": "比率設定"}], "data_class": "装置設定", "field_name": "ope_dev_a_0268", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.0", "can_calc": "1", "data_code": "ope_dev_a_0269", "data_name": "透析液流量　比率設定", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0269", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.0", "can_calc": "1", "data_code": "bvufc_dev_a_0271", "data_name": "開始時ΔBV基準値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0271", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "bvufc_dev_a_0272", "data_name": "ΔBV基準線　指数1", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0272", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "80", "can_calc": "1", "data_code": "bvufc_dev_a_0273", "data_name": "ΔBV基準線　指数2", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0273", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "95", "can_calc": "1", "data_code": "bvufc_dev_a_0274", "data_name": "ΔBV基準線　指数3", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0274", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-4.0", "can_calc": "1", "data_code": "bvufc_dev_a_0275", "data_name": "終了時ΔBV基準値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0275", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "qbqd_dev_a_0400", "data_name": "QBプログラム血流量1", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0400", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "160", "can_calc": "1", "data_code": "qbqd_dev_a_0401", "data_name": "QBプログラム血流量2", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0401", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "qbqd_dev_a_0402", "data_name": "QBプログラム血流量3", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0402", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "qbqd_dev_a_0403", "data_name": "QBプログラム血流量4", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0403", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "qbqd_dev_a_0404", "data_name": "QBプログラム血流量5", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0404", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "qbqd_dev_a_0405", "data_name": "QBプログラム血流量6", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0405", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "qbqd_dev_a_0406", "data_name": "QBプログラム血流量7", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0406", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "qbqd_dev_a_0407", "data_name": "QBプログラム血流量8", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0407", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "qbqd_dev_a_0408", "data_name": "QBプログラム血流量9", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0408", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "qbqd_dev_a_0409", "data_name": "QBプログラム血流量10", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0409", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "qbqd_dev_a_0410", "data_name": "QDプログラム透析液流量1", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0410", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "400", "can_calc": "1", "data_code": "qbqd_dev_a_0411", "data_name": "QDプログラム透析液流量2", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0411", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "qbqd_dev_a_0412", "data_name": "QDプログラム透析液流量3", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0412", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "qbqd_dev_a_0413", "data_name": "QDプログラム透析液流量4", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0413", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "qbqd_dev_a_0414", "data_name": "QDプログラム透析液流量5", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0414", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "qbqd_dev_a_0415", "data_name": "QDプログラム透析液流量6", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0415", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "qbqd_dev_a_0416", "data_name": "QDプログラム透析液流量7", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0416", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "qbqd_dev_a_0417", "data_name": "QDプログラム透析液流量8", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0417", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "qbqd_dev_a_0418", "data_name": "QDプログラム透析液流量9", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0418", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "qbqd_dev_a_0419", "data_name": "QDプログラム透析液流量10", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0419", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "qbqd_dev_a_0420", "data_name": "QB、QDプログラム切替時間1", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0420", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "qbqd_dev_a_0421", "data_name": "QB、QDプログラム切替時間2", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0421", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "qbqd_dev_a_0422", "data_name": "QB、QDプログラム切替時間3", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0422", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "qbqd_dev_a_0423", "data_name": "QB、QDプログラム切替時間4", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0423", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "qbqd_dev_a_0424", "data_name": "QB、QDプログラム切替時間5", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0424", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "qbqd_dev_a_0425", "data_name": "QB、QDプログラム切替時間6", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0425", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "qbqd_dev_a_0426", "data_name": "QB、QDプログラム切替時間7", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0426", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "qbqd_dev_a_0427", "data_name": "QB、QDプログラム切替時間8", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0427", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "qbqd_dev_a_0428", "data_name": "QB、QDプログラム切替時間9", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0428", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3", "can_calc": "1", "data_code": "qbqd_dev_a_0429", "data_name": "QB、QDプログラム最大ステップ数", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0429", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "切", "can_calc": "0", "data_code": "qbqd_dev_a_0430", "data_name": "QBプログラム電源", "data_type": "string", "conv_table": [{"code": "0", "disp": "切", "item": "切"}, {"code": "1", "disp": "入", "item": "入"}], "data_class": "装置設定", "field_name": "qbqd_dev_a_0430", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "切", "can_calc": "0", "data_code": "qbqd_dev_a_0431", "data_name": "QDプログラム電源", "data_type": "string", "conv_table": [{"code": "0", "disp": "切", "item": "切"}, {"code": "1", "disp": "入", "item": "入"}], "data_class": "装置設定", "field_name": "qbqd_dev_a_0431", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "0", "data_code": "ihdf_dev_a_0432", "data_name": "I-HDFプログラム使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "ihdf_dev_a_0432", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7", "can_calc": "1", "data_code": "ihdf_dev_a_0433", "data_name": "予定補液回数", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0433", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0434", "data_name": "補液バランス制限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0434", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0435", "data_name": "補液量01", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0435", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0436", "data_name": "補液量02", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0436", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0437", "data_name": "補液量03", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0437", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0438", "data_name": "補液量04", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0438", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0439", "data_name": "補液量05", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0439", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0440", "data_name": "補液量06", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0440", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0441", "data_name": "補液量07", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0441", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0442", "data_name": "補液量08", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0442", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0443", "data_name": "補液量09", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0443", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0444", "data_name": "補液量10", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0444", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0445", "data_name": "補液量11", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0445", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0446", "data_name": "補液量12", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0446", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0447", "data_name": "補液量13", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0447", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0448", "data_name": "補液量14", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0448", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0449", "data_name": "補液量15", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0449", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0450", "data_name": "補液量16", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0450", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0451", "data_name": "回収量01", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0451", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0452", "data_name": "回収量02", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0452", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0453", "data_name": "回収量03", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0453", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0454", "data_name": "回収量04", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0454", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0455", "data_name": "回収量05", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0455", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0456", "data_name": "回収量06", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0456", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0457", "data_name": "回収量07", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0457", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0458", "data_name": "回収量08", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0458", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0459", "data_name": "回収量09", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0459", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0460", "data_name": "回収量10", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0460", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0461", "data_name": "回収量11", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0461", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0462", "data_name": "回収量12", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0462", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0463", "data_name": "回収量13", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0463", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0464", "data_name": "回収量14", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0464", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0465", "data_name": "回収量15", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0465", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0466", "data_name": "回収量16", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0466", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]'::jsonb,'0','{"applications": [1]}'::jsonb,'{"classes": [1, 2, 3, 9, 10, 11]}'::jsonb,'実績：装置設定 @ordNo 使用','2020-03-31 23:59:59',CURRENT_TIMESTAMP,NULL);

INSERT INTO ntss.sys_data_set (sql_cd, "sql",db_class,detail,can_repeat,use_application,report_class,memo,reg_date,up_date,pre_sql_info) VALUES
	 (170, 'WITH DATA AS (

with latest_otc as(
  select * from ord_treat_condition where (ord_no, up_date) in (select ord_no, max(up_date) from ord_treat_condition where ord_no = @ordNo and is_del = ''0'' and is_disp = ''1'' group by ord_no)
)
, dialyzer_record as(
  select gas_purge_time, substituent_wash_amt, membrane_wash
  from
    ord_main
    inner join (select * from mst_dialyzer where is_del = ''0'' and is_disp = ''1'' and dialyzer_cd IN (@diaIds)) as mst_dialyzer
      on (ord_main.rst_cond_info#>>''{5, value}'')::text = mst_dialyzer.dialyzer_cd::text
  where
    ord_no = @ordNo and ord_main.is_del = ''0''
    and ord_main.rst_dialysis_state >''0'' and ord_main.rst_dialysis_state <''6''
)

select
  ord_main.ord_no as ord_no_t
	,null as ope_dev_a_0179 -- 血流量設定最大値
  ,null as ope_dev_a_0181 -- 除水速度制限
  ,null as ope_dev_a_0038 -- 動脈側気泡検出器
  ,null as ope_dev_a_0021 -- 除水計算時間
  ,null as ope_dev_a_0022 -- 除水計算優先項目
  ,null as ope_dev_a_0039 -- 除水開始遅延時間
  ,null as ope_dev_a_0182 -- 透析液温度操作範囲上限
  ,null as ope_dev_a_0183 -- 透析液温度操作範囲下限
  ,null as ope_dev_a_0024 -- シングルニードル切替圧上限
  ,null as ope_dev_a_0025 -- シングルニードル切替圧下限
  ,null as ope_dev_a_0241 -- TMPゼロ補正
  ,null as ope_dev_a_0168 -- HD補正警報上限値
  ,null as ope_dev_a_0169 -- HD補正警報下限値
  ,null as ope_dev_a_0171 -- ECUM補正警報上限値
  ,null as ope_dev_a_0172 -- ECUM補正警報下限値
  ,null as ope_dev_a_0174 -- HDF補正警報上限値
  ,null as ope_dev_a_0175 -- HDF補正警報下限値
  ,null as ope_dev_a_0177 -- HF補正警報上限値
  ,null as ope_dev_a_0178 -- HF補正警報下限値
  ,null as ope_dev_b_0037 -- HD+補液補正警報上限値
  ,null as ope_dev_b_0038 -- HD+補液補正警報下限値
  ,null as ope_dev_a_0391 -- OHDF補正警報上限値
  ,null as ope_dev_a_0392 -- OHDF補正警報下限値
  ,null as ope_dev_a_0394 -- OHF補正警報上限値
  ,null as ope_dev_a_0395 -- OHF補正警報下限値
  ,null as ope_dev_a_0383 -- 補液量制限
  ,null as ope_dev_a_0389 -- 補液計算優先項目
  ,null as ope_dev_a_0379 -- 補液比率（前補液）
  ,null as ope_dev_b_0039 -- 補液比率（後補液）
  ,null as ope_dev_a_0398 -- 補液開始遅延時間
  ,null as ope_dev_a_0369 -- DP=Qd+Qs(補液速度加算)
  ,null as ope_dev_a_0090 -- 濾過率（前補液）
  ,null as ope_dev_b_0040 -- 濾過率（後補液）
  ,null as ope_dev_a_0091 -- ヘマトクリット（Ht）
  ,null as ope_dev_a_0092 -- 総タンパク（TP）
  ,null as ope_dev_a_0336 -- 緊急補液速度
  ,null as ope_dev_a_0337 -- 緊急補液量
  ,null as ope_dev_a_0185 -- HDF速度操作範囲上限前補液
  ,null as ope_dev_b_0031 -- HDF速度操作範囲上限後補液
  ,null as ope_dev_a_0186 -- HF速度操作範囲上限前補液
  ,null as ope_dev_b_0032 -- HF速度操作範囲上限後補液
  ,null as ope_dev_b_0030 -- HD+補液速度操作範囲上限前補液
  ,null as ope_dev_b_0033 -- HD+補液速度操作範囲上限後補液
  ,null as ope_dev_a_0396 -- OHDF速度操作範囲上限前補液
  ,null as ope_dev_b_0034 -- OHDF速度操作範囲上限後補液
  ,null as ope_dev_a_0397 -- OHF速度操作範囲上限前補液
  ,null as ope_dev_b_0035 -- OHF速度操作範囲上限後補液
  ,null as ope_dev_a_0384 -- AFBF補液比率使用選択
  ,null as ope_dev_a_0385 -- AFBF補液比率
  ,null as ope_dev_a_0386 -- AFBF速度操作範囲上限
  ,null as ope_dev_a_0387 -- AFBF速度操作範囲下限
  ,null as ihdf_dev_a_0200 -- I-HDF_補液量設定
  ,null as ihdf_dev_a_0201 -- I-HDF_補液速度
  ,null as ihdf_dev_a_0202 -- I-HDF_補液周期
  ,null as ihdf_dev_a_0203 -- I-HDF_補液開始時間
  ,null as ihdf_dev_a_0204 -- I-HDF_除水再開時間
  ,null as ihdf_dev_a_0205 -- I-HDF_総補液量上限
  ,null as blood_flow_judge --ホスト監視血流量監視フラグ
  ,null as blood_flow_upper --ホスト監視血流量上限
  ,null as blood_flow_lower --ホスト監視血流量下限
  ,null as ip_speed_judge --ホスト監視IP速度監視フラグ
  ,null as ip_speed_upper --ホスト監視IP速度上限
  ,null as ip_speed_lower --ホスト監視IP速度下限
  ,null as ufr_judge --ホスト監視除水速度監視フラグ
  ,null as ufr_upper --ホスト監視除水速度上限
  ,null as ufr_lower --ホスト監視除水速度下限
  ,null as bp_max_judge --ホスト監視最高血圧監視フラグ
  ,null as bp_max_upper --ホスト監視最高血圧上限
  ,null as bp_max_lower --ホスト監視最高血圧下限
  ,null as bp_min_judge --ホスト監視最低血圧監視フラグ
  ,null as bp_min_upper --ホスト監視最低血圧上限
  ,null as bp_min_lower --ホスト監視最低血圧下限
  ,null as bp_ave_judge --ホスト監視平均血圧監視フラグ
  ,null as bp_ave_upper --ホスト監視平均血圧上限
  ,null as bp_ave_lower --ホスト監視平均血圧下限
  ,null as pulse_judge --ホスト監視脈拍監視フラグ
  ,null as pulse_upper --ホスト監視脈拍上限
  ,null as pulse_lower --ホスト監視脈拍下限
  ,null as vp_judge --ホスト監視静脈圧監視フラグ
  ,null as vp_upper --ホスト監視静脈圧上限
  ,null as vp_lower --ホスト監視静脈圧下限
  ,null as rst_ap_judge --ホスト監視動脈圧監視フラグ
  ,null as rst_ap_upper --ホスト監視動脈圧上限
  ,null as rst_ap_lower --ホスト監視動脈圧下限
  ,null as na_conc_judge --ホスト監視Na濃度監視フラグ
  ,null as na_conc_upper --ホスト監視Na濃度上限
  ,null as na_conc_lower --ホスト監視Na濃度下限
  ,null as dialys_temp_judge --ホスト監視透析液温度監視フラグ
  ,null as dialys_temp_upper --ホスト監視透析液温度上限
  ,null as dialys_temp_lower --ホスト監視透析液温度下限
  ,null as care_i_judge --ホスト監視血圧未測定時報知監視フラグ
  ,null as care_i_interval --ホスト監視ケア報知
  ,null as war_dev_a_0240 -- TMP監視モード
  ,null as war_dev_a_0100 -- HD/ECUM静脈圧自動設定警報幅上限
  ,null as war_dev_a_0101 -- HD/ECUM静脈圧自動設定警報幅下限
  ,null as war_dev_a_0102 -- HD/ECUM静脈圧自動設定警報限界上限
  ,null as war_dev_a_0103 -- HD/ECUM静脈圧自動設定警報限界下限
  ,null as war_dev_a_0104 -- HD/ECUM静脈圧固定警報上限
  ,null as war_dev_a_0105 -- HD/ECUM静脈圧固定警報下限
  ,null as war_dev_a_0152 -- HD/ECUMダイアライザ入口圧自動設定警報幅上限
  ,null as war_dev_a_0153 -- HD/ECUMダイアライザ入口圧自動設定警報幅下限
  ,null as war_dev_a_0154 -- HD/ECUMダイアライザ入口圧自動設定警報限界上限
  ,null as war_dev_a_0155 -- HD/ECUMダイアライザ入口圧自動設定警報限界下限
  ,null as war_dev_a_0156 -- HD/ECUMダイアライザ入口圧固定警報上限
  ,null as war_dev_a_0157 -- HD/ECUMダイアライザ入口圧固定警報下限
  ,null as war_dev_a_0112 -- HD/ECUM液圧自動設定警報幅上限
  ,null as war_dev_a_0113 -- HD/ECUM液圧自動設定警報幅下限
  ,null as war_dev_a_0114 -- HD/ECUM液圧自動設定警報限界上限
  ,null as war_dev_a_0115 -- HD/ECUM液圧自動設定警報限界下限
  ,null as war_dev_a_0116 -- HD/ECUM液圧固定警報上限
  ,null as war_dev_a_0117 -- HD/ECUM液圧固定警報下限
  ,null as war_dev_a_0128 -- HD/ECUMTMP自動設定警報幅上限
  ,null as war_dev_a_0129 -- HD/ECUMTMP自動設定警報幅下限
  ,null as war_dev_a_0130 -- HD/ECUMTMP自動設定警報限界上限
  ,null as war_dev_a_0131 -- HD/ECUMTMP自動設定警報限界下限
  ,null as war_dev_a_0132 -- HD/ECUMTMP固定警報上限
  ,null as war_dev_a_0133 -- HD/ECUMTMP固定警報下限
  ,null as war_dev_a_0126 -- HD/ECUMTMP自動追従警報幅上限
  ,null as war_dev_a_0127 -- HD/ECUMTMP自動追従警報幅下限
  ,null as war_dev_a_0146 -- HD/ECUMダイアライザ差圧自動設定警報幅上限
  ,null as war_dev_a_0147 -- HD/ECUMダイアライザ差圧自動設定警報幅下限
  ,null as war_dev_a_0148 -- HD/ECUMダイアライザ差圧固定警報上限
  ,null as war_dev_a_0149 -- HD/ECUMダイアライザ差圧固定警報下限
  ,null as war_dev_a_0106 -- HDF/HF静脈圧自動設定警報幅上限
  ,null as war_dev_a_0107 -- HDF/HF静脈圧自動設定警報幅下限
  ,null as war_dev_a_0158 -- HDF/HFダイアライザ入口圧自動設定警報幅上限
  ,null as war_dev_a_0159 -- HDF/HFダイアライザ入口圧自動設定警報幅下限
  ,null as war_dev_a_0118 -- HDF/HF液圧自動設定警報幅上限
  ,null as war_dev_a_0119 -- HDF/HF液圧自動設定警報幅下限
  ,null as war_dev_a_0136 -- HDF/HFTMP自動設定警報幅上限
  ,null as war_dev_a_0137 -- HDF/HFTMP自動設定警報幅下限
  ,null as war_dev_a_0134 -- HDF/HFTMP自動追従警報幅上限
  ,null as war_dev_a_0135 -- HDF/HFTMP自動追従警報幅下限
  ,null as war_dev_a_0150 -- HDF/HFダイアライザ差圧自動設定警報幅上限
  ,null as war_dev_a_0151 -- HDF/HFダイアライザ差圧自動設定警報幅下限
  ,null as war_dev_a_0110 -- SN静脈圧固定警報上限
  ,null as war_dev_a_0111 -- SN静脈圧固定警報下限
  ,null as war_dev_a_0162 -- SNダイアライザ入口圧固定警報上限
  ,null as war_dev_a_0163 -- SNダイアライザ入口圧固定警報下限
  ,null as war_dev_a_0120 -- SN液圧自動設定警報幅上限
  ,null as war_dev_a_0121 -- SN液圧自動設定警報幅下限
  ,null as war_dev_a_0122 -- SN液圧自動設定警報限界上限
  ,null as war_dev_a_0123 -- SN液圧自動設定警報限界下限
  ,null as war_dev_a_0124 -- SN液圧固定警報上限
  ,null as war_dev_a_0125 -- SN液圧固定警報下限
  ,null as war_dev_a_0140 -- SNTMP自動設定警報幅上限
  ,null as war_dev_a_0141 -- SNTMP自動設定警報幅下限
  ,null as war_dev_a_0142 -- SNTMP自動設定警報限界上限
  ,null as war_dev_a_0143 -- SNTMP自動設定警報限界下限
  ,null as war_dev_a_0144 -- SNTMP固定警報上限
  ,null as war_dev_a_0145 -- SNTMP固定警報下限
  ,null as war_dev_a_0138 -- SNTMP自動追従警報幅上限
  ,null as war_dev_a_0139 -- SNTMP自動追従警報幅下限
  ,null as war_dev_a_0108 -- 準備回収静脈圧固定警報上限
  ,null as war_dev_a_0109 -- 準備回収静脈圧固定警報下限
  ,null as war_dev_a_0160 -- 準備回収ダイアライザ入口圧固定警報上限
  ,null as war_dev_a_0161 -- 準備回収ダイアライザ入口圧固定警報下限
  ,null as war_dev_a_0254 -- Na濃度自動警報幅上限値
  ,null as war_dev_a_0255 -- Na濃度自動警報幅下限値
  ,null as war_dev_a_0256 -- Na濃度固定警報幅上限値
  ,null as war_dev_a_0257 -- Na濃度固定警報幅下限値
  ,null as bp_dev_a_0211 -- 血圧警報点最高血圧上限
  ,null as bp_dev_a_0212 -- 血圧警報点最高血圧下限
  ,null as bp_dev_a_0213 -- 血圧警報点最低血圧上限
  ,null as bp_dev_a_0214 -- 血圧警報点最低血圧下限
  ,null as bp_dev_a_0215 -- 血圧警報点平均血圧上限
  ,null as bp_dev_a_0216 -- 血圧警報点平均血圧下限
  ,null as bp_dev_a_0217 -- 血圧警報点脈拍数上限
  ,null as bp_dev_a_0218 -- 血圧警報点脈拍数下限
  ,null as bp_dev_a_0219 -- 最高血圧上限警報_血液ポンプ_動作選択
  ,null as bp_dev_a_0227 -- 最高血圧上限警報_血液ポンプ_速度
  ,null as bp_dev_a_0220 -- 最高血圧下限警報_血液ポンプ_動作選択
  ,null as bp_dev_a_0228 -- 最高血圧下限警報_血液ポンプ_速度
  ,null as bp_dev_a_0221 -- 最高血圧上限警報_除水ポンプ_動作選択
  ,null as bp_dev_a_0229 -- 最高血圧上限警報_除水ポンプ_速度
  ,null as bp_dev_a_0222 -- 最高血圧下限警報_除水ポンプ_動作選択
  ,null as bp_dev_a_0230 -- 最高血圧下限警報_除水ポンプ_速度
  ,null as bp_dev_a_0223 -- 最高血圧上限警報_Na注入ポンプ_動作選択
  ,null as bp_dev_a_0231 -- 最高血圧上限警報_Na注入ポンプ_速度
  ,null as bp_dev_a_0224 -- 最高血圧下限警報_Na注入ポンプ_動作選択
  ,null as bp_dev_a_0225 -- 最高血圧上限警報_補液ポンプ_動作選択
  ,null as bp_dev_a_0233 -- 最高血圧上限警報_補液ポンプ_速度
  ,null as bp_dev_a_0226 -- 最高血圧下限警報_補液ポンプ_動作選択
  ,null as bp_dev_a_0234 -- 最高血圧下限警報_補液ポンプ_速度
  ,null as bp_dev_a_0191 -- 血圧カフ選択
  ,null as bp_dev_a_0190 -- 血圧自動測定間隔
  ,null as bp_dev_a_0192 -- 昇圧値
  ,null as bp_dev_a_0193 -- 昇圧方法選択
  ,null as bp_dev_a_0195 -- 血圧測定方法選択
  ,null as bp_dev_a_0239 -- 高速測定選択
  ,null as bp_dev_a_0194 -- 血圧連続測定動作選択
  ,null as bp_dev_a_0235 -- 警報連動測定開始時間
  ,null as bp_dev_a_0236 -- 治療条件連動測定時間
  ,null as bp_dev_a_0237 -- 静脈圧警報発生時の血圧測定
  ,null as bp_dev_a_0238 -- 血流量または除水速度変更時の血圧測定
  ,null as bv_dev_a_0267 -- BV計使用選択
  ,null as bv_dev_a_0260 -- ⊿BV低下警報点1
  ,null as bv_dev_a_0261 -- ⊿BV低下警報点2
  ,null as bv_dev_a_0262 -- ⊿BV変化率警報点
  ,null as bv_dev_a_0277 -- ⊿BV除水低下速度
  ,null as bv_dev_a_0278 -- ⊿BV除水低下遅延時間
  ,null as bv_dev_a_0258 -- アクセス再循環測定使用選択
  ,null as bv_dev_a_0259 -- アクセス再循環自動測定1
  ,null as bv_dev_a_0263 -- アクセス再循環自動測定2
  ,null as bv_dev_a_0264 -- アクセス再循環自動測定3
  ,null as bv_dev_a_0265 -- アクセス再循環自動測定4
  ,null as bv_dev_a_0266 -- アクセス再循環自動測定5
  ,null as dfas_dev_a_0270 -- 動脈側返血使用選択
  ,null as bv_dev_a_0281 -- アクセス再循環再循環率報知
  ,null as pri_pat_a_0219 -- プライミング補助動脈充填液量
  ,null as pri_pat_a_0220 -- プライミング補助動脈充填流速
  ,null as pri_pat_a_0225 -- プライミング補助動脈充填後継続の有無
  ,null as pri_pat_a_0221 -- プライミング補助静脈充填液量
  ,null as pri_pat_a_0222 -- プライミング補助静脈充填流速
  ,null as pri_pat_a_0226 -- プライミング補助静脈充填後継続の有無
  ,null as pri_pat_a_0223 -- プライミング補助気泡抜き液量
  ,null as pri_pat_a_0224 -- プライミング補助気泡抜き流速
  ,null as pri_pat_a_0227 -- プライミング補助気泡抜き間欠動作選択
  ,null as pri_pat_a_0228 -- プライミング補助液交換量
  ,null as pri_pat_a_0229 -- プライミング補助間欠動作動作時間
  ,null as pri_pat_a_0230 -- プライミング補助間欠動作停止時間
  ,null as pri_pat_a_0232 -- 自動プライミング落差時間
  ,null as pri_pat_a_0238 -- 自動プライミング総量
  ,null as pri_pat_a_0231 -- 自動プライミング開始時間
  ,null as pri_pat_a_0233 -- 自動プライミング送液液量
  ,null as pri_pat_a_0234 -- 自動プライミング送液流速1回目
  ,null as pri_pat_a_0235 -- 自動プライミング送液流速2回目以降
  ,null as pri_pat_a_0236 -- 自動プライミング循環流速
  ,null as pri_pat_a_0237 -- 自動プライミング循環時間
  ,null as pri_dev_a_0370 -- 自動回収_使用液量
  ,null as pri_dev_a_0371 -- 自動回収_流速
  ,null as pri_dev_a_0372 -- 自動回収_血液判別器による終了選択
  ,null as pri_pat_b_0051 -- オンラインプライミング_ダイアライザ気泡抜き時間_後補液
  ,null as pri_pat_b_0032 -- オンラインプライミング_動脈チャンバ液面作成時間_前補液
  ,null as pri_pat_b_0052 -- オンラインプライミング_動脈チャンバ液面作成時間_後補液
  ,null as pri_pat_b_0033 -- オンラインプライミング_循環洗浄時間_前補液
  ,null as pri_pat_b_0053 -- オンラインプライミング_循環洗浄時間_後補液
  ,null as ufr_dev_a_0290 -- UFRプログラム使用選択
  ,null as na_dev_a_0315 -- Na注入プログラム使用選択
  ,null as na_dev_a_0184 -- Na注入濃度最大値
  ,null as dc_dev_a_0340 -- 透析液濃度プログラム使用選択
  ,null as ecum_dev_a_0016 -- ECUM選択
  ,null as ecum_dev_a_0017 -- ECUM量
  ,null as ecum_dev_a_0018 -- ECUM時間
  ,null as ecum_dev_a_0019 -- ECUM時間カウント選択
  ,null as cpro_dev_a_0252 -- Ｂ液濃度プログラム自動設定警報幅上限
  ,null as cpro_dev_a_0253 -- Ｂ液濃度プログラム自動設定警報幅下限
  ,null as cpro_dev_a_0250 -- 透析液濃度プログラム自動設定警報幅上限
  ,null as cpro_dev_a_0251 -- 透析液濃度プログラム自動設定警報幅下限
  ,null as dfas_pat_b_0001 -- IPラインプライミング使用選択
  ,dialyzer_record.gas_purge_time -- ガスパージ時間
  ,dialyzer_record.substituent_wash_amt-- 置換洗浄量（透析液）
  ,dialyzer_record.membrane_wash -- 膜洗浄（中空糸）
  ,null as dfas_pat_b_0005 -- 中空糸_プライミング時のBP速度
  ,null as dfas_pat_b_0007 -- 中空糸_送液最大時間
  ,null as dfas_pat_b_0008 -- 中空糸_回路内洗浄送液量
  ,null as dfas_pat_b_0009 -- 中空糸_気泡抜き動作実行回数
  ,null as dfas_pat_b_0010 -- 中空糸_気泡抜き圧力上限
  ,null as dfas_pat_b_0059 -- 積層_プライミング時のBP速度
  ,null as dfas_pat_b_0054 -- 積層_送液最大時間
  ,null as dfas_pat_b_0055 -- 積層_回路内洗浄送液量
  ,null as dfas_pat_b_0056 -- 積層_気泡抜き動作実行回数
  ,null as dfas_pat_b_0057 -- 積層_気泡抜き圧力上限
  ,null as dfas_pat_b_0058 -- 積層_除水ポンプ速度
  ,null as dfas_dev_a_0339 -- 脱血方法選択
  ,null as dfas_dev_a_0333 -- 脱血速度
  ,null as dfas_dev_a_0331 -- 同時脱血_脱血量
  ,null as dfas_dev_a_0334 -- 片側脱血(除水なし)_脱血量
  ,null as dfas_dev_a_0338 -- 片側脱血（除水あり）_脱血量
  ,null as dfas_dev_a_0332 -- 片側脱血への切替え透析液圧
  ,treat_condition->>''335'' as ord_treat_condition_335 -- 治療開始時_血液ポンプ速度
  ,null as dfas_dev_a_0373 -- 静脈側返血速度
  ,null as dfas_dev_a_0374 -- 静脈側最大返血量
  ,null as dfas_dev_a_0377 -- 静脈側返血_血液判別器使用選択
  ,null as dfas_dev_a_0376 -- 動脈側最大返血量
  ,null as dfas_dev_a_0378 -- 動脈側返血_血液判別器使用選択
  ,null as dia_dev_a_0282 -- 透析量プログラム使用選択
  ,treat_condition->>''283'' as ord_treat_condition_283 -- 体液量計算時後体重
  ,treat_condition->>''284'' as ord_treat_condition_284 -- 体液量+補正値
  ,treat_condition->>''285'' as ord_treat_condition_285 -- 目標後体重
  ,treat_condition->>''286'' as ord_treat_condition_286 -- 標準血流量
  ,treat_condition->>''287'' as ord_treat_condition_287 -- KoA
  ,null as dia_dev_a_0288 -- 目標Kt/V
  ,treat_condition->>''187'' as ord_treat_condition_187 -- ダイアライザ 尿素クリアランス
  ,treat_condition->>''188'' as ord_treat_condition_188 -- ダイアライザ 血流量
  ,treat_condition->>''189'' as ord_treat_condition_189 -- ダイアライザ 透析液流量
  ,null as bvufc_dev_a_0196 -- BV-UFC使用選択
  ,null as bvufc_dev_a_0197 -- UFC期間除水速度上限
  ,null as bvufc_dev_a_0198 -- UFC期間除水速度下限
  ,null as bvufc_dev_a_0199 -- 開始期間 時間
  ,null as bvufc_dev_a_0206 -- 開始期間 除水速度倍率
  ,null as bvufc_dev_a_0207 -- 固定倍率除水期間 時間
  ,null as bvufc_dev_a_0208 -- 固定倍率除水期間 除水速度倍率
  ,null as bvufc_dev_a_0209 -- 固定倍率除水終了条件　最高血圧
  ,null as bvufc_dev_a_0210 -- 固定倍率除水終了条件　脈拍
  ,null as bvufc_dev_a_0248 -- 固定倍率除水終了条件　ΔBV
  ,null as bvufc_dev_a_0249 -- 終了前期間 時間
  ,null as ope_dev_a_0268 -- 透析液流量　設定方法
  ,null as ope_dev_a_0269 -- 透析液流量　比率設定
  ,null as bvufc_dev_a_0271 -- 開始時ΔBV基準値
  ,null as bvufc_dev_a_0272 -- ΔBV基準線　指数1
  ,null as bvufc_dev_a_0273 -- ΔBV基準線　指数2
  ,null as bvufc_dev_a_0274 -- ΔBV基準線　指数3
  ,null as bvufc_dev_a_0275 -- 終了時ΔBV基準値
  ,null as qbqd_dev_a_0400 -- QBプログラム血流量1
  ,null as qbqd_dev_a_0401 -- QBプログラム血流量2
  ,null as qbqd_dev_a_0402 -- QBプログラム血流量3
  ,null as qbqd_dev_a_0403 -- QBプログラム血流量4
  ,null as qbqd_dev_a_0404 -- QBプログラム血流量5
  ,null as qbqd_dev_a_0405 -- QBプログラム血流量6
  ,null as qbqd_dev_a_0406 -- QBプログラム血流量7
  ,null as qbqd_dev_a_0407 -- QBプログラム血流量8
  ,null as qbqd_dev_a_0408 -- QBプログラム血流量9
  ,null as qbqd_dev_a_0409 -- QBプログラム血流量10
  ,null as qbqd_dev_a_0410 -- QDプログラム透析液流量1
  ,null as qbqd_dev_a_0411 -- QDプログラム透析液流量2
  ,null as qbqd_dev_a_0412 -- QDプログラム透析液流量3
  ,null as qbqd_dev_a_0413 -- QDプログラム透析液流量4
  ,null as qbqd_dev_a_0414 -- QDプログラム透析液流量5
  ,null as qbqd_dev_a_0415 -- QDプログラム透析液流量6
  ,null as qbqd_dev_a_0416 -- QDプログラム透析液流量7
  ,null as qbqd_dev_a_0417 -- QDプログラム透析液流量8
  ,null as qbqd_dev_a_0418 -- QDプログラム透析液流量9
  ,null as qbqd_dev_a_0419 -- QDプログラム透析液流量10
  ,null as qbqd_dev_a_0420 -- QB、QDプログラム切替時間1
  ,null as qbqd_dev_a_0421 -- QB、QDプログラム切替時間2
  ,null as qbqd_dev_a_0422 -- QB、QDプログラム切替時間3
  ,null as qbqd_dev_a_0423 -- QB、QDプログラム切替時間4
  ,null as qbqd_dev_a_0424 -- QB、QDプログラム切替時間5
  ,null as qbqd_dev_a_0425 -- QB、QDプログラム切替時間6
  ,null as qbqd_dev_a_0426 -- QB、QDプログラム切替時間7
  ,null as qbqd_dev_a_0427 -- QB、QDプログラム切替時間8
  ,null as qbqd_dev_a_0428 -- QB、QDプログラム切替時間9
  ,null as qbqd_dev_a_0429 -- QB、QDプログラム最大ステップ数
  ,null as qbqd_dev_a_0430 -- QBプログラム電源
  ,null as qbqd_dev_a_0431 -- QDプログラム電源
  ,null as ihdf_dev_a_0432 -- I-HDFプログラム使用選択
  ,null as ihdf_dev_a_0433 -- 予定補液回数
  ,null as ihdf_dev_a_0434 -- 補液バランス制限
  ,null as ihdf_dev_a_0435 -- 補液量01
  ,null as ihdf_dev_a_0436 -- 補液量02
  ,null as ihdf_dev_a_0437 -- 補液量03
  ,null as ihdf_dev_a_0438 -- 補液量04
  ,null as ihdf_dev_a_0439 -- 補液量05
  ,null as ihdf_dev_a_0440 -- 補液量06
  ,null as ihdf_dev_a_0441 -- 補液量07
  ,null as ihdf_dev_a_0442 -- 補液量08
  ,null as ihdf_dev_a_0443 -- 補液量09
  ,null as ihdf_dev_a_0444 -- 補液量10
  ,null as ihdf_dev_a_0445 -- 補液量11
  ,null as ihdf_dev_a_0446 -- 補液量12
  ,null as ihdf_dev_a_0447 -- 補液量13
  ,null as ihdf_dev_a_0448 -- 補液量14
  ,null as ihdf_dev_a_0449 -- 補液量15
  ,null as ihdf_dev_a_0450 -- 補液量16
  ,null as ihdf_dev_a_0451 -- 回収量01
  ,null as ihdf_dev_a_0452 -- 回収量02
  ,null as ihdf_dev_a_0453 -- 回収量03
  ,null as ihdf_dev_a_0454 -- 回収量04
  ,null as ihdf_dev_a_0455 -- 回収量05
  ,null as ihdf_dev_a_0456 -- 回収量06
  ,null as ihdf_dev_a_0457 -- 回収量07
  ,null as ihdf_dev_a_0458 -- 回収量08
  ,null as ihdf_dev_a_0459 -- 回収量09
  ,null as ihdf_dev_a_0460 -- 回収量10
  ,null as ihdf_dev_a_0461 -- 回収量11
  ,null as ihdf_dev_a_0462 -- 回収量12
  ,null as ihdf_dev_a_0463 -- 回収量13
  ,null as ihdf_dev_a_0464 -- 回収量14
  ,null as ihdf_dev_a_0465 -- 回収量15
  ,null as ihdf_dev_a_0466 -- 回収量16
from
  ord_main
  inner join latest_otc on ord_main.ord_no = latest_otc.ord_no
  cross join dialyzer_record
where ord_main.ord_no = @ordNo and ord_main.is_del = ''0''
 and ord_main.rst_dialysis_state >''0'' and ord_main.rst_dialysis_state <''6''

	),
time_info AS (
	WITH b AS (
    select ord_main.* from ord_main
     where rst_dialysis_state between ''1'' and ''5''
     and
             ord_no = @ordNo
     and
       is_del = ''0''
	), d AS (
    select b.ord_no
    , data_type
    , MAX(bio_moni_ctl_no) AS bio_moni_ctl_no
    from b inner join mni_monitor on (b.ord_no = mni_monitor.ord_no)
    group by b.ord_no
    , mni_monitor.data_type
	), e AS (
    select mni_monitor.*,
    to_number(mni_monitor.monitor_data::json->>''1'', ''9999'') AS 経過時間
    , to_number(mni_monitor.monitor_data::json->>''3'', ''9999'') AS 残り時間_除水完了
    , to_number(mni_monitor.monitor_data::json->>''4'', ''9999'') AS 残り時間_透析完了
    from d
    inner join mni_monitor on (d.bio_moni_ctl_no = mni_monitor.bio_moni_ctl_no)
    where d.data_type = 1
	), f AS (
    select e.*
    , e.経過時間 + e.残り時間_除水完了 AS 予測時間_除水
    , e.経過時間 + e.残り時間_透析完了 AS 予測時間_透析
    from e
	)
	select
	b.ord_no,
	-- 終了予定
	b.rst_start_date + e.経過時間  * interval ''1 minute'' AS  ind_end_date,
	-- 終了予測
	CASE WHEN b.rst_dialysis_state < ''3'' THEN null
       WHEN f.残り時間_除水完了 > f.残り時間_透析完了 THEN b.rst_start_date + f.予測時間_除水 * interval ''1 minute''
       ELSE b.rst_start_date + f.予測時間_透析 * interval ''1 minute''
	END AS ind_end_date_time
	-- 透析開始
	, b.rst_start_date
	-- 透析終了
	, b.rst_end_date
	from  b left JOIN e on b.ord_no=e.ord_no left JOIN f on b.ord_no=f.ord_no
)
SELECT
DATA.ord_no_t as ord_no,
	*
FROM
	DATA
	LEFT JOIN
	time_info
	on
	DATA.ord_no_t = time_info.ord_no
	;
	',2,'[{"preview": "220", "can_calc": "1", "data_code": "ope_dev_a_0179", "data_name": "血流量設定最大値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0179", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4.00", "can_calc": "1", "data_code": "ope_dev_a_0181", "data_name": "除水速度制限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0181", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "0", "data_code": "ope_dev_a_0038", "data_name": "動脈側気泡検出器", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用する", "item": "使用する"}, {"code": "1", "disp": "使用しない", "item": "使用しない"}], "data_class": "装置設定", "field_name": "ope_dev_a_0038", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析時間", "can_calc": "0", "data_code": "ope_dev_a_0021", "data_name": "除水計算時間", "data_type": "string", "conv_table": [{"code": "0", "disp": "透析時間", "item": "透析時間"}, {"code": "1", "disp": "設定時間", "item": "設定時間"}], "data_class": "装置設定", "field_name": "ope_dev_a_0021", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "除水速度算出", "can_calc": "0", "data_code": "ope_dev_a_0022", "data_name": "除水計算優先項目", "data_type": "string", "conv_table": [{"code": "0", "disp": "除水速度算出", "item": "除水速度算出"}, {"code": "1", "disp": "除水量設定算出", "item": "除水量設定算出"}], "data_class": "装置設定", "field_name": "ope_dev_a_0022", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "ope_dev_a_0039", "data_name": "除水開始遅延時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0039", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "40.0", "can_calc": "1", "data_code": "ope_dev_a_0182", "data_name": "透析液温度操作範囲上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0182", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "33.0", "can_calc": "1", "data_code": "ope_dev_a_0183", "data_name": "透析液温度操作範囲下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0183", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "ope_dev_a_0024", "data_name": "シングルニードル切替圧上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0024", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "ope_dev_a_0025", "data_name": "シングルニードル切替圧下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0025", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "あり", "can_calc": "0", "data_code": "ope_dev_a_0241", "data_name": "TMPゼロ補正", "data_type": "string", "conv_table": [{"code": "0", "disp": "あり", "item": "あり"}, {"code": "1", "disp": "なし", "item": "なし"}], "data_class": "装置設定", "field_name": "ope_dev_a_0241", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "ope_dev_a_0168", "data_name": "HD補正警報上限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0168", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "ope_dev_a_0169", "data_name": "HD補正警報下限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0169", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "ope_dev_a_0171", "data_name": "ECUM補正警報上限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0171", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "ope_dev_a_0172", "data_name": "ECUM補正警報下限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0172", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "ope_dev_a_0174", "data_name": "HDF補正警報上限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0174", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "ope_dev_a_0175", "data_name": "HDF補正警報下限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0175", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "ope_dev_a_0177", "data_name": "HF補正警報上限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0177", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "ope_dev_a_0178", "data_name": "HF補正警報下限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0178", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "ope_dev_b_0037", "data_name": "HD+補液補正警報上限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0037", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "ope_dev_b_0038", "data_name": "HD+補液補正警報下限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0038", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "ope_dev_a_0391", "data_name": "OHDF補正警報上限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0391", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "ope_dev_a_0392", "data_name": "OHDF補正警報下限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0392", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "ope_dev_a_0394", "data_name": "OHF補正警報上限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0394", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "ope_dev_a_0395", "data_name": "OHF補正警報下限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0395", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4.0", "can_calc": "1", "data_code": "ope_dev_a_0383", "data_name": "補液量制限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0383", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "補液速度算出", "can_calc": "0", "data_code": "ope_dev_a_0389", "data_name": "補液計算優先項目", "data_type": "string", "conv_table": [{"code": "0", "disp": "補液速度算出", "item": "補液速度算出"}, {"code": "1", "disp": "補液量設定算出", "item": "補液量設定算出"}, {"code": "2", "disp": "補液比率", "item": "補液比率"}, {"code": "3", "disp": "濾過率から算出", "item": "濾過率から算出"}], "data_class": "装置設定", "field_name": "ope_dev_a_0389", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20", "can_calc": "1", "data_code": "ope_dev_a_0379", "data_name": "補液比率（前補液）", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0379", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20", "can_calc": "1", "data_code": "ope_dev_b_0039", "data_name": "補液比率（後補液）", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0039", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ope_dev_a_0398", "data_name": "補液開始遅延時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0398", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "0", "data_code": "ope_dev_a_0369", "data_name": "DP=Qd+Qs(補液速度加算)", "data_type": "string", "conv_table": [{"code": "1", "disp": "使用しない", "item": "使用しない"}, {"code": "2", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "ope_dev_a_0369", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "52", "can_calc": "1", "data_code": "ope_dev_a_0090", "data_name": "濾過率（前補液）", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0090", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "42", "can_calc": "1", "data_code": "ope_dev_b_0040", "data_name": "濾過率（後補液）", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0040", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "35", "can_calc": "1", "data_code": "ope_dev_a_0091", "data_name": "ヘマトクリット（Ht）", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0091", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.7", "can_calc": "1", "data_code": "ope_dev_a_0092", "data_name": "総タンパク（TP）", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0092", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "ope_dev_a_0336", "data_name": "緊急補液速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0336", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "ope_dev_a_0337", "data_name": "緊急補液量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0337", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.00", "can_calc": "1", "data_code": "ope_dev_a_0185", "data_name": "HDF速度操作範囲上限前補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0185", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.00", "can_calc": "1", "data_code": "ope_dev_b_0031", "data_name": "HDF速度操作範囲上限後補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0031", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.00", "can_calc": "1", "data_code": "ope_dev_a_0186", "data_name": "HF速度操作範囲上限前補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0186", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.00", "can_calc": "1", "data_code": "ope_dev_b_0032", "data_name": "HF速度操作範囲上限後補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0032", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12.00", "can_calc": "1", "data_code": "ope_dev_b_0030", "data_name": "HD+補液速度操作範囲上限前補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0030", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.00", "can_calc": "1", "data_code": "ope_dev_b_0033", "data_name": "HD+補液速度操作範囲上限後補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0033", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12.00", "can_calc": "1", "data_code": "ope_dev_a_0396", "data_name": "OHDF速度操作範囲上限前補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0396", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.00", "can_calc": "1", "data_code": "ope_dev_b_0034", "data_name": "OHDF速度操作範囲上限後補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0034", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12.00", "can_calc": "1", "data_code": "ope_dev_a_0397", "data_name": "OHF速度操作範囲上限前補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0397", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.00", "can_calc": "1", "data_code": "ope_dev_b_0035", "data_name": "OHF速度操作範囲上限後補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_b_0035", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "0", "data_code": "ope_dev_a_0384", "data_name": "AFBF補液比率使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "ope_dev_a_0384", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "13.00", "can_calc": "1", "data_code": "ope_dev_a_0385", "data_name": "AFBF補液比率", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0385", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.50", "can_calc": "1", "data_code": "ope_dev_a_0386", "data_name": "AFBF速度操作範囲上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0386", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.00", "can_calc": "1", "data_code": "ope_dev_a_0387", "data_name": "AFBF速度操作範囲下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0387", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "ihdf_dev_a_0200", "data_name": "I-HDF_補液量設定", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0200", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "ihdf_dev_a_0201", "data_name": "I-HDF_補液速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0201", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30", "can_calc": "1", "data_code": "ihdf_dev_a_0202", "data_name": "I-HDF_補液周期", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0202", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30", "can_calc": "1", "data_code": "ihdf_dev_a_0203", "data_name": "I-HDF_補液開始時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0203", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0204", "data_name": "I-HDF_除水再開時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0204", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.50", "can_calc": "1", "data_code": "ihdf_dev_a_0205", "data_name": "I-HDF_総補液量上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0205", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析液圧", "can_calc": "0", "data_code": "war_dev_a_0240", "data_name": "TMP監視モード", "data_type": "string", "conv_table": [{"code": "0", "disp": "TMP自動追従", "item": "TMP自動追従"}, {"code": "1", "disp": "TMP自動設定", "item": "TMP自動設定"}, {"code": "2", "disp": "透析液圧", "item": "透析液圧"}], "data_class": "装置設定", "field_name": "war_dev_a_0240", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "war_dev_a_0100", "data_name": "HD/ECUM静脈圧自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0100", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-30", "can_calc": "1", "data_code": "war_dev_a_0101", "data_name": "HD/ECUM静脈圧自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0101", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "war_dev_a_0102", "data_name": "HD/ECUM静脈圧自動設定警報限界上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0102", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "1", "data_code": "war_dev_a_0103", "data_name": "HD/ECUM静脈圧自動設定警報限界下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0103", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "war_dev_a_0104", "data_name": "HD/ECUM静脈圧固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0104", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0105", "data_name": "HD/ECUM静脈圧固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0105", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "war_dev_a_0152", "data_name": "HD/ECUMダイアライザ入口圧自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0152", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0153", "data_name": "HD/ECUMダイアライザ入口圧自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0153", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "war_dev_a_0154", "data_name": "HD/ECUMダイアライザ入口圧自動設定警報限界上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0154", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "war_dev_a_0155", "data_name": "HD/ECUMダイアライザ入口圧自動設定警報限界下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0155", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "war_dev_a_0156", "data_name": "HD/ECUMダイアライザ入口圧固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0156", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0157", "data_name": "HD/ECUMダイアライザ入口圧固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0157", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "war_dev_a_0112", "data_name": "HD/ECUM液圧自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0112", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0113", "data_name": "HD/ECUM液圧自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0113", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "war_dev_a_0114", "data_name": "HD/ECUM液圧自動設定警報限界上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0114", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-300", "can_calc": "1", "data_code": "war_dev_a_0115", "data_name": "HD/ECUM液圧自動設定警報限界下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0115", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "war_dev_a_0116", "data_name": "HD/ECUM液圧固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0116", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-300", "can_calc": "1", "data_code": "war_dev_a_0117", "data_name": "HD/ECUM液圧固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0117", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "war_dev_a_0128", "data_name": "HD/ECUMTMP自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0128", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0129", "data_name": "HD/ECUMTMP自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0129", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "war_dev_a_0130", "data_name": "HD/ECUMTMP自動設定警報限界上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0130", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-30", "can_calc": "1", "data_code": "war_dev_a_0131", "data_name": "HD/ECUMTMP自動設定警報限界下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0131", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "war_dev_a_0132", "data_name": "HD/ECUMTMP固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0132", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-30", "can_calc": "1", "data_code": "war_dev_a_0133", "data_name": "HD/ECUMTMP固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0133", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20", "can_calc": "1", "data_code": "war_dev_a_0126", "data_name": "HD/ECUMTMP自動追従警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0126", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-20", "can_calc": "1", "data_code": "war_dev_a_0127", "data_name": "HD/ECUMTMP自動追従警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0127", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20", "can_calc": "1", "data_code": "war_dev_a_0146", "data_name": "HD/ECUMダイアライザ差圧自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0146", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-20", "can_calc": "1", "data_code": "war_dev_a_0147", "data_name": "HD/ECUMダイアライザ差圧自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0147", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "80", "can_calc": "1", "data_code": "war_dev_a_0148", "data_name": "HD/ECUMダイアライザ差圧固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0148", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "war_dev_a_0149", "data_name": "HD/ECUMダイアライザ差圧固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0149", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70", "can_calc": "1", "data_code": "war_dev_a_0106", "data_name": "HDF/HF静脈圧自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0106", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-70", "can_calc": "1", "data_code": "war_dev_a_0107", "data_name": "HDF/HF静脈圧自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0107", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70", "can_calc": "1", "data_code": "war_dev_a_0158", "data_name": "HDF/HFダイアライザ入口圧自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0158", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-70", "can_calc": "1", "data_code": "war_dev_a_0159", "data_name": "HDF/HFダイアライザ入口圧自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0159", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70", "can_calc": "1", "data_code": "war_dev_a_0118", "data_name": "HDF/HF液圧自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0118", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-70", "can_calc": "1", "data_code": "war_dev_a_0119", "data_name": "HDF/HF液圧自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0119", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "war_dev_a_0136", "data_name": "HDF/HFTMP自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0136", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0137", "data_name": "HDF/HFTMP自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0137", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70", "can_calc": "1", "data_code": "war_dev_a_0134", "data_name": "HDF/HFTMP自動追従警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0134", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-70", "can_calc": "1", "data_code": "war_dev_a_0135", "data_name": "HDF/HFTMP自動追従警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0135", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "war_dev_a_0150", "data_name": "HDF/HFダイアライザ差圧自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0150", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0151", "data_name": "HDF/HFダイアライザ差圧自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0151", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "400", "can_calc": "1", "data_code": "war_dev_a_0110", "data_name": "SN静脈圧固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0110", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0111", "data_name": "SN静脈圧固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0111", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5000", "can_calc": "1", "data_code": "war_dev_a_0162", "data_name": "SNダイアライザ入口圧固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0162", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0163", "data_name": "SNダイアライザ入口圧固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0163", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70", "can_calc": "1", "data_code": "war_dev_a_0120", "data_name": "SN液圧自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0120", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-70", "can_calc": "1", "data_code": "war_dev_a_0121", "data_name": "SN液圧自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0121", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "war_dev_a_0122", "data_name": "SN液圧自動設定警報限界上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0122", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-300", "can_calc": "1", "data_code": "war_dev_a_0123", "data_name": "SN液圧自動設定警報限界下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0123", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "war_dev_a_0124", "data_name": "SN液圧固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0124", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-300", "can_calc": "1", "data_code": "war_dev_a_0125", "data_name": "SN液圧固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0125", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "war_dev_a_0140", "data_name": "SNTMP自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0140", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-30", "can_calc": "1", "data_code": "war_dev_a_0141", "data_name": "SNTMP自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0141", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "war_dev_a_0142", "data_name": "SNTMP自動設定警報限界上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0142", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-30", "can_calc": "1", "data_code": "war_dev_a_0143", "data_name": "SNTMP自動設定警報限界下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0143", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "war_dev_a_0144", "data_name": "SNTMP固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0144", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "1", "data_code": "war_dev_a_0145", "data_name": "SNTMP固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0145", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70", "can_calc": "1", "data_code": "war_dev_a_0138", "data_name": "SNTMP自動追従警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0138", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-70", "can_calc": "1", "data_code": "war_dev_a_0139", "data_name": "SNTMP自動追従警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0139", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "400", "can_calc": "1", "data_code": "war_dev_a_0108", "data_name": "準備回収静脈圧固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0108", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-200", "can_calc": "1", "data_code": "war_dev_a_0109", "data_name": "準備回収静脈圧固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0109", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "war_dev_a_0160", "data_name": "準備回収ダイアライザ入口圧固定警報上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0160", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-200", "can_calc": "1", "data_code": "war_dev_a_0161", "data_name": "準備回収ダイアライザ入口圧固定警報下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0161", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5", "can_calc": "1", "data_code": "war_dev_a_0254", "data_name": "Na濃度自動警報幅上限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0254", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-5", "can_calc": "1", "data_code": "war_dev_a_0255", "data_name": "Na濃度自動警報幅下限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0255", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "190", "can_calc": "1", "data_code": "war_dev_a_0256", "data_name": "Na濃度固定警報幅上限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0256", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120", "can_calc": "1", "data_code": "war_dev_a_0257", "data_name": "Na濃度固定警報幅下限値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "war_dev_a_0257", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "bp_dev_a_0211", "data_name": "血圧警報点最高血圧上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0211", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "80", "can_calc": "1", "data_code": "bp_dev_a_0212", "data_name": "血圧警報点最高血圧下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0212", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "160", "can_calc": "1", "data_code": "bp_dev_a_0213", "data_name": "血圧警報点最低血圧上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0213", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "bp_dev_a_0214", "data_name": "血圧警報点最低血圧下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0214", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "180", "can_calc": "1", "data_code": "bp_dev_a_0215", "data_name": "血圧警報点平均血圧上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0215", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "bp_dev_a_0216", "data_name": "血圧警報点平均血圧下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0216", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "170", "can_calc": "1", "data_code": "bp_dev_a_0217", "data_name": "血圧警報点脈拍数上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0217", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "bp_dev_a_0218", "data_name": "血圧警報点脈拍数下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0218", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■動作", "can_calc": "0", "data_code": "bp_dev_a_0219", "data_name": "最高血圧上限警報_血液ポンプ_動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "□動作", "item": "□動作"}, {"code": "1", "disp": "■動作", "item": "■動作"}], "data_class": "装置設定", "field_name": "bp_dev_a_0219", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "bp_dev_a_0227", "data_name": "最高血圧上限警報_血液ポンプ_速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0227", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■動作", "can_calc": "0", "data_code": "bp_dev_a_0220", "data_name": "最高血圧下限警報_血液ポンプ_動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "□動作", "item": "□動作"}, {"code": "1", "disp": "■動作", "item": "■動作"}], "data_class": "装置設定", "field_name": "bp_dev_a_0220", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "bp_dev_a_0228", "data_name": "最高血圧下限警報_血液ポンプ_速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0228", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■動作", "can_calc": "0", "data_code": "bp_dev_a_0221", "data_name": "最高血圧上限警報_除水ポンプ_動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "□動作", "item": "□動作"}, {"code": "1", "disp": "■動作", "item": "■動作"}], "data_class": "装置設定", "field_name": "bp_dev_a_0221", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.10", "can_calc": "1", "data_code": "bp_dev_a_0229", "data_name": "最高血圧上限警報_除水ポンプ_速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0229", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■動作", "can_calc": "0", "data_code": "bp_dev_a_0222", "data_name": "最高血圧下限警報_除水ポンプ_動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "□動作", "item": "□動作"}, {"code": "1", "disp": "■動作", "item": "■動作"}], "data_class": "装置設定", "field_name": "bp_dev_a_0222", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.10", "can_calc": "1", "data_code": "bp_dev_a_0230", "data_name": "最高血圧下限警報_除水ポンプ_速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0230", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■動作", "can_calc": "0", "data_code": "bp_dev_a_0223", "data_name": "最高血圧上限警報_Na注入ポンプ_動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "□動作", "item": "□動作"}, {"code": "1", "disp": "■動作", "item": "■動作"}], "data_class": "装置設定", "field_name": "bp_dev_a_0223", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.30", "can_calc": "1", "data_code": "bp_dev_a_0231", "data_name": "最高血圧上限警報_Na注入ポンプ_速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0231", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■動作", "can_calc": "0", "data_code": "bp_dev_a_0224", "data_name": "最高血圧下限警報_Na注入ポンプ_動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "□動作", "item": "□動作"}, {"code": "1", "disp": "■動作", "item": "■動作"}], "data_class": "装置設定", "field_name": "bp_dev_a_0224", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.30", "can_calc": "1", "data_code": "bp_dev_a_0232", "data_name": "最高血圧下限警報_Na注入ポンプ_速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0232", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■動作", "can_calc": "0", "data_code": "bp_dev_a_0225", "data_name": "最高血圧上限警報_補液ポンプ_動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "□動作", "item": "□動作"}, {"code": "1", "disp": "■動作", "item": "■動作"}], "data_class": "装置設定", "field_name": "bp_dev_a_0225", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.00", "can_calc": "1", "data_code": "bp_dev_a_0233", "data_name": "最高血圧上限警報_補液ポンプ_速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0233", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■動作", "can_calc": "0", "data_code": "bp_dev_a_0226", "data_name": "最高血圧下限警報_補液ポンプ_動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "□動作", "item": "□動作"}, {"code": "1", "disp": "■動作", "item": "■動作"}], "data_class": "装置設定", "field_name": "bp_dev_a_0226", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.00", "can_calc": "1", "data_code": "bp_dev_a_0234", "data_name": "最高血圧下限警報_補液ポンプ_速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0234", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "成人", "can_calc": "0", "data_code": "bp_dev_a_0191", "data_name": "血圧カフ選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "成人", "item": "成人"}, {"code": "1", "disp": "幼児", "item": "幼児"}], "data_class": "装置設定", "field_name": "bp_dev_a_0191", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30", "can_calc": "1", "data_code": "bp_dev_a_0190", "data_name": "血圧自動測定間隔", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0190", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "180", "can_calc": "1", "data_code": "bp_dev_a_0192", "data_name": "昇圧値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0192", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "手動", "can_calc": "0", "data_code": "bp_dev_a_0193", "data_name": "昇圧方法選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "手動", "item": "手動"}, {"code": "1", "disp": "自動", "item": "自動"}, {"code": "2", "disp": "スマート昇圧", "item": "スマート昇圧"}], "data_class": "装置設定", "field_name": "bp_dev_a_0193", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "降圧設定", "can_calc": "0", "data_code": "bp_dev_a_0195", "data_name": "血圧測定方法選択", "data_type": "string", "conv_table": [{"code": "1", "disp": "降圧測定", "item": "降圧測定"}, {"code": "2", "disp": "昇圧測定", "item": "昇圧測定"}], "data_class": "装置設定", "field_name": "bp_dev_a_0195", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "なし", "can_calc": "0", "data_code": "bp_dev_a_0239", "data_name": "高速測定選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "なし", "item": "なし"}, {"code": "1", "disp": "あり", "item": "あり"}], "data_class": "装置設定", "field_name": "bp_dev_a_0239", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12分", "can_calc": "0", "data_code": "bp_dev_a_0194", "data_name": "血圧連続測定動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "12分", "item": "12分"}, {"code": "1", "disp": "5分", "item": "5分"}], "data_class": "装置設定", "field_name": "bp_dev_a_0194", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2:34", "can_calc": "0", "data_code": "bp_dev_a_0235", "data_name": "警報連動測定開始時間", "data_type": "DateTime", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0235", "disp_format": "[h]:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3:45", "can_calc": "0", "data_code": "bp_dev_a_0236", "data_name": "治療条件連動測定時間", "data_type": "DateTime", "conv_table": [], "data_class": "装置設定", "field_name": "bp_dev_a_0236", "disp_format": "[h]:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "継続", "can_calc": "0", "data_code": "bp_dev_a_0237", "data_name": "静脈圧警報発生時の血圧測定", "data_type": "string", "conv_table": [{"code": "0", "disp": "継続", "item": "継続"}, {"code": "1", "disp": "中断・終了", "item": "中断・終了"}], "data_class": "装置設定", "field_name": "bp_dev_a_0237", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "継続", "can_calc": "0", "data_code": "bp_dev_a_0238", "data_name": "血流量または除水速度変更時の血圧測定", "data_type": "string", "conv_table": [{"code": "0", "disp": "継続", "item": "継続"}, {"code": "1", "disp": "中断・終了", "item": "中断・終了"}], "data_class": "装置設定", "field_name": "bp_dev_a_0238", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "する", "can_calc": "0", "data_code": "bv_dev_a_0267", "data_name": "BV計使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "しない", "item": "しない"}, {"code": "1", "disp": "する", "item": "する"}], "data_class": "装置設定", "field_name": "bv_dev_a_0267", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-20.0", "can_calc": "1", "data_code": "bv_dev_a_0260", "data_name": "⊿BV低下警報点1", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0260", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-40.0", "can_calc": "1", "data_code": "bv_dev_a_0261", "data_name": "⊿BV低下警報点2", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0261", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-10.0", "can_calc": "1", "data_code": "bv_dev_a_0262", "data_name": "⊿BV変化率警報点", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0262", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.00", "can_calc": "1", "data_code": "bv_dev_a_0277", "data_name": "⊿BV除水低下速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0277", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5", "can_calc": "1", "data_code": "bv_dev_a_0278", "data_name": "⊿BV除水低下遅延時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0278", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "する", "can_calc": "0", "data_code": "bv_dev_a_0258", "data_name": "アクセス再循環測定使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "しない", "item": "しない"}, {"code": "1", "disp": "する", "item": "する"}], "data_class": "装置設定", "field_name": "bv_dev_a_0258", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10:01", "can_calc": "1", "data_code": "bv_dev_a_0259", "data_name": "アクセス再循環自動測定1", "data_type": "DateTime", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0259", "disp_format": "HH:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10:02", "can_calc": "1", "data_code": "bv_dev_a_0263", "data_name": "アクセス再循環自動測定2", "data_type": "DateTime", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0263", "disp_format": "HH:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10:03", "can_calc": "1", "data_code": "bv_dev_a_0264", "data_name": "アクセス再循環自動測定3", "data_type": "DateTime", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0264", "disp_format": "HH:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10:04", "can_calc": "1", "data_code": "bv_dev_a_0265", "data_name": "アクセス再循環自動測定4", "data_type": "DateTime", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0265", "disp_format": "HH:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10:05", "can_calc": "1", "data_code": "bv_dev_a_0266", "data_name": "アクセス再循環自動測定5", "data_type": "DateTime", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0266", "disp_format": "HH:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用する", "can_calc": "0", "data_code": "dfas_dev_a_0270", "data_name": "動脈側返血使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "dfas_dev_a_0270", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30", "can_calc": "1", "data_code": "bv_dev_a_0281", "data_name": "アクセス再循環再循環率報知", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bv_dev_a_0281", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "pri_pat_a_0219", "data_name": "プライミング補助動脈充填液量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0219", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "pri_pat_a_0220", "data_name": "プライミング補助動脈充填流速", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0220", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "しない", "can_calc": "0", "data_code": "pri_pat_a_0225", "data_name": "プライミング補助動脈充填後継続の有無", "data_type": "string", "conv_table": [{"code": "0", "disp": "しない", "item": "しない"}, {"code": "1", "disp": "する", "item": "する"}], "data_class": "装置設定", "field_name": "pri_pat_a_0225", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "pri_pat_a_0221", "data_name": "プライミング補助静脈充填液量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0221", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "pri_pat_a_0222", "data_name": "プライミング補助静脈充填流速", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0222", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "しない", "can_calc": "0", "data_code": "pri_pat_a_0226", "data_name": "プライミング補助静脈充填後継続の有無", "data_type": "string", "conv_table": [{"code": "0", "disp": "しない", "item": "しない"}, {"code": "1", "disp": "する", "item": "する"}], "data_class": "装置設定", "field_name": "pri_pat_a_0226", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "400", "can_calc": "1", "data_code": "pri_pat_a_0223", "data_name": "プライミング補助気泡抜き液量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0223", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "pri_pat_a_0224", "data_name": "プライミング補助気泡抜き流速", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0224", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "連続", "can_calc": "0", "data_code": "pri_pat_a_0227", "data_name": "プライミング補助気泡抜き間欠動作選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "連続", "item": "連続"}, {"code": "1", "disp": "間欠", "item": "間欠"}], "data_class": "装置設定", "field_name": "pri_pat_a_0227", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "800", "can_calc": "1", "data_code": "pri_pat_a_0228", "data_name": "プライミング補助液交換量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0228", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.0", "can_calc": "1", "data_code": "pri_pat_a_0229", "data_name": "プライミング補助間欠動作動作時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0229", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.0", "can_calc": "1", "data_code": "pri_pat_a_0230", "data_name": "プライミング補助間欠動作停止時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0230", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "40", "can_calc": "1", "data_code": "pri_pat_a_0232", "data_name": "自動プライミング落差時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0232", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "pri_pat_a_0238", "data_name": "自動プライミング総量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0238", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "420", "can_calc": "1", "data_code": "pri_pat_a_0231", "data_name": "自動プライミング開始時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0231", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "250", "can_calc": "1", "data_code": "pri_pat_a_0233", "data_name": "自動プライミング送液液量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0233", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "250", "can_calc": "1", "data_code": "pri_pat_a_0234", "data_name": "自動プライミング送液流速1回目", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0234", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "250", "can_calc": "1", "data_code": "pri_pat_a_0235", "data_name": "自動プライミング送液流速2回目以降", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0235", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "400", "can_calc": "1", "data_code": "pri_pat_a_0236", "data_name": "自動プライミング循環流速", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0236", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "pri_pat_a_0237", "data_name": "自動プライミング循環時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_a_0237", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "pri_dev_a_0370", "data_name": "自動回収_使用液量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_dev_a_0370", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "pri_dev_a_0371", "data_name": "自動回収_流速", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_dev_a_0371", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "OFF", "can_calc": "0", "data_code": "pri_dev_a_0372", "data_name": "自動回収_血液判別器による終了選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "OFF", "item": "OFF"}, {"code": "1", "disp": "ON", "item": "ON"}], "data_class": "装置設定", "field_name": "pri_dev_a_0372", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2", "can_calc": "1", "data_code": "pri_pat_b_0051", "data_name": "オンラインプライミング_ダイアライザ気泡抜き時間_後補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_b_0051", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "90", "can_calc": "1", "data_code": "pri_pat_b_0032", "data_name": "オンラインプライミング_動脈チャンバ液面作成時間_前補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_b_0032", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "pri_pat_b_0052", "data_name": "オンラインプライミング_動脈チャンバ液面作成時間_後補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_b_0052", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3", "can_calc": "1", "data_code": "pri_pat_b_0033", "data_name": "オンラインプライミング_循環洗浄時間_前補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_b_0033", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3", "can_calc": "1", "data_code": "pri_pat_b_0053", "data_name": "オンラインプライミング_循環洗浄時間_後補液", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "pri_pat_b_0053", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "切り", "can_calc": "0", "data_code": "ufr_dev_a_0290", "data_name": "UFRプログラム使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "切り", "item": "切り"}, {"code": "1", "disp": "入り[ステップ]", "item": "入り[ステップ]"}, {"code": "2", "disp": "入り[コース]", "item": "入り[コース]"}], "data_class": "装置設定", "field_name": "ufr_dev_a_0290", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "切り", "can_calc": "0", "data_code": "na_dev_a_0315", "data_name": "Na注入プログラム使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "切り", "item": "切り"}, {"code": "1", "disp": "入り[ステップ]", "item": "入り[ステップ]"}, {"code": "2", "disp": "入り[コース]", "item": "入り[コース]"}], "data_class": "装置設定", "field_name": "na_dev_a_0315", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "na_dev_a_0184", "data_name": "Na注入濃度最大値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "na_dev_a_0184", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "切り", "can_calc": "0", "data_code": "dc_dev_a_0340", "data_name": "透析液濃度プログラム使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "切り", "item": "切り"}, {"code": "1", "disp": "入り[B,A共通ステップ]", "item": "入り[B,A共通ステップ]"}, {"code": "2", "disp": "入り[B,A別ステップ]", "item": "入り[B,A別ステップ]"}, {"code": "3", "disp": "入り[B,A別コース]", "item": "入り[B,A別コース]"}], "data_class": "装置設定", "field_name": "dc_dev_a_0340", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "HD", "can_calc": "0", "data_code": "ecum_dev_a_0016", "data_name": "ECUM選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "HD", "item": "HD"}, {"code": "1", "disp": "ECUM", "item": "ECUM"}], "data_class": "装置設定", "field_name": "ecum_dev_a_0016", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.00", "can_calc": "1", "data_code": "ecum_dev_a_0017", "data_name": "ECUM量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ecum_dev_a_0017", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "07:59", "can_calc": "1", "data_code": "ecum_dev_a_0018", "data_name": "ECUM時間", "data_type": "DateTime", "conv_table": [], "data_class": "装置設定", "field_name": "ecum_dev_a_0018", "disp_format": "HH:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "HD", "can_calc": "0", "data_code": "ecum_dev_a_0019", "data_name": "ECUM時間カウント選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "透析時間に含まない", "item": "透析時間に含まない"}, {"code": "1", "disp": "透析時間に含む", "item": "透析時間に含む"}], "data_class": "装置設定", "field_name": "ecum_dev_a_0019", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.0", "can_calc": "1", "data_code": "cpro_dev_a_0252", "data_name": "Ｂ液濃度プログラム自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "cpro_dev_a_0252", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-5.0", "can_calc": "1", "data_code": "cpro_dev_a_0253", "data_name": "Ｂ液濃度プログラム自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "cpro_dev_a_0253", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.0", "can_calc": "1", "data_code": "cpro_dev_a_0250", "data_name": "透析液濃度プログラム自動設定警報幅上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "cpro_dev_a_0250", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-5.0", "can_calc": "1", "data_code": "cpro_dev_a_0251", "data_name": "透析液濃度プログラム自動設定警報幅下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "cpro_dev_a_0251", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "0", "data_code": "dfas_pat_b_0001", "data_name": "IPラインプライミング使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "dfas_pat_b_0001", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5", "can_calc": "1", "data_code": "gas_purge_time", "data_name": "ガスパージ時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "gas_purge_time", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1000", "can_calc": "1", "data_code": "substituent_wash_amt", "data_name": "置換洗浄量（透析液）", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "substituent_wash_amt", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "0", "data_code": "membrane_wash", "data_name": "膜洗浄（中空糸）", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "membrane_wash", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "dfas_pat_b_0005", "data_name": "中空糸_プライミング時のBP速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0005", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "dfas_pat_b_0007", "data_name": "中空糸_送液最大時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0007", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "dfas_pat_b_0008", "data_name": "中空糸_回路内洗浄送液量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0008", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "dfas_pat_b_0009", "data_name": "中空糸_気泡抜き動作実行回数", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0009", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "150", "can_calc": "1", "data_code": "dfas_pat_b_0010", "data_name": "中空糸_気泡抜き圧力上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0010", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "150", "can_calc": "1", "data_code": "dfas_pat_b_0059", "data_name": "積層_プライミング時のBP速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0059", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "dfas_pat_b_0054", "data_name": "積層_送液最大時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0054", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "dfas_pat_b_0055", "data_name": "積層_回路内洗浄送液量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0055", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "dfas_pat_b_0056", "data_name": "積層_気泡抜き動作実行回数", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0056", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "150", "can_calc": "1", "data_code": "dfas_pat_b_0057", "data_name": "積層_気泡抜き圧力上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0057", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.20", "can_calc": "1", "data_code": "dfas_pat_b_0058", "data_name": "積層_除水ポンプ速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_pat_b_0058", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "片側脱血（除水なし）", "can_calc": "0", "data_code": "dfas_dev_a_0339", "data_name": "脱血方法選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "同時脱血", "item": "同時脱血"}, {"code": "1", "disp": "片側脱血（除水あり）", "item": "片側脱血（除水あり）"}, {"code": "2", "disp": "片側脱血（除水なし）", "item": "片側脱血（除水なし）"}], "data_class": "装置設定", "field_name": "dfas_dev_a_0339", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "dfas_dev_a_0333", "data_name": "脱血速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_dev_a_0333", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "150", "can_calc": "1", "data_code": "dfas_dev_a_0331", "data_name": "同時脱血_脱血量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_dev_a_0331", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "150", "can_calc": "1", "data_code": "dfas_dev_a_0334", "data_name": "片側脱血(除水なし)_脱血量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_dev_a_0334", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "dfas_dev_a_0338", "data_name": "片側脱血（除水あり）_脱血量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_dev_a_0338", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-200", "can_calc": "1", "data_code": "dfas_dev_a_0332", "data_name": "片側脱血への切替え透析液圧", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_dev_a_0332", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "ord_treat_condition_335", "data_name": "治療開始時_血液ポンプ速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ord_treat_condition_335", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "dfas_dev_a_0373", "data_name": "静脈側返血速度", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_dev_a_0373", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "250", "can_calc": "1", "data_code": "dfas_dev_a_0374", "data_name": "静脈側最大返血量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_dev_a_0374", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "0", "data_code": "dfas_dev_a_0377", "data_name": "静脈側返血_血液判別器使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "dfas_dev_a_0377", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30", "can_calc": "1", "data_code": "dfas_dev_a_0376", "data_name": "動脈側最大返血量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dfas_dev_a_0376", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "0", "data_code": "dfas_dev_a_0378", "data_name": "動脈側返血_血液判別器使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "dfas_dev_a_0378", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用する", "can_calc": "0", "data_code": "dia_dev_a_0282", "data_name": "透析量プログラム使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "dia_dev_a_0282", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "57.90", "can_calc": "1", "data_code": "ord_treat_condition_283", "data_name": "体液量計算時後体重", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ord_treat_condition_283", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10.00", "can_calc": "1", "data_code": "ord_treat_condition_284", "data_name": "体液量+補正値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ord_treat_condition_284", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "1", "data_code": "ord_treat_condition_285", "data_name": "目標後体重", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ord_treat_condition_285", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "ord_treat_condition_286", "data_name": "標準血流量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ord_treat_condition_286", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "ord_treat_condition_287", "data_name": "KoA", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ord_treat_condition_287", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.1", "can_calc": "1", "data_code": "dia_dev_a_0288", "data_name": "目標Kt/V", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "dia_dev_a_0288", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "190", "can_calc": "1", "data_code": "ord_treat_condition_187", "data_name": "ダイアライザ 尿素クリアランス", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ord_treat_condition_187", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "ord_treat_condition_188", "data_name": "ダイアライザ 血流量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ord_treat_condition_188", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "ord_treat_condition_189", "data_name": "ダイアライザ 透析液流量", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ord_treat_condition_189", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用する", "can_calc": "0", "data_code": "bvufc_dev_a_0196", "data_name": "BV-UFC使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "bvufc_dev_a_0196", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.00", "can_calc": "1", "data_code": "bvufc_dev_a_0197", "data_name": "UFC期間除水速度上限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0197", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.00", "can_calc": "1", "data_code": "bvufc_dev_a_0198", "data_name": "UFC期間除水速度下限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0198", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "1", "data_code": "bvufc_dev_a_0199", "data_name": "開始期間 時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0199", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.00", "can_calc": "1", "data_code": "bvufc_dev_a_0206", "data_name": "開始期間 除水速度倍率", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0206", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "bvufc_dev_a_0207", "data_name": "固定倍率除水期間 時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0207", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.30", "can_calc": "1", "data_code": "bvufc_dev_a_0208", "data_name": "固定倍率除水期間 除水速度倍率", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0208", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "bvufc_dev_a_0209", "data_name": "固定倍率除水終了条件　最高血圧", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0209", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "bvufc_dev_a_0210", "data_name": "固定倍率除水終了条件　脈拍", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0210", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.0", "can_calc": "1", "data_code": "bvufc_dev_a_0248", "data_name": "固定倍率除水終了条件　ΔBV", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0248", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20", "can_calc": "1", "data_code": "bvufc_dev_a_0249", "data_name": "終了前期間 時間", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0249", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "流量設定", "can_calc": "0", "data_code": "ope_dev_a_0268", "data_name": "透析液流量　設定方法", "data_type": "string", "conv_table": [{"code": "1", "disp": "流量設定", "item": "流量設定"}, {"code": "2", "disp": "比率設定", "item": "比率設定"}], "data_class": "装置設定", "field_name": "ope_dev_a_0268", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.0", "can_calc": "1", "data_code": "ope_dev_a_0269", "data_name": "透析液流量　比率設定", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ope_dev_a_0269", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.0", "can_calc": "1", "data_code": "bvufc_dev_a_0271", "data_name": "開始時ΔBV基準値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0271", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "bvufc_dev_a_0272", "data_name": "ΔBV基準線　指数1", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0272", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "80", "can_calc": "1", "data_code": "bvufc_dev_a_0273", "data_name": "ΔBV基準線　指数2", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0273", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "95", "can_calc": "1", "data_code": "bvufc_dev_a_0274", "data_name": "ΔBV基準線　指数3", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0274", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-4.0", "can_calc": "1", "data_code": "bvufc_dev_a_0275", "data_name": "終了時ΔBV基準値", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "bvufc_dev_a_0275", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "1", "data_code": "qbqd_dev_a_0400", "data_name": "QBプログラム血流量1", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0400", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "160", "can_calc": "1", "data_code": "qbqd_dev_a_0401", "data_name": "QBプログラム血流量2", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0401", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "qbqd_dev_a_0402", "data_name": "QBプログラム血流量3", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0402", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "qbqd_dev_a_0403", "data_name": "QBプログラム血流量4", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0403", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "qbqd_dev_a_0404", "data_name": "QBプログラム血流量5", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0404", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "qbqd_dev_a_0405", "data_name": "QBプログラム血流量6", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0405", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "qbqd_dev_a_0406", "data_name": "QBプログラム血流量7", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0406", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "qbqd_dev_a_0407", "data_name": "QBプログラム血流量8", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0407", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "qbqd_dev_a_0408", "data_name": "QBプログラム血流量9", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0408", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "1", "data_code": "qbqd_dev_a_0409", "data_name": "QBプログラム血流量10", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0409", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "1", "data_code": "qbqd_dev_a_0410", "data_name": "QDプログラム透析液流量1", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0410", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "400", "can_calc": "1", "data_code": "qbqd_dev_a_0411", "data_name": "QDプログラム透析液流量2", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0411", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "qbqd_dev_a_0412", "data_name": "QDプログラム透析液流量3", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0412", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "qbqd_dev_a_0413", "data_name": "QDプログラム透析液流量4", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0413", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "qbqd_dev_a_0414", "data_name": "QDプログラム透析液流量5", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0414", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "qbqd_dev_a_0415", "data_name": "QDプログラム透析液流量6", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0415", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "qbqd_dev_a_0416", "data_name": "QDプログラム透析液流量7", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0416", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "qbqd_dev_a_0417", "data_name": "QDプログラム透析液流量8", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0417", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "qbqd_dev_a_0418", "data_name": "QDプログラム透析液流量9", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0418", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "qbqd_dev_a_0419", "data_name": "QDプログラム透析液流量10", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0419", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "qbqd_dev_a_0420", "data_name": "QB、QDプログラム切替時間1", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0420", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "qbqd_dev_a_0421", "data_name": "QB、QDプログラム切替時間2", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0421", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "qbqd_dev_a_0422", "data_name": "QB、QDプログラム切替時間3", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0422", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "qbqd_dev_a_0423", "data_name": "QB、QDプログラム切替時間4", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0423", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "qbqd_dev_a_0424", "data_name": "QB、QDプログラム切替時間5", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0424", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "qbqd_dev_a_0425", "data_name": "QB、QDプログラム切替時間6", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0425", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "qbqd_dev_a_0426", "data_name": "QB、QDプログラム切替時間7", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0426", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "qbqd_dev_a_0427", "data_name": "QB、QDプログラム切替時間8", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0427", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "1", "data_code": "qbqd_dev_a_0428", "data_name": "QB、QDプログラム切替時間9", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0428", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3", "can_calc": "1", "data_code": "qbqd_dev_a_0429", "data_name": "QB、QDプログラム最大ステップ数", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "qbqd_dev_a_0429", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "切", "can_calc": "0", "data_code": "qbqd_dev_a_0430", "data_name": "QBプログラム電源", "data_type": "string", "conv_table": [{"code": "0", "disp": "切", "item": "切"}, {"code": "1", "disp": "入", "item": "入"}], "data_class": "装置設定", "field_name": "qbqd_dev_a_0430", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "切", "can_calc": "0", "data_code": "qbqd_dev_a_0431", "data_name": "QDプログラム電源", "data_type": "string", "conv_table": [{"code": "0", "disp": "切", "item": "切"}, {"code": "1", "disp": "入", "item": "入"}], "data_class": "装置設定", "field_name": "qbqd_dev_a_0431", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "0", "data_code": "ihdf_dev_a_0432", "data_name": "I-HDFプログラム使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "装置設定", "field_name": "ihdf_dev_a_0432", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7", "can_calc": "1", "data_code": "ihdf_dev_a_0433", "data_name": "予定補液回数", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0433", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0434", "data_name": "補液バランス制限", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0434", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0435", "data_name": "補液量01", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0435", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0436", "data_name": "補液量02", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0436", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0437", "data_name": "補液量03", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0437", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0438", "data_name": "補液量04", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0438", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0439", "data_name": "補液量05", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0439", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0440", "data_name": "補液量06", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0440", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0441", "data_name": "補液量07", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0441", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0442", "data_name": "補液量08", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0442", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0443", "data_name": "補液量09", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0443", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0444", "data_name": "補液量10", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0444", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0445", "data_name": "補液量11", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0445", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0446", "data_name": "補液量12", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0446", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0447", "data_name": "補液量13", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0447", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0448", "data_name": "補液量14", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0448", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0449", "data_name": "補液量15", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0449", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0450", "data_name": "補液量16", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0450", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0451", "data_name": "回収量01", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0451", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0452", "data_name": "回収量02", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0452", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0453", "data_name": "回収量03", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0453", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0454", "data_name": "回収量04", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0454", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0455", "data_name": "回収量05", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0455", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0456", "data_name": "回収量06", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0456", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0457", "data_name": "回収量07", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0457", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0458", "data_name": "回収量08", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0458", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0459", "data_name": "回収量09", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0459", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0460", "data_name": "回収量10", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0460", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0461", "data_name": "回収量11", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0461", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0462", "data_name": "回収量12", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0462", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0463", "data_name": "回収量13", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0463", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0464", "data_name": "回収量14", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0464", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0465", "data_name": "回収量15", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0465", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ihdf_dev_a_0466", "data_name": "回収量16", "data_type": "decimal", "conv_table": [], "data_class": "装置設定", "field_name": "ihdf_dev_a_0466", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]'::jsonb,'0','{"applications": [1]}'::jsonb,'{"classes": [1, 2, 3, 9, 10, 11]}'::jsonb,'実績（治療中）：装置設定 @ordNo 使用','2005-08-01 13:30:00.000',CURRENT_TIMESTAMP,NULL);

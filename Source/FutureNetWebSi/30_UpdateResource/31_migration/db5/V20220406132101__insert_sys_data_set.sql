INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-65, 'WITH staff_cd_info AS(
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
    MAX(info ->> ''bp_max'') AS bp_max, 
    MAX(info ->> ''bp_min'') AS bp_min, 
    MAX(info ->> ''bp_ave'') AS bp_ave, 
    MAX(info ->> ''pulse'') AS pulse, 
    MAX(info ->> ''occur_date'') AS occur_date 
  FROM 
    ord_main ord 
    CROSS JOIN LATERAL json_array_elements(ord.rst_vital_info ::json) info 
  WHERE 
    ord.ord_no = @ordNo AND 
    info ->> ''bp_class'' = ''1'' AND 
    ord.facility_cd = @facilityCd AND 
    ord.is_del = ''0'' 
)
, rst_vital_info_after AS(
  --後血圧
  SELECT
    MAX(info ->> ''bp_max'') AS bp_max, 
    MAX(info ->> ''bp_min'') AS bp_min, 
    MAX(info ->> ''bp_ave'') AS bp_ave, 
    MAX(info ->> ''pulse'') AS pulse, 
    MAX(info ->> ''occur_date'') AS occur_date, 
    MAX(info ->> ''temperature'') AS temperature 
  FROM 
    ord_main ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_vital_info ::json) info 
  WHERE 
    ord.ord_no = @ordNo AND 
    info ->> ''bp_class'' = ''2'' AND 
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
) Tmp', 2, '[]', '0', '{"applications": [4]}', NULL, 'SSI）カルテ記載連携：内容取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1, "field_name": "hosp_pat_id", "replace_var": "@hospPatId"}, {"sql_cd": -1, "field_name": "pat_name", "replace_var": "@patName"}]');

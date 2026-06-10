DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (8107,-500042,-500043);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(8107, 'WITH ssi_in_hospital_cd AS ( 
  SELECT
    info->>''key2'' AS key2
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS VALUE 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = ''@facilityCd''
    AND is_del = ''0'' 
    AND COALESCE(info->>''key0'','''') = ''@key0''
    AND info->>''key1'' = ''SSI_ORDER_RECV''
    AND info->>''key2'' = ''IN_HOSPITAL_CD''
),
equipment_info AS(
    SELECT
        equipment_cd,
        equipment_name
    FROM
        mst_equipment
    WHERE
        facility_cd = ''@facilityCd''
    AND CASE (SELECT VALUE FROM ssi_in_hospital_cd)
          WHEN ''1'' THEN in_hospital_cd_1 = ''@indEquipInfo.cd''
          WHEN ''2'' THEN in_hospital_cd_2 = ''@indEquipInfo.cd''
          WHEN ''3'' THEN in_hospital_cd_3 = ''@indEquipInfo.cd''
          WHEN ''4'' THEN in_hospital_cd_4 = ''@indEquipInfo.cd''
        END
    AND is_del = ''0''
    AND is_disp = ''1''
    ORDER BY equipment_cd DESC
    LIMIT 1
)
UPDATE ord_main 
SET
  ind_equip_info = CASE ''@indEquipInfoFlg'' 
    WHEN '''' THEN ''@indEquipInfoValue'' 
    ELSE
      ind_equip_info || concat(''[{"cd":'',COALESCE((SELECT equipment_cd FROM equipment_info)::text,''''),'',
      "amount":"@indEquipInfo.amount",
      "equip_type":0,
      "ind_user_id":"@indEquipInfo.indUserId",
      "input_class":2,
      "is_editable":"@indEquipInfo.isEditable",
      "needle_type":null,
      "upd_user_id":"@indEquipInfo.updUserId",
      "cop_order_no":null,
      "ind_user_last_name":"@indEquipInfo.indUserLastName",
      "upd_user_last_name":"@indEquipInfo.updUserLastName",
      "ind_user_first_name":"@indEquipInfo.indUserFirstName",
      "upd_user_first_name":"@indEquipInfo.updUserFirstName"}]'')::jsonb 
    END 
WHERE
  ord_no = ''@ordNo''
AND
  (SELECT equipment_cd FROM equipment_info) is not null', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのオーダ受け(消耗品情報の更新)', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500042, 'WITH ssi_change_ctrl_info AS ( 
  SELECT
    info->>''key2'' AS key2
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS VALUE 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0'' 
    AND COALESCE(info->>''key0'','''') = @key0
    AND info->>''key1'' = ''SSI_CHANGE_CTRL''
)
, chenk_change_info AS (
  SELECT
    ord_no
    , info
  FROM
    ord_main 
    cross join lateral jsonb_array_elements(ord_main.ind_equip_info) info
  WHERE
    is_del = ''0'' 
    AND facility_cd = @facilityCd 
    AND ord_no = @ordNo 
    AND info->>''input_class'' = ''1''
)
SELECT
  ord_no,
  pat_id,
  fn_pat_id,
  treat_date,
  treat_week,
  facility_cd,
  facility_name,
  ind_va_cd,
  ind_treatment_cd,
  ind_treatment_name,
  ind_kur_cd,
  ind_kur_name,
  ind_treat_start_time,
  ind_bed_cd,
  ind_bed_name,
  ind_schedule_user_info,
  ind_cond_info,
  ind_medi_info,
  ind_equip_info,
  ind_ind_comment_info,
  ind_tare_info,
  ind_off_water_info,
  ind_device_set_info,
  rst_fn_dialysis_no,
  rst_relation_dialysis_no,
  rst_edition,
  rst_is_update_edition,
  rst_input_class,
  rst_dialysis_state,
  rst_treatment_cd,
  rst_treatment_name,
  rst_kur_cd,
  rst_kur_name,
  rst_bed_cd,
  rst_bed_name,
  rst_machine_no,
  rst_machine_name,
  rst_cond_send_date,
  rst_accept_date,
  rst_start_date,
  rst_end_date,
  rst_return_home_date,
  rst_in_out_class,
  rst_dialysis_cnt,
  rst_ward_cd,
  rst_ward_name,
  rst_course_cd,
  rst_course_name,
  rst_puncture_user_info,
  rst_return_user_info,
  rst_charge_user_info,
  rst_blood_circulate_total,
  rst_running_time,
  rst_kt_v,
  rec_set_date,
  send_ctl_no,
  blood_purifier_name,
  pull_leave_amount,
  rst_cond_info,
  rst_medi_info,
  rst_equip_info,
  rst_ind_comment_info,
  rst_tare_info,
  rst_off_water_info,
  rst_weight_info,
  rst_complaint_info,
  rst_treatment_info,
  rst_treat_staff_info,
  rst_rounds_info,
  is_del,
  up_date,
  reg_date,
  rst_dw,
  weight_scale_no,
  treat_type,
  is_confirm,
  ind_dw,
  rst_purification_cnt,
  addition_info,
  up_ind_user_id,
  up_user_id,
  rst_edition_date,
  cur_edition_date,
  fn_plural 
FROM
  ord_main 
WHERE
  is_del = ''0''
  AND facility_cd = @facilityCd
  AND ord_no = @ordNo
  AND (
    CASE (SELECT VALUE FROM ssi_change_ctrl_info WHERE key2 = ''EQUIPMENT'')
    WHEN ''1'' THEN NOT EXISTS (SELECT ord_no FROM chenk_change_info)
    ELSE true
    END
  )', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのオーダ受け(SELECT)', '2025-03-17 09:41:58.788', CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500043, 'WITH ssi_change_ctrl_info AS ( 
  SELECT
    info->>''key2'' AS key2
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS VALUE 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
    AND COALESCE(info->>''key0'','''') = @key0
    AND info->>''key1'' = ''SSI_CHANGE_CTRL''
) 
, chenk_change_info AS (
  SELECT
    ord_no
    , info
  FROM
    ord_main 
    cross join lateral jsonb_array_elements(ord_main.ind_medi_info) info
  WHERE
    is_del = ''0'' 
    AND facility_cd = @facilityCd 
    AND ord_no = @ordNo 
    AND info->>''input_class'' = ''1''
)
SELECT
  ord_no,
  pat_id,
  fn_pat_id,
  treat_date,
  treat_week,
  facility_cd,
  facility_name,
  ind_va_cd,
  ind_treatment_cd,
  ind_treatment_name,
  ind_kur_cd,
  ind_kur_name,
  ind_treat_start_time,
  ind_bed_cd,
  ind_bed_name,
  ind_schedule_user_info,
  ind_cond_info,
  ind_medi_info,
  ind_equip_info,
  ind_ind_comment_info,
  ind_tare_info,
  ind_off_water_info,
  ind_device_set_info,
  rst_fn_dialysis_no,
  rst_relation_dialysis_no,
  rst_edition,
  rst_is_update_edition,
  rst_input_class,
  rst_dialysis_state,
  rst_treatment_cd,
  rst_treatment_name,
  rst_kur_cd,
  rst_kur_name,
  rst_bed_cd,
  rst_bed_name,
  rst_machine_no,
  rst_machine_name,
  rst_cond_send_date,
  rst_accept_date,
  rst_start_date,
  rst_end_date,
  rst_return_home_date,
  rst_in_out_class,
  rst_dialysis_cnt,
  rst_ward_cd,
  rst_ward_name,
  rst_course_cd,
  rst_course_name,
  rst_puncture_user_info,
  rst_return_user_info,
  rst_charge_user_info,
  rst_blood_circulate_total,
  rst_running_time,
  rst_kt_v,
  rec_set_date,
  send_ctl_no,
  blood_purifier_name,
  pull_leave_amount,
  rst_cond_info,
  rst_medi_info,
  rst_equip_info,
  rst_ind_comment_info,
  rst_tare_info,
  rst_off_water_info,
  rst_weight_info,
  rst_complaint_info,
  rst_treatment_info,
  rst_treat_staff_info,
  rst_rounds_info,
  is_del,
  up_date,
  reg_date,
  rst_dw,
  weight_scale_no,
  treat_type,
  is_confirm,
  ind_dw,
  rst_purification_cnt,
  addition_info,
  up_ind_user_id,
  up_user_id,
  rst_edition_date,
  cur_edition_date,
  fn_plural 
FROM
  ord_main 
WHERE
  is_del = ''0'' 
  AND facility_cd = @facilityCd 
  AND ord_no = @ordNo 
  AND (
    CASE (SELECT VALUE FROM ssi_change_ctrl_info WHERE key2 = ''MEDICATION'')
    WHEN ''1'' THEN NOT EXISTS (SELECT ord_no FROM chenk_change_info)
    ELSE true
    END
  )', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのオーダ受け(SELECT)', '2025-03-17 09:41:58.788', CURRENT_TIMESTAMP, NULL);

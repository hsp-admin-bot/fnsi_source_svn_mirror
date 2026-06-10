delete from "sys_data_set" where "sql_cd" in (9101,9102,9103,9104,9105,9106,9107,9108,9109,9110,9111,9112,9113,9114,9115,9116,9117,9118,9119,9120,9121);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9121, 'DELETE FROM
  ord_main 
WHERE
  is_del = ''0'' 
  AND rst_edition = 0
  AND rst_treatment_cd is null
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd'' ', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NEC治療情報「指示情報」の削除', '2021-11-23 12:12:12', '2021-11-23 12:12:12', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9120, 'INSERT 
INTO ord_main_restore( 
  del_date
  , ord_no
  , pat_id
  , fn_pat_id
  , treat_date
  , treat_week
  , facility_cd
  , facility_name
  , ind_va_cd
  , ind_treatment_cd
  , ind_treatment_name
  , ind_kur_cd
  , ind_kur_name
  , ind_treat_start_time
  , ind_bed_cd
  , ind_bed_name
  , ind_schedule_user_info
  , ind_cond_info
  , ind_medi_info
  , ind_equip_info
  , ind_ind_comment_info
  , ind_tare_info
  , ind_off_water_info
  , ind_device_set_info
  , rst_fn_dialysis_no
  , rst_relation_dialysis_no
  , rst_edition
  , rst_is_update_edition
  , rst_input_class
  , rst_dialysis_state
  , rst_treatment_cd
  , rst_treatment_name
  , rst_kur_cd
  , rst_kur_name
  , rst_bed_cd
  , rst_bed_name
  , rst_machine_no
  , rst_machine_name
  , rst_cond_send_date
  , rst_accept_date
  , rst_start_date
  , rst_end_date
  , rst_return_home_date
  , rst_in_out_class
  , rst_dialysis_cnt
  , rst_ward_cd
  , rst_ward_name
  , rst_course_cd
  , rst_course_name
  , rst_puncture_user_info
  , rst_return_user_info
  , rst_charge_user_info
  , rst_blood_circulate_total
  , rst_running_time
  , rst_kt_v
  , rec_set_date
  , send_ctl_no
  , blood_purifier_name
  , pull_leave_amount
  , rst_cond_info
  , rst_medi_info
  , rst_equip_info
  , rst_ind_comment_info
  , rst_tare_info
  , rst_off_water_info
  , rst_device_set_info
  , rst_weight_info
  , rst_vital_info
  , rst_complaint_info
  , rst_treatment_info
  , rst_treat_staff_info
  , rst_rounds_info
  , is_del
  , up_date
  , reg_date
  , rst_dw
  , weight_scale_no
  , treat_type
  , is_confirm
  , ind_dw
  , rst_purification_cnt
  , addition_info
  , up_ind_user_id
  , up_user_id
  , rst_edition_date
  , cur_edition_date
  , fn_plural
) 
SELECT
  CURRENT_TIMESTAMP AS del_date
  , ord_no
  , pat_id
  , fn_pat_id
  , treat_date
  , treat_week
  , facility_cd
  , facility_name
  , ind_va_cd
  , ind_treatment_cd
  , ind_treatment_name
  , ind_kur_cd
  , ind_kur_name
  , ind_treat_start_time
  , ind_bed_cd
  , ind_bed_name
  , ind_schedule_user_info
  , ind_cond_info
  , ind_medi_info
  , ind_equip_info
  , ind_ind_comment_info
  , ind_tare_info
  , ind_off_water_info
  , ind_device_set_info
  , rst_fn_dialysis_no
  , rst_relation_dialysis_no
  , rst_edition
  , rst_is_update_edition
  , rst_input_class
  , rst_dialysis_state
  , rst_treatment_cd
  , rst_treatment_name
  , rst_kur_cd
  , rst_kur_name
  , rst_bed_cd
  , rst_bed_name
  , rst_machine_no
  , rst_machine_name
  , rst_cond_send_date
  , rst_accept_date
  , rst_start_date
  , rst_end_date
  , rst_return_home_date
  , rst_in_out_class
  , rst_dialysis_cnt
  , rst_ward_cd
  , rst_ward_name
  , rst_course_cd
  , rst_course_name
  , rst_puncture_user_info
  , rst_return_user_info
  , rst_charge_user_info
  , rst_blood_circulate_total
  , rst_running_time
  , rst_kt_v
  , rec_set_date
  , send_ctl_no
  , blood_purifier_name
  , pull_leave_amount
  , rst_cond_info
  , rst_medi_info
  , rst_equip_info
  , rst_ind_comment_info
  , rst_tare_info
  , rst_off_water_info
  , rst_device_set_info
  , rst_weight_info
  , rst_vital_info
  , rst_complaint_info
  , rst_treatment_info
  , rst_treat_staff_info
  , rst_rounds_info
  , is_del
  , up_date
  , reg_date
  , rst_dw
  , weight_scale_no
  , treat_type
  , is_confirm
  , ind_dw
  , rst_purification_cnt
  , addition_info
  , up_ind_user_id
  , up_user_id
  , rst_edition_date
  , cur_edition_date
  , fn_plural 
FROM
  ord_main 
WHERE
  is_del = ''0'' 
  AND rst_edition = 0
  AND rst_treatment_cd is null
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd'' ', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NEC治療情報「指示情報」の削除', '2021-11-23 12:12:12', '2021-11-23 12:12:12', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9119, 'UPDATE ord_main 
SET
  addition_info = CASE ''@additionInfoFlg'' 
    WHEN '''' THEN addition_info
    ELSE addition_info || ''[{"cd":"@additionInfo.cd","name":"@additionInfo.name","kind":"@additionInfo.kind"}]''
     ::jsonb 
    END 
WHERE
  ord_no = @ordNo', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NEC治療情報「指示：加算情報」の更新', '2021-11-23 12:12:12', '2021-11-23 12:12:12', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9118, 'UPDATE ord_main 
SET
  addition_info = ''[]''
WHERE
  ord_no = @ordNo
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NEC治療情報「指示：加算情報」のクリア', '2021-11-23 12:12:12', '2021-11-23 12:12:12', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9117, 'UPDATE ord_main 
SET
  ind_cond_info = jsonb_set( 
    jsonb_set( 
      jsonb_set( 
        jsonb_set( 
          jsonb_set( 
            jsonb_set( 
              jsonb_set( 
                jsonb_set( 
                  jsonb_set( 
                    jsonb_set( 
                      ind_cond_info ::JSONB
                      , ''{28, unit_name}''
                      , ''"@indCondInfo.28.unitName"'' ::JSONB
                    ) ::JSONB
                    , ''{28, unit}''
                    , ''"@indCondInfo.28.unit"'' ::JSONB
                  ) ::JSONB
                  , ''{28, value}''
                  , ''"@indCondInfo.28.value"'' ::JSONB
                ) ::JSONB
                , ''{27, unit_name}''
                , ''"@indCondInfo.27.unitName"'' ::JSONB
              ) ::JSONB
              , ''{27, unit}''
              , ''"@indCondInfo.27.unit"'' ::JSONB
            ) ::JSONB
            , ''{27, value}''
            , ''@indCondInfo.27.value'' ::JSONB
          ) ::JSONB
          , ''{25, value_name_1}''
          , ''"@indCondInfo.25.valueName1"'' ::JSONB
        ) ::JSONB
        , ''{25, value}''
        , ''"@indCondInfo.25.value"'' ::JSONB
      ) ::JSONB
      , ''{9, value_name_1}''
      , ''"@indCondInfo.9.valueName1"'' ::JSONB
    ) ::JSONB
    , ''{9, value}''
    , ''"@indCondInfo.9.value"'' ::JSONB
  ) 
WHERE
  ord_no = @ordNo', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NECの治療情報「指示：治療条件情報)」の更新', '2021-11-23 12:12:12', '2021-11-23 12:12:12', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9116, 'UPDATE ord_main 
SET
  treat_date = ''@treatDate''
  , ind_treatment_cd = CASE ''@indTreatmentCd'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@indTreatmentCd'', ''999999999'') 
    END
  , ind_treatment_name = NULLIF(''@indTreatmentName'', '''')
  , up_date = CURRENT_TIMESTAMP 
WHERE
  ord_no = @ordNo
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NECの治療情報(UPDATE)', '2021-11-23 12:12:12', '2021-11-23 12:12:12', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9115, 'INSERT INTO ord_main( 
  pat_id
  , fn_pat_id
  , treat_date
  , treat_week
  , facility_cd
  , facility_name
  , ind_va_cd
  , ind_treatment_cd
  , ind_treatment_name
  , ind_kur_cd
  , ind_kur_name
  , ind_treat_start_time
  , ind_bed_cd
  , ind_bed_name
  , ind_schedule_user_info
  , ind_cond_info
  , ind_medi_info
  , ind_equip_info
  , ind_ind_comment_info
  , ind_tare_info
  , ind_off_water_info
  , ind_device_set_info
  , rst_fn_dialysis_no
  , rst_relation_dialysis_no
  , rst_edition
  , rst_is_update_edition
  , rst_input_class
  , rst_dialysis_state
  , rst_treatment_cd
  , rst_treatment_name
  , rst_kur_cd
  , rst_kur_name
  , rst_bed_cd
  , rst_bed_name
  , rst_machine_no
  , rst_machine_name
  , rst_cond_send_date
  , rst_accept_date
  , rst_start_date
  , rst_end_date
  , rst_return_home_date
  , rst_in_out_class
  , rst_dialysis_cnt
  , rst_ward_cd
  , rst_ward_name
  , rst_course_cd
  , rst_course_name
  , rst_puncture_user_info
  , rst_return_user_info
  , rst_charge_user_info
  , rst_blood_circulate_total
  , rst_running_time
  , rst_kt_v
  , rec_set_date
  , send_ctl_no
  , blood_purifier_name
  , pull_leave_amount
  , rst_cond_info
  , rst_medi_info
  , rst_equip_info
  , rst_ind_comment_info
  , rst_tare_info
  , rst_off_water_info
  , rst_device_set_info
  , rst_weight_info
  , rst_vital_info
  , rst_complaint_info
  , rst_treatment_info
  , rst_treat_staff_info
  , rst_rounds_info
  , is_del
  , up_date
  , reg_date
  , rst_dw
  , weight_scale_no
  , treat_type
  , is_confirm
  , ind_dw
  , rst_purification_cnt
  , addition_info
  , up_ind_user_id
  , up_user_id
  , rst_edition_date
  , cur_edition_date
  , fn_plural
) 
VALUES ( 
  @patId
  , NULLIF(''@fnPatId'', '''')
  , ''@treatDate''
  , CASE 
    WHEN EXTRACT(DOW FROM ''@treatDate'' ::TIMESTAMP) = ''0'' 
      THEN 7 
    ELSE EXTRACT(DOW FROM ''@treatDate'' ::TIMESTAMP) 
    END
  , ''@facilityCd''
  , NULLIF(''@facilityName'', '''')
  , CASE ''@indVaCd'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@indVaCd'', ''999999999'') 
    END
  , CASE ''@indTreatmentCd'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@indTreatmentCd'', ''999999999'') 
    END
  , NULLIF(''@indTreatmentName'', '''')
  , CASE ''@indKurCd'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@indKurCd'', ''999999999999999999'') 
    END
  , NULLIF(''@indKurName'', '''')
  , NULLIF(''@indTreatStartTime'', '''')
  , CASE ''@indBedCd'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@indBedCd'', ''999999999999999999'') 
    END
  , NULLIF(''@indBedName'', '''')
  , CASE ''@indScheduleUserInfoFlg'' 
    WHEN '''' THEN json_build_object( 
      ''ind_user_id''
      , NULL
      , ''ind_user_last_name''
      , NULL
      , ''ind_user_first_name''
      , NULL
      , ''upd_user_id''
      , NULL
      , ''upd_user_last_name''
      , NULL
      , ''upd_user_first_name''
      , NULL
    ) 
    ELSE json_build_object( 
      ''ind_user_id''
      , CASE ''@indScheduleUserInfo.indUserId'' 
        WHEN '''' THEN NULL 
        ELSE TO_NUMBER(''@indScheduleUserInfo.indUserId'', ''999999999'') 
        END
      , ''ind_user_last_name''
      , NULLIF( 
        split_part( ''@indScheduleUserInfo.indUserLastName '', ''　'', 1 )
        , ''''
      ) 
      , ''ind_user_first_name''
      , NULLIF( 
        split_part( ''@indScheduleUserInfo.indUserFirstName '', ''　'', 2)
        , ''''
      ) 
      , ''upd_user_id''
      , CASE ''@indScheduleUserInfo.updUserId'' 
        WHEN '''' THEN NULL 
        ELSE TO_NUMBER(''@indScheduleUserInfo.updUserId'', ''999999999'') 
        END
      , ''upd_user_last_name''
      , NULLIF( 
        split_part( ''@indScheduleUserInfo.updUserLastName '', ''　'', 1 )
        , ''''
      ) 
      , ''upd_user_first_name''
      , NULLIF( 
        split_part( ''@indScheduleUserInfo.updUserFirstName '', ''　'', 2)
        , ''''
      )
    ) 
    END
  , ''{"1": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "2": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "3": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "4": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "5": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "6": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "7": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "8": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "9": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "10": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "11": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "12": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "13": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "14": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "15": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "16": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "17": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "18": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "19": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "20": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "21": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "22": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "23": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "24": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "25": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "26": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "27": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "28": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "29": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "30": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "31": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "32": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "33": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "34": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "35": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "36": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "37": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}, "38": {"unit": null, "value": null, "ind_user_id": null, "input_class": null, "is_editable": null, "upd_user_id": null, "cop_order_no": null, "value_name_1": null, "medicine_type": null, "ind_user_last_name": null, "upd_user_last_name": null, "ind_user_first_name": null, "upd_user_first_name": null}}''
  , ''@indMediInfoValue''
  , ''@indEquipInfoValue'' 
  , ''@indIndCommentInfoValue''
  , CASE ''@indTareInfoFlg'' 
    WHEN '''' THEN json_build_object( 
      ''name_1''
      , NULL
      , ''name_2''
      , NULL
      , ''name_3''
      , NULL
      , ''name_4''
      , NULL
      , ''name_5''
      , NULL
      , ''weight_1''
      , NULL
      , ''weight_2''
      , NULL
      , ''weight_3''
      , NULL
      , ''weight_4''
      , NULL
      , ''weight_5''
      , NULL
    ) 
    ELSE json_build_object( 
      ''name_1''
      , NULLIF(''@indTareInfo.name1'', '''')
      , ''name_2''
      , NULLIF(''@indTareInfo.name2'', '''')
      , ''name_3''
      , NULLIF(''@indTareInfo.name3'', '''')
      , ''name_4''
      , NULLIF(''@indTareInfo.name4'', '''')
      , ''name_5''
      , NULLIF(''@indTareInfo.name5'', '''')
      , ''weight_1''
      , CASE ''@indTareInfo.weight1'' 
        WHEN '''' THEN 0 
        ELSE TO_NUMBER(''@indTareInfo.weight1'', ''999999999'') 
        END
      , ''weight_2''
      , CASE ''@indTareInfo.weight2'' 
        WHEN '''' THEN 0 
        ELSE TO_NUMBER(''@indTareInfo.weight2'', ''999999999'') 
        END
      , ''weight_3''
      , CASE ''@indTareInfo.weight2'' 
        WHEN '''' THEN 0 
        ELSE TO_NUMBER(''@indTareInfo.weight2'', ''999999999'') 
        END
      , ''weight_4''
      , CASE ''@indTareInfo.weight4'' 
        WHEN '''' THEN 0 
        ELSE TO_NUMBER(''@indTareInfo.weight4'', ''999999999'') 
        END
      , ''weight_5''
      , CASE ''@indTareInfo.weight5'' 
        WHEN '''' THEN 0 
        ELSE TO_NUMBER(''@indTareInfo.weight5'', ''999999999'') 
        END
    ) 
    END
  , CASE ''@indOffWaterInfoFlg'' 
    WHEN '''' THEN json_build_object( 
      ''name_1''
      , NULL
      , ''name_2''
      , NULL
      , ''name_3''
      , NULL
      , ''name_4''
      , NULL
      , ''name_5''
      , NULL
      , ''weight_1''
      , NULL
      , ''weight_2''
      , NULL
      , ''weight_3''
      , NULL
      , ''weight_4''
      , NULL
      , ''weight_5''
      , NULL
    ) 
    ELSE json_build_object( 
      ''name_1''
      , NULLIF(''@indOffWaterInfo.name1'', '''')
      , ''name_2''
      , NULLIF(''@indOffWaterInfo.name2'', '''')
      , ''name_3''
      , NULLIF(''@indOffWaterInfo.name3'', '''')
      , ''name_4''
      , NULLIF(''@indOffWaterInfo.name4'', '''')
      , ''name_5''
      , NULLIF(''@indOffWaterInfo.name5'', '''')
      , ''weight_1''
      , CASE ''@indOffWaterInfo.weight1'' 
        WHEN '''' THEN 0 
        ELSE TO_NUMBER(''@indOffWaterInfo.weight1'', ''999999999'') 
        END
      , ''weight_2''
      , CASE ''@indOffWaterInfo.weight2'' 
        WHEN '''' THEN 0 
        ELSE TO_NUMBER(''@indOffWaterInfo.weight2'', ''999999999'') 
        END
      , ''weight_3''
      , CASE ''@indOffWaterInfo.weight2'' 
        WHEN '''' THEN 0 
        ELSE TO_NUMBER(''@indOffWaterInfo.weight2'', ''999999999'') 
        END
      , ''weight_4''
      , CASE ''@indOffWaterInfo.weight4'' 
        WHEN '''' THEN 0 
        ELSE TO_NUMBER(''@indOffWaterInfo.weight4'', ''999999999'') 
        END
      , ''weight_5''
      , CASE ''@indOffWaterInfo.weight5'' 
        WHEN '''' THEN 0 
        ELSE TO_NUMBER(''@indOffWaterInfo.weight5'', ''999999999'') 
        END
    ) 
    END
  , ''{"bp": {"dev": {"A": {"190": 27, "191": "1", "192": 134, "193": "0", "194": "1", "195": "2", "211": 111, "212": 82, "213": 80, "214": 46, "215": 70, "216": 64, "217": 60, "218": 48, "219": "1", "220": "1", "221": "1", "222": "1", "223": "1", "224": "1", "225": "1", "226": "1", "227": 104, "228": 104, "229": 0.15, "230": 0.06, "231": 12, "232": 5, "233": 5.93, "234": 0.08, "235": 10, "236": 19, "237": "1", "238": "1", "239": "0"}}}, "bv": {"dev": {"A": {"258": "0", "259": 3, "260": -18.8, "261": -39.5, "262": -9.6, "263": 63, "264": 66, "265": 68, "266": 81, "267": "0", "277": 0.05, "278": 7, "281": 23}}}, "iap": {"dev": {"A": {"468": 78, "469": 0.5, "470": "2", "471": "1"}}}, "ope": {"dev": {"A": {"21": "1", "22": "1", "24": 200, "25": 100, "38": "1", "39": 4, "90": 52, "91": 33, "92": 6.5, "168": 51, "169": -51, "171": 52, "172": -52, "174": 53, "175": -53, "177": 54, "178": -54, "179": 300, "181": 2.03, "182": 40, "183": 33, "185": 5.98, "186": 5.97, "241": "1", "268": "2", "269": 2, "336": 107, "337": 106, "369": "2", "379": 22, "383": 99.9, "384": "1", "385": 13, "386": 2.5, "387": 1, "389": "0", "391": 56, "392": -56, "394": 57, "395": -57, "396": 11.97, "397": 11.96, "398": 2, "472": 3, "473": 2, "474": 8, "475": 3, "476": "1", "477": 129}, "B": {"30": 11.98, "31": 5.99, "32": 5.96, "33": 5.95, "34": 5.93, "35": 5.92, "37": 55, "38": -55, "39": 20, "40": 42}, "C": {"91": "-", "92": "-"}}}, "pri": {"dev": {"A": {"370": 194, "371": 93, "372": "1"}}, "pat": {"A": {"219": 203, "220": 97, "221": 200, "222": 97, "223": 398, "224": 296, "225": "1", "226": "1", "227": "1", "228": 796, "229": 2.3, "230": 1.4, "231": 416, "232": 44, "233": 254, "234": 254, "235": 245, "236": 394, "237": 294, "238": 604}, "B": {"32": 90, "33": 3, "51": 2, "52": 60, "53": 8}}}, "war": {"dev": {"A": {"100": 51, "101": -31, "102": 301, "103": 10, "104": 296, "105": -50, "106": 71, "107": -70, "108": 375, "109": -182, "110": 379, "111": -50, "112": 53, "113": -53, "114": 303, "115": -302, "116": 297, "117": -297, "118": 74, "119": -73, "120": 90, "121": -72, "122": 303, "123": -292, "124": 289, "125": -306, "126": 20, "127": -20, "128": 54, "129": -54, "130": 494, "131": -28, "132": 494, "133": -28, "134": 48, "135": -50, "136": 77, "137": -72, "138": 55, "139": -45, "140": 86, "141": -67, "142": 474, "143": -25, "144": 493, "145": -35, "146": 25, "147": -24, "148": 78, "149": 2, "150": 59, "151": -52, "152": 52, "153": -52, "154": 302, "155": 0, "156": 298, "157": -49, "158": 73, "159": -71, "160": 479, "161": -184, "162": 497, "163": -53, "240": "0", "242": "0", "243": "0", "244": "0", "245": "0", "246": "0", "247": "0", "254": 5, "255": -5, "256": 173, "257": 134}}}, "cpro": {"dev": {"A": {"250": 5.6, "251": -4.6, "252": 6.1, "253": -4.7}}}, "dfas": {"dev": {"A": {"270": "0", "331": 146, "332": -203, "333": 103, "334": 155, "338": 46, "339": "1", "373": 104, "374": 255, "376": 34, "377": "1", "378": "1"}, "B": {"36": "0"}}, "pat": {"B": {"1": "0", "5": 293, "7": 29, "8": 214, "9": 0, "10": 150, "54": 57, "55": 200, "56": 0, "57": 142, "58": 0.2, "59": 154}}}, "ecum": {"dev": {"A": {"16": "1", "17": 0.03, "18": 31, "19": "0"}}}}''
  , NULL
  , NULL
  , 0
  , NULL
  , NULL
  , ''0''
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , ''0''
  , CURRENT_TIMESTAMP
  , CURRENT_TIMESTAMP
  , NULL
  , NULL
  , 1
  , 0
  , NULL
  , NULL
  , NULL
  , NULL
  , CASE ''@upUserId'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@upUserId'', ''999999999999999999'') 
    END
  , NULL
  , NULL
  , NULL
)', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NECの治療情報(INSERT)', '2021-11-23 12:12:12', '2021-11-23 12:12:12', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9114, 'SELECT
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
  rst_device_set_info,
  rst_weight_info,
  rst_vital_info,
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
  AND pat_id = @patId 
  AND facility_cd = @facilityCd 
  AND treat_date = @treatDate', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NECの治療情報(SELECT)', '2021-11-23 12:12:12', '2021-11-23 12:12:12', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9113, 'UPDATE pat_coop_detail 
SET
  save_1 = jsonb_build_object(''key_01'',NULLIF(''@save1.key01'', ''''), ''key_02'',NULLIF(''@save1.key02'', ''''), ''key_03'',NULLIF(''@save1.key03'', ''''), ''key_04'',NULLIF(''@save1.key04'', ''''), ''key_05'',NULLIF(''@save1.key05'', ''''), ''key_06'',NULLIF(''@save1.key06'', ''''), ''key_07'',NULLIF(''@save1.key07'', ''''), ''key_08'',NULLIF(''@save1.key08'', ''''), ''key_09'',NULLIF(''@save1.key09'', ''''), ''key_10'',NULLIF(''@save1.key10'', ''''))
  , user_id = @userId
  , up_date = CURRENT_TIMESTAMP 
WHERE
  is_del = ''0'' 
  AND coop_save_no = @coopSaveNo
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd'' ', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NECの患者連携情報の更新', '2021-11-23 12:12:12', '2021-11-23 12:12:12', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9112, 'INSERT INTO pat_coop_detail( 
  facility_cd
  , pat_id
  , save_1
  , save_2
  , save_3
  , save_4
  , save_5
  , save_6
  , save_7
  , save_8
  , save_9
  , save_10
  , is_disp
  , is_del
  , user_id
  , up_date
  , reg_date
) 
VALUES (
  ''@facilityCd''
  , @patId
  , jsonb_build_object(''key_01'',NULLIF(''@save1.key01'', ''''), ''key_02'',NULLIF(''@save1.key02'', ''''), ''key_03'',NULLIF(''@save1.key03'', ''''), ''key_04'',NULLIF(''@save1.key04'', ''''), ''key_05'',NULLIF(''@save1.key05'', ''''), ''key_06'',NULLIF(''@save1.key06'', ''''), ''key_07'',NULLIF(''@save1.key07'', ''''), ''key_08'',NULLIF(''@save1.key08'', ''''), ''key_09'',NULLIF(''@save1.key09'', ''''), ''key_10'',NULLIF(''@save1.key10'', ''''))
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , ''1''
  , ''0''
  , @userId
  , CURRENT_TIMESTAMP
  , CURRENT_TIMESTAMP
)', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NECの患者連携情報の登録', '2021-11-23 12:12:12', '2021-11-23 12:12:12', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9111, 'SELECT
    coop_save_no
  , facility_cd
  , pat_id
  , save_1
  , save_2
  , save_3
  , save_4
  , save_5
  , save_6
  , save_7
  , save_8
  , save_9
  , save_10
  , is_disp
  , is_del
  , user_id
  , up_date
  , reg_date
FROM
  pat_coop_detail 
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = @facilityCd ', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NECの患者連携情報の取得', '2021-11-23 12:12:12', '2021-11-23 12:12:12', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9110, 'UPDATE pat_insurance 
SET
  up_date = CURRENT_TIMESTAMP 
WHERE
  is_del = ''0'' 
  AND insurance_cd = @insuranceCd
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd'' ', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NECの保険情報の更新', '2021-11-23 12:12:12', '2021-11-23 12:12:12', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9109, 'INSERT INTO pat_insurance( 
  pat_id
  , facility_cd
  , ctl_no
  , fn_pat_id
  , insu_class
  , insu_name
  , insu_name_short
  , insu_info
  , insu_pub_info
  , insu_set_info
  , insu_self_info
  , is_selected
  , is_disp
  , is_del
  , coop_code
  , is_coop
  , reg_date
  , up_date
  , start_date
  , end_date
  , check_date
  , old_up_date
  , memo1
  , memo2
) 
VALUES (
  @patId
  , ''@facilityCd''
  , (SELECT (COALESCE(MAX(ctl_no), -1) + 1) AS ctl_no FROM pat_insurance AS pis WHERE pis.is_del = ''0'' AND pis.pat_id = @patId AND pis.facility_cd = ''@facilityCd'')
  , NULL
  , 9
  , ''外部連携登録''
  , NULL
  , ''{"futan-g": null, "futan-n": null, "insu_no": null, "und_six": "0", "insu_kbn": "0", "cki_class": "0", "kki_class": "0", "insu_pat_no": null, "insu_pat_mark": null, "insu_pat_name": null}''
  , ''{"insu_pub_no": null, "passbook_no": null, "insu_pub_name": null, "insu_pub_pat_no": null}''
  , ''{"insu_cd": null, "insu_pub1_cd": null, "insu_pub2_cd": null, "insu_pub3_cd": null, "insu_pub4_cd": null}''
  , ''{"insu_self_name": null}''
  , ''0''
  , ''1''
  , ''0''
  , NULLIF(''@coopCode'', '''')
  , ''1''
  , CURRENT_TIMESTAMP
  , CURRENT_TIMESTAMP
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
)', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NECの保険情報の登録', '2021-11-23 12:12:12', '2021-11-23 12:12:12', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9108, 'SELECT
  insurance_cd
  , pat_id
  , facility_cd
  , ctl_no
  , fn_pat_id
  , insu_class
  , insu_name
  , insu_name_short
  , start_date
  , end_date
  , check_date
  , insu_info
  , insu_pub_info
  , insu_set_info
  , insu_self_info
  , is_selected
  , is_disp
  , is_del
  , coop_code
  , is_coop
  , reg_date
  , up_date
  , check_date
  , old_up_date 
FROM
  pat_insurance 
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = @facilityCd 
  AND coop_code = @coopCode', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NECの保険情報の取得', '2021-11-23 12:12:12', '2021-11-23 12:12:12', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9107, 'UPDATE pat_unique 
SET
  physical_info = CASE WHEN ''@physicalInfo.height''='''' AND ''@physicalInfo.dw''='''' AND ''@physicalInfo.ctrWeight''='''' THEN physical_info
 ELSE ''[{"ctl_no":1, "exam_date":null, "order_class":"@physicalInfo.orderClass", "height":"@physicalInfo.height", "ctr_weight":"@physicalInfo.ctrWeight", "breast_dia":null, "chest_dia":null, "ctr":null, "dw":"@physicalInfo.dw", "indicator_cd":null, "indicator_start_date":null, "memo":null, "pre_scale_upper":null, "pre_scale_lower":null, "facility_cd": null}]''::jsonb END 
WHERE
  pat_id = @patId 
  AND facility_cd = ''@facilityCd'' 
  AND is_del = ''0''
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NECの患者固有情報「身体情報」の更新', '2021-11-23 12:12:12', '2021-11-23 12:12:12', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9106, 'INSERT 
INTO pat_unique( 
  pat_id
  , medical_hst_info
  , in_out_visit_history_info
  , physical_info
  , is_del
  , up_date
  , reg_date
  , facility_cd
  , old_up_date_unique
) 
VALUES ( 
  @patId
  , ''[]''
  , ''[]''
  , CASE WHEN ''@physicalInfo.height''='''' AND ''@physicalInfo.dw''='''' AND ''@physicalInfo.ctrWeight''='''' THEN ''[]''
 ELSE ''[{"ctl_no":1, "exam_date":null, "order_class":"@physicalInfo.orderClass", "height":"@physicalInfo.height", "ctr_weight":"@physicalInfo.ctrWeight", "breast_dia":null, "chest_dia":null, "ctr":null, "dw":"@physicalInfo.dw", "indicator_cd":null, "indicator_start_date":null, "memo":null, "pre_scale_upper":null, "pre_scale_lower":null, "facility_cd": null}]''::jsonb END 
  , ''0''
  , CURRENT_TIMESTAMP
  , CURRENT_TIMESTAMP
  , ''@facilityCd''
  , NULL
)', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NECの患者固有情報「身体情報」の登録', '2021-11-23 12:12:12', '2021-11-23 12:12:12', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9105, 'WITH infection_nec_sub AS ( 
  -- NECから、感染症情報
  SELECT
    1 AS order_no
    , SUBSTRING(''@infectInfo'', 1, 1) AS CONTENT 
  UNION 
  SELECT
    2 AS order_no
    , SUBSTRING(''@infectInfo'', 2, 1) AS CONTENT 
  UNION 
  SELECT
    3 AS order_no
    , SUBSTRING(''@infectInfo'', 3, 1) AS CONTENT 
  UNION 
  SELECT
    4 AS order_no
    , SUBSTRING(''@infectInfo'', 4, 1) AS CONTENT 
  UNION 
  SELECT
    5 AS order_no
    , SUBSTRING(''@infectInfo'', 5, 1) AS CONTENT 
  UNION 
  SELECT
    6 AS order_no
    , SUBSTRING(''@infectInfo'', 6, 1) AS CONTENT 
  UNION 
  SELECT
    7 AS order_no
    , SUBSTRING(''@infectInfo'', 7, 1) AS CONTENT 
  UNION 
  SELECT
    8 AS order_no
    , SUBSTRING(''@infectInfo'', 8, 1) AS CONTENT 
  UNION 
  SELECT
    9 AS order_no
    , SUBSTRING(''@infectInfo'', 9, 1) AS CONTENT 
  UNION 
  SELECT
    10 AS order_no
    , SUBSTRING(''@infectInfo'', 10, 1) AS CONTENT 
  UNION 
  SELECT
    11 AS order_no
    , SUBSTRING(''@infectInfo'', 11, 1) AS CONTENT 
  UNION 
  SELECT
    12 AS order_no
    , SUBSTRING(''@infectInfo'', 12, 1) AS CONTENT 
  UNION 
  SELECT
    13 AS order_no
    , SUBSTRING(''@infectInfo'', 13, 1) AS CONTENT 
  UNION 
  SELECT
    14 AS order_no
    , SUBSTRING(''@infectInfo'', 14, 1) AS CONTENT 
  UNION 
  SELECT
    15 AS order_no
    , SUBSTRING(''@infectInfo'', 15, 1) AS CONTENT 
  UNION 
  SELECT
    16 AS order_no
    , SUBSTRING(''@infectInfo'', 16, 1) AS CONTENT 
  UNION 
  SELECT
    17 AS order_no
    , SUBSTRING(''@infectInfo'', 17, 1) AS CONTENT 
  UNION 
  SELECT
    18 AS order_no
    , SUBSTRING(''@infectInfo'', 18, 1) AS CONTENT 
  UNION 
  SELECT
    19 AS order_no
    , SUBSTRING(''@infectInfo'', 19, 1) AS CONTENT 
  UNION 
  SELECT
    20 AS order_no
    , SUBSTRING(''@infectInfo'', 20, 1) AS CONTENT 
  ORDER BY
    order_no ASC
) 
, infection_ini AS ( 
  SELECT
    TO_NUMBER( 
      REPLACE (ini_info ->> ''key2'', ''INFECT_'', '''')
      , ''FM99''
    ) AS order_no
    , CASE 
      WHEN NULLIF(ini_info ->> ''value'', '''') IS NULL 
        THEN ini_info ->> ''default_v'' 
      ELSE ini_info ->> ''value'' 
      END AS hospital_cd 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.facility_cd = ''@facilityCd'' 
    AND ini_info ->> ''key1'' = ''NEC'' 
    AND ini_info ->> ''key2'' LIKE ''INFECT_%'' 
  ORDER BY
    TO_NUMBER( 
      REPLACE (ini_info ->> ''key2'', ''INFECT_'', '''')
      , ''FM99''
    ) ASC
) 
, infection_nec AS ( 
  SELECT
    ini.hospital_cd
    , CASE sub.CONTENT 
      WHEN ''+'' THEN ''2'' 
      WHEN ''-'' THEN ''1'' 
      WHEN ''?'' THEN ''0'' 
      ELSE NULL 
      END AS CONTENT 
  FROM
    infection_nec_sub AS sub 
    INNER JOIN infection_ini AS ini 
      ON sub.order_no = ini.order_no
) 
, infection_ntss AS ( 
  SELECT
    A.infection_cd
    , A.in_hospital_cd_1 AS hospital_cd 
  FROM
    mst_infection A
    , ( 
      SELECT
        mss.facility_cd
        , ms.*
        , ROW_NUMBER() OVER () AS INDEX 
      FROM
        mst_selector mss 
        CROSS JOIN LATERAL jsonb_to_recordset(mss.order_settings -> ''items'') AS ms(code BIGINT, NAME TEXT) 
      WHERE
        facility_cd = ''@facilityCd'' 
        AND master_physical_name = ''mst_infection''
    ) ms 
  WHERE
    A.facility_cd = ms.facility_cd 
    AND A.infection_cd = ms.code 
    AND A.is_del = ''0'' 
    AND A.is_disp = ''1'' 
  ORDER BY
    ms.INDEX
) 
, infectInfo AS ( 
  SELECT
    array_to_json( 
      ARRAY_AGG( 
        CASE 
          WHEN NULLIF(infection_nec.CONTENT, '''') IS NULL 
            THEN info.* 
          ELSE json_build_object( 
            ''infect''
            , infection_nec.CONTENT
            , ''exam_date''
            , info ->> ''exam_date''
            , ''up_date''
            , TO_CHAR(CURRENT_DATE, ''YYYYMMDD'')
            , ''infection_cd''
            , info ->> ''infection_cd''
          ) 
          END
      )
    ) AS infect_info_new 
  FROM
    pat_main AS pat 
    CROSS JOIN LATERAL json_array_elements(pat.infect_info ::json) info 
    LEFT OUTER JOIN infection_ntss 
      ON infection_ntss.infection_cd ::TEXT = info ->> ''infection_cd'' 
    LEFT OUTER JOIN infection_nec 
      ON infection_nec.hospital_cd = infection_ntss.hospital_cd 
      AND NULLIF(infection_nec.CONTENT, '''') IS NOT NULL 
  WHERE
    pat.pat_id = @patId
) 
, taboo_allergy_nec_sub AS ( 
  -- NECから、薬剤禁忌情報
  SELECT
    1 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 1, 1) AS CONTENT 
  UNION 
  SELECT
    2 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 2, 1) AS CONTENT 
  UNION 
  SELECT
    3 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 3, 1) AS CONTENT 
  UNION 
  SELECT
    4 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 4, 1) AS CONTENT 
  UNION 
  SELECT
    5 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 5, 1) AS CONTENT 
  UNION 
  SELECT
    6 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 6, 1) AS CONTENT 
  UNION 
  SELECT
    7 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 7, 1) AS CONTENT 
  UNION 
  SELECT
    8 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 8, 1) AS CONTENT 
  UNION 
  SELECT
    9 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 9, 1) AS CONTENT 
  UNION 
  SELECT
    10 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 10, 1) AS CONTENT 
  UNION 
  SELECT
    11 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 11, 1) AS CONTENT 
  UNION 
  SELECT
    12 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 12, 1) AS CONTENT 
  UNION 
  SELECT
    13 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 13, 1) AS CONTENT 
  UNION 
  SELECT
    14 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 14, 1) AS CONTENT 
  UNION 
  SELECT
    15 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 15, 1) AS CONTENT 
  UNION 
  SELECT
    16 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 16, 1) AS CONTENT 
  UNION 
  SELECT
    17 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 17, 1) AS CONTENT 
  UNION 
  SELECT
    18 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 18, 1) AS CONTENT 
  UNION 
  SELECT
    19 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 19, 1) AS CONTENT 
  UNION 
  SELECT
    20 AS order_no
    , SUBSTRING(''@tabooAllergyInfo'', 20, 1) AS CONTENT 
  ORDER BY
    order_no ASC
) 
, taboo_allergy_ini AS ( 
  SELECT
    TO_NUMBER( 
      REPLACE (ini_info ->> ''key2'', ''TABOO_'', '''')
      , ''FM99''
    ) AS order_no
    , CASE 
      WHEN NULLIF(ini_info ->> ''value'', '''') IS NULL 
        THEN ini_info ->> ''default_v'' 
      ELSE ini_info ->> ''value'' 
      END AS hospital_cd 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.facility_cd = ''@facilityCd'' 
    AND ini_info ->> ''key1'' = ''NEC'' 
    AND ini_info ->> ''key2'' LIKE ''TABOO_%'' 
    AND ini_info ->> ''key2'' <> ''TABOO_CTL_NO'' 
  ORDER BY
    TO_NUMBER( 
      REPLACE (ini_info ->> ''key2'', ''TABOO_'', '''')
      , ''FM99''
    ) ASC
) 
, taboo_allergy_nec AS ( 
  SELECT
    ini.order_no
    , ini.hospital_cd
    , ROW_NUMBER() OVER () AS index_no 
  FROM
    taboo_allergy_nec_sub AS sub 
    INNER JOIN taboo_allergy_ini AS ini 
      ON sub.order_no = ini.order_no 
  WHERE
    sub.CONTENT = ''1'' 
  ORDER BY
    ini.order_no
) 
, taboo_allergy_ntss AS ( 
  SELECT
    A.taboo_allergy_cd
    , A.in_hospital_cd_1 AS hospital_cd
    , A.CONTENT 
  FROM
    mst_taboo_allergy A
    , ( 
      SELECT
        mss.facility_cd
        , ms.*
        , ROW_NUMBER() OVER () AS INDEX 
      FROM
        mst_selector mss 
        CROSS JOIN LATERAL jsonb_to_recordset(mss.order_settings -> ''items'') AS ms(code BIGINT, NAME TEXT) 
      WHERE
        facility_cd = ''@facilityCd'' 
        AND master_physical_name = ''mst_taboo_allergy''
    ) ms 
  WHERE
    A.facility_cd = ms.facility_cd 
    AND A.taboo_allergy_cd = ms.code 
    AND A.is_del = ''0'' 
    AND A.is_disp = ''1'' 
  ORDER BY
    ms.INDEX
) 
, tabooAllergyInfo AS ( 
  SELECT
    array_to_json( 
      ARRAY_AGG( 
        CASE 
          WHEN ntss_hospital_cd.taboo_allergy_cd IS NOT NULL 
            THEN json_build_object( 
            ''memo''
            , NULL
            , ''ctl_no''
            , nec.index_no
            , ''content''
            , ntss_hospital_cd.CONTENT
            , ''disp_order''
            , nec.index_no
            , ''category_class''
            , ''0''
            , ''taboo_allergy_cd''
            , ntss_hospital_cd.taboo_allergy_cd
            , ''taboo_allergy_class''
            , ''1''
          ) 
          ELSE json_build_object( 
            ''memo''
            , NULL
            , ''ctl_no''
            , nec.index_no
            , ''content''
            , ntss_content.CONTENT
            , ''disp_order''
            , nec.index_no
            , ''category_class''
            , ''0''
            , ''taboo_allergy_cd''
            , ntss_content.taboo_allergy_cd
            , ''taboo_allergy_class''
            , ''1''
          ) 
          END
      )
    ) AS taboo_allergy_info_new 
  FROM
    taboo_allergy_nec AS nec 
    LEFT OUTER JOIN taboo_allergy_ntss AS ntss_hospital_cd 
      ON nec.hospital_cd = ntss_hospital_cd.hospital_cd 
    LEFT OUTER JOIN taboo_allergy_ntss AS ntss_content 
      ON nec.hospital_cd = ntss_content.CONTENT
) UPDATE pat_main 
SET
  charge_staff_info = CASE ''@chargeStaffInfo.staff_cd'' 
    WHEN '''' THEN charge_staff_info 
    ELSE charge_staff_info || ''[{"ctl_no":0, "disp_order":0, "staff_cd":"@chargeStaffInfo.staffCd", "is_main":"1", "is_charge":"0", "is_puncture":"0"}]''
     ::jsonb 
    END
  , infect_info = (SELECT infect_info_new FROM infectInfo) ::JSONB
  , taboo_allergy_info = COALESCE( 
    NULLIF( 
      ( 
        SELECT
          taboo_allergy_info_new 
        FROM
          tabooAllergyInfo
      ) ::TEXT
      , ''''
    ) 
    , ''[]''
  ) ::JSONB 
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NECの「担当スタッフ情報、感染症情報、禁忌・アレルギー情報」の更新', '2021-11-23 12:12:12', '2021-11-23 12:12:12', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9104, 'UPDATE pat_main 
SET charge_staff_info = ''[]'', 
--  infect_info = ''[]'', 
  taboo_allergy_info = ''[]'' 
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd'' ', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NECの「担当スタッフ情報、感染症情報、禁忌・アレルギー情報」のクリア', '2021-11-23 12:12:12', '2021-11-23 12:12:12', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9103, 'WITH pat_name AS (
  SELECT 
    COALESCE((split_part( ''@otherContactInfo.patName'', ''　'', 1 )), '''') AS last_name,
    COALESCE((split_part( ''@otherContactInfo.patName'', ''　'', 2 )), '''') AS first_name,
    CASE WHEN split_part( ''@otherContactInfo.patNameKana'', ''　'', 2 ) IS NULL OR split_part( ''@otherContactInfo.patNameKana'', ''　'', 2 ) = '''' THEN
      COALESCE((split_part( ''@otherContactInfo.patNameKana'', '' '', 1 )), '''')
    ELSE 
      COALESCE((split_part( ''@otherContactInfo.patNameKana'', '' '', 1 )), '''')
    END AS last_name_kana,
    CASE WHEN split_part( ''@otherContactInfo.patNameKana'', ''　'', 2 ) IS NULL OR split_part( ''@otherContactInfo.patNameKana'', ''　'', 2 ) = '''' THEN
      COALESCE((split_part( ''@otherContactInfo.patNameKana'', '' '', 2 )), '''')
    ELSE 
      COALESCE((split_part( ''@otherContactInfo.patNameKana'', '' '', 2 )), '''')
    END AS first_name_kana
),
json_data AS (
  SELECT 
  ''[{"ctl_no":1,"disp_order":0,"is_key_person":null,"pat_id":null,"last_name":"''||(select last_name from pat_name)||''","first_name":"''||(select first_name from pat_name)||''","last_name_kana":"''||(select last_name_kana from pat_name)||''","first_name_kana":"''||(select first_name_kana from pat_name)||''","relation_cd":@otherContactInfo.relationCd,"relation_name":null,"zip_cd":"@otherContactInfo.zipCd","address":"@otherContactInfo.address","e_mail":null,"work_name":null,"work_address":null,"work_tel":null,"tel1":"@otherContactInfo.tel1","tel2":null,"fax":null,"memo1":null,"memo2":null}]'' AS otherContactInfo
  , ''[{"dial_diff_cd":@dialDiffComInfo.dialDiffCd,"is_main":"@dialDiffComInfo.isMain","is_dial_diff":"@dialDiffComInfo.isDialDiff","reg_date":"''||TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDDHH24MISS'')||''"}]'' AS dialDiffComInfo
)
UPDATE pat_personal_main 
SET
  is_die = CASE ''@dieDate_Date'' WHEN '''' THEN is_die ELSE ''1'' END 
  , other_contact_info = CASE WHEN ''@otherContactInfo.tel1''='''' AND ''@otherContactInfo.zipCd''='''' AND ''@otherContactInfo.address''='''' THEN other_contact_info ELSE other_contact_info || (SELECT otherContactInfo FROM json_data) :: jsonb END 
  , dial_diff_com_info = CASE WHEN ''@dialDiffComInfo.dialDiffCd''='''' THEN dial_diff_com_info ELSE dial_diff_com_info || (SELECT dialDiffComInfo FROM json_data) :: jsonb  END  
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND hosp_pat_id = ''@hospPatId'' 
  AND facility_cd = ''@facilityCd''', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NECの「死亡患者、連絡先情報、透析困難情報」の更新', '2021-11-23 12:12:12', '2021-11-23 12:12:12', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9102, 'UPDATE pat_personal_main 
SET
  other_contact_info = ''[]''
  , dial_diff_com_info = COALESCE(NULLIF(''@dialDiffComInfo'', ''''), ''[]'') :: JSONB
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND hosp_pat_id = ''@hospPatId'' 
  AND facility_cd = ''@facilityCd''', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NECの「連絡先情報、透析困難情報」のクリア', '2021-11-23 12:12:12', '2021-11-23 12:12:12', '[{"sql_cd": 1001, "field_name": "dial_diff_com_info", "replace_var": "@dialDiffComInfo"}]');
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9101, 'UPDATE pat_personal_main 
SET
  in_out_class = CASE ''@medicalCareInfo.wardCd'' 
    WHEN '''' THEN 0
    ELSE 1
    END 
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND hosp_pat_id = ''@hospPatId'' 
  AND facility_cd = ''@facilityCd''
  AND COALESCE(NULLIF(''@medicalCareInfo.wardCd'', ''''), ''NONE'') <> ''NONE''', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NECの入外区分の更新', '2021-11-23 12:12:12', '2021-11-23 12:12:12', NULL);

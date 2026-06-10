delete from "sys_data_set" where "sql_cd" in (1101,1102,1103,8101,8102,8103,8104,8105,8106,8107,8108,8109);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (8109, 'UPDATE ord_main 
SET
  ind_medi_info = CASE ''@indMediInfoFlg'' 
    WHEN '''' THEN ''@indMediInfoValue'' 
    ELSE ind_medi_info || ''[{"name":"@indMediInfo.name","unit":"@indMediInfo.unit","amount":"@indMediInfo.amount","comment":"@indMediInfo.comment","class_cd":"@indMediInfo.classCd","init_date":"@indMediInfo.initDate","timing_cd":"@indMediInfo.timingCd","class_name":"@indMediInfo.className","class_type":"@indMediInfo.classType","short_name":"@indMediInfo.shortName","ind_user_id":"@indMediInfo.indUserId","input_class":"@indMediInfo.inputClass","is_editable":"@indMediInfo.isEditable","timing_name":"@indMediInfo.timingName","upd_user_id":"@indMediInfo.updUserId","cop_order_no":"@indMediInfo.copOrderNo","procedure_cd":"@indMediInfo.procedureCd","date_interval":"@indMediInfo.dateInterval","medicine_type":"@indMediInfo.medicineType","procedure_name":"@indMediInfo.procedureName","ind_user_last_name":"@indMediInfo.indUserLastName","upd_user_last_name":"@indMediInfo.updUserLastName","ind_user_first_name":"@indMediInfo.indUserFirstName","upd_user_first_name":"@indMediInfo.updUserFirstName"}]''
     ::jsonb 
    END 
WHERE
  ord_no = @ordNo', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)SSIのオーダ受け(処方情報の更新)', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (8108, 'UPDATE ord_main 
SET
  ind_medi_info = ''[]''
WHERE
  ord_no = @ordNo
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)SSIのオーダ受け(処方情報の更新)', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (8107, 'UPDATE ord_main 
SET
  ind_equip_info = CASE ''@indEquipInfoFlg'' 
    WHEN '''' THEN ''@indEquipInfoValue'' 
    ELSE ind_equip_info || ''[{"cd":"@indEquipInfo.cd","name":"@indEquipInfo.name","unit":"@indEquipInfo.unit","amount":"@indEquipInfo.amount","class_cd":"@indEquipInfo.classCd","class_name":"@indEquipInfo.className","class_type":"@indEquipInfo.classType","equip_type":"@indEquipInfo.equipType","short_name":"@indEquipInfo.shortName","ind_user_id":"@indEquipInfo.indUserId","input_class":"@indEquipInfo.inputClass","is_editable":"@indEquipInfo.isEditable","needle_type":"@indEquipInfo.needleType","upd_user_id":"@indEquipInfo.updUserId","cop_order_no":"@indEquipInfo.copOrderNo","ind_user_last_name":"@indEquipInfo.indUserLastName","upd_user_last_name":"@indEquipInfo.updUserLastName","ind_user_first_name":"@indEquipInfo.indUserFirstName","upd_user_first_name":"@indEquipInfo.updUserFirstName"}]''
     ::jsonb 
    END 
WHERE
  ord_no = @ordNo', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)SSIのオーダ受け(消耗品情報の更新)', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (8106, 'UPDATE ord_main 
SET
  ind_equip_info = ''[]''
WHERE
  ord_no = @ordNo
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)SSIのオーダ受け(消耗品情報の更新)', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (8105, 'UPDATE ord_main 
SET
  is_del = ''1''
  , up_user_id = @upUserId
  , up_date = CURRENT_TIMESTAMP 
WHERE
  ord_no = @ordNo
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)SSIのオーダ受け(DELETE)', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (8104, 'UPDATE ord_main 
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
                      jsonb_set( 
                        jsonb_set( 
                          jsonb_set( 
                            jsonb_set( 
                              jsonb_set( 
                                jsonb_set( 
                                  jsonb_set( 
                                    jsonb_set( 
                                      jsonb_set( 
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
                                                          , ''{33, value}''
                                                          , (CAST(TO_NUMBER(''@indCondInfo.033.value'', ''FM999999999999999999'')/10 AS FLOAT)::TEXT) ::JSONB
                                                        ) ::JSONB
                                                        , ''{28, value}''
                                                        , (CAST(TO_NUMBER(''@indCondInfo.028.value'', ''FM999999999999999999'')/100 AS FLOAT)::TEXT) ::JSONB
                                                      ) ::JSONB
                                                      , ''{27, value}''
                                                      , (CAST(TO_NUMBER(''@indCondInfo.027.value'', ''FM999999999999999999'')/100 AS FLOAT)::TEXT) ::JSONB
                                                    ) ::JSONB
                                                    , ''{26, value}''
                                                    , (CAST(TO_NUMBER(''@indCondInfo.026.value'', ''FM999999999999999999'')/100 AS FLOAT)::TEXT) ::JSONB
                                                  ) ::JSONB
                                                  , ''{25, unit}''
                                                  , ''"@indCondInfo.025.unit"'' ::JSONB
                                                ) ::JSONB
                                                , ''{25, value_name_1}''
                                                , ''"@indCondInfo.025.valueName1"'' ::JSONB
                                              ) ::JSONB
                                              , ''{25, value}''
                                              , ''"@indCondInfo.025.value"'' ::JSONB
                                            ) ::JSONB
                                            , ''{24, value}''
                                            , LTRIM(''@indCondInfo.024.value'', ''0'') ::JSONB
                                          ) ::JSONB
                                          , ''{22, value}''
                                          , (CASE WHEN ''@indCondInfo.format'' = ''Standard'' THEN (CAST(TO_NUMBER(''@indCondInfo.022.value'', ''FM999999999999999999'') AS INT)::TEXT) ELSE (CAST(TO_NUMBER(''@indCondInfo.022.value'', ''FM999999999999999999'')/100 AS FLOAT)::TEXT) END )::JSONB
                                        ) ::JSONB
                                        , ''{20, value}''
                                        , (CAST(TO_NUMBER(''@indCondInfo.020.value'', ''FM999999999999999999'')/10 AS FLOAT)::TEXT) ::JSONB
                                      ) ::JSONB
                                      , ''{19, value_name_1}''
                                      , ''"@indCondInfo.019.valueName1"'' ::JSONB
                                    ) ::JSONB
                                    , ''{19, value}''
                                    , ''"@indCondInfo.019.value"'' ::JSONB
                                  ) ::JSONB
                                  , ''{18, value}''
                                  , (CAST(TO_NUMBER(''@indCondInfo.018.value'', ''FM999999999999999999'')/10 AS FLOAT)::TEXT) ::JSONB
                                ) ::JSONB
                                , ''{17, value}''
                                , (CAST(TO_NUMBER(''@indCondInfo.017.value'', ''FM999999999999999999'')/100 AS FLOAT)::TEXT) ::JSONB
                              ) ::JSONB
                              , ''{15, unit}''
                              , ''"@indCondInfo.015.unit"'' ::JSONB
                            ) ::JSONB
                            , ''{15, value_name_1}''
                            , ''"@indCondInfo.015.valueName1"'' ::JSONB
                          ) ::JSONB
                          , ''{15, value}''
                          , ''"@indCondInfo.015.value"'' ::JSONB
                        ) ::JSONB
                        , ''{14, value}''
                        , LTRIM(''@indCondInfo.014.value'', ''0'') ::JSONB
                      ) ::JSONB
                      , ''{11, value_name_1}''
                      , ''"@indCondInfo.011.valueName1"'' ::JSONB
                    ) ::JSONB
                    , ''{11, value}''
                    , ''"@indCondInfo.011.value"'' ::JSONB
                  ) ::JSONB
                  , ''{10, value_name_1}''
                  , ''"@indCondInfo.010.valueName1"'' ::JSONB
                ) ::JSONB
                , ''{10, value}''
                , ''"@indCondInfo.010.value"'' ::JSONB
              ) ::JSONB
              , ''{6, value_name_1}''
              , ''"@indCondInfo.006.valueName1"'' ::JSONB
            ) ::JSONB
            , ''{6, value}''
            , ''"@indCondInfo.006.value"'' ::JSONB
          ) ::JSONB
          , ''{5, value_name_1}''
          , ''"@indCondInfo.005.valueName1"'' ::JSONB
        ) ::JSONB
        , ''{5, value}''
        , ''"@indCondInfo.005.value"'' ::JSONB
      ) ::JSONB
      , ''{4, value}''
      , (CAST(TO_NUMBER(''@indCondInfo.004.value'', ''FM999999999999999999'')/100 AS FLOAT)::TEXT) ::JSONB
    ) ::JSONB
    , ''{1, value}''
    , LTRIM(''@indCondInfo.001.value'', ''0'') ::JSONB
  ) 
WHERE
  ord_no = @ordNo', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)SSIのオーダ受け(指示：治療条件情報 の更新)', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (8103, 'UPDATE ord_main 
SET
  treat_date = ''@treatDate''
  , ind_bed_cd = CASE ''@indBedCd'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@indBedCd'', ''999999999999999999'') 
    END
  , ind_bed_name = NULLIF(''@indBedName'', '''')
  , ind_treatment_name = NULLIF(''@indTreatmentName'', '''')
  , ind_treat_start_time = NULLIF(''@indTreatStartTime'', '''')
  , ind_schedule_user_info = CASE ''@indScheduleUserInfoFlg'' 
    WHEN '''' THEN ''@indScheduleUserInfoValue'' 
    ELSE json_build_object( 
      ''ind_user_id''
      , CASE ''@indScheduleUserInfo.indUserId'' 
        WHEN '''' THEN null 
        ELSE TO_NUMBER(''@indScheduleUserInfo.indUserId'', ''999999999'') 
        END
      , ''ind_user_last_name''
      , NULLIF( 
        split_part(''@indScheduleUserInfo.indUserLastName '', ''　'', 1)
        , ''''
      ) 
      , ''ind_user_first_name''
      , NULLIF( 
        split_part( 
          ''@indScheduleUserInfo.indUserFirstName ''
          , ''　''
          , 2
        ) 
        , ''''
      ) 
      , ''upd_user_id''
      , CASE ''@indScheduleUserInfo.updUserId'' 
        WHEN '''' THEN null 
        ELSE TO_NUMBER(''@indScheduleUserInfo.updUserId'', ''999999999'') 
        END
      , ''upd_user_last_name''
      , NULLIF( 
        split_part(''@indScheduleUserInfo.updUserLastName '', ''　'', 1)
        , ''''
      ) 
      , ''upd_user_first_name''
      , NULLIF( 
        split_part( 
          ''@indScheduleUserInfo.updUserFirstName ''
          , ''　''
          , 2
        ) 
        , ''''
      )
    ) 
    END
  , ind_equip_info = CASE ''@indEquipInfo.cd'' 
    WHEN '''' THEN ''@indEquipInfoValue'' 
    ELSE ''[{"cd":"@indEquipInfo.cd","name":"@indEquipInfo.name","unit":null,"amount":null,"class_cd":null,"class_name":null,"class_type":null,"equip_type":null,"short_name":null,"ind_user_id":null,"input_class":null,"is_editable":null,"needle_type":null,"upd_user_id":null,"cop_order_no":null,"ind_user_last_name":null,"upd_user_last_name":null,"ind_user_first_name":null,"upd_user_first_name":null}]''::jsonb 
    END
  , up_user_id = CASE ''@upUserId'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@upUserId'', ''999999999999999999'') 
    END
  , up_date = CURRENT_TIMESTAMP 
WHERE
  ord_no = @ordNo
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)SSIのオーダ受け(UPDATE)', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (8102, 'INSERT INTO ord_main( 
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
  , CASE ''@indEquipInfo.cd'' 
    WHEN '''' THEN ''@indEquipInfoValue'' 
    ELSE ''[{"cd":"@indEquipInfo.cd", "name":"@indEquipInfo.name","unit":null,"amount":null,"class_cd":null,"class_name":null,"class_type":null,"equip_type":null,"short_name":null,"ind_user_id":null,"input_class":null,"is_editable":null,"needle_type":null,"upd_user_id":null,"cop_order_no":null,"ind_user_last_name":null,"upd_user_last_name":null,"ind_user_first_name":null,"upd_user_first_name":null}]''::jsonb 
    END
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
)', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)SSIのオーダ受け(INSERT)', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (8101, 'SELECT
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
  AND treat_date = @treatDate', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)SSIのオーダ受け(SELECT)', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1103, 'UPDATE pat_personal_main 
SET fn_pat_id = NULLIF ( ''@fnPatId'', '''' ),
hosp_pat_id = LTRIM(NULLIF (''@hospPatId'', ''''), ''0''),
nkk_pat_id = NULLIF ( ''@nkkPatId'', '''' ),
facility_cd = NULLIF ( ''@facilityCd'', '''' ),
pat_last_name = personal_info_encrypt(split_part( ''@patLastName'', ''　'', 1 )),
pat_first_name = personal_info_encrypt(split_part( ''@patFirstName'', ''　'', 2 )),
pat_last_name_kana =  case when split_part( ''@patLastNmKana'', ''　'', 2 ) is null or split_part( ''@patLastNmKana'', ''　'', 2 ) = '''' then 
    personal_info_encrypt(split_part( ''@patLastNmKana'', '' '', 1 ))
  else 
    personal_info_encrypt(split_part( ''@patLastNmKana'', ''　'', 1 ))
  end,
pat_first_name_kana = case when split_part( ''@patFirstNmKana'', ''　'', 2 ) is null or split_part( ''@patFirstNmKana'', ''　'', 2 ) = '''' then 
    personal_info_encrypt(split_part( ''@patFirstNmKana'', '' '', 2 ))
  else 
    personal_info_encrypt(split_part( ''@patFirstNmKana'', ''　'', 2 ))
  end,
pat_last_name_alpha = NULLIF ( ''@patLastNmAlpha'', '''' ),
pat_first_name_alpha = NULLIF ( ''@patFirstNmAlpha'', '''' ),
pat_birth_name = NULLIF ( ''@patBirthName'', '''' ),
pat_birth_name_kana = NULLIF ( ''@patBirthNmKana'', '''' ),
pat_birth_name_alpha = NULLIF ( ''@patBirthNmAlpha'', '''' ),
pat_birthday = NULLIF ( ''@patBirthday'', '''' ),
pat_sex =
CASE
        ''@patSex'' 
        WHEN '''' THEN
        NULL ELSE to_number( ''@patSex'', ''9999999999999999'' ) 
    END,
    nationality = NULLIF ( ''@nationality'', '''' ),
    pat_blood_type_abo =
CASE
        ''@patBloodTypeAbo'' 
        WHEN '''' THEN
        NULL ELSE to_number( ''@patBloodTypeAbo'', ''9999999999999999'' ) 
    END,
    pat_blood_type_rh =
CASE
    ''@patBloodTypeRh'' 
    WHEN '''' THEN
    NULL ELSE to_number( ''@patBloodTypeRh'', ''9999999999999999'' ) 
    END,
    pat_blood_type_serovar =
CASE
    ''@patBloodTypeSerovar'' 
    WHEN '''' THEN
    NULL ELSE to_number( ''@patBloodTypeSerovar'', ''9999999999999999'' ) 
    END,
    in_out_class =
CASE
    ''@inOutClass'' 
    WHEN '''' THEN
    NULL ELSE to_number( ''@inOutClass'', ''9999999999999999'' ) 
    END,
    is_die = NULLIF ( ''@isDie'', '''' ),
    die_cd =
CASE
        ''@dieCd'' 
        WHEN '''' THEN
        NULL ELSE to_number( ''@dieCd'', ''99999999999999999999999999999999'' ) 
    END,
    die_date =
CASE
    ''@dieDate_Date'' 
    WHEN '''' THEN
    NULL ELSE to_timestamp( ''@dieDate_Date'', ''yyyy-MM-dd hh24:mi:ss'' ) 
    END,
    dial_diff_com_info = ''@dialDiffComInfoValue'',
    severity_cd =
CASE
    ''@severityCd'' 
    WHEN '''' THEN
    NULL ELSE to_number( ''@severityCd'', ''99999999999999999999999999999999'' ) 
    END,
    transport_cd =
CASE
    ''@transportCd'' 
    WHEN '''' THEN
    NULL ELSE to_number( ''@transportCd'', ''99999999999999999999999999999999'' ) 
    END,
    pat_contact_info =
CASE
    ''@patContactInfoFlg'' 
    WHEN '''' THEN
    ''@patContactInfoValue'' ELSE json_build_object (
        ''zip_cd'',
        NULLIF ( ''@patContactInfo.zipCd'', '''' ),
        ''address'',
        NULLIF ( TRIM(TRIM(TRIM(''@patContactInfo.address'', ''　''), '' ''), ''　''), '''' ),
        ''tel1'',
        NULLIF ( ''@patContactInfo.tel1'', '''' ),
        ''tel2'',
        NULLIF ( ''@patContactInfo.tel2'', '''' ),
        ''fax'',
        NULLIF ( ''@patContactInfo.fax'', '''' ),
        ''e_mail'',
        NULLIF ( ''@patContactInfo.eMail'', '''' ),
        ''work_name'',
        NULLIF ( ''@patContactInfo.workName'', '''' ),
        ''work_address'',
        NULLIF ( ''@patContactInfo.workAddress'', '''' ),
        ''work_tel'',
        NULLIF ( ''@patContactInfo.workTel'', '''' ),
        ''memo1'',
        NULLIF ( ''@patContactInfo.memo1'', '''' ),
        ''memo2'',
        NULLIF ( ''@patContactInfo.memo2'', '''' ) 
    ) 
    END,
    other_contact_info = ''@otherContactInfoValue'',
    vendor_contact_info = ''@vendorContactInfoValue'',
    insurance_info = ''@insuranceInfoValue'',
    reg_date = ''@regDate'',
    up_date = CURRENT_TIMESTAMP,
    primary_disease_cd =
CASE
        ''@primaryDiseaseCd'' 
        WHEN '''' THEN
        NULL ELSE to_number( ''@primaryDiseaseCd'', ''99999999999999999999999999999999'' ) 
    END,
    remote_monitor_service =
CASE
    ''@remoteMonitorService'' 
    WHEN '''' THEN
    NULL ELSE to_number( ''@remoteMonitorService'', ''99999999999999999999999999999999'' ) 
    END,
    remote_monitor_user_id = NULLIF ( ''@remoteMonitorUserId'', '''' ),
    remote_monitor_user_pw = NULLIF ( ''@remoteMonitorUserPw'', '''' ) 
WHERE
    is_del = ''0'' 
    AND hosp_pat_id = ''@hospPatId'' 
    AND facility_cd = ''@facilityCd''', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1102, 'insert into pat_personal_main (
  fn_pat_id,
  hosp_pat_id,
  nkk_pat_id,
  facility_cd,
  pat_last_name,
  pat_first_name,
  pat_last_name_kana,
  pat_first_name_kana,
  pat_last_name_alpha,
  pat_first_name_alpha,
  pat_birth_name,
  pat_birth_name_kana,
  pat_birth_name_alpha,
  pat_birthday,
  pat_sex,
  nationality,
  pat_blood_type_abo,
  pat_blood_type_rh,
  pat_blood_type_serovar,
  in_out_class,
  is_die,
  die_cd,
  die_date,
  dial_diff_com_info,
  severity_cd,
  transport_cd,
  pat_contact_info,
  other_contact_info,
  vendor_contact_info,
  insurance_info,
  is_del,
  up_date,
  reg_date,
  primary_disease_cd,
  remote_monitor_service,
  remote_monitor_user_id,
  remote_monitor_user_pw
) values (
  NULLIF(''@fnPatId'',''''),
  LTRIM(NULLIF(''@hospPatId'',''''), ''0''),
  NULLIF(''@nkkPatId'',''''),
  NULLIF(''@facilityCd'',''''),
  personal_info_encrypt(split_part( ''@patLastName'', ''　'', 1 )),
  personal_info_encrypt(split_part( ''@patFirstName'', ''　'', 2 )),
  case when split_part( ''@patLastNmKana'', ''　'', 2 ) is null or split_part( ''@patLastNmKana'', ''　'', 2 ) = '''' then 
    personal_info_encrypt(split_part( ''@patLastNmKana'', '' '', 1 ))
  else 
    personal_info_encrypt(split_part( ''@patLastNmKana'', ''　'', 1 ))
  end,
  case when split_part( ''@patFirstNmKana'', ''　'', 2 ) is null or split_part( ''@patFirstNmKana'', ''　'', 2 ) = '''' then 
    personal_info_encrypt(split_part( ''@patFirstNmKana'', '' '', 2 ))
  else 
    personal_info_encrypt(split_part( ''@patFirstNmKana'', ''　'', 2 ))
  end,
  NULLIF(''@patLastNmAlpha'',''''),
  NULLIF(''@patFirstNmAlpha'',''''),
  NULLIF(''@patBirthName'',''''),
  NULLIF(''@patBirthNmKana'',''''),
  NULLIF(''@patBirthNmAlpha'',''''),
  NULLIF(''@patBirthday'',''''),
  case ''@patSex''
    when '''' then null
    else to_number(''@patSex'',''9999999999999999'')
  end,
  NULLIF(''@nationality'',''''),
  case ''@patBloodTypeAbo''
    when '''' then null
    else to_number(''@patBloodTypeAbo'',''9999999999999999'')
  end,
  case ''@patBloodTypeRh''
    when '''' then null
    else to_number(''@patBloodTypeRh'',''9999999999999999'')
  end,
  case ''@patBloodTypeSerovar''
    when '''' then null
    else to_number(''@patBloodTypeSerovar'',''9999999999999999'')
  end,
  case ''@inOutClass''
    when '''' then null
    else to_number(''@inOutClass'',''9999999999999999'')
  end,
  NULLIF(''@isDie'',''''),
  case ''@dieCd''
    when '''' then null
    else to_number(''@dieCd'',''99999999999999999999999999999999'')
  end,
  case ''@dieDate_Date''
    when '''' then null
    else to_timestamp(''@dieDate_Date'',''yyyy-MM-dd hh24:mi:ss'')
  end,
  ''[{"is_main": "0", "reg_date": null, "dial_diff_cd": 1, "is_dial_diff": "0"}, {"is_main": "0", "reg_date": null, "dial_diff_cd": 2, "is_dial_diff": "0"}, {"is_main": "0", "reg_date": null, "dial_diff_cd": 3, "is_dial_diff": "0"}, {"is_main": "0", "reg_date": null, "dial_diff_cd": 4, "is_dial_diff": "0"}, {"is_main": "0", "reg_date": null, "dial_diff_cd": 5, "is_dial_diff": "0"}, {"is_main": "0", "reg_date": null, "dial_diff_cd": 6, "is_dial_diff": "0"}, {"is_main": "0", "reg_date": null, "dial_diff_cd": 7, "is_dial_diff": "0"}, {"is_main": "0", "reg_date": null, "dial_diff_cd": 8, "is_dial_diff": "0"}, {"is_main": "0", "reg_date": null, "dial_diff_cd": 9, "is_dial_diff": "0"}, {"is_main": "0", "reg_date": null, "dial_diff_cd": 10, "is_dial_diff": "0"}, {"is_main": "0", "reg_date": null, "dial_diff_cd": 11, "is_dial_diff": "0"}, {"is_main": "0", "reg_date": null, "dial_diff_cd": 12, "is_dial_diff": "0"}]'',
  case ''@severityCd''
    when '''' then null
    else to_number(''@severityCd'',''99999999999999999999999999999999'')
  end,
  case ''@transportCd''
    when '''' then null
    else to_number(''@transportCd'',''99999999999999999999999999999999'')
  end,
  case ''@patContactInfoFlg''
    when '''' then json_build_object(''zip_cd'',null,''address'',null,''tel1'',null,''tel2'',null,''fax'',null,''e_mail'',null,''work_name'',null,''work_address'',null,''work_tel'',null,''memo1'',null,''memo2'',null)
    else json_build_object(''zip_cd'',NULLIF(''@patContactInfo.zipCd'',''''),''address'',NULLIF(TRIM(TRIM(TRIM(''@patContactInfo.address'', ''　''), '' ''), ''　''),''''),''tel1'',NULLIF(''@patContactInfo.tel1'',''''),''tel2'',NULLIF(''@patContactInfo.tel2'',''''),''fax'',NULLIF(''@patContactInfo.fax'',''''),''e_mail'',NULLIF(''@patContactInfo.eMail'',''''),''work_name'',NULLIF(''@patContactInfo.workName'',''''),''work_address'',NULLIF(''@patContactInfo.workAddress'',''''),''work_tel'',NULLIF(''@patContactInfo.workTel'',''''),''memo1'',NULLIF(''@patContactInfo.memo1'',''''),''memo2'',NULLIF(''@patContactInfo.memo2'',''''))
  end,
  ''@otherContactInfoValue'',
  ''@vendorContactInfoValue'',
  ''@insuranceInfoValue'',
  ''0'',
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP,
  case ''@primaryDiseaseCd''
    when '''' then null
    else to_number(''@primaryDiseaseCd'',''99999999999999999999999999999999'')
  end,
  case ''@remoteMonitorService''
    when '''' then null
    else to_number(''@remoteMonitorService'',''99999999999999999999999999999999'')
  end,
  NULLIF(''@remoteMonitorUserId'',''''),
  NULLIF(''@remoteMonitorUserPw'','''')
)', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1101, 'select
  pat_id,
  fn_pat_id,
  hosp_pat_id,
  nkk_pat_id,
  facility_cd,
  personal_info_decrypt(pat_last_name) as pat_last_name,
  personal_info_decrypt(pat_first_name) as pat_first_name,
  personal_info_decrypt(pat_last_name_kana) as pat_last_name_kana,
  personal_info_decrypt(pat_first_name_kana) as pat_first_name_kana,
  personal_info_decrypt(pat_last_name_alpha) as pat_last_name_alpha,
  personal_info_decrypt(pat_first_name_alpha) as pat_first_name_alpha,
  personal_info_decrypt(pat_birth_name) as pat_birth_name,
  personal_info_decrypt(pat_birth_name_kana) as pat_birth_name_kana,
  personal_info_decrypt(pat_birth_name_alpha) as pat_birth_name_alpha,
  pat_birthday,
  pat_sex,
  nationality,
  pat_blood_type_abo,
  pat_blood_type_rh,
  pat_blood_type_serovar,
  in_out_class,
  is_die,
  die_cd,
  die_date,
  dial_diff_com_info,
  severity_cd,
  transport_cd,
  personal_info_decrypt_jsonb(pat_contact_info) as pat_contact_info,
  personal_info_decrypt_jsonb(other_contact_info) as other_contact_info,
  personal_info_decrypt_jsonb(vendor_contact_info) as vendor_contact_info,
  insurance_info,
  is_del,
  up_date,
  reg_date,
  primary_disease_cd,
  remote_monitor_service,
  personal_info_decrypt(remote_monitor_user_id) as remote_monitor_user_id,
  personal_info_decrypt(remote_monitor_user_pw) as remote_monitor_user_pw
from
  pat_personal_main
where
  is_del = ''0''
and
  ltrim(hosp_pat_id, ''0'') = ltrim(@hospPatId, ''0'')
and
  facility_cd = @facilityCd', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);

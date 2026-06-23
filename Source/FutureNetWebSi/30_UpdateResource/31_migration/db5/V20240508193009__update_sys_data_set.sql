DELETE FROM ntss.sys_data_set WHERE sql_cd IN (8102);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(8102, 'INSERT INTO ord_main( 
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
  , rst_weight_info
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
)', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのオーダ受け(INSERT)', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, NULL);

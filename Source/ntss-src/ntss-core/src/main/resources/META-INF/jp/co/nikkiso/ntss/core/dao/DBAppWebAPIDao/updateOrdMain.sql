update ord_main set
	--- ord_no=/*ord_no*/, --- システムで管理する一意なオーダ番号
	--- pat_id=/*pat_id*/, --- システムで管理する一意な患者ID
	--- fn_pat_id=/*fn_pat_id*/, --- FNW+で管理する施設内の一意な患者ID
	--- treat_date=/*treat_date*/, --- 治療日
	--- treat_week=/*treat_week*/, --- 治療曜日
	--- facility_cd=/*facility_cd*/, --- 施設コード
	facility_name=/*ordMain.facilityName*/'', --- 施設名
	--- ind_va_cd=/*ind_va_cd*/, --- 指示：VAコード
	ind_dw=/*ordMain.indDw*/0, --- 指示：DW
    ind_dw_user_info=/*ordMain.indDwUserInfo*/'{}', --- DW指示者情报   add by shiyw 2024-01-29 [#10196]ord_mainのデータ定義の修正
	--- ind_treatment_cd=/*ind_treatment_cd*/, --- 指示：治療方法コード
	ind_treatment_name=/*ordMain.indTreatmentName*/'', --- 指示：治療方法名
    ind_device_mode=/*ordMain.indDeviceMode*/null, --- 指示：装置モード   add by shiyw 2024-01-29 [#10196]ord_mainのデータ定義の修正
	--- ind_kur_cd=/*ind_kur_cd*/, --- 指示：クールコード
	ind_kur_name=/*ordMain.indKurName*/'', --- 指示：クール名
	--- ind_treat_start_time=/*ind_treat_start_time*/, --- 指示：治療開始時刻
	--- ind_bed_cd=/*ind_bed_cd*/, --- 指示：ベッドコード
	ind_bed_name=/*ordMain.indBedName*/'', --- 指示：ベッド名
	ind_schedule_user_info=/*ordMain.indScheduleUserInfo*/'{}', --- 指示：治療予定指示者情報
	ind_cond_info=/*ordMain.indCondInfo*/'{}', --- 指示：治療条件情報
	ind_medi_info=/*ordMain.indMediInfo*/'{}', --- 指示：投与薬剤情報
	ind_equip_info=/*ordMain.indEquipInfo*/'{}', --- 指示：医療材料情報
	ind_ind_comment_info=/*ordMain.indIndCommentInfo*/'{}', --- 指示：指示コメント情報
	--- ind_tare_info=/*ind_tare_info*/, --- 指示：風袋補正
	--- ind_off_water_info=/*ind_off_water_info*/, --- 指示：除水補正
	--- ind_device_set_info=/*ind_device_set_info*/, --- 指示：装置設定情報
	--- rst_fn_dialysis_no=/*rst_fn_dialysis_no*/, --- 実績：FNW+透析番号
	--- rst_relation_dialysis_no=/*rst_relation_dialysis_no*/, --- 実績：関連透析番号
	--- rst_edition=/*rst_edition*/, --- 実績：版番号
	--- rst_is_update_edition=/*rst_is_update_edition*/, --- 実績：版番号更新フラグ
	rst_input_class=/*ordMain.rstInputClass*/1, --- 実績：登録区分
/*%if ordMain.rstDialysisState != null */
	  rst_dialysis_state=/*ordMain.rstDialysisState*/'', --- 実績：治療状況
/*%end*/
	rst_treatment_cd=/*ordMain.rstTreatmentCd*/0, --- 実績：治療方法コード
	rst_treatment_name=/*ordMain.rstTreatmentName*/'', --- 実績：治療方法名
	rst_kur_cd=/*ordMain.rstKurCd*/0, --- 実績：クールコード
	rst_kur_name=/*ordMain.rstKurName*/'', --- 実績：クール名
	rst_bed_cd=/*ordMain.rstBedCd*/0, --- 実績：ベッドコード
	rst_bed_name=/*ordMain.rstBedName*/'', --- 実績：ベッド名
	rst_machine_no=/*ordMain.rstMachineNo*/0, --- 実績：装置番号
	rst_machine_name=/*ordMain.rstMachineName*/'', --- 実績：装置名
	rst_cond_send_date=/*ordMain.rstCondSendDate*/'', --- 実績：条件送信日時
	--- rst_accept_date=/*rst_accept_date*/, --- 実績：受付日時
	--- rst_start_date=/*rst_start_date*/, --- 実績：治療開始日時
	--- rst_end_date=/*rst_end_date*/, --- 実績：治療終了日時
	--- rst_return_home_date=/*rst_return_home_date*/, --- 実績：帰宅日時
	rst_in_out_class=/*ordMain.rstInOutClass*/'', --- 実績：入外区分
	rst_dialysis_cnt=/*ordMain.rstDialysisCnt*/null, --- 実績：透析回数
    -- add FNSI-特殊血液浄化回数がカウントしない 徐 start
	rst_purification_cnt=/*ordMain.rstPurificationCnt*/null, --- 実績：特殊浄化回数
	-- add FNSI-特殊血液浄化回数がカウントしない 徐 end
	rst_ward_cd=/*ordMain.rstWardCd*/0, --- 実績：病棟コード
	rst_ward_name=/*ordMain.rstWardName*/'', --- 実績：病棟名
	rst_course_cd=/*ordMain.rstCourseCd*/0, --- 実績：診療科コード
	rst_course_name=/*ordMain.rstCourseName*/'', --- 実績：診療科名
  rst_dw=/*ordMain.rstDw*/0, --- 実績：DW
	--- rst_puncture_user_info=/*rst_puncture_user_info*/, --- 実績：穿刺者情報
	--- rst_return_user_info=/*rst_return_user_info*/, --- 実績：返血者情報
	--- rst_charge_user_info=/*rst_charge_user_info*/, --- 実績：担当者情報
	--- rst_blood_circulate_total=/*rst_blood_circulate_total*/, --- 実績：血液循環積算値
	--- rst_running_time=/*rst_running_time*/, --- 実績：透析運転時間
	--- rst_kt_v=/*rst_kt_v*/, --- 実績：Kt/V
	--- rec_set_date=/*rec_set_date*/, --- 実績：透析記録確認日時
	--- send_ctl_no=/*send_ctl_no*/, --- 実績：送信管理番号
	blood_purifier_name=/*ordMain.bloodPurifierName*/'', --- 実績：血液浄化装置名称
	--- pull_leave_amount=/*pull_leave_amount*/, --- 実績：プログラム補液引き残し量
	rst_cond_info=/*ordMain.rstCondInfo*/'{}', --- 実績：治療条件情報
	rst_medi_info=/*ordMain.rstMediInfo*/'{}', --- 実績：投与薬剤情報
	rst_equip_info=/*ordMain.rstEquipInfo*/'{}', --- 実績：医療材料情報
	rst_ind_comment_info=/*ordMain.rstIndCommentInfo*/'{}', --- 実績：指示コメント情報
	rst_tare_info=/*ordMain.rstTareInfo*/'{}', --- 実績：風袋補正
	rst_off_water_info=/*ordMain.rstOffWaterInfo*/'{}', --- 実績：除水補正
    -- delete by chamaojia 2024-01-23 [10196] 'rst_device_set_info' is no longer in use  --start
-- 	rst_device_set_info=/*ordMain.rstDeviceSetInfo*/'{}', --- 実績：装置設定情報
    -- delete by chamaojia 2024-01-23 [10196] 'rst_device_set_info' is no longer in use  --end
	rst_weight_info=/*ordMain.rstWeightInfo*/'{}', --- 実績：体重情報
	--- rst_vital_info=/*rst_vital_info*/, --- 実績：バイタル情報
	--- rst_complaint_info=/*rst_complaint_info*/, --- 実績：愁訴情報
	--- rst_treatment_info=/*rst_treatment_info*/, --- 実績：愁訴処置情報
	--- rst_treat_staff_info=/*rst_treat_staff_info*/, --- 実績：愁訴処置者情報
	--- rst_rounds_info=/*rst_rounds_info*/, --- 実績：回診記録情報
	--- is_del=/*is_del*/, --- 削除フラグ
  up_date = transaction_timestamp() --- 更新日時
	--- reg_date=/*reg_date*/, --- 登録日時
    -- add by chamaojia 2025-01-16 [11467] add a new assignment for 【rst_device_mode】 --start
    , rst_device_mode=/*ordMain.rstDeviceMode*/null
    -- add by chamaojia 2025-01-16 [11467] add a new assignment for 【rst_device_mode】 --end
where
    ord_no = /*ordMain.ordNo*/0 ;

insert into ord_main
  (
--    add #9289 直近の過去指示(投与薬剤を含まない)を使った治療予定作成時にエラー発生 zy start
   ord_no,
--     add #9289 直近の過去指示(投与薬剤を含まない)を使った治療予定作成時にエラー発生 zy end
    pat_id
    ,fn_pat_id
    ,treat_date
    ,treat_week
    ,facility_cd
    ,ind_va_cd
    ,ind_treatment_cd
    ,ind_kur_cd
    ,ind_treat_start_time
    ,ind_bed_cd
    ,ind_schedule_user_info
    ,ind_cond_info
    ,ind_medi_info
    ,ind_equip_info
    ,ind_ind_comment_info
    ,ind_tare_info
    ,ind_off_water_info
    ,ind_device_set_info
		,is_del
		,up_date
		,reg_date
  )
  values
  (
--    add #9289 直近の過去指示(投与薬剤を含まない)を使った治療予定作成時にエラー発生 zy start
    /*ordMain.ordNo*/'1',
--    add #9289 直近の過去指示(投与薬剤を含まない)を使った治療予定作成時にエラー発生 zy end
    /*ordMain.patId*/'1',
    /*ordMain.fnPatId*/null,
    /*ordMain.treatDate*/'error',
    /*ordMain.treatWeek*/'error',
    /*ordMain.facilityCd*/null,
    /*ordMain.indVaCd*/null,
    /*ordMain.indTreatmentCd*/null,
    0,
    null,
    0,
    /*ordMain.indScheduleUserInfo*/null,
    /*ordMain.indCondInfo*/null,
    /*ordMain.indMediInfo*/null,
    /*ordMain.indEquipInfo*/null,
    /*ordMain.indIndCommentInfo*/null,
    /*ordMain.indTareInfo*/null,
    /*ordMain.indOffWaterInfo*/null,
    /*ordMain.indDeviceSetInfo*/null,
	  /*ordMain.isDel*/'0',
	  CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
  );

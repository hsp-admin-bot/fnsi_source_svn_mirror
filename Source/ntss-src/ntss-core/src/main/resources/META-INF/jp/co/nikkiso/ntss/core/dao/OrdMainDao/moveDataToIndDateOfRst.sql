update ord_main
set
  treat_date = /*ordMain.treatDate*/'20180220',
  treat_week = EXTRACT(ISODOW FROM to_date(/*ordMain.treatDate*/'error', 'yyyyMMdd')),
  ind_kur_cd = /*ordMain.indKurCd*/0,
  ind_kur_name = /*ordMain.indKurName*/null,
  ind_treat_start_time = /*ordMain.indTreatStartTime*/null,
  ind_bed_cd = /*ordMain.indBedCd*/0,
  ind_bed_name = /*ordMain.indBedName*/null,
  ind_schedule_user_info = jsonb_merge_recursive(ind_schedule_user_info::jsonb, /*indScheduleUserInfo*/'{}'::jsonb),
  up_date = CURRENT_TIMESTAMP
where
  ord_no = /*ordMain.ordNo*/0


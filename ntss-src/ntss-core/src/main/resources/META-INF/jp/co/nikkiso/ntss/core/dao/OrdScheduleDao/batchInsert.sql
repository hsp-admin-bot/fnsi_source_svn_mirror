INSERT INTO ord_schedule
(facility_cd,
 ord_no,
 treat_date,
 kur_cd,
 bed_cd,
 pat_id,
 is_dummy,
 up_date,
 reg_date,
 treat_week)
VALUES
  (
    /* ordScheduleList.facilityCd */null,
    /* ordScheduleList.ordNo */null,
    /* ordScheduleList.treatDate */null,
    /* ordScheduleList.kurCd */null,
    /* ordScheduleList.bedCd */null,
    /* ordScheduleList.patId */null,
    /* ordScheduleList.isDummy */'0',
                                    current_timestamp,
                                    current_timestamp,
    /* ordScheduleList.treatWeek*/null)

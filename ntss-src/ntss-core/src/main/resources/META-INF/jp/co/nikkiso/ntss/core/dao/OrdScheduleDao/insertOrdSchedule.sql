INSERT INTO ord_schedule (
  facility_cd,
  ord_no,
  treat_date,
  kur_cd,
  bed_cd,
  pat_id,
  is_dummy,
  up_date,
  reg_date,
  treat_week
)
VALUES (
        /* ord.facilityCd */null,
        /* ord.ordNo */null,
        /* ord.treatDate */null,
        /* ord.indKurCd */null,
        /* ord.indBedCd */null,
        /* ord.patId */null,
        '0',
        current_timestamp,
        current_timestamp,
        /* ord.treatWeek*/null);

update ord_schedule
set
  treat_date = /* ord.treatDate */null,
  kur_cd = /* ord.indKurCd */null,
  bed_cd = /* ord.indBedCd */null,
  treat_week = /* ord.treatWeek */null,
  up_date = /* ord.upDate */null
where
  ord_no = /* ord.ordNo */null
;

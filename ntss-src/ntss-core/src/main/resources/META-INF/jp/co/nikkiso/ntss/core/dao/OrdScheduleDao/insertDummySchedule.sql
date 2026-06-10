insert into ord_schedule
(
  facility_cd,
  ord_no,
  treat_date,
  treat_week,
  kur_cd,
  bed_cd,
  pat_id,
  is_dummy,
  up_date,
  reg_date
)
select
  facility_cd,
  ord_no,
  /* treatDate */null,
  EXTRACT(ISODOW from to_date(/* treatDate */null,'yyyyMMdd')),
  /* kurCd */null,
  /* bedCd */null,
  pat_id,
  '1',
  /*upDate*/null,
  /*upDate*/null
from
  ord_schedule
where
  ord_no = /* ordNo */null
and
  is_dummy = '0'
;
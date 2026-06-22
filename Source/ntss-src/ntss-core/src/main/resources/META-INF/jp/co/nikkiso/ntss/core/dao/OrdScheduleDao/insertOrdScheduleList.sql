INSERT INTO
    ord_schedule
(
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
VALUES
/*%for osl : ordSchList */
(
    /* osl.facilityCd */null,
    /* osl.ordNo */null,
    /* osl.treatDate */null,
    /* osl.indKurCd */null,
    /* osl.indBedCd */null,
    /* osl.patId */null,
    '0',
    current_timestamp,
    current_timestamp,
    /* osl.treatWeek*/null
)
/*%if osl_has_next */
/*# "," */
/*%end */
/*%end*/

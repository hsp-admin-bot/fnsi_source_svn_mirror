SELECT /*%expand "o"*/*
FROM
    ord_schedule o
WHERE ( o.facility_cd, o.treat_date, o.kur_cd, o.bed_cd ) IN (
    (null, null, null, null)
    /*%for isl : indScheduleInfoList */
    ,(
        /*isl.facilityCd*/'999999',
        /*isl.treatDate*/null,
        /*isl.indKurCd*/null,
        /*isl.indBedCd*/null
        )
    /*%end*/
    )

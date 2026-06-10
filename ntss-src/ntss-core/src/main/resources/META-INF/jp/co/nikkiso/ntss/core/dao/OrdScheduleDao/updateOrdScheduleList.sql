UPDATE ord_schedule
SET treat_date = tmp.treat_date,
    kur_cd     = tmp.kur_cd,
    bed_cd     = tmp.bed_cd,
    treat_week = tmp.treat_week,
    up_date    = tmp.up_date FROM
    (VALUES
        /*%for romd : resultOrdMainDiffList */
            (
            /* romd.facilityCd */null,
            /* romd.ordNo */null,
            /* romd.treatDate */null,
            /* romd.indKurCd */null,
            /* romd.indBedCd */null,
            /* romd.treatWeek */null,
            cast(/* romd.upDate */null as  timestamp)
            )
            /*%if romd_has_next */
        /*# "," */
            /*%end */
        /*%end*/
    ) AS tmp ( facility_cd, ord_no, treat_date, kur_cd, bed_cd, treat_week, up_date )
WHERE
    ord_schedule.ord_no = tmp.ord_no AND
    ord_schedule.facility_cd = tmp.facility_cd;

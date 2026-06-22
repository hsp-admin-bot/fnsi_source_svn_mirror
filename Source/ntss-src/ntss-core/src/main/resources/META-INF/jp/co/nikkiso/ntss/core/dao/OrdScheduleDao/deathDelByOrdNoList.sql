WITH updatesAll AS (
    select
        /*%expand "os" */*
    from
        ord_schedule os
    where
            os.facility_cd = /*facilityCd*/null
        /*%if ordNoList.size() > 0 */
      and os.ord_no in /* ordNoList */(null)
    /*%end */
),
     updates AS (SELECT facility_cd, ord_no FROM updatesAll)
DELETE FROM ord_schedule
    USING updates u
WHERE
    ord_schedule.facility_cd = /*facilityCd*/null AND
    ord_schedule.facility_cd = u.facility_cd AND
    ord_schedule.ord_no = u.ord_no
RETURNING ord_schedule.*

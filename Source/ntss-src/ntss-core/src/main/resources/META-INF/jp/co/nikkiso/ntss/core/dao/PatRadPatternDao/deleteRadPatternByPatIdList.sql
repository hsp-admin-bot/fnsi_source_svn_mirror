WITH updatesAll AS (
    select
        /*%expand "A" */*
    from
        pat_rad_pattern A
    where A.facility_cd = /* facilityCd */null
        /*%if patIdList.size() != 0 */
      and A.pat_id in /* patIdList */(null)
    /*%end */
),
updates AS (SELECT facility_cd, rad_pattern_cd FROM updatesAll)
DELETE FROM pat_rad_pattern
    USING updates u
WHERE
    pat_rad_pattern.facility_cd = /*facilityCd*/null AND
    pat_rad_pattern.facility_cd = u.facility_cd AND
    pat_rad_pattern.rad_pattern_cd = u.rad_pattern_cd
RETURNING pat_rad_pattern.*

WITH updatesAll AS (
    select
        /*%expand "A" */*
    from
        pat_treatment_pattern A
    where A.facility_cd = /* facilityCd */null
        /*%if patIdList.size() != 0 */
      and A.pat_id in /* patIdList */(null)
        /*%end */
),
updates AS (SELECT facility_cd, ctl_no, pat_id FROM updatesAll)
DELETE FROM pat_treatment_pattern
    USING updates u
WHERE
    pat_treatment_pattern.facility_cd = /*facilityCd*/null AND
    pat_treatment_pattern.facility_cd = u.facility_cd AND
    pat_treatment_pattern.pat_id = u.pat_id AND
    pat_treatment_pattern.ctl_no = u.ctl_no
RETURNING pat_treatment_pattern.*

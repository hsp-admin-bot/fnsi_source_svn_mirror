WITH updatesAll AS (
    select
        /*%expand "A" */*
    from
        pat_exam_pattern A
    where A.facility_cd = /* facilityCd */null
        /*%if patIdList.size() != 0 */
      and A.pat_id in /* patIdList */(null)
    /*%end */
),
updates AS (SELECT facility_cd, exam_pattern_cd FROM updatesAll)
DELETE FROM pat_exam_pattern
    USING updates u
WHERE
    pat_exam_pattern.facility_cd = /*facilityCd*/null AND
    pat_exam_pattern.facility_cd = u.facility_cd AND
    pat_exam_pattern.exam_pattern_cd = u.exam_pattern_cd
RETURNING pat_exam_pattern.*

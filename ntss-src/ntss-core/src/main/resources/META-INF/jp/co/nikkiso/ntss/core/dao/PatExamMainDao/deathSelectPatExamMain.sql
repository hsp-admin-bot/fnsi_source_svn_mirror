select
    /*%expand "A" */*
from
    pat_exam_main A
WHERE
  A.facility_cd = /*facilityCd*/'000000'
/*%if personalMainList != null && personalMainList.size() != 0*/
  AND (
    /*%for pat : personalMainList*/
    (A.pat_id = /*pat.pat_id*/0 AND A.reg_exam_date::date >= CAST(/*pat.die_date*/'' AS DATE))
    /*%if pat_has_next */
    /*# "or" */
    /*%end*/
    /*%end*/
    )
/*%end*/

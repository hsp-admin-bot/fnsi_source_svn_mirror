select
  course_cd,
  course_name,
  -- add 10626 データリストのCTR・DW一括登録修正 房 start
  in_hospital_cd_1
  -- add 10626 データリストのCTR・DW一括登録修正 房 end
from
  mst_course A
where
    course_cd in /* courseCds */(null)
;

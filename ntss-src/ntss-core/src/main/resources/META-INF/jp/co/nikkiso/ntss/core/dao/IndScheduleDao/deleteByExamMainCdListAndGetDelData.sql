DELETE FROM pat_exam_main
WHERE exam_main_cd IN /*examMainCdList*/(null)
RETURNING pat_exam_main.*

--透析困難
SELECT /*%expand */*
FROM mst_dialysis_difficulty
WHERE dialysis_difficulty_cd = /*dialysisDifficultyCd*/0

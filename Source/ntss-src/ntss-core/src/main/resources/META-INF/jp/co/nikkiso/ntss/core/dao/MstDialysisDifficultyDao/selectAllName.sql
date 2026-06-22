--透析困難
SELECT
  dialysis_difficulty_cd,
  dialysis_difficulty_name,
  -- add 10626 データリストのCTR・DW一括登録修正 房 start
  in_hospital_cd_1,
  in_hospital_cd_2
  -- add 10626 データリストのCTR・DW一括登録修正 房 end
FROM
  mst_dialysis_difficulty
WHERE
    dialysis_difficulty_cd in /* dialysisDifficultyCds */(null)

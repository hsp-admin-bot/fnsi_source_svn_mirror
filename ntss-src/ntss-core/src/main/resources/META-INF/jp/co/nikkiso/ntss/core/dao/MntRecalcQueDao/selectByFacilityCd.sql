SELECT
  recalc_que_cd,
  status, facility_cd,
  reg_date,
  end_date,
  content,
  detail,
  reg_id,
  up_id,
  del_flg,
  up_date,
  disp_flg,
  -- 9729-検査再計算ツール画面について 20231115仕様変更 zhoubin add start
  calc_pat_id,
  -- 9729-検査再計算ツール画面について 20231115仕様変更 zhoubin add end
  journal
FROM
  mnt_recalc_que
WHERE
  facility_cd = /*facilityCd*/''
-- 9729-検査再計算ツール画面について 20231115仕様変更 zhoubin del start
--And
--  disp_flg = '1'
-- 9729-検査再計算ツール画面について 20231115仕様変更 zhoubin del end
-- add #8598 検査再計算ツールで対象患者と再計算項目の選択ができず計算ができない dou start
ORDER BY
-- 9729-検査再計算ツール画面について 20231115仕様変更 zhoubin mod start
--   reg_date ASC
  reg_date DESC
-- 9729-検査再計算ツール画面について 20231115仕様変更 zhoubin mod end
-- add #8598 検査再計算ツールで対象患者と再計算項目の選択ができず計算ができない dou end
-- 9729-検査再計算ツール画面について 20231115仕様変更 zhoubin add start
LIMIT 30
-- 9729-検査再計算ツール画面について 20231115仕様変更 zhoubin add end
;

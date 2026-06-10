-- 指定されたord_noの透析回数を更新する
UPDATE
  ord_main
SET
  rst_dialysis_cnt = /*rstDialysisCnt*/0,
  up_date = CURRENT_TIMESTAMP
WHERE
  ord_no = /*ordNo*/0

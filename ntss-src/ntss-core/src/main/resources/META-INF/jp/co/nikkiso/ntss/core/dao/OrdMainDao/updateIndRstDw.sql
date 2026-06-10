-- 指定ord_noでind_dwとrst_dwを更新する
UPDATE
  ord_main
SET
  ind_dw = /*dw*/null,
  rst_dw = /*dw*/null,
  up_date = CURRENT_TIMESTAMP
WHERE
  ord_no = /*ordNo*/0

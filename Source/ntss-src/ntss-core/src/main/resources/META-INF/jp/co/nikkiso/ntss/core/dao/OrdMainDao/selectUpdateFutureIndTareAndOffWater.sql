SELECT
  ord_no
FROM
  ord_main
WHERE
    pat_id = /*patId*/0
  AND
    treat_date >= /*treatDate*/'00000000'
  AND
    treat_week = /*treatWeek*/0
-- add FNSI-予定の場合はord_mainを更新する 趙 start
  AND
    rst_dialysis_state = '0'
-- add FNSI-予定の場合はord_mainを更新する 趙 end


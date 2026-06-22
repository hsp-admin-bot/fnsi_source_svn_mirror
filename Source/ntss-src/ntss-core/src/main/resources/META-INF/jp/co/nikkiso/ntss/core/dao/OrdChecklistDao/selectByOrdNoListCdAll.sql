select
 /*%expand "A" */*
from
  -- 指定オーダー番号、リストコードのチェックリスト実績を取得
  (select
    *
  from ord_checklist
  where
    ord_no in /*ordNos*/(1)
  and
    is_del = '0'
  ) A
;

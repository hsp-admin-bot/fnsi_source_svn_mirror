select
 /*%expand "A" */*
from
  -- 指定オーダー番号、リストコードのチェックリスト実績を取得
  (select
    *
  from ord_checklist
  where
    ord_no = /*ordNo*/1
  /*%if listCd != null */
  and
    list_cd = /*listCd*/1
  /*%end*/
  and
    is_del = '0'
  ) A
;

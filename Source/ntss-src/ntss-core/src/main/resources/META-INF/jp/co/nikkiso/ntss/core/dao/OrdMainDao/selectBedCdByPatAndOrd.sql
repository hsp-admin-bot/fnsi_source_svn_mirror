-- add #9558 機能帳票で正しく変数が引き渡されていない 2024/06/13 高　start
select
  /*%expand "A" */*
from
  ord_main A
where
  /*%if null != patId*/
    A.pat_id = /*patId*/0
  /*%else*/
  A.pat_id IS NULL
  /*%end*/
and A.ord_no = /*ordNo*/0
and A.is_del = '0'
;
-- add #9558 機能帳票で正しく変数が引き渡されていない 2024/06/13 高　end

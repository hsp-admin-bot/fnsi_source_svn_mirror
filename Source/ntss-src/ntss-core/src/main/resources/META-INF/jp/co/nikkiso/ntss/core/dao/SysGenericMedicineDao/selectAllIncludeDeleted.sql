--一般名処方(削除済を含む)
select
  /*%expand "A" */*
from
  sys_generic_medicine A
--add #9589 禁忌・アレルギーマスタ詳細の重複登録と選択状態 20231030 zhaoqi start
order by generic_cd, medicine_type
--add #9589 禁忌・アレルギーマスタ詳細の重複登録と選択状態 20231030 zhaoqi end
;

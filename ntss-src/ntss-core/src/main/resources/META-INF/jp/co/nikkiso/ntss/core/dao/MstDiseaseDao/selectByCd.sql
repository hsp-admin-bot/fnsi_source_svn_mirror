-- add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe start
select
  /*%expand "A" */*
from
  mst_disease A
where
  A.is_del = '0'
and
  A.disease_cd = /* diseaseCd*/'0'
;
-- add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe end

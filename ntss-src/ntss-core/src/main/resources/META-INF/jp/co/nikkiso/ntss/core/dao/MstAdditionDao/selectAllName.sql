-- add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe start
select
    addition_cd,
    addition_name,
    addition_kind
from
    mst_addition A
where
    addition_cd in /* additionCds */(null)
;
-- add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe end

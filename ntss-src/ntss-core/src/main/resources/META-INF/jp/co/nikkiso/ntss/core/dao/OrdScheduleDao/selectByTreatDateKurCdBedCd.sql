-- 治療スケジュールから指定条件に一致する情報を取得する
select
  /*%expand "A"*/*
from
  ord_schedule as A
where
    is_dummy = '0'
  and
--- 施設コード絞り込み
    facility_cd = /* facilityCd */null
--- 透析予定期間(開始日)
  and
    treat_date = /* treatDate */null
--- クール
  and
    kur_cd = /* kurCd */null
--- ベッド
  and
    bed_cd = /* bedCd */null
;
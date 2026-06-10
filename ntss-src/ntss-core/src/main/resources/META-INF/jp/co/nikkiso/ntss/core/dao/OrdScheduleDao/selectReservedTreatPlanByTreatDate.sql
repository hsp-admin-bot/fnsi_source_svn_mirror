-- 治療スケジュールからベッド・クール登録済みの情報を取得する
select
  /*%expand "A"*/*
from
  ord_schedule as A
where
--- 施設コード絞り込み
  facility_cd = /* facilityCd */null
-- del FNSI-FutreNetWeb+SI課題管理No.4220 李 start
--- 患者ID(自分以外)
-- and
--   pat_id <> /* patId */null
-- del FNSI-FutreNetWeb+SI課題管理No.4220 李 end
--- 透析予定期間(開始日)
and
  treat_date = /* treatDate */null
--- クール
and
  kur_cd <> 0
--- ベッド
and
  bed_cd <> 0
;

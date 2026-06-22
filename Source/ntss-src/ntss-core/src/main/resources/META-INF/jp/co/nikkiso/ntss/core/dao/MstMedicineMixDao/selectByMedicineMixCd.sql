--調製薬剤マスタ
select
  /*%expand "A" */*
from
  mst_medicine_mix A   --テーブル名
where
  A.medicine_mix_cd = /* medicineMixCd */0
and
  A.is_del = '0'
--   del 8142 患者経過総合ビューアおよび患者カレンダーが開かなくなる。削除済み、期限切れ、禁忌アレルギーの表示不具合 張 start
-- and
--   A.is_disp = '1'
--   del 8142 患者経過総合ビューアおよび患者カレンダーが開かなくなる。削除済み、期限切れ、禁忌アレルギーの表示不具合 張 end
;

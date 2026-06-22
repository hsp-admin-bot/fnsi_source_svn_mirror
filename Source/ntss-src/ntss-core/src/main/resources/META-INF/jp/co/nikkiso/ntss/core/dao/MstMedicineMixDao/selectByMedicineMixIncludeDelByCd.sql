--調製薬剤マスタ
select
    /*%expand "A" */*
from
    mst_medicine_mix A   --テーブル名
where
        A.medicine_mix_cd = /* medicineMixCd */0
;

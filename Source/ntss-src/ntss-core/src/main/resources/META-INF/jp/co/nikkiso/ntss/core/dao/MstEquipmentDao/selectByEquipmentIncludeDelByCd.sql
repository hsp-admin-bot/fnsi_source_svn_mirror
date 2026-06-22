select
    /*%expand "A" */*
from
    mst_equipment A
where
    A.equipment_cd = /* equipCd */0
;

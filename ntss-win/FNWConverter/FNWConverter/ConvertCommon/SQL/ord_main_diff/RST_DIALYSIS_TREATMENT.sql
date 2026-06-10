select
    RD.DIALYSIS_NO
from
    RST_DIALYSIS RD
    , RST_DIALYSIS_TREATMENT b 
where
    RD.DIALYSIS_NO = b.DIALYSIS_NO 
    and {0}
    AND {1}

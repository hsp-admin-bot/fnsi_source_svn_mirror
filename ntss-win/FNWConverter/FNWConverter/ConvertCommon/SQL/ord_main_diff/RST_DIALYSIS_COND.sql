select
    b.DIALYSIS_NO
from
    RST_DIALYSIS_COND  b
	INNER JOIN RST_DIALYSIS RD  ON b.DIALYSIS_NO = RD.DIALYSIS_NO
where
    {0}
    and b.CTL_NO NOT in ('026', '027', '028') 
    and {1} 
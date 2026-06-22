select
     DISTINCT b.PATID
from
    RST_DIALYSIS b
WHERE b.SERIES_CD = '{SERIES_CD}'
	and {0}
UNION
select
    DISTINCT PATID
from
    RST_MUL_PREDICT b
where {0}
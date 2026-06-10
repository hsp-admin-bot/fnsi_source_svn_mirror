select
	MT.device_mode
from
	ord_main OM
	inner join mst_treatment MT on OM.rst_treatment_cd = MT.treatment_cd  
where
	OM.is_del = '0'
and
	MT.is_del = '0'
and
	OM.ord_no = /*ordNo*/0
;
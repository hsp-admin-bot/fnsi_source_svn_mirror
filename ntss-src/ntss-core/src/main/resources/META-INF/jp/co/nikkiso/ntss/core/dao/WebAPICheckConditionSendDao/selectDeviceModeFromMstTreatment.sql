select
 tre.device_mode
from
 mst_treatment tre,
 ord_main ord
where
 tre.facility_cd = ord.facility_cd
 and
 tre.treatment_cd = ord.ind_treatment_cd
 and
 ord.ord_no = /*ordNo*/1

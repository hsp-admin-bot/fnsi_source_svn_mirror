select
  mst_machine_type.machine_type_cd
from
	ord_main,
	mst_bed,
	mst_machine,
	mst_machine_type
where
	  ord_main.facility_cd = mst_bed.facility_cd
	and
  	ord_main.ind_bed_cd = mst_bed.bed_cd
	and
  	mst_bed.facility_cd = mst_machine.facility_cd
	and
  	mst_bed.machine_no = mst_machine.machine_no
	and
  	mst_machine.machine_type_cd = mst_machine_type.machine_type_cd
	and
    ord_main.ord_no = /*ordNo*/0
